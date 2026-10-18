import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../l10n/l10n.dart';

/// Looping cartoon of two phones: one shows a QR code, the other scans it.
/// Each phone is named and tagged "shows code" or "scans", so the user can
/// tell at a glance which phone scans which.
class ScanHintAnimation extends StatefulWidget {
  const ScanHintAnimation({
    super.key,
    required this.leftLabel,
    required this.rightLabel,
    required this.qrOnLeft,
    this.height = 150,
  });

  final String leftLabel;
  final String rightLabel;

  /// True: the left phone shows the code and the right one scans it.
  final bool qrOnLeft;
  final double height;

  @override
  State<ScanHintAnimation> createState() => _ScanHintAnimationState();
}

class _ScanHintAnimationState extends State<ScanHintAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _controller
        ..stop()
        ..value = 0.5;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    Widget side(String name, {required bool scans}) => _PhoneLabel(
      name: name,
      role: scans ? l10n.scanHintRoleScans : l10n.scanHintRoleShows,
      icon: scans ? Icons.photo_camera_rounded : Icons.qr_code_2_rounded,
      scans: scans,
    );
    return Semantics(
      label: widget.qrOnLeft
          ? '${widget.rightLabel} → ${widget.leftLabel}'
          : '${widget.leftLabel} → ${widget.rightLabel}',
      child: Column(
        children: [
          SizedBox(
            height: widget.height,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => CustomPaint(
                size: Size.infinite,
                painter: _TwoPhonesPainter(
                  t: _controller.value,
                  qrOnLeft: widget.qrOnLeft,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: side(widget.leftLabel, scans: !widget.qrOnLeft)),
              const SizedBox(width: 40),
              Expanded(child: side(widget.rightLabel, scans: widget.qrOnLeft)),
            ],
          ),
        ],
      ),
    );
  }
}

/// A phone's name with a small tag saying what it does.
class _PhoneLabel extends StatelessWidget {
  const _PhoneLabel({
    required this.name,
    required this.role,
    required this.icon,
    required this.scans,
  });

  final String name;
  final String role;
  final IconData icon;
  final bool scans;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = scans ? Colors.white : AppColors.textPrimary;
    return Column(
      children: [
        Text(
          name,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelMedium?.copyWith(
            color: AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: scans ? AppColors.primaryBright : AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: foreground),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  role,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TwoPhonesPainter extends CustomPainter {
  _TwoPhonesPainter({required this.t, required this.qrOnLeft});

  final double t;
  final bool qrOnLeft;

  static const _ink = AppColors.textPrimary;
  // Fixed 7x7 pattern that reads as "a QR code" at this size.
  static const _pattern = [
    '1110111',
    '1010101',
    '1110111',
    '0001000',
    '1110010',
    '1010101',
    '1110110',
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final phoneH = size.height * 0.92;
    final phoneW = phoneH * 0.56;
    final top = (size.height - phoneH) / 2;
    final leftCx = size.width * 0.25;
    final rightCx = size.width * 0.75;
    final qrCx = qrOnLeft ? leftCx : rightCx;
    final camCx = qrOnLeft ? rightCx : leftCx;
    // The scanning phone leans toward the code and bobs a little.
    final bob = math.sin(t * 2 * math.pi) * 3;
    final lean = (qrOnLeft ? -1 : 1) * 0.12;

    final qrRect = Rect.fromCenter(
      center: Offset(qrCx, top + phoneH / 2),
      width: phoneW,
      height: phoneH,
    );
    final camRect = Rect.fromCenter(
      center: Offset(camCx, top + phoneH / 2 + bob),
      width: phoneW,
      height: phoneH,
    );

    _beam(canvas, qrRect, camRect);
    _phone(canvas, qrRect, (screen) => _qr(canvas, screen));
    canvas.save();
    canvas.translate(camRect.center.dx, camRect.center.dy);
    canvas.rotate(lean);
    canvas.translate(-camRect.center.dx, -camRect.center.dy);
    _phone(canvas, camRect, (screen) => _viewfinder(canvas, screen));
    canvas.restore();
    _packet(canvas, qrRect, camRect);
  }

  void _phone(Canvas canvas, Rect rect, void Function(Rect) screen) {
    final body = RRect.fromRectAndRadius(
      rect,
      Radius.circular(rect.width * .2),
    );
    canvas.drawRRect(
      body.shift(const Offset(0, 4)),
      Paint()..color = _ink.withValues(alpha: 0.08),
    );
    canvas.drawRRect(body, Paint()..color = Colors.white);
    canvas.drawRRect(
      body,
      Paint()
        ..color = _ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6,
    );
    final inner = rect.deflate(rect.width * 0.11);
    screen(inner);
  }

  void _qr(Canvas canvas, Rect screen) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(screen, const Radius.circular(8)),
      Paint()..color = AppColors.backgroundAccent,
    );
    final side = screen.width * 0.8;
    final cell = side / 7;
    final origin = Offset(
      screen.center.dx - side / 2,
      screen.center.dy - side / 2,
    );
    final ink = Paint()..color = _ink;
    for (var y = 0; y < 7; y++) {
      for (var x = 0; x < 7; x++) {
        if (_pattern[y][x] == '1') {
          canvas.drawRect(
            Rect.fromLTWH(
              origin.dx + x * cell,
              origin.dy + y * cell,
              cell * 0.92,
              cell * 0.92,
            ),
            ink,
          );
        }
      }
    }
    // Scan line sweeping over the code.
    final sweep = (math.sin(t * 2 * math.pi) + 1) / 2;
    final y = origin.dy + side * sweep;
    canvas.drawLine(
      Offset(origin.dx - 4, y),
      Offset(origin.dx + side + 4, y),
      Paint()
        ..color = AppColors.primaryBright
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );
  }

  void _viewfinder(Canvas canvas, Rect screen) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(screen, const Radius.circular(8)),
      Paint()..color = const Color(0xFF3B3631),
    );
    final box = Rect.fromCenter(
      center: screen.center,
      width: screen.width * 0.7,
      height: screen.width * 0.7,
    );
    final corner = box.width * 0.28;
    final paint = Paint()
      ..color = AppColors.primaryBright
      ..strokeWidth = 2.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (final (dx, dy) in [(0, 0), (1, 0), (0, 1), (1, 1)]) {
      final x = dx == 0 ? box.left : box.right;
      final y = dy == 0 ? box.top : box.bottom;
      final sx = dx == 0 ? 1.0 : -1.0;
      final sy = dy == 0 ? 1.0 : -1.0;
      canvas.drawLine(Offset(x, y), Offset(x + corner * sx, y), paint);
      canvas.drawLine(Offset(x, y), Offset(x, y + corner * sy), paint);
    }
  }

  void _beam(Canvas canvas, Rect qr, Rect cam) {
    final towardRight = cam.center.dx > qr.center.dx;
    final from = Offset(towardRight ? cam.left : cam.right, cam.center.dy);
    final edgeX = towardRight ? qr.right : qr.left;
    final pulse = 0.12 + 0.1 * (math.sin(t * 2 * math.pi) + 1) / 2;
    final path = Path()
      ..moveTo(from.dx, from.dy - 6)
      ..lineTo(edgeX, qr.top + qr.height * 0.18)
      ..lineTo(edgeX, qr.bottom - qr.height * 0.18)
      ..lineTo(from.dx, from.dy + 6)
      ..close();
    canvas.drawPath(
      path,
      Paint()..color = AppColors.primaryBright.withValues(alpha: pulse),
    );
  }

  void _packet(Canvas canvas, Rect qr, Rect cam) {
    // A small square travels from the code to the camera.
    final p = Curves.easeInOut.transform(t);
    final start = qr.center;
    final end = cam.center;
    final pos = Offset.lerp(start, end, p)!;
    final lift = math.sin(p * math.pi) * -18;
    final opacity = p < 0.1 || p > 0.9 ? 0.0 : 1.0;
    final rect = Rect.fromCenter(
      center: pos + Offset(0, lift),
      width: 12,
      height: 12,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      Paint()..color = AppColors.primary.withValues(alpha: opacity),
    );
  }

  @override
  bool shouldRepaint(covariant _TwoPhonesPainter old) =>
      old.t != t || old.qrOnLeft != qrOnLeft;
}
