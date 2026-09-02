import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kazi/features/services/domain/models/receipt_filter.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_controller.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_state.dart';
import 'package:kazi/features/services/presenter/pages/service_filters_page.dart';
import 'package:kazi/features/services/presenter/widgets/service_period_l10n.dart';
import 'package:kazi/features/services/presenter/widgets/client_filter_sheet.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final gutter = (context.width - constraints.maxWidth) / 2;

        return OverflowBox(
          fit: OverflowBoxFit.deferToChild,
          maxWidth: context.width,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: gutter),
            child: Row(
              spacing: KaziInsets.xs,
              children: _chips(context, state, controller),
            ),
          ),
        );
      },
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
      onTap: () => _openPeriodSheet(context),
    ),
    for (final filter in ReceiptFilter.values)
      KaziChip(
        label: switch (filter) {
          ReceiptFilter.all => KaziLocalizations.current.allReceipts,
          ReceiptFilter.pending => KaziLocalizations.current.pendingReceipt,
          ReceiptFilter.received => KaziLocalizations.current.receivedPlural,
        },
        isSelected: state.receiptFilter == filter,
        onTap: () => controller.onChangeReceiptFilter(filter),
      ),

    if (state.filterableClients.isNotEmpty)
      KaziChip(
        label: _clientLabel(state),
        isSelected: state.clientId != null,
        onTap: () => _openClientSheet(context, state, controller),
        onClear: state.clientId == null
            ? null
            : () => controller.onSelectClient(null),
      ),
  ];
}
