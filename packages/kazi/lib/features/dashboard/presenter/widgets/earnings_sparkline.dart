import 'package:flutter/material.dart';
import 'package:kazi/features/dashboard/domain/models/period_trend.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// The period's shape in one glance: one bar per bucket, height proportional
/// to that bucket's own commission, split into received/pending once
/// [expanded]. Touching a bar names it in the caption above the row.
///
/// A controlled component: [selectedIndex] and [onSelect] live in the card,
/// so a tap on the rest of the card can clear the selection. See README.md.
class EarningsSparkline extends StatelessWidget {
  const EarningsSparkline({
    super.key,
    required this.trend,
    required this.expanded,
    required this.currency,
    required this.textColor,
    required this.receivedColor,
    required this.pendingColor,
    required this.selectedIndex,
    required this.onSelect,
  });

  static const double _height = 32;

  final PeriodTrend trend;
  final bool expanded;
  final SupportedCurrency currency;
  final Color textColor;
  final Color receivedColor;
  final Color pendingColor;
  final int? selectedIndex;
  final ValueChanged<int?> onSelect;

  int _bucketAt(double dx, double width) {
    final slotWidth = width / trend.buckets.length;
    return (dx / slotWidth).floor().clamp(0, trend.buckets.length - 1);
  }

  /// [bucket]'s stretch in the user's words: a day names itself, a week or a
  /// month names its span.
  String _dateLabel(BucketTotal bucket) {
    String short(DateTime date) =>
        '${date.day} ${date.monthName().substring(0, 3)}';

    return switch (trend.granularity) {
      BucketGranularity.day => short(bucket.start),
      BucketGranularity.week =>
        bucket.start.month == bucket.end.month
            ? '${bucket.start.day}-${bucket.end.day} '
                  '${bucket.end.monthName().substring(0, 3)}'
            : '${short(bucket.start)} - ${short(bucket.end)}',
      BucketGranularity.month =>
        '${bucket.start.monthName()} ${bucket.start.year}',
    };
  }

  String _caption(BucketTotal bucket) {
    final label = _dateLabel(bucket);
    final total = bucket.received + bucket.pending;
    if (!expanded || total <= 0) {
      return '$label · ${NumberFormatUtils.formatCurrencyIn(total, currency)}';
    }

    final l10n = KaziLocalizations.current;
    return '$label · ${l10n.statReceived} '
        '${NumberFormatUtils.formatCurrencyIn(bucket.received, currency)}'
        ' · ${l10n.statPending} '
        '${NumberFormatUtils.formatCurrencyIn(bucket.pending, currency)}';
  }

  @override
  Widget build(BuildContext context) {
    final buckets = trend.buckets;
    final selected = selectedIndex != null && selectedIndex! < buckets.length
        ? buckets[selectedIndex!]
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          alignment: Alignment.topLeft,
          child: selected == null
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(bottom: KaziInsets.xxs),
                  child: Text(
                    _caption(selected),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: KaziTextStyles.labelSmall.copyWith(color: textColor),
                  ),
                ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            void selectAt(Offset local) =>
                onSelect(_bucketAt(local.dx, constraints.maxWidth));

            return Semantics(
              label: selected == null
                  ? KaziLocalizations.current.earningsChartHint
                  : _caption(selected),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) => selectAt(details.localPosition),
                onHorizontalDragStart: (details) =>
                    selectAt(details.localPosition),
                onHorizontalDragUpdate: (details) =>
                    selectAt(details.localPosition),
                child: SizedBox(
                  width: double.infinity,
                  height: _height,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: SizedBox.expand(
                      key: ValueKey(expanded),
                      child: CustomPaint(
                        painter: _SparklinePainter(
                          buckets: buckets,
                          expanded: expanded,
                          selectedIndex: selectedIndex,
                          receivedColor: receivedColor,
                          pendingColor: pendingColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.buckets,
    required this.expanded,
    required this.selectedIndex,
    required this.receivedColor,
    required this.pendingColor,
  });

  final List<BucketTotal> buckets;
  final bool expanded;
  final int? selectedIndex;
  final Color receivedColor;
  final Color pendingColor;

  /// The slice of each bucket's own width the bar fills — the rest is the gap
  /// that lets each one read as a separate mark.
  static const _barWidthFraction = 0.55;

  /// Kept visible even at zero: a quiet day should still mark its place.
  static const _minHeightFraction = 0.06;

  @override
  void paint(Canvas canvas, Size size) {
    final totals = [
      for (final bucket in buckets) bucket.received + bucket.pending,
    ];
    final maxValue = totals.reduce((a, b) => a > b ? a : b);
    final range = maxValue <= 0 ? 1.0 : maxValue;
    final slotWidth = size.width / buckets.length;
    final barWidth = slotWidth * _barWidthFraction;
    final minHeight = size.height * _minHeightFraction;

    final paint = Paint();
    for (var i = 0; i < buckets.length; i++) {
      final total = totals[i];
      final barHeight = (total / range * size.height).clamp(
        minHeight,
        size.height,
      );
      final left = slotWidth * i + (slotWidth - barWidth) / 2;
      final top = size.height - barHeight;
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(left, top, barWidth, barHeight),
        topLeft: const Radius.circular(2),
        topRight: const Radius.circular(2),
      );

      if (!expanded || total <= 0) {
        canvas.drawRRect(
          rect,
          paint
            ..color = total <= 0
                ? receivedColor.withValues(alpha: 0.18)
                : receivedColor,
        );
      } else {
        canvas.save();
        canvas.clipRRect(rect);
        final pendingHeight = barHeight * (buckets[i].pending / total);
        canvas
          ..drawRect(
            Rect.fromLTWH(left, top, barWidth, barHeight - pendingHeight),
            paint..color = receivedColor,
          )
          ..drawRect(
            Rect.fromLTWH(left, top, barWidth, pendingHeight),
            paint..color = pendingColor,
          );
        canvas.restore();
      }

      if (i == selectedIndex) {
        canvas.drawCircle(
          Offset(left + barWidth / 2, top - 4),
          2,
          paint..color = receivedColor,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      !identical(oldDelegate.buckets, buckets) ||
      oldDelegate.expanded != expanded ||
      oldDelegate.selectedIndex != selectedIndex ||
      oldDelegate.receivedColor != receivedColor ||
      oldDelegate.pendingColor != pendingColor;
}
