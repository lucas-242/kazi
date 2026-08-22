import 'package:kazi_core/kazi_core.dart';

abstract interface class CatalogItemRepository {
  Future<List<CatalogItem>> get();
}
