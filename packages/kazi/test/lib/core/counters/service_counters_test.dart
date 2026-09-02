import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/counters/counters_backfill.dart';
import 'package:kazi/core/services/domain/crashlytics_service.dart';
import 'package:kazi/features/services/data/repositories/firebase_services_repository.dart';
import 'package:kazi/features/services/data/repositories/models/firebase_service_model.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:mockito/annotations.dart';

import '../../../utils/test_helper.dart';
import 'service_counters_test.mocks.dart';

/// The counters are the only numbers in the app that are stored rather than
/// computed, so they are the only ones that can be wrong while looking right.
@GenerateMocks([CrashlyticsService])
void main() {
  late FakeFirebaseFirestore database;
  late FirebaseServicesRepository repository;
  late CountersBackfill backfill;

  TestHelper.loadAppLocalizations();

  const userId = 'user-1';
  const clientId = 'client-1';
  const itemId = 'item-1';

  Service service({
    double value = 100,
    double commissionPercent = 40,
    String currency = 'USD',
    String? client = clientId,
    String item = itemId,
    String id = '',
  }) => Service(
    id: id,
    value: value,
    commissionPercent: commissionPercent,
    currency: currency,
    rateDate: '2026-08-20',
    catalogItemId: item,
    clientId: client,
    clientName: client == null ? null : 'Marina',
    date: DateTime(2026, 8, 20),
    userId: userId,
  );

  Future<Map<String, dynamic>> read(String collection, String id) async =>
      (await database.collection(collection).doc(id).get()).data() ?? {};

  double generated(Map<String, dynamic> data, [String currency = 'USD']) =>
      ((data['totals'] as Map)[currency] as Map)['generated'] as double;

  double commission(Map<String, dynamic> data, [String currency = 'USD']) =>
      ((data['totals'] as Map)[currency] as Map)['commission'] as double;

  setUp(() async {
    database = FakeFirebaseFirestore();
    repository = FirebaseServicesRepository(
      database,
      MockCrashlyticsService(),
    );
    backfill = CountersBackfill(database, MockCrashlyticsService());

    await database.collection('clients').doc(clientId).set({
      'ownerId': userId,
      'name': 'Marina',
    });
    await database.collection('serviceTypes').doc(itemId).set({
      'userId': userId,
      'name': 'Alongamento',
    });
  });

  group('adding a service', () {
    test('Should raise both counters by what it is worth', () async {
      await repository.add(service());

      final client = await read('clients', clientId);
      expect(client['servicesCount'], 1);
      expect(generated(client), 100);
      expect(commission(client), 40);
      expect((client['mostUsedServices'] as Map)[itemId], 1);

      final item = await read('serviceTypes', itemId);
      expect(item['usageCount'], 1);
      expect(generated(item), 100);
    });

    test('Should count a quantity as that many services', () async {
      await repository.add(service(), 3);

      expect((await read('clients', clientId))['servicesCount'], 3);
      expect(generated(await read('serviceTypes', itemId)), 300);
    });

    // A walk-in has no client, and the catalog item still has to be counted.
    test('Should skip the client when the service has none', () async {
      await repository.add(service(client: null));

      expect((await read('clients', clientId))['servicesCount'], isNull);
      expect((await read('serviceTypes', itemId))['usageCount'], 1);
    });

    // Never one scalar: 100 BRL and 100 USD do not add up to 200 of anything.
    test('Should keep each currency apart', () async {
      await repository.add(service());
      await repository.add(service(currency: 'BRL', value: 500));

      final client = await read('clients', clientId);
      expect(generated(client), 100);
      expect(generated(client, 'BRL'), 500);
      expect(client['servicesCount'], 2);
    });
  });

  group('editing a service', () {
    test('Should reverse the old contribution before applying the new', () async {
      final added = await repository.add(service());
      await repository.update(added.single.copyWith(value: 250));

      final client = await read('clients', clientId);
      expect(client['servicesCount'], 1);
      expect(generated(client), 250);
      expect(commission(client), 100);
    });

    test('Should move the money when the service changes client', () async {
      await database.collection('clients').doc('client-2').set({
        'ownerId': userId,
        'name': 'Júlia',
      });
      final added = await repository.add(service());

      await repository.update(
        added.single.copyWith(clientId: 'client-2', clientName: 'Júlia'),
      );

      expect((await read('clients', clientId))['servicesCount'], 0);
      expect(generated(await read('clients', clientId)), 0);
      expect((await read('clients', 'client-2'))['servicesCount'], 1);
    });
  });

  group('deleting a service', () {
    test('Should give the money back', () async {
      final added = await repository.add(service());
      await repository.delete(added.single.id);

      final client = await read('clients', clientId);
      expect(client['servicesCount'], 0);
      expect(generated(client), 0);
      expect((await read('serviceTypes', itemId))['usageCount'], 0);
    });
  });

  // Receiving a payment does not generate value; only the situation changes.
  group('marking received', () {
    test('Should leave the counters alone', () async {
      final added = await repository.add(service());
      await repository.setReceivedAt([added.single.id], DateTime(2026, 9, 5));

      expect((await read('clients', clientId))['servicesCount'], 1);
      expect(generated(await read('clients', clientId)), 100);
    });
  });

  // A client deleted while their services stayed must not be resurrected by
  // an increment — the one thing the archiving rules are explicit about.
  group('a record that is gone', () {
    test('Should not be recreated by its own counters', () async {
      final added = await repository.add(service());
      await database.collection('clients').doc(clientId).delete();

      await repository.delete(added.single.id);

      final client = await database.collection('clients').doc(clientId).get();
      expect(client.exists, isFalse);
    });
  });

  group('the backfill', () {
    Future<void> seedRaw(Service value) async {
      await database
          .collection('services')
          .add(FirebaseServiceModel.fromService(value).toMap());
    }

    test('Should rebuild the counters from the services themselves', () async {
      await seedRaw(service());
      await seedRaw(service(value: 50));
      await seedRaw(service(currency: 'BRL', value: 200));

      await backfill.run(userId);

      final client = await read('clients', clientId);
      expect(client['servicesCount'], 3);
      expect(generated(client), 150);
      expect(generated(client, 'BRL'), 200);
      expect((client['mostUsedServices'] as Map)[itemId], 3);
    });

    // Written whole, never added to: a repair that doubles what it repairs is
    // worse than the drift it was fixing.
    test('Should be safe to run twice', () async {
      await seedRaw(service());

      await backfill.run(userId);
      await backfill.run(userId);

      expect((await read('clients', clientId))['servicesCount'], 1);
      expect(generated(await read('clients', clientId)), 100);
    });

    test('Should repair counters that drifted', () async {
      await seedRaw(service());
      await database.collection('clients').doc(clientId).update({
        'servicesCount': 99,
      });

      await backfill.run(userId);

      expect((await read('clients', clientId))['servicesCount'], 1);
    });

    test('Should stamp the run so it does not repeat', () async {
      expect(await backfill.isPending(userId), isTrue);

      await backfill.run(userId);

      expect(await backfill.isPending(userId), isFalse);
    });

    test('Should skip a record that no longer exists', () async {
      await seedRaw(service());
      await database.collection('clients').doc(clientId).delete();

      await backfill.run(userId);

      final client = await database.collection('clients').doc(clientId).get();
      expect(client.exists, isFalse);
      expect((await read('serviceTypes', itemId))['usageCount'], 1);
    });
  });
}
