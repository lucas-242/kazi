import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/services/domain/crashlytics_service.dart';
import 'package:kazi/features/settings/data/repositories/firebase_user_settings_repository.dart';
import 'package:kazi/features/settings/domain/models/billing_cycle.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../../utils/test_helper.dart';
import 'firebase_user_settings_repository_test.mocks.dart';

@GenerateMocks([CrashlyticsService, FirebaseFirestore])
void main() {
  const userId = 'user-1';

  late FirebaseFirestore database;
  late FirebaseUserSettingsRepository repository;

  TestHelper.loadAppLocalizations();

  setUp(() {
    database = FakeFirebaseFirestore();
    repository = FirebaseUserSettingsRepository(
      database,
      MockCrashlyticsService(),
    );
  });

  Future<Map<String, dynamic>> readUser() async {
    final doc = await database.collection(repository.path).doc(userId).get();
    return doc.data() ?? {};
  }

  group('get', () {
    test(
      'Should return empty settings when the document does not exist',
      () async {
        final settings = await repository.get(userId);

        expect(settings.defaultCurrency, isNull);
        expect(settings.hasMigratedCurrency, isFalse);
        expect(settings.billingCycle, BillingCycle.monthlyDefault);
      },
    );

    test('Should read the stored billing cycle', () async {
      await repository.setBillingCycle(
        userId,
        const FortnightlyCycle(anchorDay: 5),
      );

      final settings = await repository.get(userId);

      expect(settings.billingCycle, const FortnightlyCycle(anchorDay: 5));
    });

    test(
      'Should default the cycle for a user who predates the setting',
      () async {
        await database.collection(repository.path).doc(userId).set({
          'defaultCurrency': 'BRL',
        });

        final settings = await repository.get(userId);

        expect(settings.billingCycle, BillingCycle.monthlyDefault);
        expect(settings.defaultCurrency, SupportedCurrency.brl);
      },
    );

    test(
      'Should default the cycle rather than throw on a corrupt value',
      () async {
        await database.collection(repository.path).doc(userId).set({
          BillingCycle.typeField: 'quarterly',
          BillingCycle.anchorField: 'whenever',
        });

        final settings = await repository.get(userId);

        expect(settings.billingCycle, BillingCycle.monthlyDefault);
      },
    );

    test('Should throw ExternalError when the read fails', () async {
      final failing = MockFirebaseFirestore();
      when(failing.collection(any)).thenThrow(Exception());

      expect(
        () => FirebaseUserSettingsRepository(
          failing,
          MockCrashlyticsService(),
        ).get(userId),
        throwsA(isA<ExternalError>()),
      );
    });
  });

  group('setBillingCycle', () {
    test('Should persist the type and the anchor', () async {
      await repository.setBillingCycle(
        userId,
        const WeeklyCycle(anchorWeekday: 3),
      );

      expect(await readUser(), {
        BillingCycle.typeField: 'weekly',
        BillingCycle.anchorField: 3,
      });
    });

    /// The document is shared with the currency and the migration flag, so the
    /// write has to merge — a plain `set` would wipe them and re-open the
    /// blocking migration gate on the next launch.
    test('Should leave the other settings untouched', () async {
      await repository.setDefaultCurrency(userId, SupportedCurrency.brl);
      await repository.markCurrencyMigrated(userId, migrated: 12);

      await repository.setBillingCycle(
        userId,
        const MonthlyCycle(anchorDay: 5),
      );

      final settings = await repository.get(userId);
      expect(settings.defaultCurrency, SupportedCurrency.brl);
      expect(settings.hasMigratedCurrency, isTrue);
      expect(settings.migratedServices, 12);
      expect(settings.billingCycle, const MonthlyCycle(anchorDay: 5));
    });

    test('Should replace a previously stored cycle', () async {
      await repository.setBillingCycle(
        userId,
        const WeeklyCycle(anchorWeekday: 3),
      );
      await repository.setBillingCycle(
        userId,
        const MonthlyCycle(anchorDay: 5),
      );

      expect(
        (await repository.get(userId)).billingCycle,
        const MonthlyCycle(anchorDay: 5),
      );
    });

    test('Should throw ExternalError when the write fails', () async {
      final failing = MockFirebaseFirestore();
      when(failing.collection(any)).thenThrow(Exception());

      expect(
        () => FirebaseUserSettingsRepository(
          failing,
          MockCrashlyticsService(),
        ).setBillingCycle(userId, BillingCycle.monthlyDefault),
        throwsA(isA<ExternalError>()),
      );
    });
  });
}
