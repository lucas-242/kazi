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
  final _discountKey = GlobalKey<FormFieldState>();
  late MoneyMaskedTextController _serviceValueController;
  late final MoneyMaskedTextController _discountController;
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
    _discountController = MoneyMaskedTextController(
      initialValue: serviceType.discountPercent ?? 0,
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
      .map((c) => DropdownItem(value: c.isoCode, label: '${c.isoCode} (${c.symbol})'))
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
              KaziTextFormField(
                textFormKey: _discountKey,
                controller: _discountController,
                labelText: KaziLocalizations.current.discountPercentage,
                keyboardType: TextInputType.number,
                onChanged: (value) =>
                    controller.changeServiceTypeDiscountPercent(
                      _discountController.numberValue,
                    ),
                validator: (value) => FormValidator.validateNumberField(
                  _discountController.numberValue.toString(),
                  KaziLocalizations.current.discountPercentage,
                ),
              ),
            ],
          ),
          KaziSpacings.verticalXLg,
          KaziPillButton(
            onTap: onConfirm,
            child: Text(KaziLocalizations.current.saveType),
          ),
        ],
      ),
    );
  }
}
