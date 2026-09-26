import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/features/dashboard/domain/models/period_trend.dart';
import 'package:kazi/features/dashboard/presenter/controllers/dashboard_state.dart';
import 'package:kazi/features/dashboard/presenter/widgets/animated_amount.dart';
import 'package:kazi/features/dashboard/presenter/widgets/earnings_breakdown.dart';
import 'package:kazi/features/dashboard/presenter/widgets/earnings_sparkline.dart';
import 'package:kazi/features/dashboard/presenter/widgets/expand_toggle.dart';
import 'package:kazi/features/services/domain/models/service_totals.dart';
import 'package:kazi/features/settings/domain/models/billing_cycle.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// The floating black card: this cycle's commission on top, the sparkline
/// below it, and — one tap away — how much of it has actually landed.
/// See README.md.
class EarningsCard extends StatefulWidget {
  const EarningsCard({super.key, required this.state, required this.totals});

  final DashboardState state;

  /// `state.totals`, resolved once by the page — it re-sums every service on
  /// each read.
  final ServiceTotals totals;

  @override
  State<EarningsCard> createState() => _EarningsCardState();
}

class _EarningsCardState extends State<EarningsCard> {
  bool _expanded = false;

  /// Resolved per genuine change to [EarningsCard.state]: toggling [_expanded]
  /// rebuilds this widget without a new state, and [periodTotals] is a full
  /// pass over every service.
  late PeriodTrend _trend = _resolveTrend();

  /// The bucket under the finger, today's until one is touched. Lives here,
  /// not in [EarningsSparkline], so a tap anywhere else on this card can send
  /// it back — those are siblings of the chart's gesture region, never its
  /// ancestor. See README.md.
  late int? _selectedBucketIndex = _defaultSelection();

  @override
  void didUpdateWidget(EarningsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _trend = _resolveTrend();
      _selectedBucketIndex = _defaultSelection();
    }
  }

  /// "Seus ganhos este mês" only fits a monthly cycle; whoever is paid
  /// fortnightly reads a window they are not looking at.
  String get _eyebrow {
    final l10n = KaziLocalizations.current;
    return switch (widget.state.cycleType) {
      BillingCycleType.fortnightly => l10n.earningsThisFortnight,
      BillingCycleType.weekly => l10n.earningsThisWeek,
      BillingCycleType.custom => l10n.earningsThisCycle,
      BillingCycleType.monthly || null => l10n.earningsThisMonth,
    };
  }

  PeriodTrend _resolveTrend() {
    final state = widget.state;
    final range = state.cycleRange;
    if (range == null) return emptyPeriodTrend;

    return periodTotals(
      state.services,
      start: range.start,
      end: range.end,
      currency: state.defaultCurrency,
      rateBook: state.rateBook,
    );
  }

  void _onToggleExpanded() {
    HapticFeedback.selectionClick();
    setState(() => _expanded = !_expanded);
  }

  void _onSelectBucket(int? index) {
    if (index != _selectedBucketIndex) {
      setState(() => _selectedBucketIndex = index);
    }
  }

  void _resetSelection() => _onSelectBucket(_defaultSelection());

  /// Today's bucket — null when the cycle on screen does not cover today, and
  /// the chart rests with nothing named.
  int? _defaultSelection() {
    final referenceDate = widget.state.referenceDate;
    return referenceDate == null ? null : _trend.indexOn(referenceDate);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final totals = widget.totals;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: KaziRadii.lgBorder,
        boxShadow: [
          BoxShadow(
            color: colors.money.surface.withValues(alpha: 0.16),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: KaziRadii.lgBorder,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(colors.money.surface, Colors.white, 0.05)!,
                colors.money.surface,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  KaziInsets.lg,
                  KaziInsets.lg - KaziInsets.xxs,
                  KaziInsets.lg,
                  KaziInsets.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _resetSelection,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _eyebrow,
                                  style: KaziTextStyles.labelMedium.copyWith(
                                    color: colors.money.onSurface.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ),
                                KaziSpacings.verticalXs,
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: AnimatedAmount(
                                    value: totals.commission,
                                    currency: totals.currency,
                                    style: KaziTextStyles.amount.copyWith(
                                      color: colors.money.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ExpandToggle(
                            expanded: _expanded,
                            onTap: _onToggleExpanded,
                          ),
                        ],
                      ),
                    ),
                    if (_trend.buckets.length > 2) ...[
                      KaziSpacings.verticalSm,
                      EarningsSparkline(
                        trend: _trend,
                        expanded: _expanded,
                        currency: totals.currency,
                        textColor: colors.money.onSurface.withValues(
                          alpha: 0.7,
                        ),
                        receivedColor: colors.money.accent,
                        pendingColor: colors.money.onSurface.withValues(
                          alpha: 0.35,
                        ),
                        selectedIndex: _selectedBucketIndex,
                        onSelect: _onSelectBucket,
                      ),
                    ],
                  ],
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _resetSelection,
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  child: _expanded
                      ? EarningsBreakdown(totals: totals)
                      : const SizedBox(width: double.infinity),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
