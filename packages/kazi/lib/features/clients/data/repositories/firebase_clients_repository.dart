import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kazi/core/services/domain/crashlytics_service.dart';
import 'package:kazi/features/clients/data/repositories/models/firebase_client_model.dart';
import 'package:kazi/features/clients/domain/models/client_entry.dart';
import 'package:kazi/features/clients/domain/repositories/clients_repository.dart';
import 'package:kazi_core/kazi_core.dart';

class FirebaseClientsRepository implements ClientsRepository {
  FirebaseClientsRepository(
    FirebaseFirestore firestore,
    this.crashlyticsService,
  ) : _firestore = firestore;

  final FirebaseFirestore _firestore;
  final CrashlyticsService crashlyticsService;

  String get path => 'clients';
  String get servicesPath => 'services';

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(path);

  @override
  Future<List<ClientEntry>> getClients(
    String ownerId, {
    int limit = 10,
    String? startAfterName,
  }) async {
    try {
      var query = _collection
          .where('ownerId', isEqualTo: ownerId)
          .where('active', isEqualTo: true)
          .orderBy('name')
          .limit(limit);

      if (startAfterName != null && startAfterName.isNotEmpty) {
        query = query.startAfter([startAfterName]);
      }

      final result = await query.get();
      return result.docs.map(FirebaseClientModel.fromDoc).toList();
    } catch (exception, trace) {
      Log.error(exception);
      crashlyticsService.log(exception, trace);
      throw ExternalError(KaziLocalizations.current.errorToGetClients);
    }
  }

  @override
  Future<List<ClientEntry>> searchByName(String ownerId, String query) async {
    try {
      final result = await _collection
          .where('ownerId', isEqualTo: ownerId)
          .where('active', isEqualTo: true)
          .orderBy('name')
          .startAt([query])
          .endAt(['$query\u{F8FF}'])
          .get();
      return result.docs.map(FirebaseClientModel.fromDoc).toList();
    } catch (exception, trace) {
      Log.error(exception);
      crashlyticsService.log(exception, trace);
      throw ExternalError(KaziLocalizations.current.errorToGetClients);
    }
  }

  @override
  Future<ClientEntry?> getClientDetails(
    String ownerId,
    String clientId, {
    int limit = 15,
  }) async {
    try {
      final doc = await _collection.doc(clientId).get();
      if (!doc.exists) return null;

      final entry = FirebaseClientModel.fromDoc(doc);
      final serviceHistory = await getServiceHistory(
        ownerId,
        clientId,
        limit: limit,
      );

      final info = ClientInfo(
        user: entry.info.user,
        lastServiceName: serviceHistory.isNotEmpty
            ? serviceHistory.first.serviceName
            : entry.info.lastServiceName,
        lastServiceDate: serviceHistory.isNotEmpty
            ? serviceHistory.first.date
            : entry.info.lastServiceDate,
        mostUsedServices: const {},
        serviceHistory: serviceHistory,
      );

      return (id: entry.id, info: info);
    } catch (exception, trace) {
      Log.error(exception);
      crashlyticsService.log(exception, trace);
      throw ExternalError(KaziLocalizations.current.errorToGetClients);
    }
  }

  @override
  Future<List<ServiceHistoryItem>> getServiceHistory(
    String ownerId,
    String clientId, {
    int limit = 15,
    DateTime? startAfterDate,
  }) async {
    try {
      // Paginated on the backend so a long-lived client doesn't drag its whole
      // service history down. Requires a composite index on the `services`
      // collection: userId ASC, clientId ASC, date DESC.
      var query = _firestore
          .collection(servicesPath)
          // services collection uses userId to identify the owner
          .where('userId', isEqualTo: ownerId)
          .where('clientId', isEqualTo: clientId)
          .orderBy('date', descending: true)
          .limit(limit);

      if (startAfterDate != null) {
        query = query.startAfter([Timestamp.fromDate(startAfterDate)]);
      }

      final servicesQuery = await query.get();

      return servicesQuery.docs.map((doc) {
        final data = doc.data();
        return ServiceHistoryItem(
          serviceName: data['typeName'] ?? '',
          professionalName: data['professionalName'] ?? '',
          date: data['date'] is Timestamp
              ? (data['date'] as Timestamp).toDate()
              : DateTime(2000),
          notes: data['description'],
        );
      }).toList();
    } catch (exception, trace) {
      Log.error(exception);
      crashlyticsService.log(exception, trace);
      throw ExternalError(KaziLocalizations.current.errorToGetClients);
    }
  }

  @override
  Future<String> add(String ownerId, User client) async {
    try {
      final doc = await _collection.add(
        FirebaseClientModel.toMap(ownerId, client),
      );
      return doc.id;
    } catch (exception, trace) {
      Log.error(exception);
      crashlyticsService.log(exception, trace);
      throw ExternalError(KaziLocalizations.current.errorToAddClient);
    }
  }

  @override
  Future<int> count(String ownerId) async {
    try {
      final result = await _collection
          .where('ownerId', isEqualTo: ownerId)
          .where('active', isEqualTo: true)
          .count()
          .get();
      return result.count ?? 0;
    } catch (exception, trace) {
      Log.error(exception);
      crashlyticsService.log(exception, trace);
      throw ExternalError(KaziLocalizations.current.errorToGetClients);
    }
  }

  @override
  Future<void> update(String clientId, User client) async {
    try {
      final doc = await _collection.doc(clientId).get();
      final ownerId = doc.data()?['ownerId'] ?? '';
      await _collection
          .doc(clientId)
          .update(FirebaseClientModel.toMap(ownerId, client));
    } catch (exception, trace) {
      Log.error(exception);
      crashlyticsService.log(exception, trace);
      throw ExternalError(KaziLocalizations.current.errorToUpdateClient);
    }
  }

  @override
  Future<void> deactivate(String clientId) async {
    try {
      await _collection
          .doc(clientId)
          .update(FirebaseClientModel.deactivatedData());
    } catch (exception, trace) {
      Log.error(exception);
      crashlyticsService.log(exception, trace);
      throw ExternalError(KaziLocalizations.current.errorToDeleteClient);
    }
  }

  @override
  Future<void> updateLastService(
    String clientId,
    String serviceName,
    DateTime date,
  ) async {
    try {
      await _collection.doc(clientId).update({
        'lastServiceName': serviceName,
        'lastServiceDate': Timestamp.fromDate(date),
      });
    } catch (exception, trace) {
      Log.error(exception);
      crashlyticsService.log(exception, trace);
      // Denormalization failure shouldn't block the service flow; just log it.
    }
  }
}
