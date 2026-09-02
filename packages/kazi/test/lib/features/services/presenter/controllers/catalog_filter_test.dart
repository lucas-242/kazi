import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/clients/domain/models/record_counters.dart';
import 'package:kazi/features/services/domain/models/catalog_filter.dart';
import 'package:kazi/features/services/domain/models/catalog_item.dart';
import 'package:kazi/features/services/presenter/controllers/catalog_state.dart';

/// A filter hides rows, which is why "sem comissão" belongs in the chips and
/// not in an ordering: it is a shortcut to a gap worth fixing.
void main() {
  CatalogItem item(
    String id, {
    double? commissionPercent = 45,
    double? discountPercent,
    int uses = 0,
  }) => CatalogItem(
    id: id,
    name: id,
    userId: 'user-1',
    defaultValue: 100,
    commissionPercent: commissionPercent,
    discountPercent: discountPercent,
    counters: RecordCounters(count: uses),
  );

  CatalogState stateWith(List<CatalogItem> items, CatalogFilter filter) =>
      CatalogState(
        status: BaseStateStatus.success,
        userId: 'user-1',
        catalogItemList: items,
        filter: filter,
      );

  final withCommission = item('with', uses: 3);
  final without = item('without', commissionPercent: null, uses: 9);
  final legacy = item(
    'legacy',
    commissionPercent: null,
    discountPercent: 40,
    uses: 1,
  );

  test('Should show every active item under All', () {
    final state = stateWith([
      withCommission,
      without,
      legacy,
    ], CatalogFilter.all);

    expect(state.visibleCatalogItems, hasLength(3));
  });

  test('Should order by uses, most first', () {
    final state = stateWith([
      withCommission,
      without,
      legacy,
    ], CatalogFilter.mostUsed);

    expect(state.visibleCatalogItems.map((i) => i.id), [
      'without',
      'with',
      'legacy',
    ]);
  });

  // A legacy item carries its commission as a mirrored discount, and it is
  // configured — reading it as a gap would send the user to fix nothing.
  test('Should count only an item with no commission at all as a gap', () {
    final state = stateWith([
      withCommission,
      without,
      legacy,
    ], CatalogFilter.withoutCommission);

    expect(state.visibleCatalogItems.map((i) => i.id), ['without']);
  });

  test('Should report a chip that hides everything as filtered-empty', () {
    final state = stateWith([withCommission], CatalogFilter.withoutCommission);

    expect(state.isFilteredEmpty, isTrue);
    expect(
      stateWith([withCommission], CatalogFilter.all).isFilteredEmpty,
      isFalse,
    );
  });

  test('Should not call an empty catalogue filtered-empty', () {
    expect(
      stateWith(const [], CatalogFilter.withoutCommission).isFilteredEmpty,
      isFalse,
    );
  });
}
