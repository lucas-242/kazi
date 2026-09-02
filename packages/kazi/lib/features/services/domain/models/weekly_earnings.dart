import 'package:equatable/equatable.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// One column of the summary's chart: a week of the filtered period, split by
/// whether the money has arrived.
class WeeklyEarningsBar extends Equatable {
  const WeeklyEarningsBar({
    required this.start,
    required this.end,
    this.received = 0,
    this.pending = 0,
  });

  /// The week's first and last day, inclusive — what the column is read out as.
  final DateTime start;
  final DateTime end;

  /// The user's own cut, split by situation. Their sum is the column's height.
  final double received;
  final double pending;

  double get total => received + pending;

  @override
  List<Object?> get props => [start, end, received, pending];
}

/// The user's earnings across a period, one bar per week.
///
/// Follows the same discipline as `ServiceTotals`: every amount is converted
/// **before** it is summed, and a service whose rate cannot be resolved is
/// counted in [unconverted] and left out rather than added at face value.
class WeeklyEarnings extends Equatable {
  const WeeklyEarnings({
    required this.currency,
    this.bars = const [],
    this.unconverted = 0,
  });

  /// Buckets [services] into calendar weeks covering [start]..[end].
  ///
  /// The weeks come from the period, not from the services: an empty week is a
  /// column of zero height, and it is the one that tells the story — the last
  /// bars of a cycle are all pending because the payment arrives in a block, at
  /// closing.
  factory WeeklyEarnings.from(
    Iterable<Service> services, {
    required DateTime start,
    required DateTime end,
    required SupportedCurrency currency,
    required RateBook rateBook,
  }) {
    final buckets = _weeksBetween(start, end);
    if (buckets.isEmpty) return WeeklyEarnings(currency: currency);

    final received = List<double>.filled(buckets.length, 0);
    final pending = List<double>.filled(buckets.length, 0);
    var unconverted = 0;

    for (final service in services) {
      final converted = service.convert(
        service.commissionValue,
        to: currency,
        fallback: currency,
        rateBook: rateBook,
      );
      if (converted == null) {
        unconverted++;
        continue;
      }

      final index = _bucketOf(buckets, service.date);
      if (index == null) continue;

      if (service.isReceived) {
        received[index] += converted;
      } else {
        pending[index] += converted;
      }
    }

    return WeeklyEarnings(
      currency: currency,
      unconverted: unconverted,
      bars: [
        for (var index = 0; index < buckets.length; index++)
          WeeklyEarningsBar(
            start: buckets[index].start,
            end: buckets[index].end,
            received: received[index],
            pending: pending[index],
          ),
      ],
    );
  }

  final SupportedCurrency currency;
  final List<WeeklyEarningsBar> bars;

  /// Services left out for want of an exchange rate.
  final int unconverted;

  bool get isEmpty => bars.isEmpty || bars.every((bar) => bar.total == 0);

  /// The tallest column, which every other one is drawn against.
  double get max =>
      bars.fold(0, (tallest, bar) => bar.total > tallest ? bar.total : tallest);

  static List<({DateTime start, DateTime end})> _weeksBetween(
    DateTime start,
    DateTime end,
  ) {
    final first = DateTime(start.year, start.month, start.day);
    final last = DateTime(end.year, end.month, end.day);
    if (last.isBefore(first)) return const [];

    final weeks = <({DateTime start, DateTime end})>[];
    var cursor = first;

    while (!cursor.isAfter(last)) {
      // Seven calendar days from the period's own start, not from Monday: the
      // period is what the chips picked, and a cycle rarely opens on a Monday.
      final weekEnd = DateTime(cursor.year, cursor.month, cursor.day + 6);
      weeks.add((start: cursor, end: weekEnd.isAfter(last) ? last : weekEnd));
      cursor = DateTime(cursor.year, cursor.month, cursor.day + 7);
    }

    return weeks;
  }

  static int? _bucketOf(
    List<({DateTime start, DateTime end})> buckets,
    DateTime date,
  ) {
    final day = DateTime(date.year, date.month, date.day);

    for (var index = 0; index < buckets.length; index++) {
      final bucket = buckets[index];
      if (!day.isBefore(bucket.start) && !day.isAfter(bucket.end)) {
        return index;
      }
    }

    // A service outside the window it was fetched for. Dropped rather than
    // forced into an edge bucket, which would misreport a week.
    return null;
  }

  @override
  List<Object?> get props => [currency, bars, unconverted];
}
