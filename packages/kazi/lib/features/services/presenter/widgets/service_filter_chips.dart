import 'package:flutter/material.dart';
import 'package:kazi/features/services/domain/models/receipt_filter.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_controller.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_state.dart';
import 'package:kazi/features/services/presenter/pages/service_filters_page.dart';
import 'package:kazi/features/services/presenter/widgets/client_filter_sheet.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
import 'package:kazi_core/kazi_core.dart';

/// The filter row under the header: period, receipt status and client.
///
/// The coarse cuts sit in the open where they can be read without a tap; the
/// fine ones stay in the bottom sheet behind the period chip. Both the list and
/// the summary sit below this row, so changing a chip moves them together.
class ServiceFilterChips extends ConsumerWidget {
  const ServiceFilterChips({
    super.key,
    required this.dateKey,
    required this.dateController,
  });

  final GlobalKey<FormFieldState<dynamic>> dateKey;
  final TextEditingController dateController;

  /// The window in the user's words. A named shortcut says its name; a hand
  /// picked range has none, so it says its dates.
  String _periodLabel(ServiceLandingState state) {
    final l10n = KaziLocalizations.current;

    return switch (state.fastSearch) {
      FastSearch.today => l10n.today,
      FastSearch.week => l10n.week,
      FastSearch.fortnight => l10n.fortnight,
      FastSearch.month => l10n.month,
      FastSearch.lastMonth => l10n.lastMonth,
      FastSearch.custom =>
        '${DateFormat.yMd().format(state.startDate).normalizeDate()} - '
            '${DateFormat.yMd().format(state.endDate).normalizeDate()}',
    };
  }

  String _clientLabel(ServiceLandingState state) {
    final selected = state.filterableClients
        .where((client) => client.id == state.clientId)
        .firstOrNull;

    return selected?.name ?? KaziLocalizations.current.client;
  }

  void _openPeriodSheet(BuildContext context) => showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) =>
        FiltersBottomSheet(dateKey: dateKey, dateController: dateController),
  );

  void _openClientSheet(
    BuildContext context,
    ServiceLandingState state,
    ServiceLandingController controller,
  ) => showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => ClientFilterSheet(
      clients: state.filterableClients,
      selectedId: state.clientId,
      onSelected: (clientId) {
        KaziNavigator.pop();
        controller.onSelectClient(clientId);
      },
    ),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(serviceLandingControllerProvider);
    final controller = ref.read(serviceLandingControllerProvider.notifier);
    final clients = state.filterableClients;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          KaziChip(
            label: _periodLabel(state),
            isSelected: true,
            onTap: () => _openPeriodSheet(context),
          ),
          KaziSpacings.horizontalXs,
          for (final filter in ReceiptFilter.values) ...[
            KaziChip(
              label: switch (filter) {
                ReceiptFilter.all => KaziLocalizations.current.allReceipts,
                ReceiptFilter.pending =>
                  KaziLocalizations.current.pendingReceipt,
                ReceiptFilter.received => KaziLocalizations.current.received,
              },
              isSelected: state.receiptFilter == filter,
              onTap: () => controller.onChangeReceiptFilter(filter),
            ),
            KaziSpacings.horizontalXs,
          ],
          // Hidden when no listed service has a client: a filter that can only
          // be opened to find it empty is noise in a row read at a glance.
          if (clients.isNotEmpty)
            KaziChip(
              label: _clientLabel(state),
              isSelected: state.clientId != null,
              onTap: () => _openClientSheet(context, state, controller),
              onClear: state.clientId == null
                  ? null
                  : () => controller.onSelectClient(null),
            ),
        ],
      ),
    );
  }
}
