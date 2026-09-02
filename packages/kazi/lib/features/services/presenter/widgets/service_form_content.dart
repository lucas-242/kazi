import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:kazi/core/constants/form_keys.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/core/services/domain/analytics_event.dart';
import 'package:kazi/core/widgets/tap_probe.dart';
import 'package:kazi/injector.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/presenter/controllers/service_form_controller.dart';
import 'package:kazi/features/services/presenter/controllers/service_form_state.dart';
import 'package:kazi/features/services/presenter/widgets/add_client_sheet.dart';
import 'package:kazi/features/services/presenter/widgets/add_catalog_item_sheet.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

class ServiceFormContent extends ConsumerStatefulWidget {
  const ServiceFormContent({
    super.key,
    required this.service,
    required this.onConfirm,
    this.isCreating = true,
  });
  final Service? service;
  final Function() onConfirm;
  final bool isCreating;

  @override
  ConsumerState<ServiceFormContent> createState() => _ServiceFormContentState();
}

class _ServiceFormContentState extends ConsumerState<ServiceFormContent> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionKey = GlobalKey<FormFieldState>();
  final _dateKey = GlobalKey<FormFieldState>();
  final _dropdownKey = GlobalKey<FormFieldState>();
  final _valueKey = GlobalKey<FormFieldState>();
  final _quantityKey = GlobalKey<FormFieldState>();
  final _commissionKey = GlobalKey<FormFieldState>();

  TextEditingController? _quantityController;
  MoneyMaskedTextController? _valueController;
  MoneyMaskedTextController? _commissionController;
  MaskedTextController? _dateController;

  SupportedCurrency _valueCurrency = SupportedCurrency.usd;

  bool _didInitControllers = false;

  void _initControllers(ServiceFormState state) {
    _quantityController = TextEditingController(
      text: state.quantity.toString(),
    );
    _dateController = MaskedTextController(
      text: DateFormat.yMd().format(state.service.date).normalizeDate(),
      mask: '00/00/0000',
    );
    _valueCurrency = SupportedCurrency.fromCode(
      state.service.currency,
      fallback: ref.read(kaziDefaultCurrencyProvider),
    );
    _valueController = _buildValueController(
      _valueCurrency,
      state.service.value,
    );
    _commissionController = MoneyMaskedTextController(
      // Effective, not raw: a legacy service shows the share it always paid
      // out, and one with nothing configured shows the full 100%.
      initialValue: state.service.effectiveCommissionPercent,
      decimalSeparator: NumberFormatUtils.getDecimalSeparator(),
      thousandSeparator: NumberFormatUtils.getThousandSeparator(),
      rightSymbol: '%',
      precision: 1,
    );
  }

  MoneyMaskedTextController _buildValueController(
    SupportedCurrency currency,
    double initialValue,
  ) {
    return MoneyMaskedTextController(
      initialValue: initialValue,
      leftSymbol: '${currency.symbol} ',
      decimalSeparator: NumberFormatUtils.getDecimalSeparator(),
      thousandSeparator: NumberFormatUtils.getThousandSeparator(),
      precision: currency.decimalDigits,
    );
  }

  List<DropdownItem> get _currencyItems => SupportedCurrency.values
      .map(
        (c) => DropdownItem(
          value: c.isoCode,
          label: '${c.isoCode} (${c.symbol})',
          searchTerms: c.localizedName,
        ),
      )
      .toList();

  Future<void> _onChangeCurrency(DropdownItem? item) async {
    if (item == null) return;
    final currency = SupportedCurrency.fromCode(item.value);
    if (currency == _valueCurrency) return;

    final fromCurrency = _valueCurrency;
    final provider = serviceFormControllerProvider(service: widget.service);
    final current = ref.read(provider).asData?.value;
    if (current == null) return;

    final catalogItem = current.catalogItems
        .where((item) => item.id == current.service.catalogItemId)
        .firstOrNull;
    final originalCurrency = SupportedCurrency.fromCode(
      catalogItem?.currency ?? '',
      fallback: ref.read(kaziDefaultCurrencyProvider),
    );

    final double? newValue;
    if (currency == originalCurrency && catalogItem?.defaultValue != null) {
      // Back to the item's own currency: restore its saved value exactly,
      // sidestepping the drift a round-trip conversion would introduce.
      newValue = catalogItem!.defaultValue!;
    } else {
      newValue = await _convertValue(
        _valueController?.numberValue ?? 0,
        from: fromCurrency,
        to: currency,
      );
    }

    if (!mounted) return;

    if (newValue == null) {
      // Without a rate this would relabel the typed amount as another
      // currency, so the switch is refused. Reported because it is the only
      // user-visible failure in the exchange-rate path — see README.md.
      unawaited(
        ref
            .read(analyticsServiceProvider)
            .log(
              AnalyticsEvent.formCurrencySwitchRefused,
              parameters: {'from': fromCurrency.name, 'to': currency.name},
            ),
      );
      KaziSnackbar.show(context, KaziLocalizations.current.ratesUnavailable);
      return;
    }

    final convertedValue = newValue;
    ref.read(provider.notifier).onChangeServiceCurrency(currency);
    ref.read(provider.notifier).onChangeServiceValue(convertedValue);

    _valueController?.dispose();
    if (!mounted) return;
    setState(() {
      _valueCurrency = currency;
      _valueController = _buildValueController(currency, convertedValue);
    });
  }

  /// Null when no rate is available, so the caller can refuse to relabel the
  /// amount instead of showing it under the wrong currency.
  Future<double?> _convertValue(
    double value, {
    required SupportedCurrency from,
    required SupportedCurrency to,
  }) async {
    try {
      final rates = await ref.read(exchangeRatesProvider.future);
      if (rates == null) return null;

      return CurrencyConverter.convert(
        value: value,
        from: from,
        to: to,
        rates: rates,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _quantityController?.dispose();
    _valueController?.dispose();
    _commissionController?.dispose();
    _dateController?.dispose();
    super.dispose();
  }

  void _onChangedDropdownItem(DropdownItem? data) {
    final provider = serviceFormControllerProvider(service: widget.service);
    final controller = ref.read(provider.notifier);
    if (data != null) {
      controller.onChangeCatalogItem(data);
      final current = ref.read(provider).asData?.value;
      if (current != null) {
        final currency = SupportedCurrency.fromCode(
          current.service.currency,
          fallback: ref.read(kaziDefaultCurrencyProvider),
        );
        _commissionController?.updateValue(
          current.service.effectiveCommissionPercent,
        );
        if (currency != _valueCurrency) {
          _valueController?.dispose();
          setState(() {
            _valueCurrency = currency;
            _valueController = _buildValueController(
              currency,
              current.service.value,
            );
          });
        } else {
          _valueController?.updateValue(current.service.value);
        }
      }
    }
  }

  Future<void> _onAddCatalogItem() async {
    await KaziNavigator.showBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (_) => AddCatalogItemSheet(service: widget.service),
    );
    if (!mounted) return;
    // Quick-add auto-selects the new item, so mirror its value and commission
    // into the money controllers, as _onChangedDropdownItem does.
    final provider = serviceFormControllerProvider(service: widget.service);
    final current = ref.read(provider).asData?.value;
    if (current != null) {
      _valueController?.updateValue(current.service.value);
      _commissionController?.updateValue(
        current.service.effectiveCommissionPercent,
      );
    }
  }

  void _onAddClient() {
    KaziNavigator.showBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (_) => AddClientSheet(service: widget.service),
    );
  }

  /// Midnight [days] ago, which is the shape a date-only service is stored
  /// in — the chips must not stamp the current time onto it.
  DateTime _dayAgo(int days) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day - days);
  }

  void _onChangeDate(DateTime date) {
    final provider = serviceFormControllerProvider(service: widget.service);
    ref.read(provider.notifier).onChangeServiceDate(date);
    _dateController?.text = DateFormat.yMd().format(date).normalizeDate();
  }

  void _onConfirm() {
    if (_formKey.currentState!.validate()) {
      widget.onConfirm();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = serviceFormControllerProvider(service: widget.service);
    final asyncState = ref.watch(provider);
    final state = asyncState.asData?.value;

    if (state != null && !_didInitControllers) {
      _didInitControllers = true;
      _initControllers(state);
    }

    if (state == null ||
        _quantityController == null ||
        _valueController == null ||
        _commissionController == null ||
        _dateController == null) {
      return const KaziLoading();
    }

    final controller = ref.read(provider.notifier);
    final isSaving = state.status == BaseStateStatus.loading;

    return Form(
      key: _formKey,
      // Read-only and still visible: no dark veil over the screen, because the
      // person has to keep seeing what they typed while it saves.
      child: AbsorbPointer(
        absorbing: isSaving,
        child: Column(
          children: [
            Column(
              children: [
                KaziFieldLabel(KaziLocalizations.current.catalogItem),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: KaziDropdown(
                          key: _dropdownKey,
                          label: KaziLocalizations.current.catalogItem,
                          searchLabel: KaziLocalizations.current.search,
                          hint: KaziLocalizations.current.selectCatalogItem,
                          noResultsLabel: KaziLocalizations.current.noResults,
                          showSeach: true,
                          items: state.dropdownItems,
                          selectedItem: state.selectedDropdownItem,
                          onChanged: _onChangedDropdownItem,
                          validator: (value) =>
                              FormValidator.validateDropdownField(
                                value,
                                KaziLocalizations.current.catalogItem,
                              ),
                        ),
                      ),
                      _FieldAddButton(onTap: _onAddCatalogItem),
                    ],
                  ),
                ),
                _FieldHint(KaziLocalizations.current.catalogItemFormHint),
                KaziSpacings.verticalMd,
                KaziFieldLabel(KaziLocalizations.current.client),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: KaziDropdown(
                          label: KaziLocalizations.current.client,
                          searchLabel: KaziLocalizations.current.search,
                          hint: KaziLocalizations.current.selectClient,
                          noResultsLabel: KaziLocalizations.current.noResults,
                          showSeach: true,
                          items: state.clientDropdownItems,
                          selectedItem: state.selectedClientDropdownItem,
                          onChanged: controller.onChangeClient,
                        ),
                      ),
                      _FieldAddButton(onTap: _onAddClient),
                    ],
                  ),
                ),
                _FieldHint(KaziLocalizations.current.clientFormHint),
                if (state.service.catalogItemId.isNotEmpty)
                  Column(
                    children: [
                      KaziSpacings.verticalLg,
                      KaziFieldLabel(KaziLocalizations.current.currency),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: KaziDropdown(
                          label: KaziLocalizations.current.currency,
                          hint: KaziLocalizations.current.selectCurrency,
                          showSeach: true,
                          searchLabel: KaziLocalizations.current.search,
                          noResultsLabel: KaziLocalizations.current.noResults,
                          items: _currencyItems,
                          selectedItem: DropdownItem(
                            value: _valueCurrency.isoCode,
                            label:
                                '${_valueCurrency.isoCode} '
                                '(${_valueCurrency.symbol})',
                          ),
                          onChanged: _onChangeCurrency,
                        ),
                      ),
                      KaziSpacings.verticalLg,
                      // Side by side, because they are one decision: the two
                      // numbers only mean anything against each other, and the
                      // line under them is their answer.
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                KaziFieldLabel(KaziLocalizations.current.total),
                                KaziTextFormField(
                                  textFormKey: _valueKey,
                                  controller: _valueController!,
                                  labelText: KaziLocalizations.current.total,
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) =>
                                      controller.onChangeServiceValue(
                                        _valueController!.numberValue,
                                      ),
                                  validator: (value) =>
                                      FormValidator.validateNumberField(
                                        _valueController!.numberValue
                                            .toString(),
                                        KaziLocalizations.current.total,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          KaziSpacings.horizontalSm,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                KaziFieldLabel(
                                  KaziLocalizations.current.commission,
                                ),
                                KaziTextFormField(
                                  textFormKey: _commissionKey,
                                  controller: _commissionController!,
                                  labelText:
                                      KaziLocalizations.current.commission,
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) =>
                                      controller.onChangeServiceCommission(
                                        _commissionController!.numberValue,
                                      ),
                                  validator: (value) =>
                                      FormValidator.validateNumberField(
                                        _commissionController!.numberValue
                                            .toString(),
                                        KaziLocalizations.current.commission,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      _EarningsHint(
                        value: state.service.commissionValue,
                        currency: _valueCurrency,
                      ),
                    ],
                  ),
              ],
            ),
            KaziSpacings.verticalLg,
            Column(
              children: [
                KaziFieldLabel(KaziLocalizations.current.date),
                _DateChips(
                  selected: state.service.date,
                  onToday: () => _onChangeDate(_dayAgo(0)),
                  onYesterday: () => _onChangeDate(_dayAgo(1)),
                ),
                KaziSpacings.verticalSm,
                KaziDatePicker(
                  label: KaziLocalizations.current.pickDate,
                  key: _dateKey,
                  controller: _dateController!,
                  onChange: _onChangeDate,
                  validator: (value) => FormValidator.validateTextField(
                    value,
                    KaziLocalizations.current.date,
                  ),
                  firstDate: FormKeys.formStartDate,
                  lastDate: FormKeys.formEndDate,
                ),
                if (widget.isCreating && state.service.catalogItemId.isNotEmpty)
                  Column(
                    children: [
                      KaziSpacings.verticalLg,
                      KaziFieldLabel(KaziLocalizations.current.quantity),
                      KaziTextFormField(
                        textFormKey: _quantityKey,
                        controller: _quantityController!,
                        labelText: KaziLocalizations.current.quantity,
                        keyboardType: TextInputType.number,
                        onChanged: (value) =>
                            controller.onChangeServicesQuantity(value),
                        validator: (value) => FormValidator.validateNumberField(
                          value,
                          KaziLocalizations.current.quantity,
                        ),
                      ),
                    ],
                  ),
                KaziSpacings.verticalLg,
                KaziFieldLabel(KaziLocalizations.current.description),
                KaziTextFormField(
                  textFormKey: _descriptionKey,
                  labelText: KaziLocalizations.current.description,
                  initialValue: state.service.description,
                  onChanged: (value) =>
                      controller.onChangeServiceDescription(value),
                ),
              ],
            ),
            KaziSpacings.verticalXLg,
            TapProbe(
              target: 'save_service',
              child: KaziPillButton(
                // Null while the write is in flight: a second tap would register
                // the service twice if the first one is slow.
                onTap: isSaving ? null : _onConfirm,
                fillWidth: true,
                child: Text(
                  isSaving
                      ? KaziLocalizations.current.saving
                      : KaziLocalizations.current.save,
                ),
              ),
            ),
            KaziSpacings.verticalXLg,
          ],
        ),
      ),
    );
  }
}

/// "+ Novo" beside a picker, which creates the thing the picker could not
/// offer. A labelled pill and not a bare plus: the icon alone left the person
/// guessing what it would add, on a screen with two of them.
class _FieldAddButton extends StatelessWidget {
  const _FieldAddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(left: KaziInsets.xs),
      child: Material(
        color: colors.brand.fill,
        borderRadius: KaziRadii.xsBorder,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: KaziInsets.sm),
            child: Center(
              child: Text(
                KaziLocalizations.current.newShort,
                style: KaziTextStyles.labelLarge.copyWith(
                  color: colors.brand.onFill,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The sentence under a field that says what the field is for. Part of the
/// control, not a footnote to it.
class _FieldHint extends StatelessWidget {
  const _FieldHint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: KaziInsets.xs),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          text,
          style: KaziTextStyles.labelSmall.copyWith(
            color: context.colors.textMuted,
          ),
        ),
      ),
    );
  }
}

/// What the two fields above it come to. Amber, so the answer reads as the
/// consequence of the numbers rather than as another field.
class _EarningsHint extends StatelessWidget {
  const _EarningsHint({required this.value, required this.currency});

  final double value;
  final SupportedCurrency currency;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: KaziInsets.xs),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          KaziLocalizations.current.yoursFromThis(
            NumberFormatUtils.formatCurrencyIn(value, currency),
          ),
          style: KaziTextStyles.labelLarge.copyWith(
            color: context.colors.brand.text,
          ),
        ),
      ),
    );
  }
}

/// The two dates that cover almost every registration, one tap each. Anything
/// else goes through the picker below them.
class _DateChips extends StatelessWidget {
  const _DateChips({
    required this.selected,
    required this.onToday,
    required this.onYesterday,
  });

  final DateTime selected;
  final VoidCallback onToday;
  final VoidCallback onYesterday;

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Padding(
      padding: const EdgeInsets.only(top: KaziInsets.xs),
      child: Row(
        spacing: KaziInsets.xs,
        children: [
          KaziChip(
            label: KaziLocalizations.current.today,
            isSelected: _isSameDay(selected, now),
            onTap: onToday,
          ),
          KaziChip(
            label: KaziLocalizations.current.yesterday,
            isSelected: _isSameDay(
              selected,
              now.subtract(const Duration(days: 1)),
            ),
            onTap: onYesterday,
          ),
        ],
      ),
    );
  }
}
