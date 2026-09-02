import 'package:flutter/material.dart';

/// Raw Kazi brand palette: physical hex values that know nothing about light
/// and dark. **Never read from a widget** — it is kept out of the `themes`
/// barrel so apps cannot. Screens read `context.colors` (`KaziColors`), which
/// this file exists only to feed. Brand rules in ../README.md.
abstract class KaziPalette {
  // ── Brand ────────────────────────────────────────────────────────────────

  /// Kazi Yellow. The brand colour and the primary action surface.
  static const yellow = Color(0xFFFFCC31);

  /// Pressed/active state of [yellow].
  static const yellow600 = Color(0xFFE5AC12);

  /// Readable yellow: the ink form of the brand yellow on light surfaces.
  static const amber = Color(0xFFA87400);

  /// Darkened [amber], for yellow text at body size on light surfaces.
  ///
  /// The brandbook claims [amber] is 4.9:1 on [mist]; it measures 3.64:1,
  /// which is AA-Large only. This one is 5.05:1.
  static const amber700 = Color(0xFF8A5F00);

  /// Soft yellow wash for subtle highlights.
  static const yellow100 = Color(0xFFFFF2CC);

  // ── Neutrals ─────────────────────────────────────────────────────────────

  /// Graphite. Default ink on light, default surface on dark.
  static const graphite = Color(0xFF14120D);
  static const graphite800 = Color(0xFF22201A);
  static const graphite700 = Color(0xFF35322A);

  /// Secondary text on light surfaces.
  static const graphite500 = Color(0xFF6B675C);

  /// Secondary text on dark surfaces. [graphite500] is only 3.27:1 on
  /// [graphite] and fails for text.
  static const graphite300 = Color(0xFFA8A498);

  /// Borders on light surfaces.
  static const graphite200 = Color(0xFFD8D4C8);
  static const graphite100 = Color(0xFFE9E6DD);

  /// Mist. The default light surface.
  static const mist = Color(0xFFF4F2ED);
  static const white = Color(0xFFFFFFFF);

  // ── Derived neutrals ─────────────────────────────────────────────────────
  // Not in the brandbook. These fill the Material tonal surface ladder so the
  // schemes do not have to invent values at runtime.

  static const mist50 = Color(0xFFFAF9F6);
  static const mist200 = Color(0xFFEEEBE4);
  static const graphite900 = Color(0xFF0D0C08);
  static const graphite850 = Color(0xFF1A1813);
  static const graphite750 = Color(0xFF2B2822);

  // ── Product · status ─────────────────────────────────────────────────────
  // Light-mode base values. Dark variants live in `KaziColors.dark`.

  /// Paid, completed.
  static const success = Color(0xFF16A34A);

  /// Failed, cancelled.
  static const error = Color(0xFFE5484D);

  /// Pending. Warning is Âmbar-orange and is **never** [yellow] yellow — if the
  /// brand yellow signalled problems, the brand would start to mean "caution"
  /// instead of "energy".
  static const warning = Color(0xFFE5860A);

  /// Information.
  static const info = Color(0xFF2F6FEB);

  // ── Product · status on dark surfaces ────────────────────────────────────
  // The light values above are too dark to read on [graphite].
  // [warning] deliberately has no dark variant: lightening it pulls the hue
  // toward 38°, too close to [yellow] at 45°, and it already passes AA at
  // 6.96:1 on graphite.

  /// [success] on dark. The light value is only 5.78:1 and reads muddy.
  static const successDark = Color(0xFF3DD68C);

  /// [error] on dark. The light value is 4.85:1 — passing, but muddy.
  static const errorDark = Color(0xFFFF6369);

  /// [info] on dark. The light value is 4.15:1 and **fails** AA.
  static const infoDark = Color(0xFF5B8DEF);

  // ── Product · status containers ──────────────────────────────────────────
  // Tinted backgrounds for banners and badges, with the ink that reads on
  // them. The `on*` values are also the correct colour for status *text* on a
  // plain surface.

  static const successContainerLight = Color(0xFFDCF2E3);
  static const onSuccessContainerLight = Color(0xFF0B5F2C);
  static const successContainerDark = Color(0xFF123322);
  static const onSuccessContainerDark = Color(0xFF9FE7BF);

  static const errorContainerLight = Color(0xFFFCE9E9);
  static const onErrorContainerLight = Color(0xFF9B1F23);
  static const errorContainerDark = Color(0xFF4A1416);
  static const onErrorContainerDark = Color(0xFFFFB3B6);

  static const warningContainerLight = Color(0xFFFDEFD6);
  static const onWarningContainerLight = Color(0xFF7A4700);
  static const warningContainerDark = Color(0xFF3A2A0C);
  static const onWarningContainerDark = Color(0xFFF2C078);

  static const infoContainerLight = Color(0xFFE1E9FD);
  static const onInfoContainerLight = Color(0xFF1C4AA8);
  static const infoContainerDark = Color(0xFF16224A);
  static const onInfoContainerDark = Color(0xFFAFC6F7);

  /// The edge of a [yellow100] wash. Light enough to stay a border and dark
  /// enough that the wash still has one on a Névoa page, where a soft yellow
  /// block otherwise bleeds into the ground.
  static const yellow200 = Color(0xFFF0DFA8);

  /// Yellow wash on dark surfaces, the counterpart of [yellow100].
  static const yellow900 = Color(0xFF3A2F0C);

  /// The edge of a [yellow900] wash, its [yellow200] counterpart.
  static const yellow800 = Color(0xFF5C4A15);

  // ── Product · service categories ─────────────────────────────────────────
  // Small marks only: dots, tags, chart slices. Never a screen background, a
  // primary button or a header — that space belongs to [yellow].
  //
  // These are identity, not state, so they are the same in light and dark.
  // On light surfaces [category4] (2.51:1), [category5] (2.27:1),
  // [category7] (2.17:1) and [category9] (2.76:1) fall below the 3:1 non-text
  // threshold, so dots should carry a 1px `outlineVariant` ring there. Every
  // one of them clears 3:1 on graphite.
  //
  // Hues 33°-62° are left to the brand yellow: a mark in that band would read
  // as the app's own accent rather than as one service among others.

  static const category1 = Color(0xFF2F6FEB);
  static const category2 = Color(0xFF7C5CFC);
  static const category3 = Color(0xFFE255A1);
  static const category4 = Color(0xFFF97316);
  static const category5 = Color(0xFF10B981);
  static const category6 = Color(0xFFE5484D);
  static const category7 = Color(0xFF06B6D4);
  static const category8 = Color(0xFF9333EA);
  static const category9 = Color(0xFF65A30D);
  static const category10 = Color(0xFF0F766E);
  static const category11 = Color(0xFFB45309);
  static const category12 = Color(0xFF64748B);
  static const category13 = Color(0xFF1C79C4);
  static const category14 = Color(0xFFC42BB4);
  static const category15 = Color(0xFF7A7D14);
  static const category16 = Color(0xFF1D8732);
  static const category17 = Color(0xFFE12A15);
  static const category18 = Color(0xFFE01571);
}
