import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kazi_core/shared/themes/themes.dart';

class KaziSvg extends StatelessWidget {
  const KaziSvg(
    this.svg, {
    super.key,
    this.height,
    this.width,
    this.color,
    this.package = 'kazi_core',
  });
  final String svg;
  final Color? color;
  final double? height;
  final double? width;

  /// The package name to import the svg
  final String? package;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      svg,
      height: height,
      width: width,
      package: package,
      // Assets drawn in `currentColor` — the brand logos — resolve against the
      // ambient ink, so they invert with the theme instead of staying black on
      // a graphite page. Assets with baked-in fills are unaffected.
      theme: SvgTheme(currentColor: color ?? context.colors.text),
      colorFilter:
          color != null ? ColorFilter.mode(color!, BlendMode.srcATop) : null,
    );
  }
}
