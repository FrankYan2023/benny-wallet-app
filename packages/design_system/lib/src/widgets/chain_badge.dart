import 'package:flutter/material.dart';

/// The chain an asset or wallet lives on. Benny is Solana-only today; the
/// enum keeps badge call sites ready for more chains.
enum ChainKind { solana }

/// Solana's three slanted bars, filled with the purple→green chain gradient.
class SolanaChainMark extends StatelessWidget {
  const SolanaChainMark({super.key, this.size = 14});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.78,
      child: const CustomPaint(painter: _SolanaBarsPainter()),
    );
  }
}

class _SolanaBarsPainter extends CustomPainter {
  const _SolanaBarsPainter();

  static const gradient = [Color(0xFF9945FF), Color(0xFF19FB9B)];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: gradient,
      ).createShader(Offset.zero & size);
    final barHeight = size.height * 0.24;
    final gap = (size.height - barHeight * 3) / 2;
    final slant = size.width * 0.2;

    void bar(double top, {required bool leanLeft}) {
      final path = Path();
      if (leanLeft) {
        path
          ..moveTo(0, top)
          ..lineTo(size.width - slant, top)
          ..lineTo(size.width, top + barHeight)
          ..lineTo(slant, top + barHeight);
      } else {
        path
          ..moveTo(slant, top)
          ..lineTo(size.width, top)
          ..lineTo(size.width - slant, top + barHeight)
          ..lineTo(0, top + barHeight);
      }
      canvas.drawPath(path..close(), paint);
    }

    bar(0, leanLeft: false);
    bar(barHeight + gap, leanLeft: true);
    bar((barHeight + gap) * 2, leanLeft: false);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Round chain badge: dark disc with the chain mark, ringed in the color of
/// the surface behind it so it reads as a "subscript" on any icon.
class ChainBadge extends StatelessWidget {
  const ChainBadge({
    super.key,
    this.chain = ChainKind.solana,
    this.size = 18,
    this.ringColor,
  });

  final ChainKind chain;
  final double size;
  final Color? ringColor;

  @override
  Widget build(BuildContext context) {
    final ring = ringColor ?? Theme.of(context).colorScheme.surface;
    final ringWidth = (size * 0.11).clamp(1.5, 3.0);
    // Decorative: the chain is stated in text where it matters, so screen
    // readers don't hear "Solana" on every row.
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF14111C),
          shape: BoxShape.circle,
          border: Border.all(color: ring, width: ringWidth),
        ),
        child: SolanaChainMark(size: size * 0.52),
      ),
    );
  }
}

/// Puts a [ChainBadge] on the bottom-right of a token or wallet icon. Every
/// icon in the app uses the same proportions so the subscript looks uniform.
class ChainBadged extends StatelessWidget {
  const ChainBadged({
    super.key,
    required this.size,
    required this.child,
    this.chain = ChainKind.solana,
    this.ringColor,
  });

  /// Size of [child] (a square icon).
  final double size;
  final Widget child;
  final ChainKind chain;
  final Color? ringColor;

  static double badgeSizeFor(double iconSize) =>
      (iconSize * 0.42).clamp(12.0, 30.0);

  @override
  Widget build(BuildContext context) {
    final badge = badgeSizeFor(size);
    final overhang = badge * 0.12;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: child),
          Positioned(
            right: -overhang,
            bottom: -overhang,
            child: ChainBadge(chain: chain, size: badge, ringColor: ringColor),
          ),
        ],
      ),
    );
  }
}

/// Inline "◎ Solana" network label for wallet headers and subtitles.
class ChainLabel extends StatelessWidget {
  const ChainLabel({
    super.key,
    this.chain = ChainKind.solana,
    this.style,
    this.markSize = 12,
  });

  final ChainKind chain;
  final TextStyle? style;
  final double markSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SolanaChainMark(size: markSize),
        SizedBox(width: markSize * 0.4),
        Text('Solana', style: style),
      ],
    );
  }
}
