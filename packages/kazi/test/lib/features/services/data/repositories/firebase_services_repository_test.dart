import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/data/repositories/firebase_services_repository.dart';
import 'package:kazi/features/services/data/repositories/models/firebase_service_model.dart';
import 'package:kazi/core/services/domain/crashlytics_service.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../../mocks/mocks.dart';
import '../../../../../utils/firebase_test_helper.dart';
import '../../../../../utils/test_helper.dart';
import '../../../../../utils/test_matchers.dart';
import 'firebase_services_repository_test.mocks.dart';

@GenerateMocks([FirebaseFirestore, CrashlyticsService])
void main() {
  late FirebaseFirestore database;
  late FirebaseServicesRepository repository;
  late FirebaseTestHelper firebaseHelper;
  late MockCrashlyticsService crashlyticsService;

  TestHelper.loadAppLocalizations();

  setUp(() async {
    database = FakeFirebaseFirestore();
    crashlyticsService = MockCrashlyticsService();
    repository = FirebaseServicesRepository(database, crashlyticsService);
    firebaseHelper = FirebaseTestHelper(database, repository.path);
  });

  group('Add Service', () {
    test('Should add X services', () async {
      const quantity = 3;

      final response = await repository.add(serviceMock, quantity);
      expect(response, everyElement(IsTheSameService(serviceMock)));

      final serviceCount = await firebaseHelper.count();
      expect(serviceCount, quantity);

      final servicesAdded = await firebaseHelper.getAll(
        (snapshot, data) =>
            FirebaseServiceModel.fromMap(data).copyWith(id: snapshot.id),
      );
      expect(
        response,
        containsAll(
          servicesAdded.map(
            (service) => IsTheSameService(service, checkEqualsId: true),
          ),
        ),
      );
    });

    test('Should throw ExternalError with errorToAddService message', () {
      database = MockFirebaseFirestore();
      repository = FirebaseServicesRepository(database, crashlyticsService);
      when(database.collection(repository.path)).thenThrow(Exception());

      expectLater(
        repository.add(serviceMock),
        ErrorWithMessage<ExternalError>(
          KaziLocalizations.current.errorToAddService,
        ),
      );
    });
  });

  group('Count Services', () {
    final totalServicesToUser = servicesMock.length + 1;
    const catalogItemId = 'abcde';
    const totalServicesToUserWithTargetTypeId = 1;

    setUp(() async {
      for (var service in servicesMock) {
        //Service to logged user
        await firebaseHelper.add(
          service.toMap(),
          (snapshot) => service.copyWith(id: snapshot.id),
        );

        //Service to another user
        await firebaseHelper.add(
          service.copyWith(userId: 'aaaa9999').toMap(),
          (snapshot) => service.copyWith(id: snapshot.id),
        );
      }

      //Service to logged user with different catalogItemId
      await firebaseHelper.add(
        serviceMock.copyWith(catalogItemId: catalogItemId).toMap(),
        (snapshot) => serviceMock.copyWith(id: snapshot.id),
      );
    });

    test('Should count all user services', () async {
      final response = await repository.count(serviceMock.userId);
      expect(response, totalServicesToUser);
    });

    test('Should count user services by type', () async {
      final response = await repository.count(serviceMock.userId, catalogItemId);
      expect(response, totalServicesToUserWithTargetTypeId);
    });

    test(
      'Should throw ExternalError with message errorToCountServices',
      () async {
        database = MockFirebaseFirestore();
        repository = FirebaseServicesRepository(database, crashlyticsService);
        when(database.collection(repository.path)).thenThrow(Exception());

        expect(
          repository.count(serviceMock.userId),
          ErrorWithMessage<ExternalError>(
            KaziLocalizations.current.errorToCountServices,
          ),
        );
      },
    );
  });

  group('Delete Service', () {
    late String serviceId;

    setUp(() async {
      final response = await firebaseHelper.add(
        serviceMock.toMap(),
        (snapshot) => serviceMock.copyWith(id: snapshot.id),
      );
      serviceId = response.id;
    });

    test('Should delete service', () async {
      // Awaited, not just expected to complete: deleting reads the service
      // first, to know whose counters have to give the money back, so the
      // write no longer lands within the same microtask.
      await repository.delete(serviceId);

      final response = await firebaseHelper.get(
        serviceId,
        (snapshot, data) =>
            FirebaseServiceModel.fromMap(data).copyWith(id: snapshot.id),
      );

      expect(response, isNull);
    });

    test(
      'Should throw ExternalError with message errorToDeleteService',
      () async {
        database = MockFirebaseFirestore();
        repository = FirebaseServicesRepository(database, crashlyticsService);
        when(database.collection(repository.path)).thenThrow(Exception());

        expect(
          repository.delete(serviceId),
          ErrorWithMessage<ExternalError>(
            KaziLocalizations.current.errorToDeleteService,
          ),
        );
      },
    );
  });

  group('Get Services', () {
    final userNumberOfServices = servicesMock.length;

    setUp(() async {
      for (var service in servicesMock) {
        //Service to logged user
        await firebaseHelper.add(
          service.toMap(),
          (snapshot) => service.copyWith(id: snapshot.id),
        );

        //Service to another user
        await firebaseHelper.add(
          service.copyWith(userId: 'aaaa9999').toMap(),
          (snapshot) => service.copyWith(id: snapshot.id),
        );
      }
    });

    test('Should get all user services', () async {
      final response = await repository.get(
        serviceMock.userId,
        serviceMock.date,
      );
      expect(response, hasLength(userNumberOfServices));
      expect(
        response,
        everyElement(
          predicate((e) => e is Service && e.userId == serviceMock.userId),
        ),
      );
    });

    test('Should get user services between two dates', () async {
      final servicesRange = servicesMock.getRange(2, 4);
      final startDate = servicesRange.first.date;
      final endDate = servicesRange.last.date;

      final response = await repository.get(
        serviceMock.userId,
        startDate,
        endDate,
      );

      expect(response, hasLength(servicesRange.length));
      expect(
        response,
        everyElement(
          predicate(
            (e) =>
                e is Service &&
                e.userId == serviceMock.userId &&
                (e.date.isAfter(startDate) ||
                    e.date.isAtSameMomentAs(startDate)) &&
                (e.date.isBefore(endDate) || e.date.isAtSameMomentAs(endDate)),
          ),
        ),
      );
    });

    test(
      'Should throw ExternalError with message errorToGetServices',
      () async {
        database = MockFirebaseFirestore();
        repository = FirebaseServicesRepository(database, crashlyticsService);
        when(database.collection(repository.path)).thenThrow(Exception());

        expect(
          repository.get(serviceMock.userId, serviceMock.date),
          ErrorWithMessage<ExternalError>(
            KaziLocalizations.current.errorToGetServices,
          ),
        );
      },
    );
  });

  group('setReceivedAt', () {
    Future<String> addService({double value = 100}) async {
      final response = await firebaseHelper.add(
        serviceMock.copyWith(value: value).toMap(),
        (snapshot) => serviceMock.copyWith(id: snapshot.id),
      );
      return response.id;
    }

    Future<Map<String, dynamic>> read(String id) async {
      final doc = await database.collection(repository.path).doc(id).get();
      return doc.data()!;
    }

    test('Should stamp the given services', () async {
      final id = await addService();

      await repository.setReceivedAt([id], DateTime(2026, 9, 5));

      final restored = FirebaseServiceModel.fromMap(await read(id));
      expect(restored.receivedAt, DateTime(2026, 9, 5));
    });

    test('Should clear the stamp when passed null', () async {
      final id = await addService();
      await repository.setReceivedAt([id], DateTime(2026, 9, 5));

      await repository.setReceivedAt([id], null);

      final restored = FirebaseServiceModel.fromMap(await read(id));
      expect(restored.receivedAt, isNull);
    });

    /// The whole reason this is a field-scoped `batch.update` rather than a
    /// full `update(Service)`: marking a service as paid must not rewrite its
    /// value, its date or its exchange-rate anchor from a stale in-memory copy.
    test('Should touch only receivedAt', () async {
      final id = await addService(value: 250);
      final before = await read(id);

      await repository.setReceivedAt([id], DateTime(2026, 9, 5));

      final after = await read(id);
      expect(after['value'], before['value']);
      expect(after['date'], before['date']);
      expect(after['currency'], before['currency']);
      expect(after['rateDate'], before['rateDate']);
      expect(after['discountPercent'], before['discountPercent']);
    });

    /// Firestore caps a batch at 500 writes, so a heavy cycle has to be split.
    test('Should stamp more services than fit in one batch', () async {
      final ids = <String>[];
      for (var i = 0; i < 450; i++) {
        ids.add(await addService());
      }

      await repository.setReceivedAt(ids, DateTime(2026, 9, 5));

      for (final id in ids) {
        expect(
          FirebaseServiceModel.fromMap(await read(id)).receivedAt,
          DateTime(2026, 9, 5),
          reason: 'service $id was left unstamped',
        );
      }
    });

    test('Should do nothing for an empty list', () async {
      final failing = MockFirebaseFirestore();

      await FirebaseServicesRepository(
        failing,
        crashlyticsService,
      ).setReceivedAt([], DateTime(2026, 9, 5));

      verifyNever(failing.batch());
    });

    test(
      'Should throw ExternalError with message errorToMarkReceived',
      () async {
        final failing = MockFirebaseFirestore();
        when(failing.batch()).thenThrow(Exception());

        expect(
          FirebaseServicesRepository(
            failing,
            crashlyticsService,
          ).setReceivedAt(['a'], DateTime(2026, 9, 5)),
          ErrorWithMessage<ExternalError>(
            KaziLocalizations.current.errorToMarkReceived,
          ),
        );
      },
    );
  });

  group('Update Service Type', () {
    late String serviceId;

    setUp(() async {
      final response = await firebaseHelper.add(
        serviceMock.toMap(),
        (snapshot) => serviceMock.copyWith(id: snapshot.id),
      );
      serviceId = response.id;
    });

    test('Should update service type', () async {
      final toUpdate = serviceMock.copyWith(id: serviceId, value: 9999);
      await repository.update(toUpdate);

      final response = await firebaseHelper.get(
        toUpdate.id,
        (snapshot, data) =>
            FirebaseServiceModel.fromMap(data).copyWith(id: snapshot.id),
      );
      expect(response, IsTheSameService(toUpdate, checkEqualsId: true));
    });

    test(
      'Should throw ExternalError with message errorToUpdateService',
      () async {
        database = MockFirebaseFirestore();
        repository = FirebaseServicesRepository(database, crashlyticsService);
        when(database.collection(repository.path)).thenThrow(Exception());

        expect(
          repository.update(serviceMock),
          ErrorWithMessage<ExternalError>(
            KaziLocalizations.current.errorToUpdateService,
          ),
        );
      },
    );
  });
}
