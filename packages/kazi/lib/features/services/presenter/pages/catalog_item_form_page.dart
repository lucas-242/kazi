import 'package:flutter/material.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/services/presenter/controllers/catalog_controller.dart';
import 'package:kazi/features/services/presenter/controllers/catalog_state.dart';
import 'package:kazi/features/services/presenter/widgets/catalog_item_form.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;
import 'package:kazi_core/kazi_core.dart';

class CatalogItemFormPage extends ConsumerWidget {
  const CatalogItemFormPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(catalogControllerProvider.notifier);
    final state = ref.watch(catalogControllerProvider);

    void onConfirm() {
      if (state.catalogItem.id.isEmpty) {
        controller.addCatalogItem();
      } else {
        controller.updateCatalogItem();
      }
    }

    ref.listen<CatalogState>(catalogControllerProvider, (
      previous,
      current,
    ) {
      if (previous?.status != current.status &&
          current.status == BaseStateStatus.success) {
        final wasCreating = previous?.catalogItem.id.isEmpty ?? false;
        KaziNavigator.pop();
        if (wasCreating) {
          KaziNavigator.push(AppPage.addServices);
        }
      }
    });

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        controller.eraseCatalogItem();
      },
      child: Scaffold(
        appBar: KaziAppBar(
          title: state.catalogItem.id.isEmpty
              ? KaziLocalizations.current.newCatalogItem.capitalize()
              : ('${KaziLocalizations.current.edit} ${state.catalogItem.name}')
                    .capitalize(),
        ),
        body: KaziSafeArea(child: CatalogItemForm(onConfirm: onConfirm)),
      ),
    );
  }
}
