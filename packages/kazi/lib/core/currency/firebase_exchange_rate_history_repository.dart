import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:kazi/core/extensions/extensions.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// Daily exchange-rate snapshots shared by every user: one document per day for
/// the whole app, instead of a copy embedded in each registered service.
///
/// Documents are append-only. The first client to open the app on a given day
/// creates it (`putIfAbsent`); security rules reject updates and deletes, and
/// only accept a create whose id is today's UTC date and whose `fetchedAt` is
/// the server clock — a client cannot backdate a snapshot. Nothing here throws:
/// a missing day is a normal result the caller degrades from.
class FirebaseExchangeRateHistoryRepository
    implements ExchangeRateHistoryRepository {
  FirebaseExchangeRateHistoryRepository(FirebaseFirestore firestore)
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  /// Firestore caps `whereIn` at 30 values per query.
  static const int _chunkSize = 30;

  @visibleForTesting
  String get path => 'exchangeRates';

  @override
  Future<Map<String, ExchangeRates>> getRange(Iterable<String> dateKeys) async {
    final keys = dateKeys.toSet().toList();
    if (keys.isEmpty) return {};

    final result = <String, ExchangeRates>{};

    for (var start = 0; start < keys.length; start += _chunkSize) {
      final end =
          start + _chunkSize < keys.length ? start + _chunkSize : keys.length;

      try {
        final query = await _firestore
            .collection(path)
            .where(FieldPath.documentId, whereIn: keys.sublist(start, end))
            .getCacheFirst();

        for (final doc in query.docs) {
          final rates =
              _fromDocument(doc.id, doc.data() as Map<String, dynamic>?);
          if (rates != null) {
            result[doc.id] = rates;
          }
        }
      } catch (exception) {
        Log.error(exception);
      }
    }

    return result;
  }

  @override
  Future<ExchangeRates?> getNearestBefore(String dateKey) async {
    try {
      final query = await _firestore
          .collection(path)
          .orderBy(FieldPath.documentId)
          .endAt([dateKey])
          .limitToLast(1)
          .get();

      if (query.docs.isEmpty) return null;

      final doc = query.docs.first;
      return _fromDocument(doc.id, doc.data());
    } catch (exception) {
      Log.error(exception);
      return null;
    }
  }

  /// Publishes the day's snapshot. Failing is not an error the caller has to
  /// handle: the fetched rates are still usable locally, and the only cost is
  /// that other clients keep hitting the API until one of them lands the write.
  ///
  /// Note the id comes from the *device* clock while the rules compare against
  /// the *server* clock, so a badly skewed device crossing UTC midnight has its
  /// create rejected. That degrades to using the previous day's rate, which is
  /// why it is not worth guarding against.
  @override
  Future<void> putIfAbsent(String dateKey, ExchangeRates rates) async {
    try {
      await _firestore.collection(path).doc(dateKey).set({
        'base': rates.base.isoCode,
        'rates': rates.rates,
        // Server-set so the rules can prove the snapshot is today's; a client
        // cannot pass off old rates as current ones.
        'fetchedAt': FieldValue.serverTimestamp(),
      });
    } catch (exception) {
      // Losing the race to another client, or being rejected by the rules, is
      // expected: the document is already there and the next read picks it up.
      Log.error(exception);
    }
  }

  /// Anchors the snapshot to its document id rather than to `fetchedAt`, so the
  /// key a [RateBook] resolves is always the day the document represents.
  ExchangeRates? _fromDocument(String id, Map<String, dynamic>? data) {
    if (data == null) return null;

    return ExchangeRates.fromMap({
      ...data,
      'fetchedAt': DateTime.tryParse('${id}T00:00:00Z')?.toIso8601String(),
    });
  }
}
