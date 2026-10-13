import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../l10n/l10n.dart';

/// Shared amount entry used wherever a token amount is typed (send, swap):
/// a large tappable amount on the page and a bottom-sheet keypad with an
/// even larger readout, so every amount input looks and works the same.

/// Opens the keypad sheet. Returns the entered text, or null when dismissed.
/// [preview] renders under the readout and is rebuilt on every key press
/// (e.g. the swap output or the USD value).
Future<String?> showAmountKeypadSheet(
  BuildContext context, {
  required String initialValue,
  Widget Function(String workingValue)? preview,
  String? suffix,
}) {
  var workingValue = initialValue;
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          void append(String value) {
            setModalState(() {
              if (value == '.') {
                if (workingValue.contains('.')) {
                  return;
                }
                workingValue = workingValue.isEmpty ? '0.' : '$workingValue.';
              } else if (workingValue == '0') {
                workingValue = value;
              } else {
                workingValue = '$workingValue$value';
              }
            });
          }

          void delete() {
            setModalState(() {
              if (workingValue.isEmpty) {
                return;
              }
              workingValue = workingValue.substring(0, workingValue.length - 1);
            });
          }

          final readoutStyle = Theme.of(context).textTheme.displayLarge
              ?.copyWith(
                fontSize: 48,
                fontWeight: FontWeight.w800,
                height: 0.92,
                letterSpacing: -1.8,
              );
          return SingleChildScrollView(
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 64,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text.rich(
                            TextSpan(
                              text: workingValue.isEmpty ? '0' : workingValue,
                              children: [
                                if (suffix != null)
                                  TextSpan(
                                    text: ' $suffix',
                                    style: readoutStyle?.copyWith(
                                      fontSize: 24,
                                      letterSpacing: 0,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                            style: readoutStyle,
                          ),
                        ),
                      ),
                    ),
                    if (preview != null) ...[
                      const SizedBox(height: 16),
                      preview(workingValue),
                    ],
                    const SizedBox(height: 20),
                    AmountPad(
                      onDigit: append,
                      onDelete: delete,
                      onDone: () =>
                          Navigator.of(sheetContext).pop(workingValue),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

class AmountDisplayButton extends StatelessWidget {
  const AmountDisplayButton({
    super.key,
    required this.value,
    required this.onTap,
    this.muted = false,
  });

  final String value;
  final VoidCallback onTap;

  /// Placeholder look ("0" before anything is entered).
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: SizedBox(
        height: 54,
        child: Align(
          alignment: Alignment.centerLeft,
          child: FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 42,
                fontWeight: FontWeight.w800,
                height: 0.94,
                letterSpacing: -1.6,
                color: muted
                    ? AppColors.textSecondary.withValues(alpha: 0.4)
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AmountPad extends StatelessWidget {
  const AmountPad({
    required this.onDigit,
    required this.onDelete,
    required this.onDone,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['.', '0', 'delete'],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in rows) ...[
          Row(
            children: [
              for (final key in row) ...[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: _AmountPadKey(
                      label: key == 'delete' ? null : key,
                      icon: key == 'delete' ? Icons.backspace_outlined : null,
                      onPressed: () {
                        if (key == 'delete') {
                          onDelete();
                          return;
                        }
                        onDigit(key);
                      },
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onDone,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(42),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Text(context.l10n.commonDone),
          ),
        ),
      ],
    );
  }
}

class _AmountPadKey extends StatelessWidget {
  const _AmountPadKey({this.label, this.icon, required this.onPressed});

  final String? label;
  final IconData? icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const backgroundColor = AppColors.surface;
    const foregroundColor = AppColors.textPrimary;

    return SizedBox(
      height: 44,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onPressed,
          child: Center(
            child: icon != null
                ? Icon(icon, color: foregroundColor)
                : Text(
                    label ?? '',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: foregroundColor,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
