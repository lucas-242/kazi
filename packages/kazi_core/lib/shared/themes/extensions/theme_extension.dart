import 'package:flutter/material.dart';
import 'package:kazi_core/shared/themes/extensions/kazi_color_roles.dart';
import 'package:kazi_core/shared/themes/settings/kazi_breakpoints.dart';

/// Theme and media-query shortcuts on [BuildContext].
///
/// Named `KaziThemeExtension` rather than `ThemeExtension` because the barrel
/// re-exports this alongside `package:flutter/material.dart`, where
/// [ThemeExtension] is Material's own class. Extension members are resolved
/// implicitly, so the name never appears at a call site.
extension KaziThemeExtension on BuildContext {
  MediaQueryData get _mediaQuery => MediaQuery.of(this);
  ThemeData get _theme => Theme.of(this);
  ColorScheme get colorsScheme => _theme.colorScheme;

  /// The Kazi brand roles that [ColorScheme] has no slot for.
  ///
  /// Falls back to the light roles when the ambient theme was not built by
  /// `KaziThemeSettings` — a bare [MaterialApp] in a widget test, for
  /// instance — so reading this can never throw.
  KaziColorRoles get kaziColors =>
      _theme.extension<KaziColorRoles>() ?? KaziColorRoles.light;

  double get width => _mediaQuery.size.width;
  double get height => _mediaQuery.size.height;

  double get topPadding => _mediaQuery.viewPadding.top;
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
