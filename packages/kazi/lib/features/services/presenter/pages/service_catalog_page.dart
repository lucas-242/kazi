import 'package:flutter/material.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/services/presenter/controllers/catalog_controller.dart';
import 'package:kazi/features/services/presenter/widgets/catalog_content.dart';
import 'package:kazi/features/services/presenter/widgets/catalog_item_no_data_navbar.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;
import 'package:kazi_core/kazi_core.dart';

class ServiceCatalogPage extends ConsumerStatefulWidget {
  const ServiceCatalogPage({super.key});

  @override
  ConsumerState<ServiceCatalogPage> createState() => _ServiceCatalogPageState();
}

class _ServiceCatalogPageState extends ConsumerState<ServiceCatalogPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(catalogControllerProvider.notifier).onInit(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(catalogControllerProvider);
    final controller = ref.read(catalogControllerProvider.notifier);
    final isEmpty = state.status == BaseStateStatus.noData;

    return Scaffold(
      body: KaziSafeArea(
        isScrollView: !isEmpty,
        onRefresh: controller.getCatalogItems,
        child: switch (state.status) {
          BaseStateStatus.loading when state.catalogItems.isEmpty => Column(
            children: const [
              CatalogItemNoDataNavbar(),
              KaziSpacings.verticalMd,
              KaziSkeletonList(),
            ],
          ),
          BaseStateStatus.error when state.catalogItems.isEmpty => Column(
            children: [
              const CatalogItemNoDataNavbar(),
              Expanded(
                child: KaziError(
                  message: state.callbackMessage,
                  onRetry: controller.getCatalogItems,
                  scrollable: true,
                ),
              ),
            ],
          ),
          BaseStateStatus.noData => Column(
            children: [
              const CatalogItemNoDataNavbar(),
              Expanded(
                child: KaziEmpty(
                  message: KaziLocalizations.current.noCatalogItems,
                  description:
                      KaziLocalizations.current.noCatalogItemsDescription,
                  scrollable: true,
                  action: KaziPillButton(
                    onTap: () => KaziNavigator.push(AppPage.addCatalogItem),
                    child: Text(KaziLocalizations.current.newCatalogItem),
                  ),
                ),
              ),
            ],
          ),
          _ => const CatalogContent(),
        },
      ),
    );
  }
}
