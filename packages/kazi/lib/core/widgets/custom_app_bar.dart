import 'package:flutter/material.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.showOrderBy = false,
    this.onSelectedOrderBy,
  });

  final bool showOrderBy;
  final VoidCallback? onSelectedOrderBy;

  @override
  Size get preferredSize => const Size(0.0, 75.0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authServiceProvider).user;

    return AppBar(
      toolbarHeight: preferredSize.height,
      centerTitle: true,
      automaticallyImplyLeading: false,
      foregroundColor: context.colorsScheme.onSurface,
      backgroundColor: context.colorsScheme.primary,
      title: Row(
        children: [
          KaziSpacings.horizontalXs,
          TextButton(
            onPressed: () => KaziNavigator.navigate(AppPage.profile),
            child: SizedBox(
              width: 48.0,
              height: 48.0,
              child: CircleAvatar(
                backgroundImage: user?.thereIsPhoto ?? false
                    ? NetworkImage(user!.photoUrl!)
                    : null,
                backgroundColor: KaziColors.white,
                child: user == null || !user.thereIsPhoto
                    ? Text(
                        '🦆',
                        style: KaziTextStyles.titleMd.copyWith(
                          color: context.colorsScheme.surface,
                          fontWeight: FontWeight.w500,
                          fontSize: 38,
                        ),
                      )
                    : null,
              ),
            ),
          ),
          KaziSpacings.horizontalXs,
          Text(
            user?.shortName ?? '',
            style: KaziTextStyles.titleMd.copyWith(
              color: context.colorsScheme.onSurface,
              fontWeight: FontWeight.w400,
              fontSize: 18,
            ),
          ),
        ],
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: KaziSvg(KaziSvgAssets.logo),
        ),
      ],
    );
  }
}
