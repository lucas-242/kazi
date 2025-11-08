import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart';

import 'pill_button.dart';

class TitleAndPill extends StatelessWidget {
  const TitleAndPill({
    super.key,
    required this.title,
    required this.onTap,
    required this.pillText,
  });
  final VoidCallback onTap;
  final String title;
  final String pillText;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title.capitalize(),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        PillButton(onTap: onTap, child: Text(pillText)),
      ],
    );
  }
}
