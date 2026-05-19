import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../crypto/local_cipher.dart' show EncryptedPayload;

class BiometricSessionProtector {
  const BiometricSessionProtector();

  static const MethodChannel _channel = MethodChannel(
    'benny_wallet/biometric_session',
  );

  bool get supportsPersistentSessionProtection =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<EncryptedPayload> encrypt(String clearText) async {
    if (!supportsPersistentSessionProtection) {
      throw StateError(
        'Persistent biometric unlock is not supported on this device.',
      );
    }

    final payload = await _channel.invokeMethod<Map<Object?, Object?>>(
      'encrypt',
      {'clearText': clearText},
    );
    final cipherText = payload?['cipherText'] as String?;
    final nonce = payload?['nonce'] as String?;
    if (cipherText == null || nonce == null) {
      throw StateError('Biometric encryption did not return a payload.');
    }

    return EncryptedPayload(
      cipherText: cipherText,
      nonce: nonce,
      salt: 'android-keystore',
    );
  }

  Future<String> decrypt({
    required String cipherText,
    required String nonce,
    String salt = '',
  }) async {
    if (!supportsPersistentSessionProtection) {
      throw StateError(
        'Persistent biometric unlock is not supported on this device.',
      );
    }

    final clearText = await _channel.invokeMethod<String>('decrypt', {
      'cipherText': cipherText,
      'nonce': nonce,
    });
    if (clearText == null || clearText.isEmpty) {
      throw StateError('Biometric decryption did not return plaintext.');
    }

    return clearText;
  }

  Future<void> clear() async {
    if (!supportsPersistentSessionProtection) {
      return;
    }

    try {
      await _channel.invokeMethod<void>('clear');
    } on PlatformException {
      // Ignore cleanup failures. Secure storage keys are also cleared at logout.
    }
  }
}
