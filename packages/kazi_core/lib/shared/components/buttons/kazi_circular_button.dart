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
  });
  final VoidCallback? onTap;
  final Widget child;
  final double? iconSize;
  final bool showCircularIndicator;

  /// Defaults to `colorScheme.inverseSurface` — a dark chip on light, light on
  /// dark — so the button reads against the page in both brightnesses.
  final Color? backgroundColor;

  /// Defaults to the ink that reads on [backgroundColor].
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorsScheme;
    final background = backgroundColor ?? colors.inverseSurface;
    final foreground = foregroundColor ?? colors.onInverseSurface;

    return Stack(
      children: [
        IconButton(
          icon: child,
          onPressed: onTap,
          iconSize: iconSize,
          style: IconButton.styleFrom(
            foregroundColor: foreground,
            backgroundColor: background,
            disabledBackgroundColor: colors.onSurface.withValues(alpha: .12),
            hoverColor: background.withValues(alpha: .08),
            focusColor: background.withValues(alpha: .12),
            highlightColor: background.withValues(alpha: .12),
          ),
        ),
        Visibility(
          visible: showCircularIndicator,
          child: Positioned(
            top: 4,
            left: 17,
            child: SizedBox(
              height: 15,
              child: CircleAvatar(
                backgroundColor: context.colorsScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
