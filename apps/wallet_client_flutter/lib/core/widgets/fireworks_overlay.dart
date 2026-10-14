import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Plays a short full-screen fireworks burst above the current route and
/// removes itself when done. Touches pass through to the page below.
void showFireworks(
  BuildContext context, {
  Duration duration = const Duration(milliseconds: 3200),
}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) {
    return;
  }
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => IgnorePointer(
      child: _Fireworks(duration: duration, onDone: entry.remove),
    ),
  );
  overlay.insert(entry);
}

class _Fireworks extends StatefulWidget {
  const _Fireworks({required this.duration, required this.onDone});

  final Duration duration;
  final VoidCallback onDone;

  @override
  State<_Fireworks> createState() => _FireworksState();
}

class _FireworksState extends State<_Fireworks>
    with SingleTickerProviderStateMixin {
  static const _colors = [
    Color(0xFFFFC94A),
    Color(0xFFFF6B6B),
    Color(0xFF4ADE80),
    Color(0xFF60A5FA),
    Color(0xFFC084FC),
    Color(0xFFFF9F43),
  ];

  late final AnimationController _controller;
  late final List<_Burst> _bursts;

  @override
  void initState() {
    super.initState();
    final random = math.Random();
    _bursts = List.generate(9, (index) {
      final color = _colors[random.nextInt(_colors.length)];
      return _Burst(
        // Normalized position; bursts sit in the upper two thirds.
        center: Offset(
          0.15 + random.nextDouble() * 0.7,
          0.12 + random.nextDouble() * 0.5,
        ),
        start: index * 0.07 + random.nextDouble() * 0.05,
        color: color,
        particles: List.generate(48, (i) {
          final angle = i / 48 * math.pi * 2 + random.nextDouble() * 0.2;
          return _Particle(
            angle: angle,
            speed: 0.6 + random.nextDouble() * 0.5,
          );
        }),
      );
    });
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onDone();
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => CustomPaint(
        size: Size.infinite,
        painter: _FireworksPainter(_bursts, _controller.value),
      ),
    );
  }
}

class _Burst {
  const _Burst({
    required this.center,
    required this.start,
    required this.color,
    required this.particles,
  });

  final Offset center;
  final double start;
  final Color color;
  final List<_Particle> particles;
}

class _Particle {
  const _Particle({required this.angle, required this.speed});

  final double angle;
  final double speed;
}

class _FireworksPainter extends CustomPainter {
  _FireworksPainter(this.bursts, this.t);

  static const _launch = 0.12;
  static const _life = 0.38;

  final List<_Burst> bursts;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.shortestSide * 0.32;
    final paint = Paint()..style = PaintingStyle.fill;
    for (final burst in bursts) {
      final local = t - burst.start;
      if (local < 0) {
        continue;
      }
      final target = Offset(
        burst.center.dx * size.width,
        burst.center.dy * size.height,
      );
      if (local < _launch) {
        // Rocket rising from the bottom edge.
        final p = Curves.easeOut.transform(local / _launch);
        final origin = Offset(target.dx, size.height);
        paint.color = burst.color;
        canvas.drawCircle(Offset.lerp(origin, target, p)!, 3, paint);
        continue;
      }
      final p = (local - _launch) / _life;
      if (p > 1) {
        continue;
      }
      final spread = Curves.easeOutCubic.transform(p);
      final fade = 1 - Curves.easeIn.transform(p);
      paint.color = burst.color.withValues(alpha: fade);
      for (final particle in burst.particles) {
        final distance = radius * particle.speed * spread;
        // A little gravity pulls the sparks down as they fade.
        final drop = radius * 0.35 * p * p;
        final position =
            target +
            Offset(
              math.cos(particle.angle) * distance,
              math.sin(particle.angle) * distance + drop,
            );
        canvas.drawCircle(position, 3.6 * fade + 0.8, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_FireworksPainter oldDelegate) => oldDelegate.t != t;
}
