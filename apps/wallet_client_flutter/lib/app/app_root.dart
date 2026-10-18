import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/storage/secure_store.dart';
import '../features/settings/presentation/providers/app_settings_controller.dart';
import '../features/signer/data/network_guard.dart';
import '../features/signer/data/signer_vault.dart';
import '../features/signer/presentation/signer_app.dart';
import 'app.dart';
import 'di/providers.dart';

/// The role read at launch; switched at runtime when the user turns this
/// phone into a signer or leaves signer mode before a seed exists.
final appRoleProvider = StateProvider<AppRole>((ref) => AppRole.unset);

class AppRoot extends ConsumerWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(appRoleProvider);
    if (role != AppRole.signer) {
      return const WalletApp();
    }
    return SignerApp(
      locale: ref.watch(appSettingsControllerProvider).languageOption.locale,
      onExit: () async {
        await AppRoleStore(SecureStore()).clear();
        allowNetworkAfterSigner();
        ref.read(appRoleProvider.notifier).state = AppRole.unset;
      },
    );
  }
}

/// Turns this phone into an offline signer. The caller has checked that no
/// wallet is stored.
Future<void> enterSignerMode(WidgetRef ref) async {
  await AppRoleStore(ref.read(secureStoreProvider)).write(AppRole.signer);
  try {
    await ref.read(pushNotificationServiceProvider).stopForSigner();
  } on Object {
    // Push was never set up; nothing to stop.
  }
  blockNetworkForSigner();
  ref.read(appRoleProvider.notifier).state = AppRole.signer;
}
