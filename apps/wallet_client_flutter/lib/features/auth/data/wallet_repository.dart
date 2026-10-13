import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/crypto/local_cipher.dart';
import '../../../core/security/biometric_session_protector.dart';
import '../../../core/storage/key_value_store.dart';
import '../domain/wallet_controller_state.dart';
import '../domain/wallet_derivation.dart';

WalletCustody _walletCustodyFromJson(String? value) {
  return switch (value) {
    'mobileWalletAdapter' => WalletCustody.mobileWalletAdapter,
    'seedVault' => WalletCustody.seedVault,
    _ => WalletCustody.localMnemonic,
  };
}

/// How a record's secret is encrypted.
/// [pin]: legacy, PBKDF2(PIN) per record. [masterKey]: AES-GCM with the
/// wallet master key, which is itself encrypted by the PIN.
enum WalletSecretScheme { pin, masterKey }

WalletSecretScheme _secretSchemeFromJson(String? value) {
  return value == WalletSecretScheme.masterKey.name
      ? WalletSecretScheme.masterKey
      : WalletSecretScheme.pin;
}

class DuplicateWalletException implements Exception {
  const DuplicateWalletException(this.publicKey);

  final String publicKey;

  @override
  String toString() => 'This wallet has already been added.';
}

class WalletLimitReachedException implements Exception {
  const WalletLimitReachedException(this.limit);

  final int limit;

  @override
  String toString() => 'You can add up to $limit wallets.';
}

/// Records exist but none can prove a PIN (legacy external wallets that were
/// connected before a Benny PIN was required). The next PIN entered becomes
/// the PIN.
class PinSetupRequiredException implements Exception {
  const PinSetupRequiredException();
}

class StoredWalletRecord {
  const StoredWalletRecord({
    required this.cipherText,
    required this.nonce,
    required this.salt,
    required this.publicKey,
    this.derivation = WalletDerivation.legacy,
    this.custody = WalletCustody.localMnemonic,
    this.mwaAuthToken = '',
    this.seedVaultDerivationPath = '',
    this.walletLabel = '',
    this.name = '',
    this.secretScheme = WalletSecretScheme.pin,
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
  final WalletCustody custody;
  final String mwaAuthToken;
  final String seedVaultDerivationPath;
  final String walletLabel;

  /// User-visible wallet name, e.g. "Wallet 1".
  final String name;
  final WalletSecretScheme secretScheme;
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
    WalletCustody? custody,
    String? mwaAuthToken,
    String? seedVaultDerivationPath,
    String? walletLabel,
    String? name,
    WalletSecretScheme? secretScheme,
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
      custody: custody ?? this.custody,
      mwaAuthToken: mwaAuthToken ?? this.mwaAuthToken,
      seedVaultDerivationPath:
          seedVaultDerivationPath ?? this.seedVaultDerivationPath,
      walletLabel: walletLabel ?? this.walletLabel,
      name: name ?? this.name,
      secretScheme: secretScheme ?? this.secretScheme,
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
      'custody': custody.name,
      'mwaAuthToken': mwaAuthToken,
      'seedVaultDerivationPath': seedVaultDerivationPath,
      'walletLabel': walletLabel,
      'name': name,
      'secretScheme': secretScheme.name,
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
      custody: _walletCustodyFromJson(json['custody'] as String?),
      mwaAuthToken: json['mwaAuthToken'] as String? ?? '',
      seedVaultDerivationPath: json['seedVaultDerivationPath'] as String? ?? '',
      walletLabel: json['walletLabel'] as String? ?? '',
      name: json['name'] as String? ?? '',
      secretScheme: _secretSchemeFromJson(json['secretScheme'] as String?),
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
      custody: WalletCustody.localMnemonic,
      mwaAuthToken: '',
      seedVaultDerivationPath: '',
      walletLabel: '',
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
  static const _externalWalletPinMarker = 'benny-external-wallet-pin';
  static const _childModePinMarker = 'benny-child-mode-pin';
  static const maxWalletNameLength = 32;
  static final _defaultNamePattern = RegExp(r'^Wallet (\d+)$');

  WalletRepository(this._store, this._cipher, this._biometricSessionProtector);

  final KeyValueStore _store;
  final LocalCipher _cipher;
  final BiometricSessionProtector _biometricSessionProtector;

  /// Decoded records; secure storage decrypts on every read, so wallet
  /// switching and adding read from memory. Every write goes through
  /// [_persistRecords] or [clearAll], which keep this in sync.
  List<StoredWalletRecord>? _recordsCache;

  Future<bool> hasWallet() async => (await readRecords()).isNotEmpty;

  Future<List<StoredWalletRecord>> readRecords() async {
    final cached = _recordsCache;
    if (cached != null) {
      return cached;
    }
    final recordsJson = await _store.read(AppConstants.walletRecordsKey);
    final decodedRecords = _decodeRecords(recordsJson);
    if (decodedRecords != null) {
      return _recordsCache = await _backfillNames(decodedRecords);
    }

    final legacyRecord = await _readLegacyRecord();
    if (legacyRecord == null) {
      return const [];
    }

    final records = [legacyRecord.copyWith(name: 'Wallet 1')];
    await _persistRecords(records, selectedPublicKey: legacyRecord.publicKey);
    await _clearLegacyKeys();
    return records;
  }

  Future<List<String>> listWalletPublicKeys() async {
    final records = await readRecords();
    return records.map((record) => record.publicKey).toList(growable: false);
  }

  Future<StoredWalletRecord?> readSelectedRecordFrom(
    List<StoredWalletRecord> records, {
    String? publicKey,
  }) async {
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

  Future<StoredWalletRecord?> readRecord({String? publicKey}) async {
    final records = await readRecords();
    return readSelectedRecordFrom(records, publicKey: publicKey);
  }

  /// Default name for the next wallet: "Wallet N", one above the highest
  /// existing default-style name so deleted numbers are not reused.
  String nextDefaultWalletName(List<StoredWalletRecord> records) {
    var highest = 0;
    for (final record in records) {
      final match = _defaultNamePattern.firstMatch(record.name.trim());
      final number = int.tryParse(match?.group(1) ?? '') ?? 0;
      if (number > highest) {
        highest = number;
      }
    }
    return 'Wallet ${(highest > records.length ? highest : records.length) + 1}';
  }

  /// Throws if [publicKey] is already stored or the wallet limit is reached.
  /// The same mnemonic + account always derives the same public key, so the
  /// public key is the duplicate check for mnemonic/account combinations.
  void assertCanAddWallet(List<StoredWalletRecord> records, String publicKey) {
    if (_findRecord(records, publicKey) != null) {
      throw DuplicateWalletException(publicKey);
    }
    if (records.length >= AppConstants.maxWalletCount) {
      throw const WalletLimitReachedException(AppConstants.maxWalletCount);
    }
  }

  Future<bool> hasMasterKey() async =>
      (await _store.read(AppConstants.walletMasterKeyEnvelopeKey)) != null;

  /// Decrypts the master key with [pin], creating it on first use. Any
  /// records still encrypted with the legacy per-record PIN scheme are
  /// migrated to the master key. Throws if the PIN is wrong.
  Future<Uint8List> unlockMasterKey(String pin) async {
    final envelopeJson = await _store.read(
      AppConstants.walletMasterKeyEnvelopeKey,
    );
    final Uint8List masterKey;
    if (envelopeJson != null) {
      final envelope = jsonDecode(envelopeJson) as Map<String, dynamic>;
      masterKey = base64Decode(
        await _cipher.decryptText(
          cipherText: envelope['cipherText'] as String,
          nonce: envelope['nonce'] as String,
          salt: envelope['salt'] as String,
          pin: pin,
        ),
      );
    } else {
      await _verifyLegacyPin(pin, await readRecords());
      masterKey = _cipher.generateMasterKey();
      await _writeMasterKeyEnvelope(masterKey, pin);
    }

    await _migrateLegacyRecords(pin: pin, masterKey: masterKey);
    return masterKey;
  }

  Future<bool> requiresPinSetup() async {
    if (await hasMasterKey()) {
      return false;
    }
    final records = await readRecords();
    return records.isNotEmpty &&
        !records.any(
          (record) =>
              record.secretScheme == WalletSecretScheme.pin &&
              record.cipherText.isNotEmpty &&
              record.nonce.isNotEmpty &&
              record.salt.isNotEmpty,
        );
  }

  /// Creates the master key with a new [pin] for wallets that never had one.
  Future<Uint8List> setupPin(String pin) async {
    if (!await requiresPinSetup()) {
      throw StateError('A PIN is already set.');
    }
    final masterKey = _cipher.generateMasterKey();
    await _writeMasterKeyEnvelope(masterKey, pin);
    await _migrateLegacyRecords(pin: pin, masterKey: masterKey);
    return masterKey;
  }

  /// Adds a Mobile Wallet Adapter / Seed Vault wallet while the app is
  /// already unlocked (the master key exists, no PIN needed).
  Future<void> addExternalWallet({
    required WalletCustody custody,
    required String publicKey,
    required String authToken,
    String derivationPath = '',
    String? walletLabel,
    String? name,
  }) async {
    final records = await readRecords();
    assertCanAddWallet(records, publicKey);
    final newRecord = StoredWalletRecord.empty().copyWith(
      publicKey: publicKey,
      derivation: WalletDerivation.legacy,
      custody: custody,
      mwaAuthToken: authToken,
      seedVaultDerivationPath: derivationPath,
      walletLabel: walletLabel ?? '',
      name: _normalizeName(name) ?? nextDefaultWalletName(records),
      secretScheme: WalletSecretScheme.masterKey,
      biometricEnabled: records.any((record) => record.biometricEnabled),
    );
    await _persistRecords([
      ...records,
      newRecord,
    ], selectedPublicKey: publicKey);
  }

  /// Decrypts a record still on the legacy per-record PIN scheme.
  Future<String> decryptLegacyMnemonic({
    required StoredWalletRecord record,
    required String pin,
  }) => _decryptLegacy(record, pin);

  Future<bool> hasBiometricMasterKey() async =>
      (await _store.read(AppConstants.biometricMasterKeyKey)) != null;

  /// Biometric unlock is device-wide: it unlocks the master key, so the flag
  /// is kept identical on every record.
  Future<void> setBiometricEnabledForAll(bool enabled) async {
    final records = await readRecords();
    if (records.isEmpty) {
      return;
    }
    await _persistRecords([
      for (final record in records) record.copyWith(biometricEnabled: enabled),
    ], selectedPublicKey: await _selectedPublicKeyOr(records.first.publicKey));
  }

  Future<void> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    final masterKey = await unlockMasterKey(currentPin);
    await _writeMasterKeyEnvelope(masterKey, newPin);
  }

  /// First-wallet setup and PIN-based add: unlocks (or creates) the master
  /// key with [pin], then adds the wallet without touching existing ones.
  Future<void> saveWallet({
    required String mnemonic,
    required String pin,
    required String publicKey,
    required WalletDerivation derivation,
    required bool biometricEnabled,
    String? name,
  }) async {
    assertCanAddWallet(await readRecords(), publicKey);
    final masterKey = await unlockMasterKey(pin);
    await addLocalWallet(
      mnemonic: mnemonic,
      masterKey: masterKey,
      publicKey: publicKey,
      derivation: derivation,
      biometricEnabled: biometricEnabled,
      name: name,
    );
  }

  Future<void> addLocalWallet({
    required String mnemonic,
    required List<int> masterKey,
    required String publicKey,
    required WalletDerivation derivation,
    bool biometricEnabled = false,
    String? name,
  }) async {
    final records = await readRecords();
    assertCanAddWallet(records, publicKey);

    final encrypted = await _cipher.encryptWithKey(mnemonic, masterKey);
    final newRecord = StoredWalletRecord(
      cipherText: encrypted.cipherText,
      nonce: encrypted.nonce,
      salt: encrypted.salt,
      publicKey: publicKey,
      derivation: derivation,
      name: _normalizeName(name) ?? nextDefaultWalletName(records),
      secretScheme: WalletSecretScheme.masterKey,
      biometricEnabled:
          biometricEnabled || records.any((record) => record.biometricEnabled),
    );

    await _persistRecords([
      ...records,
      newRecord,
    ], selectedPublicKey: publicKey);
    await _clearLegacyKeys();
  }

  Future<void> saveMobileWalletAdapterWallet({
    required String publicKey,
    required String authToken,
    required String pin,
    String? walletLabel,
    String? name,
  }) {
    return _saveExternalWallet(
      publicKey: publicKey,
      pin: pin,
      name: name,
      build: (record) => record.copyWith(
        custody: WalletCustody.mobileWalletAdapter,
        mwaAuthToken: authToken,
        walletLabel: walletLabel ?? '',
      ),
    );
  }

  Future<void> saveSeedVaultWallet({
    required String publicKey,
    required String authToken,
    required String derivationPath,
    required String pin,
    String? walletLabel,
    String? name,
  }) {
    return _saveExternalWallet(
      publicKey: publicKey,
      pin: pin,
      name: name,
      build: (record) => record.copyWith(
        custody: WalletCustody.seedVault,
        mwaAuthToken: authToken,
        seedVaultDerivationPath: derivationPath,
        walletLabel: walletLabel ?? '',
      ),
    );
  }

  Future<void> _saveExternalWallet({
    required String publicKey,
    required String pin,
    required String? name,
    required StoredWalletRecord Function(StoredWalletRecord) build,
  }) async {
    assertCanAddWallet(await readRecords(), publicKey);
    // External wallets hold no secret; the PIN only gates the master key so
    // every wallet goes through the same authentication.
    await unlockMasterKey(pin);
    final records = await readRecords();
    final newRecord = build(
      StoredWalletRecord.empty().copyWith(
        publicKey: publicKey,
        derivation: WalletDerivation.legacy,
        name: _normalizeName(name) ?? nextDefaultWalletName(records),
        secretScheme: WalletSecretScheme.masterKey,
      ),
    );

    await _persistRecords([
      ...records,
      newRecord,
    ], selectedPublicKey: publicKey);
    await _clearLegacyKeys();
  }

  Future<void> renameWallet({
    required String publicKey,
    required String name,
  }) async {
    final normalized = _normalizeName(name);
    if (normalized == null) {
      throw ArgumentError('Wallet name cannot be empty.');
    }
    final records = await readRecords();
    if (_findRecord(records, publicKey) == null) {
      throw StateError('Wallet not found: $publicKey');
    }
    await _persistRecords([
      for (final record in records)
        if (record.publicKey == publicKey)
          record.copyWith(name: normalized)
        else
          record,
    ], selectedPublicKey: await _selectedPublicKeyOr(records.first.publicKey));
  }

  Future<void> verifyPin({
    required String pin,
    StoredWalletRecord? record,
  }) async {
    await unlockMasterKey(pin);
  }

  /// Points every Seed Vault wallet that signs with [oldToken] at [newToken]
  /// (one seed can back several wallets). Keeps the current selection.
  Future<void> replaceSeedVaultAuthToken({
    required String oldToken,
    required String newToken,
    String? publicKey,
    String? derivationPath,
  }) async {
    final records = await readRecords();
    if (records.isEmpty) {
      return;
    }
    final updatedRecords = [
      for (final record in records)
        if (record.custody == WalletCustody.seedVault &&
            (record.mwaAuthToken == oldToken || record.publicKey == publicKey))
          record.copyWith(
            mwaAuthToken: record.mwaAuthToken == oldToken ? newToken : null,
            seedVaultDerivationPath: record.publicKey == publicKey
                ? derivationPath
                : null,
          )
        else
          record,
    ];
    await _persistRecords(
      updatedRecords,
      selectedPublicKey: await _selectedPublicKeyOr(records.first.publicKey),
    );
  }

  Future<void> updateMobileWalletAdapterAuthToken({
    required String publicKey,
    required String authToken,
  }) async {
    final records = await readRecords();
    final updatedRecords = [
      for (final record in records)
        if (record.publicKey == publicKey)
          record.copyWith(mwaAuthToken: authToken)
        else
          record,
    ];
    await _persistRecords(updatedRecords, selectedPublicKey: publicKey);
  }

  /// PIN-based decryption; runs one PBKDF2 to unlock the master key.
  Future<String> decryptMnemonic({
    required String pin,
    required StoredWalletRecord record,
  }) async {
    final masterKey = await unlockMasterKey(pin);
    final migrated = await readRecord(publicKey: record.publicKey) ?? record;
    return decryptMnemonicWithKey(record: migrated, masterKey: masterKey);
  }

  Future<String> decryptMnemonicWithKey({
    required StoredWalletRecord record,
    required List<int> masterKey,
  }) {
    if (record.custody != WalletCustody.localMnemonic) {
      throw StateError('This wallet is connected through Seeker Vault.');
    }
    if (record.secretScheme != WalletSecretScheme.masterKey) {
      throw StateError('Unlock with your PIN to finish upgrading this wallet.');
    }
    return _cipher.decryptWithKey(
      cipherText: record.cipherText,
      nonce: record.nonce,
      key: masterKey,
    );
  }

  Future<void> _verifyLegacyPin(
    String pin,
    List<StoredWalletRecord> records,
  ) async {
    if (records.isEmpty) {
      return;
    }

    // The local mnemonic's PIN is authoritative; otherwise any external
    // wallet's PIN marker proves the PIN.
    final local = records.where(
      (record) =>
          record.custody == WalletCustody.localMnemonic &&
          record.secretScheme == WalletSecretScheme.pin,
    );
    if (local.isNotEmpty) {
      await _decryptLegacy(local.first, pin);
      return;
    }

    final external = records.where(
      (record) =>
          record.custody != WalletCustody.localMnemonic &&
          record.cipherText.isNotEmpty &&
          record.nonce.isNotEmpty &&
          record.salt.isNotEmpty,
    );
    if (external.isEmpty) {
      throw const PinSetupRequiredException();
    }
    if (await _decryptLegacy(external.first, pin) != _externalWalletPinMarker) {
      throw const FormatException('Invalid PIN.');
    }
  }

  Future<void> _migrateLegacyRecords({
    required String pin,
    required List<int> masterKey,
  }) async {
    final records = await readRecords();
    if (records.every((r) => r.secretScheme == WalletSecretScheme.masterKey)) {
      return;
    }

    final migrated = <StoredWalletRecord>[];
    for (final record in records) {
      if (record.secretScheme == WalletSecretScheme.masterKey) {
        migrated.add(record);
      } else if (record.custody != WalletCustody.localMnemonic) {
        migrated.add(
          record.copyWith(
            cipherText: '',
            nonce: '',
            salt: '',
            secretScheme: WalletSecretScheme.masterKey,
          ),
        );
      } else {
        try {
          final mnemonic = await _decryptLegacy(record, pin);
          final encrypted = await _cipher.encryptWithKey(mnemonic, masterKey);
          migrated.add(
            record.copyWith(
              cipherText: encrypted.cipherText,
              nonce: encrypted.nonce,
              salt: encrypted.salt,
              secretScheme: WalletSecretScheme.masterKey,
            ),
          );
        } catch (_) {
          // Encrypted under a different PIN; keep it until that PIN is used.
          migrated.add(record);
        }
      }
    }

    await _persistRecords(
      migrated,
      selectedPublicKey: await _selectedPublicKeyOr(records.first.publicKey),
    );
    debugPrint('[SECURITY] Wallet records migrated to master key encryption');
  }

  Future<String> _decryptLegacy(StoredWalletRecord record, String pin) {
    return _cipher.decryptText(
      cipherText: record.cipherText,
      nonce: record.nonce,
      salt: record.salt,
      pin: pin,
    );
  }

  Future<void> _writeMasterKeyEnvelope(List<int> masterKey, String pin) async {
    final encrypted = await _cipher.encryptText(base64Encode(masterKey), pin);
    await _store.write(
      AppConstants.walletMasterKeyEnvelopeKey,
      jsonEncode({
        'cipherText': encrypted.cipherText,
        'nonce': encrypted.nonce,
        'salt': encrypted.salt,
      }),
    );
  }

  Future<List<StoredWalletRecord>> _backfillNames(
    List<StoredWalletRecord> records,
  ) async {
    if (records.every((record) => record.name.trim().isNotEmpty)) {
      return records;
    }

    final named = [
      for (var i = 0; i < records.length; i++)
        records[i].name.trim().isNotEmpty
            ? records[i]
            : records[i].copyWith(
                name:
                    _normalizeName(records[i].walletLabel) ?? 'Wallet ${i + 1}',
              ),
    ];
    await _persistRecords(
      named,
      selectedPublicKey: await _selectedPublicKeyOr(records.first.publicKey),
    );
    return named;
  }

  String? _normalizeName(String? name) {
    final trimmed = name?.trim() ?? '';
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed.length > maxWalletNameLength
        ? trimmed.substring(0, maxWalletNameLength)
        : trimmed;
  }

  Future<String> _selectedPublicKeyOr(String fallback) async {
    return await _store.read(AppConstants.selectedWalletPublicKeyKey) ??
        fallback;
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

  /// Stores the master key behind the platform biometric keystore so one
  /// biometric unlock opens every wallet.
  Future<void> persistBiometricMasterKey(List<int> masterKey) async {
    final encrypted = await _biometricSessionProtector.encrypt(
      base64Encode(masterKey),
    );
    await _store.write(
      AppConstants.biometricMasterKeyKey,
      jsonEncode({
        'cipherText': encrypted.cipherText,
        'nonce': encrypted.nonce,
      }),
    );
    // The legacy single-wallet mnemonic session is superseded.
    await _store.deleteAll(const [
      AppConstants.biometricPublicKeyKey,
      AppConstants.biometricMnemonicKey,
    ]);
  }

  Future<Uint8List?> readBiometricMasterKey() async {
    final encryptedJson = await _store.read(AppConstants.biometricMasterKeyKey);
    if (encryptedJson == null) {
      return null;
    }

    try {
      final encrypted = jsonDecode(encryptedJson) as Map<String, dynamic>;
      final decrypted = await _biometricSessionProtector.decrypt(
        cipherText: encrypted['cipherText'] as String,
        nonce: encrypted['nonce'] as String,
      );
      return base64Decode(decrypted);
    } catch (e) {
      debugPrint('[SECURITY] Failed to decrypt biometric master key: $e');
      return null;
    }
  }

  Future<void> clearBiometricSession() async {
    await _biometricSessionProtector.clear();
    await _store.deleteAll(const [
      AppConstants.biometricPublicKeyKey,
      AppConstants.biometricMnemonicKey,
      AppConstants.biometricMasterKeyKey,
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
    _recordsCache = null;
    await _biometricSessionProtector.clear();
    await _store.deleteAll(const [
      AppConstants.walletRecordsKey,
      AppConstants.walletMasterKeyEnvelopeKey,
      AppConstants.biometricMasterKeyKey,
      AppConstants.selectedWalletPublicKeyKey,
      AppConstants.backendAccessSessionKey,
      AppConstants.backendAccessSessionsKey,
      AppConstants.seedVaultSeedNamesKey,
      AppConstants.unlockedSessionPublicKeyKey,
      AppConstants.unlockedSessionMnemonicKey,
      AppConstants.biometricPublicKeyKey,
      AppConstants.biometricMnemonicKey,
      AppConstants.walletCipherTextKey,
      AppConstants.walletNonceKey,
      AppConstants.walletSaltKey,
      AppConstants.walletPublicKeyKey,
      AppConstants.biometricEnabledKey,
      AppConstants.lastPushFcmTokenKey,
      AppConstants.lastPushWalletPublicKeyKey,
      AppConstants.lastPushPermissionStatusKey,
      AppConstants.lastPushRegisteredAtKey,
      AppConstants.pushWalletSyncKey,
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
    _recordsCache = List.unmodifiable(records);
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
