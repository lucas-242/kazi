import 'package:flutter/material.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/clients/domain/models/client_entry.dart';
import 'package:kazi/features/clients/presenter/controllers/client_form_controller.dart';
import 'package:kazi/features/clients/presenter/controllers/client_form_state.dart';
import 'package:kazi_core/kazi_core.dart';

class ClientFormPage extends ConsumerStatefulWidget {
  const ClientFormPage({super.key, this.client});

  final ClientEntry? client;

  @override
  ConsumerState<ClientFormPage> createState() => _ClientFormPageState();
}

class _ClientFormPageState extends ConsumerState<ClientFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _birthDateController = TextEditingController();
  bool _didInitDate = false;

  @override
  void dispose() {
    _birthDateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) =>
      DateFormat.yMd().format(date).normalizeDate();

  void _onChangeBirthDate(ClientFormController controller, DateTime date) {
    controller.onChangeBirthDate(date);
    _birthDateController.text = _formatDate(date);
  }

  void _onSave(ClientFormController controller) {
    if (_formKey.currentState!.validate()) {
      controller.save();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = clientFormControllerProvider(client: widget.client);

    ref.listen<AsyncValue<ClientFormState>>(provider, (previous, current) {
      final previousStatus = previous?.asData?.value.status;
      final currentStatus = current.asData?.value.status;
      if (previousStatus == currentStatus) return;

      if (currentStatus == BaseStateStatus.success) {
        KaziNavigator.pop();
      } else if (currentStatus == BaseStateStatus.error) {
        final message = current.asData?.value.callbackMessage ?? '';
        if (message.isNotEmpty) {
          KaziSnackbar.show(context, message);
        }
      }
    });

    final controller = ref.read(provider.notifier);
    final asyncState = ref.watch(provider);

    return asyncState.when(
      data: (state) {
        if (!_didInitDate && state.birthDate != null) {
          _didInitDate = true;
          _birthDateController.text = _formatDate(state.birthDate!);
        }

        return Scaffold(
          appBar: KaziAppBar(
            title: state.isEditing
                ? KaziLocalizations.current.edit
                : KaziLocalizations.current.addClient,
          ),
          body: KaziSafeArea(
            isLoading: state.status == BaseStateStatus.loading,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    KaziLocalizations.current.cpfCnpj,
                    style: KaziTextStyles.sm.copyWith(color: KaziColors.grey),
                  ),
                  KaziTextFormField(
                    labelText: KaziLocalizations.current.cpfCnpj,
                    initialValue: state.identifier,
                    keyboardType: TextInputType.number,
                    onChanged: controller.onChangeIdentifier,
                    validator: (value) => FormValidator.validateTextField(
                      value,
                      KaziLocalizations.current.cpfCnpj,
                    ),
                  ),
                  KaziSpacings.verticalMd,
                  Text(
                    KaziLocalizations.current.name,
                    style: KaziTextStyles.sm.copyWith(color: KaziColors.grey),
                  ),
                  KaziTextFormField(
                    labelText: KaziLocalizations.current.name,
                    initialValue: state.name,
                    textCapitalization: TextCapitalization.words,
                    onChanged: controller.onChangeName,
                    validator: (value) => FormValidator.validateTextField(
                      value,
                      KaziLocalizations.current.name,
                    ),
                  ),
                  KaziSpacings.verticalMd,
                  Text(
                    KaziLocalizations.current.phone,
                    style: KaziTextStyles.sm.copyWith(color: KaziColors.grey),
                  ),
                  KaziTextFormField(
                    labelText: KaziLocalizations.current.phone,
                    initialValue: state.phone,
                    keyboardType: TextInputType.phone,
                    onChanged: controller.onChangePhone,
                    validator: (value) => FormValidator.validateTextField(
                      value,
                      KaziLocalizations.current.phone,
                    ),
                  ),
                  KaziSpacings.verticalMd,
                  Text(
                    KaziLocalizations.current.email,
                    style: KaziTextStyles.sm.copyWith(color: KaziColors.grey),
                  ),
                  KaziTextFormField(
                    labelText: KaziLocalizations.current.email,
                    initialValue: state.email,
                    keyboardType: TextInputType.emailAddress,
                    textCapitalization: TextCapitalization.none,
                    onChanged: controller.onChangeEmail,
                  ),
                  KaziSpacings.verticalMd,
                  Text(
                    KaziLocalizations.current.birthDate,
                    style: KaziTextStyles.sm.copyWith(color: KaziColors.grey),
                  ),
                  KaziDatePicker(
                    label: KaziLocalizations.current.birthDate,
                    controller: _birthDateController,
                    onChange: (date) => _onChangeBirthDate(controller, date),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  ),
                  KaziSpacings.verticalXLg,
                  SizedBox(
                    width: double.infinity,
                    child: KaziElevatedButton.label(
                      label: KaziLocalizations.current.save,
                      onTap: () => _onSave(controller),
                      width: double.infinity,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: KaziAppBar(title: KaziLocalizations.current.addClient),
        body: const KaziSafeArea(isLoading: true),
      ),
      error: (_, _) =>
          KaziNoData(message: KaziLocalizations.current.errorUnknowError),
    );
  }
}
