import 'package:flutter/material.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/services/domain/models/catalog_item.dart';
import 'package:kazi/features/services/presenter/controllers/catalog_controller.dart';
import 'package:kazi/features/services/presenter/controllers/catalog_state.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

class CatalogItemDetailsPage extends ConsumerWidget {
  const CatalogItemDetailsPage({super.key, required this.catalogItem});

  /// The item as it was when this page was pushed. A starting point, not the
  /// source of truth: the catalogue list below is what an edit updates.
  final CatalogItem catalogItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<CatalogState>(catalogControllerProvider, (previous, current) {
      if (previous?.status != current.status &&
          current.status == BaseStateStatus.error) {
        KaziSnackbar.show(context, current.callbackMessage);
      }
    });

    final controller = ref.read(catalogControllerProvider.notifier);
    final items = ref.watch(catalogControllerProvider).catalogItems;
    final item = items.firstWhere(
      (candidate) => candidate.id == catalogItem.id,
      orElse: () => catalogItem,
    );

    final currency = SupportedCurrency.fromCode(
      item.currency,
      fallback: ref.watch(kaziDefaultCurrencyProvider),
    );

    void onTapEdit() {
      controller.changeCatalogItem(item);
      KaziNavigator.push(AppPage.addCatalogItem);
    }

    Future<void> onDelete() async {
      KaziNavigator.pop();
      await controller.deleteCatalogItem(item);
      // An item still in use is refused, and the snackbar above says so — so
      // the page only closes once the deletion actually happened.
      final isGone = !ref
          .read(catalogControllerProvider)
          .catalogItems
          .any((candidate) => candidate.id == item.id);
      if (isGone) KaziNavigator.pop();
    }

    void onTapDelete() {
      showDialog(
        context: context,
        builder: (_) => KaziDialog(
          title: KaziLocalizations.current.delete,
          message: KaziLocalizations.current.wouldYouLikeDelete(
            KaziLocalizations.current.thisCatalogItem,
          ),
          confirmText: KaziLocalizations.current.delete,
          onCancel: KaziNavigator.pop,
          onConfirm: onDelete,
        ),
      );
    }

    return Scaffold(
      appBar: KaziAppBar(
        title: KaziLocalizations.current.details,
        actions: [
          KaziCircularButton(
            onTap: onTapEdit,
            backgroundColor: context.colors.brand.fill,
            child: Icon(Icons.edit, color: context.colors.brand.onFill),
          ),
          KaziSpacings.horizontalXs,
          KaziCircularButton(
            onTap: onTapDelete,
            backgroundColor: context.colors.danger.surface,
            child: Icon(Icons.delete, color: context.colors.danger.onSurface),
          ),
          KaziSpacings.horizontalSm,
        ],
      ),
      body: KaziSafeArea(
        child: _CatalogItemDetails(catalogItem: item, currency: currency),
      ),
    );
  }
}

class _CatalogItemDetails extends StatelessWidget {
  const _CatalogItemDetails({required this.catalogItem, required this.currency});

  final CatalogItem catalogItem;
  final SupportedCurrency currency;

  @override
  Widget build(BuildContext context) {
    final commission = catalogItem.effectiveCommissionPercent ?? 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            KaziColorDot(color: catalogItem.colorAs, size: 18),
            KaziSpacings.horizontalSm,
            Expanded(
              child: Text(
                catalogItem.name,
                style: KaziTextStyles.titleMedium,
              ),
            ),
          ],
        ),
        KaziSpacings.verticalXLg,
        _InfoRow(
          label: KaziLocalizations.current.serviceValue,
          value: NumberFormatUtils.formatCurrencyIn(
            catalogItem.defaultValue,
            currency,
          ),
        ),
        KaziSpacings.verticalMd,
        _InfoRow(
          label: KaziLocalizations.current.commissionPercentage,
          value: NumberFormatUtils.formatPercent(commission),
        ),
        KaziSpacings.verticalMd,
        _InfoRow(
          label: KaziLocalizations.current.currency,
          value: '${currency.isoCode} (${currency.symbol})',
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: KaziTextStyles.bodySmall.copyWith(
            color: context.colors.textMuted,
          ),
        ),
        KaziSpacings.verticalXs,
        Text(value, style: KaziTextStyles.bodyMedium),
      ],
    );
  }
}
