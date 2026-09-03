import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kazi/core/services/domain/crashlytics_service.dart';
import 'package:kazi/features/clients/data/repositories/models/firebase_client_model.dart';
import 'package:kazi/features/clients/domain/models/client_entry.dart';
import 'package:kazi/features/clients/domain/repositories/clients_repository.dart';
import 'package:kazi/features/services/data/repositories/models/firebase_service_model.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi_core/kazi_core.dart' hide Service;

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

  /// Every listing query filters on the same two equality fields plus a name
  /// ordering, so one composite index — `ownerId`, `status`, `name` — serves
  /// them all. See core/archiving.md.
  Query<Map<String, dynamic>> _byStatus(String ownerId, String status) =>
      _collection
          .where('ownerId', isEqualTo: ownerId)
          .where('status', isEqualTo: status)
          .orderBy('name');

  @override
  Future<List<ClientEntry>> getClients(
    String ownerId, {
    int limit = 10,
    String? startAfterName,
  }) => _page(
    ownerId,
    ClientStatus.active,
    limit: limit,
    startAfterName: startAfterName,
  );

  @override
  Future<List<ClientEntry>> getAllActiveClients(String ownerId) async {
    try {
      final result = await _byStatus(ownerId, ClientStatus.active).get();
      return result.docs.map(FirebaseClientModel.fromDoc).toList();
    } catch (exception, trace) {
      Log.error(exception);
      crashlyticsService.log(exception, trace);
      throw ExternalError(KaziLocalizations.current.errorToGetClients);
    }
  }

  @override
  Future<List<ClientEntry>> getArchivedClients(
    String ownerId, {
    int limit = 20,
    String? startAfterName,
  }) => _page(
    ownerId,
    ClientStatus.archived,
    limit: limit,
    startAfterName: startAfterName,
  );

  Future<List<ClientEntry>> _page(
    String ownerId,
    String status, {
    required int limit,
    String? startAfterName,
  }) async {
    try {
      var query = _byStatus(ownerId, status).limit(limit);

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
      final result = await _byStatus(ownerId, ClientStatus.active)
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
  Future<ClientEntry?> findByIdentifier(
    String ownerId,
    String identifier,
  ) async {
    if (identifier.isEmpty) return null;

    try {
      // Two equality filters and no ordering, so Firestore serves this from the
      // single-field indexes — no composite index to create.
      final result = await _collection
          .where('ownerId', isEqualTo: ownerId)
          .where('identifier', isEqualTo: identifier)
          .limit(1)
          .get();

      if (result.docs.isEmpty) return null;
      return FirebaseClientModel.fromDoc(result.docs.first);
    } catch (exception, trace) {
      Log.error(exception);
      crashlyticsService.log(exception, trace);
      throw ExternalError(KaziLocalizations.current.errorToGetClients);
    }
  }

  @override
  Future<ClientEntry?> getClientDetails(String ownerId, String clientId) async {
    try {
      final doc = await _collection.doc(clientId).get();
      if (!doc.exists) return null;

      return FirebaseClientModel.fromDoc(doc);
    } catch (exception, trace) {
      Log.error(exception);
      crashlyticsService.log(exception, trace);
      throw ExternalError(KaziLocalizations.current.errorToGetClients);
    }
  }

  @override
  Future<List<Service>> getServiceHistory(
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

      return servicesQuery.docs
          .map((doc) => FirebaseServiceModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (exception, trace) {
      Log.error(exception);
      crashlyticsService.log(exception, trace);
      throw ExternalError(KaziLocalizations.current.errorToGetClients);
    }
  }

  @override
  Future<DateTime?> getFirstServiceDate(String ownerId, String clientId) async {
    try {
      // The same composite index the history uses: the two equality filters
      // carry no direction, so one definition serves both orderings of `date`.
      final result = await _firestore
          .collection(servicesPath)
          .where('userId', isEqualTo: ownerId)
          .where('clientId', isEqualTo: clientId)
          .orderBy('date')
          .limit(1)
          .get();

      final date = result.docs.firstOrNull?.data()['date'];
      return date is Timestamp ? date.toDate() : null;
    } catch (exception, trace) {
      Log.error(exception);
      crashlyticsService.log(exception, trace);
      throw ExternalError(KaziLocalizations.current.errorToGetClients);
    }
  }

  @override
  Future<String> add(
    String ownerId,
    User client, {
    String observation = '',
  }) async {
    try {
      final doc = await _collection.add(
        FirebaseClientModel.toMap(ownerId, client, observation: observation),
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
      // No status filter: an archived client still occupies a slot, or
      // archiving would be a way around the free-tier limit.
      final result = await _collection
          .where('ownerId', isEqualTo: ownerId)
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
  Future<int> countActive(String ownerId) =>
      _countByStatus(ownerId, ClientStatus.active);

  @override
  Future<int> countArchived(String ownerId) =>
      _countByStatus(ownerId, ClientStatus.archived);

  Future<int> _countByStatus(String ownerId, String status) async {
    try {
      final result = await _collection
          .where('ownerId', isEqualTo: ownerId)
          .where('status', isEqualTo: status)
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
  Future<int> countServicesOf(String ownerId, String clientId) async {
    try {
      final result = await _firestore
          .collection(servicesPath)
          .where('userId', isEqualTo: ownerId)
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
  Future<void> update(
    String clientId,
    User client, {
    String observation = '',
  }) async {
    try {
      await _collection
          .doc(clientId)
          .update(
            FirebaseClientModel.editableData(client, observation: observation),
          );
    } catch (exception, trace) {
      Log.error(exception);
      crashlyticsService.log(exception, trace);
      throw ExternalError(KaziLocalizations.current.errorToUpdateClient);
    }
  }

  @override
  Future<DateTime> archive(String clientId) async {
    try {
      // The device clock rather than `serverTimestamp()`: the value is only
      // shown back to this user as "archived on", and reading it back to learn
      // what the server wrote would cost a round trip for a label.
      final archivedAt = DateTime.now();
      await _collection
          .doc(clientId)
          .update(FirebaseClientModel.archivedData(archivedAt));
      return archivedAt;
    } catch (exception, trace) {
      Log.error(exception);
      crashlyticsService.log(exception, trace);
      throw ExternalError(KaziLocalizations.current.errorToArchiveClient);
    }
  }

  @override
  Future<void> restore(String clientId) async {
    try {
      await _collection
          .doc(clientId)
          .update(FirebaseClientModel.restoredData());
    } catch (exception, trace) {
      Log.error(exception);
      crashlyticsService.log(exception, trace);
      throw ExternalError(KaziLocalizations.current.errorToRestoreClient);
    }
  }

  @override
  Future<void> delete(String clientId) async {
    try {
      await _collection.doc(clientId).delete();
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
      // `update`, never `set(merge: true)`: a merge would recreate the document
      // of a client who asked to be deleted.
      await _collection.doc(clientId).update({
        'lastServiceName': serviceName,
        'lastServiceDate': Timestamp.fromDate(date),
      });
    } on FirebaseException catch (exception, trace) {
      // The client was deleted while their services stayed — an expected
      // outcome, not a fault worth reporting on every save.
      if (exception.code == 'not-found') return;
      Log.error(exception);
      crashlyticsService.log(exception, trace);
    } catch (exception, trace) {
      Log.error(exception);
      crashlyticsService.log(exception, trace);
      // Denormalization failure shouldn't block the service flow; just log it.
    }
  }
}
