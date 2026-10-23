import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/agenda/domain/models/agenda_entry.dart';
import 'package:kazi/features/services/domain/models/clock_time.dart';
import 'package:kazi/features/services/domain/models/service.dart';

void main() {
  final day = DateTime(2026, 10, 22);

  Service booking({
    ClockTime? start = const ClockTime(14, 0),
    Duration? duration = const Duration(minutes: 90),
    DateTime? finishedAt,
    DateTime? cancelledAt,
  }) => Service(
    userId: 'u',
    date: day,
    startTime: start,
    duration: duration,
    finishedAt: finishedAt,
    cancelledAt: cancelledAt,
  );

  test('a timed service spans its booking', () {
    final entry = AgendaEntry(booking());

    expect(entry.isAllDay, isFalse);
    expect(entry.start, DateTime(2026, 10, 22, 14));
    expect(entry.end, DateTime(2026, 10, 22, 15, 30));
    expect(entry.hasOpenEnd, isFalse);
  });

  test('an untimed service sits in its day, all day', () {
    final entry = AgendaEntry(booking(start: null, duration: null));

    expect(entry.isAllDay, isTrue);
    expect(entry.start, day);
    expect(entry.end, day);
    expect(entry.hasOpenEnd, isFalse);
  });

  test('a service with no duration has an open end, drawn at its start', () {
    final entry = AgendaEntry(booking(duration: null));

    expect(entry.end, entry.start);
    expect(entry.hasOpenEnd, isTrue);
  });

  test('finishing early frees the rest of the slot', () {
    final entry = AgendaEntry(booking(finishedAt: DateTime(2026, 10, 22, 15)));

    expect(entry.end, DateTime(2026, 10, 22, 15));
    expect(entry.hasOpenEnd, isFalse);
  });

  test('a finished service with no duration ends at its finish', () {
    final entry = AgendaEntry(
      booking(duration: null, finishedAt: DateTime(2026, 10, 22, 16)),
    );

    expect(entry.end, DateTime(2026, 10, 22, 16));
    expect(entry.hasOpenEnd, isFalse);
  });

  test('a cancelled service keeps the slot it was booked for', () {
    final entry = AgendaEntry(booking(cancelledAt: DateTime(2026, 10, 20)));

    expect(entry.start, DateTime(2026, 10, 22, 14));
    expect(entry.end, DateTime(2026, 10, 22, 15, 30));
    expect(entry.hasOpenEnd, isFalse);
  });

  group('fallsWithin', () {
    final overnight = AgendaEntry(
      booking(
        start: const ClockTime(22, 0),
        duration: const Duration(hours: 4),
      ),
    );

    test('a service runs into the day after it starts', () {
      expect(
        overnight.fallsWithin(DateTime(2026, 10, 23), DateTime(2026, 10, 23)),
        isTrue,
      );
    });

    test('but not into the day after that', () {
      expect(
        overnight.fallsWithin(DateTime(2026, 10, 24), DateTime(2026, 10, 30)),
        isFalse,
      );
    });

    test('one ending exactly at midnight stays out of the next day', () {
      final untilMidnight = AgendaEntry(
        booking(
          start: const ClockTime(22, 0),
          duration: const Duration(hours: 2),
        ),
      );

      expect(
        untilMidnight.fallsWithin(
          DateTime(2026, 10, 23),
          DateTime(2026, 10, 23),
        ),
        isFalse,
      );
    });

    test('an untimed service falls on its own day only', () {
      final untimed = AgendaEntry(booking(start: null, duration: null));

      expect(untimed.fallsWithin(day, day), isTrue);
      expect(
        untimed.fallsWithin(DateTime(2026, 10, 23), DateTime(2026, 10, 23)),
        isFalse,
      );
      expect(
        untimed.fallsWithin(DateTime(2026, 10, 21), DateTime(2026, 10, 21)),
        isFalse,
      );
    });
  });
}
