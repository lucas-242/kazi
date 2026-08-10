import 'package:flutter/cupertino.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:kazi/features/services/presenter/controllers/service_types_controller.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
import 'package:kazi_core/kazi_core.dart';

class ServiceTypeForm extends ConsumerStatefulWidget {
  const ServiceTypeForm({super.key, required this.onConfirm});
  final void Function() onConfirm;

  @override
  ConsumerState<ServiceTypeForm> createState() =>
      _ServiceTypeFormContentState();
}

class _ServiceTypeFormContentState extends ConsumerState<ServiceTypeForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameKey = GlobalKey<FormFieldState>();
  final _serviceValueKey = GlobalKey<FormFieldState>();
  final _commissionKey = GlobalKey<FormFieldState>();
  late MoneyMaskedTextController _serviceValueController;
  late final MoneyMaskedTextController _commissionController;
  late SupportedCurrency _currency;

  @override
  void initState() {
    final serviceType = ref.read(serviceTypesControllerProvider).serviceType;
    _currency = SupportedCurrency.fromCode(
      serviceType.currency,
      fallback: ref.read(kaziDefaultCurrencyProvider),
    );
    _serviceValueController = _buildValueController(
      _currency,
      serviceType.defaultValue ?? 0,
    );
    _commissionController = MoneyMaskedTextController(
      initialValue: serviceType.effectiveCommissionPercent ?? 100,
      decimalSeparator: NumberFormatUtils.getDecimalSeparator(),
      thousandSeparator: NumberFormatUtils.getThousandSeparator(),
      rightSymbol: '%',
      precision: 1,
    );
    super.initState();
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

  void _onChangeCurrency(DropdownItem? item) {
    if (item == null) return;
    final currency = SupportedCurrency.fromCode(item.value);
    if (currency == _currency) return;
    ref
        .read(serviceTypesControllerProvider.notifier)
        .changeServiceTypeCurrency(currency);
    final number = _serviceValueController.numberValue;
    _serviceValueController.dispose();
    setState(() {
      _currency = currency;
      _serviceValueController = _buildValueController(currency, number);
    });
  }

  void onConfirm() {
    if (_formKey.currentState!.validate()) {
      widget.onConfirm();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(serviceTypesControllerProvider.notifier);
    final serviceType = ref.watch(serviceTypesControllerProvider).serviceType;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          Column(
            children: [
              KaziFieldLabel(KaziLocalizations.current.name),
              KaziTextFormField(
                textFormKey: _nameKey,
                labelText: KaziLocalizations.current.name,
                initialValue: serviceType.name,
                onChanged: (value) => controller.changeServiceTypeName(value),
                validator: (value) => FormValidator.validateTextField(
                  value,
                  KaziLocalizations.current.name,
                ),
              ),
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
                    value: _currency.isoCode,
                    label: '${_currency.isoCode} (${_currency.symbol})',
                  ),
                  onChanged: _onChangeCurrency,
                ),
              ),
              KaziSpacings.verticalLg,
              KaziFieldLabel(
                '${KaziLocalizations.current.color} '
                '(${KaziLocalizations.current.optional})',
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: KaziColorSwatchPicker(
                  selected: serviceType.colorAs,
                  onChanged: controller.changeServiceTypeColor,
                ),
              ),
              KaziSpacings.verticalLg,
              KaziFieldLabel(KaziLocalizations.current.serviceValue),
              KaziTextFormField(
                textFormKey: _serviceValueKey,
                labelText: KaziLocalizations.current.serviceValue,
                controller: _serviceValueController,
                keyboardType: TextInputType.number,
                onChanged: (value) => controller.changeServiceTypeDefaultValue(
                  _serviceValueController.numberValue,
                ),
                validator: (value) => FormValidator.validateNumberField(
                  _serviceValueController.numberValue.toString(),
                  KaziLocalizations.current.serviceValue,
                ),
              ),
              KaziSpacings.verticalLg,
              KaziFieldLabel(KaziLocalizations.current.commissionPercentage),
              KaziTextFormField(
                textFormKey: _commissionKey,
                controller: _commissionController,
                labelText: KaziLocalizations.current.commissionPercentage,
                keyboardType: TextInputType.number,
                onChanged: (value) =>
                    controller.changeServiceTypeCommissionPercent(
                      _commissionController.numberValue,
                    ),
                validator: (value) => FormValidator.validateNumberField(
                  _commissionController.numberValue.toString(),
                  KaziLocalizations.current.commissionPercentage,
                ),
              ),
            ],
          ),
          KaziSpacings.verticalXLg,
          KaziPillButton(
            onTap: onConfirm,
            child: Text(KaziLocalizations.current.save),
          ),
        ],
      ),
    );
  }
}
