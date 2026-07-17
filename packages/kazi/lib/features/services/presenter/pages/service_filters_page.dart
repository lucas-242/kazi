import 'package:flutter/material.dart';
import 'package:kazi/core/constants/form_keys.dart';
import 'package:kazi/core/widgets/buttons/buttons.dart';
import 'package:kazi/core/widgets/texts/texts.dart';
import 'package:kazi/features/services/presenter/controllers/service_filters_controller.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_controller.dart';
import 'package:kazi/features/services/presenter/widgets/selectable_pill_button.dart';
import 'package:kazi_core/kazi_core.dart';

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

  @override
  void initState() {
    super.initState();
    final landingState = ref.read(serviceLandingControllerProvider);
    initialStartDate = landingState.startDate;
    initialEndDate = landingState.endDate;
    initialFastSearch = landingState.fastSearch;
    _filtersProvider = serviceFiltersControllerProvider(
      startDate: initialStartDate,
      endDate: initialEndDate,
      fastSearch: initialFastSearch,
    );
    widget.dateController.text =
        '${DateFormat.yMd().format(initialStartDate).normalizeDate()} - ${DateFormat.yMd().format(initialEndDate).normalizeDate()}';
  }

  void _updateDateController() {
    final state = ref.read(_filtersProvider);
    widget.dateController.text =
        '${DateFormat.yMd().format(state.startDate).normalizeDate()} - ${DateFormat.yMd().format(state.endDate).normalizeDate()}';
  }

  void _onChangeDate(DateTimeRange range) {
    ref.read(_filtersProvider.notifier).onChangeDate(range.start, range.end);
    _updateDateController();
  }

  void _onChangeFastSearch(FastSearch selectedFastSearch) {
    ref.read(_filtersProvider.notifier).onChangeFastSearch(selectedFastSearch);
    _updateDateController();
  }

  Future<void> _onApplyFilters() async {
    final state = ref.read(_filtersProvider);
    final landingController = ref.read(
      serviceLandingControllerProvider.notifier,
    );
    KaziNavigator.pop();
    await landingController.onApplyFilters(
      state.fastSearch,
      state.startDate,
      state.endDate,
    );
  }

  Future<void> _onCleanFilters() async {
    final landingController = ref.read(
      serviceLandingControllerProvider.notifier,
    );
    KaziNavigator.pop();
    await landingController.onCleanFilters();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(_filtersProvider);

    return Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: KaziInsets.xLg,
            left: KaziInsets.xLg,
            right: KaziInsets.xLg,
            bottom: KaziInsets.xxxLg,
          ),
          child: Column(
            children: [
              TextWithTrailing(
                text: KaziLocalizations.current.filters,
                trailing: PillButton(
                  onTap: _onCleanFilters,
                  backgroundColor: KaziColors.grey,
                  child: Text(KaziLocalizations.current.removeFilters),
                ),
              ),
              KaziSpacings.verticalXLg,
              KaziDateRangePicker(
                key: widget.dateKey,
                label: KaziLocalizations.current.period,
                controller: widget.dateController,
                startRange: initialStartDate,
                endRange: initialEndDate,
                firstDate: FormKeys.formStartDate,
                lastDate: FormKeys.formEndDate,
                onChange: _onChangeDate,
              ),
              KaziSpacings.verticalXLg,
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  spacing: KaziInsets.sm,
                  children: [
                    SelectablePillButton(
                      onTap: () => _onChangeFastSearch(FastSearch.today),
                      text: KaziLocalizations.current.today,
                      isSelected: state.fastSearch == FastSearch.today,
                    ),
                    SelectablePillButton(
                      onTap: () => _onChangeFastSearch(FastSearch.week),
                      text: KaziLocalizations.current.week,
                      isSelected: state.fastSearch == FastSearch.week,
                    ),
                    SelectablePillButton(
                      onTap: () => _onChangeFastSearch(FastSearch.fortnight),
                      text: KaziLocalizations.current.fortnight,
                      isSelected: state.fastSearch == FastSearch.fortnight,
                    ),
                    SelectablePillButton(
                      onTap: () => _onChangeFastSearch(FastSearch.month),
                      text: KaziLocalizations.current.month,
                      isSelected: state.fastSearch == FastSearch.month,
                    ),
                    SelectablePillButton(
                      onTap: () => _onChangeFastSearch(FastSearch.lastMonth),
                      text: KaziLocalizations.current.lastMonth,
                      isSelected: state.fastSearch == FastSearch.lastMonth,
                    ),
                  ],
                ),
              ),
              KaziSpacings.verticalXxxLg,
              PillButton(
                onTap: _onApplyFilters,
                child: Text(KaziLocalizations.current.applyFilters),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
