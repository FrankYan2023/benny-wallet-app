import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A button that fires only after being held for [holdDuration], so a
/// signature cannot be given by a stray tap.
class HoldToConfirmButton extends StatefulWidget {
  const HoldToConfirmButton({
    super.key,
    required this.label,
    required this.onConfirmed,
    this.holdDuration = const Duration(seconds: 1),
    this.danger = false,
  });

  final String label;
  final VoidCallback? onConfirmed;
  final Duration holdDuration;
  final bool danger;

  @override
  State<HoldToConfirmButton> createState() => _HoldToConfirmButtonState();
}

class _HoldToConfirmButtonState extends State<HoldToConfirmButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.holdDuration,
  )..addStatusListener(_onStatus);

  @override
  void didUpdateWidget(covariant HoldToConfirmButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = widget.holdDuration;
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      HapticFeedback.heavyImpact();
      _controller.reset();
      widget.onConfirmed?.call();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = widget.onConfirmed != null;
    final color = widget.danger
        ? theme.colorScheme.error
        : theme.colorScheme.primary;
    return GestureDetector(
      onTapDown: enabled ? (_) => _controller.forward() : null,
      onTapUp: enabled ? (_) => _controller.reverse() : null,
      onTapCancel: enabled ? () => _controller.reverse() : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Container(
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: enabled
                  ? color.withValues(alpha: 0.18)
                  : theme.disabledColor.withValues(alpha: 0.12),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _controller.value,
                  child: ColoredBox(color: color),
                ),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.fingerprint_rounded,
                        color: enabled
                            ? theme.colorScheme.onSurface
                            : theme.disabledColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.label,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: enabled
                              ? theme.colorScheme.onSurface
                              : theme.disabledColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
