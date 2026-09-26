import 'package:flutter/material.dart';
import 'package:kazi/features/onboarding/domain/models/setup_catalog_item.dart';
import 'package:kazi/features/onboarding/presenter/controllers/guided_setup_controller.dart';
import 'package:kazi/features/onboarding/presenter/controllers/guided_setup_state.dart';
import 'package:kazi/core/widgets/option_tile.dart';
import 'package:kazi/features/onboarding/presenter/widgets/setup_commission_sheet.dart';
import 'package:kazi/features/onboarding/presenter/widgets/setup_scaffold.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// Screen 5 — the commission, which is the app's entire calculation.
///
/// One percentage for everything, exceptions by tap. The question is phrased
/// as what the user *keeps*, never as what is withheld: it is their money the
/// number describes. Nothing is preselected: the kit's default is a guess, and
/// shown as an answer it gets accepted without being read.
class SetupCommissionStep extends ConsumerWidget {
  const SetupCommissionStep({super.key, required this.state});

  final GuidedSetupState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = KaziLocalizations.current;
    final controller = ref.read(guidedSetupControllerProvider.notifier);
    final shared = state.commissionAnswered ? _sharedPercent(state) : null;
    final isOther = shared != null && !setupCommissionPresets.contains(shared);

    return SetupScaffold(
      flow: state.flow,
      step: SetupStep.commission,
      onBack: controller.back,
      title: l10n.setupCommissionTitle,
      subtitle: l10n.setupCommissionSubtitle,
      actionLabel: l10n.setupContinue,
      onAction: state.canContinueFromCommission
          ? controller.goToNextStep
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: KaziInsets.xs,
            runSpacing: KaziInsets.xs,
            children: [
              for (final percent in setupCommissionPresets)
                KaziChip(
                  label: NumberFormatUtils.formatPercent(percent),
                  isSelected: shared == percent,
                  onTap: () => controller.setCommissionForAll(percent),
                ),
              KaziChip(
                label: isOther
                    ? NumberFormatUtils.formatPercent(shared)
                    : l10n.setupCommissionOther,
                isSelected: isOther,
                onTap: () => _editAll(context, ref, shared),
              ),
            ],
          ),
          KaziSpacings.verticalMd,
          for (final item in state.selectedItems)
            OptionTile(
              label: item.name,
              mark: OptionMark.none,
              detail: state.isCommissionKnown(item)
                  ? NumberFormatUtils.formatPercent(item.commissionPercent)
                  : null,
              onTap: () => _editOne(context, ref, item),
            ),
          KaziSpacings.verticalXs,
          Text(
            l10n.setupCommissionPerItem,
            style: KaziTextStyles.bodySmall.copyWith(
              color: context.colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  /// The percentage the untouched items agree on; null once they disagree.
  static double? _sharedPercent(GuidedSetupState state) {
    final open = state.selectedItems
        .where((item) => !item.hasCustomCommission)
        .toList();
    if (open.isEmpty) return null;

    final first = open.first.commissionPercent;
    return open.every((item) => item.commissionPercent == first) ? first : null;
  }

  Future<void> _editAll(
    BuildContext context,
    WidgetRef ref,
    double? current,
  ) async {
    final picked = await openSetupCommissionSheet(
      context,
      title: KaziLocalizations.current.setupPriceSheetKeep,
      initial: current,
    );
    if (picked == null) return;
    ref
        .read(guidedSetupControllerProvider.notifier)
        .setCommissionForAll(picked);
  }

  Future<void> _editOne(
    BuildContext context,
    WidgetRef ref,
    SetupCatalogItem item,
  ) async {
    final picked = await openSetupCommissionSheet(
      context,
      title: item.name,
      initial: state.isCommissionKnown(item) ? item.commissionPercent : null,
    );
    if (picked == null) return;
    ref
        .read(guidedSetupControllerProvider.notifier)
        .setCommissionFor(item.id, picked);
  }
}
