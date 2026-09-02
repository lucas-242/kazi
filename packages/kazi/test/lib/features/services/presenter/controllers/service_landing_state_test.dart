import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/services/domain/models/receipt_filter.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_state.dart';

void main() {
  final day = DateTime(2026, 8, 20);

  Service service({
    required String id,
    double value = 100,
    double commissionPercent = 40,
    DateTime? receivedAt,
    String? clientId,
    String? clientName,
  }) => Service(
    id: id,
    value: value,
    commissionPercent: commissionPercent,
    receivedAt: receivedAt,
    clientId: clientId,
    clientName: clientName,
    date: day,
    userId: 'user-1',
  );

  ServiceLandingState stateWith(
    List<Service> services, {
    ReceiptFilter receiptFilter = ReceiptFilter.all,
    String? clientId,
  }) => ServiceLandingState(
    status: BaseStateStatus.success,
    services: services,
    startDate: day,
    endDate: day,
    receiptFilter: receiptFilter,
    clientId: clientId,
  );

  final paid = service(id: 'paid', receivedAt: DateTime(2026, 9, 5));
  final owed = service(id: 'owed', value: 50);

  group('visibleServices', () {
    test('Should list everything under the default filters', () {
      expect(stateWith([paid, owed]).visibleServices, [paid, owed]);
    });

    test('Should keep only what is still owed under pending', () {
      final state = stateWith([
        paid,
        owed,
      ], receiptFilter: ReceiptFilter.pending);

      expect(state.visibleServices, [owed]);
    });

    test('Should keep only what is paid under received', () {
      final state = stateWith([
        paid,
        owed,
      ], receiptFilter: ReceiptFilter.received);

      expect(state.visibleServices, [paid]);
    });

    test('Should narrow to a single client', () {
      final marina = service(
        id: 'marina',
        clientId: 'client-1',
        clientName: 'Marina',
      );
      final julia = service(
        id: 'julia',
        clientId: 'client-2',
        clientName: 'Júlia',
      );
      final state = stateWith([marina, julia, owed], clientId: 'client-1');

      expect(state.visibleServices, [marina]);
    });

    test('Should apply the receipt and client filters together', () {
      final marinaPaid = service(
        id: 'marina-paid',
        clientId: 'client-1',
        clientName: 'Marina',
        receivedAt: DateTime(2026, 9, 5),
      );
      final marinaOwed = service(
        id: 'marina-owed',
        clientId: 'client-1',
        clientName: 'Marina',
      );
      final state = stateWith(
        [marinaPaid, marinaOwed, owed],
        receiptFilter: ReceiptFilter.pending,
        clientId: 'client-1',
      );

      expect(state.visibleServices, [marinaOwed]);
    });
  });

  /// The whole reason the filters live on the state rather than in the widget:
  /// the summary's numbers have to describe the rows the list is showing.
  group('totals', () {
    test('Should describe only the visible services', () {
      final all = stateWith([paid, owed]);
      final pending = stateWith([
        paid,
        owed,
      ], receiptFilter: ReceiptFilter.pending);

      expect(all.totals.value, 150);
      expect(pending.totals.value, 50);
      // 40% of the one remaining service.
      expect(pending.totals.commission, 20);
      expect(pending.totals.pendingCount, 1);
    });
  });

  group('hasNothingToShow', () {
    test('Should be true when the chips hide every fetched service', () {
      final state = stateWith([paid], receiptFilter: ReceiptFilter.pending);

      expect(state.hasNothingToShow, isTrue);
    });

    /// The period coming back empty is the same case: the tab reads one
    /// period, so it cannot tell a quiet month from an account with nothing.
    test('Should be true when the period itself is empty', () {
      expect(stateWith([]).hasNothingToShow, isTrue);
    });

    test('Should be false while something is still listed', () {
      expect(stateWith([paid, owed]).hasNothingToShow, isFalse);
    });
  });

  group('filterableClients', () {
    test('Should list each client once, ordered by name', () {
      final state = stateWith([
        service(id: 'a', clientId: 'client-2', clientName: 'Júlia'),
        service(id: 'b', clientId: 'client-1', clientName: 'Ana'),
        service(id: 'c', clientId: 'client-1', clientName: 'Ana'),
      ]);

      expect(state.filterableClients, [
        (id: 'client-1', name: 'Ana'),
        (id: 'client-2', name: 'Júlia'),
      ]);
    });

    test('Should skip services with no client or no name', () {
      final state = stateWith([
        owed,
        service(id: 'nameless', clientId: 'client-9'),
      ]);

      expect(state.filterableClients, isEmpty);
    });

    /// Drawn from everything fetched, not from what survives the chips —
    /// otherwise picking one client would empty the picker of every other.
    test('Should stay complete while a client filter is applied', () {
      final state = stateWith([
        service(id: 'a', clientId: 'client-1', clientName: 'Ana'),
        service(id: 'b', clientId: 'client-2', clientName: 'Júlia'),
      ], clientId: 'client-1');

      expect(state.filterableClients.length, 2);
    });
  });

  group('copyWith', () {
    test('Should keep the selected client when it is not mentioned', () {
      final state = stateWith([], clientId: 'client-1');

      expect(
        state.copyWith(receiptFilter: ReceiptFilter.pending).clientId,
        'client-1',
      );
    });

    /// A plain `?? this.clientId` could never express this, which is why the
    /// parameter is sentinel-typed.
    test('Should clear the selected client when passed null', () {
      final state = stateWith([], clientId: 'client-1');

      expect(state.copyWith(clientId: null).clientId, isNull);
    });
  });
}
