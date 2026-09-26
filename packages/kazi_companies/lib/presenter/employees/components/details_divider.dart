import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart';

class DetailsDivider extends StatelessWidget {
  const DetailsDivider({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: context.width * 0.02, child: const Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: KaziInsets.sm),
          child: Text(text, style: KaziTextStyles.titleLarge),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
