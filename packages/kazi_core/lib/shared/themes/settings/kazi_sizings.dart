import 'package:kazi_core/shared/themes/settings/kazi_insets.dart';

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

  ///48.0px — the minimum touch target.
  ///
  /// Material's and Android's floor, and the strictest of the three that
  /// apply: WCAG 2.5.8 (AA) asks 24, WCAG 2.5.5 (AAA) asks 44, Apple's HIG
  /// asks 44pt. Sizing to 48 clears all of them.
  static const minTouchTarget = 48.0;

  ///36.0px — chip and pill height.
  ///
  /// Deliberately under [minTouchTarget]: a row of filter pills reads as a
  /// toolbar, and at 48 each pill is as tall as a button and the row competes
  /// with the list it filters. Material's own chips sit lower still, at 32.
  static const chipHeight = 36.0;

  ///56.0px — floating action button diameter.
  static const fabSize = 56.0;

  ///48.0px — the shortest the bottom navigation may be, before the safe area.
  ///
  /// A floor, not the height: `KaziNavBar` sizes itself to a destination's
  /// own ink plus its breathing room, and takes this only when that would
  /// come out under [minTouchTarget]. The safe area is added on top by
  /// `BottomAppBar` itself — which is why a gesture bar and a three-button
  /// bar do not land on the same total, and why `KaziNavBar` must not add the
  /// inset a second time.
  static const navBarMinHeight = 48.0;

  ///21.0px — bottom navigation icon.
  static const navBarIcon = 21.0;

  ///54.0px — the central floating action button of the bottom navigation.
  ///
  /// Deliberately smaller than [fabSize]: it sits over the bar, not beside it.
  static const navBarFabSize = 54.0;

  ///74.0px — the gap the bottom navigation leaves for the central button.
  static const navBarCenterSlot = 74.0;

  ///35.0px — the room a page inside the shell has to leave at its bottom
  ///edge for the central button.
  ///
  /// The button is docked on the bar's top edge, so half of it
  /// ([navBarFabSize] / 2) floats over the body — which the `Scaffold` lays
  /// out as if it ended at the bar. `AppShell` hands this down as bottom
  /// padding; every page reaches it through `KaziSafeArea`.
  static const navBarFabClearance = navBarFabSize / 2 + KaziInsets.xs;

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
