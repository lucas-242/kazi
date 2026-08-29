import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/clients/domain/models/client_entry.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/presenter/controllers/service_form_state.dart';

import '../../../../../mocks/client_mocks.dart';

void main() {
  Service service({String? clientId, String? clientName}) => Service(
    id: 's1',
    value: 100,
    commissionPercent: 40,
    catalogItemId: 'c1',
    clientId: clientId,
    clientName: clientName,
    date: DateTime(2026, 8, 20),
    userId: 'u1',
  );

  ServiceFormState state({
    required Service current,
    List<ClientEntry> clients = const [],
    List<ClientEntry> archivedClients = const [],
  }) => ServiceFormState(
    status: BaseStateStatus.readyToUserInput,
    userId: 'u1',
    service: current,
    clients: clients,
    archivedClients: archivedClients,
  );

  group('selectedClientDropdownItem', () {
    test('resolves an active client', () {
      final result = state(
        current: service(clientId: '1', clientName: 'Ana'),
        clients: [clientEntryMock(id: '1', name: 'Ana')],
      ).selectedClientDropdownItem;

      expect(result?.value, '1');
      expect(result?.label, 'Ana');
    });

    test('resolves an archived client', () {
      final result = state(
        current: service(clientId: '1', clientName: 'Ana'),
        archivedClients: [clientEntryMock(id: '1', name: 'Ana')],
      ).selectedClientDropdownItem;

      expect(result?.label, 'Ana');
    });

    test('falls back to the snapshot when the client was deleted', () {
      // The service still knows who it was for; the form must not read as if
      // it had lost them.
      final result = state(
        current: service(clientId: 'gone', clientName: 'Ana'),
      ).selectedClientDropdownItem;

      expect(result?.value, 'gone');
      expect(result?.label, 'Ana');
    });

    test('prefers the current name over the snapshot', () {
      // An active client who was renamed shows their name now, not the one
      // frozen on the service.
      final result = state(
        current: service(clientId: '1', clientName: 'Ana'),
        clients: [clientEntryMock(id: '1', name: 'Ana Maria')],
      ).selectedClientDropdownItem;

      expect(result?.label, 'Ana Maria');
    });

    test('offers nothing when the deleted client left no name', () {
      final result = state(
        current: service(clientId: 'gone'),
      ).selectedClientDropdownItem;

      expect(result, isNull);
    });

    test('offers nothing when the service has no client', () {
      expect(state(current: service()).selectedClientDropdownItem, isNull);
    });

    test('never offers a deleted client in the picker list', () {
      // It shows as selected but must not be pickable: there is nothing left
      // to pick.
      final subject = state(
        current: service(clientId: 'gone', clientName: 'Ana'),
        clients: [clientEntryMock(id: '1', name: 'Bruna')],
      );

      expect(subject.clientDropdownItems.map((item) => item.value), ['1']);
    });
  });
}
