import 'package:flutter/material.dart';
import 'package:kazi/features/services/domain/models/service_status_filter.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_controller.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_state.dart';
import 'package:kazi/features/services/presenter/pages/service_filters_page.dart';
import 'package:kazi/features/services/presenter/widgets/service_period_l10n.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;
import 'package:kazi_core/kazi_core.dart';

/// The quick filters, always visible: period and status.
///
/// The period leads the row, naming the window on screen and opening the
/// filter sheet — the same string the header card below shows, because both
/// read `periodLabel`. The finer cuts — type, client, a hand-picked range —
/// live in that sheet, and surface here **only once applied**, as a chip that
/// can be cleared. That is the rule every shortcut in the app depends on: a
/// filter applied from somewhere else has to be visible and undoable from
/// where the rows are.
///
/// Both the list and the summary sit below this row, so changing a chip moves
/// them together.
class ServiceFilterChips extends ConsumerWidget {
  const ServiceFilterChips({super.key});

  String _clientLabel(ServiceLandingState state) {
    final selected = state.filterableClients
        .where((client) => client.id == state.clientId)
        .firstOrNull;

    return selected?.name ?? KaziLocalizations.current.client;
  }

  /// One name when a single type is picked, a count when several are — a chip
  /// listing five service names would push the row off the screen.
  String _catalogItemLabel(ServiceLandingState state) {
    if (state.catalogItemIds.length > 1) {
      return KaziLocalizations.current.servicesCount(
        state.catalogItemIds.length,
      );
    }

    final selected = state.filterableCatalogItems
        .where((item) => state.catalogItemIds.contains(item.id))
        .firstOrNull;

    return selected?.name ?? KaziLocalizations.current.serviceType;
  }

  void _openFiltersSheet(BuildContext context) =>
      KaziNavigator.showBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        builder: (_) => const FiltersBottomSheet(),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(serviceLandingControllerProvider);
    final controller = ref.read(serviceLandingControllerProvider.notifier);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: KaziInsets.xs,
        children: _chips(context, state, controller),
      ),
    );
  }

  List<Widget> _chips(
    BuildContext context,
    ServiceLandingState state,
    ServiceLandingController controller,
  ) => [
    KaziChip(
      label: state.periodLabel,
      isSelected: true,
      onTap: () => _openFiltersSheet(context),
    ),
    for (final filter in ServiceStatusFilter.values)
      // Cancelled gets no permanent chip: it is a corner of the history, not
      // one of the three faces of the list. Applied from the sheet, it shows
      // up here so it can be undone here — the client filter's rule.
      if (filter != ServiceStatusFilter.cancelled ||
          state.statusFilter == ServiceStatusFilter.cancelled)
        KaziChip(
          label: switch (filter) {
            ServiceStatusFilter.all => KaziLocalizations.current.allReceipts,
            ServiceStatusFilter.pending =>
              KaziLocalizations.current.pendingReceipt,
            ServiceStatusFilter.received =>
              KaziLocalizations.current.receivedPlural,
            ServiceStatusFilter.cancelled =>
              KaziLocalizations.current.cancelledPlural,
          },
          isSelected: state.statusFilter == filter,
          onTap: () => controller.onChangeStatusFilter(filter),
        ),

    // Applied elsewhere — from the sheet, from the client ranking, from a
    // shortcut — and shown here so it can be undone here.
    if (state.clientId != null)
      KaziChip(
        label: _clientLabel(state),
        isSelected: true,
        onTap: () => _openFiltersSheet(context),
        onClear: () => controller.onSelectClient(null),
      ),
    if (state.catalogItemIds.isNotEmpty)
      KaziChip(
        label: _catalogItemLabel(state),
        isSelected: true,
        onTap: () => _openFiltersSheet(context),
        onClear: () => controller.applySecondaryFilters(
          statusFilter: state.statusFilter,
          catalogItemIds: const {},
          clientId: state.clientId,
        ),
      ),
  ];
}
