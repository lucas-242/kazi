import 'package:flutter/material.dart';
import 'package:kazi/features/services/domain/models/catalog_item.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// One line of the catalog, shaped like a line of the services list: the item's
/// colour is its identity, so it sits in the leading bar rather than in a dot
/// that costs the name its width.
class CatalogItemCard extends ConsumerWidget {
  const CatalogItemCard({
    super.key,
    required this.catalogItem,
    required this.onTap,
  });
  final Function(CatalogItem) onTap;
  final CatalogItem catalogItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final currency = SupportedCurrency.fromCode(
      catalogItem.currency,
      fallback: ref.watch(kaziDefaultCurrencyProvider),
    );

    return Material(
      color: colors.card,
      borderRadius: KaziRadii.smBorder,
      child: InkWell(
        onTap: () => onTap(catalogItem),
        borderRadius: KaziRadii.smBorder,
        child: Container(
          constraints: const BoxConstraints(
            minHeight: KaziSizings.minTouchTarget,
          ),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: KaziRadii.smBorder,
            border: Border.all(color: colors.border),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                KaziCategoryBar(color: catalogItem.colorAs),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: KaziInsets.md,
                      vertical: KaziInsets.sm,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                catalogItem.name,
                                style: KaziTextStyles.titleSmall,
                              ),
                              KaziSpacings.verticalXxs,
                              Text(
                                KaziLocalizations.current.commissionPercent(
                                  // An item with no commission configured
                                  // keeps the whole value.
                                  NumberFormatUtils.formatPercent(
                                    catalogItem.effectiveCommissionPercent ??
                                        100,
                                  ),
                                ),
                                style: KaziTextStyles.labelSmall.copyWith(
                                  color: colors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        KaziSpacings.horizontalSm,
                        Text(
                          NumberFormatUtils.formatCurrencyIn(
                            catalogItem.defaultValue,
                            currency,
                          ),
                          style: KaziTextStyles.titleSmall,
                        ),
                        KaziSpacings.horizontalXs,
                        Icon(Icons.chevron_right, color: colors.textMuted),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
