import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/core/services/domain/crashlytics_service.dart';
import 'package:kazi/core/extensions/extensions.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

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
      await _firestore.collection(path).doc(id).delete();
    } catch (exception, trace) {
      Log.error(exception);
      crashlyticsService.log(exception, trace);
      throw ExternalError(KaziLocalizations.current.errorToDeleteService);
    }
  }

  @override
  Future<void> update(Service service) async {
    try {
      final data = FirebaseServiceModel.fromService(service).toMap();
      await _firestore.collection(path).doc(service.id).update(data);
    } catch (exception, trace) {
      Log.error(exception);
      crashlyticsService.log(exception, trace);
      throw ExternalError(KaziLocalizations.current.errorToUpdateService);
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
  Future<int> count(String userId, [String? typeId]) async {
    try {
      var query = _firestore
          .collection(path)
          .where('userId', isEqualTo: userId);

      if (typeId != null) {
        query = query.where('typeId', isEqualTo: typeId);
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
