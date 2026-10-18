import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solana/base58.dart';
import 'package:solana/solana.dart';

import '../../app/di/providers.dart';
import '../../features/auth/domain/wallet_derivation.dart';
import '../../features/auth/domain/wallet_controller_state.dart';
import '../../features/auth/presentation/providers/ephemeral_store.dart';
import '../../features/auth/presentation/providers/wallet_controller.dart';
import '../constants/app_constants.dart';
import '../services/mobile_wallet_adapter_service.dart';
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

class MobileWalletBackendAuthentication {
  const MobileWalletBackendAuthentication({
    required this.authToken,
    required this.session,
  });

  final String authToken;
  final BackendAccessSession session;
}

class SeedVaultBackendAuthentication {
  const SeedVaultBackendAuthentication({required this.session});

  final BackendAccessSession session;
}

class BackendSessionManager {
  BackendSessionManager({
    required Ref ref,
    required KeyValueStore store,
    required WalletAuthApiClient authApiClient,
    required MobileWalletAdapterService mobileWalletAdapterService,
    DateTime Function()? clock,
  }) : _ref = ref,
       _store = store,
       _authApiClient = authApiClient,
       _mobileWalletAdapterService = mobileWalletAdapterService,
       _clock = clock ?? DateTime.now;

  static const _refreshSkew = Duration(minutes: 5);

  final Ref _ref;
  final KeyValueStore _store;
  final WalletAuthApiClient _authApiClient;
  final MobileWalletAdapterService _mobileWalletAdapterService;
  final DateTime Function() _clock;

  // Sessions are kept per wallet so switching wallets does not force a new
  // challenge signature (which prompts external wallets every time).
  Map<String, BackendAccessSession>? _sessions;
  final Map<String, Future<BackendAccessSession>> _inFlightAuthentications = {};

  Future<Map<String, String>> currentHeaders() async {
    final session = await currentSession();
    return headersFor(session);
  }

  Map<String, String> headersFor(BackendAccessSession session) {
    return {'Authorization': 'Bearer ${session.accessToken}'};
  }

  Future<BackendAccessSession> currentSession() async {
    final walletState = _ref.read(walletControllerProvider);
    final ownerAddress = walletState.publicKey;
    if (!walletState.isUnlocked ||
        ownerAddress == null ||
        ownerAddress.isEmpty) {
      throw StateError(
        'Unlock your wallet to access protected backend features.',
      );
    }

    final stored = await _usableSession(ownerAddress);
    if (stored != null) {
      return stored;
    }

    return _authenticateOnce(ownerAddress, () => _authenticate(ownerAddress));
  }

  /// Session for a local (mnemonic) wallet that may not be the selected one,
  /// e.g. to register push notifications for every wallet after unlock.
  Future<BackendAccessSession> sessionForLocalWallet({
    required String ownerAddress,
    required String mnemonic,
    required WalletDerivation derivation,
  }) async {
    final stored = await _usableSession(ownerAddress);
    if (stored != null) {
      return stored;
    }

    return _authenticateOnce(ownerAddress, () async {
      final challenge = await _authApiClient.createChallenge(ownerAddress);
      final signature = await _signWithMnemonic(
        mnemonic: mnemonic,
        derivation: derivation,
        message: challenge.message,
      );
      final session = await _authApiClient.verifyChallenge(
        ownerAddress: ownerAddress,
        challenge: challenge.challenge,
        signature: signature,
      );
      return _storeSession(session);
    });
  }

  /// Stored, non-expiring session for [ownerAddress], without signing.
  Future<BackendAccessSession?> storedSessionFor(String ownerAddress) {
    return _usableSession(ownerAddress);
  }

  Future<void> clear() async {
    _sessions = {};
    _inFlightAuthentications.clear();
    await _store.deleteAll(const [
      AppConstants.backendAccessSessionKey,
      AppConstants.backendAccessSessionsKey,
    ]);
  }

  Future<void> clearOwner(String ownerAddress) async {
    final sessions = await _loadSessions();
    _inFlightAuthentications.remove(ownerAddress);
    if (sessions.remove(ownerAddress) != null) {
      await _persistSessions(sessions);
    }
  }

  Future<BackendAccessSession> _authenticateOnce(
    String ownerAddress,
    Future<BackendAccessSession> Function() authenticate,
  ) async {
    final inFlight = _inFlightAuthentications[ownerAddress];
    if (inFlight != null) {
      return inFlight;
    }

    final future = authenticate();
    _inFlightAuthentications[ownerAddress] = future;
    try {
      return await future;
    } finally {
      if (identical(_inFlightAuthentications[ownerAddress], future)) {
        _inFlightAuthentications.remove(ownerAddress);
      }
    }
  }

  Future<MobileWalletBackendAuthentication> authenticateMobileWallet({
    required String ownerAddress,
    required String authToken,
  }) async {
    final challenge = await _authApiClient.createChallenge(ownerAddress);
    final result = await _mobileWalletAdapterService.signMessages(
      authToken: authToken,
      messages: [utf8.encode(challenge.message)],
      addresses: [base58decode(ownerAddress)],
    );
    final session = await _authApiClient.verifyChallenge(
      ownerAddress: ownerAddress,
      challenge: challenge.challenge,
      signature: result.signatures.first,
    );
    final backendSession = await _storeSession(session);
    return MobileWalletBackendAuthentication(
      authToken: result.authToken,
      session: backendSession,
    );
  }

  Future<SeedVaultBackendAuthentication> authenticateSeedVault({
    required String ownerAddress,
    required String authToken,
    required String derivationPath,
  }) async {
    final challenge = await _authApiClient.createChallenge(ownerAddress);
    final result = await _mobileWalletAdapterService.signSeedVaultMessages(
      authToken: authToken,
      derivationPath: derivationPath,
      messages: [utf8.encode(challenge.message)],
      ownerAddress: ownerAddress,
      onAccountChanged: (newToken, newPath) => _ref
          .read(walletControllerProvider.notifier)
          .updateSeedVaultAccount(
            publicKey: ownerAddress,
            oldToken: authToken,
            newToken: newToken,
            derivationPath: newPath,
          ),
    );
    final session = await _authApiClient.verifyChallenge(
      ownerAddress: ownerAddress,
      challenge: challenge.challenge,
      signature: result.signatures.first,
    );
    final backendSession = await _storeSession(session);
    return SeedVaultBackendAuthentication(session: backendSession);
  }

  Future<bool> hasUsableStoredSession(String ownerAddress) async {
    return await _usableSession(ownerAddress) != null;
  }

  Future<BackendAccessSession> _authenticate(String ownerAddress) async {
    final challenge = await _authApiClient.createChallenge(ownerAddress);
    final signature = await _signChallengeMessage(
      ownerAddress: ownerAddress,
      message: challenge.message,
    );
    final session = await _authApiClient.verifyChallenge(
      ownerAddress: ownerAddress,
      challenge: challenge.challenge,
      signature: signature,
    );

    return _storeSession(session);
  }

  Future<BackendAccessSession> _storeSession(WalletAuthSession session) async {
    final backendSession = BackendAccessSession(
      accessToken: session.accessToken,
      expiresAt: session.expiresAt,
      ownerAddress: session.ownerAddress,
    );
    final sessions = await _loadSessions();
    sessions[backendSession.ownerAddress] = backendSession;
    await _persistSessions(sessions);
    return backendSession;
  }

  Future<String> _signChallengeMessage({
    required String ownerAddress,
    required String message,
  }) async {
    final walletState = _ref.read(walletControllerProvider);
    // The challenge was requested for [ownerAddress]; if the user switched
    // wallets meanwhile, the current credentials belong to another wallet.
    // Signing with them fails verification, and a Seed Vault retry would
    // move the other wallet onto this wallet's auth token.
    if (walletState.publicKey != ownerAddress) {
      throw StateError('Wallet changed while signing in; try again.');
    }
    if (walletState.custody == WalletCustody.mobileWalletAdapter) {
      final authToken = walletState.mwaAuthToken;
      if (authToken == null || authToken.isEmpty) {
        throw StateError('Connect Seeker Vault again to continue.');
      }

      final result = await _mobileWalletAdapterService.signMessages(
        authToken: authToken,
        messages: [utf8.encode(message)],
        addresses: [base58decode(ownerAddress)],
      );
      await _ref
          .read(walletControllerProvider.notifier)
          .updateMobileWalletAdapterAuthToken(result.authToken);
      return result.signatures.first;
    }
    if (walletState.custody == WalletCustody.airGap) {
      return _ref
          .read(airGapSigningServiceProvider)
          .signMessage(
            ownerAddress: ownerAddress,
            message: Uint8List.fromList(utf8.encode(message)),
            signIn: true,
          );
    }
    if (walletState.custody == WalletCustody.seedVault) {
      final authToken = walletState.mwaAuthToken;
      final derivationPath = walletState.seedVaultDerivationPath;
      if (authToken == null ||
          authToken.isEmpty ||
          derivationPath == null ||
          derivationPath.isEmpty) {
        throw StateError('Connect Seed Vault again to continue.');
      }

      final result = await _mobileWalletAdapterService.signSeedVaultMessages(
        authToken: authToken,
        derivationPath: derivationPath,
        messages: [utf8.encode(message)],
        ownerAddress: ownerAddress,
        onAccountChanged: (newToken, newPath) => _ref
            .read(walletControllerProvider.notifier)
            .updateSeedVaultAccount(
              publicKey: ownerAddress,
              oldToken: authToken,
              newToken: newToken,
              derivationPath: newPath,
            ),
      );
      return result.signatures.first;
    }

    return _signWithMnemonic(
      mnemonic: _readCurrentMnemonic(),
      derivation: _readCurrentDerivation(),
      message: message,
    );
  }

  Future<String> _signWithMnemonic({
    required String mnemonic,
    required WalletDerivation derivation,
    required String message,
  }) {
    // BIP39 seed + ed25519 derivation is CPU heavy; keep it off the UI isolate.
    final account = derivation.accountIndex;
    final change = derivation.changeIndex;
    if (kIsWeb) {
      return _signChallenge(mnemonic, account, change, message);
    }
    return Isolate.run(
      () => _signChallenge(mnemonic, account, change, message),
    );
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

  Future<BackendAccessSession?> _usableSession(String ownerAddress) async {
    final sessions = await _loadSessions();
    final session = sessions[ownerAddress];
    if (session == null) {
      return null;
    }
    if (_isExpiringSoon(session.expiresAt)) {
      sessions.remove(ownerAddress);
      await _persistSessions(sessions);
      return null;
    }
    return session;
  }

  Future<Map<String, BackendAccessSession>> _loadSessions() async {
    final cached = _sessions;
    if (cached != null) {
      return cached;
    }

    final sessions = <String, BackendAccessSession>{};
    try {
      final jsonValue = await _store.read(
        AppConstants.backendAccessSessionsKey,
      );
      final decoded = jsonValue == null ? null : jsonDecode(jsonValue);
      if (decoded is Map<String, dynamic>) {
        for (final entry in decoded.entries) {
          if (entry.value is Map<String, dynamic>) {
            sessions[entry.key] = BackendAccessSession.fromJson(
              entry.value as Map<String, dynamic>,
            );
          }
        }
      }

      // Single-session storage from before multi-wallet support.
      final legacyJson = await _store.read(
        AppConstants.backendAccessSessionKey,
      );
      final legacy = legacyJson == null ? null : jsonDecode(legacyJson);
      if (legacy is Map<String, dynamic>) {
        final session = BackendAccessSession.fromJson(legacy);
        if (session.ownerAddress.isNotEmpty) {
          sessions.putIfAbsent(session.ownerAddress, () => session);
        }
        await _store.delete(AppConstants.backendAccessSessionKey);
      }
    } catch (_) {
      // Corrupt session cache: start empty, sessions are re-created on demand.
    }

    sessions.removeWhere((_, session) => _isExpiringSoon(session.expiresAt));
    _sessions = sessions;
    return sessions;
  }

  Future<void> _persistSessions(Map<String, BackendAccessSession> sessions) {
    _sessions = sessions;
    return _store.write(
      AppConstants.backendAccessSessionsKey,
      jsonEncode({
        for (final entry in sessions.entries) entry.key: entry.value.toJson(),
      }),
    );
  }

  bool _isExpiringSoon(DateTime expiresAt) {
    final now = _clock().toUtc();
    return !expiresAt.toUtc().isAfter(now.add(_refreshSkew));
  }

  void _expireWalletSession() {
    _ref.read(walletControllerProvider.notifier).lock();
  }
}

Future<String> _signChallenge(
  String mnemonic,
  int? account,
  int? change,
  String message,
) async {
  final keyPair = await Ed25519HDKeyPair.fromMnemonic(
    mnemonic,
    account: account,
    change: change,
  );
  final signature = await keyPair.sign(utf8.encode(message));
  return base58encode(signature.bytes.toList(growable: false));
}
