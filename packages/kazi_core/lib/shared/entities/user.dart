import 'package:equatable/equatable.dart';
import 'package:kazi_core/shared/entities/address.dart';
import 'package:kazi_core/shared/entities/catalog_item.dart';
import 'package:kazi_core/shared/enums/user_type.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.userType,
    required this.document,
    required this.birthDate,
    this.createdAt,
    this.role,
    this.admissionDate,
    this.services = const [],
    this.addresses = const [],
    this.phones = const <String>[],
    this.password,
    required this.authToken,
    required this.refreshToken,
    required this.authExpires,
  });

  factory User.empty() => User(
        id: 0,
        name: '',
        email: '',
        userType: UserType.client,
        document: '',
        birthDate: DateTime(2000),
        authToken: '',
        refreshToken: '',
        authExpires: DateTime(2100),
      );

  final int id;
  final String name;
  final String email;
  final String? photoUrl;

  final List<String> phones;

  /// User document
  final String document;

  final DateTime birthDate;

  /// When this person entered the book. Null where the backing record predates
  /// the field, or where the source simply does not carry one — so a screen
  /// reading it has to be prepared to say nothing rather than invent a date.
  final DateTime? createdAt;

  final UserType userType;

  /// Identifies the User's role/function in the company.
  ///
  /// Will be null if [UserType] is [UserType.client].
  final String? role;

  /// Will be null if [UserType] is [UserType.client] or [UserType.selfEmployed].
  final DateTime? admissionDate;

  /// Represents the list of [CatalogItem] that user can offer.
  ///
  /// Will be empty if [UserType] is [UserType.client].
  final List<CatalogItem> services;
  final List<Address> addresses;

  final String? password;
  final String authToken;
  final String refreshToken;
  final DateTime authExpires;

  String get shortName => name.length > 18 ? name.split('').first : name;

  bool get isBirthdayInMonth => DateTime.now().month == birthDate.month;

  User copyWith({
    String? name,
    String? email,
    String? photoUrl,
    int? id,
    String? identifier,
    DateTime? birthDate,
    DateTime? createdAt,
    String? role,
    DateTime? admissionDate,
    List<CatalogItem>? services,
    List<Address>? addresses,
    List<String>? phones,
    String? password,
    UserType? userType,
    String? authToken,
    String? refreshToken,
    DateTime? authExpires,
  }) {
    return User(
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      id: id ?? this.id,
      document: identifier ?? document,
      birthDate: birthDate ?? this.birthDate,
      createdAt: createdAt ?? this.createdAt,
      role: role ?? this.role,
      admissionDate: admissionDate ?? this.admissionDate,
      services: services ?? this.services,
      addresses: addresses ?? this.addresses,
      phones: phones ?? this.phones,
      password: password ?? this.password,
      userType: userType ?? this.userType,
      authToken: authToken ?? this.authToken,
      authExpires: authExpires ?? this.authExpires,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        photoUrl,
        document,
        birthDate,
        createdAt,
        role,
        admissionDate,
        services,
        addresses,
        phones,
        password,
        userType,
        authToken,
        authExpires,
        refreshToken,
      ];
}
