import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/airgap/airgap_protocol.dart';
import '../../../core/airgap/builtin_token_list.dart';
import '../../../core/airgap/signer_engine.dart';
import '../../../core/airgap/token_registry.dart';
import '../../../core/services/biometric_auth_service.dart';
import '../data/offline_status.dart';
import '../data/signer_vault.dart';

enum SignerStage { loading, setup, locked, unlocked }

/// The seed was not opened (or was closed again at once) because the phone
/// is not offline, or the post-update offline check has not been done.
class SignerNotOffline implements Exception {
  const SignerNotOffline({required this.recheckPending});

  /// True when the offline checklist must be confirmed first
  /// ([SignerController.confirmOfflineRecheck]).
  final bool recheckPending;

  @override
  String toString() => recheckPending
      ? 'The offline check must be done before unlocking.'
      : 'A network connection is up; the signer stays locked.';
}

/// State of the offline signer: whether a seed exists, whether it is
/// unlocked, and the signing engine while it is. Everything here stays on
/// the device; the only output is QR codes the user chooses to show.
class SignerController extends ChangeNotifier {
  SignerController({
    required SignerVault vault,
    required OfflineStatusService offline,
    required BiometricAuthService biometricAuth,
    required this.appVersion,
  }) : _vault = vault,
       _offline = offline,
       _biometricAuth = biometricAuth;

  static const _networkPollInterval = Duration(seconds: 3);

  final SignerVault _vault;
  final OfflineStatusService _offline;
  final BiometricAuthService _biometricAuth;
  final String appVersion;
  final TokenRegistry tokens = TokenRegistry(version: builtinTokenListVersion);

  SignerStage _stage = SignerStage.loading;
  SignerVaultInfo? _info;
  SignerSession? _session;
  SignerEngine? _engine;
  OfflineStatus? _status;
  Timer? _networkTimer;
  bool _biometricAvailable = false;

  /// Checks (required ones only) that passed when the seed was opened; any
  /// of them failing later locks the signer.
  Set<OfflineCheck> _baseline = const {};
  bool _recheckConfirmed = false;

  SignerStage get stage => _stage;
  SignerVaultInfo? get info => _info;
  SignerEngine? get engine => _engine;
  SignerSession? get session => _session;
  OfflineStatus? get offlineStatus => _status;
  bool get biometricAvailable => _biometricAvailable;
  OfflineStatusService get offline => _offline;

  /// After an app update the full offline checklist runs again before the
  /// seed is opened, because the update needed a network. [appVersion] is
  /// "version+build", so a rebuild with the same version name counts too;
  /// an unknown version (empty) always asks for the check. A vault last
  /// opened by an older build that stored only "0.1.0" simply gets the
  /// check once, then records the full string.
  bool get needsOfflineRecheck => _versionChanged && !_recheckConfirmed;

  bool get _versionChanged {
    if (appVersion.isEmpty) {
      return true;
    }
    final last = _info?.appVersionAtLastUnlock;
    return last != null && last != appVersion;
  }

  AirGapSignerInfo get signerInfo => AirGapSignerInfo(
    // The wallet compares dotted versions; the build number stays local.
    appVersion: appVersion.split('+').first,
    protocolVersion: airGapProtocolVersion,
    tokenListVersion: tokens.version,
    capabilities: const {
      AirGapCapability.signTransaction,
      AirGapCapability.signMessage,
      AirGapCapability.lookupTables,
      AirGapCapability.tokenHints,
      AirGapCapability.signIn,
    },
  );

  Future<void> load() async {
    _info = await _vault.info();
    _biometricAvailable = await _biometricAuth.isSupported();
    _stage = _info == null ? SignerStage.setup : SignerStage.locked;
    notifyListeners();
  }

  Future<OfflineStatus> refreshOfflineStatus() async {
    final status = await _readOffline();
    _status = status;
    if (_stage == SignerStage.unlocked && _regressed(status)) {
      // A live network, or a radio / airplane mode / USB debugging change
      // while the seed is open: close it at once.
      lock();
    } else {
      if (_stage == SignerStage.unlocked) {
        // Ratchet: whatever has been off during this session must stay off.
        _baseline = {..._baseline, ..._required(status)};
      }
      notifyListeners();
    }
    return status;
  }

  /// The user went through the offline checklist after an update. Only
  /// accepted when the phone reads as offline right now.
  Future<bool> confirmOfflineRecheck() async {
    final status = await _readOffline();
    _status = status;
    final ok = status.isOffline && !status.hasNetwork;
    if (ok) {
      _recheckConfirmed = true;
    }
    notifyListeners();
    return ok;
  }

  /// A failing read counts as online.
  Future<OfflineStatus> _readOffline() async {
    try {
      return await _offline.read();
    } on Object {
      return const OfflineStatus(
        passed: {},
        detected: {OfflineCheck.noNetwork},
        recommendedOnly: {OfflineCheck.simRemoved},
      );
    }
  }

  static Set<OfflineCheck> _required(OfflineStatus status) => {
    for (final check in status.passed)
      if (!status.recommendedOnly.contains(check)) check,
  };

  bool _regressed(OfflineStatus status) =>
      status.hasNetwork || !status.passed.containsAll(_baseline);

  /// Refuses before the seed is touched (no PIN attempt is used).
  Future<OfflineStatus> _requireOffline() async {
    if (needsOfflineRecheck) {
      throw const SignerNotOffline(recheckPending: true);
    }
    final status = await _readOffline();
    _status = status;
    if (status.hasNetwork) {
      notifyListeners();
      throw const SignerNotOffline(recheckPending: false);
    }
    return status;
  }

  Future<void> createVault({
    required String mnemonic,
    required String pin,
    required String deviceName,
    required bool enableBiometric,
  }) async {
    await _vault.create(mnemonic: mnemonic, pin: pin, deviceName: deviceName);
    final session = await _vault.unlockWithPin(pin, appVersion: appVersion);
    if (enableBiometric) {
      try {
        await _vault.setBiometric(session, true);
      } on Object {
        // Biometrics stay off; the PIN works.
      }
    }
    _info = await _vault.info();
    try {
      await _open(session);
    } on SignerNotOffline {
      // Saved, but a network showed up: unlock again once offline.
      _stage = SignerStage.locked;
      notifyListeners();
      rethrow;
    }
  }

  /// Throws [SignerNotOffline] (nothing opened, no attempt used),
  /// [SignerWrongPin] or [SignerWiped].
  Future<void> unlockWithPin(String pin) async {
    await _requireOffline();
    final SignerSession session;
    try {
      session = await _vault.unlockWithPin(pin, appVersion: appVersion);
    } on SignerWiped {
      await _afterWipe();
      rethrow;
    }
    await _open(session);
  }

  Future<bool> unlockWithBiometric({required String reason}) async {
    if (!(_info?.biometricEnabled ?? false)) {
      return false;
    }
    try {
      await _requireOffline();
    } on SignerNotOffline {
      return false;
    }
    final approved = await _biometricAuth.authenticateForUnlock(
      localizedReason: reason,
    );
    if (!approved) {
      return false;
    }
    try {
      await _requireOffline();
      final session = await _vault.unlockWithBiometric(appVersion: appVersion);
      await _open(session);
      return true;
    } on Object {
      return false;
    }
  }

  /// Opens [session]: checks the network again right after the seed was
  /// decrypted and closes it at once (throwing [SignerNotOffline]) if one
  /// appeared, then keeps watching while unlocked.
  Future<void> _open(SignerSession session) async {
    final status = await _readOffline();
    _status = status;
    if (status.hasNetwork) {
      session.dispose();
      lock();
      throw const SignerNotOffline(recheckPending: false);
    }
    final previous = _session;
    _session = session;
    if (previous != null && !identical(previous.masterKey, session.masterKey)) {
      previous.dispose();
    }
    _engine?.dispose();
    _engine = null;
    final SignerEngine engine;
    try {
      engine = await SignerEngine.fromMnemonic(
        session.mnemonic,
        accountIndexes: session.accountIndexes,
      );
    } on Object {
      _dropSecrets();
      _stage = _info == null ? SignerStage.setup : SignerStage.locked;
      notifyListeners();
      rethrow;
    }
    _engine = engine;
    _info = await _vault.info();
    _baseline = _required(status);
    _lockedByUser = false;
    _stage = SignerStage.unlocked;
    _networkTimer?.cancel();
    _networkTimer = Timer.periodic(
      _networkPollInterval,
      (_) => unawaited(refreshOfflineStatus()),
    );
    notifyListeners();
    // The engine took a moment; look once more instead of waiting a tick.
    await refreshOfflineStatus();
    if (_stage != SignerStage.unlocked) {
      throw const SignerNotOffline(recheckPending: false);
    }
  }

  void _dropSecrets() {
    _networkTimer?.cancel();
    _networkTimer = null;
    _engine?.dispose();
    _engine = null;
    _session?.dispose();
    _session = null;
    _baseline = const {};
  }

  /// True after the user tapped the lock button: the unlock screen then
  /// waits for them instead of starting biometrics on its own.
  bool get lockedByUser => _lockedByUser;
  bool _lockedByUser = false;

  void lock({bool byUser = false}) {
    if (_stage != SignerStage.unlocked) {
      return;
    }
    _lockedByUser = byUser;
    _dropSecrets();
    // An unknown version asks for the checklist before every unlock.
    _recheckConfirmed = false;
    _stage = _info == null ? SignerStage.setup : SignerStage.locked;
    notifyListeners();
  }

  /// Uses up a PIN attempt when wrong, like unlocking. Returns false when
  /// wrong; when that was the last attempt the seed is erased and the
  /// controller moves to setup.
  Future<bool> verifyPin(String pin) async {
    try {
      return await _vault.verifyPin(pin);
    } on SignerWiped {
      await _afterWipe();
      return false;
    }
  }

  /// Throws [SignerWrongPin] (attempts left) or [SignerWiped] (the seed was
  /// erased and the controller moved to setup).
  Future<void> checkPin(String pin) async {
    try {
      await _vault.checkPin(pin);
    } on SignerWiped {
      await _afterWipe();
      rethrow;
    }
  }

  Future<bool> setBiometric(bool enabled, {required String reason}) async {
    final session = _session;
    if (session == null) {
      return false;
    }
    if (enabled) {
      final approved = await _biometricAuth.authenticateForSetup(
        localizedReason: reason,
      );
      if (!approved) {
        return false;
      }
    }
    try {
      await _vault.setBiometric(session, enabled);
    } on Object {
      return false;
    }
    _info = await _vault.info();
    notifyListeners();
    return true;
  }

  Future<void> setAccountCount(int count) async {
    final session = _session;
    if (session == null) {
      return;
    }
    await _vault.setAccountCount(count);
    _info = await _vault.info();
    final reopened = SignerSession(
      mnemonic: session.mnemonic,
      accountIndexes: [for (var i = 0; i < _info!.accountCount; i++) i],
      // A copy: _open wipes the previous session's buffer.
      masterKey: Uint8List.fromList(session.masterKey),
    );
    await _open(reopened);
  }

  /// Erases the seed. The caller then leaves signer mode.
  Future<void> wipe() async {
    await _vault.wipe();
    await _afterWipe();
  }

  Future<void> _afterWipe() async {
    _dropSecrets();
    _info = null;
    _stage = SignerStage.setup;
    notifyListeners();
  }

  @override
  void dispose() {
    _dropSecrets();
    super.dispose();
  }
}
