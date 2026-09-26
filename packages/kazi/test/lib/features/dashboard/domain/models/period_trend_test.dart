import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/dashboard/domain/models/period_trend.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi_core/kazi_core.dart' hide Service;

void main() {
  PeriodTrend trendOver(DateTime start, DateTime end) => periodTotals(
    const <Service>[],
    start: start,
    end: end,
    currency: SupportedCurrency.brl,
    rateBook: const RateBook.empty(),
  );

  group('indexOn', () {
    test('Should point at the day bucket holding the date', () {
      final trend = trendOver(DateTime(2026, 9, 2), DateTime(2026, 9, 30));

      expect(trend.granularity, BucketGranularity.day);
      expect(trend.indexOn(DateTime(2026, 9, 2)), 0);
      expect(trend.indexOn(DateTime(2026, 9, 25, 23, 59)), 23);
      expect(trend.indexOn(DateTime(2026, 9, 30)), 28);
    });

    test('Should point at the week bucket holding the date', () {
      final trend = trendOver(DateTime(2026, 1, 2), DateTime(2026, 12, 31));

      expect(trend.granularity, BucketGranularity.week);
      expect(trend.indexOn(DateTime(2026, 1, 8)), 0);
      expect(trend.indexOn(DateTime(2026, 1, 9)), 1);
    });

    test('Should be null when the period does not reach the date', () {
      final trend = trendOver(DateTime(2026, 8, 2), DateTime(2026, 8, 31));

      expect(trend.indexOn(DateTime(2026, 9, 25)), isNull);
      expect(trend.indexOn(DateTime(2026, 7, 31)), isNull);
    });

    test('Should be null for a period too short to have buckets', () {
      final trend = trendOver(DateTime(2026, 9, 25), DateTime(2026, 9, 26));

      expect(trend.buckets, isEmpty);
      expect(trend.indexOn(DateTime(2026, 9, 25)), isNull);
    });
  });
}
