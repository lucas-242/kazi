import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart';

class ProfileOptionButton extends StatelessWidget {
  const ProfileOptionButton({
    super.key,
    required this.onTap,
    required this.text,
    this.textStyle,
  });
  final VoidCallback onTap;
  final String text;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: KaziInsets.lg,
            vertical: KaziInsets.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text.capitalize(),
                  style: textStyle ?? Theme.of(context).textTheme.titleSmall,
                ),
              ),
              const Icon(Icons.chevron_right, color: KaziColors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
