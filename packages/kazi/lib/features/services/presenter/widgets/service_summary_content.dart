import 'package:flutter/material.dart';
import 'package:kazi/features/services/domain/models/service_breakdown.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_controller.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_state.dart';
import 'package:kazi/features/services/presenter/widgets/mark_received_bar.dart';
import 'package:kazi/features/services/presenter/widgets/partial_totals_note.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// How many clients the ranking shows — a podium, not a directory.
const _topClientCount = 5;

/// The summary side of the services tab: the same filtered services, totalled
/// and broken down instead of listed.
class ServiceSummaryContent extends ConsumerWidget {
  const ServiceSummaryContent({super.key, required this.state});

  final ServiceLandingState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totals = state.totals;
    final byType = state.breakdownByType(KaziLocalizations.current.withoutCatalogItem);
    final byClient = state.breakdownByClient;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _PeriodCard(state: state),
        PartialTotalsNote(totals: totals),
        MarkReceivedBar(totals: totals),
        if (!byType.isEmpty) ...[
          KaziSpacings.verticalLg,
          _SectionHeading(title: KaziLocalizations.current.byCatalogItem),
          KaziSpacings.verticalSm,
          _TypeBreakdown(breakdown: byType),
        ],
        if (!byClient.isEmpty) ...[
          KaziSpacings.verticalLg,
          _SectionHeading(title: KaziLocalizations.current.topClients),
          KaziSpacings.verticalSm,
          _ClientBreakdown(breakdown: byClient),
        ],
        KaziSpacings.verticalLg,
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    // Upper-cased at the call site: Flutter has no text-transform.
    return Text(
      title.toUpperCase(),
      style: KaziTextStyles.tag.copyWith(color: context.colors.textMuted),
    );
  }
}

/// What the period was worth, and what of it is the user's. A plain card, not
/// a second graphite panel — see README.md.
class _PeriodCard extends StatelessWidget {
  const _PeriodCard({required this.state});

  final ServiceLandingState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final totals = state.totals;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KaziInsets.md),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: KaziRadii.smBorder,
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            KaziLocalizations.current.generatedInPeriod.toUpperCase(),
            style: KaziTextStyles.tag.copyWith(color: colors.textMuted),
          ),
          KaziSpacings.verticalXs,
          // Scaled rather than wrapped: a truncated amount is worse than a
          // smaller one.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              NumberFormatUtils.formatCurrencyIn(totals.value, totals.currency),
              style: KaziTextStyles.amount,
            ),
          ),
          KaziSpacings.verticalXs,
          Text(
            KaziLocalizations.current.toReceive(
              NumberFormatUtils.formatCurrencyIn(
                totals.commission,
                totals.currency,
              ),
            ),
            // Amber, not the brand yellow: yellow is surface, never text ink.
            style: KaziTextStyles.labelLarge.copyWith(color: colors.brand.text),
          ),
          if (totals.withheld > 0) ...[
            KaziSpacings.verticalXxs,
            Text(
              '${KaziLocalizations.current.discounts}: '
              '${NumberFormatUtils.formatCurrencyIn(totals.withheld, totals.currency)}',
              style: KaziTextStyles.labelSmall.copyWith(
                color: colors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TypeBreakdown extends StatelessWidget {
  const _TypeBreakdown({required this.breakdown});

  final ServiceBreakdown breakdown;

  /// The colour an item falls back to when it never got one of its own. Keyed
  /// on the item's id, never on its position — changing a filter must not
  /// repaint the bars that survive it.
  Color _fallbackColor(BuildContext context, String id) {
    var seed = 0;
    for (final unit in id.codeUnits) {
      seed = (seed + unit) % 1000;
    }
    return context.colors.category(seed);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(KaziInsets.md),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: KaziRadii.smBorder,
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          for (final slice in breakdown.slices) ...[
            if (slice != breakdown.slices.first) KaziSpacings.verticalSm,
            _BreakdownRow(
              slice: slice,
              currency: breakdown.currency,
              // An all-zero period would divide by zero.
              fraction: breakdown.max <= 0 ? 0 : slice.value / breakdown.max,
              color: slice.color ?? _fallbackColor(context, slice.id),
            ),
          ],
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.slice,
    required this.currency,
    required this.fraction,
    required this.color,
  });

  final BreakdownSlice slice;
  final SupportedCurrency currency;
  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                slice.label,
                style: KaziTextStyles.labelSmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            KaziSpacings.horizontalXs,
            Text(
              NumberFormatUtils.formatCurrencyIn(slice.value, currency),
              // Ink, not the slice's colour: coloured numbers read as status.
              style: KaziTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        KaziSpacings.verticalXxs,
        ClipRRect(
          borderRadius: KaziRadii.fullBorder,
          child: LinearProgressIndicator(
            value: fraction.clamp(0, 1),
            minHeight: 6,
            backgroundColor: colors.surfaceStrong,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _ClientBreakdown extends ConsumerWidget {
  const _ClientBreakdown({required this.breakdown});

  final ServiceBreakdown breakdown;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final controller = ref.read(serviceLandingControllerProvider.notifier);
    final slices = breakdown.top(_topClientCount);

    return Column(
      children: [
        for (final slice in slices) ...[
          if (slice != slices.first) KaziSpacings.verticalXs,
          Material(
            color: colors.card,
            borderRadius: KaziRadii.smBorder,
            child: InkWell(
              // Filtering in place answers "how much did this person bring me"
              // without a new screen.
              onTap: () => controller.onSelectClient(slice.id),
              borderRadius: KaziRadii.smBorder,
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: KaziSizings.minTouchTarget,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: KaziInsets.md,
                  vertical: KaziInsets.sm,
                ),
                decoration: BoxDecoration(
                  borderRadius: KaziRadii.smBorder,
                  border: Border.all(color: colors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            slice.label,
                            style: KaziTextStyles.titleSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                          KaziSpacings.verticalXxs,
                          Text(
                            KaziLocalizations.current.servicesCount(
                              slice.count,
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
                        slice.value,
                        breakdown.currency,
                      ),
                      style: KaziTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
