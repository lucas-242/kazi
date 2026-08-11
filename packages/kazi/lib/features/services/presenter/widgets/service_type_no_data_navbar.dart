import 'package:flutter/material.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
import 'package:kazi_core/kazi_core.dart';

class ServiceTypeNoDataNavbar extends StatelessWidget {
  const ServiceTypeNoDataNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: KaziInsets.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            KaziLocalizations.current.serviceTypes.capitalize(),
            style: KaziTextStyles.titleMedium,
          ),
          KaziPillButton(
            onTap: () => KaziNavigator.push(AppPage.addServiceType),
            child: Text(KaziLocalizations.current.newType),
          ),
        ],
      ),
    );
  }
}
