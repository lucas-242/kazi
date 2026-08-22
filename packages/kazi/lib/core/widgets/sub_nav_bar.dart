import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart';

class SubNavBar extends StatelessWidget {
  const SubNavBar({
    super.key,
    required this.title,
    this.pills,
    this.showBack = true,
    this.showDivider = true,
  });
  final String title;
  final List<Widget>? pills;

  /// Off at the root of a bottom-navigation tab, where there is nothing behind
  /// the screen to go back to.
  final bool showBack;

  /// Off where the header band continues below this row — the services tab
  /// closes it under the list/summary switch instead.
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (showBack) ...[
                  const KaziBackButton(),
                  KaziSpacings.horizontalXs,
                ],
                Text(title, style: KaziTextStyles.titleMedium),
              ],
            ),
            if (pills != null) Row(children: pills!),
          ],
        ),
        if (showDivider) const KaziBandDivider(),
      ],
    );
  }
}
