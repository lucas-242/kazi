import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/domain/models/service_status.dart';

/// The two stamps are independent facts, and [Service.status] is the only place
/// that settles which one the app reads.
void main() {
  final paidOn = DateTime(2026, 9, 5);
  final cancelledOn = DateTime(2026, 9, 10);
  final now = DateTime(2026, 9, 15);

  Service service({DateTime? receivedAt, DateTime? cancelledAt}) => Service(
    id: 'service-1',
    value: 100,
    commissionPercent: 40,
    catalogItemId: 'item-1',
    date: DateTime(2026, 8, 20),
    receivedAt: receivedAt,
    cancelledAt: cancelledAt,
    userId: 'user-1',
  );

  group('status', () {
    test('Should open as pending, which is what registering work means', () {
      expect(service().status, ServiceStatus.pending);
    });

    test('Should read a stamped service as received', () {
      expect(service(receivedAt: paidOn).status, ServiceStatus.received);
    });

    test('Should let cancellation outrank payment', () {
      final service_ = service(receivedAt: paidOn, cancelledAt: cancelledOn);

      expect(service_.status, ServiceStatus.cancelled);
      expect(service_.receivedAt, paidOn);
    });
  });

  group('withStatus', () {
    test('Should stamp a service moved to received', () {
      final moved = service().withStatus(ServiceStatus.received, at: now);

      expect(moved.receivedAt, now);
      expect(moved.isCancelled, isFalse);
    });

    test('Should keep a payment date it already carries', () {
      final moved = service(
        receivedAt: paidOn,
      ).withStatus(ServiceStatus.received, at: now);

      expect(moved.receivedAt, paidOn);
    });

    test('Should hand the payment stamp back when uncancelled', () {
      final moved = service(
        receivedAt: paidOn,
        cancelledAt: cancelledOn,
      ).withStatus(ServiceStatus.received, at: now);

      expect(moved.status, ServiceStatus.received);
      expect(moved.receivedAt, paidOn);
    });

    test('Should keep the payment stamp under a cancellation', () {
      final moved = service(
        receivedAt: paidOn,
      ).withStatus(ServiceStatus.cancelled, at: now);

      expect(moved.status, ServiceStatus.cancelled);
      expect(moved.cancelledAt, now);
      expect(moved.receivedAt, paidOn);
    });

    test('Should clear both stamps on the way back to pending', () {
      final moved = service(
        receivedAt: paidOn,
        cancelledAt: cancelledOn,
      ).withStatus(ServiceStatus.pending, at: now);

      expect(moved.status, ServiceStatus.pending);
      expect(moved.receivedAt, isNull);
      expect(moved.cancelledAt, isNull);
    });
  });

  /// Each named transition mirrors a field-scoped write, so it must touch the
  /// one stamp that write touches and nothing else.
  group('the named transitions', () {
    test('Should cancel without disturbing the payment stamp', () {
      final cancelled = service(receivedAt: paidOn).markedCancelledAt(now);

      expect(cancelled.cancelledAt, now);
      expect(cancelled.receivedAt, paidOn);
    });

    test('Should uncancel without disturbing the payment stamp', () {
      final reopened = service(
        receivedAt: paidOn,
        cancelledAt: cancelledOn,
      ).notCancelled();

      expect(reopened.cancelledAt, isNull);
      expect(reopened.receivedAt, paidOn);
    });

    test('Should flip the payment stamp without lifting a cancellation', () {
      final stamped = service(cancelledAt: cancelledOn).markedReceivedAt(now);

      expect(stamped.receivedAt, now);
      expect(stamped.cancelledAt, cancelledOn);
      expect(stamped.notReceived().cancelledAt, cancelledOn);
    });
  });

  group('copyWith', () {
    test('Should carry the cancellation through an ordinary edit', () {
      final edited = service(cancelledAt: cancelledOn).copyWith(value: 250);

      expect(edited.cancelledAt, cancelledOn);
    });
  });
}
