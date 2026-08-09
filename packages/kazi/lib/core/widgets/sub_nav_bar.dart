import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart';

class SubNavBar extends StatelessWidget {
  const SubNavBar({
    super.key,
    required this.title,
    this.pills,
    this.showBack = true,
  });
  final String title;
  final List<Widget>? pills;

  /// Off at the root of a bottom-navigation tab, where there is nothing behind
  /// the screen to go back to.
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (showBack) ...[
              KaziCircularButton(
                onTap: KaziNavigator.pop,
                child: const Icon(Icons.chevron_left),
              ),
              KaziSpacings.horizontalXs,
            ],
            Text(title, style: KaziTextStyles.titleMd),
          ],
        ),
        if (pills != null) Row(children: pills!),
      ],
    );
  }
}
