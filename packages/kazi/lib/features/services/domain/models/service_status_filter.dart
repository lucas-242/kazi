import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/domain/models/service_status.dart';

/// Narrows the listed services by where they stand.
///
/// Applied in memory over the services already fetched for the period — the
/// Firestore query stays a date-range query, so flipping this costs no read.
enum ServiceStatusFilter {
  all,
  pending,
  received,
  cancelled;

  bool allows(Service service) => switch (this) {
    ServiceStatusFilter.all => true,
    ServiceStatusFilter.pending => service.status == ServiceStatus.pending,
    ServiceStatusFilter.received => service.status == ServiceStatus.received,
    ServiceStatusFilter.cancelled => service.status == ServiceStatus.cancelled,
  };
}
