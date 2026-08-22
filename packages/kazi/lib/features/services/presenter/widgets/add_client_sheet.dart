import 'package:flutter/material.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/presenter/controllers/service_form_controller.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// Quick-add sheet to create a client without leaving the service form. Only
/// the required fields are asked (CPF/CNPJ, name, phone). On success the new
/// client is appended to the form's dropdown (no refetch) and auto-selected;
/// validation/creation errors are shown as a snackbar.
class AddClientSheet extends ConsumerStatefulWidget {
  const AddClientSheet({super.key, required this.service});

  /// The service that keys the [serviceFormControllerProvider] family.
  final Service? service;

  @override
  ConsumerState<AddClientSheet> createState() => _AddClientSheetState();
}

class _AddClientSheetState extends ConsumerState<AddClientSheet> {
  final _formKey = GlobalKey<FormState>();
  final _identifierKey = GlobalKey<FormFieldState>();
  final _nameKey = GlobalKey<FormFieldState>();
  final _phoneKey = GlobalKey<FormFieldState>();
  final _identifierController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _onConfirm() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final provider = serviceFormControllerProvider(service: widget.service);
    try {
      await ref
          .read(provider.notifier)
          .quickAddClient(
            identifier: _identifierController.text,
            name: _nameController.text,
            phone: _phoneController.text,
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
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    KaziLocalizations.current.newClient,
                    style: KaziTextStyles.titleMedium,
                  ),
                ),
                KaziSpacings.verticalXLg,
                KaziFieldLabel(KaziLocalizations.current.cpfCnpj),
                KaziTextFormField(
                  textFormKey: _identifierKey,
                  controller: _identifierController,
                  labelText: KaziLocalizations.current.cpfCnpj,
                  keyboardType: TextInputType.number,
                  validator: (value) => FormValidator.validateTextField(
                    value,
                    KaziLocalizations.current.cpfCnpj,
                  ),
                ),
                KaziSpacings.verticalLg,
                KaziFieldLabel(KaziLocalizations.current.name),
                KaziTextFormField(
                  textFormKey: _nameKey,
                  controller: _nameController,
                  labelText: KaziLocalizations.current.name,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) => FormValidator.validateTextField(
                    value,
                    KaziLocalizations.current.name,
                  ),
                ),
                KaziSpacings.verticalLg,
                KaziFieldLabel(KaziLocalizations.current.phone),
                KaziTextFormField(
                  textFormKey: _phoneKey,
                  controller: _phoneController,
                  labelText: KaziLocalizations.current.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) => FormValidator.validateTextField(
                    value,
                    KaziLocalizations.current.phone,
                  ),
                ),
                KaziSpacings.verticalXLg,
                KaziPillButton(
                  onTap: _onConfirm,
                  child: _saving
                      ? KaziLoading(
                          color: context.colors.onInverse,
                        )
                      : Text(KaziLocalizations.current.save),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
