import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/crypto/local_cipher.dart';
import '../../../core/security/biometric_session_protector.dart';
import '../../../core/storage/key_value_store.dart';
import '../domain/wallet_derivation.dart';

class StoredWalletRecord {
  const StoredWalletRecord({
    required this.cipherText,
    required this.nonce,
    required this.salt,
    required this.publicKey,
    this.derivation = WalletDerivation.legacy,
    required this.biometricEnabled,
    this.childModeEnabled = false,
    this.childWalletsJson = const [],
    this.childModePinCipherText = '',
    this.childModePinNonce = '',
    this.childModePinSalt = '',
  });

  final String cipherText;
  final String nonce;
  final String salt;
  final String publicKey;
  final WalletDerivation derivation;
  final bool biometricEnabled;
  final bool childModeEnabled;
  final List<Map<String, dynamic>> childWalletsJson;
  final String childModePinCipherText;
  final String childModePinNonce;
  final String childModePinSalt;

  bool get hasChildModePin =>
      childModePinCipherText.isNotEmpty &&
      childModePinNonce.isNotEmpty &&
      childModePinSalt.isNotEmpty;

  StoredWalletRecord copyWith({
    String? cipherText,
    String? nonce,
    String? salt,
    String? publicKey,
    WalletDerivation? derivation,
    bool? biometricEnabled,
    bool? childModeEnabled,
    List<Map<String, dynamic>>? childWalletsJson,
    String? childModePinCipherText,
    String? childModePinNonce,
    String? childModePinSalt,
    bool clearChildModePin = false,
  }) {
    return StoredWalletRecord(
      cipherText: cipherText ?? this.cipherText,
      nonce: nonce ?? this.nonce,
      salt: salt ?? this.salt,
      publicKey: publicKey ?? this.publicKey,
      derivation: derivation ?? this.derivation,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      childModeEnabled: childModeEnabled ?? this.childModeEnabled,
      childWalletsJson: childWalletsJson ?? this.childWalletsJson,
      childModePinCipherText: clearChildModePin
          ? ''
          : childModePinCipherText ?? this.childModePinCipherText,
      childModePinNonce: clearChildModePin
          ? ''
          : childModePinNonce ?? this.childModePinNonce,
      childModePinSalt: clearChildModePin
          ? ''
          : childModePinSalt ?? this.childModePinSalt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cipherText': cipherText,
      'nonce': nonce,
      'salt': salt,
      'publicKey': publicKey,
      'derivation': derivation.toJson(),
      'biometricEnabled': biometricEnabled,
      'childModeEnabled': childModeEnabled,
      'childWalletsJson': childWalletsJson,
      'childModePinCipherText': childModePinCipherText,
      'childModePinNonce': childModePinNonce,
      'childModePinSalt': childModePinSalt,
    };
  }

  factory StoredWalletRecord.fromJson(Map<String, dynamic> json) {
    return StoredWalletRecord(
      cipherText: json['cipherText'] as String,
      nonce: json['nonce'] as String,
      salt: json['salt'] as String,
      publicKey: json['publicKey'] as String,
      derivation: WalletDerivation.fromJson(
        Map<String, dynamic>.from(
          json['derivation'] as Map<String, dynamic>? ?? const {},
        ),
      ),
      biometricEnabled: json['biometricEnabled'] as bool? ?? false,
      childModeEnabled: json['childModeEnabled'] as bool? ?? false,
      childWalletsJson:
          (json['childWalletsJson'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          const [],
      childModePinCipherText: json['childModePinCipherText'] as String? ?? '',
      childModePinNonce: json['childModePinNonce'] as String? ?? '',
      childModePinSalt: json['childModePinSalt'] as String? ?? '',
    );
  }

  factory StoredWalletRecord.empty() {
    return StoredWalletRecord(
      cipherText: '',
      nonce: '',
      salt: '',
      publicKey: '',
      derivation: WalletDerivation.legacy,
      biometricEnabled: false,
      childModeEnabled: false,
      childWalletsJson: const [],
      childModePinCipherText: '',
      childModePinNonce: '',
      childModePinSalt: '',
    );
  }
}

class UnlockedWalletSession {
  const UnlockedWalletSession({
    required this.publicKey,
    required this.mnemonic,
  });

  final String publicKey;
  final String mnemonic;
}

class BiometricWalletSession {
  const BiometricWalletSession({
    required this.publicKey,
    required this.mnemonic,
  });

  final String publicKey;
  final String mnemonic;
}

class WalletRepository {
  static const _childModePinMarker = 'benny-child-mode-pin';

  WalletRepository(this._store, this._cipher, this._biometricSessionProtector);

  final KeyValueStore _store;
  final LocalCipher _cipher;
  final BiometricSessionProtector _biometricSessionProtector;

  Future<bool> hasWallet() async => (await readRecords()).isNotEmpty;

  Future<List<StoredWalletRecord>> readRecords() async {
    final recordsJson = await _store.read(AppConstants.walletRecordsKey);
    final decodedRecords = _decodeRecords(recordsJson);
    if (decodedRecords != null) {
      return decodedRecords;
    }

    final legacyRecord = await _readLegacyRecord();
    if (legacyRecord == null) {
      return const [];
    }

    await _persistRecords([
      legacyRecord,
    ], selectedPublicKey: legacyRecord.publicKey);
    await _clearLegacyKeys();
    return [legacyRecord];
  }

  Future<List<String>> listWalletPublicKeys() async {
    final records = await readRecords();
    return records.map((record) => record.publicKey).toList(growable: false);
  }

  Future<StoredWalletRecord?> readRecord({String? publicKey}) async {
    final records = await readRecords();
    if (records.isEmpty) {
      return null;
    }

    final selectedPublicKey =
        publicKey ??
        await _store.read(AppConstants.selectedWalletPublicKeyKey) ??
        records.first.publicKey;
    final record = _findRecord(records, selectedPublicKey) ?? records.first;

    if (record.publicKey != selectedPublicKey) {
      await _store.write(
        AppConstants.selectedWalletPublicKeyKey,
        record.publicKey,
      );
    }

    return record;
  }

  Future<void> saveWallet({
    required String mnemonic,
    required String pin,
    required String publicKey,
    required WalletDerivation derivation,
    required bool biometricEnabled,
  }) async {
    final encrypted = await _cipher.encryptText(mnemonic, pin);
    final newRecord = StoredWalletRecord(
      cipherText: encrypted.cipherText,
      nonce: encrypted.nonce,
      salt: encrypted.salt,
      publicKey: publicKey,
      derivation: derivation,
      biometricEnabled: biometricEnabled,
    );

    await _persistRecords([newRecord], selectedPublicKey: publicKey);
    await _clearLegacyKeys();
  }

  Future<String> decryptMnemonic({
    required String pin,
    required StoredWalletRecord record,
  }) {
    return _cipher.decryptText(
      cipherText: record.cipherText,
      nonce: record.nonce,
      salt: record.salt,
      pin: pin,
    );
  }

  Future<void> selectWallet(String publicKey) async {
    final records = await readRecords();
    if (_findRecord(records, publicKey) == null) {
      throw StateError('Wallet not found: $publicKey');
    }

    await _store.write(AppConstants.selectedWalletPublicKeyKey, publicKey);
  }

  Future<void> persistUnlockedSession({
    required String publicKey,
    required String mnemonic,
  }) async {
    // Plaintext unlocked sessions are intentionally not persisted.
    await _store.write(AppConstants.unlockedSessionPublicKeyKey, publicKey);
    await _store.delete(AppConstants.unlockedSessionMnemonicKey);
  }

  Future<UnlockedWalletSession?> readUnlockedSession() async => null;

  Future<void> clearUnlockedSession() {
    return _store.deleteAll(const [
      AppConstants.unlockedSessionPublicKeyKey,
      AppConstants.unlockedSessionMnemonicKey,
    ]);
  }

  Future<void> persistBiometricSession({
    required String publicKey,
    required String mnemonic,
  }) async {
    final encrypted = await _biometricSessionProtector.encrypt(mnemonic);

    await _store.write(AppConstants.biometricPublicKeyKey, publicKey);

    await _store.write(
      AppConstants.biometricMnemonicKey,
      jsonEncode({
        'cipherText': encrypted.cipherText,
        'nonce': encrypted.nonce,
        'salt': encrypted.salt,
      }),
    );

    debugPrint('[SECURITY] Biometric session stored encrypted');
  }

  Future<BiometricWalletSession?> readBiometricSession() async {
    final publicKey = await _store.read(AppConstants.biometricPublicKeyKey);
    final encryptedJson = await _store.read(AppConstants.biometricMnemonicKey);
    if (publicKey == null || encryptedJson == null) {
      return null;
    }

    try {
      final encrypted = jsonDecode(encryptedJson) as Map<String, dynamic>;
      final decrypted = await _biometricSessionProtector.decrypt(
        cipherText: encrypted['cipherText'] as String,
        nonce: encrypted['nonce'] as String,
        salt: encrypted['salt'] as String? ?? '',
      );

      debugPrint('[SECURITY] Biometric session decrypted successfully');
      return BiometricWalletSession(publicKey: publicKey, mnemonic: decrypted);
    } catch (e) {
      debugPrint('[SECURITY] Failed to decrypt biometric session: $e');
      return null;
    }
  }

  Future<void> clearBiometricSession() async {
    await _biometricSessionProtector.clear();
    await _store.deleteAll(const [
      AppConstants.biometricPublicKeyKey,
      AppConstants.biometricMnemonicKey,
    ]);
  }

  Future<void> updateBiometricEnabled({
    required String publicKey,
    required bool biometricEnabled,
  }) async {
    final records = await readRecords();
    final updatedRecords = [
      for (final record in records)
        if (record.publicKey == publicKey)
          record.copyWith(biometricEnabled: biometricEnabled)
        else
          record,
    ];
    await _persistRecords(updatedRecords, selectedPublicKey: publicKey);
  }

  Future<void> enableChildMode({
    required String publicKey,
    required String childModePin,
  }) async {
    final encrypted = await _cipher.encryptText(
      _childModePinMarker,
      childModePin,
    );
    final records = await readRecords();
    final updatedRecords = [
      for (final record in records)
        if (record.publicKey == publicKey)
          record.copyWith(
            childModeEnabled: true,
            childModePinCipherText: encrypted.cipherText,
            childModePinNonce: encrypted.nonce,
            childModePinSalt: encrypted.salt,
          )
        else
          record,
    ];
    await _persistRecords(updatedRecords, selectedPublicKey: publicKey);
  }

  Future<void> disableChildMode({required String publicKey}) async {
    final records = await readRecords();
    final updatedRecords = [
      for (final record in records)
        if (record.publicKey == publicKey)
          record.copyWith(childModeEnabled: false, clearChildModePin: true)
        else
          record,
    ];
    await _persistRecords(updatedRecords, selectedPublicKey: publicKey);
  }

  Future<void> verifyChildModePin({
    required StoredWalletRecord record,
    required String childModePin,
  }) async {
    if (!record.hasChildModePin) {
      return;
    }

    final marker = await _cipher.decryptText(
      cipherText: record.childModePinCipherText,
      nonce: record.childModePinNonce,
      salt: record.childModePinSalt,
      pin: childModePin,
    );

    if (marker != _childModePinMarker) {
      throw const FormatException('Invalid child mode PIN.');
    }
  }

  Future<void> applyCloudChildSettings({
    required String publicKey,
    required bool childModeEnabled,
    required String childModePinCipherText,
    required String childModePinNonce,
    required String childModePinSalt,
    required List<Map<String, dynamic>> childWalletsJson,
  }) async {
    final records = await readRecords();
    final updatedRecords = [
      for (final record in records)
        if (record.publicKey == publicKey)
          record.copyWith(
            childModeEnabled: childModeEnabled,
            childModePinCipherText: childModePinCipherText,
            childModePinNonce: childModePinNonce,
            childModePinSalt: childModePinSalt,
            childWalletsJson: childWalletsJson,
            clearChildModePin: !childModeEnabled,
          )
        else
          record,
    ];
    await _persistRecords(updatedRecords, selectedPublicKey: publicKey);
  }

  Future<void> addChildWallet({
    required String publicKey,
    required String childId,
    required String childName,
    required String childAddress,
  }) async {
    final records = await readRecords();
    final updatedRecords = [
      for (final record in records)
        if (record.publicKey == publicKey)
          record.copyWith(
            childWalletsJson: [
              ...record.childWalletsJson,
              {'id': childId, 'name': childName, 'address': childAddress},
            ],
          )
        else
          record,
    ];
    await _persistRecords(updatedRecords, selectedPublicKey: publicKey);
  }

  Future<void> updateChildWallet({
    required String publicKey,
    required String childId,
    required String childName,
    required String childAddress,
  }) async {
    final records = await readRecords();
    final updatedRecords = [
      for (final record in records)
        if (record.publicKey == publicKey)
          record.copyWith(
            childWalletsJson: [
              for (final child in record.childWalletsJson)
                if (child['id'] == childId)
                  {'id': childId, 'name': childName, 'address': childAddress}
                else
                  child,
            ],
          )
        else
          record,
    ];
    await _persistRecords(updatedRecords, selectedPublicKey: publicKey);
  }

  Future<void> removeChildWallet({
    required String publicKey,
    required String childId,
  }) async {
    final records = await readRecords();
    final updatedRecords = [
      for (final record in records)
        if (record.publicKey == publicKey)
          record.copyWith(
            childWalletsJson: [
              for (final child in record.childWalletsJson)
                if (child['id'] != childId) child,
            ],
          )
        else
          record,
    ];
    await _persistRecords(updatedRecords, selectedPublicKey: publicKey);
  }

  Future<void> removeWallet(String publicKey) async {
    final records = await readRecords();
    final updatedRecords = [
      for (final record in records)
        if (record.publicKey != publicKey) record,
    ];

    if (updatedRecords.isEmpty) {
      await clearAll();
      return;
    }

    final selectedPublicKey = await _store.read(
      AppConstants.selectedWalletPublicKeyKey,
    );
    final nextSelectedPublicKey =
        selectedPublicKey == null || selectedPublicKey == publicKey
        ? updatedRecords.first.publicKey
        : selectedPublicKey;

    await _persistRecords(
      updatedRecords,
      selectedPublicKey: nextSelectedPublicKey,
    );

    final session = await readUnlockedSession();
    if (session?.publicKey == publicKey) {
      await clearUnlockedSession();
    }

    final biometricSession = await readBiometricSession();
    if (biometricSession?.publicKey == publicKey) {
      await clearBiometricSession();
    }
  }

  Future<void> clear() {
    return clearAll();
  }

  Future<void> clearAll() async {
    await _biometricSessionProtector.clear();
    await _store.deleteAll(const [
      AppConstants.walletRecordsKey,
      AppConstants.selectedWalletPublicKeyKey,
      AppConstants.backendAccessSessionKey,
      AppConstants.unlockedSessionPublicKeyKey,
      AppConstants.unlockedSessionMnemonicKey,
      AppConstants.biometricPublicKeyKey,
      AppConstants.biometricMnemonicKey,
      AppConstants.walletCipherTextKey,
      AppConstants.walletNonceKey,
      AppConstants.walletSaltKey,
      AppConstants.walletPublicKeyKey,
      AppConstants.biometricEnabledKey,
    ]);
  }

  List<StoredWalletRecord>? _decodeRecords(String? recordsJson) {
    if (recordsJson == null || recordsJson.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(recordsJson);
      if (decoded is! List<dynamic>) {
        return null;
      }

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(StoredWalletRecord.fromJson)
          .toList(growable: false);
    } catch (_) {
      return null;
    }
  }

  Future<StoredWalletRecord?> _readLegacyRecord() async {
    final cipherText = await _store.read(AppConstants.walletCipherTextKey);
    final nonce = await _store.read(AppConstants.walletNonceKey);
    final salt = await _store.read(AppConstants.walletSaltKey);
    final publicKey = await _store.read(AppConstants.walletPublicKeyKey);
    final biometricEnabled = await _store.read(
      AppConstants.biometricEnabledKey,
    );

    if (cipherText == null ||
        nonce == null ||
        salt == null ||
        publicKey == null) {
      return null;
    }

    return StoredWalletRecord(
      cipherText: cipherText,
      nonce: nonce,
      salt: salt,
      publicKey: publicKey,
      biometricEnabled: biometricEnabled == 'true',
    );
  }

  Future<void> _persistRecords(
    List<StoredWalletRecord> records, {
    required String selectedPublicKey,
  }) async {
    final encoded = jsonEncode(
      records.map((record) => record.toJson()).toList(growable: false),
    );
    await _store.write(AppConstants.walletRecordsKey, encoded);
    await _store.write(
      AppConstants.selectedWalletPublicKeyKey,
      selectedPublicKey,
    );
  }

  Future<void> _clearLegacyKeys() {
    return _store.deleteAll(const [
      AppConstants.walletCipherTextKey,
      AppConstants.walletNonceKey,
      AppConstants.walletSaltKey,
      AppConstants.walletPublicKeyKey,
      AppConstants.biometricEnabledKey,
    ]);
  }

  StoredWalletRecord? _findRecord(
    List<StoredWalletRecord> records,
    String publicKey,
  ) {
    for (final record in records) {
      if (record.publicKey == publicKey) {
        return record;
      }
    }
    return null;
  }
}
