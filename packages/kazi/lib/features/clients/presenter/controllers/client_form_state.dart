import 'package:kazi/core/utils/base_state.dart';

class ClientFormState extends BaseState {
  ClientFormState({
    required super.status,
    super.callbackMessage,
    this.clientId,
    this.name = '',
    this.phone = '',
    this.email = '',
    this.identifier = '',
    this.birthDate,
  });

  /// `null` while creating a new client; set to the document id while editing.
  final String? clientId;

  // Required fields.
  final String name;
  final String phone;

  // Optional fields.
  final String email;

  /// CPF or CNPJ.
  final String identifier;
  final DateTime? birthDate;

  bool get isEditing => clientId != null;

  @override
  ClientFormState copyWith({
    BaseStateStatus? status,
    String? callbackMessage,
    String? clientId,
    String? name,
    String? phone,
    String? email,
    String? identifier,
    DateTime? birthDate,
  }) {
    return ClientFormState(
      status: status ?? this.status,
      callbackMessage: callbackMessage ?? this.callbackMessage,
      clientId: clientId ?? this.clientId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      identifier: identifier ?? this.identifier,
      birthDate: birthDate ?? this.birthDate,
    );
  }
}
