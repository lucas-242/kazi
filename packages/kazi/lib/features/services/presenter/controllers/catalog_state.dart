import 'package:equatable/equatable.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/services/domain/models/catalog_item.dart';

class CatalogState extends BaseState with Equatable {
  CatalogState({
    required this.userId,
    CatalogItem? catalogItem,
    List<CatalogItem>? catalogItemList,
    required super.status,
    super.callbackMessage,
  }) : catalogItem = catalogItem ?? CatalogItem(userId: userId),
       catalogItems = catalogItemList ?? [];
  final List<CatalogItem> catalogItems;
  final CatalogItem catalogItem;
  final String userId;

  @override
  CatalogState copyWith({
    List<CatalogItem>? catalogItems,
    CatalogItem? catalogItem,
    BaseStateStatus? status,
    String? callbackMessage,
  }) {
    return CatalogState(
      status: status ?? this.status,
      catalogItem: catalogItem ?? this.catalogItem,
      catalogItemList: catalogItems ?? this.catalogItems,
      callbackMessage: callbackMessage ?? this.callbackMessage,
      userId: userId,
    );
  }

  @override
  List<Object?> get props => [
    catalogItems,
    catalogItem,
    userId,
    status,
    callbackMessage,
  ];
}
