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
    final background = backgroundColor ?? KaziColors.white;
    final foreground = foregroundColor ?? KaziColors.graphite;

    return Material(
      color: background,
      borderRadius: KaziRadii.mdBorder,
      elevation: 1,
      shadowColor: KaziColors.graphite,
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
                  style: KaziTextStyles.titleSm.copyWith(color: foreground),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
