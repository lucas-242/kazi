import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/data/repositories/firebase_services_repository.dart';
import 'package:kazi/features/services/data/repositories/models/firebase_service_model.dart';
import 'package:kazi/features/services/domain/models/clock_time.dart';
import 'package:kazi/core/services/domain/crashlytics_service.dart';
import 'package:kazi/features/services/domain/errors/services_error.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../../mocks/mocks.dart';
import '../../../../../utils/firebase_test_helper.dart';
import '../../../../../utils/test_helper.dart';
import '../../../../../utils/test_matchers.dart';
import 'firebase_services_repository_test.mocks.dart';
import '../../../../../utils/fakes/fake_firestore.dart';
import '../../../../../utils/fakes/fake_time_service.dart';

@GenerateMocks([FirebaseFirestore, CrashlyticsService])
void main() {
  late FirebaseFirestore database;
  late FirebaseServicesRepository repository;
  late FirebaseTestHelper firebaseHelper;
  late MockCrashlyticsService crashlyticsService;

  TestHelper.loadAppLocalizations();

  setUp(() async {
    database = FakeFirestore();
    crashlyticsService = MockCrashlyticsService();
    repository = FirebaseServicesRepository(
      database,
      crashlyticsService,
      FakeTimeService(DateTime(2026, 12, 31)),
    );
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

    test('Should fail with errorToAddService', () {
      database = MockFirebaseFirestore();
      repository = FirebaseServicesRepository(
        database,
        crashlyticsService,
        FakeTimeService(DateTime(2026, 12, 31)),
      );
      when(database.collection(repository.path)).thenThrow(Exception());

      expectLater(
        repository.add(serviceMock),
        failsWith(ServicesFailure.add),
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
      final response = await repository.count(
        serviceMock.userId,
        catalogItemId,
      );
      expect(response, totalServicesToUserWithTargetTypeId);
    });

    test(
      'Should fail with errorToCountServices',
      () async {
        database = MockFirebaseFirestore();
        repository = FirebaseServicesRepository(
          database,
          crashlyticsService,
          FakeTimeService(DateTime(2026, 12, 31)),
        );
        when(database.collection(repository.path)).thenThrow(Exception());

        expect(
          repository.count(serviceMock.userId),
          failsWith(ServicesFailure.count),
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
      'Should fail with errorToDeleteService',
      () async {
        database = MockFirebaseFirestore();
        repository = FirebaseServicesRepository(
          database,
          crashlyticsService,
          FakeTimeService(DateTime(2026, 12, 31)),
        );
        when(database.collection(repository.path)).thenThrow(Exception());

        expect(
          repository.delete(serviceId),
          failsWith(ServicesFailure.delete),
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
      'Should fail with errorToGetServices',
      () async {
        database = MockFirebaseFirestore();
        repository = FirebaseServicesRepository(
          database,
          crashlyticsService,
          FakeTimeService(DateTime(2026, 12, 31)),
        );
        when(database.collection(repository.path)).thenThrow(Exception());

        expect(
          repository.get(serviceMock.userId, serviceMock.date),
          failsWith(ServicesFailure.load),
        );
      },
    );
  });

  group('getMultiDay', () {
    Future<String> seed(FirebaseServiceModel service) async =>
        (await firebaseHelper.add(
          service.toMap(),
          (snapshot) => service.copyWith(id: snapshot.id),
        )).id;

    FirebaseServiceModel booked(DateTime date, Duration duration) =>
        serviceMock.copyWith(
          date: date,
          startTime: const ClockTime(22, 0),
          duration: duration,
        );

    test('Should return only multi-day services dated in the window', () async {
      final spanning = await seed(
        booked(DateTime(2026, 9, 27), const Duration(hours: 4)),
      );
      await seed(booked(DateTime(2026, 9, 27), const Duration(hours: 1)));
      await seed(booked(DateTime(2026, 8, 3), const Duration(hours: 4)));
      await seed(serviceMock.copyWith(date: DateTime(2026, 9, 27)));

      final result = await repository.getMultiDay(
        serviceMock.userId,
        DateTime(2026, 9, 2),
        DateTime(2026, 9, 28),
      );

      expect(result.map((service) => service.id), [spanning]);
      expect(result.single.isMultiDay, isTrue);
    });

    test('Should leave out other users', () async {
      await seed(
        booked(
          DateTime(2026, 9, 27),
          const Duration(hours: 4),
        ).copyWith(userId: 'someone-else'),
      );

      final result = await repository.getMultiDay(
        serviceMock.userId,
        DateTime(2026, 9, 2),
        DateTime(2026, 9, 28),
      );

      expect(result, isEmpty);
    });
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
        FakeTimeService(DateTime(2026, 12, 31)),
      ).setReceivedAt([], DateTime(2026, 9, 5));

      verifyNever(failing.batch());
    });

    test(
      'Should fail with errorToMarkReceived',
      () async {
        final failing = MockFirebaseFirestore();
        when(failing.batch()).thenThrow(Exception());

        expect(
          FirebaseServicesRepository(
            failing,
            crashlyticsService,
            FakeTimeService(DateTime(2026, 12, 31)),
          ).setReceivedAt(['a'], DateTime(2026, 9, 5)),
          failsWith(ServicesFailure.markReceived),
        );
      },
    );
  });

  group('setCancelledAt', () {
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

    test('Should call the service off', () async {
      final id = await addService();

      await repository.setCancelledAt(id, DateTime(2026, 9, 10));

      final restored = FirebaseServiceModel.fromMap(await read(id));
      expect(restored.cancelledAt, DateTime(2026, 9, 10));
      expect(restored.isCancelled, isTrue);
    });

    test('Should put it back in force when passed null', () async {
      final id = await addService();
      await repository.setCancelledAt(id, DateTime(2026, 9, 10));

      await repository.setCancelledAt(id, null);

      expect(FirebaseServiceModel.fromMap(await read(id)).isCancelled, isFalse);
    });

    /// Field-scoped for the same reason `setReceivedAt` is: cancelling must not
    /// rewrite the value, the date or the exchange-rate anchor from a stale
    /// in-memory copy — and it must leave the payment stamp where it is.
    test('Should touch only cancelledAt', () async {
      final id = await addService(value: 250);
      await repository.setReceivedAt([id], DateTime(2026, 9, 5));
      final before = await read(id);

      await repository.setCancelledAt(id, DateTime(2026, 9, 10));

      final after = await read(id);
      expect(after['value'], before['value']);
      expect(after['date'], before['date']);
      expect(after['currency'], before['currency']);
      expect(after['rateDate'], before['rateDate']);
      expect(after['receivedAt'], before['receivedAt']);
    });

    test(
      'Should fail with errorToCancelService',
      () async {
        final failing = MockFirebaseFirestore();
        when(failing.collection(any)).thenThrow(Exception());

        expect(
          FirebaseServicesRepository(
            failing,
            crashlyticsService,
            FakeTimeService(DateTime(2026, 12, 31)),
          ).setCancelledAt('a', DateTime(2026, 9, 10)),
          failsWith(ServicesFailure.cancel),
        );
      },
    );
  });

  group('setFinishedAt', () {
    Future<String> addService() async {
      final response = await firebaseHelper.add(
        serviceMock.toMap(),
        (snapshot) => serviceMock.copyWith(id: snapshot.id),
      );
      return response.id;
    }

    Future<Map<String, dynamic>> read(String id) async {
      final doc = await database.collection(repository.path).doc(id).get();
      return doc.data()!;
    }

    test('Should stamp the service as finished', () async {
      final id = await addService();

      await repository.setFinishedAt(id, DateTime(2026, 9, 28, 16));

      final restored = FirebaseServiceModel.fromMap(await read(id));
      expect(restored.finishedAt, DateTime(2026, 9, 28, 16));
    });

    test('Should put it back on the agenda when passed null', () async {
      final id = await addService();
      await repository.setFinishedAt(id, DateTime(2026, 9, 28, 16));

      await repository.setFinishedAt(id, null);

      expect(FirebaseServiceModel.fromMap(await read(id)).isFinished, isFalse);
    });

    test('Should touch only finishedAt', () async {
      final id = await addService();
      await repository.setReceivedAt([id], DateTime(2026, 9, 5));
      final before = await read(id);

      await repository.setFinishedAt(id, DateTime(2026, 9, 28, 16));

      final after = await read(id)
        ..remove('finishedAt');
      expect(after, before..remove('finishedAt'));
    });

    test('Should refuse to finish a cancelled service', () async {
      final id = await addService();
      await repository.setCancelledAt(id, DateTime(2026, 9, 10));

      await expectLater(
        repository.setFinishedAt(id, DateTime(2026, 9, 28, 16)),
        ErrorWithMessage<ClientError>(
          KaziLocalizations.current.cancelledServiceCannotBeFinished,
        ),
      );
      expect(FirebaseServiceModel.fromMap(await read(id)).isFinished, isFalse);
    });

    test('Should refuse to cancel a finished service', () async {
      final id = await addService();
      await repository.setFinishedAt(id, DateTime(2026, 9, 28, 16));

      await expectLater(
        repository.setCancelledAt(id, DateTime(2026, 9, 29)),
        ErrorWithMessage<ClientError>(
          KaziLocalizations.current.finishedServiceCannotBeCancelled,
        ),
      );
      expect(FirebaseServiceModel.fromMap(await read(id)).isCancelled, isFalse);
    });

    test('Should refuse an edit that cancels a finished service', () async {
      final id = await addService();
      await repository.setFinishedAt(id, DateTime(2026, 9, 28, 16));
      final stored = FirebaseServiceModel.fromMap(
        await read(id),
      ).copyWith(id: id);

      await expectLater(
        repository.update(stored.markedCancelledAt(DateTime(2026, 9, 29))),
        ErrorWithMessage<ClientError>(
          KaziLocalizations.current.finishedServiceCannotBeCancelled,
        ),
      );
      expect(FirebaseServiceModel.fromMap(await read(id)).isCancelled, isFalse);
    });

    test('Should refuse to add a service both cancelled and finished', () {
      final both = serviceMock
          .markedCancelledAt(DateTime(2026, 9, 10))
          .markedFinished(at: DateTime(2026, 9, 10));

      expect(
        repository.add(both),
        ErrorWithMessage<ClientError>(
          KaziLocalizations.current.cancelledServiceCannotBeFinished,
        ),
      );
    });

    test(
      'Should throw ExternalError with message errorToFinishService',
      () async {
        final failing = MockFirebaseFirestore();
        when(failing.collection(any)).thenThrow(Exception());

        expect(
          FirebaseServicesRepository(
            failing,
            crashlyticsService,
            FakeTimeService(DateTime(2026, 12, 31)),
          ).setFinishedAt('a', DateTime(2026, 9, 28, 16)),
          ErrorWithMessage<ExternalError>(
            KaziLocalizations.current.errorToFinishService,
          ),
        );
      },
    );

    test('Should report the root cause of a failed write', () async {
      final failing = MockFirebaseFirestore();
      final cause = Exception('offline');
      when(failing.collection(any)).thenThrow(cause);

      await expectLater(
        FirebaseServicesRepository(
          failing,
          crashlyticsService,
          FakeTimeService(DateTime(2026, 12, 31)),
        ).setFinishedAt('a', DateTime(2026, 9, 28, 16)),
        throwsA(
          isA<ExternalError>().having((error) => error.cause, 'cause', cause),
        ),
      );
    });
  });

  group('finish stamp bounds', () {
    Future<String> addService(FirebaseServiceModel service) async {
      final response = await firebaseHelper.add(
        service.toMap(),
        (snapshot) => service.copyWith(id: snapshot.id),
      );
      return response.id;
    }

    Future<Map<String, dynamic>> read(String id) async {
      final doc = await database.collection(repository.path).doc(id).get();
      return doc.data()!;
    }

    /// 14:00–15:30 on 28/09/2026; the repository's clock reads 31/12/2026.
    final booked = serviceMock.copyWith(
      date: DateTime(2026, 9, 28),
      startTime: const ClockTime(14, 0),
      duration: const Duration(minutes: 90),
    );

    test('Should refuse to finish a service before it starts', () async {
      final id = await addService(booked);

      await expectLater(
        repository.setFinishedAt(id, DateTime(2026, 9, 28, 13, 59)),
        ErrorWithMessage<ClientError>(
          KaziLocalizations.current.finishedBeforeStart,
        ),
      );
      expect(FirebaseServiceModel.fromMap(await read(id)).isFinished, isFalse);
    });

    test('Should refuse an untimed service finished before its day', () async {
      final id = await addService(
        serviceMock.copyWith(date: DateTime(2026, 9, 28)),
      );

      await expectLater(
        repository.setFinishedAt(id, DateTime(2026, 9, 27, 23)),
        ErrorWithMessage<ClientError>(
          KaziLocalizations.current.finishedBeforeStart,
        ),
      );
    });

    test('Should accept a stamp at the very start', () async {
      final id = await addService(booked);

      await repository.setFinishedAt(id, DateTime(2026, 9, 28, 14));

      expect(
        FirebaseServiceModel.fromMap(await read(id)).finishedAt,
        DateTime(2026, 9, 28, 14),
      );
    });

    test('Should refuse a stamp more than a day past the clock', () async {
      final id = await addService(booked);

      await expectLater(
        repository.setFinishedAt(id, DateTime(2027, 1, 1, 0, 1)),
        ErrorWithMessage<ClientError>(
          KaziLocalizations.current.finishedInFuture,
        ),
      );
    });

    test('Should allow a day of clock skew', () async {
      final id = await addService(booked);

      await repository.setFinishedAt(id, DateTime(2026, 12, 31, 23));

      expect(FirebaseServiceModel.fromMap(await read(id)).isFinished, isTrue);
    });

    test('Should refuse to add a service finished before it starts', () {
      expect(
        repository.add(booked.markedFinishedAt(DateTime(2026, 9, 28, 13))),
        ErrorWithMessage<ClientError>(
          KaziLocalizations.current.finishedBeforeStart,
        ),
      );
    });

    test('Should refuse an edit that moves the start past the stamp', () async {
      final id = await addService(
        booked.copyWith(finishedAt: DateTime(2026, 9, 28, 15, 30)),
      );
      final stored = FirebaseServiceModel.fromMap(
        await read(id),
      ).copyWith(id: id);

      await expectLater(
        repository.update(stored.withStartTime(const ClockTime(16, 0))),
        ErrorWithMessage<ClientError>(
          KaziLocalizations.current.finishedBeforeStart,
        ),
      );
    });
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
      'Should fail with errorToUpdateService',
      () async {
        database = MockFirebaseFirestore();
        repository = FirebaseServicesRepository(
          database,
          crashlyticsService,
          FakeTimeService(DateTime(2026, 12, 31)),
        );
        when(database.collection(repository.path)).thenThrow(Exception());

        expect(
          repository.update(serviceMock),
          failsWith(ServicesFailure.update),
        );
      },
    );
  });

  group('countDatedSince', () {
    setUp(() async {
      for (final (date, userId) in [
        (DateTime(2026, 6, 14), serviceMock.userId),
        (DateTime(2026, 6, 15), serviceMock.userId),
        (DateTime(2026, 7), serviceMock.userId),
        (DateTime(2026, 7), 'aaaa9999'),
      ]) {
        await firebaseHelper.add(
          FirebaseServiceModel.fromService(
            serviceMock.copyWith(date: date, userId: userId),
          ).toMap(),
          (snapshot) => serviceMock.copyWith(id: snapshot.id),
        );
      }
    });

    test(
      'Should count the user services dated on or after the cutoff',
      () async {
        final response = await repository.countDatedSince(
          serviceMock.userId,
          DateTime(2026, 6, 15),
        );
        expect(response, 2);
      },
    );

    test(
      'Should fail with errorToCountServices',
      () async {
        database = MockFirebaseFirestore();
        repository = FirebaseServicesRepository(
          database,
          crashlyticsService,
          FakeTimeService(DateTime(2026, 12, 31)),
        );
        when(database.collection(repository.path)).thenThrow(Exception());

        expect(
          repository.countDatedSince(serviceMock.userId, DateTime(2026)),
          failsWith(ServicesFailure.count),
        );
      },
    );
  });
}
