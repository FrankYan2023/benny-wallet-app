import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../../auth/presentation/providers/wallet_controller.dart';
import '../../domain/airdrop_view_data.dart';

final activeAirdropProfileProvider = FutureProvider<AirdropProfileViewData>((ref) async {
  final walletState = ref.watch(walletControllerProvider);
  if (!walletState.isUnlocked || walletState.publicKey == null) {
    throw Exception('Unlock your wallet to access the BYC airdrop.');
  }

  return ref.read(airdropRepositoryProvider).loadProfile();
});
