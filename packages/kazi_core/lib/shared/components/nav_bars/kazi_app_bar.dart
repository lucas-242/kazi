import 'package:flutter/material.dart';
import 'package:kazi_core/shared/components/buttons/kazi_back_button.dart';
import 'package:kazi_core/shared/themes/themes.dart';

class KaziAppBar extends StatelessWidget implements PreferredSizeWidget {
  const KaziAppBar({super.key, required this.title, this.actions = const []});

  static const double _dividerHeight = 1.0;

  final String title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          const KaziBackButton(),
          KaziSpacings.horizontalXs,
          Flexible(
            child: Text(
              title,
              style: KaziTextStyles.titleLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      automaticallyImplyLeading: false,
      // Colours come from `appBarTheme`: a surface-coloured bar with graphite
      // ink. The old yellow bar with white ink was 1.7:1, which the brandbook
      // rules out explicitly — yellow is a surface, and never carries white.
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(_dividerHeight),
        child: Divider(height: _dividerHeight, color: context.colors.border),
      ),
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight + _dividerHeight);
}
