import 'package:flutter/material.dart';
import 'package:kazi_core/shared/components/buttons/kazi_circular_button.dart';
import 'package:kazi_core/shared/navigation/kazi_navigator.dart';
import 'package:kazi_core/shared/themes/themes.dart';

class KaziAppBar extends StatelessWidget implements PreferredSizeWidget {
  const KaziAppBar({super.key, required this.title, this.actions = const []});

  final String title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: KaziTextStyles.titleLg),
      backgroundColor: KaziColors.primary,
      foregroundColor: KaziColors.white,
      actions: actions,
      leading: const Padding(
        padding: EdgeInsets.only(left: KaziInsets.md),
        child: KaziCircularButton(
          onTap: KaziNavigator.pop,
          child: Icon(Icons.chevron_left),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
