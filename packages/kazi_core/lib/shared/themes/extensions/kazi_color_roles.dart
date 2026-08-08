import 'package:flutter/material.dart';
import 'package:kazi_core/shared/themes/settings/kazi_colors.dart';

/// Kazi brand colour roles that Material's [ColorScheme] has no slot for.
///
/// Every role here resolves **per brightness**, so the same token can be a
/// different hex in light and dark. Read it with `context.kaziColors`.
///
/// Anything that does map onto a Material role (surfaces, ink, outlines,
/// error) belongs in the [ColorScheme] instead — see `KaziColorSchemes`.
@immutable
class KaziColorRoles extends ThemeExtension<KaziColorRoles> {
  const KaziColorRoles({
    required this.accentInk,
    required this.accentInkStrong,
    required this.accentSurface,
    required this.accentSurfacePressed,
    required this.onAccentSurface,
    required this.accentSubtle,
    required this.onAccentSubtle,
    required this.focusRing,
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.info,
    required this.onInfo,
    required this.infoContainer,
    required this.onInfoContainer,
    required this.moneySurface,
    required this.onMoneySurface,
    required this.moneyAccent,
    required this.categories,
  });

  /// The light-mode roles.
  static const light = KaziColorRoles(
    accentInk: KaziColors.amber,
    accentInkStrong: KaziColors.amber700,
    accentSurface: KaziColors.yellow,
    accentSurfacePressed: KaziColors.yellow600,
    onAccentSurface: KaziColors.graphite,
    accentSubtle: KaziColors.yellow100,
    onAccentSubtle: KaziColors.graphite,
    focusRing: KaziColors.graphite,
    success: KaziColors.success,
    onSuccess: KaziColors.white,
    successContainer: KaziColors.successContainerLight,
    onSuccessContainer: KaziColors.onSuccessContainerLight,
    warning: KaziColors.warning,
    onWarning: KaziColors.graphite,
    warningContainer: KaziColors.warningContainerLight,
    onWarningContainer: KaziColors.onWarningContainerLight,
    info: KaziColors.info,
    onInfo: KaziColors.white,
    infoContainer: KaziColors.infoContainerLight,
    onInfoContainer: KaziColors.onInfoContainerLight,
    moneySurface: KaziColors.graphite,
    onMoneySurface: KaziColors.mist,
    moneyAccent: KaziColors.yellow,
    categories: _categories,
  );

  /// The dark-mode roles.
  static const dark = KaziColorRoles(
    accentInk: KaziColors.yellow,
    accentInkStrong: KaziColors.yellow,
    accentSurface: KaziColors.yellow,
    accentSurfacePressed: KaziColors.yellow600,
    onAccentSurface: KaziColors.graphite,
    accentSubtle: KaziColors.yellow900,
    onAccentSubtle: KaziColors.yellow,
    focusRing: KaziColors.yellow,
    success: KaziColors.successDark,
    onSuccess: KaziColors.graphite,
    successContainer: KaziColors.successContainerDark,
    onSuccessContainer: KaziColors.onSuccessContainerDark,
    warning: KaziColors.warning,
    onWarning: KaziColors.graphite,
    warningContainer: KaziColors.warningContainerDark,
    onWarningContainer: KaziColors.onWarningContainerDark,
    info: KaziColors.infoDark,
    onInfo: KaziColors.graphite,
    infoContainer: KaziColors.infoContainerDark,
    onInfoContainer: KaziColors.onInfoContainerDark,
    moneySurface: KaziColors.graphite800,
    onMoneySurface: KaziColors.mist,
    moneyAccent: KaziColors.yellow,
    categories: _categories,
  );

  static const _categories = <Color>[
    KaziColors.category1,
    KaziColors.category2,
    KaziColors.category3,
    KaziColors.category4,
    KaziColors.category5,
    KaziColors.category6,
  ];

  /// Brand yellow in its **ink** form: use this whenever you need to *write*
  /// in yellow, or tint an icon or a selected label.
  ///
  /// The brandbook rule "yellow is a surface, not ink" only holds on light
  /// backgrounds, so this resolves to Âmbar on light (Kazi yellow on Névoa is
  /// 1.4:1 — invisible) and to Kazi yellow on dark (12.42:1 on Graphite).
  ///
  /// 3.64:1 on Névoa, so it passes AA-Large only. Use [accentInkStrong] for
  /// text below 18.66px.
  final Color accentInk;

  /// [accentInk] darkened enough for body-size text on light surfaces
  /// (5.05:1). Identical to [accentInk] on dark.
  final Color accentInkStrong;

  /// Brand yellow as a **fill**: the FAB, the primary call to action.
  /// Remember "one yellow per screen".
  final Color accentSurface;

  /// Pressed state of [accentSurface].
  final Color accentSurfacePressed;

  /// Ink on [accentSurface] — graphite in both modes, 12.42:1. Never white:
  /// white on the brand yellow is 1.7:1.
  final Color onAccentSurface;

  /// A soft yellow wash for highlighted rows and badges.
  final Color accentSubtle;

  /// Ink on [accentSubtle].
  final Color onAccentSubtle;

  /// Focus indicators. Graphite on light, yellow on dark — a yellow ring on
  /// Névoa cannot be seen.
  final Color focusRing;

  /// Paid, completed. As a fill this is AA-Large only, so keep it to dots,
  /// icons and bold text; for success *text* use [onSuccessContainer].
  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;

  /// Pending. Âmbar-orange, never the brand yellow. Unchanged across
  /// brightnesses on purpose — see [KaziColors.warning].
  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color onWarningContainer;

  /// Information.
  final Color info;
  final Color onInfo;
  final Color infoContainer;
  final Color onInfoContainer;

  /// "Graphite carries the money." The dark panel that money values sit on,
  /// in both light and dark mode; on dark it lifts to graphite-800 so it still
  /// separates from the page.
  final Color moneySurface;
  final Color onMoneySurface;

  /// Yellow on [moneySurface], for the amount still to come in.
  final Color moneyAccent;

  /// The six service-category marks, in brandbook order.
  ///
  /// Small marks only: dots, tags, chart slices. These are identity rather
  /// than state, so they are the same hexes in light and dark. On light
  /// surfaces indices 3 and 4 fall below the 3:1 non-text threshold — give
  /// dots a 1px `outlineVariant` ring there.
  ///
  /// Prefer [category] over indexing this directly.
  final List<Color> categories;

  /// The category colour at [index], wrapping around for indices beyond the
  /// six defined marks.
  Color category(int index) => categories[index % categories.length];

  @override
  KaziColorRoles copyWith({
    Color? accentInk,
    Color? accentInkStrong,
    Color? accentSurface,
    Color? accentSurfacePressed,
    Color? onAccentSurface,
    Color? accentSubtle,
    Color? onAccentSubtle,
    Color? focusRing,
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? info,
    Color? onInfo,
    Color? infoContainer,
    Color? onInfoContainer,
    Color? moneySurface,
    Color? onMoneySurface,
    Color? moneyAccent,
    List<Color>? categories,
  }) {
    return KaziColorRoles(
      accentInk: accentInk ?? this.accentInk,
      accentInkStrong: accentInkStrong ?? this.accentInkStrong,
      accentSurface: accentSurface ?? this.accentSurface,
      accentSurfacePressed: accentSurfacePressed ?? this.accentSurfacePressed,
      onAccentSurface: onAccentSurface ?? this.onAccentSurface,
      accentSubtle: accentSubtle ?? this.accentSubtle,
      onAccentSubtle: onAccentSubtle ?? this.onAccentSubtle,
      focusRing: focusRing ?? this.focusRing,
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      infoContainer: infoContainer ?? this.infoContainer,
      onInfoContainer: onInfoContainer ?? this.onInfoContainer,
      moneySurface: moneySurface ?? this.moneySurface,
      onMoneySurface: onMoneySurface ?? this.onMoneySurface,
      moneyAccent: moneyAccent ?? this.moneyAccent,
      categories: categories ?? this.categories,
    );
  }

  @override
  KaziColorRoles lerp(covariant KaziColorRoles? other, double t) {
    if (other == null) {
      return this;
    }

    return KaziColorRoles(
      accentInk: Color.lerp(accentInk, other.accentInk, t)!,
      accentInkStrong:
          Color.lerp(accentInkStrong, other.accentInkStrong, t)!,
      accentSurface: Color.lerp(accentSurface, other.accentSurface, t)!,
      accentSurfacePressed:
          Color.lerp(accentSurfacePressed, other.accentSurfacePressed, t)!,
      onAccentSurface: Color.lerp(onAccentSurface, other.onAccentSurface, t)!,
      accentSubtle: Color.lerp(accentSubtle, other.accentSubtle, t)!,
      onAccentSubtle: Color.lerp(onAccentSubtle, other.onAccentSubtle, t)!,
      focusRing: Color.lerp(focusRing, other.focusRing, t)!,
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successContainer:
          Color.lerp(successContainer, other.successContainer, t)!,
      onSuccessContainer:
          Color.lerp(onSuccessContainer, other.onSuccessContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      warningContainer:
          Color.lerp(warningContainer, other.warningContainer, t)!,
      onWarningContainer:
          Color.lerp(onWarningContainer, other.onWarningContainer, t)!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      onInfoContainer: Color.lerp(onInfoContainer, other.onInfoContainer, t)!,
      moneySurface: Color.lerp(moneySurface, other.moneySurface, t)!,
      onMoneySurface: Color.lerp(onMoneySurface, other.onMoneySurface, t)!,
      moneyAccent: Color.lerp(moneyAccent, other.moneyAccent, t)!,
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
