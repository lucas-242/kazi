import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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
      colorFilter:
          color != null ? ColorFilter.mode(color!, BlendMode.srcATop) : null,
    );
  }
}
