import 'package:flutter/material.dart';
import 'package:kazi/features/onboarding/domain/models/checklist_step.dart';
import 'package:kazi/features/onboarding/presenter/controllers/checklist_controller.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// The five-step trail, on the home, between the money panel and today's list.
///
/// It removes itself: finished, or once ten services are registered. Nothing on
/// it is mandatory and none of it blocks the screen.
class OnboardingChecklistCard extends ConsumerWidget {
  const OnboardingChecklistCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(checklistControllerProvider).asData?.value;
    if (state == null || !state.isVisible) return const SizedBox.shrink();

    final colors = context.colors;
    final l10n = KaziLocalizations.current;
    final total = ChecklistStep.values.length;

    return Container(
      width: double.infinity,
      // The gap below belongs to the card rather than to the home, because
      // whether the card is there at all is resolved asynchronously in here —
      // a guard at the call site would have to duplicate that decision.
      margin: const EdgeInsets.only(bottom: KaziInsets.md),
      padding: const EdgeInsets.all(KaziInsets.sm),
      decoration: BoxDecoration(
        color: colors.money.surface,
        borderRadius: KaziRadii.mdBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.checklistTitle,
                  style: KaziTextStyles.titleSmall.copyWith(
                    color: colors.money.onSurface,
                  ),
                ),
              ),
              Text(
                l10n.checklistProgress(state.doneCount, total),
                style: KaziTextStyles.tag.copyWith(color: colors.brand.fill),
              ),
            ],
          ),
          KaziSpacings.verticalXs,
          _ProgressBar(done: state.doneCount, total: total),
          KaziSpacings.verticalXs,
          for (final step in ChecklistStep.values)
            _StepRow(step: step, done: state.isDone(step)),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ClipRRect(
      borderRadius: KaziRadii.fullBorder,
      child: LinearProgressIndicator(
        value: total == 0 ? 0 : done / total,
        minHeight: 4,
        backgroundColor: colors.money.onSurface.withValues(alpha: 0.2),
        valueColor: AlwaysStoppedAnimation(colors.brand.fill),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.step, required this.done});

  final ChecklistStep step;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ink = colors.money.onSurface.withValues(alpha: done ? 0.5 : 0.9);

    return Semantics(
      checked: done,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: KaziInsets.xxs),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: done ? colors.brand.fill : Colors.transparent,
                borderRadius: KaziRadii.xsBorder,
                border: Border.all(
                  color: done ? colors.brand.fill : ink,
                  width: 1.3,
                ),
              ),
              child: done
                  ? Icon(Icons.check, size: 12, color: colors.brand.onFill)
                  : null,
            ),
            KaziSpacings.horizontalXs,
            Expanded(
              child: Text(
                step.label,
                style: KaziTextStyles.bodySmall.copyWith(
                  color: ink,
                  decoration: done ? TextDecoration.lineThrough : null,
                  decorationColor: ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
