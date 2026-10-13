import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/security/secure_screen.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/pin_keypad.dart';
import '../../../../l10n/l10n.dart';
import '../../../auth/presentation/providers/wallet_controller.dart';

enum _ChangePinStep { current, next, confirm }

/// Current PIN → new PIN → confirm. Only the master key envelope is
/// re-encrypted, so this is instant regardless of how many wallets exist.
class ChangePinPage extends ConsumerStatefulWidget {
  const ChangePinPage({super.key});

  static const routeName = 'changePin';
  static const routePath = '/change-pin';

  @override
  ConsumerState<ChangePinPage> createState() => _ChangePinPageState();
}

class _ChangePinPageState extends ConsumerState<ChangePinPage> {
  _ChangePinStep _step = _ChangePinStep.current;
  String _current = '';
  String _next = '';
  String _input = '';
  String? _error;
  bool _submitting = false;

  void _appendDigit(String digit) {
    if (_submitting || _input.length >= 6) {
      return;
    }
    setState(() {
      _input = '$_input$digit';
      _error = null;
    });
    if (_input.length == 6) {
      Future<void>.microtask(_submitStep);
    }
  }

  void _removeDigit() {
    if (_submitting || _input.isEmpty) {
      return;
    }
    setState(() => _input = _input.substring(0, _input.length - 1));
  }

  Future<void> _submitStep() async {
    final l10n = context.l10n;
    final controller = ref.read(walletControllerProvider.notifier);
    switch (_step) {
      case _ChangePinStep.current:
        setState(() => _submitting = true);
        try {
          await controller.verifyPin(_input);
          _current = _input;
          _moveTo(_ChangePinStep.next);
        } catch (_) {
          _fail(l10n.unlockIncorrectPin);
        }
      case _ChangePinStep.next:
        if (_input == _current) {
          _fail(l10n.changePinSameAsOld);
          return;
        }
        _next = _input;
        _moveTo(_ChangePinStep.confirm);
      case _ChangePinStep.confirm:
        if (_input != _next) {
          _fail(l10n.pinMismatch);
          return;
        }
        setState(() => _submitting = true);
        try {
          await controller.changePin(currentPin: _current, newPin: _next);
          HapticFeedback.mediumImpact();
          if (!mounted) {
            return;
          }
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.changePinSuccess)));
          context.pop();
        } catch (_) {
          _fail(l10n.walletActionFailed);
        }
    }
  }

  void _moveTo(_ChangePinStep step) {
    if (!mounted) {
      return;
    }
    setState(() {
      _step = step;
      _input = '';
      _submitting = false;
    });
  }

  void _fail(String message) {
    if (!mounted) {
      return;
    }
    HapticFeedback.heavyImpact();
    setState(() {
      _input = '';
      _error = message;
      _submitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final title = switch (_step) {
      _ChangePinStep.current => l10n.changePinCurrent,
      _ChangePinStep.next => l10n.changePinNew,
      _ChangePinStep.confirm => l10n.changePinConfirm,
    };

    return SecureScreen(
      child: AppScaffold(
        title: l10n.settingsChangePin,
        child: Column(
          children: [
            const Spacer(),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                title,
                key: ValueKey(_step),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.settingsChangePinSubtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            PinDots(filledCount: _input.length),
            SizedBox(
              height: 34,
              child: _error == null
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            PinKeypad(
              onDigit: _submitting ? null : _appendDigit,
              onDelete: _submitting || _input.isEmpty ? null : _removeDigit,
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
