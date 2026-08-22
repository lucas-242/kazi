import 'package:flutter/material.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/widgets/sub_nav_bar.dart';
import 'package:kazi/features/services/presenter/controllers/catalog_controller.dart';
import 'package:kazi/features/services/presenter/widgets/catalog_item_card.dart';
import 'package:kazi/features/services/services.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;
import 'package:kazi_core/kazi_core.dart';

class CatalogContent extends ConsumerWidget {
  const CatalogContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(catalogControllerProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SubNavBar(title: KaziLocalizations.current.catalogItems),
        KaziSpacings.verticalXLg,
        Card(
          child: Padding(
            padding: const EdgeInsets.only(
              left: KaziInsets.lg,
              right: KaziInsets.lg,
              top: KaziInsets.xs,
              bottom: KaziInsets.sm,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.catalogItems.length,
              itemBuilder: (context, index) => CatalogItemCard(
                catalogItem: state.catalogItems[index],
                onTap: (catalogItem) => KaziNavigator.push(
                  AppPage.catalogItemDetails,
                  extra: CatalogItemArguments(catalogItem: catalogItem),
                ),
              ),
              separatorBuilder: (context, index) => const Divider(),
            ),
          ),
        ),
      ],
    );
  }
}
