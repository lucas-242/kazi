import 'package:flutter/material.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/widgets/sub_nav_bar.dart';
import 'package:kazi/features/services/domain/models/catalog_filter.dart';
import 'package:kazi/features/services/presenter/controllers/catalog_controller.dart';
import 'package:kazi/features/services/presenter/controllers/catalog_state.dart';
import 'package:kazi/features/services/presenter/widgets/catalog_item_card.dart';
import 'package:kazi/features/services/services.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

class CatalogContent extends ConsumerWidget {
  const CatalogContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(catalogControllerProvider);
    final items = state.visibleCatalogItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(state: state),
        KaziSpacings.verticalMd,
        _FilterChips(state: state),
        KaziSpacings.verticalMd,
        if (state.isFilteredEmpty)
          _FilteredEmpty(state: state)
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            // A gap, not a rule: a divider between two bordered cards reads as
            // a third.
            separatorBuilder: (context, index) => KaziSpacings.verticalXs,
            itemBuilder: (context, index) => CatalogItemCard(
              catalogItem: items[index],
              onTap: (catalogItem) => KaziNavigator.push(
                AppPage.catalogItemDetails,
                extra: CatalogItemArguments(catalogItem: catalogItem),
              ),
            ),
          ),
        KaziSpacings.verticalLg,
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.state});

  final CatalogState state;

  @override
  Widget build(BuildContext context) {
    return SubNavBar(
      title: KaziLocalizations.current.catalogItems,
      showDivider: false,
      pills: [
        Text(
          state.activeCatalogItems.length.toString(),
          style: KaziTextStyles.tag.copyWith(color: context.colors.textMuted),
        ),
        KaziSpacings.horizontalXs,
        KaziCircularButton.plain(
          onTap: () => KaziNavigator.push(AppPage.addCatalogItem),
          semantics: KaziLocalizations.current.add,
          child: const Icon(Icons.add, size: 18),
        ),
        // Same shape as the clients list: the archive is a door used once a
        // quarter, and it disappears when there is nothing behind it.
        KaziOverflowMenu(
          semantics: KaziLocalizations.current.actions,
          actions: [
            if (state.archivedCount > 0)
              KaziOverflowAction(
                label: KaziLocalizations.current.viewArchived(
                  state.archivedCount,
                ),
                icon: Icons.inventory_2_outlined,
                onTap: () => KaziNavigator.push(AppPage.archivedCatalogItems),
              ),
          ],
        ),
      ],
    );
  }
}

class _FilterChips extends ConsumerWidget {
  const _FilterChips({required this.state});

  final CatalogState state;

  String _label(CatalogFilter filter) => switch (filter) {
    CatalogFilter.all => KaziLocalizations.current.catalogAll,
    CatalogFilter.mostUsed => KaziLocalizations.current.catalogMostUsed,
    CatalogFilter.withoutCommission =>
      KaziLocalizations.current.catalogWithoutCommission,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(catalogControllerProvider.notifier);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: KaziInsets.xs,
        children: [
          for (final filter in CatalogFilter.values)
            KaziChip(
              label: _label(filter),
              isSelected: state.filter == filter,
              onTap: () => controller.onChangeFilter(filter),
            ),
        ],
      ),
    );
  }
}

/// The chips hid every item. Never the empty state — removing the chip would
/// bring rows back, so what is missing is the cut, not the catalogue.
class _FilteredEmpty extends ConsumerWidget {
  const _FilteredEmpty({required this.state});

  final CatalogState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return KaziNoResults(
      message: KaziLocalizations.current.noResults,
      action: KaziPillButton(
        onTap: () => ref
            .read(catalogControllerProvider.notifier)
            .onChangeFilter(CatalogFilter.all),
        outlinedButton: true,
        child: Text(KaziLocalizations.current.removeFilters),
      ),
    );
  }
}
