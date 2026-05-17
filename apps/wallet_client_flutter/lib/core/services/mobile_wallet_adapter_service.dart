import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:solana/base58.dart';

import '../config/app_features.dart';

class MobileWalletConnection {
  const MobileWalletConnection({
    required this.authToken,
    required this.publicKey,
    this.accountLabel,
    this.walletUriBase,
    this.walletIcon,
  });

  final String authToken;
  final String publicKey;
  final String? accountLabel;
  final String? walletUriBase;
  final String? walletIcon;
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

  MobileWalletConnection _connectionFromResult(Map<String, Object?> result) {
    final authToken = result['authToken'] as String?;
    final publicKeyBase64 = result['publicKeyBase64'] as String?;
    if (authToken == null || authToken.isEmpty) {
      throw StateError('Seeker Wallet did not return an auth token.');
    }
    if (publicKeyBase64 == null || publicKeyBase64.isEmpty) {
      throw StateError('Seeker Wallet did not return a public key.');
    }

    return MobileWalletConnection(
      authToken: authToken,
      publicKey: base58encode(base64Decode(publicKeyBase64)),
      accountLabel: result['accountLabel'] as String?,
      walletUriBase: result['walletUriBase'] as String?,
      walletIcon: result['walletIcon'] as String?,
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
