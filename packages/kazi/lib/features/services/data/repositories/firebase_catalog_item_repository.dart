import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:kazi/features/services/domain/models/catalog_item.dart';
import 'package:kazi/core/services/domain/crashlytics_service.dart';
import 'package:kazi/core/extensions/extensions.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

import 'package:kazi/features/services/domain/repositories/catalog_item_repository.dart';

class FirebaseCatalogItemRepository extends CatalogItemRepository {
  FirebaseCatalogItemRepository(
    FirebaseFirestore firestore,
    this._crashlyticsService,
  ) : _firestore = firestore;
  final FirebaseFirestore _firestore;
  final CrashlyticsService _crashlyticsService;

  @visibleForTesting
  // The collection predates the rename to catalog. See services/README.md.
  String get path => 'serviceTypes';

  @override
  Future<CatalogItem> add(CatalogItem catalogItem) async {
    try {
      final data = catalogItem.toMap();
      final document = await _firestore.collection(path).add(data);
      final result = catalogItem.copyWith(id: document.id);
      return result;
    } catch (exception, trace) {
      Log.error(exception);
      _crashlyticsService.log(exception, trace);
      throw ExternalError(KaziLocalizations.current.errorToAddCatalogItem);
    }
  }

  @override
  Future<List<CatalogItem>> addAll(List<CatalogItem> catalogItems) async {
    if (catalogItems.isEmpty) return const [];

    try {
      final batch = _firestore.batch();
      final result = <CatalogItem>[];

      for (final catalogItem in catalogItems) {
        final document = _firestore.collection(path).doc();
        batch.set(document, catalogItem.toMap());
        result.add(catalogItem.copyWith(id: document.id));
      }

      // No chunking: the only caller seeds a profession preset, which is
      // capped at eight items — an order of magnitude below Firestore's limit
      // of 500 writes per batch.
      await batch.commit();
      return result;
    } catch (exception, trace) {
      Log.error(exception);
      _crashlyticsService.log(exception, trace);
      throw ExternalError(KaziLocalizations.current.errorToAddCatalogItem);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _firestore.collection(path).doc(id).delete();
    } catch (exception, trace) {
      Log.error(exception);
      _crashlyticsService.log(exception, trace);
      throw ExternalError(KaziLocalizations.current.errorToDeleteCatalogItem);
    }
  }

  @override
  Future<List<CatalogItem>> get(String userId) async {
    try {
      final query = await _firestore
          .collection(path)
          .where('userId', isEqualTo: userId)
          .getCacheFirst();

      final result = query.docs.map((DocumentSnapshot snapshot) {
        final data = snapshot.data() as Map<String, dynamic>;
        return CatalogItem.fromMap(data).copyWith(id: snapshot.id);
      }).toList();

      return result;
    } catch (exception) {
      Log.error(exception);
      throw ExternalError(KaziLocalizations.current.errorToGetCatalogItems);
    }
  }

  @override
  Future<void> update(CatalogItem catalogItem) async {
    try {
      final data = catalogItem.toMap();
      await _firestore.collection(path).doc(catalogItem.id).update(data);
    } catch (exception) {
      Log.error(exception);
      throw ExternalError(KaziLocalizations.current.errorToUpdateCatalogItem);
    }
  }
}
