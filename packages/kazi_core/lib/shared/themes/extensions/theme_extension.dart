import 'package:flutter/material.dart';
import 'package:kazi_core/shared/themes/settings/kazi_breakpoints.dart';

extension ThemeExtension on BuildContext {
  MediaQueryData get _mediaQuery => MediaQuery.of(this);
  ThemeData get _theme => Theme.of(this);
  ColorScheme get colorsScheme => _theme.colorScheme;

  double get width => _mediaQuery.size.width;
  double get height => _mediaQuery.size.height;

  double get bottomPadding => _mediaQuery.viewPadding.bottom;

  /// Returns T according to the screen size.
  ///
  /// If the screen size is not provided,
  /// it will use the next lowest screen size provided.
  T whenScreenSize<T>({
    T? xxxLg,
    T? xxLg,
    T? xLg,
    T? lg,
    T? md,
    T? sm,
    required T xs,
  }) {
    switch (width) {
      case >= KaziBreakpoints.xxxLg:
        return xxxLg ?? xxLg ?? xLg ?? lg ?? md ?? sm ?? xs;
      case >= KaziBreakpoints.xxLg:
        return xxLg ?? xLg ?? lg ?? md ?? sm ?? xs;
      case >= KaziBreakpoints.xLg:
        return xLg ?? lg ?? md ?? sm ?? xs;
      case >= KaziBreakpoints.lg:
        return lg ?? md ?? sm ?? xs;
      case >= KaziBreakpoints.md:
        return md ?? sm ?? xs;
      case >= KaziBreakpoints.sm:
        return sm ?? xs;
      default:
        return xs;
    }
  }
}
