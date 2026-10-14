import 'package:flutter/material.dart';

/// Stands in for the brand logo while the travel guard is set: a shield with
/// a lock on the brand's brown-to-amber gradient, so the user can tell at a
/// glance that the guard PIN is armed.
class TravelGuardBadge extends StatelessWidget {
  const TravelGuardBadge({super.key, this.size = 44, this.tooltip});

  final double size;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7A4A06), Color(0xFFE39B1F)],
        ),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7A4A06).withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.shield_rounded, color: Colors.white, size: size * 0.62),
          Padding(
            padding: EdgeInsets.only(top: size * 0.06),
            child: Icon(
              Icons.lock_rounded,
              color: const Color(0xFF9A5C08),
              size: size * 0.28,
            ),
          ),
        ],
      ),
    );
    final message = tooltip;
    return message == null ? badge : Tooltip(message: message, child: badge);
  }
}
