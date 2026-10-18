import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// One line of the signer's offline checklist.
enum OfflineCheck {
  airplaneMode,
  wifiOff,
  bluetoothOff,
  nfcOff,
  noNetwork,
  usbDebuggingOff,
  simRemoved,
}

class OfflineStatus {
  const OfflineStatus({
    required this.passed,
    required this.detected,
    required this.recommendedOnly,
  });

  /// Checks that pass right now.
  final Set<OfflineCheck> passed;

  /// Checks this platform can detect; the rest the user confirms by hand.
  final Set<OfflineCheck> detected;

  /// Checks that are advice, not a requirement (e.g. removing the SIM).
  final Set<OfflineCheck> recommendedOnly;

  bool isPassed(OfflineCheck check) => passed.contains(check);

  /// True when every required, detectable check passes.
  bool get isOffline => detected
      .where((check) => !recommendedOnly.contains(check))
      .every(passed.contains);

  /// Any live network path at all. Signing is refused while this is true.
  bool get hasNetwork => !passed.contains(OfflineCheck.noNetwork);
}

/// Reads radio state for the signer. Android answers through a platform
/// channel (Settings.Global, no extra permissions); elsewhere only "is there
/// a network" can be detected and the user ticks the rest.
class OfflineStatusService {
  OfflineStatusService({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  static const _channel = MethodChannel('benny_wallet/offline_status');
  final Connectivity _connectivity;

  Future<OfflineStatus> read() async {
    // An unreadable state counts as "a network may be up" (fail closed).
    final results = await _safeConnectivity();
    final noNetwork =
        results != null &&
        results.isNotEmpty &&
        results.every((result) => result == ConnectivityResult.none);

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        final raw = await _channel.invokeMapMethod<String, Object?>('status');
        if (raw != null) {
          bool flag(String key) => raw[key] == true;
          final passed = <OfflineCheck>{
            if (flag('airplaneMode')) OfflineCheck.airplaneMode,
            if (!flag('wifiOn')) OfflineCheck.wifiOff,
            if (!flag('bluetoothOn')) OfflineCheck.bluetoothOff,
            if (!flag('nfcOn')) OfflineCheck.nfcOff,
            if (noNetwork && !flag('hasNetwork')) OfflineCheck.noNetwork,
            if (!flag('usbDebugging')) OfflineCheck.usbDebuggingOff,
            if (!flag('simPresent')) OfflineCheck.simRemoved,
          };
          return OfflineStatus(
            passed: passed,
            detected: OfflineCheck.values.toSet(),
            recommendedOnly: const {OfflineCheck.simRemoved},
          );
        }
      } on PlatformException {
        // Fall through to the generic check.
      } on MissingPluginException {
        // Fall through to the generic check.
      }
    }

    return OfflineStatus(
      passed: {if (noNetwork) OfflineCheck.noNetwork},
      detected: const {OfflineCheck.noNetwork},
      recommendedOnly: const {OfflineCheck.simRemoved},
    );
  }

  Future<void> openAirplaneSettings() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    try {
      await _channel.invokeMethod<bool>('openAirplaneSettings');
    } on Object {
      // Nothing else to try; the checklist explains what to do.
    }
  }

  /// Null when the platform could not say; never "no network" by default.
  Future<List<ConnectivityResult>?> _safeConnectivity() async {
    try {
      return await _connectivity.checkConnectivity();
    } on Object {
      return null;
    }
  }
}
