import 'package:flutter/material.dart';
import 'package:kazi/features/services/domain/models/weekly_earnings.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// The summary's chart: one column per week of the filtered period, stacked in
/// **two inks only** — graphite for what has arrived, a neutral for what has
/// not. See README.md.
class WeeklyEarningsChart extends StatelessWidget {
  const WeeklyEarningsChart({super.key, required this.earnings});

  static const double _height = 72;

  final WeeklyEarnings earnings;

  @override
  Widget build(BuildContext context) {
    if (earnings.isEmpty) return const SizedBox.shrink();

    final colors = context.colors;
    final max = earnings.max;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: _height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: KaziInsets.xs,
            children: [
              for (final bar in earnings.bars)
                Expanded(
                  child: _Column(
                    bar: bar,
                    max: max,
                    currency: earnings.currency,
                    maxHeight: _height,
                  ),
                ),
            ],
          ),
        ),
        KaziSpacings.verticalSm,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                children: [
                  Flexible(
                    child: _LegendEntry(
                      color: colors.inverse,
                      label: KaziLocalizations.current.received.toLowerCase(),
                    ),
                  ),
                  KaziSpacings.horizontalMd,
                  Flexible(
                    child: _LegendEntry(
                      color: colors.surfaceStrong,
                      label: KaziLocalizations.current.statusPending
                          .toLowerCase(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Text(
                KaziLocalizations.current.earningsPerWeek,
                textAlign: TextAlign.end,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: KaziTextStyles.labelSmall.copyWith(
                  color: colors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// One week, read out loud as week, amount and how much of it arrived — the
/// test the chart has to pass to be allowed to exist.
class _Column extends StatelessWidget {
  const _Column({
    required this.bar,
    required this.max,
    required this.currency,
    required this.maxHeight,
  });

  final WeeklyEarningsBar bar;
  final double max;
  final SupportedCurrency currency;
  final double maxHeight;

  String _label(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final format = DateFormat.MMMd(locale);
    final range = '${format.format(bar.start)} – ${format.format(bar.end)}';
    final total = NumberFormatUtils.formatCurrencyIn(bar.total, currency);
    final received = NumberFormatUtils.formatCurrencyIn(bar.received, currency);

    return '$range · $total · '
        '${KaziLocalizations.current.alreadyReceived(received)}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // An all-zero period would divide by zero, and every column would be as
    // meaningless as the next.
    final scale = max <= 0 ? 0.0 : maxHeight / max;

    return Semantics(
      label: _label(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (bar.pending > 0)
            _Segment(
              height: bar.pending * scale,
              color: colors.surfaceStrong,
              isTop: true,
            ),
          if (bar.received > 0)
            _Segment(
              height: bar.received * scale,
              color: colors.inverse,
              isTop: bar.pending == 0,
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.height,
    required this.color,
    required this.isTop,
  });

  /// Kept visible when a week earned something but almost nothing: a segment
  /// rounded down to nothing would report a week with no work.
  static const double _minimum = 2;

  final double height;
  final Color color;
  final bool isTop;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height < _minimum ? _minimum : height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: isTop
            ? const BorderRadius.vertical(top: Radius.circular(3))
            : null,
      ),
    );
  }
}

class _LegendEntry extends StatelessWidget {
  const _LegendEntry({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        KaziSpacings.horizontalXxs,
        Flexible(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: KaziTextStyles.labelSmall.copyWith(
                color: context.colors.textMuted,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
