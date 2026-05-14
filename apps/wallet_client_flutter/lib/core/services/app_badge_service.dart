import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AppBadgeService {
  static const MethodChannel _channel = MethodChannel('benny_wallet/app_badge');

  bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  Future<void> clearApplicationBadge() async {
    if (!isSupported) {
      return;
    }

    try {
      await _channel.invokeMethod<void>('clearBadge');
    } on PlatformException {
      // Badge APIs vary by platform and launcher; failure should not block app startup.
    } on MissingPluginException {
      // Ignore during tests and unsupported runtimes.
    }
  }
}
