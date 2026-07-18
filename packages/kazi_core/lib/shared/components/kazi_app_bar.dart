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
      title: Row(
        children: [
          const KaziCircularButton(
            onTap: KaziNavigator.pop,
            child: Icon(Icons.chevron_left),
          ),
          KaziSpacings.horizontalXs,
          Text(title, style: KaziTextStyles.titleLg),
        ],
      ),
      automaticallyImplyLeading: false,
      backgroundColor: KaziColors.primary,
      foregroundColor: KaziColors.white,
      actions: actions,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
