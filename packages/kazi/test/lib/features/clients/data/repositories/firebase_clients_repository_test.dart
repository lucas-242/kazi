import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/clients/data/repositories/firebase_clients_repository.dart';
import 'package:kazi/features/clients/data/repositories/models/firebase_client_model.dart';
import 'package:kazi/features/clients/domain/models/client_entry.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;
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
    document: identifier,
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
    bool archived = false,
    String lastServiceName = '',
    DateTime? lastServiceDate,
  }) async {
    final doc = await database.collection('clients').add({
      ...FirebaseClientModel.toMap(owner, clientUser(name: name)),
      if (archived)
        ...FirebaseClientModel.archivedData(DateTime(2026, 8, 24)),
      'lastServiceName': lastServiceName,
      if (lastServiceDate != null)
        'lastServiceDate': Timestamp.fromDate(lastServiceDate),
    });
    return doc.id;
  }

  Future<void> seedService({
    String owner = ownerId,
    required String clientId,
    required String catalogItemName,
    required DateTime date,
    double value = 100,
    String? description,
  }) async {
    await database.collection('services').add({
      'userId': owner,
      'clientId': clientId,
      'typeId': catalogItemName,
      'typeName': catalogItemName,
      'type': {'id': catalogItemName, 'name': catalogItemName},
      'value': value,
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

    test('excludes archived clients', () async {
      await seedClient(name: 'Ana');
      await seedClient(name: 'Bruna', archived: true);

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

    test('reads the denormalized last service off the document', () async {
      final id = await seedClient(
        name: 'Ana',
        lastServiceName: 'Manicure',
        lastServiceDate: DateTime(2026, 4),
      );

      final result = await repository.getClientDetails(ownerId, id);

      expect(result!.info.user.name, 'Ana');
      expect(result.info.lastServiceName, 'Manicure');
      expect(result.info.lastServiceDate, DateTime(2026, 4));
    });
  });

  group('getServiceHistory', () {
    test('returns the history newest first', () async {
      final id = await seedClient(name: 'Ana');
      for (var month = 1; month <= 3; month++) {
        await seedService(
          clientId: id,
          catalogItemName: 'Service $month',
          date: DateTime(2026, month),
        );
      }

      final result = await repository.getServiceHistory(ownerId, id);

      expect(result.map((service) => service.catalogItem?.name), [
        'Service 3',
        'Service 2',
        'Service 1',
      ]);
    });

    test('carries the whole service, not a projection of it', () async {
      final id = await seedClient(name: 'Ana');
      await seedService(
        clientId: id,
        catalogItemName: 'Pedicure',
        date: DateTime(2026, 6),
        value: 180,
        description: 'Sensitive skin',
      );

      final service = (await repository.getServiceHistory(ownerId, id)).single;

      expect(service.id, isNotEmpty);
      expect(service.value, 180);
      expect(service.description, 'Sensitive skin');
      expect(service.clientId, id);
    });

    test('never leaks another owner\'s services', () async {
      final id = await seedClient(name: 'Ana');
      await seedService(
        owner: otherOwnerId,
        clientId: id,
        catalogItemName: 'Not mine',
        date: DateTime(2026, 6),
      );

      expect(await repository.getServiceHistory(ownerId, id), isEmpty);
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
          catalogItemName: 'Service $month',
          date: DateTime(2026, month),
        );
      }

      final result = await repository.getServiceHistory(ownerId, id, limit: 2);

      expect(result, hasLength(2));
    });
  });

  group('getFirstServiceDate', () {
    test('returns the oldest service, not the newest', () async {
      final id = await seedClient(name: 'Ana');
      for (final month in [6, 2, 9]) {
        await seedService(
          clientId: id,
          catalogItemName: 'Service $month',
          date: DateTime(2026, month),
        );
      }

      expect(
        await repository.getFirstServiceDate(ownerId, id),
        DateTime(2026, 2),
      );
    });

    test('returns null for a client with no service at all', () async {
      final id = await seedClient(name: 'Ana');

      expect(await repository.getFirstServiceDate(ownerId, id), isNull);
    });

    test('never counts another owner\'s services', () async {
      final id = await seedClient(name: 'Ana');
      await seedService(
        owner: otherOwnerId,
        clientId: id,
        catalogItemName: 'Not mine',
        date: DateTime(2020),
      );

      expect(await repository.getFirstServiceDate(ownerId, id), isNull);
    });
  });

  group('add', () {
    test('writes the client and returns its new id', () async {
      final id = await repository.add(ownerId, clientUser(name: 'Ana'));

      final doc = await database.collection('clients').doc(id).get();
      expect(doc.exists, isTrue);
      expect(doc.data()!['name'], 'Ana');
      expect(doc.data()!['ownerId'], ownerId);
      expect(doc.data()!['status'], ClientStatus.active);
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
    test('counts every client of the owner, archived included', () async {
      await seedClient(name: 'Ana');
      await seedClient(name: 'Bruna');
      await seedClient(name: 'Carla', archived: true);
      await seedClient(owner: otherOwnerId, name: 'Dani');

      expect(await repository.count(ownerId), 3);
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

  group('archive', () {
    test('flags the client archived and keeps every personal field', () async {
      final id = await seedClient(name: 'Ana');

      await repository.archive(id);

      final data = (await database.collection('clients').doc(id).get()).data()!;
      expect(data['status'], ClientStatus.archived);
      expect(data['archivedAt'], isNotNull);
      expect(data['name'], 'Ana');
      expect(data['email'], isNotEmpty);
      expect(data['identifier'], isNotEmpty);
      expect(data['phones'], isNotEmpty);
    });

    test('keeps the document so the service history stays intact', () async {
      final id = await seedClient(name: 'Ana');

      await repository.archive(id);

      expect(
        (await database.collection('clients').doc(id).get()).exists,
        isTrue,
      );
    });

    test('drops the client out of the listing', () async {
      final id = await seedClient(name: 'Ana');

      await repository.archive(id);

      expect(await repository.getClients(ownerId), isEmpty);
    });

    test('moves the client into the archived listing', () async {
      final id = await seedClient(name: 'Ana');

      await repository.archive(id);

      final archived = await repository.getArchivedClients(ownerId);
      expect(archived.single.id, id);
      expect(archived.single.info.user.name, 'Ana');
      expect(archived.single.archivedAt, isNotNull);
    });

    test('restoring puts it back with its data intact', () async {
      final id = await seedClient(name: 'Ana');

      await repository.archive(id);
      await repository.restore(id);

      final result = await repository.getClients(ownerId);
      expect(result.single.info.user.name, 'Ana');
      expect(result.single.archivedAt, isNull);
      expect(await repository.getArchivedClients(ownerId), isEmpty);
    });

    test('an edit never brings an archived client back', () async {
      // `update` writes only the editable fields; carrying `status` would
      // silently unarchive.
      final id = await seedClient(name: 'Ana');
      await repository.archive(id);

      await repository.update(id, clientUser(name: 'Ana Maria'));

      final data = (await database.collection('clients').doc(id).get()).data()!;
      expect(data['status'], ClientStatus.archived);
      expect(data['name'], 'Ana Maria');
      expect(await repository.getClients(ownerId), isEmpty);
    });
  });

  group('delete', () {
    test('removes the document for good', () async {
      final id = await seedClient(name: 'Ana');

      await repository.delete(id);

      expect(
        (await database.collection('clients').doc(id).get()).exists,
        isFalse,
      );
    });

    test('deletes a client who still has services', () async {
      // The whole point: someone asking to be removed is usually someone
      // already served, so their own history must not bar the request.
      final id = await seedClient(name: 'Ana');
      await seedService(
        clientId: id,
        catalogItemName: 'Manicure',
        date: DateTime(2026, 6),
      );

      await repository.delete(id);

      expect(
        (await database.collection('clients').doc(id).get()).exists,
        isFalse,
      );
    });

    test('leaves the services untouched', () async {
      final id = await seedClient(name: 'Ana');
      await seedService(
        clientId: id,
        catalogItemName: 'Manicure',
        date: DateTime(2026, 6),
      );

      await repository.delete(id);

      final services = await database.collection('services').get();
      expect(services.docs, hasLength(1));
      // The dangling id stays: the per-client breakdown and the listing filter
      // group by it, so clearing it would drop these services out of both.
      expect(services.docs.single.data()['clientId'], id);
      expect(services.docs.single.data()['typeName'], 'Manicure');
    });
  });

  group('updateLastService after a deletion', () {
    test('swallows the missing document without reporting it', () async {
      // Editing a service whose client was deleted is a normal flow, not a
      // fault: reporting it would fill Crashlytics with expected noise.
      final id = await seedClient(name: 'Ana');
      await repository.delete(id);

      await repository.updateLastService(id, 'Manicure', DateTime(2026, 6));

      expect(crashlytics.loggedExceptions, isEmpty);
    });

    test('never recreates the deleted document', () async {
      final id = await seedClient(name: 'Ana');
      await repository.delete(id);

      await repository.updateLastService(id, 'Manicure', DateTime(2026, 6));

      expect(
        (await database.collection('clients').doc(id).get()).exists,
        isFalse,
      );
    });
  });

  group('counts', () {
    test('count includes archived clients, so archiving frees no slot', () async {
      await seedClient(name: 'Ana');
      await seedClient(name: 'Bruna', archived: true);

      expect(await repository.count(ownerId), 2);
    });

    test('countActive covers only what the listing shows', () async {
      await seedClient(name: 'Ana');
      await seedClient(name: 'Bruna', archived: true);

      expect(await repository.countActive(ownerId), 1);
    });

    test('countArchived covers only the archive', () async {
      await seedClient(name: 'Ana');
      await seedClient(name: 'Bruna', archived: true);

      expect(await repository.countArchived(ownerId), 1);
    });

    test('countServicesOf counts the services pointing at a client', () async {
      final id = await seedClient(name: 'Ana');
      await seedService(
        clientId: id,
        catalogItemName: 'Manicure',
        date: DateTime(2026, 6),
      );
      await seedService(
        clientId: id,
        catalogItemName: 'Pedicure',
        date: DateTime(2026, 7),
      );

      expect(await repository.countServicesOf(ownerId, id), 2);
      expect(await repository.countServicesOf(ownerId, 'other'), 0);
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

    test('archive reports a localized external error', () async {
      await expectLater(
        failing.archive('any'),
        ErrorWithMessage<ExternalError>(
          KaziLocalizations.current.errorToArchiveClient,
        ),
      );
    });

    test('delete reports a localized external error', () async {
      await expectLater(
        failing.delete('any'),
        ErrorWithMessage<ExternalError>(
          KaziLocalizations.current.errorToDeleteClient,
        ),
      );
    });
  });
}
