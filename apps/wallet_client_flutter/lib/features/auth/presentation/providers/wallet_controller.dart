import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../../../core/utils/validators.dart';
import '../../../portfolio/presentation/providers/portfolio_provider.dart';
import '../../data/wallet_repository.dart';
import '../../domain/wallet_derivation.dart';
import '../../domain/wallet_controller_state.dart';
import 'ephemeral_store.dart';

class WalletController extends StateNotifier<WalletControllerState> {
  static const _unlockSessionTtl = Duration(minutes: 10);
  static const _biometricSessionTtl = Duration(minutes: 10);

  WalletController(this.ref) : super(WalletControllerState.loading) {
    _bootstrap();
  }

  final Ref ref;

  Future<void> _bootstrap() async {
    final repository = ref.read(walletRepositoryProvider);
    final walletPublicKeys = await repository.listWalletPublicKeys();
    await repository.clearUnlockedSession();
    if (walletPublicKeys.isEmpty) {
      state = WalletControllerState.noWallet;
      return;
    }

    final record = await _sanitizeBiometricRecord(
      repository,
      await repository.readRecord(),
    );
    if (record == null) {
      state = WalletControllerState.noWallet;
      return;
    }

    if (record.custody == WalletCustody.mobileWalletAdapter) {
      final nextState = _resolvedBiometricEnabled(record)
          ? _lockedState(record, walletPublicKeys: walletPublicKeys)
          : _unlockedExternalState(record, walletPublicKeys: walletPublicKeys);
      state = nextState;
      if (nextState.isUnlocked) {
        unawaited(_syncPushNotificationsIfEnabled(nextState));
      }
      return;
    }

    state = _lockedState(record, walletPublicKeys: walletPublicKeys);
  }

  Future<void> importWallet({
    required String mnemonic,
    required String pin,
    required bool biometricEnabled,
    WalletDerivation derivation = WalletDerivation.standard,
    String? publicKey,
  }) async {
    final normalized = Validators.normalizeMnemonic(mnemonic);
    if (!Validators.isValidMnemonic(normalized)) {
      state = state.copyWith(errorMessage: 'Invalid recovery phrase');
      return;
    }

    final solana = ref.read(solanaWalletServiceProvider);
    final repository = ref.read(walletRepositoryProvider);
    final ephemeralStore = ref.read(mnemonicEphemeralStoreProvider);
    final resolvedPublicKey =
        publicKey ??
        await solana.deriveAddress(normalized, derivation: derivation);
    final effectiveBiometricEnabled =
        biometricEnabled && _supportsPersistentBiometricSessions;

    await repository.saveWallet(
      mnemonic: normalized,
      pin: pin,
      publicKey: resolvedPublicKey,
      derivation: derivation,
      biometricEnabled: effectiveBiometricEnabled,
    );

    // 🔐 Security: Store mnemonic in ephemeral provider, not in state
    final token = ephemeralStore.store(normalized, ttl: _unlockSessionTtl);
    debugPrint('[SECURITY] Mnemonic token issued on import.');

    final walletPublicKeys = await repository.listWalletPublicKeys();
    var nextState = WalletControllerState(
      status: WalletStatus.unlocked,
      walletPublicKeys: walletPublicKeys,
      publicKey: resolvedPublicKey,
      derivation: derivation,
      mnemonic: null, // ❌ DO NOT store plaintext
      mnemonicTokenId: token, // ✅ Store only token
      biometricEnabled: effectiveBiometricEnabled,
      childModeEnabled: false,
      hasChildModePin: false,
      childWallets: [],
      loggedOut: false,
    );
    state = nextState;
    nextState = await _syncCloudChildSettings(nextState);
    unawaited(
      _registerAnonymousInstallIfNeeded(nextState, source: 'pin_setup'),
    );
    unawaited(_syncPushNotificationsIfEnabled(nextState));
  }

  Future<void> importMobileWalletAdapterWallet({
    required String publicKey,
    required String authToken,
    required String pin,
    String? walletLabel,
  }) async {
    final repository = ref.read(walletRepositoryProvider);
    await repository.saveMobileWalletAdapterWallet(
      publicKey: publicKey,
      authToken: authToken,
      pin: pin,
      walletLabel: walletLabel,
    );

    final walletPublicKeys = await repository.listWalletPublicKeys();
    final record = await repository.readRecord(publicKey: publicKey);
    if (record == null) {
      state = WalletControllerState.noWallet;
      return;
    }

    var nextState = _unlockedExternalState(
      record,
      walletPublicKeys: walletPublicKeys,
    );
    state = nextState;
    nextState = await _syncCloudChildSettings(nextState);
    unawaited(
      _registerAnonymousInstallIfNeeded(nextState, source: 'pin_setup'),
    );
    unawaited(_syncPushNotificationsIfEnabled(nextState));
  }

  Future<void> updateMobileWalletAdapterAuthToken(String authToken) async {
    final publicKey = state.publicKey;
    if (publicKey == null || !state.isExternalWallet) {
      return;
    }
    await ref
        .read(walletRepositoryProvider)
        .updateMobileWalletAdapterAuthToken(
          publicKey: publicKey,
          authToken: authToken,
        );
    state = state.copyWith(mwaAuthToken: authToken, clearError: true);
  }

  Future<void> unlock(String pin) async {
    final repository = ref.read(walletRepositoryProvider);
    final ephemeralStore = ref.read(mnemonicEphemeralStoreProvider);
    final walletPublicKeys = await repository.listWalletPublicKeys();
    final record = await _sanitizeBiometricRecord(
      repository,
      await repository.readRecord(),
    );
    if (record == null) {
      state = WalletControllerState.noWallet;
      return;
    }

    try {
      if (record.custody == WalletCustody.mobileWalletAdapter) {
        if (record.biometricEnabled) {
          state = _lockedState(
            record,
            walletPublicKeys: walletPublicKeys,
            errorMessage: 'Use biometric unlock for this Seeker Vault wallet.',
          );
          return;
        }
        state = _unlockedExternalState(
          record,
          walletPublicKeys: walletPublicKeys,
        );
        return;
      }

      final mnemonic = await repository.decryptMnemonic(
        pin: pin,
        record: record,
      );

      // 🔐 Security: Store mnemonic in ephemeral provider, not in state
      final token = ephemeralStore.store(mnemonic, ttl: _unlockSessionTtl);
      debugPrint('[SECURITY] Mnemonic token issued on unlock.');

      final childWallets = _loadChildWallets(record);
      var nextState = WalletControllerState(
        status: WalletStatus.unlocked,
        walletPublicKeys: walletPublicKeys,
        publicKey: record.publicKey,
        derivation: record.derivation,
        mnemonic: null, // ❌ DO NOT store plaintext
        mnemonicTokenId: token, // ✅ Store only token
        biometricEnabled: _resolvedBiometricEnabled(record),
        childModeEnabled: record.childModeEnabled,
        hasChildModePin: record.hasChildModePin,
        childWallets: childWallets,
        loggedOut: false,
      );
      state = nextState;
      nextState = await _syncCloudChildSettings(nextState);
      unawaited(
        _registerAnonymousInstallIfNeeded(nextState, source: 'pin_unlock'),
      );
      unawaited(_syncPushNotificationsIfEnabled(nextState));
    } catch (_) {
      state = _lockedState(
        record,
        walletPublicKeys: walletPublicKeys,
        errorMessage: 'Incorrect PIN',
      );
    }
  }

  Future<String> authenticate(String pin) async {
    final repository = ref.read(walletRepositoryProvider);
    final record = await repository.readRecord();
    if (record == null) {
      throw StateError('Wallet not found');
    }
    return repository.decryptMnemonic(pin: pin, record: record);
  }

  Future<void> verifyPin(String pin) async {
    final repository = ref.read(walletRepositoryProvider);
    final record = await repository.readRecord();
    if (record == null) {
      throw StateError('Wallet not found');
    }
    await repository.verifyPin(pin: pin, record: record);
  }

  Future<void> selectWallet(String publicKey) async {
    final repository = ref.read(walletRepositoryProvider);
    await repository.selectWallet(publicKey);
    await _clearBackendSession();

    final walletPublicKeys = await repository.listWalletPublicKeys();
    final record = await _sanitizeBiometricRecord(
      repository,
      await repository.readRecord(publicKey: publicKey),
    );
    if (record == null) {
      state = WalletControllerState.noWallet;
      return;
    }

    state = record.custody == WalletCustody.mobileWalletAdapter
        ? _unlockedExternalState(record, walletPublicKeys: walletPublicKeys)
        : _lockedState(record, walletPublicKeys: walletPublicKeys);
  }

  void touch() {}

  Future<bool> unlockWithBiometrics() async {
    try {
      if (!_supportsPersistentBiometricSessions) {
        return false;
      }

      final repository = ref.read(walletRepositoryProvider);
      final ephemeralStore = ref.read(mnemonicEphemeralStoreProvider);

      debugPrint('[SECURITY] Starting biometric unlock flow...');

      final walletPublicKeys = await repository.listWalletPublicKeys();
      if (walletPublicKeys.isEmpty) {
        debugPrint('[SECURITY] No wallets available');
        return false;
      }

      final record = await repository.readRecord();
      if (record == null) {
        debugPrint('[SECURITY] Wallet record not found');
        return false;
      }

      if (!record.biometricEnabled) {
        debugPrint('[SECURITY] Biometric not enabled for the selected wallet.');
        return false;
      }

      if (record.custody == WalletCustody.mobileWalletAdapter) {
        var nextState = _unlockedExternalState(
          record,
          walletPublicKeys: walletPublicKeys,
        );
        state = nextState;
        nextState = await _syncCloudChildSettings(nextState);
        unawaited(
          _registerAnonymousInstallIfNeeded(
            nextState,
            source: 'biometric_unlock',
          ),
        );
        unawaited(_syncPushNotificationsIfEnabled(nextState));
        debugPrint('[SECURITY] Biometric unlock restored external wallet.');
        return true;
      }

      final biometricSession = await repository.readBiometricSession();
      if (biometricSession == null) {
        debugPrint('[SECURITY] No biometric session stored');
        return false;
      }

      if (biometricSession.publicKey != record.publicKey) {
        debugPrint('[SECURITY] Public key mismatch');
        return false;
      }

      // 🔐 Security: Store mnemonic in ephemeral provider (2-5 min TTL)
      // Never store plaintext mnemonic in persistent state
      final token = ephemeralStore.store(
        biometricSession.mnemonic,
        ttl: _biometricSessionTtl,
      );
      debugPrint('[SECURITY] Mnemonic token issued for biometric unlock.');

      final childWallets = _loadChildWallets(record);
      var nextState = WalletControllerState(
        status: WalletStatus.unlocked,
        walletPublicKeys: walletPublicKeys,
        publicKey: record.publicKey,
        derivation: record.derivation,
        mnemonic: null, // ❌ DO NOT store plaintext
        mnemonicTokenId: token, // ✅ Store only ephemeral token
        biometricEnabled: true,
        childModeEnabled: record.childModeEnabled,
        hasChildModePin: record.hasChildModePin,
        childWallets: childWallets,
        loggedOut: false,
      );
      state = nextState;
      nextState = await _syncCloudChildSettings(nextState);
      unawaited(
        _registerAnonymousInstallIfNeeded(
          nextState,
          source: 'biometric_unlock',
        ),
      );
      unawaited(_syncPushNotificationsIfEnabled(nextState));

      debugPrint('[SECURITY] ✅ Biometric unlock successful');
      return true;
    } catch (e, stack) {
      debugPrint('[SECURITY] ❌ Biometric unlock failed: $e');
      debugPrintStack(stackTrace: stack, label: '[SECURITY] Stack');
      return false;
    }
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final repository = ref.read(walletRepositoryProvider);
    final ephemeralStore = ref.read(mnemonicEphemeralStoreProvider);
    final publicKey = state.publicKey;

    if (publicKey == null) {
      throw StateError('No wallet selected.');
    }

    final record = await repository.readRecord(publicKey: publicKey);
    final isExternalWallet =
        record?.custody == WalletCustody.mobileWalletAdapter ||
        state.isExternalWallet;

    if (enabled && !_supportsPersistentBiometricSessions) {
      throw StateError(
        'Persistent biometric unlock is currently supported only on Android.',
      );
    }

    if (enabled && !isExternalWallet) {
      // 🔐 Security: Get mnemonic from ephemeral store, not from state
      final mnemonicTokenId = state.mnemonicTokenId;
      if (mnemonicTokenId == null) {
        throw StateError('Unlock the wallet before enabling biometrics.');
      }

      final mnemonic = ephemeralStore.retrieveTemporary(mnemonicTokenId);
      if (mnemonic == null || mnemonic.isEmpty) {
        throw StateError('Wallet session expired. Please unlock again.');
      }

      debugPrint('[SECURITY] Storing encrypted biometric session.');
      await repository.persistBiometricSession(
        publicKey: publicKey,
        mnemonic: mnemonic,
      );
      debugPrint('[SECURITY] Biometric session stored successfully');
    } else if (!enabled && !isExternalWallet) {
      debugPrint('[SECURITY] Clearing biometric session for: $publicKey');
      await repository.clearBiometricSession();
      debugPrint('[SECURITY] Biometric session cleared');
    }

    await repository.updateBiometricEnabled(
      publicKey: publicKey,
      biometricEnabled: enabled,
    );

    state = state.copyWith(biometricEnabled: enabled, clearError: true);
    debugPrint('[SECURITY] Biometric setting updated: $enabled');
  }

  Future<void> enableChildMode(String childModePin) async {
    final repository = ref.read(walletRepositoryProvider);
    final publicKey = state.publicKey;

    if (publicKey == null) {
      throw StateError('No wallet selected.');
    }

    if (state.childModeEnabled) {
      return;
    }

    if (state.childWallets.isNotEmpty) {
      throw ArgumentError(
        'Remove all child accounts before enabling child mode.',
      );
    }

    if (!RegExp(r'^\d{4}$').hasMatch(childModePin)) {
      throw ArgumentError('Child mode PIN must be exactly 4 digits.');
    }

    debugPrint('[SECURITY] Enabling child mode for wallet: $publicKey');
    await repository.enableChildMode(
      publicKey: publicKey,
      childModePin: childModePin,
    );

    state = state.copyWith(
      childModeEnabled: true,
      hasChildModePin: true,
      clearError: true,
    );
    unawaited(_pushCloudChildModeSettings(publicKey));
    debugPrint('[SECURITY] Child mode enabled');
  }

  Future<void> disableChildMode(String childModePin) async {
    final repository = ref.read(walletRepositoryProvider);
    final publicKey = state.publicKey;

    if (publicKey == null) {
      throw StateError('No wallet selected.');
    }

    if (!state.childModeEnabled) {
      return;
    }

    final record = await repository.readRecord(publicKey: publicKey);
    if (record == null) {
      throw StateError('Wallet not found.');
    }

    if (record.hasChildModePin) {
      if (!RegExp(r'^\d{4}$').hasMatch(childModePin)) {
        throw ArgumentError('Child mode PIN must be exactly 4 digits.');
      }
      try {
        await repository.verifyChildModePin(
          record: record,
          childModePin: childModePin,
        );
      } catch (_) {
        throw ArgumentError('Incorrect child mode PIN.');
      }
    }

    debugPrint('[SECURITY] Disabling child mode for wallet: $publicKey');
    await repository.disableChildMode(publicKey: publicKey);

    state = state.copyWith(
      childModeEnabled: false,
      hasChildModePin: false,
      clearError: true,
    );
    unawaited(_pushCloudChildModeSettings(publicKey));
    debugPrint('[SECURITY] Child mode disabled');
  }

  Future<void> addChildWallet(String childName, String childAddress) async {
    final repository = ref.read(walletRepositoryProvider);
    final publicKey = state.publicKey;

    if (publicKey == null) {
      throw StateError('No wallet selected.');
    }

    final normalizedName = childName.trim();
    final normalizedAddress = childAddress.trim();

    // Validate inputs
    if (normalizedName.isEmpty) {
      throw ArgumentError('Child name cannot be empty.');
    }
    if (normalizedAddress.isEmpty) {
      throw ArgumentError('Child wallet address cannot be empty.');
    }
    if (!Validators.isValidPublicAddress(normalizedAddress)) {
      throw ArgumentError('Child wallet address is invalid.');
    }
    if (state.childWallets.any(
      (wallet) => wallet.address == normalizedAddress,
    )) {
      throw ArgumentError('This child wallet address has already been added.');
    }

    debugPrint(
      '[SECURITY] Adding child wallet: $normalizedName at ${normalizedAddress.substring(0, 8)}...',
    );
    await repository.addChildWallet(
      publicKey: publicKey,
      childId: DateTime.now().millisecondsSinceEpoch.toString(),
      childName: normalizedName,
      childAddress: normalizedAddress,
    );

    final updatedRecords = await _readCurrentChildWallets(
      repository,
      publicKey,
    );
    state = state.copyWith(childWallets: updatedRecords, clearError: true);
    unawaited(
      _pushCloudChildAccount(
        childName: normalizedName,
        childAddress: normalizedAddress,
      ),
    );
    debugPrint('[SECURITY] Child wallet added successfully');
  }

  Future<void> updateChildWallet(
    String childId,
    String childName,
    String childAddress,
  ) async {
    final repository = ref.read(walletRepositoryProvider);
    final publicKey = state.publicKey;

    if (publicKey == null) {
      throw StateError('No wallet selected.');
    }

    final normalizedName = childName.trim();
    final normalizedAddress = childAddress.trim();

    // Validate inputs
    if (normalizedName.isEmpty) {
      throw ArgumentError('Child name cannot be empty.');
    }
    if (normalizedAddress.isEmpty) {
      throw ArgumentError('Child wallet address cannot be empty.');
    }
    if (!Validators.isValidPublicAddress(normalizedAddress)) {
      throw ArgumentError('Child wallet address is invalid.');
    }
    if (state.childWallets.any(
      (wallet) => wallet.id != childId && wallet.address == normalizedAddress,
    )) {
      throw ArgumentError('This child wallet address has already been added.');
    }
    final previousAddress = state.childWallets
        .where((wallet) => wallet.id == childId)
        .map((wallet) => wallet.address)
        .firstOrNull;

    debugPrint(
      '[SECURITY] Updating child wallet: $normalizedName (ID: $childId)',
    );
    await repository.updateChildWallet(
      publicKey: publicKey,
      childId: childId,
      childName: normalizedName,
      childAddress: normalizedAddress,
    );

    final updatedRecords = await _readCurrentChildWallets(
      repository,
      publicKey,
    );
    state = state.copyWith(childWallets: updatedRecords, clearError: true);
    unawaited(
      _pushCloudChildAccountUpdate(
        currentChildAddress: previousAddress ?? normalizedAddress,
        childName: normalizedName,
        childAddress: normalizedAddress,
      ),
    );
    debugPrint('[SECURITY] Child wallet updated successfully');
  }

  Future<void> removeChildWallet(String childId) async {
    final repository = ref.read(walletRepositoryProvider);
    final publicKey = state.publicKey;

    if (publicKey == null) {
      throw StateError('No wallet selected.');
    }

    final removedAddress = state.childWallets
        .where((wallet) => wallet.id == childId)
        .map((wallet) => wallet.address)
        .firstOrNull;

    debugPrint('[SECURITY] Removing child wallet ID: $childId');
    await repository.removeChildWallet(publicKey: publicKey, childId: childId);

    final updatedRecords = await _readCurrentChildWallets(
      repository,
      publicKey,
    );
    state = state.copyWith(childWallets: updatedRecords, clearError: true);
    if (removedAddress != null) {
      unawaited(_removeCloudChildAccount(removedAddress));
    }
    debugPrint('[SECURITY] Child wallet removed successfully');
  }

  Future<List<ChildWallet>> _readCurrentChildWallets(
    WalletRepository repository,
    String publicKey,
  ) async {
    final record = await repository.readRecord(publicKey: publicKey);
    if (record == null) {
      return const [];
    }
    return _loadChildWallets(record);
  }

  List<ChildWallet> _loadChildWallets(StoredWalletRecord record) {
    try {
      final wallets = <ChildWallet>[];
      for (final childData in record.childWalletsJson) {
        final wallet = ChildWallet(
          id: childData['id'] as String? ?? '',
          name: childData['name'] as String? ?? 'Child',
          address: childData['address'] as String? ?? '',
        );
        if (wallet.id.isNotEmpty && wallet.address.isNotEmpty) {
          wallets.add(wallet);
        }
      }
      return wallets;
    } catch (e) {
      debugPrint('[ERROR] Failed to load child wallets: $e');
      return [];
    }
  }

  void lock() {
    unawaited(ref.read(walletRepositoryProvider).clearUnlockedSession());

    // 🔐 Clear ephemeral mnemonic token
    if (state.mnemonicTokenId != null) {
      final ephemeralStore = ref.read(mnemonicEphemeralStoreProvider);
      ephemeralStore.clear(state.mnemonicTokenId!);
    }

    if (!state.hasWallet) {
      state = WalletControllerState.noWallet;
      return;
    }
    if (state.isExternalWallet && !state.biometricEnabled) {
      state = state.copyWith(
        status: WalletStatus.unlocked,
        clearMnemonic: true,
        clearMnemonicToken: true,
        clearError: true,
        loggedOut: false,
      );
      return;
    }
    state = state.copyWith(
      status: WalletStatus.locked,
      clearMnemonic: true,
      clearMnemonicToken: true,
      clearError: true,
      loggedOut: false,
    );
  }

  Future<void> logOut() async {
    final ephemeralStore = ref.read(mnemonicEphemeralStoreProvider);
    ephemeralStore.clearAll();

    ref.read(portfolioCacheProvider.notifier).state = const {};
    await _clearBackendSession();

    if (state.isExternalWallet) {
      await ref.read(walletRepositoryProvider).clearUnlockedSession();
      await ref.read(localNotificationServiceProvider).cancelAll();
      state = state.copyWith(
        status: WalletStatus.locked,
        clearMnemonic: true,
        clearMnemonicToken: true,
        clearError: true,
        loggedOut: true,
      );
      return;
    }

    await ref.read(walletRepositoryProvider).clearAll();
    await ref.read(appSettingsRepositoryProvider).clearAll();
    await ref.read(localNotificationServiceProvider).cancelAll();

    state = WalletControllerState.noWallet;
  }

  Future<String> revealMnemonic(String pin) => authenticate(pin);

  Future<void> clearWallet() async {
    final publicKey = state.publicKey;
    if (publicKey == null) {
      state = WalletControllerState.noWallet;
      return;
    }

    await removeWallet(publicKey);
  }

  Future<void> removeWallet(String publicKey) async {
    await _clearBackendSession();
    await ref.read(walletRepositoryProvider).removeWallet(publicKey);
    await _bootstrap();
  }

  Future<void> _clearBackendSession() {
    return ref.read(backendSessionManagerProvider).clear();
  }

  Future<void> _syncPushNotificationsIfEnabled(
    WalletControllerState nextState,
  ) async {
    if (!await _canUseBackendWithoutPrompt(nextState)) {
      return;
    }

    final settings = await ref.read(appSettingsRepositoryProvider).load();
    await ref
        .read(pushNotificationServiceProvider)
        .syncEnabledDevice(
          walletState: nextState,
          notificationsEnabled: settings.notificationsEnabled,
        );
  }

  Future<WalletControllerState> _syncCloudChildSettings(
    WalletControllerState nextState,
  ) async {
    final publicKey = nextState.publicKey;
    if (!nextState.isUnlocked || publicKey == null) {
      return nextState;
    }
    if (!await _canUseBackendWithoutPrompt(nextState)) {
      return nextState;
    }

    try {
      final repository = ref.read(walletRepositoryProvider);
      final apiClient = ref.read(backendApiClientProvider);
      final localRecord = await repository.readRecord(publicKey: publicKey);
      final snapshot = await apiClient.getWalletProfile();

      if (snapshot.hasCloudData) {
        final cloudChildModeEnabled =
            snapshot.profile.childModeEnabled ||
            snapshot.profile.accountRole == 'child';
        final childWalletsJson = [
          for (final child in snapshot.childAccounts)
            if (child.status == 'active' && child.childAddress.isNotEmpty)
              {
                'id': child.id,
                'name': child.childName,
                'address': child.childAddress,
              },
        ];

        await repository.applyCloudChildSettings(
          publicKey: publicKey,
          childModeEnabled: cloudChildModeEnabled,
          childModePinCipherText: snapshot.profile.childModePinCipherText,
          childModePinNonce: snapshot.profile.childModePinNonce,
          childModePinSalt: snapshot.profile.childModePinSalt,
          childWalletsJson: childWalletsJson,
        );

        final refreshedRecord = await repository.readRecord(
          publicKey: publicKey,
        );
        if (refreshedRecord == null) {
          return nextState;
        }

        final syncedState = nextState.copyWith(
          childModeEnabled: refreshedRecord.childModeEnabled,
          hasChildModePin: refreshedRecord.hasChildModePin,
          childWallets: _loadChildWallets(refreshedRecord),
          clearError: true,
        );
        state = syncedState;
        return syncedState;
      }

      if (localRecord != null &&
          (localRecord.childModeEnabled ||
              localRecord.hasChildModePin ||
              localRecord.childWalletsJson.isNotEmpty)) {
        await _pushLocalChildSettingsToCloud(localRecord);
      }
    } catch (error, stack) {
      debugPrint('[SYNC] Wallet child cloud sync failed: $error');
      debugPrintStack(stackTrace: stack, label: '[SYNC] Stack');
    }

    return nextState;
  }

  Future<void> _pushLocalChildSettingsToCloud(StoredWalletRecord record) async {
    final apiClient = ref.read(backendApiClientProvider);
    await apiClient.updateWalletChildMode(
      childModeEnabled: record.childModeEnabled,
      childModePinCipherText: record.childModePinCipherText,
      childModePinNonce: record.childModePinNonce,
      childModePinSalt: record.childModePinSalt,
    );
    for (final child in _loadChildWallets(record)) {
      await apiClient.upsertChildAccount(
        childName: child.name,
        childAddress: child.address,
      );
    }
  }

  Future<bool> _canUseBackendWithoutPrompt(WalletControllerState walletState) {
    final publicKey = walletState.publicKey;
    if (!walletState.isExternalWallet) {
      return Future.value(true);
    }
    if (!walletState.isUnlocked || publicKey == null || publicKey.isEmpty) {
      return Future.value(false);
    }
    return ref
        .read(backendSessionManagerProvider)
        .hasUsableStoredSession(publicKey);
  }

  Future<void> _pushCloudChildModeSettings(String publicKey) async {
    try {
      final record = await ref
          .read(walletRepositoryProvider)
          .readRecord(publicKey: publicKey);
      if (record == null) {
        return;
      }
      await ref
          .read(backendApiClientProvider)
          .updateWalletChildMode(
            childModeEnabled: record.childModeEnabled,
            childModePinCipherText: record.childModePinCipherText,
            childModePinNonce: record.childModePinNonce,
            childModePinSalt: record.childModePinSalt,
          );
    } catch (error, stack) {
      debugPrint('[SYNC] Child mode cloud update failed: $error');
      debugPrintStack(stackTrace: stack, label: '[SYNC] Stack');
    }
  }

  Future<void> _pushCloudChildAccount({
    required String childName,
    required String childAddress,
  }) async {
    try {
      await ref
          .read(backendApiClientProvider)
          .upsertChildAccount(childName: childName, childAddress: childAddress);
    } catch (error, stack) {
      debugPrint('[SYNC] Child account cloud upsert failed: $error');
      debugPrintStack(stackTrace: stack, label: '[SYNC] Stack');
    }
  }

  Future<void> _pushCloudChildAccountUpdate({
    required String currentChildAddress,
    required String childName,
    required String childAddress,
  }) async {
    try {
      await ref
          .read(backendApiClientProvider)
          .updateChildAccountByAddress(
            currentChildAddress: currentChildAddress,
            childName: childName,
            childAddress: childAddress,
          );
    } catch (error, stack) {
      debugPrint('[SYNC] Child account cloud update failed: $error');
      debugPrintStack(stackTrace: stack, label: '[SYNC] Stack');
    }
  }

  Future<void> _removeCloudChildAccount(String childAddress) async {
    try {
      await ref
          .read(backendApiClientProvider)
          .removeChildAccountByAddress(childAddress);
    } catch (error, stack) {
      debugPrint('[SYNC] Child account cloud removal failed: $error');
      debugPrintStack(stackTrace: stack, label: '[SYNC] Stack');
    }
  }

  Future<void> _registerAnonymousInstallIfNeeded(
    WalletControllerState nextState, {
    required String source,
  }) async {
    try {
      await ref
          .read(installAnalyticsRepositoryProvider)
          .registerWalletActivation(state: nextState, source: source);
    } catch (error, stack) {
      debugPrint('[ANALYTICS] Failed to register anonymous install: $error');
      debugPrintStack(stackTrace: stack, label: '[ANALYTICS] Stack');
    }
  }

  bool get _supportsPersistentBiometricSessions => ref
      .read(biometricSessionProtectorProvider)
      .supportsPersistentSessionProtection;

  bool _resolvedBiometricEnabled(StoredWalletRecord record) {
    return record.biometricEnabled && _supportsPersistentBiometricSessions;
  }

  Future<StoredWalletRecord?> _sanitizeBiometricRecord(
    WalletRepository repository,
    StoredWalletRecord? record,
  ) async {
    if (record == null ||
        _supportsPersistentBiometricSessions ||
        !record.biometricEnabled) {
      return record;
    }

    await repository.clearBiometricSession();
    await repository.updateBiometricEnabled(
      publicKey: record.publicKey,
      biometricEnabled: false,
    );

    return await repository.readRecord(publicKey: record.publicKey);
  }

  WalletControllerState _lockedState(
    StoredWalletRecord record, {
    required List<String> walletPublicKeys,
    String? errorMessage,
  }) {
    final childWallets = _loadChildWallets(record);
    return WalletControllerState(
      status: WalletStatus.locked,
      walletPublicKeys: walletPublicKeys,
      publicKey: record.publicKey,
      derivation: record.derivation,
      custody: record.custody,
      mwaAuthToken: record.mwaAuthToken.isEmpty ? null : record.mwaAuthToken,
      walletLabel: record.walletLabel.isEmpty ? null : record.walletLabel,
      biometricEnabled: _resolvedBiometricEnabled(record),
      childModeEnabled: record.childModeEnabled,
      hasChildModePin: record.hasChildModePin,
      childWallets: childWallets,
      loggedOut: false,
      errorMessage: errorMessage,
    );
  }

  WalletControllerState _unlockedExternalState(
    StoredWalletRecord record, {
    required List<String> walletPublicKeys,
  }) {
    final childWallets = _loadChildWallets(record);
    return WalletControllerState(
      status: WalletStatus.unlocked,
      walletPublicKeys: walletPublicKeys,
      publicKey: record.publicKey,
      derivation: record.derivation,
      custody: WalletCustody.mobileWalletAdapter,
      mwaAuthToken: record.mwaAuthToken.isEmpty ? null : record.mwaAuthToken,
      walletLabel: record.walletLabel.isEmpty ? null : record.walletLabel,
      biometricEnabled: _resolvedBiometricEnabled(record),
      childModeEnabled: record.childModeEnabled,
      hasChildModePin: record.hasChildModePin,
      childWallets: childWallets,
      loggedOut: false,
    );
  }
}

final walletControllerProvider =
    StateNotifierProvider<WalletController, WalletControllerState>((ref) {
      return WalletController(ref);
    });
