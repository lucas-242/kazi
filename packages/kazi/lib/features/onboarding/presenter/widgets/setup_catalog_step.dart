import 'package:flutter/material.dart';
import 'package:kazi/features/onboarding/domain/models/setup_catalog_item.dart';
import 'package:kazi/features/onboarding/presenter/controllers/guided_setup_controller.dart';
import 'package:kazi/features/onboarding/presenter/controllers/guided_setup_state.dart';
import 'package:kazi/features/onboarding/presenter/widgets/setup_item_sheet.dart';
import 'package:kazi/core/widgets/option_tile.dart';
import 'package:kazi/features/onboarding/presenter/widgets/setup_editable_price.dart';
import 'package:kazi/features/onboarding/presenter/widgets/setup_scaffold.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// Screen 2 — the catalog, which is the whole reason the setup exists.
///
/// This is the most critical CRUD in the app, resolved in taps: the kit arrives
/// with the common services ticked, the rest visible and unticked, and every
/// price editable in place.
class SetupCatalogStep extends ConsumerWidget {
  const SetupCatalogStep({super.key, required this.state});

  final GuidedSetupState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = KaziLocalizations.current;
    final controller = ref.read(guidedSetupControllerProvider.notifier);
    final isTypedPath = state.preset == null;
    final selectedCount = state.selectedItems.length;

    return SetupScaffold(
      step: SetupStep.catalog,
      onClose: () => showSetupExitDialog(context, ref),
      title: isTypedPath
          ? l10n.setupCatalogTypedTitle
          : l10n.setupCatalogTitle,
      subtitle: isTypedPath
          ? l10n.setupCatalogTypedSubtitle
          : l10n.setupCatalogSubtitle,
      action: KaziElevatedButton.label(
        label: l10n.setupCatalogContinueWith(selectedCount),
        // One is enough for the app to calculate. Demanding three before any
        // value has been delivered is what strands people at the door.
        onTap: state.canContinueFromCatalog
            ? () => controller.goToStep(SetupStep.commission)
            : null,
      ),
      footer: KaziTextButton(
        onTap: () => openSetupItemSheet(context, ref, currency: state.currency),
        child: Text(l10n.setupCatalogAddAnother),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in state.items)
            OptionTile(
              label: item.name,
              selected: item.selected,
              onTap: () => controller.toggleItem(item.id),
              trailing: _Price(item: item, state: state),
            ),
          // The typed path arrives here with nothing, so the empty state has
          // to be the action itself rather than a link at the bottom of a
          // blank screen.
          if (state.items.isEmpty)
            OptionTile(
              label: l10n.setupCatalogAddAnother,
              showCheckbox: false,
              onTap: () =>
                  openSetupItemSheet(context, ref, currency: state.currency),
            ),
          KaziSpacings.verticalXs,
          Text(
            l10n.setupCatalogBlankPrice,
            style: KaziTextStyles.bodySmall.copyWith(
              color: context.colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _Price extends ConsumerWidget {
  const _Price({required this.item, required this.state});

  final SetupCatalogItem item;
  final GuidedSetupState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = item.value;
    final label = value == null
        ? KaziLocalizations.current.setupPriceSheetValue
        : NumberFormatUtils.formatCurrencyIn(value, state.currency);

    return SetupEditablePrice(
      label: label,
      onTap: () => openSetupItemSheet(
        context,
        ref,
        currency: state.currency,
        item: item,
      ),
    );
  }
}
