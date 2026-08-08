import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:kazi_companies/core/routes/routes.dart';
import 'package:kazi_companies/presenter/clients/components/favorite_services_chips.dart';
import 'package:kazi_core/kazi_core.dart';

class ClientForm extends StatelessWidget {
  const ClientForm({
    super.key,
    required this.services,
    required this.onSubmit,
    required this.formKey,
    required this.nameEC,
    required this.emailEC,
    required this.phoneEC,
    required this.birthDateEC,
    required this.identifierEC,
    required this.cepEC,
    required this.streetEC,
    required this.numberEC,
    required this.neighborhoodEC,
    required this.cityEC,
    required this.stateEC,
    required this.complementEC,
    required this.favoriteServices,
    required this.onFavoriteServicesChanged,
    required this.onImageChanged,
  });

  final List<ServiceType> services;
  final VoidCallback onSubmit;
  final GlobalKey<FormState> formKey;
  final TextEditingController nameEC;
  final TextEditingController emailEC;
  final TextEditingController phoneEC;
  final TextEditingController birthDateEC;
  final TextEditingController identifierEC;
  final TextEditingController cepEC;
  final TextEditingController streetEC;
  final TextEditingController numberEC;
  final TextEditingController neighborhoodEC;
  final TextEditingController cityEC;
  final TextEditingController stateEC;
  final TextEditingController complementEC;
  final List<ServiceType> favoriteServices;
  final ValueChanged<List<ServiceType>> onFavoriteServicesChanged;
  final ValueChanged<Uint8List> onImageChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: formKey,
        child: Column(
          spacing: KaziInsets.md,
          children: [
            const KaziPageTitle(
              title: 'Cadastrar Cliente',
              subtitle: 'Adicione um novo cliente ao sistema',
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(KaziInsets.xxLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    KaziSpacings.verticalSm,
                    Center(
                      child: KaziImagePicker(onChange: onImageChanged),
                    ),
                    KaziSpacings.verticalXxLg,
                    Row(
                      children: [
                        Icon(Icons.person, color: context.kaziColors.accentInk),
                        KaziSpacings.horizontalSm,
                        const Text(
                          'Informações Pessoais',
                          style: KaziTextStyles.titleMd,
                        ),
                      ],
                    ),
                    KaziSpacings.verticalLg,
                    KaziTextFormField(
                      controller: nameEC,
                      labelText: 'Nome Completo *',
                      validator: (value) => FormValidator.validateTextField(
                        value,
                        'nome completo',
                      ),
                    ),
                    KaziSpacings.verticalLg,
                    Row(
                      children: [
                        Expanded(
                          child: KaziTextFormField(
                            controller: emailEC,
                            labelText: 'E-mail *',
                            keyboardType: TextInputType.emailAddress,
                            validator: FormValidator.validateEmailField,
                          ),
                        ),
                        KaziSpacings.horizontalLg,
                        Expanded(
                          child: KaziTextFormField(
                            controller: phoneEC,
                            labelText: 'Telefone *',
                            keyboardType: TextInputType.phone,
                            validator: (value) =>
                                FormValidator.validateTextField(
                              value,
                              'telefone',
                            ),
                          ),
                        ),
                      ],
                    ),
                    KaziSpacings.verticalLg,
                    KaziDatePicker(
                      controller: birthDateEC,
                      label: 'Data de Aniversário *',
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      onChange: (date) {
                        birthDateEC.text =
                            date.format(const Locale('pt', 'BR'));
                      },
                      validator: (value) => FormValidator.validateTextField(
                        value,
                        'data de aniversário',
                      ),
                    ),
                    KaziSpacings.verticalLg,
                    KaziTextFormField(
                      controller: identifierEC,
                      labelText: 'CPF/CNPJ *',
                      validator: (value) =>
                          FormValidator.validateTextField(value, 'CPF/CNPJ'),
                    ),
                    KaziSpacings.verticalXxLg,
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: context.kaziColors.accentInk,
                        ),
                        KaziSpacings.horizontalSm,
                        const Text(
                          'Endereço (Opcional)',
                          style: KaziTextStyles.titleMd,
                        ),
                      ],
                    ),
                    KaziSpacings.verticalLg,
                    KaziTextFormField(
                      controller: cepEC,
                      labelText: 'CEP',
                      keyboardType: TextInputType.number,
                    ),
                    KaziSpacings.verticalLg,
                    KaziTextFormField(
                      controller: streetEC,
                      labelText: 'Rua',
                    ),
                    KaziSpacings.verticalLg,
                    Row(
                      children: [
                        Expanded(
                          child: KaziTextFormField(
                            controller: numberEC,
                            labelText: 'Número',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        KaziSpacings.horizontalLg,
                        Expanded(
                          child: KaziTextFormField(
                            controller: neighborhoodEC,
                            labelText: 'Bairro',
                          ),
                        ),
                      ],
                    ),
                    KaziSpacings.verticalLg,
                    Row(
                      children: [
                        Expanded(
                          child: KaziTextFormField(
                            controller: cityEC,
                            labelText: 'Cidade',
                          ),
                        ),
                        KaziSpacings.horizontalLg,
                        Expanded(
                          child: KaziTextFormField(
                            controller: stateEC,
                            labelText: 'Estado',
                          ),
                        ),
                      ],
                    ),
                    KaziSpacings.verticalLg,
                    KaziTextFormField(
                      controller: complementEC,
                      labelText: 'Complemento',
                    ),
                    KaziSpacings.verticalXxLg,
                    Row(
                      children: [
                        Icon(Icons.star, color: context.kaziColors.accentInk),
                        KaziSpacings.horizontalSm,
                        const Text(
                          'Serviços Favoritos',
                          style: KaziTextStyles.titleMd,
                        ),
                      ],
                    ),
                    KaziSpacings.verticalLg,
                    FavoriteServicesChips(
                      serviceTypes: services,
                      initialFavoriteServices: favoriteServices,
                      onSelectionChanged: onFavoriteServicesChanged,
                    ),
                    KaziSpacings.verticalXxLg,
                    Row(
                      children: [
                        Expanded(
                          child: KaziElevatedButton.outlined(
                            onTap: () => context.navigate(Routes.clients),
                            label: 'Cancelar',
                          ),
                        ),
                        KaziSpacings.horizontalLg,
                        Expanded(
                          child: KaziElevatedButton.label(
                            onTap: onSubmit,
                            label: 'Cadastrar Cliente',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
