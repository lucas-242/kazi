import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

abstract class CurrencyMigrationRepository {
  /// Stamps [currency] onto every service and catalog item of [userId] that
  /// still has none, anchoring each service to the rate snapshot of its own
  /// date. Returns how many documents were updated.
  ///
  /// Must be idempotent: documents that already carry a currency are skipped,
  /// so an interrupted run can simply be repeated.
  Future<int> backfillCurrency(String userId, SupportedCurrency currency);
}
