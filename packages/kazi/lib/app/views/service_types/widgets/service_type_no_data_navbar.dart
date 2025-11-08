import 'package:flutter/material.dart';
import 'package:kazi/app/shared/extensions/extensions.dart';
import 'package:kazi/app/shared/l10n/generated/l10n.dart';
import 'package:kazi/app/shared/widgets/buttons/buttons.dart';
import 'package:kazi/app/shared/widgets/texts/texts.dart';
import 'package:kazi_core/kazi_core.dart';

class ServiceTypeNoDataNavbar extends StatelessWidget {
  const ServiceTypeNoDataNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: KaziInsets.xs),
      child: TextWithTrailing(
        text: AppLocalizations.current.serviceTypes,
        trailing: PillButton(
          onTap: () => context.navigateTo(AppPage.addServiceType),
          child: Text(AppLocalizations.current.newType),
        ),
      ),
    );
  }
}
