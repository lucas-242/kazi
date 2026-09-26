import 'package:kazi_core/shared/entities/address.dart';
import 'package:kazi_core/shared/entities/catalog_item.dart';
import 'package:kazi_core/shared/enums/user_type.dart';

class CreateUserParams {
  CreateUserParams({
    required this.identifier,
    required this.name,
    required this.email,
    this.phones = const [],
    required this.role,
    this.services = const [],
    this.addresses = const [],
    required this.userType,
    this.password,
  });

  final String identifier;
  final String name;
  final String email;
  final List<String> phones;
  final String? role;
  final List<CatalogItem> services;
  final List<Address> addresses;
  final UserType userType;

  final String? password;
}
