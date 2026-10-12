import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/services/domain/models/clock_time.dart';
import 'package:kazi/features/services/domain/models/service.dart';

void main() {
  Service service({
    ClockTime? startTime,
    Duration? duration,
    DateTime? receivedAt,
    DateTime? cancelledAt,
  }) => Service(
    value: 100,
    date: DateTime(2026, 9, 28),
    startTime: startTime,
    duration: duration,
    receivedAt: receivedAt,
    cancelledAt: cancelledAt,
    userId: 'user-1',
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
  });
}
