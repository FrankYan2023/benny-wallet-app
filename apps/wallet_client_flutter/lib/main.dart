import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app_root.dart';
import 'core/storage/secure_store.dart';
import 'core/config/app_features.dart';
import 'features/settings/data/app_settings_repository.dart';
import 'features/settings/presentation/providers/app_settings_controller.dart';
import 'features/signer/data/network_guard.dart';
import 'features/signer/data/signer_vault.dart';

bool _isPhone() {
  final view = PlatformDispatcher.instance.implicitView;
  if (view == null) {
    return true;
  }
  final size = view.physicalSize / view.devicePixelRatio;
  return size.shortestSide < 600;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Phones stay portrait; tablets and foldables may rotate and resize, as
  // Google Play asks for large screens.
  if (_isPhone()) {
    unawaited(
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
    );
  }
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }
  final role = await AppRoleStore(SecureStore()).read();
  if (role == AppRole.signer) {
    // Before anything else can open a connection.
    blockNetworkForSigner();
  }
  final initialSettings = await AppSettingsRepository().load();
  await AppFeatures.loadFullUnlock();
  runApp(
    ProviderScope(
      overrides: [
        initialAppSettingsProvider.overrideWithValue(initialSettings),
        appRoleProvider.overrideWith((ref) => role),
      ],
      child: const AppRoot(),
    ),
  );
}
