import 'package:flutter/material.dart';

/// Colors for rising and falling prices. Many markets show gains in green;
/// mainland China, Taiwan, Japan and Korea show them in red, so users pick.
@immutable
class PriceTrendColors extends ThemeExtension<PriceTrendColors> {
  const PriceTrendColors({required this.up, required this.down});

  static const green = Color(0xFF30A46C);
  static const red = Color(0xFFE2562A);

  static const greenUp = PriceTrendColors(up: green, down: red);
  static const redUp = PriceTrendColors(up: red, down: green);

  final Color up;
  final Color down;

  static PriceTrendColors of(BuildContext context) {
    return Theme.of(context).extension<PriceTrendColors>() ?? greenUp;
  }

  /// The color for a change, or [neutral] when there is none.
  Color forChange(num? change, {required Color neutral}) {
    if (change == null || change == 0) {
      return neutral;
    }
    return change > 0 ? up : down;
  }

  @override
  PriceTrendColors copyWith({Color? up, Color? down}) {
    return PriceTrendColors(up: up ?? this.up, down: down ?? this.down);
  }

  @override
  PriceTrendColors lerp(PriceTrendColors? other, double t) {
    if (other == null) {
      return this;
    }
    return PriceTrendColors(
      up: Color.lerp(up, other.up, t)!,
      down: Color.lerp(down, other.down, t)!,
    );
  }
}
