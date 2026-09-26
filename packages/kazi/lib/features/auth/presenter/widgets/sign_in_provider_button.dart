import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart';

class SignInProviderButton extends StatelessWidget {
  const SignInProviderButton({
    super.key,
    required this.onTap,
    required this.label,
    required this.icon,
    this.backgroundColor,
    this.foregroundColor,
  });

  final VoidCallback onTap;
  final String label;
  final Widget icon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    // The button sits on the brand canvas, so it needs the card surface rather
    // than a literal white — which was invisible against the dark hero.
    final background = backgroundColor ?? context.colors.card;
    final foreground = foregroundColor ?? context.colors.text;

    return Material(
      color: background,
      borderRadius: KaziRadii.mdBorder,
      elevation: 1,
      // No explicit shadow colour: Material falls back to the theme's, which is
      // graphite on light and black on dark.
      child: InkWell(
        onTap: onTap,
        borderRadius: KaziRadii.mdBorder,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            minHeight: KaziSizings.minTouchTarget,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: KaziInsets.md,
            vertical: KaziInsets.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox.square(dimension: KaziSizings.iconMd, child: icon),
              KaziSpacings.horizontalSm,
              Flexible(
                child: Text(
                  label,
                  style: KaziTextStyles.titleSmall.copyWith(color: foreground),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
