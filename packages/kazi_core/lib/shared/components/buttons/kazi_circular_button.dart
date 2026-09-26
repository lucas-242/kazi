import 'package:flutter/material.dart';
import 'package:kazi_core/shared/themes/themes.dart';

class KaziCircularButton extends StatelessWidget {
  const KaziCircularButton({
    super.key,
    this.onTap,
    required this.child,
    this.iconSize,
    this.showCircularIndicator = false,
    this.backgroundColor,
    this.foregroundColor,
    this.semantics,
  }) : isPlain = false;

  /// Backgroundless: the icon alone, over whatever it sits on.
  ///
  /// For icons that accompany content rather than lead it — a toolbar of
  /// filters, the actions of a details screen. A filled circle there reads as
  /// a button competing with the screen's primary action, which on these
  /// screens is the yellow one that registers a service.
  const KaziCircularButton.plain({
    super.key,
    this.onTap,
    required this.child,
    this.iconSize,
    this.showCircularIndicator = false,
    this.foregroundColor,
    this.semantics,
  })  : backgroundColor = null,
        isPlain = true;

  final VoidCallback? onTap;
  final Widget child;
  final double? iconSize;
  final bool showCircularIndicator;

  /// Defaults to `colorScheme.inverseSurface` — a dark chip on light, light on
  /// dark — so the button reads against the page in both brightnesses.
  final Color? backgroundColor;

  /// Defaults to the ink that reads on [backgroundColor].
  final Color? foregroundColor;

  final bool isPlain;

  final String? semantics;

  /// The circle a plain button draws, against the 40 of a filled one.
  ///
  /// Only the circle shrinks — the icon keeps whatever size it was given. With
  /// no ground to fill, the empty ring around the icon is just space that
  /// pushes a row of these apart and away from the edge of the screen.
  ///
  /// It takes the tap target down with it, below the 48 of
  /// [KaziSizings.minTouchTarget]: these are secondary actions that sit beside
  /// content, never the primary one on a screen.
  static const double _plainDiameter = 32.0;

  static const double _indicatorDiameter = 15.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final background =
        isPlain ? Colors.transparent : backgroundColor ?? colors.inverse;
    final foreground =
        foregroundColor ?? (isPlain ? colors.text : colors.onInverse);
    // A transparent ground cannot tint itself, so the press states of a plain
    // button come from its ink instead.
    final overlay = isPlain ? foreground : background;

    return Semantics(
      value: semantics,
      button: true,
      child: Stack(
        children: [
          IconButton(
            icon: child,
            onPressed: onTap,
            iconSize: iconSize,
            style: IconButton.styleFrom(
              foregroundColor: foreground,
              backgroundColor: background,
              disabledForegroundColor: colors.textMuted,
              disabledBackgroundColor: isPlain
                  ? Colors.transparent
                  : colors.text.withValues(alpha: .12),
              hoverColor: overlay.withValues(alpha: .08),
              focusColor: overlay.withValues(alpha: .12),
              highlightColor: overlay.withValues(alpha: .12),
              padding: isPlain ? const EdgeInsets.all(KaziInsets.xxs) : null,
              minimumSize: isPlain ? const Size.square(_plainDiameter) : null,
              tapTargetSize: isPlain ? MaterialTapTargetSize.shrinkWrap : null,
            ),
          ),
          if (showCircularIndicator)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: _indicatorDiameter,
                height: _indicatorDiameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.brand.fill,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
