import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

enum BucketGranularity { day, week, month }

/// One bucket's own commission, split by whether it landed yet, and the
/// stretch of the period it covers.
typedef BucketTotal = ({
  double received,
  double pending,
  DateTime start,
  DateTime end,
});

/// A period's shape: which [BucketGranularity] applies and each bucket's own
/// totals.
typedef PeriodTrend = ({
  BucketGranularity granularity,
  List<BucketTotal> buckets,
});

/// A period too short to have a shape, and what a caller with no period at
/// all renders.
const PeriodTrend emptyPeriodTrend = (
  granularity: BucketGranularity.day,
  buckets: <BucketTotal>[],
);

extension PeriodTrendSelection on PeriodTrend {
  /// The index of the bucket covering [date], or null when the period does not
  /// reach it — a cycle that closed before today has no bucket for it.
  int? indexOn(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    for (var i = 0; i < buckets.length; i++) {
      final bucket = buckets[i];
      if (!day.isBefore(bucket.start) && !day.isAfter(bucket.end)) return i;
    }
    return null;
  }
}

/// Buckets [services] into the stretches of [start]..[end], each carrying its
/// own commission split by whether it has landed.
///
/// A shape, not a ledger: unlike [ServiceTotals], a service whose rate cannot
/// be resolved is dropped from its bucket silently rather than counted as
/// unconverted. The bucket widens with the period — a day up to two months, a
/// week up to a year, a month beyond that. See README.md.
PeriodTrend periodTotals(
  Iterable<Service> services, {
  required DateTime start,
  required DateTime end,
  required SupportedCurrency currency,
  required RateBook rateBook,
}) {
  final first = DateTime(start.year, start.month, start.day);
  final last = DateTime(end.year, end.month, end.day);
  final totalDays = last.difference(first).inDays;
  if (totalDays < 2) return emptyPeriodTrend;

  final granularity = totalDays <= 60
      ? BucketGranularity.day
      : totalDays <= 365
      ? BucketGranularity.week
      : BucketGranularity.month;

  final bucketCount = switch (granularity) {
    BucketGranularity.day => totalDays + 1,
    BucketGranularity.week => (totalDays ~/ 7) + 1,
    BucketGranularity.month =>
      (last.year - first.year) * 12 + (last.month - first.month) + 1,
  };

  DateTime bucketStart(int i) => switch (granularity) {
    BucketGranularity.day => DateTime(first.year, first.month, first.day + i),
    BucketGranularity.week => DateTime(
      first.year,
      first.month,
      first.day + i * 7,
    ),
    BucketGranularity.month => DateTime(first.year, first.month + i),
  };

  // Clamped to the period's own end: a trailing partial week or month must
  // not claim days the period never covered.
  DateTime bucketEnd(int i) {
    final natural = switch (granularity) {
      BucketGranularity.day => bucketStart(i),
      BucketGranularity.week => DateTime(
        first.year,
        first.month,
        first.day + i * 7 + 6,
      ),
      BucketGranularity.month => DateTime(first.year, first.month + i + 1, 0),
    };
    return natural.isAfter(last) ? last : natural;
  }

  final received = List<double>.filled(bucketCount, 0);
  final pending = List<double>.filled(bucketCount, 0);
  for (final service in services.excludingCancelled) {
    final converted = service.convert(
      service.commissionValue,
      to: currency,
      fallback: currency,
      rateBook: rateBook,
    );
    if (converted == null) continue;

    final day = DateTime(
      service.date.year,
      service.date.month,
      service.date.day,
    );
    final index = switch (granularity) {
      BucketGranularity.day => day.difference(first).inDays,
      BucketGranularity.week => day.difference(first).inDays ~/ 7,
      BucketGranularity.month =>
        (day.year - first.year) * 12 + (day.month - first.month),
    };
    if (index < 0 || index >= bucketCount) continue;
    if (service.isReceived) {
      received[index] += converted;
    } else {
      pending[index] += converted;
    }
  }

  return (
    granularity: granularity,
    buckets: [
      for (var i = 0; i < bucketCount; i++)
        (
          received: received[i],
          pending: pending[i],
          start: bucketStart(i),
          end: bucketEnd(i),
        ),
    ],
  );
}
