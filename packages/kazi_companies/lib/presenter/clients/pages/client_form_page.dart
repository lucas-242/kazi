import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kazi_companies/core/routes/routes.dart';
import 'package:kazi_companies/presenter/clients/components/client_form.dart';
import 'package:kazi_companies/presenter/clients/controllers/client_form_controller.dart';
import 'package:kazi_core/kazi_core.dart';

class ClientFormPage extends ConsumerStatefulWidget {
  const ClientFormPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ClientFormPageState();
}

class _ClientFormPageState extends ConsumerState<ClientFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameEC = TextEditingController();
  final _emailEC = TextEditingController();
  final _phoneEC = TextEditingController();
  final _birthDateEC = TextEditingController();
  final _identifierEC = TextEditingController();
  final _cepEC = TextEditingController();
  final _streetEC = TextEditingController();
  final _numberEC = TextEditingController();
  final _neighborhoodEC = TextEditingController();
  final _cityEC = TextEditingController();
  final _stateEC = TextEditingController();
  final _complementEC = TextEditingController();
  List<ServiceType> _favoriteServices = [];
  Uint8List? _image;

  @override
  void dispose() {
    super.dispose();
    _nameEC.dispose();
    _emailEC.dispose();
    _phoneEC.dispose();
    _birthDateEC.dispose();
    _identifierEC.dispose();
    _cepEC.dispose();
    _streetEC.dispose();
    _numberEC.dispose();
    _neighborhoodEC.dispose();
    _cityEC.dispose();
    _stateEC.dispose();
    _complementEC.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final services = ref.watch(clientFormControllerProvider);

    return KaziSafeArea(
      child: services.when(
        data: (data) => ClientForm(
          services: data,
          onSubmit: _onSubmit,
          formKey: _formKey,
          nameEC: _nameEC,
          emailEC: _emailEC,
          phoneEC: _phoneEC,
          birthDateEC: _birthDateEC,
          identifierEC: _identifierEC,
          cepEC: _cepEC,
          streetEC: _streetEC,
          numberEC: _numberEC,
          neighborhoodEC: _neighborhoodEC,
          cityEC: _cityEC,
          stateEC: _stateEC,
          complementEC: _complementEC,
          favoriteServices: _favoriteServices,
          onFavoriteServicesChanged: (selection) {
            _favoriteServices = selection;
          },
          onImageChanged: (image) {
            _image = image;
          },
        ),
        error: (error, stackTrace) => KaziError(message: error.toString()),
        loading: () => const KaziLoading(),
      ),
    );
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    context.showKaziLoading();

    final controller = ref.read(clientFormControllerProvider.notifier);

    final address = controller.getAddress(
      cep: _cepEC.text,
      street: _streetEC.text,
      number: _numberEC.text,
      neighborhood: _neighborhoodEC.text,
      city: _cityEC.text,
      state: _stateEC.text,
      complement: _complementEC.text,
    );

    final message = await controller.submit(
      image: _image,
      name: _nameEC.text,
      email: _emailEC.text,
      phone: _phoneEC.text,
      birthDate: _birthDateEC.text,
      identifier: _identifierEC.text,
      address: address,
      favoriteServices: _favoriteServices,
    );

    if (!mounted) return;

    context.pop();

    if (message == null) {
      context.showSnackbar('Cliente cadastrado com sucesso!');
      context.navigate(Routes.clients);
    } else {
      context.showSnackbar(message);
    }
  }
}
