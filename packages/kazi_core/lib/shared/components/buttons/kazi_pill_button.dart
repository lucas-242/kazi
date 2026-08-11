import 'package:flutter/material.dart';
import 'package:kazi_core/shared/themes/themes.dart';

class KaziPillButton extends StatelessWidget {
  const KaziPillButton({
    super.key,
    required this.onTap,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.fillWidth = false,
    this.outlinedButton = false,
    this.width,
  });
  final VoidCallback? onTap;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool fillWidth;
  final double? width;
  final bool outlinedButton;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ButtonStyle buttonStyle = ButtonStyle(
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
      minimumSize: WidgetStateProperty.all<Size>(
        fillWidth
            ? const Size.fromHeight(45)
            : width != null
                ? Size(width!, 40)
                : const Size(5, 40),
      ),
      backgroundColor: WidgetStateProperty.all<Color>(
        backgroundColor ?? colors.inverse,
      ),
      foregroundColor: WidgetStateProperty.all<Color>(
        foregroundColor ?? colors.onInverse,
      ),
      textStyle: WidgetStateProperty.all<TextStyle>(KaziTextStyles.titleSmall),
    );

    return outlinedButton
        ? OutlinedButton(
            key: key,
            onPressed: onTap,
            style: buttonStyle,
            child: child,
          )
        : ElevatedButton(
            key: key,
            onPressed: onTap,
            style: buttonStyle,
            child: child,
          );
  }
}
