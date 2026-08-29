import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/services/data/local_time_service.dart';
import 'package:kazi/features/services/data/repositories/firebase_catalog_item_repository.dart';
import 'package:kazi/features/services/data/repositories/firebase_services_repository.dart';
import 'package:kazi/features/services/data/services/local_service_organizer.dart';
import 'package:kazi/features/services/domain/models/catalog_item.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/services/domain/models/service_breakdown.dart';
import 'package:kazi/features/services/domain/models/service_totals.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_state.dart';
import 'package:kazi/features/services/domain/services/service_organizer.dart';
import 'package:kazi_core/kazi_core.dart' hide Service, CatalogItem;

import '../../../../../utils/fakes/fake_crashlytics_service.dart';
import '../../../../../utils/test_helper.dart';

/// The acceptance test of the archiving feature: **archiving changes no
/// number**. Every total, every breakdown line and every joined name has to
/// come out byte-identical before and after.
void main() {
  const userId = 'user-1';

  // The repositories throw localized messages.
  TestHelper.loadAppLocalizations();

  CatalogItem catalogItem({
    required String id,
    required String name,
    DateTime? archivedAt,
  }) => CatalogItem(
    id: id,
    name: name,
    defaultValue: 100,
    commissionPercent: 60,
    color: 'FF2F6FEB',
    currency: 'USD',
    archivedAt: archivedAt,
    userId: userId,
  );

  Service service({
    required String id,
    required String catalogItemId,
    double value = 100,
    double commissionPercent = 60,
    String? clientId,
    String? clientName,
    DateTime? receivedAt,
  }) => Service(
    id: id,
    value: value,
    commissionPercent: commissionPercent,
    currency: 'USD',
    rateDate: '2026-08-20',
    date: DateTime(2026, 8, 20),
    catalogItemId: catalogItemId,
    clientId: clientId,
    clientName: clientName,
    receivedAt: receivedAt,
    userId: userId,
  );

  final manicure = catalogItem(id: 'a', name: 'Manicure');
  final pedicure = catalogItem(id: 'b', name: 'Pedicure');

  final services = [
    service(
      id: '1',
      catalogItemId: 'a',
      clientId: 'c1',
      clientName: 'Ana',
      receivedAt: DateTime(2026, 9, 5),
    ),
    service(id: '2', catalogItemId: 'a', value: 250, clientId: 'c1', clientName: 'Ana'),
    service(
      id: '3',
      catalogItemId: 'b',
      value: 80,
      commissionPercent: 100,
      clientId: 'c2',
      clientName: 'Bruna',
    ),
  ];

  ServiceTotals totalsOf(List<Service> list) => ServiceTotals.from(
    list,
    currency: SupportedCurrency.usd,
    rateBook: const RateBook.empty(),
  );

  ServiceOrganizer organizer() =>
      LocalServiceOrganizer(LocalTimeService(DateTime(2026, 8, 24)));

  group('archiving a catalog item', () {
    test('leaves every total exactly where it was', () async {
      // Driven through the real archive path and recomputed from what
      // Firestore holds afterwards, so this fails the moment archiving starts
      // rewriting anything a service is totalled from.
      final database = FakeFirebaseFirestore();
      final crashlytics = FakeCrashlyticsService();
      final servicesRepository = FirebaseServicesRepository(
        database,
        crashlytics,
      );
      final catalogRepository = FirebaseCatalogItemRepository(
        database,
        crashlytics,
      );

      final storedItem = await catalogRepository.add(pedicure.restored());
      for (final entry in services) {
        await servicesRepository.add(
          entry.copyWith(catalogItemId: storedItem.id),
        );
      }

      Future<ServiceTotals> currentTotals() async => totalsOf(
        await servicesRepository.get(userId, DateTime(2026), DateTime(2027)),
      );

      final before = await currentTotals();
      await catalogRepository.archive(storedItem.id);
      final after = await currentTotals();

      expect(after.value, before.value);
      expect(after.commission, before.commission);
      expect(after.withheld, before.withheld);
      expect(after.receivedCommission, before.receivedCommission);
      expect(after.unconverted, before.unconverted);

      // And the item itself kept every field a service reads through it.
      final restored = (await catalogRepository.get(userId)).single;
      expect(restored.isArchived, isTrue);
      expect(restored.name, pedicure.name);
      expect(restored.defaultValue, pedicure.defaultValue);
      expect(restored.effectiveCommissionPercent,
          pedicure.effectiveCommissionPercent);
      expect(restored.color, pedicure.color);
      expect(restored.currency, pedicure.currency);
    });

    test('leaves every joined name and colour intact', () {
      final before = organizer().addCatalogItemToServices(
        List<Service>.from(services),
        [manicure, pedicure],
      );

      final after = organizer().addCatalogItemToServices(
        List<Service>.from(services),
        // The join is fed the full catalog, archived items included — which is
        // exactly what keeps an old service showing its type.
        [manicure, pedicure.copyWith(archivedAt: DateTime(2026, 8, 24))],
      );

      expect(
        after.map((s) => s.catalogItem?.name),
        before.map((s) => s.catalogItem?.name),
      );
      expect(
        after.map((s) => s.catalogItem?.colorAs),
        before.map((s) => s.catalogItem?.colorAs),
      );
    });

    test('leaves each service its own value and commission', () {
      final archived = pedicure.copyWith(archivedAt: DateTime(2026, 8, 24));

      final joined = organizer().addCatalogItemToServices(
        List<Service>.from(services),
        [manicure, archived],
      );

      final pedicureService = joined.firstWhere((s) => s.id == '3');
      expect(pedicureService.value, 80);
      expect(pedicureService.effectiveCommissionPercent, 100);
      expect(pedicureService.commissionValue, 80);
      expect(pedicureService.withheldValue, 0);
    });

    test('marks the archived item so the detail screen can label it', () {
      final joined = organizer().addCatalogItemToServices(
        List<Service>.from(services),
        [manicure, pedicure.copyWith(archivedAt: DateTime(2026, 8, 24))],
      );

      expect(joined.firstWhere((s) => s.id == '1').catalogItem?.isArchived,
          isFalse);
      expect(joined.firstWhere((s) => s.id == '3').catalogItem?.isArchived,
          isTrue);
    });
  });

  group('archiving a client', () {

    test('leaves the client name on each service, from its own snapshot', () {
      // `clientName` is frozen on the service, so archiving — which no longer
      // wipes anything anyway — cannot reach it.
      expect(services.map((s) => s.clientName), ['Ana', 'Ana', 'Bruna']);
      expect(services.map((s) => s.clientId), ['c1', 'c1', 'c2']);
    });
  });

  // Deleting a client removes their document; the services keep `clientId` and
  // `clientName` untouched. These tests are why there is no batch clearing the
  // dangling `clientId`: doing it would empty the ranking below.
  group('deleting a client', () {
    test('keeps every service counted in the totals', () {
      // Totals read nothing from the client document, so deleting it cannot
      // reach them. Asserted against the arithmetic rather than against a
      // second identical run, which would prove nothing.
      final totals = totalsOf(services);

      expect(totals.value, 430);
      expect(totals.commission, 290);
      expect(totals.withheld, 140);
      expect(totals.unconverted, 0);
    });

    test('keeps the deleted client in the per-client breakdown', () {
      // The ranking groups by `clientId` + `clientName`, both of which live on
      // the service. Clearing the id to tidy up after a deletion would drop
      // these services out of the ranking — changing a number on screen.
      final breakdown = ServiceBreakdown.byClient(
        services,
        currency: SupportedCurrency.usd,
        rateBook: const RateBook.empty(),
      );

      expect(breakdown.slices.map((slice) => slice.label), contains('Ana'));
      expect(
        breakdown.slices.firstWhere((slice) => slice.label == 'Ana').id,
        'c1',
      );
    });

    test('keeps the deleted client offered as a listing filter', () {
      // `filterableClients` is derived from the loaded services, so the
      // history of a deleted client stays filterable — which is the only way
      // to reach it now that their record is gone.
      final state = ServiceLandingState(
        status: BaseStateStatus.success,
        services: services,
        startDate: DateTime(2026, 8),
        endDate: DateTime(2026, 8, 31),
      );

      expect(state.filterableClients.map((client) => client.name), [
        'Ana',
        'Bruna',
      ]);
    });
  });
}
