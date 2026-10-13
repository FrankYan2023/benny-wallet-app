import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/key_value_store.dart';
import '../../auth/domain/wallet_controller_state.dart';

class InstallAnalyticsRepository {
  InstallAnalyticsRepository(this._store, this._apiClient);

  final KeyValueStore _store;
  final BackendApiClient _apiClient;

  Future<void> registerWalletActivation({
    required WalletControllerState state,
    required String source,
  }) async {
    if (!state.isUnlocked) {
      return;
    }

    final alreadySent = await _store.read(AppConstants.installAnalyticsSentKey);
    if (alreadySent == '1') {
      return;
    }

    final installId = await _readOrCreateInstallId();
    final packageInfo = await PackageInfo.fromPlatform();
    final locale = PlatformDispatcher.instance.locale;

    await _apiClient.registerInstallAnalytics(
      appVersion: packageInfo.version,
      biometricEnabled: state.biometricEnabled,
      buildNumber: packageInfo.buildNumber,
      childModeEnabled: state.childModeEnabled,
      childWalletCount: state.childWallets.length,
      collectedAt: DateTime.now().toUtc().toIso8601String(),
      installId: installId,
      locale: locale.toLanguageTag(),
      platform: _platformName(),
      source: source,
      timeZone: DateTime.now().timeZoneName,
      walletCount: state.walletPublicKeys.length,
    );

    await _store.write(AppConstants.installAnalyticsSentKey, '1');
  }

  Future<String> _readOrCreateInstallId() async {
    final existing = await _store.read(AppConstants.installAnalyticsIdKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final installId = _generateUuidV4();
    await _store.write(AppConstants.installAnalyticsIdKey, installId);
    return installId;
  }

  String _platformName() {
    if (kIsWeb) {
      return 'web';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.linux:
        return 'linux';
      case TargetPlatform.fuchsia:
        return 'unknown';
    }
  }
}

String _generateUuidV4() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;

  String hexByte(int value) => value.toRadixString(16).padLeft(2, '0');

  return [
    for (final value in bytes) hexByte(value),
  ].join().replaceFirstMapped(
    RegExp(
      r'^(.{8})(.{4})(.{4})(.{4})(.{12})$',
    ),
    (match) =>
        '${match.group(1)}-${match.group(2)}-${match.group(3)}-${match.group(4)}-${match.group(5)}',
  );
}
