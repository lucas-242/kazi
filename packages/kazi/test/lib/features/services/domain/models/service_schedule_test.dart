import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/services/domain/models/clock_time.dart';
import 'package:kazi/features/services/domain/models/schedule_state.dart';
import 'package:kazi/features/services/domain/models/service.dart';

void main() {
  Service service({
    ClockTime? startTime,
    Duration? duration,
    DateTime? receivedAt,
    DateTime? cancelledAt,
    DateTime? finishedAt,
    DateTime? date,
  }) => Service(
    value: 100,
    date: date ?? DateTime(2026, 9, 28),
    startTime: startTime,
    duration: duration,
    receivedAt: receivedAt,
    cancelledAt: cancelledAt,
    finishedAt: finishedAt,
    userId: 'user-1',
  );

  /// 14:00–15:30 on 28/09.
  Service booked({DateTime? finishedAt, DateTime? cancelledAt}) => service(
    startTime: const ClockTime(14, 0),
    duration: const Duration(minutes: 90),
    finishedAt: finishedAt,
    cancelledAt: cancelledAt,
  );

  group('withDuration', () {
    test('clears the duration, which copyWith cannot', () {
      final received = service(
        duration: const Duration(hours: 1),
        receivedAt: DateTime(2026, 9, 29),
      );

      final cleared = received.withDuration(null);

      expect(cleared.duration, isNull);
      expect(cleared.receivedAt, DateTime(2026, 9, 29));
    });
  });

  group('startsAt / endsAt', () {
    test('places the start time on the service date', () {
      final booked = service(startTime: const ClockTime(14, 30));

      expect(booked.startsAt, DateTime(2026, 9, 28, 14, 30));
    });

    test('moving the date carries the booking along', () {
      final booked = service(startTime: const ClockTime(14, 30));

      final moved = booked.copyWith(date: DateTime(2026, 10, 2));

      expect(moved.startsAt, DateTime(2026, 10, 2, 14, 30));
    });

    test('ends the duration after the start', () {
      final booked = service(
        startTime: const ClockTime(23, 30),
        duration: const Duration(minutes: 90),
      );

      expect(booked.endsAt, DateTime(2026, 9, 29, 1));
    });

    test('has no start or end without a start time', () {
      final unbooked = service(duration: const Duration(hours: 1));

      expect(unbooked.startsAt, isNull);
      expect(unbooked.endsAt, isNull);
    });

    test('a duration of days ends that many days later', () {
      final booked = service(
        startTime: const ClockTime(9, 0),
        duration: const Duration(days: 2, hours: 1),
      );

      expect(booked.endsAt, DateTime(2026, 9, 30, 10));
    });

    test('has no end without a duration', () {
      final booked = service(startTime: const ClockTime(9, 0));

      expect(booked.endsAt, isNull);
    });
  });

  group('isMultiDay', () {
    test('is set when the booking ends on a later day', () {
      expect(
        service(
          startTime: const ClockTime(23, 30),
          duration: const Duration(minutes: 90),
        ).isMultiDay,
        isTrue,
      );
    });

    test('is not set when the booking ends at midnight of the same day', () {
      expect(
        service(
          startTime: const ClockTime(22, 0),
          duration: const Duration(hours: 1, minutes: 59),
        ).isMultiDay,
        isFalse,
      );
    });

    test('is not set without a planned end', () {
      expect(service(duration: const Duration(days: 2)).isMultiDay, isFalse);
      expect(service(startTime: const ClockTime(9, 0)).isMultiDay, isFalse);
    });
  });

  group('withStartTime', () {
    test('books and unbooks, which copyWith cannot', () {
      final booked = service(
        duration: const Duration(hours: 1),
      ).withStartTime(const ClockTime(10, 15));

      expect(booked.startsAt, DateTime(2026, 9, 28, 10, 15));

      final unbooked = booked.withStartTime(null);

      expect(unbooked.startTime, isNull);
      expect(unbooked.duration, const Duration(hours: 1));
    });
  });

  group('withEndsAt', () {
    test('derives the duration, keeping the start', () {
      final ended = booked().withEndsAt(DateTime(2026, 9, 28, 17));

      expect(ended.startsAt, DateTime(2026, 9, 28, 14));
      expect(ended.duration, const Duration(hours: 3));
      expect(ended.endsAt, DateTime(2026, 9, 28, 17));
    });

    test('an end on a later day becomes a multi-day duration', () {
      final ended = booked().withEndsAt(DateTime(2026, 9, 30, 9));

      expect(ended.duration, const Duration(days: 1, hours: 19));
      expect(ended.isMultiDay, isTrue);
    });

    test('ignores an end not after the start', () {
      final source = booked();

      expect(source.withEndsAt(DateTime(2026, 9, 28, 14)), same(source));
      expect(source.withEndsAt(DateTime(2026, 9, 28, 13)), same(source));
    });

    test('ignores an end on an untimed service', () {
      final untimed = service(duration: const Duration(hours: 1));

      expect(untimed.withEndsAt(DateTime(2026, 9, 28, 17)), same(untimed));
    });
  });

  group('editing the start', () {
    test('keeps the duration and moves the end', () {
      final moved = booked().withStartTime(const ClockTime(15, 0));

      expect(moved.duration, const Duration(minutes: 90));
      expect(moved.endsAt, DateTime(2026, 9, 28, 16, 30));
    });
  });

  group('withoutClient', () {
    test('clears the client and its name, and nothing else', () {
      final linked = service(
        startTime: const ClockTime(9, 0),
      ).copyWith(clientId: 'client-1', clientName: 'Ana');

      final unlinked = linked.withoutClient();

      expect(unlinked.clientId, isNull);
      expect(unlinked.clientName, isNull);
      expect(unlinked.startTime, linked.startTime);
    });
  });

  group('markedFinished', () {
    final markedAt = DateTime(2026, 9, 28, 18, 5);

    test(
      'stamps the end the booking planned, not the moment it was marked',
      () {
        final booked = service(
          startTime: const ClockTime(14, 0),
          duration: const Duration(minutes: 45),
        );

        final finished = booked.markedFinished(at: markedAt);

        expect(finished.finishedAt, DateTime(2026, 9, 28, 14, 45));
        expect(finished.isFinished, isTrue);
      },
    );

    test('stamps the moment it was marked when that is before the end', () {
      final early = DateTime(2026, 9, 28, 14, 20);
      final booked = service(
        startTime: const ClockTime(14, 0),
        duration: const Duration(minutes: 45),
      );

      expect(booked.markedFinished(at: early).finishedAt, early);
    });

    test('never stamps the future when marking a booking still ahead', () {
      final dayBefore = DateTime(2026, 9, 27, 10);
      final booked = service(
        startTime: const ClockTime(14, 0),
        duration: const Duration(minutes: 45),
      );

      expect(booked.markedFinished(at: dayBefore).finishedAt, dayBefore);
    });

    test('falls back to the moment it was marked without a planned end', () {
      expect(service().markedFinished(at: markedAt).finishedAt, markedAt);
      expect(
        service(
          startTime: const ClockTime(14, 0),
        ).markedFinished(at: markedAt).finishedAt,
        markedAt,
      );
    });

    test('leaves the payment and cancellation stamps alone', () {
      final source = service(
        receivedAt: DateTime(2026, 9, 20),
        cancelledAt: DateTime(2026, 9, 21),
      );

      final finished = source.markedFinished(at: markedAt);

      expect(finished.receivedAt, DateTime(2026, 9, 20));
      expect(finished.cancelledAt, DateTime(2026, 9, 21));
    });

    test('markedFinishedAt stamps exactly the moment given', () {
      final booked = service(
        startTime: const ClockTime(14, 0),
        duration: const Duration(minutes: 45),
      );

      expect(
        booked.markedFinishedAt(DateTime(2026, 9, 28, 14, 20)).finishedAt,
        DateTime(2026, 9, 28, 14, 20),
      );
    });

    /// `copyWith(finishedAt: null)` reads as "leave it alone".
    test('notFinished clears the stamp where copyWith cannot', () {
      final finished = service().markedFinished(at: markedAt);

      expect(finished.copyWith().finishedAt, markedAt);
      expect(finished.notFinished().isFinished, isFalse);
    });

    test('the other transitions keep the booking and the finish stamp', () {
      final finished = service(
        startTime: const ClockTime(14, 0),
        duration: const Duration(minutes: 45),
      ).markedFinished(at: markedAt);

      for (final next in [
        finished.markedReceivedAt(markedAt),
        finished.markedCancelledAt(markedAt),
        finished.withoutClient(),
      ]) {
        expect(next.startTime, finished.startTime);
        expect(next.duration, finished.duration);
        expect(next.finishedAt, finished.finishedAt);
      }
    });
  });

  group('cancelled and finished exclude each other', () {
    final at = DateTime(2026, 9, 28, 18);

    test('a finished service cannot be cancelled', () {
      expect(service().canBeCancelled, isTrue);
      expect(service().markedFinished(at: at).canBeCancelled, isFalse);
    });

    test('a cancelled service cannot be finished', () {
      expect(service().canBeFinished, isTrue);
      expect(service(cancelledAt: at).canBeFinished, isFalse);
    });

    test('nor can a service that has not started', () {
      expect(booked().canBeFinishedAt(DateTime(2026, 9, 28, 13, 59)), isFalse);
      expect(booked().canBeFinishedAt(DateTime(2026, 9, 28, 14)), isTrue);
      expect(service().canBeFinishedAt(DateTime(2026, 9, 27, 23)), isFalse);
      expect(service().canBeFinishedAt(DateTime(2026, 9, 28)), isTrue);
      expect(
        booked(
          cancelledAt: DateTime(2026, 9, 27),
        ).canBeFinishedAt(DateTime(2026, 10)),
        isFalse,
      );
    });
  });

  group('earliestFinish', () {
    test('is the start of a timed service', () {
      expect(booked().earliestFinish, DateTime(2026, 9, 28, 14));
    });

    test('is the start of the day of an untimed one', () {
      expect(service().earliestFinish, DateTime(2026, 9, 28));
    });
  });

  group('agendaBlock', () {
    test('holds the planned slot while not finished', () {
      expect(booked().agendaBlock, (
        start: DateTime(2026, 9, 28, 14),
        end: DateTime(2026, 9, 28, 15, 30),
      ));
    });

    test('finishing early frees the rest of the slot', () {
      expect(
        booked(finishedAt: DateTime(2026, 9, 28, 15)).agendaBlock?.end,
        DateTime(2026, 9, 28, 15),
      );
    });

    test('running late holds the slot longer', () {
      expect(
        booked(finishedAt: DateTime(2026, 9, 28, 16)).agendaBlock?.end,
        DateTime(2026, 9, 28, 16),
      );
    });

    test('a finished service with no duration holds until it finished', () {
      expect(
        service(
          startTime: const ClockTime(9, 0),
          finishedAt: DateTime(2026, 9, 28, 10),
        ).agendaBlock,
        (start: DateTime(2026, 9, 28, 9), end: DateTime(2026, 9, 28, 10)),
      );
    });

    test('holds nothing when cancelled, untimed or with no end', () {
      expect(booked(cancelledAt: DateTime(2026, 9, 27)).agendaBlock, isNull);
      expect(service(duration: const Duration(hours: 1)).agendaBlock, isNull);
      expect(service(startTime: const ClockTime(9, 0)).agendaBlock, isNull);
    });
  });

  group('overlaps', () {
    Service at(int hour, int minute, {int minutes = 60}) => service(
      startTime: ClockTime(hour, minute),
      duration: Duration(minutes: minutes),
    );

    test('is set when the blocks share time', () {
      expect(booked().overlaps(at(15, 0)), isTrue);
      expect(at(13, 0, minutes: 180).overlaps(booked()), isTrue);
    });

    test('is not set for back-to-back bookings', () {
      expect(booked().overlaps(at(15, 30)), isFalse);
      expect(booked().overlaps(at(13, 0)), isFalse);
    });

    test('a slot freed by finishing early no longer overlaps', () {
      expect(
        booked(finishedAt: DateTime(2026, 9, 28, 15)).overlaps(at(15, 0)),
        isFalse,
      );
    });

    test('a cancelled or untimed service overlaps nothing', () {
      expect(
        booked(cancelledAt: DateTime(2026, 9, 27)).overlaps(at(14, 0)),
        isFalse,
      );
      expect(service().overlaps(booked()), isFalse);
    });
  });

  group('scheduleStateAt', () {
    test('reads cancelled and finished before anything else', () {
      final now = DateTime(2026, 9, 28, 14, 30);

      expect(
        booked(cancelledAt: DateTime(2026, 9, 27)).scheduleStateAt(now),
        ScheduleState.cancelled,
      );
      expect(
        booked(finishedAt: DateTime(2026, 9, 28, 14, 20)).scheduleStateAt(now),
        ScheduleState.finished,
      );
    });

    test('follows the booking from upcoming to overdue', () {
      expect(
        booked().scheduleStateAt(DateTime(2026, 9, 28, 13, 59)),
        ScheduleState.upcoming,
      );
      expect(
        booked().scheduleStateAt(DateTime(2026, 9, 28, 14)),
        ScheduleState.inProgress,
      );
      expect(
        booked().scheduleStateAt(DateTime(2026, 9, 28, 15, 30)),
        ScheduleState.overdue,
      );
    });

    test('an untimed service is never overdue, however old', () {
      expect(service().scheduleStateAt(DateTime(2027)), ScheduleState.untimed);
    });

    test('a timed service with no duration stays in progress once started', () {
      final noDuration = service(startTime: const ClockTime(9, 0));

      expect(
        noDuration.scheduleStateAt(DateTime(2026, 9, 28, 8, 59)),
        ScheduleState.upcoming,
      );
      expect(
        noDuration.scheduleStateAt(DateTime(2027)),
        ScheduleState.inProgress,
      );
    });
  });

  group('reconciledFinish', () {
    final now = DateTime(2026, 10, 12, 9);

    test('leaves a service that is not finished alone', () {
      final edited = booked().withStartTime(const ClockTime(16, 0));

      expect(edited.reconciledFinish(booked(), now: now), edited);
    });

    test('moves the automatic stamp along with the new planned end', () {
      final previous = booked().markedFinished(at: now);
      final edited = previous.withStartTime(const ClockTime(16, 0));

      expect(
        edited.reconciledFinish(previous, now: now).finishedAt,
        DateTime(2026, 9, 28, 17, 30),
      );
    });

    test('keeps a stamp the user set by hand', () {
      final previous = booked(finishedAt: DateTime(2026, 9, 28, 15, 10));
      final edited = previous.withDuration(const Duration(hours: 2));

      expect(
        edited.reconciledFinish(previous, now: now).finishedAt,
        DateTime(2026, 9, 28, 15, 10),
      );
    });

    test('re-derives a hand-set stamp that the new start overtook', () {
      final previous = booked(finishedAt: DateTime(2026, 9, 28, 15, 10));
      final edited = previous.withStartTime(const ClockTime(18, 0));

      expect(
        edited.reconciledFinish(previous, now: now).finishedAt,
        DateTime(2026, 9, 28, 19, 30),
      );
    });

    test('finished work moved into the future is no longer finished', () {
      final previous = booked().markedFinished(at: now);
      final edited = previous.copyWith(date: DateTime(2026, 10, 20));

      expect(edited.reconciledFinish(previous, now: now).isFinished, isFalse);
    });
  });
}
