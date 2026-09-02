import 'package:flutter/material.dart';
import 'package:kazi_core/shared/themes/themes.dart';

/// The colour bar on the leading edge of a list row, saying which category the
/// row belongs to.
///
/// Meant to stretch to the row's height: put it in a `Row` with
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
