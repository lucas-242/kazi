import 'package:flutter/material.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/core/widgets/tap_probe.dart';
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

  void _onSave(ClientFormController controller) {
    if (_formKey.currentState!.validate()) {
      controller.save();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = clientFormControllerProvider(client: widget.client);

    ref.listen<AsyncValue<ClientFormState>>(provider, (previous, current) {
      final namesake = current.asData?.value.namesakeWarning;
      if (namesake != null &&
          previous?.asData?.value.namesakeWarning != namesake) {
        _showNamesakeWarning(context, provider, namesake);
        return;
      }

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
        return Scaffold(
          appBar: KaziAppBar(
            title: state.isEditing
                ? KaziLocalizations.current.edit
                : KaziLocalizations.current.addClient,
          ),
          bottomNavigationBar: KaziFormFooter(
            label: KaziLocalizations.current.save,
            onTap: () => _onSave(controller),
            child: (button) => TapProbe(target: 'save_client', child: button),
          ),
          body: KaziSafeArea(
            isLoading: state.status == BaseStateStatus.loading,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  KaziFieldInput(
                    label: KaziLocalizations.current.name,
                    initialValue: state.name,
                    textCapitalization: TextCapitalization.words,
                    onChanged: controller.onChangeName,
                    validateOnFocusLost: true,
                    validator: (value) => FormValidator.validateTextField(
                      value,
                      KaziLocalizations.current.name,
                    ),
                  ),
                  KaziSpacings.verticalXs,
                  KaziFieldInput(
                    label: KaziLocalizations.current.phone,
                    placeholder: KaziLocalizations.current.phoneHint,
                    initialValue: state.phone,
                    keyboardType: TextInputType.phone,
                    onChanged: controller.onChangePhone,
                    validator: (value) => FormValidator.validateTextField(
                      value,
                      KaziLocalizations.current.phone,
                    ),
                  ),
                  KaziSpacings.verticalXs,
                  KaziFieldInput(
                    label:
                        '${KaziLocalizations.current.email} · '
                        '${KaziLocalizations.current.optional}',
                    initialValue: state.email,
                    keyboardType: TextInputType.emailAddress,
                    textCapitalization: TextCapitalization.none,
                    onChanged: controller.onChangeEmail,
                  ),
                  KaziSpacings.verticalXs,
                  KaziFieldInput(
                    label:
                        '${KaziLocalizations.current.document} · '
                        '${KaziLocalizations.current.optional}',
                    placeholder: KaziLocalizations.current.documentHint,
                    initialValue: state.identifier,
                    textCapitalization: TextCapitalization.characters,
                    onChanged: controller.onChangeIdentifier,
                  ),
                  KaziFieldHint(KaziLocalizations.current.documentPrivacyHint),
                  KaziSpacings.verticalXs,
                  KaziFieldDate(
                    label:
                        '${KaziLocalizations.current.birthDate} · '
                        '${KaziLocalizations.current.optional}',
                    value: state.birthDate,
                    onChanged: controller.onChangeBirthDate,
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  ),
                  KaziSpacings.verticalXs,
                  KaziFieldInput(
                    label:
                        '${KaziLocalizations.current.observation} · '
                        '${KaziLocalizations.current.optional}',
                    placeholder: KaziLocalizations.current.observationHint,
                    initialValue: state.observation,
                    textInputAction: TextInputAction.done,
                    maxLines: 2,
                    onChanged: controller.onChangeObservation,
                  ),

                  KaziSpacings.verticalLg,
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
          KaziEmpty(message: KaziLocalizations.current.errorUnknowError),
    );
  }

  void _showNamesakeWarning(
    BuildContext context,
    ClientFormControllerProvider provider,
    String namesake,
  ) {
    final controller = ref.read(provider.notifier);

    showDialog(
      context: context,
      builder: (_) => KaziDialog(
        title: KaziLocalizations.current.attention,
        message: KaziLocalizations.current.clientNamesakePlain(namesake),
        emphasis: namesake,
        confirmText: KaziLocalizations.current.save,
        onCancel: () {
          KaziNavigator.pop();
          controller.dismissNamesakeWarning();
        },
        onConfirm: () {
          KaziNavigator.pop();
          controller.confirmNamesake();
        },
      ),
    );
  }
}
