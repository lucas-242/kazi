import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/services/domain/models/clock_time.dart';

void main() {
  group('ClockTime.fromMinutes', () {
    test('reads minutes into the day', () {
      expect(ClockTime.fromMinutes(0), const ClockTime(0, 0));
      expect(ClockTime.fromMinutes(870), const ClockTime(14, 30));
      expect(ClockTime.fromMinutes(1439), const ClockTime(23, 59));
    });

    test('reads a value outside the day, or not a number, as null', () {
      expect(ClockTime.fromMinutes(-1), isNull);
      expect(ClockTime.fromMinutes(1440), isNull);
      expect(ClockTime.fromMinutes('870'), isNull);
      expect(ClockTime.fromMinutes(null), isNull);
    });

    test('round-trips through inMinutes', () {
      const time = ClockTime(9, 5);

      expect(ClockTime.fromMinutes(time.inMinutes), time);
    });
  });

  test('on places the time on the given calendar date', () {
    expect(
      const ClockTime(8, 30).on(DateTime(2026, 10, 12, 23, 59)),
      DateTime(2026, 10, 12, 8, 30),
    );
  });

  test('orders by time of day', () {
    expect(const ClockTime(9, 0).compareTo(const ClockTime(8, 59)), 1);
    expect(const ClockTime(9, 0).compareTo(const ClockTime(9, 0)), 0);
  });
}
