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
          Text(title, style: KaziTextStyles.titleLarge),
        ],
      ),
      automaticallyImplyLeading: false,
      // Colours come from `appBarTheme`: a surface-coloured bar with graphite
      // ink. The old yellow bar with white ink was 1.7:1, which the brandbook
      // rules out explicitly — yellow is a surface, and never carries white.
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
