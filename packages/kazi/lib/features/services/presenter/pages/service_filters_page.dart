import 'package:flutter/material.dart';
import 'package:kazi/core/constants/form_keys.dart';
import 'package:kazi/features/services/domain/models/receipt_filter.dart';
import 'package:kazi/features/services/presenter/controllers/service_filters_controller.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_controller.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;
import 'package:kazi_core/kazi_core.dart';

/// Everything that does not fit in a chip: the full period picker, status, the
/// service types and the client.
///
/// Its draft is applied on the way out, not as it is edited — which is what
/// lets the button count the result before anyone applies it blind. The count
/// is only shown when it can be trusted; see [_ApplyLabel]. See README.md.
class FiltersBottomSheet extends ConsumerStatefulWidget {
  const FiltersBottomSheet({
    super.key,
    required this.dateKey,
    required this.dateController,
  });
  final GlobalKey<FormFieldState> dateKey;
  final TextEditingController dateController;

  @override
  ConsumerState<FiltersBottomSheet> createState() => _FiltersBottomSheetState();
}

class _FiltersBottomSheetState extends ConsumerState<FiltersBottomSheet> {
  late DateTime initialStartDate;
  late DateTime initialEndDate;
  late FastSearch initialFastSearch;
  late ServiceFiltersControllerProvider _filtersProvider;

  late ReceiptFilter _receiptFilter;
  late Set<String> _catalogItemIds;
  late String? _clientId;

  @override
  void initState() {
    super.initState();
    final landingState = ref.read(serviceLandingControllerProvider);
    initialStartDate = landingState.startDate;
    initialEndDate = landingState.endDate;
    initialFastSearch = landingState.fastSearch;
    _receiptFilter = landingState.receiptFilter;
    _catalogItemIds = {...landingState.catalogItemIds};
    _clientId = landingState.clientId;
    _filtersProvider = serviceFiltersControllerProvider(
      startDate: initialStartDate,
      endDate: initialEndDate,
      fastSearch: initialFastSearch,
    );
    widget.dateController.text = _formatRange(initialStartDate, initialEndDate);
  }

  String _formatRange(DateTime start, DateTime end) =>
      '${DateFormat.yMd().format(start).normalizeDate()} - '
      '${DateFormat.yMd().format(end).normalizeDate()}';

  void _updateDateController() {
    final state = ref.read(_filtersProvider);
    widget.dateController.text = _formatRange(state.startDate, state.endDate);
  }

  void _onChangeDate(DateTimeRange range) {
    ref.read(_filtersProvider.notifier).onChangeDate(range.start, range.end);
    _updateDateController();
  }

  void _onChangeFastSearch(FastSearch selectedFastSearch) {
    ref.read(_filtersProvider.notifier).onChangeFastSearch(selectedFastSearch);
    _updateDateController();
  }

  void _onSelectCurrentCycle() {
    ref.read(_filtersProvider.notifier).onSelectCurrentCycle();
    _updateDateController();
  }

  /// Whether the draft still describes the period already in memory. When it
  /// does not, the result cannot be counted without a query — which is exactly
  /// what applying is for.
  bool get _periodIsLoaded {
    final draft = ref.read(_filtersProvider);
    final landing = ref.read(serviceLandingControllerProvider);
    return draft.startDate == landing.startDate &&
        draft.endDate == landing.endDate;
  }

  /// How many rows the draft would leave standing, over the services already
  /// fetched. Null when the period moved and the answer is not in memory.
  int? get _resultCount {
    if (!_periodIsLoaded) return null;

    return ref
        .read(serviceLandingControllerProvider)
        .services
        .where(
          (service) =>
              _receiptFilter.allows(service) &&
              (_clientId == null || service.clientId == _clientId) &&
              (_catalogItemIds.isEmpty ||
                  _catalogItemIds.contains(service.catalogItemId)),
        )
        .length;
  }

  Future<void> _onApply() async {
    final draft = ref.read(_filtersProvider);
    final controller = ref.read(serviceLandingControllerProvider.notifier);

    KaziNavigator.pop();
    controller.applySecondaryFilters(
      receiptFilter: _receiptFilter,
      catalogItemIds: _catalogItemIds,
      clientId: _clientId,
    );
    await controller.onApplyFilters(
      draft.fastSearch,
      draft.startDate,
      draft.endDate,
    );
  }

  Future<void> _onClearAll() async {
    KaziNavigator.pop();
    await ref.read(serviceLandingControllerProvider.notifier).onCleanFilters();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(_filtersProvider);
    final landing = ref.watch(serviceLandingControllerProvider);
    final count = _resultCount;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          KaziInsets.xLg,
          KaziInsets.xLg,
          KaziInsets.xLg,
          KaziInsets.xLg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  KaziLocalizations.current.filters.capitalize(),
                  style: KaziTextStyles.titleLarge,
                ),
                KaziTextButton(
                  onTap: _onClearAll,
                  child: Text(KaziLocalizations.current.clearAll),
                ),
              ],
            ),
            KaziSpacings.verticalLg,
            _Section(
              title: KaziLocalizations.current.period,
              child: Wrap(
                spacing: KaziInsets.xs,
                runSpacing: KaziInsets.xs,
                children: [
                  // First: it is the window the home reports on, and the one
                  // the bulk "mark as received" action is meant to operate on.
                  KaziChip(
                    onTap: _onSelectCurrentCycle,
                    label: KaziLocalizations.current.currentCycle,
                    isSelected: draft.isCurrentCycle,
                  ),
                  for (final search in FastSearch.values)
                    if (search != FastSearch.custom)
                      KaziChip(
                        onTap: () => _onChangeFastSearch(search),
                        label: _fastSearchLabel(search),
                        isSelected:
                            !draft.isCurrentCycle &&
                            draft.fastSearch == search,
                      ),
                ],
              ),
            ),
            KaziSpacings.verticalMd,
            KaziDateRangePicker(
              key: widget.dateKey,
              label: KaziLocalizations.current.pickDates,
              controller: widget.dateController,
              startRange: initialStartDate,
              endRange: initialEndDate,
              firstDate: FormKeys.formStartDate,
              lastDate: FormKeys.formEndDate,
              onChange: _onChangeDate,
            ),
            KaziSpacings.verticalLg,
            _Section(
              title: KaziLocalizations.current.situation,
              child: Wrap(
                spacing: KaziInsets.xs,
                runSpacing: KaziInsets.xs,
                children: [
                  for (final filter in ReceiptFilter.values)
                    KaziChip(
                      onTap: () => setState(() => _receiptFilter = filter),
                      label: _receiptLabel(filter),
                      isSelected: _receiptFilter == filter,
                    ),
                ],
              ),
            ),
            if (landing.filterableCatalogItems.isNotEmpty) ...[
              KaziSpacings.verticalLg,
              _Section(
                title: KaziLocalizations.current.serviceType,
                child: Wrap(
                  spacing: KaziInsets.xs,
                  runSpacing: KaziInsets.xs,
                  children: [
                    for (final item in landing.filterableCatalogItems)
                      KaziChip(
                        onTap: () => setState(() {
                          if (!_catalogItemIds.remove(item.id)) {
                            _catalogItemIds.add(item.id);
                          }
                        }),
                        label: '${item.name}  ${item.count}',
                        isSelected: _catalogItemIds.contains(item.id),
                      ),
                  ],
                ),
              ),
            ],
            if (landing.filterableClients.isNotEmpty) ...[
              KaziSpacings.verticalLg,
              _Section(
                title: KaziLocalizations.current.client,
                child: Wrap(
                  spacing: KaziInsets.xs,
                  runSpacing: KaziInsets.xs,
                  children: [
                    KaziChip(
                      onTap: () => setState(() => _clientId = null),
                      label: KaziLocalizations.current.allClients,
                      isSelected: _clientId == null,
                    ),
                    for (final client in landing.filterableClients)
                      KaziChip(
                        onTap: () => setState(() => _clientId = client.id),
                        label: client.name,
                        isSelected: _clientId == client.id,
                      ),
                  ],
                ),
              ),
            ],
            KaziSpacings.verticalXxxLg,
            KaziPillButton(
              onTap: _onApply,
              fillWidth: true,
              child: Text(
                count == null
                    ? KaziLocalizations.current.applyFilters
                    : KaziLocalizations.current.seeNServices(count),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fastSearchLabel(FastSearch search) => switch (search) {
    FastSearch.today => KaziLocalizations.current.today,
    FastSearch.week => KaziLocalizations.current.week,
    FastSearch.fortnight => KaziLocalizations.current.fortnight,
    FastSearch.month => KaziLocalizations.current.month,
    FastSearch.lastMonth => KaziLocalizations.current.lastMonth,
    FastSearch.custom => KaziLocalizations.current.pickDates,
  };

  String _receiptLabel(ReceiptFilter filter) => switch (filter) {
    ReceiptFilter.all => KaziLocalizations.current.allReceipts,
    ReceiptFilter.pending => KaziLocalizations.current.pendingReceipt,
    ReceiptFilter.received => KaziLocalizations.current.receivedPlural,
  };
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Upper-cased at the call site: Flutter has no text-transform.
        Text(
          title.toUpperCase(),
          style: KaziTextStyles.tag.copyWith(color: context.colors.textMuted),
        ),
        KaziSpacings.verticalSm,
        child,
      ],
    );
  }
}
