import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/network/api_client.dart';

class AppUpdateCheckResult {
  const AppUpdateCheckResult({
    required this.currentBuild,
    required this.downloadUrl,
    required this.latestBuild,
    required this.latestVersion,
    required this.message,
    required this.platform,
    required this.required,
    required this.storeUrl,
    required this.title,
    required this.updateAvailable,
  });

  final int currentBuild;
  final String? downloadUrl;
  final int? latestBuild;
  final String? latestVersion;
  final String message;
  final String platform;
  final bool required;
  final String? storeUrl;
  final String title;
  final bool updateAvailable;
}

class AppUpdateRepository {
  AppUpdateRepository(this._apiClient);

  final BackendApiClient _apiClient;

  Future<AppUpdateCheckResult?> checkForUpdate() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentBuild = int.tryParse(packageInfo.buildNumber);
    if (currentBuild == null || currentBuild < 1) {
      return null;
    }

    final platform = _platformName();
    if (platform == 'unknown') {
      return null;
    }

    final remote = await _apiClient.checkAppUpdate(
      buildNumber: currentBuild,
      platform: platform,
    );

    if (!remote.configured || !remote.updateAvailable) {
      return null;
    }

    return AppUpdateCheckResult(
      currentBuild: currentBuild,
      downloadUrl: _cleanUrl(remote.downloadUrl),
      latestBuild: remote.latestBuild,
      latestVersion: remote.latestVersion,
      message:
          _normalizeText(remote.message) ??
          'A newer version of Benny Wallet is available.',
      platform: remote.platform,
      required: remote.required,
      storeUrl: _cleanUrl(remote.storeUrl),
      title: _normalizeText(remote.title) ?? 'Update available',
      updateAvailable: remote.updateAvailable,
    );
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

String? _cleanUrl(String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }

  return normalized;
}

String? _normalizeText(String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }

  return normalized;
}
