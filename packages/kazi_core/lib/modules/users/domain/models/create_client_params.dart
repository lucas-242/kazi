import 'dart:typed_data';

import 'package:kazi_core/shared/entities/address.dart';
import 'package:kazi_core/shared/entities/catalog_item.dart';

class CreateClientParams {
  CreateClientParams({
    required this.identifier,
    required this.name,
    required this.birthDate,
    required this.email,
    required this.phone,
    this.favoriteSevices = const [],
    this.address,
    this.photo,
    this.password,
  });

  final String identifier;
  final String name;
  final DateTime birthDate;
  final String email;
  final String phone;
  final List<CatalogItem> favoriteSevices;
  final Address? address;
  final Uint8List? photo;
  final String? password;
}
