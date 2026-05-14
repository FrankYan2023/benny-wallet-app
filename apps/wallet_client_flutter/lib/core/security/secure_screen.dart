import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class SecureScreen extends StatefulWidget {
  const SecureScreen({
    super.key,
    required this.child,
    this.enabled = true,
  });

  final Widget child;
  final bool enabled;

  @override
  State<SecureScreen> createState() => _SecureScreenState();
}

class _SecureScreenState extends State<SecureScreen> {
  bool _holdingFlag = false;

  @override
  void initState() {
    super.initState();
    _syncProtection();
  }

  @override
  void didUpdateWidget(covariant SecureScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled) {
      _syncProtection();
    }
  }

  @override
  void dispose() {
    if (_holdingFlag) {
      _holdingFlag = false;
      SecureScreenController.release();
    }
    super.dispose();
  }

  void _syncProtection() {
    final shouldProtect = widget.enabled && SecureScreenController.isSupported;
    if (shouldProtect == _holdingFlag) {
      return;
    }

    _holdingFlag = shouldProtect;
    if (shouldProtect) {
      SecureScreenController.acquire();
    } else {
      SecureScreenController.release();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

abstract final class SecureScreenController {
  static const MethodChannel _channel = MethodChannel(
    'benny_wallet/screen_security',
  );

  static int _holdCount = 0;

  static bool get isSupported =>
      !kIsWeb &&
      defaultTargetPlatform == TargetPlatform.android &&
      !kDebugMode;

  static Future<void> acquire() async {
    if (!isSupported) {
      return;
    }

    _holdCount += 1;
    if (_holdCount == 1) {
      await _setSecure(enabled: true);
    }
  }

  static Future<void> release() async {
    if (!isSupported || _holdCount == 0) {
      return;
    }

    _holdCount -= 1;
    if (_holdCount == 0) {
      await _setSecure(enabled: false);
    }
  }

  static Future<void> _setSecure({required bool enabled}) async {
    try {
      await _channel.invokeMethod<void>('setSecureScreen', {
        'enabled': enabled,
      });
    } on PlatformException {
      // Ignore on unsupported runtimes.
    }
  }
}