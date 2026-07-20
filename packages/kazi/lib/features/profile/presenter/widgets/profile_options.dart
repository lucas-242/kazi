import 'package:flutter/material.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/features/profile/presenter/widgets/language_bottom_sheet.dart';
import 'package:kazi/features/profile/presenter/widgets/profile_option_button.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

class ProfileOptions extends StatelessWidget {
  const ProfileOptions({
    super.key,
    required this.onSignOut,
    required this.onRateApp,
  });
  final VoidCallback onSignOut;
  final VoidCallback onRateApp;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileOptionButton(
          onTap: () => KaziNavigator.push(AppPage.servicesType),
          text: KaziLocalizations.current.serviceTypes,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: KaziInsets.lg),
          child: Divider(),
        ),
        ProfileOptionButton(
          onTap: () => KaziNavigator.push(AppPage.clients),
          text: KaziLocalizations.current.clients,
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
          onTap: onRateApp,
          text: KaziLocalizations.current.rateApp,
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
