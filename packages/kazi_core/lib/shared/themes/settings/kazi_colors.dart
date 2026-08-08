import 'package:flutter/material.dart';

/// Raw Kazi brand palette, straight from the brandbook.
///
/// This class is deliberately **brightness-agnostic**: these are physical hex
/// values, not roles. Light/dark roles are resolved by `KaziColorRoles` and by
/// the `ColorScheme`s in `KaziColorSchemes` — read colours from those, not
/// from here, whenever the widget lives inside a theme.
///
/// Brand rules encoded elsewhere but worth repeating:
/// - Yellow is a **surface**, not ink. To write "in yellow" on a light
///   background use [ambar] (or `KaziColorRoles.accentInk`, which flips to
///   yellow on dark).
/// - One yellow per screen. It marks either the primary action or the primary
///   number — never both.
/// - Graphite carries the money. Values sit on dark surfaces, with yellow
///   indicating what is still coming in.
/// - Categories only as small marks: dots, tags, chart slices.
abstract class KaziColors {
  // ── Brand ────────────────────────────────────────────────────────────────

  /// Kazi Yellow. The brand colour and the primary action surface.
  static const kazi = Color(0xFFFFCC31);

  /// Pressed/active state of [kazi].
  static const amarelo600 = Color(0xFFE5AC12);

  /// Readable yellow: the ink form of the brand yellow on light surfaces.
  static const ambar = Color(0xFFA87400);

  /// Darkened [ambar], for yellow text at body size on light surfaces.
  ///
  /// The brandbook claims [ambar] is 4.9:1 on [nevoa]; it measures 3.64:1,
  /// which is AA-Large only. This one is 5.05:1.
  static const ambar700 = Color(0xFF8A5F00);

  /// Soft yellow wash for subtle highlights.
  static const amarelo100 = Color(0xFFFFF2CC);

  // ── Neutrals ─────────────────────────────────────────────────────────────

  /// Graphite. Default ink on light, default surface on dark.
  static const grafite = Color(0xFF14120D);
  static const grafite800 = Color(0xFF22201A);
  static const grafite700 = Color(0xFF35322A);

  /// Secondary text on light surfaces.
  static const grafite500 = Color(0xFF6B675C);

  /// Secondary text on dark surfaces. [grafite500] is only 3.27:1 on
  /// [grafite] and fails for text.
  static const grafite300 = Color(0xFFA8A498);

  /// Borders on light surfaces.
  static const grafite200 = Color(0xFFD8D4C8);
  static const grafite100 = Color(0xFFE9E6DD);

  /// Mist. The default light surface.
  static const nevoa = Color(0xFFF4F2ED);
  static const branco = Color(0xFFFFFFFF);

  // ── Derived neutrals ─────────────────────────────────────────────────────
  // Not in the brandbook. These fill the Material tonal surface ladder so the
  // schemes do not have to invent values at runtime.

  static const nevoa50 = Color(0xFFFAF9F6);
  static const nevoa200 = Color(0xFFEEEBE4);
  static const grafite900 = Color(0xFF0D0C08);
  static const grafite850 = Color(0xFF1A1813);
  static const grafite750 = Color(0xFF2B2822);

  // ── Product · status ─────────────────────────────────────────────────────
  // Light-mode base values. Dark variants live in `KaziColorRoles.dark`.

  /// Paid, completed.
  static const success = Color(0xFF16A34A);

  /// Failed, cancelled.
  static const error = Color(0xFFE5484D);

  /// Pending. Warning is Âmbar-orange and is **never** [kazi] yellow — if the
  /// brand yellow signalled problems, the brand would start to mean "caution"
  /// instead of "energy".
  static const warning = Color(0xFFE5860A);

  /// Information.
  static const info = Color(0xFF2F6FEB);

  // ── Product · status on dark surfaces ────────────────────────────────────
  // The light values above are too dark to read on [grafite].
  // [warning] deliberately has no dark variant: lightening it pulls the hue
  // toward 38°, too close to [kazi] at 45°, and it already passes AA at
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

  /// Yellow wash on dark surfaces, the counterpart of [amarelo100].
  static const amarelo900 = Color(0xFF3A2F0C);

  // ── Product · service categories ─────────────────────────────────────────
  // Small marks only: dots, tags, chart slices. Never a screen background, a
  // primary button or a header — that space belongs to [kazi].
  //
  // These are identity, not state, so they are the same in light and dark.
  // On light surfaces [category4] (2.51:1) and [category5] (2.27:1) fall below
  // the 3:1 non-text threshold, so dots should carry a 1px `outlineVariant`
  // ring there.

  static const category1 = Color(0xFF2F6FEB);
  static const category2 = Color(0xFF7C5CFC);
  static const category3 = Color(0xFFE255A1);
  static const category4 = Color(0xFFF97316);
  static const category5 = Color(0xFF10B981);
  static const category6 = Color(0xFFE5484D);

  // ── Legacy ───────────────────────────────────────────────────────────────
  // Kept so the existing static call sites keep compiling while the app is
  // migrated to the tokens above. Do not use in new code: prefer
  // `Theme.of(context).colorScheme` or `context.kaziColors`.

  @Deprecated('Use KaziColors.category1 or colorScheme-driven category roles')
  static const blue = category1;

  @Deprecated('Use KaziColors.category2 or colorScheme-driven category roles')
  static const purple = category2;

  @Deprecated('Use KaziColors.category3 or colorScheme-driven category roles')
  static const pink = category3;

  @Deprecated('Use KaziColors.category4 or colorScheme-driven category roles')
  static const orange = category4;

  @Deprecated('Use KaziColors.category5, or KaziColors.success if semantic')
  static const green = category5;

  @Deprecated('Use KaziColors.category6, or KaziColors.error if semantic')
  static const red = category6;

  @Deprecated('Use KaziColors.kazi or colorScheme.primary')
  static const primary = Color(0xFFFFCC31);

  @Deprecated('Use KaziColors.nevoa or colorScheme.surface')
  static const background = Color(0xFFF9FAFB);

  @Deprecated('Use KaziColors.branco or colorScheme.surfaceContainerLowest')
  static const white = Color(0xFFFFFFFF);

  @Deprecated('Use KaziColors.grafite or colorScheme.onSurface')
  static const black = Color(0xFF1F1F1F);

  @Deprecated('Use KaziColors.grafite500 or colorScheme.onSurfaceVariant')
  static const darkGrey = Color(0xFF374151);

  @Deprecated('Use KaziColors.grafite500 or colorScheme.onSurfaceVariant')
  static const grey = Color(0xFF9EA4B1);

  @Deprecated('Use KaziColors.grafite100 or colorScheme.surfaceContainerHigh')
  static const lightGrey = Color(0xFFF3F4F6);

  @Deprecated('Use KaziColors.grafite200 or colorScheme.outlineVariant')
  static const stroke = Color(0xFFE5E7EB);

  @Deprecated('Use colorScheme.scrim with an explicit opacity')
  static const overlay = Color(0x99F9FAFB);
}
