import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/presenter/controllers/service_form_controller.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

/// Quick-add sheet to create a service type without leaving the service form.
/// On success the new type is appended to the form's dropdown (no refetch) and
/// auto-selected; validation/creation errors are shown as a snackbar.
class AddServiceTypeSheet extends ConsumerStatefulWidget {
  const AddServiceTypeSheet({super.key, required this.service});

  /// The service that keys the [serviceFormControllerProvider] family.
  final Service? service;

  @override
  ConsumerState<AddServiceTypeSheet> createState() =>
      _AddServiceTypeSheetState();
}

class _AddServiceTypeSheetState extends ConsumerState<AddServiceTypeSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameKey = GlobalKey<FormFieldState>();
  final _valueKey = GlobalKey<FormFieldState>();
  final _discountKey = GlobalKey<FormFieldState>();
  final _nameController = TextEditingController();
  late final MoneyMaskedTextController _valueController;
  late final MoneyMaskedTextController _discountController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _valueController = MoneyMaskedTextController(
      leftSymbol: NumberFormatUtils.getCurrencySymbol(),
      decimalSeparator: NumberFormatUtils.getDecimalSeparator(),
      thousandSeparator: NumberFormatUtils.getThousandSeparator(),
    );
    _discountController = MoneyMaskedTextController(
      decimalSeparator: NumberFormatUtils.getDecimalSeparator(),
      thousandSeparator: NumberFormatUtils.getThousandSeparator(),
      rightSymbol: '%',
      precision: 1,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _onConfirm() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final provider = serviceFormControllerProvider(service: widget.service);
    try {
      await ref
          .read(provider.notifier)
          .quickAddServiceType(
            name: _nameController.text,
            defaultValue: _valueController.numberValue,
            discountPercent: _discountController.numberValue,
          );
      if (mounted) KaziNavigator.pop();
    } on AppError catch (exception) {
      if (mounted) {
        setState(() => _saving = false);
        KaziSnackbar.show(context, exception.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        KaziSnackbar.show(context, KaziLocalizations.current.errorUnknowError);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: KaziInsets.xLg,
            left: KaziInsets.xLg,
            right: KaziInsets.xLg,
            bottom: KaziInsets.xxxLg + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  KaziLocalizations.current.newType,
                  style: KaziTextStyles.titleMd,
                ),
                KaziSpacings.verticalXLg,
                KaziFieldLabel(KaziLocalizations.current.name),
                KaziTextFormField(
                  textFormKey: _nameKey,
                  controller: _nameController,
                  labelText: KaziLocalizations.current.name,
                  validator: (value) => FormValidator.validateTextField(
                    value,
                    KaziLocalizations.current.name,
                  ),
                ),
                KaziSpacings.verticalLg,
                KaziFieldLabel(KaziLocalizations.current.serviceValue),
                KaziTextFormField(
                  textFormKey: _valueKey,
                  controller: _valueController,
                  labelText: KaziLocalizations.current.serviceValue,
                  keyboardType: TextInputType.number,
                  validator: (value) => FormValidator.validateNumberField(
                    _valueController.numberValue.toString(),
                    KaziLocalizations.current.serviceValue,
                  ),
                ),
                KaziSpacings.verticalLg,
                KaziFieldLabel(KaziLocalizations.current.discountPercentage),
                KaziTextFormField(
                  textFormKey: _discountKey,
                  controller: _discountController,
                  labelText: KaziLocalizations.current.discountPercentage,
                  keyboardType: TextInputType.number,
                  validator: (value) => FormValidator.validateNumberField(
                    _discountController.numberValue.toString(),
                    KaziLocalizations.current.discountPercentage,
                  ),
                ),
                KaziSpacings.verticalXLg,
                KaziPillButton(
                  onTap: _onConfirm,
                  child: _saving
                      ? const KaziLoading(color: KaziColors.white)
                      : Text(KaziLocalizations.current.saveType),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
