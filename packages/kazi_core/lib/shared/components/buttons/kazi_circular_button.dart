import 'package:flutter/material.dart';
import 'package:kazi_core/shared/themes/themes.dart';

class KaziCircularButton extends StatelessWidget {
  const KaziCircularButton({
    super.key,
    this.onTap,
    required this.child,
    this.iconSize,
    this.showCircularIndicator = false,
  });
  final VoidCallback? onTap;
  final Widget child;
  final double? iconSize;
  final bool showCircularIndicator;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(useMaterial3: true),
      child: Stack(
        children: [
          IconButton(
            icon: child,
            onPressed: onTap,
            iconSize: iconSize,
            style: IconButton.styleFrom(
              foregroundColor: KaziColors.white,
              backgroundColor: KaziColors.darkGrey,
              disabledBackgroundColor: KaziColors.darkGrey.withValues(
                alpha: 0.12,
              ),
              hoverColor: KaziColors.darkGrey.withValues(alpha: 0.08),
              focusColor: KaziColors.darkGrey.withValues(alpha: 0.12),
              highlightColor: KaziColors.darkGrey.withValues(alpha: 0.12),
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
      ),
    );
  }
}
