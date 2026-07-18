import 'package:flutter/cupertino.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:kazi/features/services/presenter/controllers/service_types_controller.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
import 'package:kazi_core/kazi_core.dart';

class ServiceTypeFormContent extends ConsumerStatefulWidget {
  const ServiceTypeFormContent({super.key, required this.onConfirm});
  final void Function() onConfirm;

  @override
  ConsumerState<ServiceTypeFormContent> createState() =>
      _ServiceTypeFormContentState();
}

class _ServiceTypeFormContentState
    extends ConsumerState<ServiceTypeFormContent> {
  final _formKey = GlobalKey<FormState>();
  final _nameKey = GlobalKey<FormFieldState>();
  final _serviceValueKey = GlobalKey<FormFieldState>();
  final _discountKey = GlobalKey<FormFieldState>();
  late final MoneyMaskedTextController _serviceValueController;
  late final MoneyMaskedTextController _discountController;

  @override
  void initState() {
    final serviceType = ref.read(serviceTypesControllerProvider).serviceType;
    _serviceValueController = MoneyMaskedTextController(
      initialValue: serviceType.defaultValue ?? 0,
      leftSymbol: NumberFormatUtils.getCurrencySymbol(),
      decimalSeparator: NumberFormatUtils.getDecimalSeparator(),
      thousandSeparator: NumberFormatUtils.getThousandSeparator(),
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
      child: Padding(
        padding: const EdgeInsets.only(top: KaziInsets.lg),
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
                KaziTextFormField(
                  textFormKey: _serviceValueKey,
                  labelText: KaziLocalizations.current.serviceValue,
                  controller: _serviceValueController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) =>
                      controller.changeServiceTypeDefaultValue(
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
      ),
    );
  }
}
