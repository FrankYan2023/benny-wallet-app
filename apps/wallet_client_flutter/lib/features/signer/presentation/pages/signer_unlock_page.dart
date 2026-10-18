import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/brand_logo.dart';
import '../../../../core/widgets/pin_keypad.dart';
import '../../../../l10n/l10n.dart';
import '../../data/signer_vault.dart';
import '../signer_controller.dart';
import '../widgets/offline_checklist.dart';
import '../widgets/signer_language.dart';
import '../widgets/signer_ui.dart';

class SignerUnlockPage extends StatefulWidget {
  const SignerUnlockPage({super.key, required this.controller});

  final SignerController controller;

  @override
  State<SignerUnlockPage> createState() => _SignerUnlockPageState();
}

class _SignerUnlockPageState extends State<SignerUnlockPage> {
  static const _pinLength = 6;

  String _pin = '';
  String? _error;
  bool _busy = false;
  bool _hasNetwork = false;
  bool _recheckReady = false;
  bool _biometricTried = false;
  Timer? _timer;

  SignerController get _controller => widget.controller;

  /// The controller enforces this too; the page only shows the checklist.
  bool get _showRecheck => _controller.needsOfflineRecheck;

  @override
  void initState() {
    super.initState();
    unawaited(_poll());
    _timer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => unawaited(_poll()),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _poll() async {
    final status = await _controller.offline.read();
    if (!mounted) {
      return;
    }
    setState(() => _hasNetwork = status.hasNetwork);
    if (!_hasNetwork && !_showRecheck) {
      unawaited(_tryBiometricOnce());
    }
  }

  Future<void> _confirmRecheck() async {
    final ok = await _controller.confirmOfflineRecheck();
    if (!mounted) {
      return;
    }
    setState(() {
      if (!ok) {
        _recheckReady = false;
      }
    });
    if (ok) {
      unawaited(_poll());
    }
  }

  Future<void> _tryBiometricOnce() async {
    if (_biometricTried ||
        _controller.lockedByUser ||
        !(_controller.info?.biometricEnabled ?? false)) {
      return;
    }
    _biometricTried = true;
    await _unlockWithBiometric();
  }

  Future<void> _unlockWithBiometric() async {
    if (_busy || _hasNetwork) {
      return;
    }
    setState(() => _busy = true);
    await _controller.unlockWithBiometric(
      reason: context.l10n.signerBiometricReason,
    );
    if (mounted) {
      setState(() => _busy = false);
    }
  }

  void _onDigit(String digit) {
    if (_busy || _hasNetwork || _pin.length >= _pinLength) {
      return;
    }
    setState(() {
      _error = null;
      _pin += digit;
    });
    if (_pin.length == _pinLength) {
      unawaited(_submit());
    }
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    final l10n = context.l10n;
    try {
      await _controller.unlockWithPin(_pin);
    } on SignerWrongPin catch (error) {
      if (mounted) {
        setState(() {
          _pin = '';
          _busy = false;
          _error = l10n.signerWrongPin(error.attemptsLeft);
        });
      }
    } on SignerWiped {
      // The controller moves to setup; nothing to show here.
    } on SignerNotOffline {
      // Refused before the PIN was tried (or closed again at once).
      if (mounted) {
        setState(() {
          _pin = '';
          _busy = false;
          _hasNetwork = _controller.offlineStatus?.hasNetwork ?? true;
          _error = _hasNetwork ? null : l10n.signerUnlockFailed;
        });
      }
    } on Object {
      if (mounted) {
        setState(() {
          _pin = '';
          _busy = false;
          _error = l10n.signerUnlockFailed;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    if (_showRecheck) {
      return SignerScaffold(
        title: l10n.signerRecheckTitle,
        children: [
          SignerHero(
            icon: Icons.system_update_rounded,
            title: l10n.signerRecheckTitle,
            subtitle: l10n.signerRecheckBody,
          ),
          signerGap,
          WalletCard(
            child: OfflineChecklist(
              service: _controller.offline,
              onReadyChanged: (ready) => setState(() => _recheckReady = ready),
            ),
          ),
          const SizedBox(height: 22),
          PrimaryButton(
            label: l10n.commonContinue,
            onPressed: _recheckReady ? _confirmRecheck : null,
          ),
        ],
      );
    }

    final info = _controller.info;
    return Scaffold(
      appBar: AppBar(actions: const [SignerLanguageButton()]),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          children: [
            const Center(child: BrandLogo(size: 84)),
            const SizedBox(height: 14),
            Text(
              info?.deviceName ?? '',
              textAlign: TextAlign.center,
              style: theme.textTheme.displaySmall,
            ),
            const SizedBox(height: 6),
            Text(
              l10n.signerUnlockSubtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            if (_hasNetwork) ...[
              const SizedBox(height: 16),
              SignerNotice(
                text: l10n.signerUnlockNetworkBlocked,
                icon: Icons.wifi_rounded,
                tone: SignerTone.danger,
              ),
            ],
            const SizedBox(height: 26),
            PinDots(filledCount: _pin.length, length: _pinLength),
            SizedBox(
              height: 40,
              child: Center(
                child: _error == null
                    ? null
                    : Text(
                        _error!,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
              ),
            ),
            Center(
              child: PinKeypad(
                onDigit: _hasNetwork ? null : _onDigit,
                onDelete: _pin.isEmpty
                    ? null
                    : () => setState(
                        () => _pin = _pin.substring(0, _pin.length - 1),
                      ),
              ),
            ),
            if (info?.biometricEnabled ?? false) ...[
              const SizedBox(height: 16),
              Center(
                child: TextButton.icon(
                  onPressed: _hasNetwork || _busy ? null : _unlockWithBiometric,
                  icon: const Icon(Icons.fingerprint_rounded),
                  label: Text(l10n.signerUseBiometric),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
