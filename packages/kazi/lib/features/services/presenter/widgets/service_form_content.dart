import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:kazi/core/constants/form_keys.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/presenter/controllers/service_form_controller.dart';
import 'package:kazi/features/services/presenter/controllers/service_form_state.dart';
import 'package:kazi/features/services/presenter/widgets/add_client_sheet.dart';
import 'package:kazi/features/services/presenter/widgets/add_service_type_sheet.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

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
  final _discountKey = GlobalKey<FormFieldState>();

  TextEditingController? _quantityController;
  MoneyMaskedTextController? _valueController;
  MoneyMaskedTextController? _discountController;
  MaskedTextController? _dateController;

  bool _didInitControllers = false;

  void _initControllers(ServiceFormState state) {
    _quantityController = TextEditingController(
      text: state.quantity.toString(),
    );
    _dateController = MaskedTextController(
      text: DateFormat.yMd().format(state.service.date).normalizeDate(),
      mask: '00/00/0000',
    );
    _valueController = MoneyMaskedTextController(
      initialValue: state.service.value,
      leftSymbol: NumberFormatUtils.getCurrencySymbol(),
      decimalSeparator: NumberFormatUtils.getDecimalSeparator(),
      thousandSeparator: NumberFormatUtils.getThousandSeparator(),
    );
    _discountController = MoneyMaskedTextController(
      initialValue: state.service.discountPercent,
      decimalSeparator: NumberFormatUtils.getDecimalSeparator(),
      thousandSeparator: NumberFormatUtils.getThousandSeparator(),
      rightSymbol: '%',
      precision: 1,
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _quantityController?.dispose();
    _valueController?.dispose();
    _discountController?.dispose();
    _dateController?.dispose();
    super.dispose();
  }

  void _onChangedDropdownItem(DropdownItem? data) {
    final provider = serviceFormControllerProvider(service: widget.service);
    final controller = ref.read(provider.notifier);
    if (data != null) {
      controller.onChangeServiceType(data);
      final current = ref.read(provider).asData?.value;
      if (current != null) {
        _valueController?.updateValue(current.service.value);
        _discountController?.updateValue(current.service.discountPercent);
      }
    }
  }

  Future<void> _onAddServiceType() async {
    await KaziNavigator.showBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (_) => AddServiceTypeSheet(service: widget.service),
    );
    if (!mounted) return;
    // The quick-add auto-selects the new type with its default value/discount,
    // so mirror those into the money controllers (as _onChangedDropdownItem).
    final provider = serviceFormControllerProvider(service: widget.service);
    final current = ref.read(provider).asData?.value;
    if (current != null) {
      _valueController?.updateValue(current.service.value);
      _discountController?.updateValue(current.service.discountPercent);
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
        _discountController == null ||
        _dateController == null) {
      return const KaziLoading();
    }

    final controller = ref.read(provider.notifier);
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Column(
            children: [
              KaziFieldLabel(KaziLocalizations.current.serviceType),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: KaziDropdown(
                        key: _dropdownKey,
                        label: KaziLocalizations.current.serviceType,
                        searchLabel: KaziLocalizations.current.search,
                        hint: KaziLocalizations.current.selectServiceType,
                        noResultsLabel: KaziLocalizations.current.noResults,
                        items: state.dropdownItems,
                        selectedItem: state.selectedDropdownItem,
                        onChanged: _onChangedDropdownItem,
                        validator: (value) =>
                            FormValidator.validateDropdownField(
                              value,
                              KaziLocalizations.current.serviceType,
                            ),
                      ),
                    ),
                    _FieldAddButton(onTap: _onAddServiceType),
                  ],
                ),
              ),
              KaziSpacings.verticalLg,
              KaziFieldLabel(
                '${KaziLocalizations.current.client} '
                '(${KaziLocalizations.current.optional})',
              ),
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
              KaziSpacings.verticalLg,
              KaziFieldLabel(KaziLocalizations.current.total),
              KaziTextFormField(
                textFormKey: _valueKey,
                controller: _valueController!,
                labelText: KaziLocalizations.current.total,
                keyboardType: TextInputType.number,
                onChanged: (value) => controller.onChangeServiceValue(
                  _valueController!.numberValue,
                ),
                validator: (value) => FormValidator.validateNumberField(
                  _valueController!.numberValue.toString(),
                  KaziLocalizations.current.total,
                ),
              ),
              KaziSpacings.verticalLg,
              KaziFieldLabel(KaziLocalizations.current.discountPercentage),
              KaziTextFormField(
                textFormKey: _discountKey,
                controller: _discountController!,
                labelText: KaziLocalizations.current.discountPercentage,
                keyboardType: TextInputType.number,
                onChanged: (value) => controller.onChangeServiceDiscount(
                  _discountController!.numberValue,
                ),
                validator: (value) => FormValidator.validateNumberField(
                  _discountController!.numberValue.toString(),
                  KaziLocalizations.current.discountPercentage,
                ),
              ),
            ],
          ),
          KaziSpacings.verticalLg,
          Column(
            children: [
              KaziFieldLabel(KaziLocalizations.current.date),
              KaziDatePicker(
                label: KaziLocalizations.current.date,
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
              if (widget.isCreating)
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
          KaziPillButton(
            onTap: _onConfirm,
            child: Text(KaziLocalizations.current.saveService),
          ),
          KaziSpacings.verticalXLg,
        ],
      ),
    );
  }
}

class _FieldAddButton extends StatelessWidget {
  const _FieldAddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: KaziColors.primary,
      borderRadius: BorderRadius.circular(KaziInsets.xs),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: const SizedBox(
          width: 52,
          child: Center(child: Icon(Icons.add, color: KaziColors.white)),
        ),
      ),
    );
  }
}
