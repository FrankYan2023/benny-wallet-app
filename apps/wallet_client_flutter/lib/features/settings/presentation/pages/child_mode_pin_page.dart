import 'package:flutter/material.dart';

import '../../../../core/security/secure_screen.dart';
import '../../../../core/widgets/pin_keypad.dart';
import '../../../../l10n/l10n.dart';

enum ChildModePinPageMode { create, verify }

class ChildModePinPage extends StatefulWidget {
  const ChildModePinPage.create({super.key})
    : mode = ChildModePinPageMode.create;

  const ChildModePinPage.verify({super.key})
    : mode = ChildModePinPageMode.verify;

  final ChildModePinPageMode mode;

  @override
  State<ChildModePinPage> createState() => _ChildModePinPageState();
}

class _ChildModePinPageState extends State<ChildModePinPage> {
  static const _pinLength = 4;

  String _pin = '';
  String _confirmPin = '';
  bool _confirming = false;

  bool get _isCreateFlow => widget.mode == ChildModePinPageMode.create;
  String get _activePin => _confirming ? _confirmPin : _pin;

  void _appendDigit(String digit) {
    if (_activePin.length >= _pinLength) {
      return;
    }

    setState(() {
      if (_confirming) {
        _confirmPin = '$_confirmPin$digit';
      } else {
        _pin = '$_pin$digit';
      }
    });

    if (_activePin.length == _pinLength) {
      Future<void>.microtask(_submitStep);
    }
  }

  void _removeDigit() {
    if (_activePin.isEmpty) {
      return;
    }

    setState(() {
      if (_confirming) {
        _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
      } else {
        _pin = _pin.substring(0, _pin.length - 1);
      }
    });
  }

  void _handleBack() {
    if (_confirming) {
      setState(() {
        _confirming = false;
        _confirmPin = '';
      });
      return;
    }

    Navigator.of(context).pop();
  }

  Future<void> _submitStep() async {
    if (_activePin.length != _pinLength) {
      return;
    }

    if (_isCreateFlow && !_confirming) {
      setState(() => _confirming = true);
      return;
    }

    if (_isCreateFlow && _pin != _confirmPin) {
      setState(() => _confirmPin = '');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.pinMismatch)));
      return;
    }

    Navigator.of(context).pop(_isCreateFlow ? _pin : _activePin);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final baseTheme = Theme.of(context);
    final theme = baseTheme.copyWith(
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: const Color(0xFF4B97D3),
        surface: Colors.white,
        onSurface: const Color(0xFF16364D),
        outline: const Color(0xFF99B9D5),
      ),
    );

    final title = switch (widget.mode) {
      ChildModePinPageMode.create when _confirming =>
        l10n.childModeConfirmPinTitle,
      ChildModePinPageMode.create => l10n.childModeSetPinTitle,
      ChildModePinPageMode.verify => l10n.childModeEnterPinTitle,
    };
    final subtitle = switch (widget.mode) {
      ChildModePinPageMode.create when _confirming =>
        l10n.childModeConfirmPinSubtitle,
      ChildModePinPageMode.create => l10n.childModeSetPinSubtitle,
      ChildModePinPageMode.verify => l10n.childModeEnterPinSubtitle,
    };

    return SecureScreen(
      child: Theme(
        data: theme,
        child: Scaffold(
          backgroundColor: const Color(0xFFEAF6FF),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      tooltip: l10n.commonBack,
                      onPressed: _handleBack,
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(36),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x143A6E93),
                          blurRadius: 28,
                          offset: Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD5EEFF),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(
                            Icons.child_care_rounded,
                            color: Color(0xFF4B97D3),
                            size: 34,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: const Color(0xFF16364D),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF52738C),
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (widget.mode == ChildModePinPageMode.verify) ...[
                          Text(
                            l10n.unlockEnterPin,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF16364D),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 18),
                        ],
                        PinDots(
                          filledCount: _activePin.length,
                          length: _pinLength,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  PinKeypad(
                    onDigit: _appendDigit,
                    onDelete: _activePin.isEmpty ? null : _removeDigit,
                    width: 320,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.childModeOnlyUsed,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF608099),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
