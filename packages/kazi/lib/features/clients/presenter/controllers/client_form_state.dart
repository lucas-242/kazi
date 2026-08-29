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
    this.namesakeWarning,
    this.namesakeAcknowledged = false,
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

  /// The name of an active client already on file under this same name, or null
  /// when there is none.
  ///
  /// Namesakes are legitimate, so this only ever warns — unlike a repeated
  /// document, which is refused outright. See core/archiving.md.
  final String? namesakeWarning;

  /// Raised once the user has seen the warning and saved anyway, so the second
  /// attempt goes through instead of warning again.
  final bool namesakeAcknowledged;

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
    String? namesakeWarning,
    bool? namesakeAcknowledged,
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
      namesakeWarning: namesakeWarning ?? this.namesakeWarning,
      namesakeAcknowledged: namesakeAcknowledged ?? this.namesakeAcknowledged,
    );
  }

  /// Drops a pending warning. A separate method because [copyWith] reads null
  /// as "keep what you have".
  ClientFormState withoutNamesakeWarning() => ClientFormState(
    status: status,
    callbackMessage: callbackMessage,
    clientId: clientId,
    name: name,
    phone: phone,
    email: email,
    identifier: identifier,
    birthDate: birthDate,
    namesakeAcknowledged: namesakeAcknowledged,
  );
}
