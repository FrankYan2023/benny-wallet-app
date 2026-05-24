import 'package:flutter/material.dart';

import '../security/secure_screen.dart';
import 'pin_keypad.dart';

class PinPromptDialog extends StatefulWidget {
  const PinPromptDialog({super.key, this.title});

  final String? title;

  @override
  State<PinPromptDialog> createState() => _PinPromptDialogState();
}

class _PinPromptDialogState extends State<PinPromptDialog> {
  String _pin = '';

  void _appendDigit(String digit) {
    if (_pin.length >= 6) {
      return;
    }
    setState(() => _pin = '$_pin$digit');
    if (_pin.length == 6) {
      Future<void>.microtask(() {
        if (mounted) {
          Navigator.of(context).pop(_pin);
        }
      });
    }
  }

  void _removeDigit() {
    if (_pin.isEmpty) {
      return;
    }
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SecureScreen(
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
              const SizedBox(height: 8),
              if (widget.title != null) ...[
                Text(
                  widget.title!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
              ],
              Text(
                'Enter PIN',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              PinDots(filledCount: _pin.length),
              const SizedBox(height: 24),
              PinKeypad(
                onDigit: _appendDigit,
                onDelete: _pin.isEmpty ? null : _removeDigit,
                width: 320,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
