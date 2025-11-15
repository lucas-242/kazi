import 'package:kazi/app/models/service.dart';
import 'package:kazi/app/models/service_group_by_date.dart';
import 'package:kazi/app/models/service_type.dart';
import 'package:kazi_core/kazi_core.dart' hide Service, ServiceType;

abstract class ServicesService {
  DateTime get now;

  List<Service> addServiceTypeToServices(
    List<Service> services,
    List<ServiceType> serviceTypes,
  );

  List<Service> orderServices(List<Service> services, OrderBy orderBy);

  ///Group [services] by date ordering by date desc.
  ///
  /// Brings isExpanded property as true if it is grouped by today or yesterday
  List<ServicesGroupByDate> groupServicesByDate(
    List<Service> services,
    OrderBy orderBy,
  );

  Map<String, DateTime> getRangeDateByFastSearch(FastSearch fastSearch);
}
