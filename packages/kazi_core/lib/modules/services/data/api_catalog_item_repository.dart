import 'package:kazi_core/modules/services/data/mocks/catalog_item_mock.dart';
import 'package:kazi_core/modules/services/domain/repositories/catalog_item_repository.dart';
import 'package:kazi_core/shared/entities/catalog_item.dart';

final class ApiCatalogItemRepository implements CatalogItemRepository {
  @override
  Future<List<CatalogItem>> get() async {
    await Future.delayed(const Duration(seconds: 1));
    return CatalogItemMock.all;
  }
}
