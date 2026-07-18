import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kazi/features/clients/domain/models/client_entry.dart';
import 'package:kazi_core/kazi_core.dart';

/// Serialization between Firestore `clients` documents and kazi_core's [User]
/// entity (wrapped in a [ClientEntry] so the document id is preserved).
abstract final class FirebaseClientModel {
  /// Builds the map stored under a `clients` document. The `lastServiceName`
  /// and `lastServiceDate` fields are denormalized and updated separately.
  static Map<String, dynamic> toMap(String ownerId, User client) {
    return {
      'ownerId': ownerId,
      'name': client.name,
      'phones': client.phones,
      'email': client.email,
      'identifier': client.identifier,
      'birthDate': client.birthDate.year > 2000
          ? Timestamp.fromDate(client.birthDate)
          : null,
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

    return (id: doc.id, info: info);
  }

  static User _mapToUser(Map<String, dynamic> data) {
    return User(
      id: 0,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      identifier: data['identifier'] ?? '',
      birthDate: data['birthDate'] is Timestamp
          ? (data['birthDate'] as Timestamp).toDate()
          : DateTime(2000),
      userType: UserType.client,
      authToken: '',
      refreshToken: '',
      authExpires: DateTime(2100),
      phones: data['phones'] != null ? List<String>.from(data['phones']) : [],
    );
  }
}
