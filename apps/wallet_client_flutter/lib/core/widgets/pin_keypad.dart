import 'package:flutter/material.dart';

class PinDots extends StatelessWidget {
  const PinDots({
    super.key,
    required this.filledCount,
    this.length = 6,
  });

  final int filledCount;
  final int length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        length,
        (index) => Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index < filledCount
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }
}

class PinKeypad extends StatelessWidget {
  const PinKeypad({
    super.key,
    required this.onDigit,
    required this.onDelete,
    this.onConfirm,
    this.showConfirmKey = false,
    this.confirmLabel = 'OK',
    this.width = 300,
  });

  final ValueChanged<String>? onDigit;
  final VoidCallback? onDelete;
  final VoidCallback? onConfirm;
  final bool showConfirmKey;
  final String confirmLabel;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        children: [
          for (final row in const [
            ['1', '2', '3'],
            ['4', '5', '6'],
            ['7', '8', '9'],
          ]) ...[
            Row(
              children: [
                for (final key in row) ...[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: _PinKeyButton(
                        label: key,
                        onPressed: onDigit == null ? null : () => onDigit!(key),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: showConfirmKey
                      ? _PinKeyButton(
                          icon: Icons.backspace_outlined,
                          onPressed: onDelete,
                        )
                      : const SizedBox(height: 68),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: _PinKeyButton(
                    label: '0',
                    onPressed: onDigit == null ? null : () => onDigit!('0'),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: showConfirmKey
                      ? _PinKeyButton(
                          label: confirmLabel,
                          isPrimary: true,
                          onPressed: onConfirm,
                        )
                      : _PinKeyButton(
                          icon: Icons.backspace_outlined,
                          onPressed: onDelete,
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PinKeyButton extends StatelessWidget {
  const _PinKeyButton({
    this.label,
    this.icon,
    this.onPressed,
    this.isPrimary = false,
  });

  final String? label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onPressed != null;
    final backgroundColor = isPrimary
        ? theme.colorScheme.primary
        : theme.colorScheme.surface.withValues(alpha: 0.98);
    final foregroundColor = isPrimary
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;

    return SizedBox(
      height: 72,
      child: Material(
        color: enabled
            ? backgroundColor
            : backgroundColor.withValues(alpha: isPrimary ? 0.45 : 0.55),
        borderRadius: BorderRadius.circular(26),
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: onPressed,
          child: Center(
            child: icon != null
                ? Icon(
                    icon,
                    color: enabled
                        ? foregroundColor
                        : foregroundColor.withValues(alpha: 0.45),
                  )
                : Text(
                    label ?? '',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: enabled
                          ? foregroundColor
                          : foregroundColor.withValues(alpha: 0.45),
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
