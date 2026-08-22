import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/clients/data/repositories/models/firebase_client_model.dart';
import 'package:kazi/features/clients/domain/models/client_entry.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

void main() {
  const ownerId = 'abc123';

  User client({
    String name = 'Ana',
    String email = 'ana@test.com',
    String identifier = '12345678900',
    List<String> phones = const ['11999999999'],
    DateTime? birthDate,
  }) => User(
    id: 0,
    name: name,
    email: email,
    identifier: identifier,
    phones: phones,
    birthDate: birthDate ?? ClientBirthDate.missing,
    userType: UserType.client,
    authToken: '',
    refreshToken: '',
    authExpires: DateTime(2100),
  );

  Future<DocumentSnapshot<Map<String, dynamic>>> docFrom(
    Map<String, dynamic> data,
  ) async {
    final database = FakeFirebaseFirestore();
    final ref = await database.collection('clients').add(data);
    return ref.get();
  }

  group('toMap', () {
    test('writes the owner and marks the client active', () {
      final map = FirebaseClientModel.toMap(ownerId, client());

      expect(map['ownerId'], ownerId);
      expect(map['active'], isTrue);
    });

    test('writes every personal field', () {
      final map = FirebaseClientModel.toMap(
        ownerId,
        client(name: 'Ana Maria', phones: ['11999999999', '1133334444']),
      );

      expect(map['name'], 'Ana Maria');
      expect(map['email'], 'ana@test.com');
      expect(map['identifier'], '12345678900');
      expect(map['phones'], ['11999999999', '1133334444']);
    });

    test('writes a real birth date as a Timestamp', () {
      final map = FirebaseClientModel.toMap(
        ownerId,
        client(birthDate: DateTime(1990, 5, 12)),
      );

      expect((map['birthDate'] as Timestamp).toDate(), DateTime(1990, 5, 12));
    });

    test('writes null for the missing-birth-date sentinel', () {
      final map = FirebaseClientModel.toMap(
        ownerId,
        client(birthDate: ClientBirthDate.missing),
      );

      expect(map['birthDate'], isNull);
    });

    test('keeps a birth date from before the sentinel year', () {
      // The rule is equality with the sentinel, not a year comparison: most
      // clients were born before 2000 and must not lose their birth date.
      final map = FirebaseClientModel.toMap(
        ownerId,
        client(birthDate: DateTime(1985, 2, 3)),
      );

      expect((map['birthDate'] as Timestamp).toDate(), DateTime(1985, 2, 3));
    });
  });

  group('deactivatedData', () {
    test('flags the client inactive', () {
      expect(FirebaseClientModel.deactivatedData()['active'], isFalse);
    });

    test('wipes every piece of personal data', () {
      final map = FirebaseClientModel.deactivatedData();

      expect(map['name'], '');
      expect(map['email'], '');
      expect(map['identifier'], '');
      expect(map['phones'], isEmpty);
      expect(map['birthDate'], isNull);
    });

    test('stamps the deactivation with the server clock', () {
      expect(
        FirebaseClientModel.deactivatedData()['deactivatedAt'],
        isA<FieldValue>(),
      );
    });

    test('leaves the denormalized service fields alone', () {
      // They are not personal data, and the service history still refers to
      // them.
      final map = FirebaseClientModel.deactivatedData();

      expect(map.containsKey('lastServiceName'), isFalse);
      expect(map.containsKey('lastServiceDate'), isFalse);
    });
  });

  group('fromDoc', () {
    test('round-trips a written client', () async {
      final original = client(birthDate: DateTime(1990, 5, 12));

      final entry = FirebaseClientModel.fromDoc(
        await docFrom(FirebaseClientModel.toMap(ownerId, original)),
      );

      expect(entry.info.user.name, original.name);
      expect(entry.info.user.email, original.email);
      expect(entry.info.user.identifier, original.identifier);
      expect(entry.info.user.phones, original.phones);
      expect(entry.info.user.birthDate, original.birthDate);
    });

    test('carries the document id', () async {
      final doc = await docFrom(FirebaseClientModel.toMap(ownerId, client()));

      expect(FirebaseClientModel.fromDoc(doc).id, doc.id);
    });

    test('reads a missing birth date back as the sentinel', () async {
      final entry = FirebaseClientModel.fromDoc(
        await docFrom(FirebaseClientModel.toMap(ownerId, client())),
      );

      expect(ClientBirthDate.isMissing(entry.info.user.birthDate), isTrue);
    });

    test('tolerates a document with no fields at all', () async {
      final entry = FirebaseClientModel.fromDoc(await docFrom({}));

      expect(entry.info.user.name, '');
      expect(entry.info.user.email, '');
      expect(entry.info.user.identifier, '');
      expect(entry.info.user.phones, isEmpty);
      expect(entry.info.lastServiceName, '');
    });

    test('reads the denormalized last service', () async {
      final entry = FirebaseClientModel.fromDoc(
        await docFrom({
          ...FirebaseClientModel.toMap(ownerId, client()),
          'lastServiceName': 'Manicure',
          'lastServiceDate': Timestamp.fromDate(DateTime(2026, 6)),
        }),
      );

      expect(entry.info.lastServiceName, 'Manicure');
      expect(entry.info.lastServiceDate, DateTime(2026, 6));
    });

    test('falls back to the sentinel date with no last service', () async {
      final entry = FirebaseClientModel.fromDoc(
        await docFrom(FirebaseClientModel.toMap(ownerId, client())),
      );

      expect(entry.info.lastServiceDate, ClientBirthDate.missing);
    });
  });

  group('ClientBirthDate', () {
    test('treats null and the sentinel as missing', () {
      expect(ClientBirthDate.isMissing(null), isTrue);
      expect(ClientBirthDate.isMissing(ClientBirthDate.missing), isTrue);
      expect(ClientBirthDate.isMissing(DateTime(2000)), isTrue);
    });

    test('treats any other date as present', () {
      expect(ClientBirthDate.isMissing(DateTime(1985, 2, 3)), isFalse);
      expect(ClientBirthDate.isMissing(DateTime(2000, 1, 2)), isFalse);
      expect(ClientBirthDate.isMissing(DateTime(2005)), isFalse);
    });
  });
}
