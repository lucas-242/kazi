/// Fixed component dimensions.
///
/// These are the numbers that are neither spacing nor radius — heights,
/// diameters and touch targets. Keeping them here is what stops them being
/// re-typed as literals inside component themes.
abstract class KaziSizings {
  ///50.0px — splash and header logo.
  static const logoHeight = 50.0;

  ///68.0px — matches `BottomAppBarThemeData.height`.
  static const bottomAppBarHeight = 68.0;

  ///56.0px — standard app bar.
  static const appBarHeight = 56.0;

  ///48.0px — the minimum touch target (WCAG 2.5.5 and Material).
  static const minTouchTarget = 48.0;

  ///56.0px — floating action button diameter.
  static const fabSize = 56.0;

  ///16.0px
  static const iconSm = 16.0;

  ///24.0px
  static const iconMd = 24.0;

  ///32.0px
  static const iconLg = 32.0;

  ///42.0px — data table heading and max data row height.
  static const tableRowHeight = 42.0;

  ///28.0px — data table minimum data row height.
  static const tableRowMinHeight = 28.0;
}
