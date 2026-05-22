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

final activePortfolioProvider = Provider<AsyncValue<PortfolioViewData>>((ref) {
  final walletState = ref.watch(walletControllerProvider);
  final publicKey = walletState.publicKey;

  if (!walletState.isUnlocked || publicKey == null) {
    return const AsyncLoading<PortfolioViewData>();
  }

  return ref.watch(portfolioProvider(publicKey));
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
