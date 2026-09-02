import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/services/domain/models/catalog_item.dart';
import 'package:kazi/features/services/domain/models/receipt_filter.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_state.dart';

/// Search is the one cut that deliberately disobeys the period, and the type
/// filter is the one that can be several things at once. Both are easy to get
/// subtly wrong and invisible in a screenshot.
void main() {
  final day = DateTime(2026, 8, 20);

  CatalogItem item(String id, String name) => CatalogItem(
    id: id,
    name: name,
    userId: 'user-1',
    defaultValue: 100,
  );

  Service service({
    required String id,
    String catalogItemId = 'type-1',
    String? catalogItemName = 'Alongamento em gel',
    String? clientName,
    String? description,
    DateTime? date,
  }) => Service(
    id: id,
    value: 100,
    commissionPercent: 40,
    catalogItemId: catalogItemId,
    catalogItem: catalogItemName == null
        ? null
        : item(catalogItemId, catalogItemName),
    clientName: clientName,
    description: description,
    date: date ?? day,
    userId: 'user-1',
  );

  ServiceLandingState stateWith({
    List<Service> services = const [],
    List<Service> searchServices = const [],
    String searchTerm = '',
    Set<String> catalogItemIds = const {},
    ReceiptFilter receiptFilter = ReceiptFilter.all,
  }) => ServiceLandingState(
    status: BaseStateStatus.success,
    services: services,
    searchServices: searchServices,
    searchTerm: searchTerm,
    catalogItemIds: catalogItemIds,
    receiptFilter: receiptFilter,
    startDate: day,
    endDate: day,
  );

  group('searchedServices', () {
    final all = [
      service(id: 'a', clientName: 'Marina Rocha'),
      service(
        id: 'b',
        catalogItemId: 'type-2',
        catalogItemName: 'Manutenção',
        clientName: 'Júlia Santana',
      ),
      service(id: 'c', description: 'Pediu decoração nas duas mãos'),
    ];

    test('Should search over everything registered, not over the period', () {
      // The period holds one service; the search holds all three.
      final state = stateWith(
        services: [all.first],
        searchServices: all,
        searchTerm: 'marina',
      );

      expect(state.services, hasLength(1));
      expect(state.searchedServices.map((s) => s.id), ['a']);
    });

    test('Should match the type, the client and the note', () {
      String? found(String term) => stateWith(
        searchServices: all,
        searchTerm: term,
      ).searchedServices.firstOrNull?.id;

      expect(found('manutenção'), 'b');
      expect(found('júlia'), 'b');
      expect(found('decoração'), 'c');
    });

    // Same rule the catalog uses for duplicate names: accents and case are
    // how the word was typed, not what it means.
    test('Should ignore case and accents', () {
      expect(
        stateWith(searchServices: all, searchTerm: 'MANUTENCAO')
            .searchedServices
            .map((s) => s.id),
        ['b'],
      );
    });

    test('Should find nothing on an empty term', () {
      expect(stateWith(searchServices: all).searchedServices, isEmpty);
    });

    test('Should order the results newest first', () {
      final state = stateWith(
        searchServices: [
          service(id: 'old', clientName: 'Marina', date: DateTime(2026, 1, 5)),
          service(id: 'new', clientName: 'Marina', date: DateTime(2026, 8, 5)),
        ],
        searchTerm: 'marina',
      );

      expect(state.searchedServices.map((s) => s.id), ['new', 'old']);
    });
  });

  group('the type filter', () {
    final services = [
      service(id: 'a'),
      service(id: 'b', catalogItemId: 'type-2', catalogItemName: 'Manutenção'),
      service(id: 'c', catalogItemId: 'type-3', catalogItemName: 'Blindagem'),
    ];

    test('Should keep every type when nothing is selected', () {
      expect(stateWith(services: services).visibleServices, hasLength(3));
    });

    test('Should keep the several types selected at once', () {
      final state = stateWith(
        services: services,
        catalogItemIds: {'type-1', 'type-3'},
      );

      expect(state.visibleServices.map((s) => s.id), ['a', 'c']);
    });

    test('Should count what it offers, by name', () {
      final state = stateWith(services: [...services, service(id: 'd')]);

      expect(
        state.filterableCatalogItems.map((i) => '${i.name}:${i.count}'),
        ['Alongamento em gel:2', 'Blindagem:1', 'Manutenção:1'],
      );
    });

    test('Should count as an active filter', () {
      expect(stateWith(services: services).hasSecondaryFilters, isFalse);
      expect(
        stateWith(services: services, catalogItemIds: {'type-1'})
            .hasSecondaryFilters,
        isTrue,
      );
    });
  });
}
