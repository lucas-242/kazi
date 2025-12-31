import 'package:flutter/material.dart';
import 'package:kazi/app/shared/extensions/extensions.dart';
import 'package:kazi/app/views/profile/widgets/language_bottom_sheet.dart';
import 'package:kazi/app/views/profile/widgets/profile_option_button.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
import 'package:kazi_core/kazi_core.dart';

class ProfileOptions extends StatelessWidget {
  const ProfileOptions({super.key, required this.onSignOut});
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileOptionButton(
          onTap: () => context.navigateTo(AppPage.servicesType),
          text: KaziLocalizations.current.serviceTypes,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: KaziInsets.lg),
          child: Divider(),
        ),
        ProfileOptionButton(
          text: KaziLocalizations.current.language,
          onTap: () => showModalBottomSheet(
            context: context,
            useRootNavigator: true,
            isScrollControlled: true,
            builder: (context) => const LanguageBottomSheet(),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: KaziInsets.lg),
          child: Divider(),
        ),
        ProfileOptionButton(
          onTap: onSignOut,
          text: KaziLocalizations.current.logout,
          textStyle: KaziTextStyles.sm.copyWith(color: KaziColors.red),
        ),
      ],
    );
  }
}
