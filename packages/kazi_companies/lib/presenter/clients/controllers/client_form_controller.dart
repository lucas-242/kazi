import 'package:flutter/foundation.dart';
import 'package:kazi_core/kazi_core.dart';
import 'package:kazi_core/modules/users/domain/models/create_client_params.dart';

part 'client_form_controller.g.dart';

@riverpod
class ClientFormController extends _$ClientFormController {
  @override
  Future<List<ServiceType>> build() {
    return ref.read(serviceTypeRepositoyProvider).get();
  }

  Future<String?> submit({
    required String name,
    required String email,
    required String phone,
    required String birthDate,
    required String identifier,
    Address? address,
    Uint8List? image,
    required List<ServiceType> favoriteServices,
  }) async {
    final params = CreateClientParams(
      name: name,
      email: email,
      identifier: identifier,
      phone: phone,
      birthDate: DateFormat('dd/MM/yyyy').parse(birthDate),
      address: address,
      favoriteSevices: favoriteServices,
      photo: image,
    );

    try {
      await ref.read(usersRepositoryProvider).createClient(params);
      return null;
    } catch (error) {
      return error.toString();
    }
  }

  Address? getAddress({
    String? cep,
    String? street,
    String? number,
    String? neighborhood,
    String? city,
    String? state,
    String? complement,
  }) {
    if (cep == null ||
        cep.isNotEmpty ||
        street == null ||
        street.isNotEmpty ||
        number == null ||
        number.isNotEmpty ||
        neighborhood == null ||
        neighborhood.isNotEmpty ||
        city == null ||
        city.isNotEmpty ||
        state == null ||
        state.isNotEmpty) {
      return null;
    }

    return Address(
      id: 0,
      postalCode: cep,
      street: street,
      number: int.tryParse(number),
      neighborhood: neighborhood,
      city: city,
      state: state,
      complement: complement,
    );
  }
}
