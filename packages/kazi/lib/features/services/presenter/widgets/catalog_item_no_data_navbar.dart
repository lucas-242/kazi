import 'package:flutter/material.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;
import 'package:kazi_core/kazi_core.dart';

class CatalogItemNoDataNavbar extends StatelessWidget {
  const CatalogItemNoDataNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: KaziInsets.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            KaziLocalizations.current.catalogItems.capitalize(),
            style: KaziTextStyles.titleMedium,
          ),
          KaziPillButton(
            onTap: () => KaziNavigator.push(AppPage.addCatalogItem),
            child: Text(KaziLocalizations.current.newCatalogItem),
          ),
        ],
      ),
    );
  }
}
