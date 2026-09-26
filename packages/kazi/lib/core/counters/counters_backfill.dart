import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kazi/core/counters/service_counter_delta.dart';
import 'package:kazi/core/services/domain/crashlytics_service.dart';
import 'package:kazi/features/services/data/repositories/models/firebase_service_model.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// Recomputes the denormalized counters from the services themselves.
///
/// Runs once per account, and again whenever the drift the best-effort
/// increments allow needs repairing. It reads every service the user has, sums
/// them in memory and **writes the totals rather than incrementing them**, so
/// running it twice is the same as running it once. See `core/counters.md`.
class CountersBackfill {
  CountersBackfill(FirebaseFirestore firestore, this._crashlyticsService)
    : _firestore = firestore;

  final FirebaseFirestore _firestore;
  final CrashlyticsService _crashlyticsService;

  /// Kept below Firestore's cap of 500 writes per batch, so one page always
  /// fits in one batch. Matches the currency backfill.
  static const int _pageSize = 400;

  /// Rebuilds every counter for [userId] and stamps the run on the user
  /// document. Returns how many records were written.
  ///
  /// Never throws: a failed repair is not worth taking a session down for, and
  /// the absent stamp means the next launch tries again.
  Future<int> run(String userId) async {
    try {
      final tallies = await _tallyServices(userId);
      final written =
          await _write('clients', tallies.clients) +
          await _write('serviceTypes', tallies.catalogItems);

      await _firestore.collection('users').doc(userId).set({
        'countersBackfilledAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return written;
    } catch (exception, trace) {
      Log.error(exception);
      _crashlyticsService.log(exception, trace);
      return 0;
    }
  }

  /// Whether the account has never been through this.
  Future<bool> isPending(String userId) async {
    try {
      final snapshot = await _firestore.collection('users').doc(userId).get();
      return snapshot.data()?['countersBackfilledAt'] == null;
    } catch (_) {
      // Unknown is treated as "done": a repair that cannot read its own stamp
      // would otherwise run on every launch.
      return false;
    }
  }

  Future<({Map<String, _Tally> clients, Map<String, _Tally> catalogItems})>
  _tallyServices(String userId) async {
    final clients = <String, _Tally>{};
    final catalogItems = <String, _Tally>{};
    String? lastId;

    while (true) {
      var query = _firestore
          .collection('services')
          .where('userId', isEqualTo: userId);

      if (lastId != null) {
        // A document-id range rather than `startAfterDocument`: cursor
        // semantics over `__name__` differ between the SDK and the in-memory
        // test double, and this filter means the same thing to both.
        query = query.where(FieldPath.documentId, isGreaterThan: lastId);
      }

      final page = await query
          .orderBy(FieldPath.documentId)
          .limit(_pageSize)
          .get();

      if (page.docs.isEmpty) break;

      for (final doc in page.docs) {
        final service = FirebaseServiceModel.fromMap(doc.data());
        final delta = ServiceCounterDelta.of(service);

        final clientId = service.clientId;
        if (clientId != null && clientId.isNotEmpty) {
          (clients[clientId] ??= _Tally()).add(delta, tallyByItem: true);
        }
        if (service.catalogItemId.isNotEmpty) {
          (catalogItems[service.catalogItemId] ??= _Tally()).add(delta);
        }
      }

      if (page.docs.length < _pageSize) break;
      lastId = page.docs.last.id;
    }

    return (clients: clients, catalogItems: catalogItems);
  }

  Future<int> _write(String collection, Map<String, _Tally> tallies) async {
    if (tallies.isEmpty) return 0;

    final entries = tallies.entries.toList();
    var written = 0;

    for (var start = 0; start < entries.length; start += _pageSize) {
      final end = start + _pageSize;
      final chunk = entries.sublist(
        start,
        end < entries.length ? end : entries.length,
      );
      final batch = _firestore.batch();

      for (final entry in chunk) {
        // `update`, never `set(merge:)`: a record deleted while its services
        // stayed must not be recreated by its own repair.
        batch.update(
          _firestore.collection(collection).doc(entry.key),
          entry.value.toMap(isClient: collection == 'clients'),
        );
      }

      try {
        await batch.commit();
        written += chunk.length;
      } on FirebaseException catch (exception) {
        // One missing record fails the whole batch, so the chunk is retried a
        // document at a time and the gone ones are skipped.
        if (exception.code != 'not-found') rethrow;
        written += await _writeOneByOne(collection, chunk);
      }
    }

    return written;
  }

  Future<int> _writeOneByOne(
    String collection,
    List<MapEntry<String, _Tally>> chunk,
  ) async {
    var written = 0;

    for (final entry in chunk) {
      try {
        await _firestore
            .collection(collection)
            .doc(entry.key)
            .update(entry.value.toMap(isClient: collection == 'clients'));
        written++;
      } on FirebaseException catch (exception) {
        if (exception.code != 'not-found') rethrow;
      }
    }

    return written;
  }
}

/// One record's counters, summed in memory before being written whole.
class _Tally {
  int count = 0;
  final Map<String, ({double generated, double commission})> byCurrency = {};
  final Map<String, int> byItem = {};

  void add(ServiceCounterDelta delta, {bool tallyByItem = false}) {
    count += delta.count;

    final current =
        byCurrency[delta.currencyKey] ?? (generated: 0.0, commission: 0.0);
    byCurrency[delta.currencyKey] = (
      generated: current.generated + delta.generated,
      commission: current.commission + delta.commission,
    );

    if (tallyByItem && delta.catalogItemId.isNotEmpty) {
      byItem[delta.catalogItemId] = (byItem[delta.catalogItemId] ?? 0) + 1;
    }
  }

  Map<String, Object?> toMap({required bool isClient}) => {
    if (isClient) 'servicesCount': count else 'usageCount': count,
    'totals': {
      for (final entry in byCurrency.entries)
        entry.key: {
          'generated': entry.value.generated,
          'commission': entry.value.commission,
        },
    },
    if (isClient) 'mostUsedServices': byItem,
  };
}
