import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solana/base58.dart';
import 'package:solana/solana.dart';

import '../../features/auth/domain/wallet_derivation.dart';
import '../../features/auth/presentation/providers/ephemeral_store.dart';
import '../../features/auth/presentation/providers/wallet_controller.dart';
import '../constants/app_constants.dart';
import '../storage/key_value_store.dart';
import 'wallet_auth_api_client.dart';

class BackendAccessSession {
  const BackendAccessSession({
    required this.accessToken,
    required this.expiresAt,
    required this.ownerAddress,
  });

  final String accessToken;
  final DateTime expiresAt;
  final String ownerAddress;

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'expiresAt': expiresAt.toUtc().toIso8601String(),
      'ownerAddress': ownerAddress,
    };
  }

  factory BackendAccessSession.fromJson(Map<String, dynamic> json) {
    return BackendAccessSession(
      accessToken: json['accessToken'] as String? ?? '',
      expiresAt:
          DateTime.tryParse(json['expiresAt'] as String? ?? '') ??
          DateTime.now().toUtc(),
      ownerAddress: json['ownerAddress'] as String? ?? '',
    );
  }
}

class BackendSessionManager {
  BackendSessionManager({
    required Ref ref,
    required KeyValueStore store,
    required WalletAuthApiClient authApiClient,
    DateTime Function()? clock,
  }) : _ref = ref,
       _store = store,
       _authApiClient = authApiClient,
       _clock = clock ?? DateTime.now;

  static const _refreshSkew = Duration(minutes: 5);

  final Ref _ref;
  final KeyValueStore _store;
  final WalletAuthApiClient _authApiClient;
  final DateTime Function() _clock;

  BackendAccessSession? _cachedSession;
  Future<BackendAccessSession>? _inFlightAuthentication;

  Future<Map<String, String>> currentHeaders() async {
    final session = await currentSession();
    return {'Authorization': 'Bearer ${session.accessToken}'};
  }

  Future<BackendAccessSession> currentSession() async {
    final walletState = _ref.read(walletControllerProvider);
    final ownerAddress = walletState.publicKey;
    if (!walletState.isUnlocked ||
        ownerAddress == null ||
        ownerAddress.isEmpty) {
      await clear();
      throw StateError(
        'Unlock your wallet to access protected backend features.',
      );
    }

    final cachedSession = _cachedSession ?? await _readStoredSession();
    if (cachedSession != null) {
      if (cachedSession.ownerAddress != ownerAddress) {
        await clear();
      } else if (!_isExpiringSoon(cachedSession.expiresAt)) {
        _cachedSession = cachedSession;
        return cachedSession;
      }
    }

    final inFlightAuthentication = _inFlightAuthentication;
    if (inFlightAuthentication != null) {
      return inFlightAuthentication;
    }

    final future = _authenticate(ownerAddress);
    _inFlightAuthentication = future;
    try {
      return await future;
    } finally {
      if (identical(_inFlightAuthentication, future)) {
        _inFlightAuthentication = null;
      }
    }
  }

  Future<void> clear() async {
    _cachedSession = null;
    _inFlightAuthentication = null;
    await _store.delete(AppConstants.backendAccessSessionKey);
  }

  Future<BackendAccessSession> _authenticate(String ownerAddress) async {
    final mnemonic = _readCurrentMnemonic();
    final derivation = _readCurrentDerivation();
    final challenge = await _authApiClient.createChallenge(ownerAddress);
    final keyPair = await Ed25519HDKeyPair.fromMnemonic(
      mnemonic,
      account: derivation.accountIndex,
      change: derivation.changeIndex,
    );
    final signature = await keyPair.sign(utf8.encode(challenge.message));
    final session = await _authApiClient.verifyChallenge(
      ownerAddress: ownerAddress,
      challenge: challenge.challenge,
      signature: base58encode(signature.bytes.toList(growable: false)),
    );

    final backendSession = BackendAccessSession(
      accessToken: session.accessToken,
      expiresAt: session.expiresAt,
      ownerAddress: session.ownerAddress,
    );
    _cachedSession = backendSession;
    await _store.write(
      AppConstants.backendAccessSessionKey,
      jsonEncode(backendSession.toJson()),
    );
    return backendSession;
  }

  String _readCurrentMnemonic() {
    final walletState = _ref.read(walletControllerProvider);
    final mnemonicTokenId = walletState.mnemonicTokenId;
    if (mnemonicTokenId == null || mnemonicTokenId.isEmpty) {
      _expireWalletSession();
      throw StateError('Wallet session expired. Please unlock again.');
    }

    final mnemonic = _ref
        .read(mnemonicEphemeralStoreProvider)
        .retrieveTemporary(mnemonicTokenId);
    if (mnemonic == null || mnemonic.isEmpty) {
      _expireWalletSession();
      throw StateError('Wallet session expired. Please unlock again.');
    }

    return mnemonic;
  }

  WalletDerivation _readCurrentDerivation() {
    final walletState = _ref.read(walletControllerProvider);
    return walletState.derivation;
  }

  Future<BackendAccessSession?> _readStoredSession() async {
    final jsonValue = await _store.read(AppConstants.backendAccessSessionKey);
    if (jsonValue == null || jsonValue.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(jsonValue);
      if (decoded is! Map<String, dynamic>) {
        await clear();
        return null;
      }

      final session = BackendAccessSession.fromJson(decoded);
      if (_isExpiringSoon(session.expiresAt)) {
        await clear();
        return null;
      }

      return session;
    } catch (_) {
      await clear();
      return null;
    }
  }

  bool _isExpiringSoon(DateTime expiresAt) {
    final now = _clock().toUtc();
    return !expiresAt.toUtc().isAfter(now.add(_refreshSkew));
  }

  void _expireWalletSession() {
    _cachedSession = null;
    _inFlightAuthentication = null;
    unawaited(_store.delete(AppConstants.backendAccessSessionKey));
    _ref.read(walletControllerProvider.notifier).lock();
  }
}
