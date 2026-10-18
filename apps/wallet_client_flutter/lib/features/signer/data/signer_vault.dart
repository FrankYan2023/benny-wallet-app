import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import '../../../core/crypto/local_cipher.dart';
import '../../../core/security/biometric_session_protector.dart';
import '../../../core/storage/key_value_store.dart';

/// Which personality the app runs as. Set once on first launch; a signer
/// can only go back to [wallet] by wiping its seed.
enum AppRole { unset, wallet, signer }

class AppRoleStore {
  AppRoleStore(this._store);

  static const _key = 'app_role_v1';
  final KeyValueStore _store;

  Future<AppRole> read() async {
    final String? raw;
    try {
      raw = await _store.read(_key);
    } on Object {
      return AppRole.unset;
    }
    return AppRole.values.firstWhere(
      (role) => role.name == raw,
      orElse: () => AppRole.unset,
    );
  }

  Future<void> write(AppRole role) => _store.write(_key, role.name);

  Future<void> clear() => _store.delete(_key);
}

class SignerWrongPin implements Exception {
  const SignerWrongPin(this.attemptsLeft);

  final int attemptsLeft;
}

/// Raised after too many wrong PINs; the vault has been erased.
class SignerWiped implements Exception {
  const SignerWiped();
}

/// What an unlock opens.
class SignerSession {
  const SignerSession({
    required this.mnemonic,
    required this.accountIndexes,
    required this.masterKey,
  });

  /// Dart strings are immutable and cannot be wiped; the engine keeps its
  /// own zeroable copy of the seed, and this reference is dropped on lock.
  final String mnemonic;
  final List<int> accountIndexes;

  /// Mutable buffer, zeroed by [dispose].
  final List<int> masterKey;

  /// Overwrites the master key bytes. Call once the session is dropped.
  void dispose() {
    try {
      masterKey.fillRange(0, masterKey.length, 0);
    } on UnsupportedError {
      // An unmodifiable list holds no buffer of ours to wipe.
    }
  }
}

class SignerVaultInfo {
  const SignerVaultInfo({
    required this.wordCount,
    required this.accountCount,
    required this.deviceName,
    required this.biometricEnabled,
    required this.appVersionAtLastUnlock,
  });

  final int wordCount;
  final int accountCount;
  final String deviceName;
  final bool biometricEnabled;
  final String? appVersionAtLastUnlock;
}

/// The signer's encrypted seed. Layout mirrors the wallet's two layers:
/// PIN (PBKDF2) → random master key → AES-GCM encrypted mnemonic. The
/// storage itself is the platform keystore-backed secure storage.
class SignerVault {
  SignerVault(this._store, this._cipher, this._biometric);

  static const maxPinAttempts = 10;
  static const maxAccounts = 5;
  static const _vaultKey = 'signer_vault_v1';
  static const _biometricKey = 'signer_biometric_master_v1';

  final KeyValueStore _store;
  final LocalCipher _cipher;
  final BiometricSessionProtector _biometric;

  /// Tail of the queue of vault mutations, per backing store, so that every
  /// read-modify-write of the blob (above all `failedAttempts`) runs one at
  /// a time, even across [SignerVault] instances sharing a store.
  static final Expando<Future<void>> _queues = Expando('signerVaultQueue');

  Future<T> _serial<T>(Future<T> Function() action) {
    final previous = _queues[_store] ?? Future<void>.value();
    final result = previous.then((_) => action());
    _queues[_store] = result.then<void>((_) {}, onError: (Object _) {});
    return result;
  }

  Future<Map<String, dynamic>?> _readVault() async {
    final raw = await _store.read(_vaultKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  Future<void> _writeVault(Map<String, dynamic> vault) =>
      _store.write(_vaultKey, jsonEncode(vault));

  Future<bool> exists() async => await _readVault() != null;

  Future<SignerVaultInfo?> info() async {
    final vault = await _readVault();
    if (vault == null) {
      return null;
    }
    return SignerVaultInfo(
      wordCount: (vault['wordCount'] as num).toInt(),
      accountCount: (vault['accountCount'] as num).toInt(),
      deviceName: vault['deviceName'] as String? ?? '',
      biometricEnabled: await _store.read(_biometricKey) != null,
      appVersionAtLastUnlock: vault['appVersion'] as String?,
    );
  }

  Future<void> create({
    required String mnemonic,
    required String pin,
    required String deviceName,
    int accountCount = 1,
  }) => _serial(() async {
    final masterKey = _cipher.generateMasterKey();
    final masterEnvelope = await _cipher.encryptText(
      base64Encode(masterKey),
      pin,
    );
    final seed = await _cipher.encryptWithKey(mnemonic, masterKey);
    await _writeVault({
      'version': 1,
      'wordCount': mnemonic.trim().split(RegExp(r'\s+')).length,
      'accountCount': accountCount.clamp(1, maxAccounts),
      'deviceName': deviceName,
      'master': _payload(masterEnvelope),
      'seed': _payload(seed),
      'failedAttempts': 0,
    });
    _zero(masterKey);
  });

  /// Throws [SignerWrongPin] or [SignerWiped]. An empty [appVersion]
  /// (unknown) leaves the recorded version as it was.
  Future<SignerSession> unlockWithPin(
    String pin, {
    required String appVersion,
  }) => _serial(() async {
    final (vault, masterKey) = await _checkPin(pin);
    try {
      _recordUnlock(vault, appVersion);
      await _writeVault(vault);
      return await _open(vault, masterKey);
    } on Object {
      _zero(masterKey);
      rethrow;
    }
  });

  Future<SignerSession> unlockWithBiometric({required String appVersion}) =>
      _serial(() async {
        final vault = await _readVault();
        final raw = await _store.read(_biometricKey);
        if (vault == null || raw == null) {
          throw StateError('Biometric unlock is not set up.');
        }
        final payload = Map<String, dynamic>.from(jsonDecode(raw) as Map);
        final clear = await _biometric.decrypt(
          cipherText: payload['cipherText'] as String,
          nonce: payload['nonce'] as String,
        );
        final masterKey = base64Decode(clear);
        try {
          _recordUnlock(vault, appVersion);
          await _writeVault(vault);
          return await _open(vault, masterKey);
        } on Object {
          _zero(masterKey);
          rethrow;
        }
      });

  Future<void> setBiometric(SignerSession session, bool enabled) async {
    if (!enabled) {
      await _store.delete(_biometricKey);
      await _biometric.clear();
      return;
    }
    final payload = await _biometric.encrypt(base64Encode(session.masterKey));
    await _store.write(
      _biometricKey,
      jsonEncode({'cipherText': payload.cipherText, 'nonce': payload.nonce}),
    );
  }

  Future<void> setAccountCount(int count) => _serial(() async {
    final vault = (await _readVault())!;
    vault['accountCount'] = count.clamp(1, maxAccounts);
    await _writeVault(vault);
  });

  /// Checks a PIN without unlocking (used before wipe / settings changes).
  /// Counts exactly like [unlockWithPin]: a wrong PIN uses up an attempt and
  /// the last one erases the vault (then [SignerWiped] is thrown); the
  /// right PIN resets the counter.
  Future<bool> verifyPin(String pin) => _serial(() async {
    try {
      final (vault, masterKey) = await _checkPin(pin);
      _zero(masterKey);
      await _writeVault(vault);
      return true;
    } on SignerWrongPin {
      return false;
    }
  });

  /// Like [verifyPin] but throws [SignerWrongPin] (with the attempts left)
  /// or [SignerWiped] instead of returning false.
  Future<void> checkPin(String pin) => _serial(() async {
    final (vault, masterKey) = await _checkPin(pin);
    _zero(masterKey);
    await _writeVault(vault);
  });

  /// Must run inside [_serial]. On success the returned vault has its
  /// counter reset (not yet written); on failure the counter is written, or
  /// the vault wiped at [maxPinAttempts].
  Future<(Map<String, dynamic>, List<int>)> _checkPin(String pin) async {
    final vault = await _readVault();
    if (vault == null) {
      throw const SignerWiped();
    }
    List<int>? masterKey;
    try {
      masterKey = await _decryptMaster(vault['master'] as Map, pin);
    } on Object {
      masterKey = null;
    }
    if (masterKey == null) {
      final failed = ((vault['failedAttempts'] as num?)?.toInt() ?? 0) + 1;
      if (failed >= maxPinAttempts) {
        await _wipe();
        throw const SignerWiped();
      }
      vault['failedAttempts'] = failed;
      await _writeVault(vault);
      throw SignerWrongPin(maxPinAttempts - failed);
    }
    vault['failedAttempts'] = 0;
    return (vault, masterKey);
  }

  static void _recordUnlock(Map<String, dynamic> vault, String appVersion) {
    vault['failedAttempts'] = 0;
    if (appVersion.isNotEmpty) {
      vault['appVersion'] = appVersion;
    }
  }

  static void _zero(List<int> bytes) {
    try {
      bytes.fillRange(0, bytes.length, 0);
    } on UnsupportedError {
      // Not a buffer we own.
    }
  }

  Future<void> wipe() => _serial(_wipe);

  Future<void> _wipe() async {
    await _store.delete(_vaultKey);
    await _store.delete(_biometricKey);
    try {
      await _biometric.clear();
    } on Object {
      // The keystore key is useless without the stored envelope anyway.
    }
  }

  Future<Uint8List> _decryptMaster(Map envelope, String pin) async {
    final clear = await _cipher.decryptText(
      cipherText: envelope['cipherText'] as String,
      nonce: envelope['nonce'] as String,
      salt: envelope['salt'] as String,
      pin: pin,
    );
    return base64Decode(clear);
  }

  Future<SignerSession> _open(
    Map<String, dynamic> vault,
    List<int> masterKey,
  ) async {
    final seed = vault['seed'] as Map;
    final mnemonic = await _cipher.decryptWithKey(
      cipherText: seed['cipherText'] as String,
      nonce: seed['nonce'] as String,
      key: masterKey,
    );
    final count = (vault['accountCount'] as num).toInt();
    return SignerSession(
      mnemonic: mnemonic,
      accountIndexes: [for (var i = 0; i < count; i++) i],
      masterKey: masterKey,
    );
  }

  static Map<String, String> _payload(EncryptedPayload payload) => {
    'cipherText': payload.cipherText,
    'nonce': payload.nonce,
    'salt': payload.salt,
  };
}
