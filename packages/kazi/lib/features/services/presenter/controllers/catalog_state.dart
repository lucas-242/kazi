import 'package:equatable/equatable.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/services/domain/models/catalog_filter.dart';
import 'package:kazi/features/services/domain/models/catalog_item.dart';

class CatalogState extends BaseState with Equatable {
  CatalogState({
    required this.userId,
    CatalogItem? catalogItem,
    List<CatalogItem>? catalogItemList,
    this.archivedCollision,
    this.filter = CatalogFilter.all,
    required super.status,
    super.callbackMessage,
  }) : catalogItem = catalogItem ?? CatalogItem(userId: userId),
       catalogItems = catalogItemList ?? [];
  /// Every item the user owns, archived ones included — the services list joins
  /// against this list, so dropping archived items here would cost old services
  /// their name and colour. Screens that present items read [activeCatalogItems].
  final List<CatalogItem> catalogItems;
  final CatalogItem catalogItem;
  final String userId;

  /// An archived item whose name the user just tried to reuse. The form offers
  /// to restore it instead of refusing the name, which is what stops the
  /// catalog from growing a second row that splits the same total in two.
  final CatalogItem? archivedCollision;

  final CatalogFilter filter;

  List<CatalogItem> get activeCatalogItems =>
      catalogItems.where((item) => !item.isArchived).toList();

  /// What the chips left standing, in the order the chip implies.
  List<CatalogItem> get visibleCatalogItems {
    final items = activeCatalogItems;

    return switch (filter) {
      CatalogFilter.all => items,
      CatalogFilter.withoutCommission => items
          .where((item) => item.effectiveCommissionPercent == null)
          .toList(),
      CatalogFilter.mostUsed =>
        [...items]
          ..sort((a, b) => b.counters.count.compareTo(a.counters.count)),
    };
  }

  /// The period has items but the chips hide all of them.
  bool get isFilteredEmpty =>
      activeCatalogItems.isNotEmpty && visibleCatalogItems.isEmpty;

  List<CatalogItem> get archivedCatalogItems =>
      catalogItems.where((item) => item.isArchived).toList();

  int get archivedCount => archivedCatalogItems.length;

  @override
  CatalogState copyWith({
    List<CatalogItem>? catalogItems,
    CatalogItem? catalogItem,
    CatalogItem? archivedCollision,
    CatalogFilter? filter,
    BaseStateStatus? status,
    String? callbackMessage,
  }) {
    return CatalogState(
      status: status ?? this.status,
      catalogItem: catalogItem ?? this.catalogItem,
      catalogItemList: catalogItems ?? this.catalogItems,
      archivedCollision: archivedCollision ?? this.archivedCollision,
      filter: filter ?? this.filter,
      callbackMessage: callbackMessage ?? this.callbackMessage,
      userId: userId,
    );
  }

  /// Drops a pending [archivedCollision]. A separate method because [copyWith]
  /// reads null as "keep what you have".
  CatalogState withoutArchivedCollision() => CatalogState(
    status: status,
    catalogItem: catalogItem,
    catalogItemList: catalogItems,
    filter: filter,
    callbackMessage: callbackMessage,
    userId: userId,
  );

  @override
  List<Object?> get props => [
    catalogItems,
    catalogItem,
    archivedCollision,
    filter,
    userId,
    status,
    callbackMessage,
  ];
}
