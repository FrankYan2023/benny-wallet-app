import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'features/settings/data/app_settings_repository.dart';
import 'features/settings/presentation/providers/app_settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
  );
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }
  final initialSettings = await AppSettingsRepository().load();
  runApp(
    ProviderScope(
      overrides: [
        initialAppSettingsProvider.overrideWithValue(initialSettings),
      ],
      child: const WalletApp(),
    ),
  );
}
