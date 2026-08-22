/// Fixed component dimensions.
///
/// These are the numbers that are neither spacing nor radius — heights,
/// diameters and touch targets. Keeping them here is what stops them being
/// re-typed as literals inside component themes.
abstract class KaziSizings {
  ///50.0px — header logo.
  static const logoHeight = 50.0;

  ///120.0px — the Raio-K on the splash.
  ///
  /// Like every size here it measures the **logo asset's box**, which is the
  /// brandbook's 100x100 grid; the mark itself spans 92 of those units, so what
  /// lands on screen is 110dp tall and 74dp wide.
  ///
  /// Those two numbers are shared with the Android launch resources: they are
  /// baked into `kazi_splash_mark.xml` (74x110dp) and into the scale/translate
  /// of `kazi_splash_icon.xml`. The platform splash cannot be turned off on
  /// Android 12+, so the only way to show the user one splash instead of two is
  /// for both to draw the mark at the same size on the same ground. Change it
  /// here and change it there, or the handoff jumps.
  static const splashLogoHeight = 120.0;

  ///70.0px — the Raio-K on the login gate.
  static const loginLogoHeight = 70.0;

  ///68.0px — matches `BottomAppBarThemeData.height`.
  static const bottomAppBarHeight = 68.0;

  ///56.0px — standard app bar.
  static const appBarHeight = 56.0;

  ///48.0px — the minimum touch target (WCAG 2.5.5 and Material).
  static const minTouchTarget = 48.0;

  ///56.0px — floating action button diameter.
  static const fabSize = 56.0;

  ///62.0px — bottom navigation height, before the safe area.
  static const navBarHeight = 62.0;

  ///21.0px — bottom navigation icon.
  static const navBarIcon = 21.0;

  ///54.0px — the central floating action button of the bottom navigation.
  ///
  /// Deliberately smaller than [fabSize]: it sits over the bar, not beside it.
  static const navBarFabSize = 54.0;

  ///74.0px — the gap the bottom navigation leaves for the central button.
  static const navBarCenterSlot = 74.0;

  ///4.0px — the ring of page ground around the central button, which is what
  ///keeps the yellow from touching the bar it floats over.
  static const navBarFabRing = 4.0;

  ///15.0px — how far the central button sits below the standard docked
  ///position, leaving 12 of its 54 above the bar's top edge.
  static const navBarFabSink = 15.0;

  ///3.0px — how far the active destination's icon and label rise.
  static const navBarActiveLift = 3.0;

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
