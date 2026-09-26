import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/services/domain/models/catalog_item.dart';
import 'package:kazi/features/services/data/repositories/firebase_catalog_item_repository.dart';
import 'package:kazi/core/services/domain/crashlytics_service.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../../mocks/mocks.dart';
import '../../../../../utils/firebase_test_helper.dart';
import '../../../../../utils/test_helper.dart';
import '../../../../../utils/test_matchers.dart';
import 'firebase_catalog_item_repository_test.mocks.dart';

@GenerateMocks([FirebaseFirestore, CrashlyticsService])
void main() {
  late FirebaseFirestore database;
  late FirebaseCatalogItemRepository repository;
  late FirebaseTestHelper firebaseHelper;
  late MockCrashlyticsService mockCrashlyticsService;

  TestHelper.loadAppLocalizations();

  setUp(() async {
    database = FakeFirebaseFirestore();
    mockCrashlyticsService = MockCrashlyticsService();
    repository = FirebaseCatalogItemRepository(
      database,
      mockCrashlyticsService,
    );
    firebaseHelper = FirebaseTestHelper(database, repository.path);
  });

  group('Add Service Type', () {
    test('Should add service type', () async {
      final response = await repository.add(catalogItemMock);
      expect(response, IsTheSameCatalogItem(catalogItemMock));

      final catalogItemCount = await firebaseHelper.count();
      expect(catalogItemCount, 1);

      final catalogItemAdded = await firebaseHelper.get(
        response.id,
        (snapshot, data) => CatalogItem.fromMap(data).copyWith(id: snapshot.id),
      );
      expect(
        catalogItemAdded,
        IsTheSameCatalogItem(response, checkEqualsId: true),
      );
    });

    test('Should round-trip the colour', () async {
      final coloured = catalogItemMock.copyWith(color: 'FF2F6FEB');
      final response = await repository.add(coloured);

      final catalogItemAdded = await firebaseHelper.get(
        response.id,
        (snapshot, data) => CatalogItem.fromMap(data).copyWith(id: snapshot.id),
      );

      expect(catalogItemAdded?.color, 'FF2F6FEB');
      expect(catalogItemAdded?.colorAs, const Color(0xFF2F6FEB));
    });

    test(
      'Should read a legacy document with no colour as having none',
      () async {
        final legacyMap = catalogItemMock.toMap()..remove('color');
        final added = await firebaseHelper.add(
          legacyMap,
          (snapshot) => catalogItemMock.copyWith(id: snapshot.id),
        );

        final response = await repository.get(catalogItemMock.userId);
        final legacy = response.firstWhere((type) => type.id == added.id);

        expect(legacy.color, isEmpty);
        expect(legacy.colorAs, isNull);
      },
    );

    test('Should throw ExternalError with errorToAddCatalogItem message', () {
      database = MockFirebaseFirestore();
      repository = FirebaseCatalogItemRepository(
        database,
        mockCrashlyticsService,
      );
      when(database.collection(repository.path)).thenThrow(Exception());

      expectLater(
        repository.add(catalogItemMock),
        ErrorWithMessage<ExternalError>(
          KaziLocalizations.current.errorToAddCatalogItem,
        ),
      );
    });
  });

  group('Delete Service Type', () {
    late String catalogItemId;

    setUp(() async {
      final response = await firebaseHelper.add(
        catalogItemMock.toMap(),
        (snapshot) => catalogItemMock.copyWith(id: snapshot.id),
      );
      catalogItemId = response.id;
    });

    test('Should delete service type', () async {
      expect(repository.delete(catalogItemId), completion(null));

      final response = await firebaseHelper.get(
        catalogItemId,
        (snapshot, data) => CatalogItem.fromMap(data).copyWith(id: snapshot.id),
      );

      expect(response, isNull);
    });

    test(
      'Should throw ExternalError with message errorToDeleteCatalogItem',
      () async {
        database = MockFirebaseFirestore();
        repository = FirebaseCatalogItemRepository(
          database,
          mockCrashlyticsService,
        );
        when(database.collection(repository.path)).thenThrow(Exception());

        expect(
          repository.delete(catalogItemId),
          ErrorWithMessage<ExternalError>(
            KaziLocalizations.current.errorToDeleteCatalogItem,
          ),
        );
      },
    );
  });

  group('Get Service Types', () {
    const userNumberOfCatalogItems = 5;

    setUp(() async {
      for (var i = 0; i < userNumberOfCatalogItems; i++) {
        await firebaseHelper.add(
          catalogItemMock.toMap(),
          (snapshot) => catalogItemMock.copyWith(id: snapshot.id),
        );
      }

      //Service type to another user
      await firebaseHelper.add(
        catalogItemMock.copyWith(userId: 'aaaa9999').toMap(),
        (snapshot) => catalogItemMock.copyWith(id: snapshot.id),
      );
    });

    test('Should get service types', () async {
      final response = await repository.get(catalogItemMock.userId);
      expect(response, hasLength(userNumberOfCatalogItems));
      expect(
        response,
        everyElement(
          predicate(
            (e) => e is CatalogItem && e.userId == catalogItemMock.userId,
          ),
        ),
      );
    });

    test(
      'Should throw ExternalError with message errorToGetCatalogItems',
      () async {
        database = MockFirebaseFirestore();
        repository = FirebaseCatalogItemRepository(
          database,
          mockCrashlyticsService,
        );
        when(database.collection(repository.path)).thenThrow(Exception());

        expect(
          repository.get(catalogItemMock.userId),
          ErrorWithMessage<ExternalError>(
            KaziLocalizations.current.errorToGetCatalogItems,
          ),
        );
      },
    );
  });

  group('Update Service Type', () {
    late String catalogItemId;

    setUp(() async {
      final response = await firebaseHelper.add(
        catalogItemMock.toMap(),
        (snapshot) => catalogItemMock.copyWith(id: snapshot.id),
      );
      catalogItemId = response.id;
    });

    test('Should update service type', () async {
      final toUpdate = catalogItemMock.copyWith(
        id: catalogItemId,
        name: 'Update test',
      );
      await repository.update(toUpdate);

      final response = await firebaseHelper.get(
        toUpdate.id,
        (snapshot, data) => CatalogItem.fromMap(data).copyWith(id: snapshot.id),
      );
      expect(response, IsTheSameCatalogItem(toUpdate, checkEqualsId: true));
    });

    test(
      'Should throw ExternalError with message errorToUpdateCatalogItem',
      () async {
        database = MockFirebaseFirestore();
        repository = FirebaseCatalogItemRepository(
          database,
          mockCrashlyticsService,
        );
        when(database.collection(repository.path)).thenThrow(Exception());

        expect(
          repository.update(catalogItemMock),
          ErrorWithMessage<ExternalError>(
            KaziLocalizations.current.errorToUpdateCatalogItem,
          ),
        );
      },
    );
  });
}
