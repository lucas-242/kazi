import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/auth/data/repositories/firebase_account_data_repository.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

import '../../../../../utils/fakes/fake_crashlytics_service.dart';
import '../../../../../utils/test_helper.dart';
import '../../../../../utils/fakes/fake_firestore.dart';

void main() {
  const userId = 'user-1';
  const otherUserId = 'user-2';

  late FirebaseFirestore database;
  late FirebaseAccountDataRepository repository;

  TestHelper.loadAppLocalizations();

  setUp(() {
    database = FakeFirestore();
    repository = FirebaseAccountDataRepository(
      database,
      FakeCrashlyticsService(),
      pageSize: 2,
    );
  });

  Future<void> seedAccount(String owner, {int services = 1}) async {
    for (var i = 0; i < services; i++) {
      await database.collection('services').add({'userId': owner});
    }
    await database.collection('clients').add({'ownerId': owner});
    await database.collection('serviceTypes').add({'userId': owner});
    await database.collection('users').doc(owner).set({'currency': 'BRL'});
  }

  Future<int> countOwned(String collection, String field, String owner) async {
    final snapshot = await database
        .collection(collection)
        .where(field, isEqualTo: owner)
        .get();
    return snapshot.docs.length;
  }

  test('deletes every document the account owns, across pages', () async {
    await seedAccount(userId, services: 5);

    await repository.deleteAll(userId);

    expect(await countOwned('services', 'userId', userId), 0);
    expect(await countOwned('clients', 'ownerId', userId), 0);
    expect(await countOwned('serviceTypes', 'userId', userId), 0);
    expect((await database.collection('users').doc(userId).get()).exists, false);
  });

  test('leaves other accounts and the shared exchange rates alone', () async {
    await seedAccount(userId);
    await seedAccount(otherUserId, services: 3);
    await database.collection('exchangeRates').doc('2026-10-01').set({
      'base': 'USD',
    });

    await repository.deleteAll(userId);

    expect(await countOwned('services', 'userId', otherUserId), 3);
    expect(await countOwned('clients', 'ownerId', otherUserId), 1);
    expect(await countOwned('serviceTypes', 'userId', otherUserId), 1);
    expect(
      (await database.collection('users').doc(otherUserId).get()).exists,
      true,
    );
    expect(
      (await database.collection('exchangeRates').doc('2026-10-01').get())
          .exists,
      true,
    );
  });

  test('succeeds on an account with nothing left to delete', () async {
    await repository.deleteAll(userId);

    expect((await database.collection('users').doc(userId).get()).exists, false);
  });

  test('wraps a failure in a localized ExternalError', () async {
    final failing = FirebaseAccountDataRepository(
      _ThrowingFirestore(),
      FakeCrashlyticsService(),
    );

    expect(
      failing.deleteAll(userId),
      throwsA(
        isA<ExternalError>().having(
          (error) => error.message,
          'message',
          KaziLocalizations.current.errorToDeleteAccount,
        ),
      ),
    );
  });
}

class _ThrowingFirestore extends Fake implements FirebaseFirestore {
  @override
  CollectionReference<Map<String, dynamic>> collection(String path) =>
      throw FirebaseException(plugin: 'cloud_firestore', code: 'unavailable');
}
