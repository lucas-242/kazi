import 'package:flutter/material.dart';
import 'package:kazi_core/shared/themes/themes.dart';

class KaziCircularButton extends StatelessWidget {
  const KaziCircularButton({
    super.key,
    this.onTap,
    required this.child,
    this.iconSize,
    this.showCircularIndicator = false,
    this.backgroundColor = KaziColors.black,
    this.foregroundColor = KaziColors.white,
  });
  final VoidCallback? onTap;
  final Widget child;
  final double? iconSize;
  final bool showCircularIndicator;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: child,
          onPressed: onTap,
          iconSize: iconSize,
          style: IconButton.styleFrom(
            foregroundColor: foregroundColor,
            backgroundColor: backgroundColor,
            disabledBackgroundColor: KaziColors.white.withValues(alpha: .12),
            hoverColor: backgroundColor.withValues(alpha: .08),
            focusColor: backgroundColor.withValues(alpha: .12),
            highlightColor: backgroundColor.withValues(alpha: .12),
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
