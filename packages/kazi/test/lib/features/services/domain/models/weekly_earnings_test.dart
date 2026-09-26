import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/domain/models/weekly_earnings.dart';
import 'package:kazi_core/kazi_core.dart' hide Service;

/// The chart is only allowed to exist if it can be read out loud, which means
/// the buckets have to be defensible: a week that got the wrong service tells
/// a story that did not happen.
void main() {
  Service service({
    required DateTime date,
    double value = 100,
    double commissionPercent = 40,
    String currency = 'USD',
    bool isReceived = false,
  }) => Service(
    id: 'service-${date.day}-${value.toInt()}-$isReceived',
    value: value,
    commissionPercent: commissionPercent,
    currency: currency,
    rateDate: '2026-08-20',
    date: date,
    receivedAt: isReceived ? DateTime(2026, 9, 5) : null,
    userId: 'user-1',
  );

  WeeklyEarnings earningsOf(
    List<Service> services, {
    DateTime? start,
    DateTime? end,
    RateBook rateBook = const RateBook.empty(),
  }) => WeeklyEarnings.from(
    services,
    start: start ?? DateTime(2026, 8),
    end: end ?? DateTime(2026, 8, 28),
    currency: SupportedCurrency.usd,
    rateBook: rateBook,
  );

  group('the buckets', () {
    // Seven days from the period's own start, not from Monday: the period is
    // what the chips picked, and a cycle rarely opens on a Monday.
    test('Should run in weeks from the start of the period', () {
      final bars = earningsOf(const []).bars;

      expect(bars, hasLength(4));
      expect(bars.first.start, DateTime(2026, 8));
      expect(bars.first.end, DateTime(2026, 8, 7));
      expect(bars[1].start, DateTime(2026, 8, 8));
    });

    test('Should clip the last week to the end of the period', () {
      final bars = earningsOf(const [], end: DateTime(2026, 8, 10)).bars;

      expect(bars, hasLength(2));
      expect(bars.last.end, DateTime(2026, 8, 10));
    });

    test('Should give a period shorter than a week a single bar', () {
      final bars = earningsOf(
        const [],
        start: DateTime(2026, 8, 3),
        end: DateTime(2026, 8, 5),
      ).bars;

      expect(bars, hasLength(1));
    });

    // The empty week is the one that tells the story: the last bars of a cycle
    // are all pending because the payment arrives in a block, at closing.
    test('Should keep a week with no service as a bar of zero', () {
      final earnings = earningsOf([service(date: DateTime(2026, 8, 2))]);

      expect(earnings.bars, hasLength(4));
      expect(earnings.bars.last.total, 0);
    });
  });

  group('the split', () {
    test('Should put each service in the week it happened', () {
      final earnings = earningsOf([
        service(date: DateTime(2026, 8, 2)),
        service(date: DateTime(2026, 8, 9), value: 200),
      ]);

      expect(earnings.bars.first.total, 40);
      expect(earnings.bars[1].total, 80);
    });

    test('Should split a week by whether the money arrived', () {
      final earnings = earningsOf([
        service(date: DateTime(2026, 8, 2), isReceived: true),
        service(date: DateTime(2026, 8, 4), value: 50),
      ]);
      final week = earnings.bars.first;

      expect(week.received, 40);
      expect(week.pending, 20);
      expect(week.total, 60);
    });

    test('Should sum the user share, never the gross', () {
      final earnings = earningsOf([
        service(date: DateTime(2026, 8, 2), commissionPercent: 25),
      ]);

      expect(earnings.bars.first.total, 25);
    });

    test('Should measure every bar against the tallest', () {
      final earnings = earningsOf([
        service(date: DateTime(2026, 8, 2)),
        service(date: DateTime(2026, 8, 9), value: 200),
      ]);

      expect(earnings.max, 80);
    });
  });

  group('the edges', () {
    // Same rule as every other total: 100 BRL must never enter a USD bar as
    // 100.
    test('Should leave out a service it cannot convert', () {
      final earnings = earningsOf([
        service(date: DateTime(2026, 8, 2), currency: 'BRL'),
        service(date: DateTime(2026, 8, 2)),
      ]);

      expect(earnings.unconverted, 1);
      expect(earnings.bars.first.total, 40);
    });

    test('Should drop a service outside the window it was fetched for', () {
      final earnings = earningsOf([service(date: DateTime(2026, 7, 2))]);

      expect(earnings.isEmpty, isTrue);
    });

    test('Should report an all-zero period as empty', () {
      expect(earningsOf(const []).isEmpty, isTrue);
      expect(earningsOf(const []).max, 0);
    });

    test('Should have no bars when the period is inverted', () {
      final earnings = earningsOf(
        const [],
        start: DateTime(2026, 8, 20),
        end: DateTime(2026, 8),
      );

      expect(earnings.bars, isEmpty);
    });
  });
}
