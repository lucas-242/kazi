import 'package:flutter/material.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/core/widgets/archived_entry_tile.dart';
import 'package:kazi/features/services/presenter/controllers/catalog_controller.dart';
import 'package:kazi/features/services/presenter/controllers/catalog_state.dart';
import 'package:kazi/features/services/presenter/widgets/catalog_item_no_data_navbar.dart';
import 'package:kazi/features/services/presenter/widgets/catalog_content.dart';
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
    ref.listen<CatalogState>(catalogControllerProvider, (
      previous,
      current,
    ) {
      if (previous?.status != current.status &&
          current.status == BaseStateStatus.error) {
        KaziSnackbar.show(context, current.callbackMessage);
      }
    });

    final state = ref.watch(catalogControllerProvider);

    return Scaffold(
      body: KaziSafeArea(
        isLoading: state.status == BaseStateStatus.loading,
        onRefresh: () =>
            ref.read(catalogControllerProvider.notifier).getCatalogItems(),
        child: state.when(
          onState: (_) => const CatalogContent(),
          onLoading: () => state.catalogItems.isEmpty
              ? const SizedBox.shrink()
              : const CatalogContent(),
          onNoData: () => Column(
            children: [
              Expanded(
                child: KaziNoData(
                  message: KaziLocalizations.current.noCatalogItems,
                  navbar: const CatalogItemNoDataNavbar(),
                ),
              ),
              ArchivedEntryTile(
                count: state.archivedCount,
                onTap: () => KaziNavigator.push(AppPage.archivedCatalogItems),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
