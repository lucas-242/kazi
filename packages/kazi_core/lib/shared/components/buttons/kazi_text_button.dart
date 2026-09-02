import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart';

class KaziTextButton extends StatelessWidget {
  const KaziTextButton({
    super.key,
    required this.onTap,
    required this.child,
    this.color,
  });

  final VoidCallback onTap;
  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        textStyle: KaziTextStyles.titleSmall,
        foregroundColor: color,
      ),
      child: child,
    );
  }
}
