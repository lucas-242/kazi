import 'package:flutter/material.dart';
import 'package:kazi/app/shared/extensions/extensions.dart';
import 'package:kazi/app/views/profile/widgets/option_button.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
import 'package:kazi_core/kazi_core.dart';

class Options extends StatelessWidget {
  const Options({super.key, required this.onSignOut});
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OptionButton(
          onTap: () => context.navigateTo(AppPage.servicesType),
          text: KaziLocalizations.current.serviceTypes,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: KaziInsets.lg),
          child: Divider(),
        ),
        OptionButton(
          onTap: onSignOut,
          text: KaziLocalizations.current.logout,
          textStyle: KaziTextStyles.sm.copyWith(color: KaziColors.red),
        ),
      ],
    );
  }
}
