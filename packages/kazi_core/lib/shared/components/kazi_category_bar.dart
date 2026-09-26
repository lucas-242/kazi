import 'package:flutter/material.dart';
import 'package:kazi_core/shared/themes/themes.dart';

/// The category mark as a standalone 3 dp block, for the places with no card
/// around it to carry the colour — the type row of a detail screen, and the
/// skeleton that stands in for a row while it loads. In a card the mark is
/// `KaziCategoryBorder`, which follows the corner instead of squaring off
/// against it.
///
/// Meant to stretch to its neighbour's height: put it in a `Row` with
/// `CrossAxisAlignment.stretch`, or give it a [height]. A null [color] renders
/// the neutral "no category" bar, so callers can pass an optional colour
/// straight through. See `themes/README.md`.
class KaziCategoryBar extends StatelessWidget {
  const KaziCategoryBar({super.key, this.color, this.height});

  static const double width = 3;

  final Color? color;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: color ?? context.colors.surfaceStrong,
    );
  }
}
