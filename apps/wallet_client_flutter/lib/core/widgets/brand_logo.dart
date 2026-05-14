import 'package:flutter/material.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    required this.size,
    this.radius,
  });

  final double size;
  final double? radius;

  static const _assetPath = 'assets/brand/benny_logo.png';

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        _assetPath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        gaplessPlayback: true,
      ),
    );
  }
}
