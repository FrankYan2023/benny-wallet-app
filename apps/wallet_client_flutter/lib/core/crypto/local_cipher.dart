import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

class EncryptedPayload {
  const EncryptedPayload({
    required this.cipherText,
    required this.nonce,
    required this.salt,
  });

  final String cipherText;
  final String nonce;
  final String salt;
}

class LocalCipher {
  static const _iterations = 120000;
  static const _saltLength = 16;
  static const _nonceLength = 12;

  final _algorithm = AesGcm.with256bits();
  final _pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: _iterations,
    bits: 256,
  );

  Future<EncryptedPayload> encryptText(String clearText, String pin) async {
    final salt = _randomBytes(_saltLength);
    final nonce = _randomBytes(_nonceLength);
    final secretKey = await _deriveKey(pin, salt);
    final secretBox = await _algorithm.encrypt(
      utf8.encode(clearText),
      secretKey: secretKey,
      nonce: nonce,
    );

    return EncryptedPayload(
      cipherText: base64Encode([...secretBox.cipherText, ...secretBox.mac.bytes]),
      nonce: base64Encode(secretBox.nonce),
      salt: base64Encode(salt),
    );
  }

  Future<String> decryptText({
    required String cipherText,
    required String nonce,
    required String salt,
    required String pin,
  }) async {
    final bytes = base64Decode(cipherText);
    if (bytes.length < 16) {
      throw const FormatException('Invalid cipher text');
    }

    final secretKey = await _deriveKey(pin, base64Decode(salt));
    final secretBox = SecretBox(
      bytes.sublist(0, bytes.length - 16),
      nonce: base64Decode(nonce),
      mac: Mac(bytes.sublist(bytes.length - 16)),
    );

    final decrypted = await _algorithm.decrypt(secretBox, secretKey: secretKey);
    return utf8.decode(decrypted);
  }

  Future<SecretKey> _deriveKey(String pin, List<int> salt) {
    return _pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(pin)),
      nonce: salt,
    );
  }

  Uint8List _randomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(List<int>.generate(length, (_) => random.nextInt(256)));
  }
}

