import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../../auth/presentation/providers/wallet_controller.dart';
import '../../domain/entities/portfolio_view_data.dart';

final portfolioCacheProvider = StateProvider<Map<String, PortfolioViewData>>(
  (ref) => const {},
);

final portfolioProvider =
    FutureProvider.family<PortfolioViewData, String>((ref, ownerAddress) async {
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
