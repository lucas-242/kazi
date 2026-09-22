import 'package:flutter/material.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// The three primary actions below the earnings card — all real destinations,
/// only one of them primary. See README.md.
class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = KaziLocalizations.current;

    return Row(
      children: [
        Expanded(
          child: KaziQuickActionButton(
            icon: LucideIcons.plus,
            label: l10n.newService,
            onTap: () => KaziNavigator.push(AppPage.addServices),
          ),
        ),
        Expanded(
          child: KaziQuickActionButton(
            icon: LucideIcons.userPlus,
            label: l10n.addClient,
            onTap: () => KaziNavigator.push(AppPage.addClient),
            isPrimary: false,
          ),
        ),
        Expanded(
          child: KaziQuickActionButton(
            icon: LucideIcons.layoutGrid,
            label: l10n.catalogItems,
            onTap: () => KaziNavigator.push(AppPage.serviceCatalog),
            isPrimary: false,
          ),
        ),
      ],
    );
  }
}
