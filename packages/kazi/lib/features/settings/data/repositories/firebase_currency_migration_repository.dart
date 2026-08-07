import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kazi/core/services/domain/crashlytics_service.dart';
import 'package:kazi/features/settings/domain/repositories/currency_migration_repository.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

/// One-off backfill for data written before the app knew about currencies.
///
/// Documents are paged by id and filtered **in memory** rather than with a
/// `where('currency', isEqualTo: '')` clause: combined with the `userId`
/// filter that would need a composite index, and a user's own collection is
/// small enough that paging it is cheaper than shipping an index.
class FirebaseCurrencyMigrationRepository implements CurrencyMigrationRepository {
  FirebaseCurrencyMigrationRepository(
    FirebaseFirestore firestore,
    this._crashlyticsService,
  ) : _firestore = firestore;

  final FirebaseFirestore _firestore;
  final CrashlyticsService _crashlyticsService;

  /// Kept below Firestore's cap of 500 writes per batch, so one page always
  /// fits in one batch.
  static const int _pageSize = 400;

  @override
  Future<int> backfillCurrency(
    String userId,
    SupportedCurrency currency,
  ) async {
    try {
      final services = await _backfill(
        collection: 'services',
        userId: userId,
        currency: currency,
        // Anchor each service to its own date. The shared history rarely
        // reaches that far back, and RateBook then falls back to the closest
        // snapshot it has — but the anchor is recorded, so the day the history
        // does cover it, the conversion becomes exact without another write.
        extraFields: (data) => {
          'rateDate': ExchangeRates.dateKeyOf(
            (data['date'] as Timestamp).toDate(),
          ),
        },
      );

      final types = await _backfill(
        collection: 'serviceTypes',
        userId: userId,
        currency: currency,
      );

      return services + types;
    } catch (exception, trace) {
      Log.error(exception);
      _crashlyticsService.log(exception, trace);
      throw ExternalError(KaziLocalizations.current.errorToMigrateCurrency);
    }
  }

  Future<int> _backfill({
    required String collection,
    required String userId,
    required SupportedCurrency currency,
    Map<String, dynamic> Function(Map<String, dynamic> data)? extraFields,
  }) async {
    var updated = 0;
    String? lastId;

    while (true) {
      var query = _firestore
          .collection(collection)
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

      final batch = _firestore.batch();
      var pending = 0;

      for (final doc in page.docs) {
        final data = doc.data();
        final existing = data['currency'];
        if (existing is String && existing.isNotEmpty) continue;

        batch.update(doc.reference, {
          'currency': currency.isoCode,
          ...?extraFields?.call(data),
        });
        pending++;
      }

      if (pending > 0) {
        await batch.commit();
        updated += pending;
      }

      if (page.docs.length < _pageSize) break;
      lastId = page.docs.last.id;
    }

    return updated;
  }
}
