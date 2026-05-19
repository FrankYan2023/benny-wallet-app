import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:solana/base58.dart';

import '../config/app_features.dart';

class MobileWalletConnection {
  const MobileWalletConnection({
    required this.authToken,
    required this.accounts,
    this.walletUriBase,
    this.walletIcon,
  });

  final String authToken;
  final List<MobileWalletAccount> accounts;
  final String? walletUriBase;
  final String? walletIcon;
}

class MobileWalletAccount {
  const MobileWalletAccount({required this.publicKey, this.accountLabel});

  final String publicKey;
  final String? accountLabel;
}

class MobileWalletSignAndSendResult {
  const MobileWalletSignAndSendResult({
    required this.authToken,
    required this.signatures,
  });

  final String authToken;
  final List<String> signatures;
}

class MobileWalletSignMessagesResult {
  const MobileWalletSignMessagesResult({
    required this.authToken,
    required this.signatures,
  });

  final String authToken;
  final List<String> signatures;
}

class SeedVaultAccountSnapshot {
  const SeedVaultAccountSnapshot({
    required this.available,
    required this.hasUnauthorizedSeeds,
    required this.accounts,
  });

  final bool available;
  final bool hasUnauthorizedSeeds;
  final List<SeedVaultAccount> accounts;
}

class SeedVaultAccount {
  const SeedVaultAccount({
    required this.seedAuthToken,
    required this.publicKey,
    required this.derivationPath,
    this.seedName,
    this.accountId,
    this.accountName,
    this.isBackedUp,
    this.isUserWallet,
  });

  final String seedAuthToken;
  final String publicKey;
  final String derivationPath;
  final String? seedName;
  final String? accountId;
  final String? accountName;
  final bool? isBackedUp;
  final bool? isUserWallet;

  String get label {
    final account = accountName?.trim();
    if (account != null && account.isNotEmpty) {
      return account;
    }
    final seed = seedName?.trim();
    if (seed != null && seed.isNotEmpty) {
      return seed;
    }
    return 'Seed Vault Wallet';
  }
}

class SeedVaultSignResult {
  const SeedVaultSignResult({required this.signatures});

  final List<String> signatures;
}

class SeekerDeviceInfo {
  const SeekerDeviceInfo({
    required this.brand,
    required this.manufacturer,
    required this.model,
    required this.fingerprint,
  });

  final String brand;
  final String manufacturer;
  final String model;
  final String fingerprint;

  bool get isSeeker {
    final normalizedModel = model.trim().toLowerCase();
    final normalizedBrand = brand.trim().toLowerCase();
    final normalizedManufacturer = manufacturer.trim().toLowerCase();
    return normalizedModel == 'seeker' &&
        normalizedBrand == 'solanamobile' &&
        normalizedManufacturer == 'solana mobile inc.';
  }
}

class MobileWalletAdapterService {
  static const _channel = MethodChannel('benny_wallet/mobile_wallet_adapter');

  bool get canCheckDevice =>
      AppFeatures.canConnectSeekerVault &&
      !kIsWeb &&
      defaultTargetPlatform == TargetPlatform.android;

  Future<SeekerDeviceInfo?> loadDeviceInfo() async {
    if (!canCheckDevice) {
      return null;
    }

    final result = await _channel.invokeMapMethod<String, Object?>(
      'getDeviceInfo',
    );
    if (result == null) {
      return null;
    }

    return SeekerDeviceInfo(
      brand: result['brand'] as String? ?? '',
      manufacturer: result['manufacturer'] as String? ?? '',
      model: result['model'] as String? ?? '',
      fingerprint: result['fingerprint'] as String? ?? '',
    );
  }

  Future<bool> isSeekerVaultSupported() async {
    final deviceInfo = await loadDeviceInfo();
    return deviceInfo?.isSeeker ?? false;
  }

  Future<bool> isSeedVaultAvailable() async {
    if (!canCheckDevice) {
      return false;
    }
    return await _channel.invokeMethod<bool>('isSeedVaultAvailable') ?? false;
  }

  Future<SeedVaultAccountSnapshot> listSeedVaultAccounts() async {
    await _ensureSupported();
    final result = await _channel.invokeMapMethod<String, Object?>(
      'listSeedVaultAccounts',
    );
    return _seedVaultAccountSnapshotFromResult(result);
  }

  Future<SeedVaultAccountSnapshot> authorizeSeedVaultSeed() async {
    await _ensureSupported();
    final result = await _channel.invokeMapMethod<String, Object?>(
      'authorizeSeedVaultSeed',
    );
    return _seedVaultAccountSnapshotFromResult(result);
  }

  Future<void> deauthorizeSeedVaultSeed(String authToken) async {
    if (!canCheckDevice || authToken.isEmpty) {
      return;
    }
    try {
      await _channel.invokeMethod<bool>('deauthorizeSeedVaultSeed', {
        'authToken': authToken,
      });
    } on PlatformException catch (error) {
      debugPrint('Seed Vault deauthorize failed: ${error.message}');
    }
  }

  Future<void> markSeedVaultAccountAsUserWallet(
    SeedVaultAccount account,
  ) async {
    if (!canCheckDevice ||
        account.seedAuthToken.isEmpty ||
        account.accountId == null ||
        account.accountId!.isEmpty) {
      return;
    }
    try {
      await _channel.invokeMethod<bool>('markSeedVaultAccountAsUserWallet', {
        'authToken': account.seedAuthToken,
        'accountId': account.accountId,
      });
    } on PlatformException catch (error) {
      debugPrint('Seed Vault account metadata update failed: ${error.message}');
    }
  }

  Future<MobileWalletConnection> connect({String? authToken}) async {
    await _ensureSupported();
    final result = await _channel.invokeMapMethod<String, Object?>('connect', {
      if (authToken != null && authToken.isNotEmpty) 'authToken': authToken,
    });
    if (result == null) {
      throw StateError('Mobile Wallet Adapter returned no connection data.');
    }
    return _connectionFromResult(result);
  }

  Future<MobileWalletSignAndSendResult> signAndSendTransactions({
    required String authToken,
    required List<String> encodedTransactions,
  }) async {
    await _ensureSupported();
    if (authToken.isEmpty) {
      throw StateError('Connect a Seeker Vault wallet before signing.');
    }
    if (encodedTransactions.isEmpty) {
      throw ArgumentError.value(
        encodedTransactions,
        'encodedTransactions',
        'Provide at least one transaction.',
      );
    }

    final result = await _channel.invokeMapMethod<String, Object?>(
      'signAndSendTransactions',
      {'authToken': authToken, 'transactions': encodedTransactions},
    );
    if (result == null) {
      throw StateError('Mobile Wallet Adapter returned no signature data.');
    }

    final signaturesBase64 =
        (result['signaturesBase64'] as List<dynamic>? ?? const [])
            .whereType<String>()
            .toList(growable: false);
    final nextAuthToken = result['authToken'] as String? ?? authToken;
    if (signaturesBase64.isEmpty) {
      throw StateError('Seeker Wallet did not return a transaction signature.');
    }

    return MobileWalletSignAndSendResult(
      authToken: nextAuthToken,
      signatures: signaturesBase64
          .map((value) => base58encode(base64Decode(value)))
          .toList(growable: false),
    );
  }

  Future<MobileWalletSignMessagesResult> signMessages({
    required String authToken,
    required List<List<int>> messages,
    required List<List<int>> addresses,
  }) async {
    await _ensureSupported();
    if (authToken.isEmpty) {
      throw StateError('Connect a Seeker Vault wallet before signing.');
    }
    if (messages.isEmpty) {
      throw ArgumentError.value(
        messages,
        'messages',
        'Provide at least one message.',
      );
    }
    if (addresses.isEmpty) {
      throw ArgumentError.value(
        addresses,
        'addresses',
        'Provide at least one signer address.',
      );
    }

    final result = await _channel
        .invokeMapMethod<String, Object?>('signMessages', {
          'authToken': authToken,
          'messages': messages.map(base64Encode).toList(growable: false),
          'addresses': addresses.map(base64Encode).toList(growable: false),
        });
    if (result == null) {
      throw StateError('Mobile Wallet Adapter returned no signature data.');
    }

    final signaturesBase64 =
        (result['signaturesBase64'] as List<dynamic>? ?? const [])
            .whereType<String>()
            .toList(growable: false);
    final nextAuthToken = result['authToken'] as String? ?? authToken;
    if (signaturesBase64.isEmpty) {
      throw StateError('Seeker Wallet did not return a message signature.');
    }

    return MobileWalletSignMessagesResult(
      authToken: nextAuthToken,
      signatures: signaturesBase64
          .map((value) => base58encode(base64Decode(value)))
          .toList(growable: false),
    );
  }

  Future<SeedVaultSignResult> signSeedVaultTransactions({
    required String authToken,
    required String derivationPath,
    required List<String> encodedTransactions,
  }) async {
    await _ensureSupported();
    if (authToken.isEmpty || derivationPath.isEmpty) {
      throw StateError('Connect a Seed Vault wallet before signing.');
    }
    if (encodedTransactions.isEmpty) {
      throw ArgumentError.value(
        encodedTransactions,
        'encodedTransactions',
        'Provide at least one transaction.',
      );
    }

    final result = await _channel
        .invokeMapMethod<String, Object?>('signSeedVaultTransactions', {
          'authToken': authToken,
          'derivationPath': derivationPath,
          'transactions': encodedTransactions,
        });
    return _seedVaultSignResultFromResult(result);
  }

  Future<SeedVaultSignResult> signSeedVaultMessages({
    required String authToken,
    required String derivationPath,
    required List<List<int>> messages,
  }) async {
    await _ensureSupported();
    if (authToken.isEmpty || derivationPath.isEmpty) {
      throw StateError('Connect a Seed Vault wallet before signing.');
    }
    if (messages.isEmpty) {
      throw ArgumentError.value(
        messages,
        'messages',
        'Provide at least one message.',
      );
    }

    final result = await _channel
        .invokeMapMethod<String, Object?>('signSeedVaultMessages', {
          'authToken': authToken,
          'derivationPath': derivationPath,
          'messages': messages.map(base64Encode).toList(growable: false),
        });
    return _seedVaultSignResultFromResult(result);
  }

  MobileWalletConnection _connectionFromResult(Map<String, Object?> result) {
    final authToken = result['authToken'] as String?;
    if (authToken == null || authToken.isEmpty) {
      throw StateError('Seeker Wallet did not return an auth token.');
    }
    final rawAccounts = result['accounts'] as List<dynamic>? ?? const [];
    final accounts = rawAccounts
        .whereType<Map<dynamic, dynamic>>()
        .map((account) {
          final publicKeyBase64 = account['publicKeyBase64'] as String?;
          if (publicKeyBase64 == null || publicKeyBase64.isEmpty) {
            return null;
          }
          return MobileWalletAccount(
            publicKey: base58encode(base64Decode(publicKeyBase64)),
            accountLabel: account['accountLabel'] as String?,
          );
        })
        .nonNulls
        .toList(growable: false);
    if (accounts.isEmpty) {
      throw StateError('Seeker Wallet did not return any accounts.');
    }

    return MobileWalletConnection(
      authToken: authToken,
      accounts: accounts,
      walletUriBase: result['walletUriBase'] as String?,
      walletIcon: result['walletIcon'] as String?,
    );
  }

  SeedVaultAccountSnapshot _seedVaultAccountSnapshotFromResult(
    Map<String, Object?>? result,
  ) {
    if (result == null) {
      throw StateError('Seed Vault returned no account data.');
    }

    final rawAccounts = result['accounts'] as List<dynamic>? ?? const [];
    final accounts = rawAccounts
        .whereType<Map<dynamic, dynamic>>()
        .map(_seedVaultAccountFromResult)
        .nonNulls
        .toList(growable: false);

    return SeedVaultAccountSnapshot(
      available: result['available'] as bool? ?? false,
      hasUnauthorizedSeeds: result['hasUnauthorizedSeeds'] as bool? ?? false,
      accounts: accounts,
    );
  }

  SeedVaultAccount? _seedVaultAccountFromResult(Map<dynamic, dynamic> account) {
    final authToken = account['seedAuthToken'] as String?;
    final derivationPath = account['derivationPath'] as String?;
    if (authToken == null ||
        authToken.isEmpty ||
        derivationPath == null ||
        derivationPath.isEmpty) {
      return null;
    }

    final publicKey = _readSeedVaultPublicKey(account);
    if (publicKey == null || publicKey.isEmpty) {
      return null;
    }

    return SeedVaultAccount(
      seedAuthToken: authToken,
      publicKey: publicKey,
      derivationPath: derivationPath,
      seedName: account['seedName'] as String?,
      accountId: account['accountId'] as String?,
      accountName: account['accountName'] as String?,
      isBackedUp: account['isBackedUp'] as bool?,
      isUserWallet: account['isUserWallet'] as bool?,
    );
  }

  String? _readSeedVaultPublicKey(Map<dynamic, dynamic> account) {
    final encoded = account['publicKeyEncoded'] as String?;
    if (encoded != null && encoded.isNotEmpty) {
      return encoded;
    }
    final rawBase64 = account['publicKeyBase64'] as String?;
    if (rawBase64 == null || rawBase64.isEmpty) {
      return null;
    }
    return base58encode(base64Decode(rawBase64));
  }

  SeedVaultSignResult _seedVaultSignResultFromResult(
    Map<String, Object?>? result,
  ) {
    if (result == null) {
      throw StateError('Seed Vault returned no signature data.');
    }
    final signaturesBase64 =
        (result['signaturesBase64'] as List<dynamic>? ?? const [])
            .whereType<String>()
            .toList(growable: false);
    if (signaturesBase64.isEmpty) {
      throw StateError('Seed Vault did not return a signature.');
    }
    return SeedVaultSignResult(
      signatures: signaturesBase64
          .map((value) => base58encode(base64Decode(value)))
          .toList(growable: false),
    );
  }

  Future<void> _ensureSupported() async {
    if (!await isSeekerVaultSupported()) {
      throw UnsupportedError(
        'Seeker Vault connection is available only on Seeker Android devices.',
      );
    }
  }
}
