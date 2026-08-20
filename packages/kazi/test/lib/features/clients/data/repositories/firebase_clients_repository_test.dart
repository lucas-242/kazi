import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/clients/data/repositories/firebase_clients_repository.dart';
import 'package:kazi/features/clients/data/repositories/models/firebase_client_model.dart';
import 'package:kazi/features/clients/domain/models/client_entry.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
import 'package:mockito/annotations.dart';

import '../../../../../utils/fakes/fake_crashlytics_service.dart';
import '../../../../../utils/test_helper.dart';
import '../../../../../utils/test_matchers.dart';
import 'firebase_clients_repository_test.mocks.dart';

@GenerateMocks([FirebaseFirestore])
void main() {
  const ownerId = 'abc123';
  const otherOwnerId = 'zzz999';

  late FakeFirebaseFirestore database;
  late FakeCrashlyticsService crashlytics;
  late FirebaseClientsRepository repository;

  TestHelper.loadAppLocalizations();

  User clientUser({
    required String name,
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

  /// Seeds a client document directly, bypassing the repository, so read tests
  /// do not depend on the write path.
  Future<String> seedClient({
    String owner = ownerId,
    required String name,
    bool active = true,
    String lastServiceName = '',
    DateTime? lastServiceDate,
  }) async {
    final doc = await database.collection('clients').add({
      ...FirebaseClientModel.toMap(owner, clientUser(name: name)),
      'active': active,
      'lastServiceName': lastServiceName,
      if (lastServiceDate != null)
        'lastServiceDate': Timestamp.fromDate(lastServiceDate),
    });
    return doc.id;
  }

  Future<void> seedService({
    String owner = ownerId,
    required String clientId,
    required String typeName,
    required DateTime date,
    String professionalName = 'Pro',
    String? description,
  }) async {
    await database.collection('services').add({
      'userId': owner,
      'clientId': clientId,
      'typeName': typeName,
      'professionalName': professionalName,
      'date': Timestamp.fromDate(date),
      if (description != null) 'description': description,
    });
  }

  setUp(() {
    database = FakeFirebaseFirestore();
    crashlytics = FakeCrashlyticsService();
    repository = FirebaseClientsRepository(database, crashlytics);
  });

  group('getClients', () {
    test('returns the owner\'s active clients ordered by name', () async {
      await seedClient(name: 'Carla');
      await seedClient(name: 'Ana');
      await seedClient(name: 'Bruna');

      final result = await repository.getClients(ownerId);

      expect(result.map((client) => client.info.user.name), [
        'Ana',
        'Bruna',
        'Carla',
      ]);
    });

    test('excludes other owners', () async {
      await seedClient(name: 'Ana');
      await seedClient(owner: otherOwnerId, name: 'Bruna');

      final result = await repository.getClients(ownerId);

      expect(result, hasLength(1));
      expect(result.single.info.user.name, 'Ana');
    });

    test('excludes deactivated clients', () async {
      await seedClient(name: 'Ana');
      await seedClient(name: 'Bruna', active: false);

      final result = await repository.getClients(ownerId);

      expect(result.map((client) => client.info.user.name), ['Ana']);
    });

    test('honours the page limit', () async {
      for (final name in ['Ana', 'Bruna', 'Carla']) {
        await seedClient(name: name);
      }

      final result = await repository.getClients(ownerId, limit: 2);

      expect(result, hasLength(2));
    });

    test('pages after the given name', () async {
      for (final name in ['Ana', 'Bruna', 'Carla']) {
        await seedClient(name: name);
      }

      final result = await repository.getClients(
        ownerId,
        startAfterName: 'Ana',
      );

      expect(result.map((client) => client.info.user.name), ['Bruna', 'Carla']);
    });

    test('carries the document id into the entry', () async {
      final id = await seedClient(name: 'Ana');

      final result = await repository.getClients(ownerId);

      expect(result.single.id, id);
    });
  });

  group('searchByName', () {
    test('matches on a name prefix', () async {
      for (final name in ['Ana', 'Ana Maria', 'Bruna']) {
        await seedClient(name: name);
      }

      final result = await repository.searchByName(ownerId, 'Ana');

      expect(result.map((client) => client.info.user.name), [
        'Ana',
        'Ana Maria',
      ]);
    });

    test('returns nothing when no name matches', () async {
      await seedClient(name: 'Ana');

      final result = await repository.searchByName(ownerId, 'Zoe');

      expect(result, isEmpty);
    });
  });

  group('getClientDetails', () {
    test('returns null for a client that does not exist', () async {
      expect(await repository.getClientDetails(ownerId, 'nope'), isNull);
    });

    test('joins the service history, newest first', () async {
      final id = await seedClient(name: 'Ana');
      await seedService(
        clientId: id,
        typeName: 'Manicure',
        date: DateTime(2026, 5),
      );
      await seedService(
        clientId: id,
        typeName: 'Pedicure',
        date: DateTime(2026, 6),
        description: 'Sensitive skin',
      );

      final result = await repository.getClientDetails(ownerId, id);

      expect(result!.info.serviceHistory.map((item) => item.serviceName), [
        'Pedicure',
        'Manicure',
      ]);
      expect(result.info.serviceHistory.first.notes, 'Sensitive skin');
    });

    test('takes the last service from the history when it has one', () async {
      final id = await seedClient(name: 'Ana', lastServiceName: 'Stale');
      await seedService(
        clientId: id,
        typeName: 'Pedicure',
        date: DateTime(2026, 6),
      );

      final result = await repository.getClientDetails(ownerId, id);

      expect(result!.info.lastServiceName, 'Pedicure');
      expect(result.info.lastServiceDate, DateTime(2026, 6));
    });

    test('falls back to the denormalized fields with no history', () async {
      final id = await seedClient(
        name: 'Ana',
        lastServiceName: 'Manicure',
        lastServiceDate: DateTime(2026, 4),
      );

      final result = await repository.getClientDetails(ownerId, id);

      expect(result!.info.lastServiceName, 'Manicure');
      expect(result.info.serviceHistory, isEmpty);
    });

    test('never leaks another owner\'s services', () async {
      final id = await seedClient(name: 'Ana');
      await seedService(
        owner: otherOwnerId,
        clientId: id,
        typeName: 'Not mine',
        date: DateTime(2026, 6),
      );

      final result = await repository.getClientDetails(ownerId, id);

      expect(result!.info.serviceHistory, isEmpty);
    });
  });

  group('getServiceHistory', () {
    test('returns the history newest first', () async {
      final id = await seedClient(name: 'Ana');
      for (var month = 1; month <= 3; month++) {
        await seedService(
          clientId: id,
          typeName: 'Service $month',
          date: DateTime(2026, month),
        );
      }

      final result = await repository.getServiceHistory(ownerId, id);

      expect(result.map((item) => item.serviceName), [
        'Service 3',
        'Service 2',
        'Service 1',
      ]);
    });

    // Paging by `startAfterDate` is asserted in the controller test instead:
    // fake_cloud_firestore's `startAfter` scans the ordered docs with
    // `lastIndexWhere`, which assumes an ascending order, so on this
    // `descending: true` query it returns nothing (and a raw `DateTime` cursor
    // throws inside `Timestamp.compareTo`). The limitation is the fake's, not
    // the query's.

    test('honours the page limit', () async {
      final id = await seedClient(name: 'Ana');
      for (var month = 1; month <= 3; month++) {
        await seedService(
          clientId: id,
          typeName: 'Service $month',
          date: DateTime(2026, month),
        );
      }

      final result = await repository.getServiceHistory(ownerId, id, limit: 2);

      expect(result, hasLength(2));
    });
  });

  group('add', () {
    test('writes the client and returns its new id', () async {
      final id = await repository.add(ownerId, clientUser(name: 'Ana'));

      final doc = await database.collection('clients').doc(id).get();
      expect(doc.exists, isTrue);
      expect(doc.data()!['name'], 'Ana');
      expect(doc.data()!['ownerId'], ownerId);
      expect(doc.data()!['active'], isTrue);
    });

    test('persists a real birth date', () async {
      final id = await repository.add(
        ownerId,
        clientUser(name: 'Ana', birthDate: DateTime(1990, 5, 12)),
      );

      final doc = await database.collection('clients').doc(id).get();
      expect(
        (doc.data()!['birthDate'] as Timestamp).toDate(),
        DateTime(1990, 5, 12),
      );
    });

    test('stores no birth date when there is none', () async {
      final id = await repository.add(ownerId, clientUser(name: 'Ana'));

      final doc = await database.collection('clients').doc(id).get();
      expect(doc.data()!['birthDate'], isNull);
    });
  });

  group('count', () {
    test('counts only the owner\'s active clients', () async {
      await seedClient(name: 'Ana');
      await seedClient(name: 'Bruna');
      await seedClient(name: 'Carla', active: false);
      await seedClient(owner: otherOwnerId, name: 'Dani');

      expect(await repository.count(ownerId), 2);
    });

    test('is zero for an owner with no clients', () async {
      expect(await repository.count(ownerId), 0);
    });
  });

  group('update', () {
    test('rewrites the fields while keeping the owner', () async {
      final id = await seedClient(name: 'Ana');

      await repository.update(id, clientUser(name: 'Ana Maria'));

      final doc = await database.collection('clients').doc(id).get();
      expect(doc.data()!['name'], 'Ana Maria');
      expect(doc.data()!['ownerId'], ownerId);
    });
  });

  group('deactivate', () {
    test('flags the client inactive and wipes personal data', () async {
      final id = await seedClient(name: 'Ana');

      await repository.deactivate(id);

      final data = (await database.collection('clients').doc(id).get()).data()!;
      expect(data['active'], isFalse);
      expect(data['name'], '');
      expect(data['email'], '');
      expect(data['identifier'], '');
      expect(data['phones'], isEmpty);
      expect(data['birthDate'], isNull);
    });

    test('keeps the document so the service history stays intact', () async {
      final id = await seedClient(name: 'Ana');

      await repository.deactivate(id);

      expect(
        (await database.collection('clients').doc(id).get()).exists,
        isTrue,
      );
    });

    test('drops the client out of the listing', () async {
      final id = await seedClient(name: 'Ana');

      await repository.deactivate(id);

      expect(await repository.getClients(ownerId), isEmpty);
    });
  });

  group('updateLastService', () {
    test('denormalizes the last service onto the document', () async {
      final id = await seedClient(name: 'Ana');

      await repository.updateLastService(id, 'Manicure', DateTime(2026, 6));

      final data = (await database.collection('clients').doc(id).get()).data()!;
      expect(data['lastServiceName'], 'Manicure');
      expect(
        (data['lastServiceDate'] as Timestamp).toDate(),
        DateTime(2026, 6),
      );
    });

    test('swallows a failure — it must not break the service flow', () async {
      final failing = FirebaseClientsRepository(
        MockFirebaseFirestore(),
        crashlytics,
      );

      // Deliberately no expectation of a throw: the denormalization is
      // best-effort by design.
      await failing.updateLastService('any', 'Manicure', DateTime(2026, 6));

      expect(crashlytics.loggedExceptions, hasLength(1));
    });
  });

  group('failures', () {
    late FirebaseClientsRepository failing;

    setUp(() {
      failing = FirebaseClientsRepository(MockFirebaseFirestore(), crashlytics);
    });

    test('getClients reports a localized external error', () async {
      await expectLater(
        failing.getClients(ownerId),
        ErrorWithMessage<ExternalError>(
          KaziLocalizations.current.errorToGetClients,
        ),
      );
      expect(crashlytics.loggedExceptions, hasLength(1));
    });

    test('add reports a localized external error', () async {
      await expectLater(
        failing.add(ownerId, clientUser(name: 'Ana')),
        ErrorWithMessage<ExternalError>(
          KaziLocalizations.current.errorToAddClient,
        ),
      );
    });

    test('update reports a localized external error', () async {
      await expectLater(
        failing.update('any', clientUser(name: 'Ana')),
        ErrorWithMessage<ExternalError>(
          KaziLocalizations.current.errorToUpdateClient,
        ),
      );
    });

    test('deactivate reports a localized external error', () async {
      await expectLater(
        failing.deactivate('any'),
        ErrorWithMessage<ExternalError>(
          KaziLocalizations.current.errorToDeleteClient,
        ),
      );
    });
  });
}
