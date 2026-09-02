import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kazi/core/counters/service_counter_delta.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/core/services/domain/crashlytics_service.dart';
import 'package:kazi/core/extensions/extensions.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

import 'package:kazi/features/services/domain/repositories/services_repository.dart';
import 'models/firebase_service_model.dart';

class FirebaseServicesRepository implements ServicesRepository {
  FirebaseServicesRepository(
    FirebaseFirestore firestore,
    this.crashlyticsService,
  ) : _firestore = firestore;
  final FirebaseFirestore _firestore;
  final CrashlyticsService crashlyticsService;
  String get path => 'services';

  @override
  Future<List<Service>> add(Service service, [int quantity = 1]) async {
    try {
      final batch = _firestore.batch();
      final data = FirebaseServiceModel.fromService(service);
      final result = <Service>[];

      for (var i = 0; i < quantity; i++) {
        final collection = _firestore.collection(path).doc();
        // `createdAt` is a server-set, immutable creation timestamp used to
        // enforce the monthly freemium limit. It is never written on update,
        // so users cannot dodge the limit by editing a service's `date`.
        batch.set(collection, {
          ...data.toMap(),
          'createdAt': FieldValue.serverTimestamp(),
        });
        result.add(data.copyWith(id: collection.id));
      }

      await batch.commit();
      await _applyCounters(ServiceCounterDelta.of(service, quantity: quantity));
      return result;
    } catch (exception, trace) {
      Log.error(exception);
      crashlyticsService.log(exception, trace);
      throw ExternalError(KaziLocalizations.current.errorToAddService);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      // Read first: the document is the only thing that knows which client and
      // which catalog item have to give the money back.
      final previous = await _previousService(id);
      await _firestore.collection(path).doc(id).delete();

      if (previous != null) {
        await _applyCounters(
          ServiceCounterDelta.of(previous, isRemoval: true),
        );
      }
    } catch (exception, trace) {
      Log.error(exception);
      crashlyticsService.log(exception, trace);
      throw ExternalError(KaziLocalizations.current.errorToDeleteService);
    }
  }

  @override
  Future<void> update(Service service) async {
    try {
      // An edit can move a service to another client, another type, another
      // currency or another amount, so the old contribution is reversed rather
      // than adjusted.
      final previous = await _previousService(service.id);
      final data = FirebaseServiceModel.fromService(service).toMap();
      await _firestore.collection(path).doc(service.id).update(data);

      if (previous != null) {
        await _applyCounters(
          ServiceCounterDelta.of(previous, isRemoval: true),
        );
      }
      await _applyCounters(ServiceCounterDelta.of(service));
    } catch (exception, trace) {
      Log.error(exception);
      crashlyticsService.log(exception, trace);
      throw ExternalError(KaziLocalizations.current.errorToUpdateService);
    }
  }

  /// The service as it is stored right now, for reversing what it already
  /// contributed. Null when it is gone, which a concurrent delete can produce.
  Future<Service?> _previousService(String id) async {
    final snapshot = await _firestore.collection(path).doc(id).get();
    final data = snapshot.data();
    if (data == null) return null;

    return FirebaseServiceModel.fromMap(data).copyWith(id: snapshot.id);
  }

  /// Folds a service's contribution into the denormalized counters on its
  /// client and its catalog item.
  ///
  /// **After** the service write, never inside its batch, and never fatal to
  /// it: the writes are `update`, which no-ops on a document that is gone, and
  /// a `set(merge:)` here would recreate the document of a client who asked to
  /// be deleted — the one thing `updateLastService` is careful never to do. A
  /// service must save even when its counters cannot; the backfill is the
  /// repair path for the drift that buys. See `core/counters.md`.
  Future<void> _applyCounters(ServiceCounterDelta delta) async {
    await _increment('clients', delta.clientId, delta.clientUpdates);
    await _increment(
      'serviceTypes',
      delta.catalogItemId,
      delta.catalogItemUpdates,
    );
  }

  Future<void> _increment(
    String collection,
    String? id,
    Map<String, Object?> updates,
  ) async {
    if (id == null || id.isEmpty || updates.isEmpty) return;

    try {
      await _firestore.collection(collection).doc(id).update(updates);
    } on FirebaseException catch (exception, trace) {
      // The record was deleted while its services stayed — an expected
      // outcome, not a fault worth reporting on every save.
      if (exception.code == 'not-found') return;
      Log.error(exception);
      crashlyticsService.log(exception, trace);
    } catch (exception, trace) {
      Log.error(exception);
      crashlyticsService.log(exception, trace);
    }
  }

  /// Kept below Firestore's cap of 500 writes per batch, matching the paging
  /// size the currency backfill settled on.
  static const int _batchSize = 400;

  @override
  Future<void> setReceivedAt(List<String> ids, DateTime? receivedAt) async {
    if (ids.isEmpty) return;

    try {
      final stamp = receivedAt == null ? null : Timestamp.fromDate(receivedAt);

      // Committed in chunks, so a cycle with more than 400 services does not
      // exceed the batch cap. That makes the operation non-atomic across
      // chunks, and idempotent instead: a failure part-way leaves the rest
      // unstamped, and running it again finishes the job without double-
      // stamping anything.
      for (var start = 0; start < ids.length; start += _batchSize) {
        final end = start + _batchSize;
        final chunk = ids.sublist(start, end < ids.length ? end : ids.length);
        final batch = _firestore.batch();

        for (final id in chunk) {
          batch.update(_firestore.collection(path).doc(id), {
            'receivedAt': stamp,
          });
        }

        await batch.commit();
      }
    } catch (exception, trace) {
      Log.error(exception);
      crashlyticsService.log(exception, trace);
      throw ExternalError(KaziLocalizations.current.errorToMarkReceived);
    }
  }

  @override
  Future<List<Service>> get(
    String userId,
    DateTime startDate, [
    DateTime? endDate,
  ]) async {
    try {
      var query = _firestore
          .collection(path)
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startDate);

      if (endDate != null) {
        query = query.where('date', isLessThanOrEqualTo: endDate);
      }

      final finalQuery = await query.getCacheFirst();

      final result = finalQuery.docs.map((DocumentSnapshot snapshot) {
        final data = snapshot.data() as Map<String, dynamic>;
        return FirebaseServiceModel.fromMap(data).copyWith(id: snapshot.id);
      }).toList();

      return result;
    } catch (exception, trace) {
      Log.error(exception);
      crashlyticsService.log(exception, trace);
      throw ExternalError(KaziLocalizations.current.errorToGetServices);
    }
  }

  @override
  Future<int> count(String userId, [String? catalogItemId]) async {
    try {
      var query = _firestore
          .collection(path)
          .where('userId', isEqualTo: userId);

      if (catalogItemId != null) {
        query = query.where('typeId', isEqualTo: catalogItemId);
      }

      final result = await query.count().get();
      return result.count ?? 0;
    } catch (exception, trace) {
      Log.error(exception);
      crashlyticsService.log(exception, trace);
      throw ExternalError(KaziLocalizations.current.errorToCountServices);
    }
  }

  @override
  Future<int> countByClient(String userId, String clientId) async {
    try {
      final result = await _firestore
          .collection(path)
          .where('userId', isEqualTo: userId)
          .where('clientId', isEqualTo: clientId)
          .count()
          .get();
      return result.count ?? 0;
    } catch (exception, trace) {
      Log.error(exception);
      crashlyticsService.log(exception, trace);
      throw ExternalError(KaziLocalizations.current.errorToCountServices);
    }
  }

  @override
  Future<int> countCreatedSince(String userId, DateTime since) async {
    try {
      final result = await _firestore
          .collection(path)
          .where('userId', isEqualTo: userId)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(since))
          .count()
          .get();
      return result.count ?? 0;
    } catch (exception, trace) {
      Log.error(exception);
      crashlyticsService.log(exception, trace);
      throw ExternalError(KaziLocalizations.current.errorToCountServices);
    }
  }
}
