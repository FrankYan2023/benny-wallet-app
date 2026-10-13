import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

class BiometricAuthService {
  BiometricAuthService({LocalAuthentication? auth})
    : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  /// Check if device supports biometrics
  Future<bool> isSupported() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final biometrics = await _auth.getAvailableBiometrics();
      final result = canCheck && biometrics.isNotEmpty;
      debugPrint('[SECURITY] Biometric supported: $result');
      return result;
    } catch (e) {
      debugPrint('[SECURITY] Biometric check failed: $e');
      return false;
    }
  }

  /// Get available biometric types (fingerprint, face, etc.)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final biometrics = await _auth.getAvailableBiometrics();
      debugPrint('[SECURITY] Available biometrics: $biometrics');
      return biometrics;
    } catch (e) {
      debugPrint('[SECURITY] Failed to get biometrics: $e');
      return [];
    }
  }

  /// Authenticate for wallet unlock (5-minute session TTL)
  /// Uses sticky auth for better UX
  Future<bool> authenticateForUnlock({String? localizedReason}) async {
    final supported = await isSupported();
    if (!supported) {
      debugPrint('[SECURITY] Biometric not supported, skipping unlock');
      return false;
    }

    try {
      final authenticated = await _auth.authenticate(
        localizedReason:
            localizedReason ?? 'Use biometrics to unlock your Benny Wallet.',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      if (authenticated) {
        debugPrint('[SECURITY] Biometric unlock approved');
      } else {
        debugPrint('[SECURITY] Biometric unlock rejected');
      }
      return authenticated;
    } catch (e) {
      debugPrint('[SECURITY] Biometric unlock failed: $e');
      return false;
    }
  }

  /// Authenticate for enabling/setting up biometrics
  /// More strict than unlock (requires explicit approval each time)
  Future<bool> authenticateForSetup({String? localizedReason}) async {
    final supported = await isSupported();
    if (!supported) {
      debugPrint('[SECURITY] Biometric not supported for setup');
      return false;
    }

    try {
      final authenticated = await _auth.authenticate(
        localizedReason:
            localizedReason ??
            'Verify with biometrics to enable this security feature.',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: false, // No sticky auth for setup (more secure)
          useErrorDialogs: true,
        ),
      );

      if (authenticated) {
        debugPrint('[SECURITY] Biometric setup approved');
      } else {
        debugPrint('[SECURITY] Biometric setup rejected');
      }
      return authenticated;
    } catch (e) {
      debugPrint('[SECURITY] Biometric setup failed: $e');
      return false;
    }
  }

  /// Check if device can check biometrics (required for secure storage)
  Future<bool> canCheckBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }
}
