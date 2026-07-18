import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart';

class SubNavBar extends StatelessWidget {
  const SubNavBar({super.key, required this.title, this.pills});
  final String title;
  final List<Widget>? pills;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            KaziCircularButton(
              onTap: KaziNavigator.pop,
              child: const Icon(Icons.chevron_left),
            ),
            KaziSpacings.horizontalXs,
            Text(title, style: KaziTextStyles.titleMd),
          ],
        ),
        if (pills != null) Row(children: pills!),
      ],
    );
  }
}
