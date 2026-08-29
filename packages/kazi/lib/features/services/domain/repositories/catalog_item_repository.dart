import 'package:kazi/features/services/domain/models/catalog_item.dart';

abstract class CatalogItemRepository {
  Future<CatalogItem> add(CatalogItem catalogItem);

  /// Writes [catalogItems] in one atomic batch, returning them with their
  /// generated ids. Used to seed a whole profession preset: one round trip, and
  /// a network failure leaves no half-written catalog behind.
  Future<List<CatalogItem>> addAll(List<CatalogItem> catalogItems);

  /// Removes the document for good. Only ever called for an item no service
  /// points at — see core/archiving.md.
  Future<void> delete(String id);

  /// Every item the user owns, archived ones included: the services list joins
  /// against this to keep showing the name of an archived item. Callers that
  /// present a picker filter it themselves.
  Future<List<CatalogItem>> get(String userId);
  Future<void> update(CatalogItem catalogItem);

  /// Hides the item from pickers and listings without touching anything a
  /// service reads. Returns the moment it was archived.
  Future<DateTime> archive(String id);
  Future<void> restore(String id);
}
