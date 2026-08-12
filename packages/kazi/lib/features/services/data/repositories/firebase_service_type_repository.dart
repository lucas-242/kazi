import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:kazi/features/services/domain/models/service_type.dart';
import 'package:kazi/core/services/domain/crashlytics_service.dart';
import 'package:kazi/core/extensions/extensions.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

import 'package:kazi/features/services/domain/repositories/service_type_repository.dart';

class FirebaseServiceTypeRepository extends ServiceTypeRepository {
  FirebaseServiceTypeRepository(
    FirebaseFirestore firestore,
    this._crashlyticsService,
  ) : _firestore = firestore;
  final FirebaseFirestore _firestore;
  final CrashlyticsService _crashlyticsService;

  @visibleForTesting
  String get path => 'serviceTypes';

  @override
  Future<ServiceType> add(ServiceType serviceType) async {
    try {
      final data = serviceType.toMap();
      final document = await _firestore.collection(path).add(data);
      final result = serviceType.copyWith(id: document.id);
      return result;
    } catch (exception, trace) {
      Log.error(exception);
      _crashlyticsService.log(exception, trace);
      throw ExternalError(KaziLocalizations.current.errorToAddServiceType);
    }
  }

  @override
  Future<List<ServiceType>> addAll(List<ServiceType> serviceTypes) async {
    if (serviceTypes.isEmpty) return const [];

    try {
      final batch = _firestore.batch();
      final result = <ServiceType>[];

      for (final serviceType in serviceTypes) {
        final document = _firestore.collection(path).doc();
        batch.set(document, serviceType.toMap());
        result.add(serviceType.copyWith(id: document.id));
      }

      // No chunking: the only caller seeds a profession preset, which is
      // capped at eight types — an order of magnitude below Firestore's limit
      // of 500 writes per batch.
      await batch.commit();
      return result;
    } catch (exception, trace) {
      Log.error(exception);
      _crashlyticsService.log(exception, trace);
      throw ExternalError(KaziLocalizations.current.errorToAddServiceType);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _firestore.collection(path).doc(id).delete();
    } catch (exception, trace) {
      Log.error(exception);
      _crashlyticsService.log(exception, trace);
      throw ExternalError(KaziLocalizations.current.errorToDeleteServiceType);
    }
  }

  @override
  Future<List<ServiceType>> get(String userId) async {
    try {
      final query = await _firestore
          .collection(path)
          .where('userId', isEqualTo: userId)
          .getCacheFirst();

      final result = query.docs.map((DocumentSnapshot snapshot) {
        final data = snapshot.data() as Map<String, dynamic>;
        return ServiceType.fromMap(data).copyWith(id: snapshot.id);
      }).toList();

      return result;
    } catch (exception) {
      Log.error(exception);
      throw ExternalError(KaziLocalizations.current.errorToGetServiceTypes);
    }
  }

  @override
  Future<void> update(ServiceType serviceType) async {
    try {
      final data = serviceType.toMap();
      await _firestore.collection(path).doc(serviceType.id).update(data);
    } catch (exception) {
      Log.error(exception);
      throw ExternalError(KaziLocalizations.current.errorToUpdateServiceType);
    }
  }
}
