import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/push_notification_service.dart';
import '../../../../core/storage/key_value_store.dart';
import '../../../../core/utils/validators.dart';
import '../../../portfolio/presentation/providers/portfolio_provider.dart';
import '../../../settings/presentation/providers/app_settings_controller.dart';
import '../../data/wallet_repository.dart';
import '../../domain/wallet_derivation.dart';
import '../../domain/wallet_controller_state.dart';
import 'ephemeral_store.dart';

/// Adding a wallet needs the master key; it is only held for a while after
/// unlock, so the UI asks for the PIN again when this is thrown.
class MasterKeyLockedException implements Exception {
  const MasterKeyLockedException();

  @override
  String toString() => 'Enter your PIN to continue.';
}

/// Switching or adding wallets is disabled while child mode is on, so a child
/// cannot leave the restricted wallet.
enum ChildWalletCheck { notChild, childWithPin, childWithoutPin }

/// Child mode has no PIN of its own, so turning it off needs the app PIN.
class ChildModeAppPinRequiredException implements Exception {
  const ChildModeAppPinRequiredException();
}

class ChildModeRestrictionException implements Exception {
  const ChildModeRestrictionException();

  @override
  String toString() => 'Turn off child mode to manage wallets.';
}

/// Biometric unlock would skip the PIN choice between the app PIN and the
/// travel guard PIN, so it stays off while the guard is set.
class TravelGuardBlocksBiometricsException implements Exception {
  const TravelGuardBlocksBiometricsException();

  @override
  String toString() => 'Turn off the travel guard to use biometric unlock.';
}

/// What the add-wallet flow collected before the name step.
class NewWalletInput {
  const NewWalletInput.mnemonic({
    required String this.mnemonic,
    required this.derivation,
    this.publicKey,
  }) : custody = WalletCustody.localMnemonic,
       authToken = null,
       derivationPath = null,
       walletLabel = null,
       airGapMeta = null;

  const NewWalletInput.mobileWalletAdapter({
    required String this.publicKey,
    required String this.authToken,
    this.walletLabel,
  }) : custody = WalletCustody.mobileWalletAdapter,
       mnemonic = null,
       derivation = WalletDerivation.legacy,
       derivationPath = null,
       airGapMeta = null;

  const NewWalletInput.seedVault({
    required String this.publicKey,
    required String this.authToken,
    required String this.derivationPath,
    this.walletLabel,
  }) : custody = WalletCustody.seedVault,
       mnemonic = null,
       derivation = WalletDerivation.legacy,
       airGapMeta = null;

  const NewWalletInput.airGap({
    required String this.publicKey,
    required String this.derivationPath,
    required String this.airGapMeta,
    this.walletLabel,
  }) : custody = WalletCustody.airGap,
       mnemonic = null,
       derivation = WalletDerivation.legacy,
       authToken = null;

  final WalletCustody custody;
  final String? mnemonic;
  final WalletDerivation derivation;
  final String? publicKey;
  final String? authToken;
  final String? derivationPath;
  final String? walletLabel;
  final String? airGapMeta;
}

class WalletController extends StateNotifier<WalletControllerState> {
  static const _unlockSessionTtl = Duration(minutes: 10);
  static const _pushSyncDelay = Duration(seconds: 2);
  static const _postActivateDelay = Duration(milliseconds: 450);
  static const _pushSyncInterval = Duration(hours: 12);

  WalletController(this.ref) : super(WalletControllerState.loading) {
    _bootstrap();
  }

  final Ref ref;

  /// Ephemeral-store token for the base64 master key; never in state.
  String? _masterKeyToken;

  /// Whether a travel guard PIN is set; mirrored into every state.
  bool _travelGuardArmed = false;

  WalletRepository get _repository => ref.read(walletRepositoryProvider);

  MnemonicEphemeralStore get _ephemeralStore =>
      ref.read(mnemonicEphemeralStoreProvider);

  bool get canAddWallet =>
      state.walletPublicKeys.length < AppConstants.maxWalletCount;

  /// Whether wallets can be added or switched without asking for the PIN.
  bool get hasActiveMasterKey => _readMasterKey() != null;

  Future<void> _bootstrap() async {
    final records = await _repository.readRecords();
    unawaited(_repository.clearUnlockedSession());
    if (records.isEmpty) {
      state = WalletControllerState.noWallet;
      unawaited(_clearNoWalletCaches(_repository));
      return;
    }

    _travelGuardArmed = await _repository.travelGuardPublicKey() != null;
    var sanitized = await _sanitizeBiometricRecords(records);
    if (_travelGuardArmed && sanitized.any((r) => r.biometricEnabled)) {
      await _repository.clearBiometricSession();
      await _repository.setBiometricEnabledForAll(false);
      sanitized = await _repository.readRecords();
    }
    final record = await _repository.readSelectedRecordFrom(sanitized);
    if (record == null) {
      state = WalletControllerState.noWallet;
      unawaited(_clearNoWalletCaches(_repository));
      return;
    }

    // Every wallet, including external ones, starts locked behind the PIN or
    // biometrics.
    state = _lockedState(record, records: sanitized);
  }

  Future<void> _clearNoWalletCaches(WalletRepository repository) async {
    await _deauthorizeSeedVaultRecords(await repository.readRecords());

    _clearSecrets();

    ref.read(portfolioCacheProvider.notifier).state = const {};
    await _clearBackendSession();
    await repository.clearAll();
    await ref.read(appSettingsRepositoryProvider).clearAll();
    await ref.read(localNotificationServiceProvider).cancelAll();
  }

  // ---------------------------------------------------------------------------
  // First wallet (onboarding: the PIN is set here)
  // ---------------------------------------------------------------------------

  Future<void> importWallet({
    required String mnemonic,
    required String pin,
    required bool biometricEnabled,
    WalletDerivation derivation = WalletDerivation.standard,
    String? publicKey,
    String? name,
  }) async {
    final normalized = Validators.normalizeMnemonic(mnemonic);
    if (!Validators.isValidMnemonic(normalized)) {
      state = state.copyWith(errorMessage: 'Invalid recovery phrase');
      return;
    }

    final resolvedPublicKey =
        publicKey ??
        await ref
            .read(solanaWalletServiceProvider)
            .deriveAddress(normalized, derivation: derivation);

    try {
      final masterKey = await _repository.unlockMasterKey(pin);
      _storeMasterKey(masterKey);
      await _repository.addLocalWallet(
        mnemonic: normalized,
        masterKey: masterKey,
        publicKey: resolvedPublicKey,
        derivation: derivation,
        biometricEnabled:
            biometricEnabled && _supportsPersistentBiometricSessions,
        name: name,
      );
    } catch (error) {
      state = state.copyWith(errorMessage: _friendlyAddError(error));
      return;
    }

    await _activate(
      resolvedPublicKey,
      source: 'pin_setup',
      activateLinkedChildMode: true,
      enablePush: true,
    );
  }

  Future<void> importMobileWalletAdapterWallet({
    required String publicKey,
    required String authToken,
    required String pin,
    String? walletLabel,
    String? name,
  }) async {
    try {
      await _repository.saveMobileWalletAdapterWallet(
        publicKey: publicKey,
        authToken: authToken,
        pin: pin,
        walletLabel: walletLabel,
        name: name,
      );
      _storeMasterKey(await _repository.unlockMasterKey(pin));
    } catch (error) {
      state = state.copyWith(errorMessage: _friendlyAddError(error));
      return;
    }

    await _activate(
      publicKey,
      source: 'pin_setup',
      activateLinkedChildMode: true,
      enablePush: true,
    );
  }

  Future<void> importSeedVaultWallet({
    required String publicKey,
    required String authToken,
    required String derivationPath,
    required String pin,
    String? walletLabel,
    String? name,
  }) async {
    try {
      await _repository.saveSeedVaultWallet(
        publicKey: publicKey,
        authToken: authToken,
        derivationPath: derivationPath,
        pin: pin,
        walletLabel: walletLabel,
        name: name,
      );
      _storeMasterKey(await _repository.unlockMasterKey(pin));
    } catch (error) {
      state = state.copyWith(errorMessage: _friendlyAddError(error));
      return;
    }

    await _activate(
      publicKey,
      source: 'pin_setup',
      activateLinkedChildMode: true,
      enablePush: true,
    );
  }

  Future<void> importAirGapWallet({
    required String publicKey,
    required String derivationPath,
    required String airGapMeta,
    required String pin,
    String? walletLabel,
    String? name,
  }) async {
    try {
      await _repository.saveAirGapWallet(
        publicKey: publicKey,
        derivationPath: derivationPath,
        airGapMeta: airGapMeta,
        pin: pin,
        walletLabel: walletLabel,
        name: name,
      );
      _storeMasterKey(await _repository.unlockMasterKey(pin));
    } catch (error) {
      state = state.copyWith(errorMessage: _friendlyAddError(error));
      return;
    }

    await _activate(
      publicKey,
      source: 'pin_setup',
      activateLinkedChildMode: true,
      enablePush: true,
    );
  }

  // ---------------------------------------------------------------------------
  // Multi-wallet
  // ---------------------------------------------------------------------------

  /// Adds another wallet while unlocked. Pass [pin] when [hasActiveMasterKey]
  /// is false. Throws [DuplicateWalletException],
  /// [WalletLimitReachedException], [MasterKeyLockedException] or
  /// [ChildModeRestrictionException]; on success the new wallet is active.
  Future<void> addWallet(
    NewWalletInput input, {
    String? name,
    String? pin,
    String? childModePin,
  }) async {
    if (state.childModeEnabled) {
      throw const ChildModeRestrictionException();
    }

    var masterKey = _readMasterKey();
    if (masterKey == null) {
      if (pin == null) {
        throw const MasterKeyLockedException();
      }
      masterKey = await _repository.unlockMasterKey(pin);
      _storeMasterKey(masterKey);
    }

    final String publicKey;
    switch (input.custody) {
      case WalletCustody.localMnemonic:
        final normalized = Validators.normalizeMnemonic(input.mnemonic!);
        if (!Validators.isValidMnemonic(normalized)) {
          throw ArgumentError('Invalid recovery phrase');
        }
        publicKey =
            input.publicKey ??
            await ref
                .read(solanaWalletServiceProvider)
                .deriveAddress(normalized, derivation: input.derivation);
        await _repository.addLocalWallet(
          mnemonic: normalized,
          masterKey: masterKey,
          publicKey: publicKey,
          derivation: input.derivation,
          name: name,
        );
      case WalletCustody.mobileWalletAdapter:
      case WalletCustody.seedVault:
      case WalletCustody.airGap:
        publicKey = input.publicKey!;
        await _repository.addExternalWallet(
          custody: input.custody,
          publicKey: publicKey,
          authToken: input.authToken ?? '',
          derivationPath: input.derivationPath ?? '',
          walletLabel: input.walletLabel,
          name: name,
          airGapMeta: input.airGapMeta ?? '',
        );
    }

    if (childModePin != null) {
      // A linked child wallet whose PIN was never saved to the cloud: lock it
      // with the PIN the parent just chose. The cloud sync after activation
      // keeps this PIN and uploads it.
      await _repository.enableChildMode(
        publicKey: publicKey,
        childModePin: childModePin,
      );
    }

    await _activate(
      publicKey,
      source: 'wallet_add',
      activateLinkedChildMode: true,
      enablePush: true,
    );
  }

  /// Whether [input] is a wallet its parent put in child mode, so adding it
  /// would switch the app into child mode, and whether the cloud still holds
  /// its child-mode PIN. Only recovery-phrase wallets can be checked before
  /// they are added (external wallets would need a signature prompt); any
  /// failure counts as "not a child wallet".
  Future<ChildWalletCheck> checkChildModeWallet(NewWalletInput input) async {
    if (input.custody != WalletCustody.localMnemonic) {
      return ChildWalletCheck.notChild;
    }
    try {
      final mnemonic = Validators.normalizeMnemonic(input.mnemonic!);
      final publicKey =
          input.publicKey ??
          await ref
              .read(solanaWalletServiceProvider)
              .deriveAddress(mnemonic, derivation: input.derivation);
      final sessionManager = ref.read(backendSessionManagerProvider);
      final session = await sessionManager.sessionForLocalWallet(
        ownerAddress: publicKey,
        mnemonic: mnemonic,
        derivation: input.derivation,
      );
      final snapshot = await ref
          .read(backendApiClientProvider)
          .getWalletProfile(authHeaders: sessionManager.headersFor(session));
      final profile = snapshot.profile;
      if (!snapshot.hasCloudData ||
          !(profile.childModeEnabled || profile.accountRole == 'child')) {
        return ChildWalletCheck.notChild;
      }
      final hasPin =
          profile.childModePinCipherText.isNotEmpty &&
          profile.childModePinNonce.isNotEmpty &&
          profile.childModePinSalt.isNotEmpty;
      return hasPin
          ? ChildWalletCheck.childWithPin
          : ChildWalletCheck.childWithoutPin;
    } catch (error) {
      debugPrint('[WALLET] Child mode pre-check failed: $error');
      return ChildWalletCheck.notChild;
    }
  }

  /// Makes [publicKey] the active wallet. While unlocked this is instant
  /// (one AES decrypt, no PIN); when locked it only changes the selection.
  Future<void> selectWallet(String publicKey) async {
    if (publicKey == state.publicKey || state.travelGuardSession) {
      return;
    }
    if (state.isUnlocked && state.childModeEnabled) {
      throw const ChildModeRestrictionException();
    }

    if (state.isUnlocked && _readMasterKey() != null) {
      await _activate(publicKey, source: 'wallet_switch');
      return;
    }

    await _repository.selectWallet(publicKey);
    final records = await _repository.readRecords();
    final record = await _repository.readSelectedRecordFrom(
      records,
      publicKey: publicKey,
    );
    if (record == null) {
      state = WalletControllerState.noWallet;
      return;
    }
    _clearSecrets();
    state = _lockedState(record, records: records);
  }

  Future<void> renameWallet(String publicKey, String name) async {
    await _repository.renameWallet(publicKey: publicKey, name: name);
    final records = await _repository.readRecords();
    state = state.copyWith(
      wallets: _summaries(
        state.travelGuardSession
            ? [
                for (final r in records)
                  if (r.publicKey == state.publicKey) r,
              ]
            : records,
      ),
    );
  }

  Future<String> nextDefaultWalletName() async {
    return _repository.nextDefaultWalletName(await _repository.readRecords());
  }

  Future<void> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    await _repository.changePin(currentPin: currentPin, newPin: newPin);
  }

  /// Seed Vault authorizations the stored wallets sign with; re-authorizing
  /// must not revoke them.
  Future<List<String>> seedVaultAuthTokensInUse() async {
    final records = await _repository.readRecords();
    return [
      for (final record in records)
        if (record.custody == WalletCustody.seedVault &&
            record.mwaAuthToken.isNotEmpty)
          record.mwaAuthToken,
    ];
  }

  /// Seed Vault signed for [publicKey] only with [newToken] / [derivationPath]
  /// (what it lists now). If [oldToken] was [publicKey]'s stored token, every
  /// wallet on it moves to the new token; [publicKey] keeps the working path.
  Future<void> updateSeedVaultAccount({
    required String publicKey,
    required String oldToken,
    required String newToken,
    required String derivationPath,
  }) async {
    await _repository.replaceSeedVaultAuthToken(
      oldToken: oldToken,
      newToken: newToken,
      publicKey: publicKey,
      derivationPath: derivationPath,
    );
    if (state.custody != WalletCustody.seedVault) {
      return;
    }
    // Mirror what was stored for the current wallet, which may not be
    // [publicKey] if the user switched while signing.
    final current = (await _repository.readRecords())
        .where((record) => record.publicKey == state.publicKey)
        .firstOrNull;
    if (current == null || current.custody != WalletCustody.seedVault) {
      return;
    }
    state = state.copyWith(
      mwaAuthToken: current.mwaAuthToken,
      seedVaultDerivationPath: current.seedVaultDerivationPath,
      clearError: true,
    );
  }

  Future<void> updateMobileWalletAdapterAuthToken(String authToken) async {
    final publicKey = state.publicKey;
    if (publicKey == null || !state.isExternalWallet) {
      return;
    }
    await _repository.updateMobileWalletAdapterAuthToken(
      publicKey: publicKey,
      authToken: authToken,
    );
    state = state.copyWith(mwaAuthToken: authToken, clearError: true);
  }

  // ---------------------------------------------------------------------------
  // Travel guard
  // ---------------------------------------------------------------------------

  /// Wallet the travel guard PIN opens, or null when it is off.
  Future<String?> travelGuardPublicKey() => _repository.travelGuardPublicKey();

  /// Sets [guardPin] to open [publicKey] alone and turns biometrics off.
  /// Needs the master key in memory (verify the app PIN first).
  Future<void> enableTravelGuard({
    required String publicKey,
    required String guardPin,
  }) async {
    final masterKey = _readMasterKey();
    if (masterKey == null) {
      throw const MasterKeyLockedException();
    }
    await _repository.setTravelGuard(
      masterKey: masterKey,
      publicKey: publicKey,
      guardPin: guardPin,
    );
    await _repository.clearBiometricSession();
    await _repository.setBiometricEnabledForAll(false);
    _travelGuardArmed = true;
    state = state.copyWith(
      travelGuardArmed: true,
      biometricEnabled: false,
      clearError: true,
    );
  }

  /// Turns the travel guard off. Needs the master key in memory.
  Future<void> disableTravelGuard() async {
    if (_readMasterKey() == null) {
      throw const MasterKeyLockedException();
    }
    await _repository.clearTravelGuard();
    _travelGuardArmed = false;
    state = state.copyWith(travelGuardArmed: false, clearError: true);
  }

  // ---------------------------------------------------------------------------
  // Unlock / authentication (one PIN for every wallet)
  // ---------------------------------------------------------------------------

  Future<void> unlock(String pin) async {
    final records = await _repository.readRecords();
    final record = await _repository.readSelectedRecordFrom(records);
    if (record == null) {
      state = WalletControllerState.noWallet;
      return;
    }

    try {
      final masterKey = await _unlockOrSetupMasterKey(pin);
      _storeMasterKey(masterKey);
      unawaited(_upgradeBiometricToMasterKey(masterKey));
      await _activate(record.publicKey, source: 'pin_unlock', pin: pin);
    } catch (error) {
      final guard = _travelGuardArmed
          ? await _repository.unlockTravelGuard(pin)
          : null;
      if (guard != null) {
        _activateTravelGuard(guard);
        return;
      }
      debugPrint('[SECURITY] PIN unlock failed: $error');
      _clearSecrets();
      state = _lockedState(
        record,
        records: records,
        errorMessage: 'Incorrect PIN',
      );
    }
  }

  Future<Uint8List> _unlockOrSetupMasterKey(String pin) async {
    try {
      return await _repository.unlockMasterKey(pin);
    } on PinSetupRequiredException {
      return _repository.setupPin(pin);
    }
  }

  /// Opens only the travel guard wallet: no master key, no other wallets,
  /// no background work that would touch the other wallets.
  void _activateTravelGuard(TravelGuardUnlock guard) {
    _clearSecrets();
    final mnemonic = guard.mnemonic;
    _setUnlockedState(
      guard.record,
      records: [guard.record],
      mnemonicTokenId: mnemonic == null ? null : _storeMnemonic(mnemonic),
      travelGuardSession: true,
    );
    debugPrint('[SECURITY] Unlocked one wallet.');
  }

  Future<TravelGuardUnlock> _verifyTravelGuardPin(String pin) async {
    final guard = await _repository.unlockTravelGuard(pin);
    if (guard == null || guard.record.publicKey != state.publicKey) {
      throw StateError('Incorrect PIN');
    }
    return guard;
  }

  Future<bool> requiresPinSetup() => _repository.requiresPinSetup();

  Future<String> authenticate(String pin) async {
    if (state.travelGuardSession) {
      final mnemonic = (await _verifyTravelGuardPin(pin)).mnemonic;
      if (mnemonic == null) {
        throw StateError('This wallet is connected through Seeker Vault.');
      }
      return mnemonic;
    }
    final record = await _repository.readRecord(publicKey: state.publicKey);
    if (record == null) {
      throw StateError('Wallet not found');
    }
    return _repository.decryptMnemonic(pin: pin, record: record);
  }

  Future<void> verifyPin(String pin) async {
    if (state.travelGuardSession) {
      await _verifyTravelGuardPin(pin);
      return;
    }
    final masterKey = await _repository.unlockMasterKey(pin);
    _storeMasterKey(masterKey);
  }

  void touch() {}

  Future<bool> unlockWithBiometrics() async {
    try {
      if (!_supportsPersistentBiometricSessions) {
        return false;
      }

      if (_travelGuardArmed) {
        return false;
      }
      final records = await _repository.readRecords();
      final record = await _repository.readSelectedRecordFrom(records);
      if (record == null || !records.any((r) => r.biometricEnabled)) {
        debugPrint('[SECURITY] Biometric unlock is not enabled.');
        return false;
      }

      final masterKey = await _repository.readBiometricMasterKey();
      if (masterKey != null) {
        _storeMasterKey(masterKey);
        await _activate(record.publicKey, source: 'biometric_unlock');
        debugPrint('[SECURITY] Biometric unlock opened the master key.');
        return true;
      }

      // Pre-multi-wallet biometric session: it holds one wallet's mnemonic
      // (or nothing for external wallets). Unlock that wallet only; the
      // master key is restored the next time the PIN is entered.
      if (record.custody != WalletCustody.localMnemonic) {
        _setUnlockedState(record, records: records);
        unawaited(_afterActivate(state, source: 'biometric_unlock'));
        return true;
      }

      final legacy = await _repository.readBiometricSession();
      if (legacy == null || legacy.publicKey != record.publicKey) {
        debugPrint('[SECURITY] No biometric session for the selected wallet.');
        return false;
      }
      _setUnlockedState(
        record,
        records: records,
        mnemonicTokenId: _storeMnemonic(legacy.mnemonic),
      );
      unawaited(_afterActivate(state, source: 'biometric_unlock'));
      return true;
    } catch (e, stack) {
      debugPrint('[SECURITY] Biometric unlock failed: $e');
      debugPrintStack(stackTrace: stack, label: '[SECURITY] Stack');
      return false;
    }
  }

  /// Biometrics unlock the master key and therefore every wallet. Call right
  /// after a successful biometric prompt (the keystore key needs it).
  Future<void> setBiometricEnabled(bool enabled) async {
    if (state.publicKey == null) {
      throw StateError('No wallet selected.');
    }
    if (enabled && (_travelGuardArmed || state.travelGuardSession)) {
      throw const TravelGuardBlocksBiometricsException();
    }
    if (enabled && !_supportsPersistentBiometricSessions) {
      throw StateError(
        'Persistent biometric unlock is not supported on this device.',
      );
    }

    if (enabled) {
      final masterKey = _readMasterKey();
      if (masterKey == null) {
        throw const MasterKeyLockedException();
      }
      await _repository.persistBiometricMasterKey(masterKey);
    } else {
      await _repository.clearBiometricSession();
    }

    await _repository.setBiometricEnabledForAll(enabled);
    state = state.copyWith(biometricEnabled: enabled, clearError: true);
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

  /// Turns child mode off. Needs the child-mode PIN, or the app PIN as
  /// [appPin] when this wallet has no child-mode PIN (e.g. a linked child
  /// wallet whose PIN was never saved), so a child can't just switch it off.
  Future<void> disableChildMode(String childModePin, {String? appPin}) async {
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
    } else {
      if (appPin == null || appPin.isEmpty) {
        throw const ChildModeAppPinRequiredException();
      }
      try {
        _storeMasterKey(await _repository.unlockMasterKey(appPin));
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
    unawaited(_clearCloudChildModeSettings(publicKey));
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
    unawaited(_repository.clearUnlockedSession());
    _clearSecrets();

    if (!state.hasWallet) {
      state = WalletControllerState.noWallet;
      return;
    }
    if (state.travelGuardSession) {
      // Back to the real wallet list behind the lock screen.
      state = state.copyWith(
        status: WalletStatus.locked,
        clearMnemonic: true,
        clearMnemonicToken: true,
        clearError: true,
        travelGuardSession: false,
        travelGuardArmed: _travelGuardArmed,
      );
      unawaited(_restoreLockedState());
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

  Future<void> _restoreLockedState() async {
    final records = await _repository.readRecords();
    final record = await _repository.readSelectedRecordFrom(records);
    if (record == null || state.status != WalletStatus.locked) {
      return;
    }
    state = _lockedState(record, records: records);
  }

  /// Wipes every wallet, except in a travel guard session, where it only
  /// locks: the session must never be able to delete the hidden wallets.
  Future<void> logOut() async {
    if (state.travelGuardSession) {
      lock();
      return;
    }
    final records = await _repository.readRecords();
    await _deauthorizeSeedVaultRecords(records);
    await _prunePushWallets(const []);

    _clearSecrets();

    ref.read(portfolioCacheProvider.notifier).state = const {};
    await _clearBackendSession();

    await _repository.clearAll();
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

  /// Removes one wallet. If it was active, the next wallet becomes active
  /// (without asking for the PIN while unlocked).
  Future<void> removeWallet(String publicKey) async {
    if (state.travelGuardSession) {
      throw StateError('Wallet cannot be removed right now.');
    }
    final records = await _repository.readRecords();
    final record = records.where((r) => r.publicKey == publicKey).firstOrNull;
    if (record == null) {
      return;
    }
    if (records.length == 1) {
      await logOut();
      return;
    }

    // Another wallet may be a different account of the same seed and still
    // sign with this authorization.
    final tokenStillUsed = records.any(
      (r) =>
          r.publicKey != publicKey &&
          r.custody == WalletCustody.seedVault &&
          r.mwaAuthToken.isNotEmpty &&
          r.mwaAuthToken == record.mwaAuthToken,
    );
    if (!tokenStillUsed) {
      await _deauthorizeSeedVaultRecords([record]);
    }
    final remaining = [
      for (final r in records)
        if (r.publicKey != publicKey) r.publicKey,
    ];
    await _prunePushWallets(remaining);
    await ref.read(backendSessionManagerProvider).clearOwner(publicKey);
    final cache = {...ref.read(portfolioCacheProvider)}..remove(publicKey);
    ref.read(portfolioCacheProvider.notifier).state = cache;

    final wasActive = state.publicKey == publicKey;
    await _repository.removeWallet(publicKey);
    final updated = await _repository.readRecords();

    if (!wasActive) {
      state = state.copyWith(
        walletPublicKeys: _publicKeys(updated),
        wallets: _summaries(updated),
      );
      return;
    }

    final next = await _repository.readSelectedRecordFrom(updated);
    if (next == null) {
      state = WalletControllerState.noWallet;
      return;
    }
    if (state.isUnlocked && _readMasterKey() != null) {
      await _activate(next.publicKey, source: 'wallet_switch');
    } else {
      _clearSecrets();
      state = _lockedState(next, records: updated);
    }
  }

  // ---------------------------------------------------------------------------
  // Activation
  // ---------------------------------------------------------------------------

  /// Makes [publicKey] the unlocked, active wallet using the master key in
  /// memory. Background work (cloud sync, push) runs after the state update
  /// so the UI switches immediately.
  Future<void> _activate(
    String publicKey, {
    required String source,
    String? pin,
    bool activateLinkedChildMode = false,
    bool enablePush = false,
  }) async {
    final records = await _repository.readRecords();
    final record = await _repository.readSelectedRecordFrom(
      records,
      publicKey: publicKey,
    );
    if (record == null) {
      state = WalletControllerState.noWallet;
      return;
    }
    if (record.publicKey != publicKey) {
      throw StateError('Wallet not found: $publicKey');
    }

    String? mnemonicTokenId;
    if (record.custody == WalletCustody.localMnemonic) {
      final masterKey = _readMasterKey();
      final String mnemonic;
      if (record.secretScheme == WalletSecretScheme.masterKey &&
          masterKey != null) {
        mnemonic = await _repository.decryptMnemonicWithKey(
          record: record,
          masterKey: masterKey,
        );
      } else if (pin != null) {
        mnemonic = await _repository.decryptLegacyMnemonic(
          record: record,
          pin: pin,
        );
      } else {
        throw const MasterKeyLockedException();
      }
      mnemonicTokenId = _storeMnemonic(mnemonic);
    } else {
      _clearMnemonicToken();
    }

    // Show the wallet first; persisting the selection can finish after.
    _setUnlockedState(
      record,
      records: records,
      mnemonicTokenId: mnemonicTokenId,
    );
    await _repository.selectWallet(record.publicKey);

    // Start network/crypto follow-ups after the page transition so the new
    // wallet appears without a dropped frame.
    final activeState = state;
    unawaited(
      Future<void>.delayed(
        _postActivateDelay,
        () => _afterActivate(
          activeState,
          source: source,
          activateLinkedChildMode: activateLinkedChildMode,
          enablePush: enablePush,
        ),
      ),
    );
  }

  Future<void> _afterActivate(
    WalletControllerState activeState, {
    required String source,
    bool activateLinkedChildMode = false,
    bool enablePush = false,
  }) async {
    try {
      if (enablePush) {
        await ref
            .read(appSettingsControllerProvider.notifier)
            .setNotificationsEnabled(true);
      }
      if (activateLinkedChildMode) {
        await _ensureBackendSessionForExternalWallet(activeState);
      }
      await _syncCloudChildSettings(
        activeState,
        activateLinkedChildMode: activateLinkedChildMode,
      );
      unawaited(_registerAnonymousInstallIfNeeded(activeState, source: source));
      if (source != 'wallet_switch') {
        // Let the home screen settle before signing in every wallet.
        await Future<void>.delayed(_pushSyncDelay);
        await syncPushForAllWallets(force: enablePush);
      }
    } catch (error, stack) {
      debugPrint('[WALLET] Post-activation tasks failed: $error');
      debugPrintStack(stackTrace: stack, label: '[WALLET] Stack');
    }
  }

  void _setUnlockedState(
    StoredWalletRecord record, {
    required List<StoredWalletRecord> records,
    String? mnemonicTokenId,
    bool travelGuardSession = false,
  }) {
    final previousToken = state.mnemonicTokenId;
    state = WalletControllerState(
      status: WalletStatus.unlocked,
      walletPublicKeys: _publicKeys(records),
      wallets: _summaries(records),
      publicKey: record.publicKey,
      derivation: record.derivation,
      custody: record.custody,
      mnemonic: null,
      mnemonicTokenId: mnemonicTokenId,
      mwaAuthToken: record.mwaAuthToken.isEmpty ? null : record.mwaAuthToken,
      seedVaultDerivationPath: record.seedVaultDerivationPath.isEmpty
          ? null
          : record.seedVaultDerivationPath,
      walletLabel: record.walletLabel.isEmpty ? null : record.walletLabel,
      biometricEnabled:
          !_travelGuardArmed && _resolvedBiometricEnabled(records),
      childModeEnabled: record.childModeEnabled,
      hasChildModePin: record.hasChildModePin,
      childWallets: _loadChildWallets(record),
      loggedOut: false,
      // A guard session looks like an ordinary wallet without the guard.
      travelGuardArmed: _travelGuardArmed && !travelGuardSession,
      travelGuardSession: travelGuardSession,
    );
    if (previousToken != null && previousToken != mnemonicTokenId) {
      _ephemeralStore.clear(previousToken);
    }
  }

  // ---------------------------------------------------------------------------
  // Push notifications (every wallet on the device)
  // ---------------------------------------------------------------------------

  /// Registers incoming-funds push for every wallet that can authenticate
  /// without a prompt: local wallets sign with their key, external wallets
  /// use a stored session. Removed wallets are turned off.
  ///
  /// Throttled: skipped when the same wallets were synced recently, unless
  /// [force] (new wallet, notifications turned on, FCM token changed).
  Future<void> syncPushForAllWallets({bool force = false}) async {
    if (state.travelGuardSession) {
      return;
    }
    try {
      final settings = await ref.read(appSettingsRepositoryProvider).load();
      if (!settings.notificationsEnabled || !state.isUnlocked) {
        return;
      }

      final sessionManager = ref.read(backendSessionManagerProvider);
      final records = await _repository.readRecords();
      final ownersKey = (_publicKeys(records).toList()..sort()).join(',');
      final store = ref.read(secureStoreProvider);
      if (!force && await _pushSyncIsFresh(store, ownersKey)) {
        return;
      }
      final masterKey = _readMasterKey();
      final targets = <PushWalletTarget>[];
      // Active wallet first: its session also authorizes the prune call.
      final ordered = [
        ...records.where((r) => r.publicKey == state.publicKey),
        ...records.where((r) => r.publicKey != state.publicKey),
      ];
      for (final record in ordered) {
        try {
          final session =
              record.custody == WalletCustody.localMnemonic &&
                  record.secretScheme == WalletSecretScheme.masterKey &&
                  masterKey != null
              ? await sessionManager.sessionForLocalWallet(
                  ownerAddress: record.publicKey,
                  mnemonic: await _repository.decryptMnemonicWithKey(
                    record: record,
                    masterKey: masterKey,
                  ),
                  derivation: record.derivation,
                )
              : await sessionManager.storedSessionFor(record.publicKey);
          if (session != null) {
            targets.add(
              PushWalletTarget(
                ownerAddress: record.publicKey,
                authHeaders: sessionManager.headersFor(session),
              ),
            );
          }
        } catch (error) {
          debugPrint('[PUSH] Session for wallet push failed: $error');
        }
      }

      await ref
          .read(pushNotificationServiceProvider)
          .syncWalletDevices(
            targets: targets,
            keepOwnerAddresses: _publicKeys(records),
          );
      if (targets.length == records.length) {
        await store.write(
          AppConstants.pushWalletSyncKey,
          jsonEncode({
            'owners': ownersKey,
            'at': DateTime.now().toUtc().toIso8601String(),
          }),
        );
      }
    } catch (error, stack) {
      debugPrint('[PUSH] Wallet push sync failed: $error');
      debugPrintStack(stackTrace: stack, label: '[PUSH] Stack');
    }
  }

  Future<bool> _pushSyncIsFresh(KeyValueStore store, String ownersKey) async {
    try {
      final raw = await store.read(AppConstants.pushWalletSyncKey);
      if (raw == null) {
        return false;
      }
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final at = DateTime.tryParse(json['at'] as String? ?? '');
      return json['owners'] == ownersKey &&
          at != null &&
          DateTime.now().toUtc().difference(at) < _pushSyncInterval;
    } catch (_) {
      return false;
    }
  }

  /// Turns push off for this device (all wallets) when notifications are
  /// disabled in settings.
  Future<void> disablePushForAllWallets() => _prunePushWallets(const []);

  Future<void> _prunePushWallets(List<String> keepOwnerAddresses) async {
    try {
      final sessionManager = ref.read(backendSessionManagerProvider);
      final records = await _repository.readRecords();
      for (final record in records) {
        final session = await sessionManager.storedSessionFor(record.publicKey);
        if (session != null) {
          await ref
              .read(pushNotificationServiceProvider)
              .pruneWallets(
                authHeaders: sessionManager.headersFor(session),
                keepOwnerAddresses: keepOwnerAddresses,
              );
          return;
        }
      }
      debugPrint('[PUSH] Prune skipped: no stored backend session.');
    } catch (error, stack) {
      debugPrint('[PUSH] Push prune failed: $error');
      debugPrintStack(stackTrace: stack, label: '[PUSH] Stack');
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Future<void> _clearBackendSession() {
    return ref.read(backendSessionManagerProvider).clear();
  }

  Future<void> _deauthorizeSeedVaultRecords(
    List<StoredWalletRecord> records,
  ) async {
    final tokens = records
        .where((record) => record.custody == WalletCustody.seedVault)
        .map((record) => record.mwaAuthToken)
        .where((token) => token.isNotEmpty)
        .toSet();
    if (tokens.isEmpty) {
      return;
    }

    final service = ref.read(mobileWalletAdapterServiceProvider);
    for (final token in tokens) {
      try {
        await service.deauthorizeSeedVaultSeed(token);
      } catch (error) {
        debugPrint('[WALLET] Seed Vault deauthorize failed: $error');
      }
    }
  }

  Future<void> _ensureBackendSessionForExternalWallet(
    WalletControllerState nextState,
  ) async {
    final publicKey = nextState.publicKey;
    if (!nextState.isExternalWallet ||
        !nextState.isUnlocked ||
        publicKey == null ||
        publicKey.isEmpty) {
      return;
    }
    try {
      await ref.read(backendSessionManagerProvider).currentSession();
    } catch (error, stack) {
      debugPrint('[PUSH] External wallet backend session setup failed: $error');
      debugPrintStack(stackTrace: stack, label: '[PUSH] Stack');
    }
  }

  Future<WalletControllerState> _syncCloudChildSettings(
    WalletControllerState nextState, {
    bool activateLinkedChildMode = false,
  }) async {
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
        final linkedAsChild = snapshot.profile.accountRole == 'child';
        final shouldUseCloudChildMode = activateLinkedChildMode;
        final cloudChildModeEnabled =
            snapshot.profile.childModeEnabled ||
            (activateLinkedChildMode && linkedAsChild);
        final childModeEnabled = shouldUseCloudChildMode
            ? cloudChildModeEnabled
            : localRecord?.childModeEnabled ?? nextState.childModeEnabled;
        // A cloud profile linked as child but without a PIN must not wipe a
        // PIN this device already holds; keep it and upload it instead.
        final cloudHasPin =
            snapshot.profile.childModePinCipherText.isNotEmpty &&
            snapshot.profile.childModePinNonce.isNotEmpty &&
            snapshot.profile.childModePinSalt.isNotEmpty;
        final keepLocalPin =
            shouldUseCloudChildMode &&
            childModeEnabled &&
            !cloudHasPin &&
            (localRecord?.hasChildModePin ?? false);
        final useCloudPin = shouldUseCloudChildMode && !keepLocalPin;
        final childModePinCipherText = useCloudPin
            ? snapshot.profile.childModePinCipherText
            : localRecord?.childModePinCipherText ?? '';
        final childModePinNonce = useCloudPin
            ? snapshot.profile.childModePinNonce
            : localRecord?.childModePinNonce ?? '';
        final childModePinSalt = useCloudPin
            ? snapshot.profile.childModePinSalt
            : localRecord?.childModePinSalt ?? '';
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
          childModeEnabled: childModeEnabled,
          childModePinCipherText: childModePinCipherText,
          childModePinNonce: childModePinNonce,
          childModePinSalt: childModePinSalt,
          childWalletsJson: childWalletsJson,
        );

        final refreshedRecord = await repository.readRecord(
          publicKey: publicKey,
        );
        if (refreshedRecord == null) {
          return nextState;
        }
        if (keepLocalPin) {
          unawaited(_pushCloudChildModeSettings(publicKey));
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

  Future<void> _clearCloudChildModeSettings(String publicKey) async {
    try {
      await ref.read(backendApiClientProvider).clearWalletChildMode();
    } catch (error, stack) {
      debugPrint('[SYNC] Child mode cloud clear failed: $error');
      debugPrintStack(stackTrace: stack, label: '[SYNC] Stack');
      await _pushCloudChildModeSettings(publicKey);
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

  bool _resolvedBiometricEnabled(List<StoredWalletRecord> records) {
    return _supportsPersistentBiometricSessions &&
        records.any((record) => record.biometricEnabled);
  }

  Future<List<StoredWalletRecord>> _sanitizeBiometricRecords(
    List<StoredWalletRecord> records,
  ) async {
    if (_supportsPersistentBiometricSessions ||
        !records.any((record) => record.biometricEnabled)) {
      return records;
    }

    await _repository.clearBiometricSession();
    await _repository.setBiometricEnabledForAll(false);
    return _repository.readRecords();
  }

  /// Moves a legacy single-wallet biometric session to the master key.
  /// Best effort: the keystore key may need a recent biometric prompt.
  Future<void> _upgradeBiometricToMasterKey(List<int> masterKey) async {
    try {
      final records = await _repository.readRecords();
      if (!_resolvedBiometricEnabled(records) ||
          await _repository.hasBiometricMasterKey()) {
        return;
      }
      await _repository.persistBiometricMasterKey(masterKey);
      debugPrint('[SECURITY] Biometric session upgraded to master key.');
    } catch (error) {
      debugPrint('[SECURITY] Biometric upgrade deferred: $error');
    }
  }

  String _friendlyAddError(Object error) {
    if (error is DuplicateWalletException ||
        error is WalletLimitReachedException) {
      return error.toString();
    }
    if (error is FormatException || error is ArgumentError) {
      return 'Incorrect PIN';
    }
    return 'Unable to add this wallet.';
  }

  // Secrets in memory -------------------------------------------------------

  void _storeMasterKey(List<int> masterKey) {
    final previous = _masterKeyToken;
    _masterKeyToken = _ephemeralStore.store(
      base64Encode(masterKey),
      ttl: _unlockSessionTtl,
    );
    if (previous != null) {
      _ephemeralStore.clear(previous);
    }
  }

  Uint8List? _readMasterKey() {
    final token = _masterKeyToken;
    if (token == null) {
      return null;
    }
    final encoded = _ephemeralStore.retrieveTemporary(token);
    return encoded == null ? null : base64Decode(encoded);
  }

  String _storeMnemonic(String mnemonic) {
    return _ephemeralStore.store(mnemonic, ttl: _unlockSessionTtl);
  }

  void _clearMnemonicToken() {
    final token = state.mnemonicTokenId;
    if (token != null) {
      _ephemeralStore.clear(token);
    }
  }

  void _clearSecrets() {
    _clearMnemonicToken();
    final masterKeyToken = _masterKeyToken;
    if (masterKeyToken != null) {
      _ephemeralStore.clear(masterKeyToken);
      _masterKeyToken = null;
    }
  }

  List<String> _publicKeys(List<StoredWalletRecord> records) =>
      records.map((record) => record.publicKey).toList(growable: false);

  List<WalletSummary> _summaries(List<StoredWalletRecord> records) => [
    for (final record in records)
      WalletSummary(
        publicKey: record.publicKey,
        name: record.name,
        custody: record.custody,
      ),
  ];

  WalletControllerState _lockedState(
    StoredWalletRecord record, {
    required List<StoredWalletRecord> records,
    String? errorMessage,
  }) {
    return WalletControllerState(
      status: WalletStatus.locked,
      walletPublicKeys: _publicKeys(records),
      wallets: _summaries(records),
      publicKey: record.publicKey,
      derivation: record.derivation,
      custody: record.custody,
      mwaAuthToken: record.mwaAuthToken.isEmpty ? null : record.mwaAuthToken,
      seedVaultDerivationPath: record.seedVaultDerivationPath.isEmpty
          ? null
          : record.seedVaultDerivationPath,
      walletLabel: record.walletLabel.isEmpty ? null : record.walletLabel,
      biometricEnabled:
          !_travelGuardArmed && _resolvedBiometricEnabled(records),
      childModeEnabled: record.childModeEnabled,
      hasChildModePin: record.hasChildModePin,
      childWallets: _loadChildWallets(record),
      loggedOut: false,
      errorMessage: errorMessage,
      travelGuardArmed: _travelGuardArmed,
    );
  }
}

final walletControllerProvider =
    StateNotifierProvider<WalletController, WalletControllerState>((ref) {
      return WalletController(ref);
    });
