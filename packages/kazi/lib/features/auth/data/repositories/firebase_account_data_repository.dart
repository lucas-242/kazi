import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kazi/core/services/domain/crashlytics_service.dart';
import 'package:kazi/features/auth/domain/repositories/account_data_repository.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

// Every collection holding user data must be listed here. See auth/README.md.
class FirebaseAccountDataRepository implements AccountDataRepository {
  FirebaseAccountDataRepository(
    FirebaseFirestore firestore,
    this._crashlyticsService, {
    int pageSize = 400,
  }) : _firestore = firestore,
       _pageSize = pageSize;

  final FirebaseFirestore _firestore;
  final CrashlyticsService _crashlyticsService;

  /// Below Firestore's cap of 500 writes per batch.
  final int _pageSize;

  /// Services first, since they reference the clients and catalog items, and
  /// the user document last: it holds the onboarding stamps, so an interrupted
  /// run leaves the account looking set up rather than replaying the setup
  /// over half-deleted data.
  static const _ownedCollections = [
    (collection: 'services', ownerField: 'userId'),
    (collection: 'clients', ownerField: 'ownerId'),
    (collection: 'serviceTypes', ownerField: 'userId'),
  ];

  @override
  Future<void> deleteAll(String userId) async {
    try {
      for (final owned in _ownedCollections) {
        await _deleteOwned(owned.collection, owned.ownerField, userId);
      }
      await _firestore.collection('users').doc(userId).delete();
    } catch (exception, trace) {
      Log.error(exception);
      _crashlyticsService.log(exception, trace);
      throw ExternalError(
        KaziLocalizations.current.errorToDeleteAccount,
        cause: exception,
        trace: trace,
      );
    }
  }

  /// No cursor: each page is deleted before the next query, so the same query
  /// keeps returning what is left.
  Future<void> _deleteOwned(
    String collection,
    String ownerField,
    String userId,
  ) async {
    while (true) {
      final page = await _firestore
          .collection(collection)
          .where(ownerField, isEqualTo: userId)
          .limit(_pageSize)
          .get();

      if (page.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (final doc in page.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      if (page.docs.length < _pageSize) return;
    }
  }
}
