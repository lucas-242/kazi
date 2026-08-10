import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/services/data/local_time_service.dart';
import 'package:kazi/core/utils/date_range.dart';
import 'package:kazi/features/services/data/services/local_services_service.dart';
import 'package:kazi/features/settings/domain/models/billing_cycle.dart';
import 'package:kazi_core/kazi_core.dart' hide Service;

/// The arithmetic under test is daylight-saving sensitive. It is written with
/// the `DateTime(y, m, d)` constructor precisely so the results are the same in
/// every zone, which is what makes these tests portable. To check that claim by
/// hand, run them somewhere that springs forward at midnight:
///
/// ```
/// TZ=America/Santiago flutter test test/lib/features/settings/domain/models/billing_cycle_test.dart
/// ```
void main() {
  DateTime dayAfter(DateTime date) =>
      DateTime(date.year, date.month, date.day + 1);

  group('Tiling', () {
    /// Every day belongs to exactly one window, and consecutive windows meet
    /// without a gap or an overlap. Walking three years of anchors this way
    /// catches every clamping and midpoint mistake at once — which is why the
    /// per-type tests below only need to pin down the interesting dates.
    void expectTiles(BillingCycle cycle) {
      var day = DateTime(2024);
      var current = cycle.currentCycle(day);

      while (day.isBefore(DateTime(2027))) {
        expect(
          current.contains(day),
          isTrue,
          reason: '$cycle: $day fell outside $current',
        );
        expect(
          current.end.isAfter(current.start),
          isTrue,
          reason: '$cycle: $current ends before it starts',
        );

        final next = dayAfter(day);
        final nextCycle = cycle.currentCycle(next);

        if (nextCycle != current) {
          expect(
            nextCycle.start,
            dayAfter(current.end),
            reason: '$cycle: gap or overlap between $current and $nextCycle',
          );
        }

        day = next;
        current = nextCycle;
      }
    }

    test('Should tile the calendar for every monthly anchor', () {
      for (var anchor = 1; anchor <= 31; anchor++) {
        expectTiles(MonthlyCycle(anchorDay: anchor));
      }
    });

    test('Should tile the calendar for every fortnightly anchor', () {
      for (var anchor = 1; anchor <= 31; anchor++) {
        expectTiles(FortnightlyCycle(anchorDay: anchor));
      }
    });

    test('Should tile the calendar for every weekly anchor', () {
      for (
        var weekday = DateTime.monday;
        weekday <= DateTime.sunday;
        weekday++
      ) {
        expectTiles(WeeklyCycle(anchorWeekday: weekday));
      }
    });
  });

  group('MonthlyCycle', () {
    test(
      'Should end on the payday and start the day after the previous one',
      () {
        const cycle = MonthlyCycle(anchorDay: 5);

        expect(
          cycle.currentCycle(DateTime(2026, 8, 20)),
          DateRange(
            start: DateTime(2026, 8, 6),
            end: DateTime(2026, 9, 5, 23, 59, 59),
          ),
        );
      },
    );

    test('Should still close today when today is the payday', () {
      const cycle = MonthlyCycle(anchorDay: 5);

      expect(cycle.closesOn(DateTime(2026, 8, 5)), DateTime(2026, 8, 5));
      expect(cycle.daysUntilClose(DateTime(2026, 8, 5)), 0);
      expect(
        cycle.currentCycle(DateTime(2026, 8, 5)),
        DateRange(
          start: DateTime(2026, 7, 6),
          end: DateTime(2026, 8, 5, 23, 59, 59),
        ),
      );
    });

    test('Should count the days left until the payday', () {
      const cycle = MonthlyCycle(anchorDay: 5);

      expect(cycle.daysUntilClose(DateTime(2026, 8, 14)), 22);
    });

    test('Should clamp an anchor past the end of a short month', () {
      const cycle = MonthlyCycle(anchorDay: 31);

      expect(cycle.closesOn(DateTime(2026, 2, 10)), DateTime(2026, 2, 28));
      expect(cycle.closesOn(DateTime(2026, 4, 10)), DateTime(2026, 4, 30));
    });

    test('Should follow February across a leap year', () {
      const cycle = MonthlyCycle(anchorDay: 29);

      expect(cycle.closesOn(DateTime(2024, 2, 10)), DateTime(2024, 2, 29));
      expect(cycle.closesOn(DateTime(2025, 2, 10)), DateTime(2025, 2, 28));
    });

    test('Should roll into the next year in December', () {
      const cycle = MonthlyCycle(anchorDay: 5);

      expect(
        cycle.currentCycle(DateTime(2026, 12, 20)),
        DateRange(
          start: DateTime(2026, 12, 6),
          end: DateTime(2027, 1, 5, 23, 59, 59),
        ),
      );
    });
  });

  group('FortnightlyCycle', () {
    test('Should split the month at the midpoint between paydays', () {
      const cycle = FortnightlyCycle(anchorDay: 5);

      expect(
        cycle.currentCycle(DateTime(2026, 8, 12)),
        DateRange(
          start: DateTime(2026, 8, 6),
          end: DateTime(2026, 8, 20, 23, 59, 59),
        ),
      );
      expect(
        cycle.currentCycle(DateTime(2026, 8, 25)),
        DateRange(
          start: DateTime(2026, 8, 21),
          end: DateTime(2026, 9, 5, 23, 59, 59),
        ),
      );
    });

    test('Should pull the midpoint back in a short month', () {
      const cycle = FortnightlyCycle(anchorDay: 5);

      expect(cycle.closesOn(DateTime(2026, 2, 10)), DateTime(2026, 2, 19));
    });

    test('Should close on the midpoint when today is the midpoint', () {
      const cycle = FortnightlyCycle(anchorDay: 5);

      expect(cycle.daysUntilClose(DateTime(2026, 8, 20)), 0);
    });
  });

  group('WeeklyCycle', () {
    test('Should close on the next occurrence of the anchor weekday', () {
      const cycle = WeeklyCycle(anchorWeekday: DateTime.friday);

      // 2026-08-12 is a Wednesday.
      expect(cycle.closesOn(DateTime(2026, 8, 12)), DateTime(2026, 8, 14));
      expect(
        cycle.currentCycle(DateTime(2026, 8, 12)),
        DateRange(
          start: DateTime(2026, 8, 8),
          end: DateTime(2026, 8, 14, 23, 59, 59),
        ),
      );
    });

    test('Should close today when today is the anchor weekday', () {
      const cycle = WeeklyCycle(anchorWeekday: DateTime.friday);

      expect(cycle.daysUntilClose(DateTime(2026, 8, 14)), 0);
    });
  });

  group('The default cycle', () {
    /// The proof that nobody's home changes. `FastSearch.month` is what the
    /// dashboard used before cycles existed; delete this test the day
    /// `getRangeDateByFastSearch` goes away.
    test('Should match FastSearch.month on every day of the year', () {
      for (
        var day = DateTime(2026);
        day.isBefore(DateTime(2027));
        day = dayAfter(day)
      ) {
        final legacy = LocalServicesService(
          LocalTimeService(day),
        ).getRangeDateByFastSearch(FastSearch.month);

        expect(
          BillingCycle.monthlyDefault.currentCycle(day),
          DateRange(start: legacy['startDate']!, end: legacy['endDate']!),
          reason: 'diverged on $day',
        );
      }
    });
  });

  group('fromMap', () {
    test('Should restore each cycle type', () {
      expect(
        BillingCycle.fromMap(const MonthlyCycle(anchorDay: 5).toMap()),
        const MonthlyCycle(anchorDay: 5),
      );
      expect(
        BillingCycle.fromMap(const FortnightlyCycle(anchorDay: 5).toMap()),
        const FortnightlyCycle(anchorDay: 5),
      );
      expect(
        BillingCycle.fromMap(const WeeklyCycle(anchorWeekday: 3).toMap()),
        const WeeklyCycle(anchorWeekday: 3),
      );
    });

    test('Should fall back to the default for a user with no cycle set', () {
      expect(BillingCycle.fromMap(const {}), BillingCycle.monthlyDefault);
    });

    test('Should fall back to the default for an unknown type', () {
      expect(
        BillingCycle.fromMap(const {
          BillingCycle.typeField: 'quarterly',
          BillingCycle.anchorField: 99,
        }),
        BillingCycle.monthlyDefault,
      );
    });

    test('Should survive an anchor of the wrong type', () {
      expect(
        BillingCycle.fromMap(const {
          BillingCycle.typeField: 'monthly',
          BillingCycle.anchorField: 'fifth',
        }),
        BillingCycle.monthlyDefault,
      );
    });

    test(
      'Should treat an out-of-range anchor as the last day of the month',
      () {
        final cycle = BillingCycle.fromMap(const {
          BillingCycle.typeField: 'monthly',
          BillingCycle.anchorField: 99,
        });

        expect(cycle.closesOn(DateTime(2026, 2, 10)), DateTime(2026, 2, 28));
      },
    );
  });
}
