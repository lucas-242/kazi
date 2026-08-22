import 'package:flutter/material.dart';
import 'package:kazi/features/services/domain/models/catalog_item.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;
import 'package:kazi_core/kazi_core.dart' hide CatalogItem;

class CatalogItemCard extends ConsumerWidget {
  const CatalogItemCard({
    super.key,
    required this.catalogItem,
    required this.onTapEdit,
  });
  final Function(CatalogItem) onTapEdit;
  final CatalogItem catalogItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = SupportedCurrency.fromCode(
      catalogItem.currency,
      fallback: ref.watch(kaziDefaultCurrencyProvider),
    );
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: KaziColorDot(color: catalogItem.colorAs),
      minLeadingWidth: 0,
      title: Text(
        catalogItem.name,
        style: Theme.of(context).textTheme.titleSmall,
      ),
      subtitle: Text(
        KaziLocalizations.current.commissionPercent(
          // An item with no commission configured keeps the whole value.
          NumberFormatUtils.formatPercent(
            catalogItem.effectiveCommissionPercent ?? 100,
          ),
        ),
        style: Theme.of(context).textTheme.labelSmall,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            NumberFormatUtils.formatCurrencyIn(
              catalogItem.defaultValue,
              currency,
            ),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          KaziSpacings.horizontalLg,
          KaziCircularButton(
            onTap: () => onTapEdit(catalogItem),
            child: const Icon(Icons.edit, size: 20),
          ),
        ],
      ),
    );
  }
}
