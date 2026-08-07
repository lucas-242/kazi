import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/domain/models/service_group_by_date.dart';
import 'package:kazi/features/services/domain/models/service_type.dart';
import 'package:kazi_core/kazi_core.dart' hide Service, ServiceType;

abstract class ServicesService {
  DateTime get now;

  List<Service> addServiceTypeToServices(
    List<Service> services,
    List<ServiceType> serviceTypes,
  );

  /// Orders [services]. The value orderings compare amounts converted into
  /// [currency] — comparing raw values across currencies ranks by the size of
  /// the number rather than by what it is worth.
  List<Service> orderServices(
    List<Service> services,
    OrderBy orderBy, {
    required SupportedCurrency currency,
    required RateBook rateBook,
  });

  ///Group [services] by date ordering by date desc.
  ///
  /// Brings isExpanded property as true if it is grouped by today or yesterday
  List<ServicesGroupByDate> groupServicesByDate(
    List<Service> services,
    OrderBy orderBy,
  );

  Map<String, DateTime> getRangeDateByFastSearch(FastSearch fastSearch);
}
