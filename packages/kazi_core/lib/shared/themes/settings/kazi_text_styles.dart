import 'package:flutter/material.dart';

/// The Kazi type scale: two families, three jobs.
///
/// - **Archivo** — a tight grotesque, for saying things. Display, headlines
///   and titles.
/// - **IBM Plex Sans** — a humanist, for explaining things. Body and captions.
/// - **IBM Plex Mono** — for tags and eyebrows. See [tag].
///
/// Everything here is **colourless on purpose**. `Text` merges the style it is
/// given over the ambient `DefaultTextStyle`, which Material seeds from
/// `theme.textTheme.bodyMedium`, so colour arrives from the theme and follows
/// the brightness. Use [themed] for the coloured copy that goes into
/// `ThemeData` — a colourless `TextTheme` installed there would render black
/// in both brightnesses.
///
/// Tracking is in logical pixels, not em: `letterSpacing` here is the
/// brandbook's percentage multiplied by the font size.
///
/// Sentence case everywhere. Upper case belongs only to the monospaced [tag] —
/// the brand is confident, not loud.
abstract class KaziTextStyles {
  // ── Families ─────────────────────────────────────────────────────────────
  // Declared in this package's pubspec, so every style carries `package` and
  // Flutter resolves them as `packages/kazi_core/<family>`.

  static const _archivo = 'Archivo';
  static const _plexSans = 'IBM Plex Sans';
  static const _plexMono = 'IBM Plex Mono';
  static const _package = 'kazi_core';

  // ── Display · Archivo 800 ────────────────────────────────────────────────

  /// Archivo 800 · 34px · tracking −4.5%.
  static const TextStyle displayLg = TextStyle(
    fontFamily: _archivo,
    package: _package,
    fontWeight: FontWeight.w800,
    fontSize: 34,
    height: 1,
    letterSpacing: -1.53,
  );

  /// Archivo 800 · 32px · tracking −4.5%.
  static const TextStyle displayMd = TextStyle(
    fontFamily: _archivo,
    package: _package,
    fontWeight: FontWeight.w800,
    fontSize: 32,
    height: 1,
    letterSpacing: -1.44,
  );

  /// Archivo 800 · 30/32 · tracking −3.5%. The brandbook's TÍTULO.
  static const TextStyle displaySm = TextStyle(
    fontFamily: _archivo,
    package: _package,
    fontWeight: FontWeight.w800,
    fontSize: 30,
    height: 32 / 30,
    letterSpacing: -1.05,
  );

  // ── Headline · Archivo 800 ───────────────────────────────────────────────

  /// Archivo 800 · 32px · tracking −3.5%.
  static const TextStyle headlineLg = TextStyle(
    fontFamily: _archivo,
    package: _package,
    fontWeight: FontWeight.w800,
    fontSize: 32,
    height: 1.05,
    letterSpacing: -1.12,
  );

  /// Archivo 800 · 24px · tracking −3.5%.
  static const TextStyle headlineMd = TextStyle(
    fontFamily: _archivo,
    package: _package,
    fontWeight: FontWeight.w800,
    fontSize: 24,
    height: 1.08,
    letterSpacing: -0.84,
  );

  /// Archivo 800 · 18px · tracking −3%.
  static const TextStyle headlineSm = TextStyle(
    fontFamily: _archivo,
    package: _package,
    fontWeight: FontWeight.w800,
    fontSize: 18,
    height: 1.15,
    letterSpacing: -0.54,
  );

  // ── Title · Archivo 600 ──────────────────────────────────────────────────

  /// Archivo 600 · 24px · tracking −2%.
  static const TextStyle titleLg = TextStyle(
    fontFamily: _archivo,
    package: _package,
    fontWeight: FontWeight.w600,
    fontSize: 24,
    height: 1.25,
    letterSpacing: -0.48,
  );

  /// Archivo 600 · 20/26 · tracking −2%. The brandbook's SUBTÍTULO.
  static const TextStyle titleMd = TextStyle(
    fontFamily: _archivo,
    package: _package,
    fontWeight: FontWeight.w600,
    fontSize: 20,
    height: 26 / 20,
    letterSpacing: -0.4,
  );

  /// Archivo 600 · 16px · tracking −2%.
  static const TextStyle titleSm = TextStyle(
    fontFamily: _archivo,
    package: _package,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    height: 1.35,
    letterSpacing: -0.32,
  );

  // ── Body · IBM Plex Sans 400 ─────────────────────────────────────────────

  /// IBM Plex Sans 400 · 17/28. The brandbook's CORPO.
  static const TextStyle lg = TextStyle(
    fontFamily: _plexSans,
    package: _package,
    fontWeight: FontWeight.w400,
    fontSize: 17,
    height: 28 / 17,
  );

  /// IBM Plex Sans 400 · 16/26.
  static const TextStyle md = TextStyle(
    fontFamily: _plexSans,
    package: _package,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 26 / 16,
  );

  /// IBM Plex Sans 400 · 14/22.
  static const TextStyle sm = TextStyle(
    fontFamily: _plexSans,
    package: _package,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 22 / 14,
  );

  /// IBM Plex Sans 400 · 15/24. The brandbook's APOIO — "Atualizado hoje às
  /// 14:32". It has no Material slot, so opt in explicitly.
  static const TextStyle support = TextStyle(
    fontFamily: _plexSans,
    package: _package,
    fontWeight: FontWeight.w400,
    fontSize: 15,
    height: 24 / 15,
  );

  // ── Label · IBM Plex Sans ────────────────────────────────────────────────
  // These are Material's button and caption slots, so they stay in Plex Sans.
  // The monospaced ETIQUETA is [tag], which you choose deliberately.

  /// IBM Plex Sans 500 · 16px. Material's button label; also field labels and
  /// input hints.
  static const TextStyle labelLg = TextStyle(
    fontFamily: _plexSans,
    package: _package,
    fontWeight: FontWeight.w500,
    fontSize: 16,
    height: 1.25,
  );

  /// IBM Plex Sans 400 · 14px. Captions.
  static const TextStyle labelMd = TextStyle(
    fontFamily: _plexSans,
    package: _package,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.43,
  );

  /// IBM Plex Sans 400 · 12px. Small captions.
  static const TextStyle labelSm = TextStyle(
    fontFamily: _plexSans,
    package: _package,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 1.4,
  );

  // ── Tag · IBM Plex Mono ──────────────────────────────────────────────────

  /// ETIQUETA — IBM Plex Mono 500 · 12px · tracking +10%.
  ///
  /// Eyebrows, section markers and metadata chips: "A receber · 12 serviços".
  /// This is the **only** place upper case is allowed, and Flutter has no text
  /// transform, so the call site upper-cases the string itself.
  static const TextStyle tag = TextStyle(
    fontFamily: _plexMono,
    package: _package,
    fontWeight: FontWeight.w500,
    fontSize: 12,
    height: 1.33,
    letterSpacing: 1.2,
  );

  // ── Money · Archivo 800, tabular ─────────────────────────────────────────

  /// Archivo 800 · 32px with tabular figures, so digits keep their column and
  /// the number does not jitter as values change.
  ///
  /// "Dinheiro é a informação mais lida do produto."
  static const TextStyle money = TextStyle(
    fontFamily: _archivo,
    package: _package,
    fontWeight: FontWeight.w800,
    fontSize: 32,
    height: 1,
    letterSpacing: -1.28,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );

  /// The colourless scale as a Material [TextTheme].
  static const TextTheme textTheme = TextTheme(
    displayLarge: displayLg,
    displayMedium: displayMd,
    displaySmall: displaySm,
    headlineLarge: headlineLg,
    headlineMedium: headlineMd,
    headlineSmall: headlineSm,
    titleLarge: titleLg,
    titleMedium: titleMd,
    titleSmall: titleSm,
    bodyLarge: lg,
    bodyMedium: md,
    bodySmall: sm,
    labelLarge: labelLg,
    labelMedium: labelMd,
    labelSmall: labelSm,
  );

  /// The **wordmark** — "kazi" in Archivo 800 at −5.5% tracking.
  ///
  /// Not part of the type scale: this is the logo set as text, and its tracking
  /// is a property of the lockup, not of a heading. Use it only where the brand
  /// signs itself (the splash); anywhere the name appears in a sentence it is
  /// "Kazi" in ordinary body type, like any proper noun.
  static TextStyle wordmarkAt(double fontSize) => TextStyle(
        fontFamily: _archivo,
        package: _package,
        fontWeight: FontWeight.w800,
        fontSize: fontSize,
        height: 1,
        letterSpacing: fontSize * -0.055,
      );

  /// [money] at another size, keeping tracking proportional at −4%.
  ///
  /// The brandbook also wants the currency symbol at 60% of the value and
  /// aligned to its top. The 60% is `moneyAt(size * 0.6)`; the top alignment
  /// cannot live in a [TextStyle] and needs a `RichText` with an explicit
  /// baseline shift.
  static TextStyle moneyAt(double fontSize) => money.copyWith(
        fontSize: fontSize,
        letterSpacing: fontSize * -0.04,
      );

  /// [textTheme] with colours resolved against [colors], for `ThemeData`.
  ///
  /// Applied slot by slot rather than through `TextTheme.apply`, which spreads
  /// `displayColor` onto `bodySmall` and `bodyColor` onto the label slots.
  /// Doing it by hand is clearer, and it is what lets captions be muted while
  /// the button label keeps full contrast.
  static TextTheme themed(ColorScheme colors) {
    final ink = colors.onSurface;
    final muted = colors.onSurfaceVariant;

    return TextTheme(
      displayLarge: displayLg.copyWith(color: ink),
      displayMedium: displayMd.copyWith(color: ink),
      displaySmall: displaySm.copyWith(color: ink),
      headlineLarge: headlineLg.copyWith(color: ink),
      headlineMedium: headlineMd.copyWith(color: ink),
      headlineSmall: headlineSm.copyWith(color: ink),
      titleLarge: titleLg.copyWith(color: ink),
      titleMedium: titleMd.copyWith(color: ink),
      titleSmall: titleSm.copyWith(color: ink),
      bodyLarge: lg.copyWith(color: ink),
      bodyMedium: md.copyWith(color: ink),
      bodySmall: sm.copyWith(color: ink),
      labelLarge: labelLg.copyWith(color: ink),
      labelMedium: labelMd.copyWith(color: muted),
      labelSmall: labelSm.copyWith(color: muted),
    );
  }
}
