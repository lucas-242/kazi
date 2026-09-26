import 'package:flutter/material.dart';
import 'package:kazi/features/onboarding/domain/models/checklist_step.dart';
import 'package:kazi/features/onboarding/presenter/controllers/checklist_controller.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// The five-step trail, on the home, between the money panel and today's list.
///
/// It removes itself: finished, or once ten services are registered. Nothing on
/// it is mandatory and none of it blocks the screen. Open by default; the
/// chevron collapses it down to just the header for anyone who wants it out
/// of the way without dismissing it outright.
class OnboardingChecklistCard extends ConsumerStatefulWidget {
  const OnboardingChecklistCard({super.key});

  @override
  ConsumerState<OnboardingChecklistCard> createState() =>
      _OnboardingChecklistCardState();
}

class _OnboardingChecklistCardState
    extends ConsumerState<OnboardingChecklistCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
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
        color: colors.card,
        borderRadius: KaziRadii.mdBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: KaziRadii.xsBorder,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.checklistTitle,
                    style: KaziTextStyles.titleSmall.copyWith(
                      color: colors.text,
                    ),
                  ),
                ),
                Text(
                  l10n.checklistProgress(state.doneCount, total),
                  style: KaziTextStyles.tag.copyWith(color: colors.brand.text),
                ),
                KaziSpacings.horizontalXxs,
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: Durations.short3,
                  child: Icon(
                    LucideIcons.chevronDown,
                    size: 20,
                    color: colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            duration: Durations.short3,
            crossFadeState: _expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KaziSpacings.verticalXs,
                _ProgressBar(done: state.doneCount, total: total),
                KaziSpacings.verticalXs,
                for (final step in ChecklistStep.values)
                  _StepRow(step: step, done: state.isDone(step)),
              ],
            ),
            secondChild: const SizedBox(width: double.infinity),
          ),
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
        backgroundColor: colors.surfaceMuted,
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
    final ink = done ? colors.textMuted : colors.text;

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
                  color: done ? colors.brand.fill : colors.border,
                  width: 1.3,
                ),
              ),
              child: done
                  ? Icon(
                      LucideIcons.check,
                      size: 12,
                      color: colors.brand.onFill,
                    )
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
