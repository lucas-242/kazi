import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kazi/core/currency/currency_providers.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/core/widgets/archived_record_tile.dart';
import 'package:kazi/features/services/domain/models/catalog_item.dart';
import 'package:kazi/features/services/presenter/controllers/archived_catalog_controller.dart';
import 'package:kazi/features/services/presenter/controllers/archived_catalog_state.dart';
import 'package:kazi/features/services/presenter/controllers/catalog_controller.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_controller.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

class ArchivedCatalogPage extends ConsumerStatefulWidget {
  const ArchivedCatalogPage({super.key});

  @override
  ConsumerState<ArchivedCatalogPage> createState() =>
      _ArchivedCatalogPageState();
}

class _ArchivedCatalogPageState extends ConsumerState<ArchivedCatalogPage> {
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(archivedCatalogControllerProvider.notifier).onInit(),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ArchivedCatalogState>(archivedCatalogControllerProvider, (
      previous,
      current,
    ) {
      if (previous?.status != current.status &&
          current.status == BaseStateStatus.error) {
        KaziSnackbar.show(context, current.callbackMessage);
      }
    });

    final counts = ref.watch(archivedCatalogControllerProvider);
    final items = ref.watch(catalogControllerProvider).archivedCatalogItems;

    // Emptying the screen leaves nothing to come back to: leave rather than
    // show an empty archive. Guarded, because build runs again before the
    // microtask lands and a second pop would take the caller's screen with it.
    if (items.isEmpty &&
        counts.status != BaseStateStatus.loading &&
        !_leaving) {
      _leaving = true;
      Future.microtask(KaziNavigator.pop);
    }

    return Scaffold(
      appBar: KaziAppBar(title: KaziLocalizations.current.archivedCatalogItems),
      body: KaziSafeArea(
        isLoading: counts.status == BaseStateStatus.loading,
        // The list is the catalogue's archive and the counts are this
        // controller's, so a refresh has to bring both back.
        onRefresh: () async {
          await ref.read(catalogControllerProvider.notifier).getCatalogItems();
          await ref.read(archivedCatalogControllerProvider.notifier).onInit();
        },
        child: ListView.separated(
          itemCount: items.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (_, _) => const Divider(),
          itemBuilder: (context, index) => _ArchivedCatalogTile(
            catalogItem: items[index],
            linkedServices: counts.countFor(items[index].id),
          ),
        ),
      ),
    );
  }
}

class _ArchivedCatalogTile extends ConsumerWidget {
  const _ArchivedCatalogTile({
    required this.catalogItem,
    required this.linkedServices,
  });

  final CatalogItem catalogItem;
  final int? linkedServices;

  /// Says why it cannot go, with the number that makes the reason concrete,
  /// and offers the way to check. Deleting an item still in use would leave its
  /// old services rendering a nameless placeholder — see core/archiving.md.
  void _explainBlocked(BuildContext context, WidgetRef ref) {
    final count = linkedServices ?? 0;
    final currency = ref.read(kaziDefaultCurrencyProvider);
    final rateBook =
        ref
            .read(dayRateBookProvider(ExchangeRates.dateKeyOf(DateTime.now())))
            .asData
            ?.value ??
        const RateBook.empty();
    final generated = catalogItem.counters.generatedIn(
      currency,
      rateBook: rateBook,
      legacyCurrency: currency,
      dateKey: ExchangeRates.dateKeyOf(DateTime.now()),
    );

    showDialog<void>(
      context: context,
      builder: (_) => KaziDialog(
        title: KaziLocalizations.current.cantDeleteTitle(catalogItem.name),
        message:
            '${KaziLocalizations.current.cantDeleteBody(count, NumberFormatUtils.formatCurrencyIn(generated.amount, currency))}'
            '\n\n${KaziLocalizations.current.cantDeleteReassurance}',
        cancelText: KaziLocalizations.current.understood,
        confirmText: KaziLocalizations.current.seeTheServices(count),
        onCancel: KaziNavigator.pop,
        onConfirm: () {
          KaziNavigator.pop();
          unawaited(
            ref
                .read(serviceLandingControllerProvider.notifier)
                .openServices(catalogItemId: catalogItem.id),
          );
          KaziNavigator.navigate(AppPage.services);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ArchivedRecordTile(
      name: catalogItem.name,
      archivedAt: catalogItem.archivedAt,
      // A catalog item is not a person, and deleting one still in use would
      // leave its old services rendering a nameless, colourless placeholder.
      // While the count is null it has not arrived yet, and not knowing is not
      // the same as knowing it is safe.
      deletable: linkedServices == 0,
      note: linkedServices == null || linkedServices == 0
          ? null
          : KaziLocalizations.current.cantDeleteLinkedServices(linkedServices!),
      deleteMessage: KaziLocalizations.current.deletePermanentlyConfirm(
        catalogItem.name,
      ),
      onRestore: () => ref
          .read(catalogControllerProvider.notifier)
          .restoreCatalogItem(catalogItem),
      onDelete: () => ref
          .read(archivedCatalogControllerProvider.notifier)
          .deleteCatalogItem(catalogItem),
      // Only once the count has arrived: not knowing is not the same as
      // knowing it is blocked.
      onBlockedDelete: linkedServices == null
          ? null
          : () => _explainBlocked(context, ref),
    );
  }
}
