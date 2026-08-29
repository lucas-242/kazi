import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/domain/models/service_group_by_date.dart';
import 'package:kazi/features/services/data/services/local_service_organizer.dart';
import 'package:kazi/features/services/domain/services/service_organizer.dart';
import 'package:kazi/core/services/data/local_time_service.dart';
import 'package:kazi/core/services/domain/time_service.dart';
import 'package:kazi_core/kazi_core.dart' hide Service;

import '../../../../../mocks/mocks.dart';

void main() {
  late TimeService timeService;
  late ServiceOrganizer serviceOrganizer;

  setUp(() {
    timeService = LocalTimeService(DateTime(2023));
    serviceOrganizer = LocalServiceOrganizer(timeService);
  });

  group('Get range date by FastSearch', () {
    Map<String, DateTime> getExpected(DateTime startDate, DateTime endDate) => {
      'startDate': startDate,
      'endDate': endDate,
    };

    test('Should get range for Last Month', () {
      final result = serviceOrganizer.getRangeDateByFastSearch(
        FastSearch.lastMonth,
      );

      expect(
        result,
        getExpected(DateTime(2022, 12), DateTime(2022, 12, 31, 23, 59, 59)),
      );
    });

    test('Should get range for Month', () {
      final result = serviceOrganizer.getRangeDateByFastSearch(FastSearch.month);

      expect(
        result,
        getExpected(
          serviceOrganizer.now,
          serviceOrganizer.now.copyWith(
            day: 31,
            hour: 23,
            minute: 59,
            second: 59,
          ),
        ),
      );
    });

    test('Should get range for First Fortnight', () {
      final result = serviceOrganizer.getRangeDateByFastSearch(
        FastSearch.fortnight,
      );

      expect(
        result,
        getExpected(
          serviceOrganizer.now,
          serviceOrganizer.now.copyWith(
            day: 15,
            hour: 23,
            minute: 59,
            second: 59,
          ),
        ),
      );
    });

    test('Should get range for Last Fortnight', () {
      //HERE serviceOrganizer.now.copyWith(day: 17)
      serviceOrganizer = LocalServiceOrganizer(
        LocalTimeService(serviceOrganizer.now.copyWith(day: 17)),
      );
      final result = serviceOrganizer.getRangeDateByFastSearch(
        FastSearch.fortnight,
      );

      expect(
        result,
        getExpected(
          serviceOrganizer.now.copyWith(day: 16),
          serviceOrganizer.now.copyWith(
            day: 31,
            hour: 23,
            minute: 59,
            second: 59,
          ),
        ),
      );
    });

    test('Should get range for Week', () {
      final result = serviceOrganizer.getRangeDateByFastSearch(FastSearch.week);

      expect(
        result,
        getExpected(
          serviceOrganizer.now.lastWeekday(DateTime.sunday),
          serviceOrganizer.now
              .copyWith(hour: 23, minute: 59, second: 59)
              .nextWeekday(DateTime.saturday),
        ),
      );
    });

    test('Should get range for Today', () {
      final result = serviceOrganizer.getRangeDateByFastSearch(FastSearch.today);

      expect(
        result,
        getExpected(
          serviceOrganizer.now,
          serviceOrganizer.now.copyWith(hour: 23, minute: 59, second: 59),
        ),
      );
    });
  });

  group('Add catalog item to services', () {
    final known = catalogItemMock.copyWith(id: 'known', name: 'known item');

    test('Should join each service with its catalog item', () {
      final services = [serviceMock.copyWith(catalogItemId: known.id)];

      final result = serviceOrganizer.addCatalogItemToServices(services, [
        known,
      ]);

      expect(result.single.catalogItem, known);
    });

    test('Should fall back to a placeholder when the item is missing', () {
      // A service outliving its catalog item still has to render: it carries
      // its own value and commission, and the screen must not go down with it.
      final services = [serviceMock.copyWith(catalogItemId: 'gone')];

      final result = serviceOrganizer.addCatalogItemToServices(services, [
        known,
      ]);

      expect(result.single.catalogItem?.id, 'gone');
      expect(result.single.catalogItem?.name, isEmpty);
      expect(result.single.value, serviceMock.value);
      expect(
        result.single.effectiveCommissionPercent,
        serviceMock.effectiveCommissionPercent,
      );
    });

    test('Should sort alphabetically with a missing item present', () {
      final services = [
        serviceMock.copyWith(catalogItemId: 'gone'),
        serviceMock.copyWith(catalogItemId: known.id),
      ];

      final joined = serviceOrganizer.addCatalogItemToServices(services, [
        known,
      ]);

      expect(
        () => serviceOrganizer.orderServices(
          joined,
          OrderBy.alphabetical,
          currency: SupportedCurrency.brl,
          rateBook: const RateBook.empty(),
        ),
        returnsNormally,
      );
    });
  });

  group('Get Services by Date', () {
    late List<Service> services;
    late List<ServicesGroupByDate> expected;

    setUpAll(() {
      services = [
        serviceMock.copyWith(date: DateTime(2022, 12, 7)),
        serviceMock.copyWith(date: DateTime(2022, 12, 13)),
        serviceMock.copyWith(date: DateTime(2023)),
        serviceMock.copyWith(date: DateTime(2022, 12, 31)),
        serviceMock.copyWith(date: DateTime(2022, 12, 7)),
        serviceMock.copyWith(date: DateTime(2023)),
        serviceMock.copyWith(date: DateTime(2022, 12, 13)),
      ];

      expected = [
        ServicesGroupByDate(
          isExpanded: true,
          date: DateTime(2023),
          services: [
            serviceMock.copyWith(date: DateTime(2023)),
            serviceMock.copyWith(date: DateTime(2023)),
          ],
        ),
        ServicesGroupByDate(
          date: DateTime(2022, 12, 31),
          services: [serviceMock.copyWith(date: DateTime(2022, 12, 31))],
        ),
        ServicesGroupByDate(
          date: DateTime(2022, 12, 13),
          services: [
            serviceMock.copyWith(date: DateTime(2022, 12, 13)),
            serviceMock.copyWith(date: DateTime(2022, 12, 13)),
          ],
        ),
        ServicesGroupByDate(
          date: DateTime(2022, 12, 7),
          services: [
            serviceMock.copyWith(date: DateTime(2022, 12, 7)),
            serviceMock.copyWith(date: DateTime(2022, 12, 7)),
          ],
        ),
      ];
    });

    test('Should group services by date ordered by date Desc', () {
      final result = serviceOrganizer.groupServicesByDate(
        services,
        OrderBy.dateDesc,
      );

      expect(result, expected);
    });

    test('Should group services by date ordered by date Asc', () {
      expected = expected.reversed.toList();
      expected.last = expected.last.copyWith(isExpanded: false);
      expected.first = expected.first.copyWith(isExpanded: true);

      final result = serviceOrganizer.groupServicesByDate(
        services,
        OrderBy.dateAsc,
      );

      expect(result, expected);
    });
  });
}
