import 'package:flutter/material.dart';
import 'package:kazi_core/shared/themes/themes.dart';

/// Adds padding to the [child].
///
/// When the sceen size hits a xxLg width, it fixes a padding to the screen considering [wideDevicesPaddingTop].
class KaziPaddingWrap extends StatelessWidget {
  const KaziPaddingWrap({
    super.key,
    this.child,
    this.paddingLeft,
    this.paddingRight,
    this.paddingTop,
    this.paddingBottom,
  });

  final Widget? child;
  final double? paddingLeft;
  final double? paddingRight;
  final double? paddingTop;
  final double? paddingBottom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.whenScreenSize(
        xs: EdgeInsets.only(
          left: paddingLeft ?? KaziInsets.lg,
          right: paddingRight ?? KaziInsets.lg,
          top: paddingTop ?? KaziInsets.lg,
          bottom: paddingBottom ?? 0,
        ),
        xxLg: EdgeInsets.only(
          left: context.width * .06,
          right: context.width * .06,
          top: paddingTop ?? 0,
          bottom: paddingBottom ?? 0,
        ),
      ),
      child: child,
    );
  }
}
