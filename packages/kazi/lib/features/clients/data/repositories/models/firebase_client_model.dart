import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kazi/features/clients/domain/models/client_entry.dart';
import 'package:kazi_core/kazi_core.dart';

/// Serialization between Firestore `clients` documents and kazi_core's [User]
/// entity (wrapped in a [ClientEntry] so the document id is preserved).
abstract final class FirebaseClientModel {
  /// Builds the map stored when a client is created. The `lastServiceName`
  /// and `lastServiceDate` fields are denormalized and updated separately.
  static Map<String, dynamic> toMap(String ownerId, User client) {
    return {
      'ownerId': ownerId,
      'status': ClientStatus.active,
      ...editableData(client),
    };
  }

  /// The fields an edit is allowed to touch.
  ///
  /// Deliberately excludes `status` and `archivedAt`: writing them here would
  /// make editing an archived client quietly bring it back.
  static Map<String, dynamic> editableData(User client) {
    return {
      'name': client.name,
      'phones': client.phones,
      'email': client.email,
      'identifier': client.identifier,
      'birthDate': ClientBirthDate.isMissing(client.birthDate)
          ? null
          : Timestamp.fromDate(client.birthDate),
    };
  }

  static Map<String, dynamic> archivedData(DateTime archivedAt) {
    return {
      'status': ClientStatus.archived,
      'archivedAt': Timestamp.fromDate(archivedAt),
    };
  }

  static Map<String, dynamic> restoredData() {
    return {
      'status': ClientStatus.active,
      'archivedAt': FieldValue.delete(),
    };
  }

  static ClientEntry fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    final user = _mapToUser(data);
    final lastServiceDate = data['lastServiceDate'] is Timestamp
        ? (data['lastServiceDate'] as Timestamp).toDate()
        : DateTime(2000);

    final info = ClientInfo(
      user: user,
      lastServiceName: data['lastServiceName'] ?? '',
      lastServiceDate: lastServiceDate,
      mostUsedServices: const {},
    );

    final archivedAt = data['archivedAt'];

    return (
      id: doc.id,
      info: info,
      archivedAt: archivedAt is Timestamp ? archivedAt.toDate() : null,
    );
  }

  static User _mapToUser(Map<String, dynamic> data) {
    return User(
      id: 0,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      identifier: data['identifier'] ?? '',
      birthDate: data['birthDate'] is Timestamp
          ? (data['birthDate'] as Timestamp).toDate()
          : ClientBirthDate.missing,
      userType: UserType.client,
      authToken: '',
      refreshToken: '',
      authExpires: DateTime(2100),
      phones: data['phones'] != null ? List<String>.from(data['phones']) : [],
    );
  }
}
