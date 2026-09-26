import 'package:flutter/material.dart';
import 'package:kazi/features/dashboard/presenter/widgets/animated_amount.dart';
import 'package:kazi/features/services/domain/models/service_totals.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// The earnings card's Received/Pending panel, revealed by [ExpandToggle].
class EarningsBreakdown extends StatelessWidget {
  const EarningsBreakdown({super.key, required this.totals});

  final ServiceTotals totals;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = KaziLocalizations.current;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: KaziInsets.lg,
        vertical: KaziInsets.sm,
      ),
      color: colors.money.surfaceMuted,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _Stat(
                label: l10n.statReceived,
                amount: totals.receivedCommission,
                currency: totals.currency,
              ),
            ),
            const _StatDivider(),
            Expanded(
              child: _Stat(
                label: l10n.statPending,
                amount: totals.pendingCommission,
                currency: totals.currency,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.amount,
    required this.currency,
  });

  final String label;
  final double amount;
  final SupportedCurrency currency;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: AnimatedAmount(
            value: amount,
            currency: currency,
            // Tabular figures by hand: `titleSmall` does not carry them, and
            // two amounts side by side look uneven when the digits do not
            // keep their column.
            style: KaziTextStyles.titleSmall.copyWith(
              color: colors.money.onSurface,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        KaziSpacings.verticalXxs,
        Text(
          label,
          style: KaziTextStyles.labelSmall.copyWith(
            color: colors.money.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: KaziInsets.xs),
      child: VerticalDivider(
        width: 1,
        thickness: 1,
        color: context.colors.money.onSurface.withValues(alpha: 0.15),
      ),
    );
  }
}
