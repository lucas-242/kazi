import 'package:flutter/material.dart';
import 'package:kazi_core/shared/themes/settings/kazi_colors.dart';

/// The Kazi [ColorScheme]s, written out explicitly rather than seeded.
///
/// `ColorScheme.fromSeed` was deliberately dropped. It derives every role you
/// do not override by running HCT tone mapping on the seed, which means a
/// brand palette the brandbook already specifies in full would be re-invented
/// by an algorithm — and silently repainted whenever the seed or the Flutter
/// version changes. Writing both schemes out is also `const`, so building a
/// theme costs nothing at runtime.
///
/// Note [ColorScheme.surfaceTint] is pinned to `surface` in both schemes.
/// Left unset it falls back to `primary`, which would wash every elevated
/// Material surface in yellow; the brandbook design is flat ("sem
/// gradientes"), so separation comes from the surface ladder plus a 1px
/// outline instead of from tonal elevation.
abstract class KaziColorSchemes {
  /// Light scheme. Surfaces run Névoa → white, ink is Graphite, and the
  /// accent takes its **ink** form (Âmbar) wherever it has to be readable.
  static const light = ColorScheme(
    brightness: Brightness.light,

    primary: KaziColors.yellow,
    onPrimary: KaziColors.graphite,
    primaryContainer: KaziColors.yellow100,
    onPrimaryContainer: KaziColors.graphite,

    // Âmbar: the accent that can be written with on a light surface.
    secondary: KaziColors.amber,
    onSecondary: KaziColors.white,
    secondaryContainer: KaziColors.yellow100,
    onSecondaryContainer: KaziColors.amber700,

    // There is no third brand accent, so tertiary stays neutral.
    tertiary: KaziColors.graphite700,
    onTertiary: KaziColors.mist,
    tertiaryContainer: KaziColors.graphite100,
    onTertiaryContainer: KaziColors.graphite800,

    error: KaziColors.error,
    onError: KaziColors.white,
    errorContainer: KaziColors.errorContainerLight,
    onErrorContainer: KaziColors.onErrorContainerLight,

    surface: KaziColors.mist,
    onSurface: KaziColors.graphite,
    onSurfaceVariant: KaziColors.graphite500,

    // Cards sit on white, one step above the Névoa page.
    surfaceContainerLowest: KaziColors.white,
    surfaceContainerLow: KaziColors.mist50,
    surfaceContainer: KaziColors.mist,
    surfaceContainerHigh: KaziColors.mist200,
    surfaceContainerHighest: KaziColors.graphite100,
    surfaceDim: KaziColors.graphite100,
    surfaceBright: KaziColors.white,
    surfaceTint: KaziColors.mist,

    outline: KaziColors.graphite500,
    outlineVariant: KaziColors.graphite200,

    inverseSurface: KaziColors.graphite800,
    onInverseSurface: KaziColors.mist,
    inversePrimary: KaziColors.yellow,

    shadow: KaziColors.graphite,
    scrim: KaziColors.graphite,
  );

  /// Dark scheme, anchored on the brandbook's dark artefacts: the hero
  /// (graphite ground, Névoa ink), the dark splash (yellow mark, Névoa word)
  /// and the dark app icon (graphite ground, yellow symbol).
  ///
  /// The accent needs no ink form here — on graphite the brand yellow is
  /// 12.42:1 and reads perfectly as text.
  static const dark = ColorScheme(
    brightness: Brightness.dark,

    primary: KaziColors.yellow,
    onPrimary: KaziColors.graphite,
    primaryContainer: KaziColors.yellow900,
    onPrimaryContainer: KaziColors.yellow,

    secondary: KaziColors.yellow,
    onSecondary: KaziColors.graphite,
    secondaryContainer: KaziColors.graphite700,
    onSecondaryContainer: KaziColors.yellow,

    tertiary: KaziColors.graphite200,
    onTertiary: KaziColors.graphite,
    tertiaryContainer: KaziColors.graphite700,
    onTertiaryContainer: KaziColors.graphite100,

    error: KaziColors.errorDark,
    onError: KaziColors.graphite,
    errorContainer: KaziColors.errorContainerDark,
    onErrorContainer: KaziColors.onErrorContainerDark,

    surface: KaziColors.graphite,
    onSurface: KaziColors.mist,
    // Graphite-300, not graphite-500: the latter is only 3.27:1 here and
    // fails for text. The brandbook's own dark hero meta uses graphite-300.
    onSurfaceVariant: KaziColors.graphite300,

    surfaceContainerLowest: KaziColors.graphite900,
    surfaceContainerLow: KaziColors.graphite850,
    surfaceContainer: KaziColors.graphite800,
    surfaceContainerHigh: KaziColors.graphite750,
    surfaceContainerHighest: KaziColors.graphite700,
    surfaceDim: KaziColors.graphite,
    surfaceBright: KaziColors.graphite700,
    surfaceTint: KaziColors.graphite,

    outline: KaziColors.graphite300,
    outlineVariant: KaziColors.graphite700,

    inverseSurface: KaziColors.mist,
    onInverseSurface: KaziColors.graphite800,
    // Âmbar is the accent that reads on the inverse (light) surface.
    inversePrimary: KaziColors.amber,

    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
  );
}
