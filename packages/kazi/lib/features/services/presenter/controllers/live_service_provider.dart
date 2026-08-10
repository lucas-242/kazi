import 'package:kazi/features/dashboard/presenter/controllers/dashboard_controller.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_controller.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

part 'live_service_provider.g.dart';

/// The current version of the service with [id], or null when no list holds it.
///
/// The details page is handed an immutable `Service` through go_router's
/// `extra`, so anything that mutates the service — marking it as received —
/// would leave that page rendering the state from before the tap. Watching this
/// instead makes the page follow whichever list the service came from.
///
/// Both sources are `keepAlive` and their `build()` only assembles a state
/// object, so reading them here cannot trigger a fetch.
@riverpod
Service? liveService(Ref ref, String id) {
  final services = [
    ...ref.watch(dashboardControllerProvider).services,
    ...ref.watch(serviceLandingControllerProvider).services,
  ];

  for (final service in services) {
    if (service.id == id) return service;
  }

  return null;
}
