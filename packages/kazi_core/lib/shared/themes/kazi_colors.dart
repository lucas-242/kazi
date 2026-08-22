import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi_core/shared/themes/settings/kazi_palette.dart';

/// Every colour the Kazi apps are allowed to paint with, resolved for the
/// ambient brightness. Read it as `context.colors`.
///
/// This is the single source: a screen never asks which mode it is in, never
/// touches `ColorScheme`, and never touches `KaziPalette`. The Material
/// [ColorScheme] is plumbing, held in [scheme] and fed to `ThemeData`.
///
/// The "I want to paint X, which token?" tables are in README.md.
@immutable
class KaziColors extends ThemeExtension<KaziColors> {
  const KaziColors({
    required this.scheme,
    required this.brand,
    required this.success,
    required this.warning,
    required this.info,
    required this.danger,
    required this.money,
    required this.hero,
    required this.focusRing,
    required this.categories,
  });

  /// The light palette.
  static const light = KaziColors(
    scheme: _lightScheme,
    brand: KaziBrandColors.light,
    success: KaziStatusColors.successLight,
    warning: KaziStatusColors.warningLight,
    info: KaziStatusColors.infoLight,
    danger: KaziStatusColors.dangerLight,
    money: KaziMoneyColors.light,
    hero: KaziHeroColors.light,
    focusRing: KaziPalette.graphite,
    categories: _categories,
  );

  /// The dark palette.
  static const dark = KaziColors(
    scheme: _darkScheme,
    brand: KaziBrandColors.dark,
    success: KaziStatusColors.successDark,
    warning: KaziStatusColors.warningDark,
    info: KaziStatusColors.infoDark,
    danger: KaziStatusColors.dangerDark,
    money: KaziMoneyColors.dark,
    hero: KaziHeroColors.dark,
    // A yellow ring cannot be seen on Névoa, a graphite one cannot be seen on
    // Graphite — so this is the one neutral that has to flip.
    focusRing: KaziPalette.yellow,
    categories: _categories,
  );

  static const _categories = <Color>[
    KaziPalette.category1,
    KaziPalette.category2,
    KaziPalette.category3,
    KaziPalette.category4,
    KaziPalette.category5,
    KaziPalette.category6,
  ];

  /// Material plumbing: the scheme handed to `ThemeData` so Flutter's built-in
  /// widgets theme themselves. Screens read the named getters below instead —
  /// `primary` in particular is the brand yellow, which is invisible as ink on
  /// a light surface. Use `brand.text` for that.
  final ColorScheme scheme;

  /// The brand yellow, split by the job it is doing.
  final KaziBrandColors brand;

  /// Paid, completed.
  final KaziStatusColors success;

  /// Pending. Âmbar-orange, never the brand yellow — if Kazi yellow signalled
  /// problems, the brand would start to mean "caution" instead of "energy".
  final KaziStatusColors warning;

  /// Neutral information.
  final KaziStatusColors info;

  /// Failed, cancelled, destructive. Material's `error`, given the same shape
  /// as the other three so there is nothing special to remember about it.
  final KaziStatusColors danger;

  /// "Graphite carries the money" — the dark panel a headline value sits on.
  final KaziMoneyColors money;

  /// The brand canvas: splash screens and the login page, where the brand
  /// itself is the background rather than an accent.
  final KaziHeroColors hero;

  /// Focus indicators.
  final Color focusRing;

  /// The six service-category marks, in brandbook order.
  ///
  /// Small marks only: dots, tags, chart slices. These are identity rather
  /// than state, so they are the same hexes in light and dark. On light
  /// surfaces indices 3 and 4 fall below the 3:1 non-text threshold — give
  /// dots a 1px [border] ring there.
  ///
  /// Prefer [category] over indexing this directly.
  final List<Color> categories;

  // ── Surfaces ─────────────────────────────────────────────────────────────

  /// The page itself: scaffolds, sheets, the ground everything sits on.
  Color get background => scheme.surface;

  /// The dim laid over the page when something in front of it has to be read
  /// first — a coach mark, a modal barrier.
  ///
  /// Graphite in both brightnesses, and pre-diluted: a scrim that lightens the
  /// page does not read as "behind", and letting each call site pick its own
  /// opacity is how a product ends up with four different dims. Derived rather
  /// than constructed, so it needs no slot in `copyWith`/`lerp`.
  Color get scrim => KaziPalette.graphite.withValues(alpha: 0.62);

  /// One step up from [background]: cards, list items, raised panels.
  Color get card => scheme.surfaceContainerLowest;

  /// A quiet fill that still separates from [background]: input fields,
  /// chips, inactive rows, skeletons.
  Color get surfaceMuted => scheme.surfaceContainerHigh;

  /// [surfaceMuted] with more contrast, for when a block has to read as a
  /// distinct region rather than a fill.
  Color get surfaceStrong => scheme.surfaceContainerHighest;

  /// A surface of the opposite brightness — snackbars, tooltips, the "dark
  /// strip on a light page" pattern.
  Color get inverse => scheme.inverseSurface;

  /// Ink on [inverse].
  Color get onInverse => scheme.onInverseSurface;

  // ── Ink ──────────────────────────────────────────────────────────────────

  /// Default text and icon colour.
  Color get text => scheme.onSurface;

  /// Supporting text: captions, hints, metadata, disabled labels.
  Color get textMuted => scheme.onSurfaceVariant;

  // ── Borders ──────────────────────────────────────────────────────────────

  /// Hairlines, dividers, card outlines.
  Color get border => scheme.outlineVariant;

  /// A border that has to be noticed: focused fields, selected outlines.
  Color get borderStrong => scheme.outline;

  // ── Helpers ──────────────────────────────────────────────────────────────

  Brightness get brightness => scheme.brightness;

  /// The category colour at [index], wrapping around for indices beyond the
  /// six defined marks.
  Color category(int index) => categories[index % categories.length];

  /// The status-bar and navigation-bar style that stays legible over
  /// [background] — icons go dark on a light ground and light on a dark one.
  ///
  /// This is why no screen needs to ask what brightness it is in: pass the
  /// colour actually behind the bar (often [background], or `hero.surface` on
  /// a splash) and the icon brightness follows from it.
  SystemUiOverlayStyle overlayOn(Color surface) {
    final isLight =
        ThemeData.estimateBrightnessForColor(surface) == Brightness.light;

    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      // Android reads `statusBarIconBrightness`, iOS reads
      // `statusBarBrightness`, and the two are inverses of each other.
      statusBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
      statusBarBrightness: isLight ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: surface,
      systemNavigationBarIconBrightness:
          isLight ? Brightness.dark : Brightness.light,
    );
  }

  @override
  KaziColors copyWith({
    ColorScheme? scheme,
    KaziBrandColors? brand,
    KaziStatusColors? success,
    KaziStatusColors? warning,
    KaziStatusColors? info,
    KaziStatusColors? danger,
    KaziMoneyColors? money,
    KaziHeroColors? hero,
    Color? focusRing,
    List<Color>? categories,
  }) {
    return KaziColors(
      scheme: scheme ?? this.scheme,
      brand: brand ?? this.brand,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      danger: danger ?? this.danger,
      money: money ?? this.money,
      hero: hero ?? this.hero,
      focusRing: focusRing ?? this.focusRing,
      categories: categories ?? this.categories,
    );
  }

  @override
  KaziColors lerp(covariant KaziColors? other, double t) {
    if (other == null) {
      return this;
    }

    return KaziColors(
      scheme: ColorScheme.lerp(scheme, other.scheme, t),
      brand: brand.lerp(other.brand, t),
      success: success.lerp(other.success, t),
      warning: warning.lerp(other.warning, t),
      info: info.lerp(other.info, t),
      danger: danger.lerp(other.danger, t),
      money: money.lerp(other.money, t),
      hero: hero.lerp(other.hero, t),
      focusRing: Color.lerp(focusRing, other.focusRing, t)!,
      // Only interpolate pairwise when both sides describe the same number of
      // categories; otherwise snap, since there is no sensible pairing.
      categories: other.categories.length == categories.length
          ? <Color>[
              for (var i = 0; i < categories.length; i++)
                Color.lerp(categories[i], other.categories[i], t)!,
            ]
          : (t < 0.5 ? categories : other.categories),
    );
  }
}

/// The brand yellow, resolved by the job it is doing rather than by its hex.
///
/// [fill] and [text] are separate tokens because "yellow is a surface, not
/// ink" only holds on light backgrounds: on Névoa the yellow is 1.4:1.
@immutable
class KaziBrandColors {
  const KaziBrandColors({
    required this.fill,
    required this.onFill,
    required this.pressed,
    required this.text,
    required this.textStrong,
    required this.surface,
    required this.onSurface,
  });

  static const light = KaziBrandColors(
    fill: KaziPalette.yellow,
    onFill: KaziPalette.graphite,
    pressed: KaziPalette.yellow600,
    text: KaziPalette.amber,
    textStrong: KaziPalette.amber700,
    surface: KaziPalette.yellow100,
    onSurface: KaziPalette.graphite,
  );

  static const dark = KaziBrandColors(
    fill: KaziPalette.yellow,
    onFill: KaziPalette.graphite,
    pressed: KaziPalette.yellow600,
    // On graphite the brand yellow is 12.42:1 and reads perfectly as text, so
    // dark needs no ink form.
    text: KaziPalette.yellow,
    textStrong: KaziPalette.yellow,
    surface: KaziPalette.yellow900,
    onSurface: KaziPalette.yellow,
  );

  /// Brand yellow as a **fill**: the FAB, the primary call to action.
  /// Remember "one yellow per screen".
  final Color fill;

  /// Ink on [fill] — graphite in both modes, 12.42:1. Never white: white on
  /// the brand yellow is 1.7:1.
  final Color onFill;

  /// Pressed state of [fill].
  final Color pressed;

  /// Brand yellow in its **ink** form: whenever you need to *write* in yellow,
  /// tint an icon, or colour a selected label.
  ///
  /// Âmbar on light (3.64:1 — AA-Large, so 18.66px and up), Kazi yellow on
  /// dark. Use [textStrong] for smaller text.
  final Color text;

  /// [text] darkened enough for body-size text on light surfaces (5.05:1).
  /// Identical to [text] on dark.
  final Color textStrong;

  /// A soft yellow wash for highlighted rows and badges.
  final Color surface;

  /// Ink on [surface].
  final Color onSurface;

  KaziBrandColors lerp(KaziBrandColors other, double t) => KaziBrandColors(
        fill: Color.lerp(fill, other.fill, t)!,
        onFill: Color.lerp(onFill, other.onFill, t)!,
        pressed: Color.lerp(pressed, other.pressed, t)!,
        text: Color.lerp(text, other.text, t)!,
        textStrong: Color.lerp(textStrong, other.textStrong, t)!,
        surface: Color.lerp(surface, other.surface, t)!,
        onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      );
}

/// One status colour in its four usable forms — success, warning, info and
/// danger all share this shape. [fill] for a dot or solid chip,
/// [surface]/[onSurface] for a badge, [onSurface] for status text.
@immutable
class KaziStatusColors {
  const KaziStatusColors({
    required this.fill,
    required this.onFill,
    required this.surface,
    required this.onSurface,
  });

  static const successLight = KaziStatusColors(
    fill: KaziPalette.success,
    onFill: KaziPalette.white,
    surface: KaziPalette.successContainerLight,
    onSurface: KaziPalette.onSuccessContainerLight,
  );

  static const successDark = KaziStatusColors(
    fill: KaziPalette.successDark,
    onFill: KaziPalette.graphite,
    surface: KaziPalette.successContainerDark,
    onSurface: KaziPalette.onSuccessContainerDark,
  );

  // `warning` itself does not change across brightnesses: lightening it pulls
  // the hue toward 38°, too close to the brand yellow at 45°.
  static const warningLight = KaziStatusColors(
    fill: KaziPalette.warning,
    onFill: KaziPalette.graphite,
    surface: KaziPalette.warningContainerLight,
    onSurface: KaziPalette.onWarningContainerLight,
  );

  static const warningDark = KaziStatusColors(
    fill: KaziPalette.warning,
    onFill: KaziPalette.graphite,
    surface: KaziPalette.warningContainerDark,
    onSurface: KaziPalette.onWarningContainerDark,
  );

  static const infoLight = KaziStatusColors(
    fill: KaziPalette.info,
    onFill: KaziPalette.white,
    surface: KaziPalette.infoContainerLight,
    onSurface: KaziPalette.onInfoContainerLight,
  );

  static const infoDark = KaziStatusColors(
    fill: KaziPalette.infoDark,
    onFill: KaziPalette.graphite,
    surface: KaziPalette.infoContainerDark,
    onSurface: KaziPalette.onInfoContainerDark,
  );

  static const dangerLight = KaziStatusColors(
    fill: KaziPalette.error,
    onFill: KaziPalette.white,
    surface: KaziPalette.errorContainerLight,
    onSurface: KaziPalette.onErrorContainerLight,
  );

  static const dangerDark = KaziStatusColors(
    fill: KaziPalette.errorDark,
    onFill: KaziPalette.graphite,
    surface: KaziPalette.errorContainerDark,
    onSurface: KaziPalette.onErrorContainerDark,
  );

  /// The saturated form: dots, icons, solid chips, progress.
  ///
  /// As a fill on a light page this is AA-Large only, so do not write small
  /// text in it — that is what [onSurface] is for.
  final Color fill;

  /// Ink on [fill].
  final Color onFill;

  /// The tinted background of a badge or banner.
  final Color surface;

  /// Ink on [surface] — and the correct colour for status text written
  /// directly on the page.
  final Color onSurface;

  KaziStatusColors lerp(KaziStatusColors other, double t) => KaziStatusColors(
        fill: Color.lerp(fill, other.fill, t)!,
        onFill: Color.lerp(onFill, other.onFill, t)!,
        surface: Color.lerp(surface, other.surface, t)!,
        onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      );
}

/// The dark panel a headline money value sits on. Graphite against a Névoa
/// page in light; Graphite-800 in dark, so it still separates from the
/// already-graphite page.
@immutable
class KaziMoneyColors {
  const KaziMoneyColors({
    required this.surface,
    required this.onSurface,
    required this.accent,
  });

  static const light = KaziMoneyColors(
    surface: KaziPalette.graphite,
    onSurface: KaziPalette.mist,
    accent: KaziPalette.yellow,
  );

  static const dark = KaziMoneyColors(
    surface: KaziPalette.graphite800,
    onSurface: KaziPalette.mist,
    accent: KaziPalette.yellow,
  );

  /// The panel background.
  final Color surface;

  /// The value itself, and any label on the panel.
  final Color onSurface;

  /// Yellow on [surface], for the amount still to come in.
  final Color accent;

  KaziMoneyColors lerp(KaziMoneyColors other, double t) => KaziMoneyColors(
        surface: Color.lerp(surface, other.surface, t)!,
        onSurface: Color.lerp(onSurface, other.onSurface, t)!,
        accent: Color.lerp(accent, other.accent, t)!,
      );
}

/// The brand canvas — screens where the brand *is* the background: the two
/// splash screens and the login page. Light is a yellow ground with graphite
/// artwork; dark is a graphite ground with a yellow mark.
@immutable
class KaziHeroColors {
  const KaziHeroColors({
    required this.surface,
    required this.ink,
    required this.mark,
    required this.muted,
  });

  static const light = KaziHeroColors(
    surface: KaziPalette.yellow,
    ink: KaziPalette.graphite,
    mark: KaziPalette.graphite,
    muted: KaziPalette.amber700,
  );

  static const dark = KaziHeroColors(
    surface: KaziPalette.graphite,
    ink: KaziPalette.mist,
    mark: KaziPalette.yellow,
    muted: KaziPalette.graphite300,
  );

  /// The full-bleed background.
  final Color surface;

  /// The wordmark and any primary text on [surface].
  final Color ink;

  /// The Raio-K symbol. Same as [ink] on light, but yellow on dark.
  final Color mark;

  /// The signature line and any secondary text on [surface].
  final Color muted;

  KaziHeroColors lerp(KaziHeroColors other, double t) => KaziHeroColors(
        surface: Color.lerp(surface, other.surface, t)!,
        ink: Color.lerp(ink, other.ink, t)!,
        mark: Color.lerp(mark, other.mark, t)!,
        muted: Color.lerp(muted, other.muted, t)!,
      );
}

/// Light [ColorScheme], written out explicitly rather than seeded, with
/// [ColorScheme.surfaceTint] pinned to `surface`. Both are deliberate — see
/// README.md before changing either.
const _lightScheme = ColorScheme(
  brightness: Brightness.light,

  primary: KaziPalette.yellow,
  onPrimary: KaziPalette.graphite,
  primaryContainer: KaziPalette.yellow100,
  onPrimaryContainer: KaziPalette.graphite,

  // Âmbar: the accent that can be written with on a light surface.
  secondary: KaziPalette.amber,
  onSecondary: KaziPalette.white,
  secondaryContainer: KaziPalette.yellow100,
  onSecondaryContainer: KaziPalette.amber700,

  // There is no third brand accent, so tertiary stays neutral.
  tertiary: KaziPalette.graphite700,
  onTertiary: KaziPalette.mist,
  tertiaryContainer: KaziPalette.graphite100,
  onTertiaryContainer: KaziPalette.graphite800,

  error: KaziPalette.error,
  onError: KaziPalette.white,
  errorContainer: KaziPalette.errorContainerLight,
  onErrorContainer: KaziPalette.onErrorContainerLight,

  surface: KaziPalette.mist,
  onSurface: KaziPalette.graphite,
  onSurfaceVariant: KaziPalette.graphite500,

  // Cards sit on white, one step above the Névoa page.
  surfaceContainerLowest: KaziPalette.white,
  surfaceContainerLow: KaziPalette.mist50,
  surfaceContainer: KaziPalette.mist,
  surfaceContainerHigh: KaziPalette.mist200,
  surfaceContainerHighest: KaziPalette.graphite100,
  surfaceDim: KaziPalette.graphite100,
  surfaceBright: KaziPalette.white,
  surfaceTint: KaziPalette.mist,

  outline: KaziPalette.graphite500,
  outlineVariant: KaziPalette.graphite200,

  inverseSurface: KaziPalette.graphite800,
  onInverseSurface: KaziPalette.mist,
  inversePrimary: KaziPalette.yellow,

  shadow: KaziPalette.graphite,
  scrim: KaziPalette.graphite,
);

/// Dark [ColorScheme], anchored on the brandbook's dark artefacts. The accent
/// needs no ink form here: on graphite the brand yellow is 12.42:1.
const _darkScheme = ColorScheme(
  brightness: Brightness.dark,

  primary: KaziPalette.yellow,
  onPrimary: KaziPalette.graphite,
  primaryContainer: KaziPalette.yellow900,
  onPrimaryContainer: KaziPalette.yellow,

  secondary: KaziPalette.yellow,
  onSecondary: KaziPalette.graphite,
  secondaryContainer: KaziPalette.graphite700,
  onSecondaryContainer: KaziPalette.yellow,

  tertiary: KaziPalette.graphite200,
  onTertiary: KaziPalette.graphite,
  tertiaryContainer: KaziPalette.graphite700,
  onTertiaryContainer: KaziPalette.graphite100,

  error: KaziPalette.errorDark,
  onError: KaziPalette.graphite,
  errorContainer: KaziPalette.errorContainerDark,
  onErrorContainer: KaziPalette.onErrorContainerDark,

  surface: KaziPalette.graphite,
  onSurface: KaziPalette.mist,
  // Graphite-300, not graphite-500: the latter is only 3.27:1 here and
  // fails for text. The brandbook's own dark hero meta uses graphite-300.
  onSurfaceVariant: KaziPalette.graphite300,

  surfaceContainerLowest: KaziPalette.graphite900,
  surfaceContainerLow: KaziPalette.graphite850,
  surfaceContainer: KaziPalette.graphite800,
  surfaceContainerHigh: KaziPalette.graphite750,
  surfaceContainerHighest: KaziPalette.graphite700,
  surfaceDim: KaziPalette.graphite,
  surfaceBright: KaziPalette.graphite700,
  surfaceTint: KaziPalette.graphite,

  outline: KaziPalette.graphite300,
  outlineVariant: KaziPalette.graphite700,

  inverseSurface: KaziPalette.mist,
  onInverseSurface: KaziPalette.graphite800,
  // Âmbar is the accent that reads on the inverse (light) surface.
  inversePrimary: KaziPalette.amber,

  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
);
