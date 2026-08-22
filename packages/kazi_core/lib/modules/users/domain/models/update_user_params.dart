import 'package:kazi_core/shared/entities/address.dart';
import 'package:kazi_core/shared/entities/catalog_item.dart';
import 'package:kazi_core/shared/enums/user_type.dart';

class UpdateUserParams {
  UpdateUserParams({
    this.identifier,
    this.name,
    this.email,
    this.phones,
    this.role,
    this.services,
    this.addresses,
    this.userType,
    this.password,
  });

  final String? identifier;
  final String? name;
  final String? email;
  final List<String>? phones;
  final String? role;
  final List<CatalogItem>? services;
  final List<Address>? addresses;
  final UserType? userType;

  final String? password;
}
