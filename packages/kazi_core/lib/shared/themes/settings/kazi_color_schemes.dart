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

    primary: KaziColors.kazi,
    onPrimary: KaziColors.grafite,
    primaryContainer: KaziColors.amarelo100,
    onPrimaryContainer: KaziColors.grafite,

    // Âmbar: the accent that can be written with on a light surface.
    secondary: KaziColors.ambar,
    onSecondary: KaziColors.branco,
    secondaryContainer: KaziColors.amarelo100,
    onSecondaryContainer: KaziColors.ambar700,

    // There is no third brand accent, so tertiary stays neutral.
    tertiary: KaziColors.grafite700,
    onTertiary: KaziColors.nevoa,
    tertiaryContainer: KaziColors.grafite100,
    onTertiaryContainer: KaziColors.grafite800,

    error: KaziColors.error,
    onError: KaziColors.branco,
    errorContainer: KaziColors.errorContainerLight,
    onErrorContainer: KaziColors.onErrorContainerLight,

    surface: KaziColors.nevoa,
    onSurface: KaziColors.grafite,
    onSurfaceVariant: KaziColors.grafite500,

    // Cards sit on white, one step above the Névoa page.
    surfaceContainerLowest: KaziColors.branco,
    surfaceContainerLow: KaziColors.nevoa50,
    surfaceContainer: KaziColors.nevoa,
    surfaceContainerHigh: KaziColors.nevoa200,
    surfaceContainerHighest: KaziColors.grafite100,
    surfaceDim: KaziColors.grafite100,
    surfaceBright: KaziColors.branco,
    surfaceTint: KaziColors.nevoa,

    outline: KaziColors.grafite500,
    outlineVariant: KaziColors.grafite200,

    inverseSurface: KaziColors.grafite800,
    onInverseSurface: KaziColors.nevoa,
    inversePrimary: KaziColors.kazi,

    shadow: KaziColors.grafite,
    scrim: KaziColors.grafite,
  );

  /// Dark scheme, anchored on the brandbook's dark artefacts: the hero
  /// (graphite ground, Névoa ink), the dark splash (yellow mark, Névoa word)
  /// and the dark app icon (graphite ground, yellow symbol).
  ///
  /// The accent needs no ink form here — on graphite the brand yellow is
  /// 12.42:1 and reads perfectly as text.
  static const dark = ColorScheme(
    brightness: Brightness.dark,

    primary: KaziColors.kazi,
    onPrimary: KaziColors.grafite,
    primaryContainer: KaziColors.amarelo900,
    onPrimaryContainer: KaziColors.kazi,

    secondary: KaziColors.kazi,
    onSecondary: KaziColors.grafite,
    secondaryContainer: KaziColors.grafite700,
    onSecondaryContainer: KaziColors.kazi,

    tertiary: KaziColors.grafite200,
    onTertiary: KaziColors.grafite,
    tertiaryContainer: KaziColors.grafite700,
    onTertiaryContainer: KaziColors.grafite100,

    error: KaziColors.errorDark,
    onError: KaziColors.grafite,
    errorContainer: KaziColors.errorContainerDark,
    onErrorContainer: KaziColors.onErrorContainerDark,

    surface: KaziColors.grafite,
    onSurface: KaziColors.nevoa,
    // Graphite-300, not graphite-500: the latter is only 3.27:1 here and
    // fails for text. The brandbook's own dark hero meta uses graphite-300.
    onSurfaceVariant: KaziColors.grafite300,

    surfaceContainerLowest: KaziColors.grafite900,
    surfaceContainerLow: KaziColors.grafite850,
    surfaceContainer: KaziColors.grafite800,
    surfaceContainerHigh: KaziColors.grafite750,
    surfaceContainerHighest: KaziColors.grafite700,
    surfaceDim: KaziColors.grafite,
    surfaceBright: KaziColors.grafite700,
    surfaceTint: KaziColors.grafite,

    outline: KaziColors.grafite300,
    outlineVariant: KaziColors.grafite700,

    inverseSurface: KaziColors.nevoa,
    onInverseSurface: KaziColors.grafite800,
    // Âmbar is the accent that reads on the inverse (light) surface.
    inversePrimary: KaziColors.ambar,

    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
  );
}
