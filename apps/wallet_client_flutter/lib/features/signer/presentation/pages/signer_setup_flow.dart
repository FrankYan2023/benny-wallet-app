import 'package:bip39/bip39.dart' as bip39;
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/security/secure_screen.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../../core/widgets/pin_keypad.dart';
import '../../../../l10n/l10n.dart';
import '../signer_controller.dart';
import '../widgets/offline_checklist.dart';
import '../widgets/recovery_words_grid.dart';
import '../widgets/signer_language.dart';
import '../widgets/signer_ui.dart';
import '../widgets/word_quiz.dart';

enum _SetupStep {
  intro,
  offline,
  pin,
  pinConfirm,
  source,
  showWords,
  verify,
  import,
  finish,
}

/// First-run flow of signer mode. The phone is taken fully offline before
/// any seed exists, then the user sets a PIN and creates (24 words by
/// default) or imports a recovery phrase.
class SignerSetupFlow extends StatefulWidget {
  const SignerSetupFlow({
    super.key,
    required this.controller,
    required this.onCancel,
  });

  final SignerController controller;

  /// Leaves signer mode; only offered before a seed exists.
  final VoidCallback onCancel;

  @override
  State<SignerSetupFlow> createState() => _SignerSetupFlowState();
}

class _SignerSetupFlowState extends State<SignerSetupFlow> {
  static const _pinLength = 6;

  _SetupStep _step = _SetupStep.intro;
  bool _offlineReady = false;
  String _pin = '';
  String _pinAgain = '';
  String? _pinError;
  String? _mnemonic;
  final TextEditingController _importField = TextEditingController();
  late final TextEditingController _nameField = TextEditingController(
    text: 'Benny Signer',
  );
  String? _error;
  bool _biometric = false;
  bool _saving = false;

  @override
  void dispose() {
    _importField.dispose();
    _nameField.dispose();
    _mnemonic = null;
    super.dispose();
  }

  void _go(_SetupStep step) {
    setState(() {
      _step = step;
      _error = null;
    });
  }

  void _back() {
    switch (_step) {
      case _SetupStep.intro:
        widget.onCancel();
      case _SetupStep.offline:
        _go(_SetupStep.intro);
      case _SetupStep.pin:
        _go(_SetupStep.offline);
      case _SetupStep.pinConfirm:
        setState(() => _pinAgain = '');
        _go(_SetupStep.pin);
      case _SetupStep.source:
        setState(() {
          _pin = '';
          _pinAgain = '';
        });
        _go(_SetupStep.pin);
      case _SetupStep.showWords:
      case _SetupStep.import:
        _mnemonic = null;
        _go(_SetupStep.source);
      case _SetupStep.verify:
        _go(_SetupStep.showWords);
      case _SetupStep.finish:
        _go(_SetupStep.source);
    }
  }

  /// The seed is only ever generated or typed while the phone is offline.
  Future<bool> _stillOffline() async {
    final status = await widget.controller.offline.read();
    if (status.hasNetwork) {
      if (mounted) {
        setState(() {
          _offlineReady = false;
          _step = _SetupStep.offline;
          _error = context.l10n.signerNetworkDetected;
        });
      }
      return false;
    }
    return true;
  }

  void _onPinDigit(String digit) {
    setState(() {
      _pinError = null;
      if (_step == _SetupStep.pin && _pin.length < _pinLength) {
        _pin += digit;
        if (_pin.length == _pinLength) {
          _step = _SetupStep.pinConfirm;
        }
      } else if (_step == _SetupStep.pinConfirm &&
          _pinAgain.length < _pinLength) {
        _pinAgain += digit;
        if (_pinAgain.length == _pinLength) {
          if (_pinAgain == _pin) {
            _step = _SetupStep.source;
          } else {
            _pin = '';
            _pinAgain = '';
            _step = _SetupStep.pin;
            _pinError = context.l10n.signerPinMismatch;
          }
        }
      }
    });
  }

  void _onPinDelete() {
    setState(() {
      if (_step == _SetupStep.pin && _pin.isNotEmpty) {
        _pin = _pin.substring(0, _pin.length - 1);
      } else if (_step == _SetupStep.pinConfirm && _pinAgain.isNotEmpty) {
        _pinAgain = _pinAgain.substring(0, _pinAgain.length - 1);
      }
    });
  }

  Future<void> _create(int words) async {
    if (!await _stillOffline()) {
      return;
    }
    final mnemonic = bip39.generateMnemonic(strength: words == 24 ? 256 : 128);
    setState(() => _mnemonic = mnemonic);
    _go(_SetupStep.showWords);
  }

  Future<void> _checkImport() async {
    if (!await _stillOffline()) {
      return;
    }
    final normalized = _importField.text
        .trim()
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .join(' ');
    final count = normalized.split(' ').length;
    if ((count != 12 && count != 24) || !bip39.validateMnemonic(normalized)) {
      if (mounted) {
        setState(() => _error = context.l10n.signerImportInvalid);
      }
      return;
    }
    _importField.clear();
    _mnemonic = normalized;
    _go(_SetupStep.finish);
  }

  Future<void> _finish() async {
    if (_saving || !await _stillOffline()) {
      return;
    }
    setState(() => _saving = true);
    try {
      final name = _nameField.text.trim();
      await widget.controller.createVault(
        mnemonic: _mnemonic!,
        pin: _pin,
        deviceName: name.isEmpty ? 'Benny Signer' : name,
        enableBiometric: _biometric,
      );
      _mnemonic = null;
      _pin = '';
      _pinAgain = '';
    } on Object {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = context.l10n.signerSetupFailed;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = switch (_step) {
      _SetupStep.intro => l10n.signerIntroTitle,
      _SetupStep.offline => l10n.signerOfflineTitle,
      _SetupStep.pin => l10n.signerPinTitle,
      _SetupStep.pinConfirm => l10n.signerPinConfirmTitle,
      _SetupStep.source => l10n.signerSourceTitle,
      _SetupStep.showWords => l10n.signerWordsTitle,
      _SetupStep.verify => l10n.signerVerifyTitle,
      _SetupStep.import => l10n.signerImportTitle,
      _SetupStep.finish => l10n.signerFinishTitle,
    };
    final secret =
        _step == _SetupStep.showWords ||
        _step == _SetupStep.verify ||
        _step == _SetupStep.import;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_saving) {
          _back();
        }
      },
      child: SecureScreen(
        enabled: secret,
        child: SignerScaffold(
          title: _step == _SetupStep.intro ? null : title,
          leading: IconButton(
            icon: Icon(
              _step == _SetupStep.intro
                  ? Icons.close_rounded
                  : Icons.arrow_back_rounded,
            ),
            onPressed: _saving ? null : _back,
          ),
          actions: _step == _SetupStep.intro
              ? const [SignerLanguageButton()]
              : null,
          children: _body(context),
        ),
      ),
    );
  }

  List<Widget> _body(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    Widget errorText() => _error == null
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(top: 12),
            child: SignerNotice(
              text: _error!,
              icon: Icons.error_outline_rounded,
              tone: SignerTone.danger,
            ),
          );

    switch (_step) {
      case _SetupStep.intro:
        final points = [
          (Icons.lock_rounded, l10n.signerIntroPoint1),
          (Icons.qr_code_scanner_rounded, l10n.signerIntroPoint2),
          (Icons.airplanemode_active_rounded, l10n.signerIntroPoint3),
          (Icons.edit_note_rounded, l10n.signerIntroPoint4),
        ];
        return [
          SignerHero(
            showLogo: true,
            tone: SignerTone.brand,
            title: l10n.signerIntroTitle,
            subtitle: l10n.signerIntroSubtitle,
          ),
          signerGap,
          WalletCard(
            child: Column(
              children: [
                for (final (icon, line) in points)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            icon,
                            size: 18,
                            color: theme.colorScheme.onTertiaryContainer,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 7),
                            child: Text(line, style: theme.textTheme.bodyLarge),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          PrimaryButton(
            label: l10n.signerIntroStart,
            onPressed: () => _go(_SetupStep.offline),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: widget.onCancel,
            child: Text(l10n.signerIntroCancel),
          ),
        ];
      case _SetupStep.offline:
        return [
          SignerHero(
            icon: Icons.airplanemode_active_rounded,
            title: l10n.signerOfflineTitle,
            subtitle: l10n.signerOfflineBody,
          ),
          errorText(),
          signerGap,
          WalletCard(
            child: OfflineChecklist(
              service: widget.controller.offline,
              onReadyChanged: (ready) => setState(() => _offlineReady = ready),
            ),
          ),
          const SizedBox(height: 22),
          PrimaryButton(
            label: l10n.commonContinue,
            onPressed: _offlineReady ? () => _go(_SetupStep.pin) : null,
          ),
        ];
      case _SetupStep.pin:
      case _SetupStep.pinConfirm:
        final entered = _step == _SetupStep.pin ? _pin : _pinAgain;
        return [
          const SizedBox(height: 8),
          const Center(child: BrandLogo(size: 64)),
          const SizedBox(height: 16),
          Text(
            _step == _SetupStep.pin
                ? l10n.signerPinBody
                : l10n.signerPinConfirmBody,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          PinDots(filledCount: entered.length, length: _pinLength),
          if (_pinError != null) ...[
            const SizedBox(height: 16),
            Text(
              _pinError!,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ],
          const SizedBox(height: 28),
          Center(
            child: PinKeypad(onDigit: _onPinDigit, onDelete: _onPinDelete),
          ),
        ];
      case _SetupStep.source:
        return [
          Text(l10n.signerSourceBody, style: theme.textTheme.bodyLarge),
          signerGap,
          SignerTile(
            icon: Icons.auto_awesome_rounded,
            tone: SignerTone.brand,
            title: l10n.signerSourceCreate24,
            subtitle: l10n.signerSourceCreate24Subtitle,
            onTap: () => _create(24),
          ),
          signerGap,
          SignerTile(
            icon: Icons.short_text_rounded,
            tone: SignerTone.info,
            title: l10n.signerSourceCreate12,
            subtitle: l10n.signerSourceCreate12Subtitle,
            onTap: () => _create(12),
          ),
          signerGap,
          SignerTile(
            icon: Icons.download_rounded,
            tone: SignerTone.warm,
            title: l10n.signerSourceImport,
            subtitle: l10n.signerSourceImportSubtitle,
            onTap: () => _go(_SetupStep.import),
          ),
        ];
      case _SetupStep.showWords:
        return [
          SignerNotice(
            text: l10n.signerWordsWarning,
            icon: Icons.warning_amber_rounded,
            tone: SignerTone.danger,
          ),
          signerGap,
          WalletCard(
            padding: const EdgeInsets.all(14),
            child: RecoveryWordsGrid(words: _mnemonic!.split(' ')),
          ),
          const SizedBox(height: 22),
          PrimaryButton(
            label: l10n.signerWordsDone,
            onPressed: () => _go(_SetupStep.verify),
          ),
        ];
      case _SetupStep.verify:
        return [
          Text(
            l10n.signerQuizBody(
              quizQuestionCount(_mnemonic!.split(' ').length),
            ),
            style: theme.textTheme.bodyLarge,
          ),
          signerGap,
          WordQuiz(
            words: _mnemonic!.split(' '),
            onPassed: () => _go(_SetupStep.finish),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => _go(_SetupStep.showWords),
            icon: const Icon(Icons.visibility_rounded),
            label: Text(l10n.signerQuizShowWords),
          ),
        ];
      case _SetupStep.import:
        return [
          SignerHero(
            icon: Icons.download_rounded,
            tone: SignerTone.warm,
            title: l10n.signerImportTitle,
            subtitle: l10n.signerImportBody,
          ),
          signerGap,
          WalletCard(
            child: TextField(
              controller: _importField,
              minLines: 4,
              maxLines: 6,
              autocorrect: false,
              enableSuggestions: false,
              keyboardType: TextInputType.visiblePassword,
            ),
          ),
          errorText(),
          const SizedBox(height: 22),
          PrimaryButton(label: l10n.commonContinue, onPressed: _checkImport),
        ];
      case _SetupStep.finish:
        return [
          SignerHero(
            icon: Icons.verified_rounded,
            tone: SignerTone.success,
            title: l10n.signerFinishTitle,
            subtitle: l10n.signerFinishSubtitle,
          ),
          signerGap,
          WalletCard(
            child: Column(
              children: [
                TextField(
                  controller: _nameField,
                  maxLength: 24,
                  decoration: InputDecoration(
                    labelText: l10n.signerDeviceNameLabel,
                    helperText: l10n.signerDeviceNameHelper,
                  ),
                ),
                if (widget.controller.biometricAvailable)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _biometric,
                    activeTrackColor: AppColors.primaryBright,
                    onChanged: _saving
                        ? null
                        : (value) => setState(() => _biometric = value),
                    title: Text(
                      l10n.signerBiometricToggle,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
              ],
            ),
          ),
          errorText(),
          const SizedBox(height: 22),
          if (_saving)
            const Center(child: CircularProgressIndicator())
          else
            PrimaryButton(label: l10n.signerFinishButton, onPressed: _finish),
        ];
    }
  }
}
