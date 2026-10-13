import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../../auth/presentation/providers/wallet_controller.dart';
import '../../../../core/config/app_features.dart';
import '../../domain/entities/defi_position_view_data.dart';
import '../../domain/entities/portfolio_view_data.dart';

final portfolioCacheProvider = StateProvider<Map<String, PortfolioViewData>>(
  (ref) => const {},
);

final defiPortfolioCacheProvider =
    StateProvider<Map<String, DefiPortfolioViewData>>((ref) => const {});

final portfolioProvider = FutureProvider.family<PortfolioViewData, String>((
  ref,
  ownerAddress,
) async {
  return ref.read(portfolioRepositoryProvider).loadPortfolio(ownerAddress);
});

/// A transfer this app just sent, shown in balances right away. The backend
/// and its RPC proxy cache balances for several seconds, so a fresh load can
/// still return the pre-transfer amount; the change applies only while the
/// loaded balance still equals [baseline], and for at most [_pendingWindow].
class PendingBalanceChange {
  const PendingBalanceChange({
    required this.address,
    required this.mintAddress,
    required this.delta,
    required this.baseline,
    required this.createdAt,
  });

  final String address;
  final String mintAddress;
  final double delta;
  final double baseline;
  final DateTime createdAt;
}

const _pendingWindow = Duration(seconds: 90);

final pendingBalanceChangesProvider = StateProvider<List<PendingBalanceChange>>(
  (ref) => const [],
);

/// Balance as shown to the user: the loaded portfolio plus any transfer that
/// the backend hasn't caught up with yet.
final displayPortfolioProvider =
    Provider.family<AsyncValue<PortfolioViewData>, String>((ref, address) {
      final raw = ref.watch(portfolioProvider(address));
      final changes = ref
          .watch(pendingBalanceChangesProvider)
          .where((change) => change.address == address)
          .toList(growable: false);
      if (changes.isEmpty) {
        return raw;
      }
      return raw.whenData((data) => applyPendingBalanceChanges(data, changes));
    });

PortfolioViewData applyPendingBalanceChanges(
  PortfolioViewData data,
  List<PendingBalanceChange> changes, {
  DateTime? now,
}) {
  final at = now ?? DateTime.now();
  var totalDelta = 0.0;
  final assets = [
    for (final asset in data.assets)
      () {
        var balance = asset.balance;
        for (final change in changes) {
          if (change.mintAddress != asset.token.mintAddress ||
              at.difference(change.createdAt) > _pendingWindow ||
              (asset.balance - change.baseline).abs() > 1e-9) {
            continue;
          }
          balance += change.delta;
        }
        if (balance == asset.balance) {
          return asset;
        }
        if (balance < 0) {
          balance = 0;
        }
        final price = double.tryParse(asset.priceQuote?.priceUsd ?? '') ?? 0;
        final value = balance * price;
        totalDelta += value - asset.totalValueUsd;
        return AssetHolding(
          token: asset.token,
          category: asset.category,
          balance: balance,
          priceQuote: asset.priceQuote,
          totalValueUsd: value,
          existsOnChain: asset.existsOnChain,
          logoUrl: asset.logoUrl,
          rawAmount: asset.rawAmount,
        );
      }(),
  ];
  if (totalDelta == 0) {
    return data;
  }
  return PortfolioViewData(
    address: data.address,
    assets: assets,
    totalValueUsd: data.totalValueUsd + totalDelta,
    lastUpdatedAt: data.lastUpdatedAt,
  );
}

final activePortfolioProvider = Provider<AsyncValue<PortfolioViewData>>((ref) {
  final walletState = ref.watch(walletControllerProvider);
  final publicKey = walletState.publicKey;

  if (!walletState.isUnlocked || publicKey == null) {
    return const AsyncLoading<PortfolioViewData>();
  }

  return ref.watch(displayPortfolioProvider(publicKey));
});

final defiPortfolioProvider =
    FutureProvider.family<DefiPortfolioViewData, String>((
      ref,
      ownerAddress,
    ) async {
      if (!AppFeatures.canOpenDefiPortfolio) {
        return DefiPortfolioViewData(
          address: ownerAddress,
          totalValueUsd: 0,
          positions: const [],
          lastUpdatedAt: DateTime.now(),
        );
      }
      return ref
          .read(defiPositionRepositoryProvider)
          .loadDefiPositions(ownerAddress);
    });

final activeDefiPortfolioProvider = Provider<AsyncValue<DefiPortfolioViewData>>(
  (ref) {
    final walletState = ref.watch(walletControllerProvider);
    final publicKey = walletState.publicKey;

    if (!walletState.isUnlocked || publicKey == null) {
      return const AsyncLoading<DefiPortfolioViewData>();
    }

    return ref.watch(defiPortfolioProvider(publicKey));
  },
);

/// Reloads [addresses] now, once [signature] is confirmed, and again after the
/// backend caches (portfolio 8 s, RPC proxy up to 15 s) have expired, so the
/// real balance replaces stale or pending figures. Outlives the calling page.
void refreshBalancesAfterTransaction(
  ProviderContainer container, {
  required String signature,
  required List<String> addresses,
}) {
  final solana = container.read(solanaWalletServiceProvider);
  void refresh() {
    for (final address in addresses) {
      container.invalidate(portfolioProvider(address));
    }
  }

  refresh();
  unawaited(() async {
    try {
      await solana.waitForConfirmation(signature);
    } catch (error) {
      debugPrint('[PORTFOLIO] Confirmation wait failed: $error');
    }
    refresh();
    for (final wait in const [Duration(seconds: 10), Duration(seconds: 15)]) {
      await Future<void>.delayed(wait);
      refresh();
    }
  }());
}
