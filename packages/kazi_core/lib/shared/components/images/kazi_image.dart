import 'package:flutter/material.dart';

class KaziImage extends StatelessWidget {
  const KaziImage(
    this.image, {
    super.key,
    this.height,
    this.width,
    this.color,
    this.package = 'kazi_core',
  });
  final String image;
  final Color? color;
  final double? height;
  final double? width;

  /// The package name to import the image
  final String? package;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      image,
      height: height,
      width: width,
      package: package,
      color: color,
    );
  }
}
