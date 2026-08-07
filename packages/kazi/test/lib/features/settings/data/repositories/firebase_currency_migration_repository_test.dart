import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/services/domain/crashlytics_service.dart';
import 'package:kazi/features/settings/data/repositories/firebase_currency_migration_repository.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
import 'package:mockito/annotations.dart';

import '../../../../../utils/test_helper.dart';
import 'firebase_currency_migration_repository_test.mocks.dart';

@GenerateMocks([CrashlyticsService])
void main() {
  const userId = 'user-1';
  const otherUserId = 'user-2';

  late FirebaseFirestore database;
  late FirebaseCurrencyMigrationRepository repository;

  TestHelper.loadAppLocalizations();

  setUp(() {
    database = FakeFirebaseFirestore();
    repository = FirebaseCurrencyMigrationRepository(
      database,
      MockCrashlyticsService(),
    );
  });

  Future<void> addService({
    required String id,
    required String owner,
    String? currency,
    DateTime? date,
  }) async {
    await database.collection('services').doc(id).set({
      'userId': owner,
      'value': 100.0,
      'discountPercent': 0.0,
      'typeId': 'type-1',
      'date': Timestamp.fromDate(date ?? DateTime.utc(2025, 6, 15)),
      if (currency != null) 'currency': currency,
    });
  }

  Future<Map<String, dynamic>> readService(String id) async {
    final doc = await database.collection('services').doc(id).get();
    return doc.data()!;
  }

  group('backfillCurrency', () {
    test('stamps the currency and a rate anchor on legacy services', () async {
      await addService(id: 'a', owner: userId);

      final migrated = await repository.backfillCurrency(
        userId,
        SupportedCurrency.brl,
      );

      final data = await readService('a');
      expect(migrated, 1);
      expect(data['currency'], 'BRL');
      // Anchored to the service's own date, not to the day of the migration.
      expect(data['rateDate'], '2025-06-15');
    });

    test('leaves services that already declare a currency untouched', () async {
      await addService(id: 'a', owner: userId, currency: 'USD');

      final migrated = await repository.backfillCurrency(
        userId,
        SupportedCurrency.brl,
      );

      expect(migrated, 0);
      expect((await readService('a'))['currency'], 'USD');
    });

    test('never touches another user\'s data', () async {
      await addService(id: 'mine', owner: userId);
      await addService(id: 'theirs', owner: otherUserId);

      await repository.backfillCurrency(userId, SupportedCurrency.brl);

      expect((await readService('theirs'))['currency'], isNull);
    });

    test('backfills service types too', () async {
      await database.collection('serviceTypes').doc('t1').set({
        'userId': userId,
        'name': 'Cut',
        'defaultValue': 50.0,
      });

      final migrated = await repository.backfillCurrency(
        userId,
        SupportedCurrency.brl,
      );

      final type = await database.collection('serviceTypes').doc('t1').get();
      expect(migrated, 1);
      expect(type.data()!['currency'], 'BRL');
      // Types carry no amount history, so they need no rate anchor.
      expect(type.data()!.containsKey('rateDate'), isFalse);
    });

    test('pages past the batch limit', () async {
      // More than the 400-document page size, so the run spans several batches.
      for (var i = 0; i < 450; i++) {
        await addService(id: 'service-${i.toString().padLeft(4, '0')}',
            owner: userId,);
      }

      final migrated = await repository.backfillCurrency(
        userId,
        SupportedCurrency.brl,
      );

      expect(migrated, 450);
      expect((await readService('service-0449'))['currency'], 'BRL');
    });

    test('is idempotent, so an interrupted run can be repeated', () async {
      await addService(id: 'a', owner: userId);

      final first = await repository.backfillCurrency(
        userId,
        SupportedCurrency.brl,
      );
      final second = await repository.backfillCurrency(
        userId,
        SupportedCurrency.usd,
      );

      expect(first, 1);
      expect(second, 0);
      // The retry must not relabel data the first run already stamped.
      expect((await readService('a'))['currency'], 'BRL');
    });
  });
}
