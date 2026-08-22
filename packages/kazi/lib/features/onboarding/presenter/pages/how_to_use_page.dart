import 'package:flutter/material.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/widgets/sub_nav_bar.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// What "review the tutorial" becomes once the setup exists.
///
/// Replaying the setup on a configured app helps nobody — the catalog is
/// already there, the currency is already chosen. What is actually useful is a
/// short list of topics that each **open the real function**, so the answer is
/// found where the work happens.
class HowToUsePage extends StatelessWidget {
  const HowToUsePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = KaziLocalizations.current;

    return Scaffold(
      body: KaziSafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SubNavBar(title: l10n.howToUseKazi),
            KaziSpacings.verticalMd,
            _Topic(
              icon: Icons.category_outlined,
              title: l10n.checklistBuildCatalog,
              message: l10n.setupCatalogSubtitle,
              destination: AppPage.serviceCatalog,
            ),
            _Topic(
              icon: Icons.bolt,
              title: l10n.hintFabTitle,
              message: l10n.hintFabBody,
              destination: AppPage.addServices,
            ),
            _Topic(
              icon: Icons.check_circle_outline,
              title: l10n.hintReceivedTitle,
              message: l10n.hintReceivedBody,
              destination: AppPage.services,
            ),
            _Topic(
              icon: Icons.insights_outlined,
              title: l10n.hintSummaryTitle,
              message: l10n.hintSummaryBody,
              destination: AppPage.services,
            ),
            _Topic(
              icon: Icons.event_repeat_outlined,
              title: l10n.billingCycle,
              message: l10n.billingCycleDescription,
              destination: AppPage.billingCycle,
            ),
          ],
        ),
      ),
    );
  }
}

class _Topic extends StatelessWidget {
  const _Topic({
    required this.icon,
    required this.title,
    required this.message,
    required this.destination,
  });

  final IconData icon;
  final String title;
  final String message;
  final AppPage destination;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ListTile(
      leading: Icon(icon, color: colors.brand.text),
      title: Text(title, style: KaziTextStyles.titleSmall),
      subtitle: Text(
        message,
        style: KaziTextStyles.bodySmall.copyWith(color: colors.textMuted),
      ),
      trailing: Icon(Icons.chevron_right, color: colors.textMuted),
      onTap: () => KaziNavigator.navigate(destination),
    );
  }
}
