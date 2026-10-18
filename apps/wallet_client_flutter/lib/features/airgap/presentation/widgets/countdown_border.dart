import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Time left shown around the whole screen: a line runs from the bottom
/// right corner, up and over the top, down to the bottom left, and shrinks
/// toward the bottom left as time runs out, going green → yellow → red.
/// The background behind [child] pulses in the same colour, faster near
/// the end. [remaining] is 1 at the start and 0 when time is up.
class CountdownBorder extends StatefulWidget {
  const CountdownBorder({
    super.key,
    required this.remaining,
    required this.child,
    this.background,
    this.color,
  });

  final double remaining;
  final Widget child;

  /// A fixed colour instead of the time-based one, e.g. the signer's
  /// green / yellow / red for how far a transaction can be trusted. The
  /// pulse is then steady and clearly visible.
  final Color? color;

  /// Base page colour under the pulse; the theme's scaffold colour if null.
  final Color? background;

  static Color colorFor(double remaining) {
    const green = Color(0xFF2EB872);
    const yellow = Color(0xFFF5B82E);
    const red = Color(0xFFE5484D);
    final r = remaining.clamp(0.0, 1.0);
    return r > 0.5
        ? Color.lerp(yellow, green, (r - 0.5) * 2)!
        : Color.lerp(red, yellow, r * 2)!;
  }

  @override
  State<CountdownBorder> createState() => _CountdownBorderState();
}

class _CountdownBorderState extends State<CountdownBorder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );
  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.of(context).disableAnimations;
    if (_reduceMotion) {
      _pulse.stop();
    } else if (!_pulse.isAnimating) {
      _pulse.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant CountdownBorder oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Beat faster as the deadline comes closer.
    final period = Duration(
      milliseconds: widget.color != null
          ? 1400
          : (600 + 1000 * widget.remaining.clamp(0.0, 1.0)).round(),
    );
    if (!_reduceMotion &&
        (period - _pulse.duration!).inMilliseconds.abs() > 150) {
      _pulse
        ..duration = period
        ..repeat();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? CountdownBorder.colorFor(widget.remaining);
    final base = widget.background ?? Theme.of(context).scaffoldBackgroundColor;
    final urgency = widget.color != null
        ? 0.6
        : 1 - widget.remaining.clamp(0.0, 1.0);
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final wave = _reduceMotion
            ? 0.5
            : (math.sin(_pulse.value * 2 * math.pi) + 1) / 2;
        // Faint while there is time, stronger as it runs out.
        final alpha = (0.05 + 0.13 * urgency) * (0.4 + 0.6 * wave);
        return Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(
              color: Color.alphaBlend(color.withValues(alpha: alpha), base),
            ),
            child!,
            IgnorePointer(
              child: CustomPaint(
                painter: _BorderPainter(
                  remaining: widget.remaining.clamp(0.0, 1.0),
                  color: color,
                  glow: 0.35 + 0.4 * wave,
                  radius: MediaQuery.of(context).padding.top > 30 ? 46 : 22,
                ),
              ),
            ),
          ],
        );
      },
      child: widget.child,
    );
  }
}

class _BorderPainter extends CustomPainter {
  _BorderPainter({
    required this.remaining,
    required this.color,
    required this.glow,
    required this.radius,
  });

  final double remaining;
  final Color color;
  final double glow;
  final double radius;

  static const _stroke = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (remaining <= 0) {
      return;
    }
    const inset = _stroke / 2 + 1;
    final rect = Rect.fromLTRB(
      inset,
      inset,
      size.width - inset,
      size.height - inset,
    );
    final r = radius - inset;
    // Bottom right → up the right side → across the top → down the left
    // side → bottom left.
    final path = Path()
      ..moveTo(rect.right - r, rect.bottom)
      ..arcToPoint(
        Offset(rect.right, rect.bottom - r),
        radius: Radius.circular(r),
        clockwise: false,
      )
      ..lineTo(rect.right, rect.top + r)
      ..arcToPoint(
        Offset(rect.right - r, rect.top),
        radius: Radius.circular(r),
        clockwise: false,
      )
      ..lineTo(rect.left + r, rect.top)
      ..arcToPoint(
        Offset(rect.left, rect.top + r),
        radius: Radius.circular(r),
        clockwise: false,
      )
      ..lineTo(rect.left, rect.bottom - r)
      ..arcToPoint(
        Offset(rect.left + r, rect.bottom),
        radius: Radius.circular(r),
        clockwise: false,
      );
    final metric = path.computeMetrics().first;
    final visible = metric.extractPath(
      metric.length * (1 - remaining),
      metric.length,
    );
    canvas.drawPath(
      visible,
      Paint()
        ..color = color.withValues(alpha: glow * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke * 2.4
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawPath(
      visible,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _BorderPainter old) =>
      old.remaining != remaining || old.color != color || old.glow != glow;
}
