import 'package:flutter/material.dart';
import 'package:kazi_core/shared/themes/themes.dart';

/// The small round colour mark used to identify a category — in dropdown rows,
/// list tiles and pickers.
///
/// Always ringed with a 1px `outlineVariant`: two of the six brandbook category
/// colours fall below the 3:1 non-text threshold on light surfaces, and the ring
/// is what keeps them visible. A null [color] renders the neutral "no colour"
/// dot, so callers can pass an optional colour straight through.
class KaziColorDot extends StatelessWidget {
  const KaziColorDot({super.key, this.color, this.size = 14});

  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? context.colorsScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
        border: Border.all(color: context.colorsScheme.outlineVariant),
      ),
    );
  }
}
