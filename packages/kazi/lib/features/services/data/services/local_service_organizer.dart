import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/domain/models/service_group_by_date.dart';
import 'package:kazi/features/services/domain/models/catalog_item.dart';
import 'package:kazi/features/services/domain/services/service_organizer.dart';
import 'package:kazi/core/services/domain/time_service.dart';
import 'package:kazi_core/kazi_core.dart' hide Service, CatalogItem;

class LocalServiceOrganizer extends ServiceOrganizer {
  LocalServiceOrganizer(this._timeService);

  final TimeService _timeService;
  @override
  DateTime get now => _timeService.now;

  @override
  List<Service> addCatalogItemToServices(
    List<Service> services,
    List<CatalogItem> catalogItems,
  ) {
    final result = <Service>[];
    for (var service in services) {
      result.add(_fillServiceWithCatalogItem(service, catalogItems));
    }
    return result;
  }

  Service _fillServiceWithCatalogItem(
    Service service,
    List<CatalogItem> catalogItems,
  ) {
    return service.copyWith(
      catalogItem: catalogItems.firstWhere(
        (item) => item.id == service.catalogItemId,
        // A service whose catalog item is gone still has to render: it carries
        // its own value, commission and name snapshot, and losing the item must
        // not cost the user the whole screen.
        orElse: () =>
            service.catalogItem ??
            CatalogItem(id: service.catalogItemId, userId: service.userId),
      ),
    );
  }

  @override
  List<Service> orderServices(
    List<Service> services,
    OrderBy orderBy, {
    required SupportedCurrency currency,
    required RateBook rateBook,
  }) {
    // Precomputed once per sort instead of on every comparison, and so a
    // service with no usable rate keeps a stable position rather than making
    // the comparator inconsistent.
    final converted = <String, double>{
      for (final service in services)
        service.id:
            service.convert(
              service.value,
              to: currency,
              fallback: currency,
              rateBook: rateBook,
            ) ??
            service.value,
    };

    int compareValueAsc(Service a, Service b) =>
        (converted[a.id] ?? a.value).compareTo(converted[b.id] ?? b.value);
    int compareValueDesc(Service a, Service b) => -compareValueAsc(a, b);

    switch (orderBy) {
      case OrderBy.dateAsc:
        return _sortWithTiebreaker(
          services,
          _compareDateAsc,
          _compareAlphabetical,
          compareValueDesc,
        );
      case OrderBy.dateDesc:
        return _sortWithTiebreaker(
          services,
          _compareDateDesc,
          _compareAlphabetical,
          compareValueDesc,
        );
      case OrderBy.alphabetical:
        return _sortWithTiebreaker(
          services,
          _compareAlphabetical,
          _compareDateDesc,
          compareValueDesc,
        );
      case OrderBy.valueAsc:
        return _sortWithTiebreaker(
          services,
          compareValueAsc,
          _compareAlphabetical,
          _compareDateDesc,
        );
      case OrderBy.valueDesc:
        return _sortWithTiebreaker(
          services,
          compareValueDesc,
          _compareAlphabetical,
          _compareDateDesc,
        );
    }
  }

  List<Service> _sortWithTiebreaker(
    List<Service> services,
    int Function(Service, Service) firstCompare,
    int Function(Service, Service) secondCompare,
    int Function(Service, Service) thirdCompare,
  ) {
    services.sort((a, b) {
      final firstResult = firstCompare(a, b);
      if (firstResult != 0) return firstResult;
      final secondResult = secondCompare(a, b);
      if (secondResult != 0) return secondResult;
      return thirdCompare(a, b);
    });

    return services;
  }

  int _compareAlphabetical(Service a, Service b) =>
      a.catalogItem!.name.compareTo(b.catalogItem!.name);
  int _compareDateAsc(Service a, Service b) => a.date.compareTo(b.date);
  int _compareDateDesc(Service a, Service b) => b.date.compareTo(a.date);

  @override
  List<ServicesGroupByDate> groupServicesByDate(
    List<Service> services,
    OrderBy orderBy,
  ) {
    var result = <ServicesGroupByDate>[];
    final dates = _getServicesDates(services);

    for (var date in dates) {
      final servicesOnDate = services.where((s) => s.date == date).toList();
      if (servicesOnDate.isNotEmpty) {
        result.add(ServicesGroupByDate(date: date, services: servicesOnDate));
      }
    }

    if (result.isEmpty) return [];

    result = _sortGroupServicesByDate(result, orderBy);
    result.first = result.first.copyWith(isExpanded: true);

    return result;
  }

  List<DateTime> _getServicesDates(List<Service> services) {
    final dates = services.map((s) => s.date).toSet().toList();
    final yesterday = now.copyWith(day: now.day - 1);

    //* Remove today and yesterday from middle of the list to add them on top
    final todayWasRemoved = dates.remove(now);
    final yesterdayWasRemoved = dates.remove(yesterday);

    dates.sort((a, b) => b.compareTo(a));

    if (todayWasRemoved) {
      dates.insert(0, now);
      if (yesterdayWasRemoved) dates.insert(1, yesterday);
    } else if (yesterdayWasRemoved) {
      dates.insert(0, yesterday);
    }

    return dates;
  }

  List<ServicesGroupByDate> _sortGroupServicesByDate(
    List<ServicesGroupByDate> groups,
    OrderBy orderBy,
  ) {
    if (orderBy == OrderBy.dateAsc) {
      groups.sort((a, b) => a.date.compareTo(b.date));
    } else {
      groups.sort((a, b) => b.date.compareTo(a.date));
    }

    return groups;
  }

  @override
  Map<String, DateTime> getRangeDateByFastSearch(FastSearch fastSearch) {
    DateTime startDate;
    DateTime endDate;
    switch (fastSearch) {
      case FastSearch.week:
        startDate = now.lastWeekday(DateTime.sunday);
        endDate = now.nextWeekday(DateTime.saturday);
        break;
      case FastSearch.fortnight:
        if (now.day <= 15) {
          startDate = DateTime(now.year, now.month);
          endDate = DateTime(now.year, now.month, 15);
        } else {
          startDate = DateTime(now.year, now.month, 16);
          endDate = DateTime(now.year, now.month + 1, 0);
        }
        break;
      case FastSearch.month:
        startDate = DateTime(now.year, now.month);
        endDate = DateTime(now.year, now.month + 1, 0);
        break;
      case FastSearch.lastMonth:
        startDate = DateTime(now.year, now.month - 1);
        endDate = DateTime(now.year, now.month, 0);
        break;
      default:
        startDate = now;
        endDate = now;
        break;
    }
    return {
      'startDate': startDate.firstHourOfDay,
      'endDate': endDate.lastHourOfDay,
    };
  }
}
