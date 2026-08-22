import 'package:kazi/features/services/domain/models/catalog_item.dart';

abstract class CatalogItemRepository {
  Future<CatalogItem> add(CatalogItem catalogItem);

  /// Writes [catalogItems] in one atomic batch, returning them with their
  /// generated ids. Used to seed a whole profession preset: one round trip, and
  /// a network failure leaves no half-written catalog behind.
  Future<List<CatalogItem>> addAll(List<CatalogItem> catalogItems);
  Future<void> delete(String id);
  Future<List<CatalogItem>> get(String userId);
  Future<void> update(CatalogItem catalogItem);
}
