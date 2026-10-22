import 'dart:async';

import 'package:kazi/core/services/domain/analytics_event.dart';
import 'package:kazi/core/services/domain/analytics_service.dart';
import 'package:kazi/core/services/domain/time_service.dart';
import 'package:kazi/features/agenda/presenter/controllers/agenda_controller.dart';
import 'package:kazi/features/dashboard/presenter/controllers/dashboard_controller.dart';
import 'package:kazi/features/onboarding/domain/models/checklist_step.dart';
import 'package:kazi/features/onboarding/presenter/controllers/checklist_controller.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/domain/repositories/services_repository.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_controller.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

part 'service_status_controller.g.dart';

/// The single place a service's status stamps are written — the payment stamp,
/// the cancellation and the finish.
///
/// One writer, two readers: the write goes to Firestore once, then both list
/// controllers patch their own copy in memory. Refetching instead would depend
/// on the write echo having landed — `ServicesRepository.get` reads
/// cache-first — so the list could come back showing the state from before the
/// tap. An in-memory patch is deterministic and instant.
///
/// `keepAlive` because the write is awaited: an auto-disposed writer has no
/// listener holding it, so the Ref is gone by the time Firestore answers and
/// every patch below throws.
@Riverpod(keepAlive: true)
class ServiceStatusController extends _$ServiceStatusController {
  ServicesRepository get _repository => ref.read(servicesRepositoryProvider);

  TimeService get _timeService => ref.read(timeServiceProvider);

  AnalyticsService get _analytics => ref.read(analyticsServiceProvider);

  final _inFlight = InFlight();

  @override
  void build() {}

  /// Stamps or clears [services], then patches the lists that show them.
  ///
  /// Returns the ids it wrote, so an undo can hand back exactly the same set
  /// rather than re-deriving it from a list that has since moved.
  Future<List<String>> setReceived(
    Iterable<Service> services, {
    required bool received,
  }) => setReceivedByIds(
    services.map((service) => service.id).toList(),
    received: received,
  );

  /// The id-based form, for callers that no longer hold the services — an undo
  /// acts on the set that was written, which by then may have scrolled out of
  /// any list.
  Future<List<String>> setReceivedByIds(
    List<String> ids, {
    required bool received,
  }) async {
    if (ids.isEmpty) return const [];

    final key = ('received', ids.join(','));

    return await _inFlight.run(
          key,
          () => _setReceivedByIds(ids, received: received),
        ) ??
        const [];
  }

  Future<List<String>> _setReceivedByIds(
    List<String> ids, {
    required bool received,
  }) async {
    final stamp = received ? _timeService.now : null;
    await _repository.setReceivedAt(ids, stamp);

    final stamps = {for (final id in ids) id: stamp};
    ref.read(dashboardControllerProvider.notifier).applyReceipt(stamps);
    ref.read(serviceLandingControllerProvider.notifier).applyReceipt(stamps);
    ref.read(agendaControllerProvider.notifier).applyReceipt(stamps);

    if (received) {
      // Ticks the home checklist. There is no cheap "has ever received"
      // query, so the step is stamped where it happens; the call is a no-op
      // once it already is.
      unawaited(
        ref
            .read(checklistControllerProvider.notifier)
            .markStep(ChecklistStep.markReceived),
      );
    }

    return ids;
  }

  /// Calls [service] off, or puts it back in force, then patches the lists that
  /// show it.
  ///
  /// One service at a time: nothing in the app cancels in bulk, and the write
  /// moves the denormalized counters, which costs a read per service.
  Future<void> setCancelled(Service service, {required bool cancelled}) =>
      setCancelledById(service.id, cancelled: cancelled);

  /// The id-based form, for an undo acting on a service it no longer holds.
  ///
  /// A second call would read the service before the first wrote it, and move
  /// the counters twice.
  Future<void> setCancelledById(String id, {required bool cancelled}) async {
    if (id.isEmpty) return;
    final key = ('cancelled', id);
    await _inFlight.run(key, () => _setCancelledById(id, cancelled: cancelled));
  }

  Future<void> _setCancelledById(String id, {required bool cancelled}) async {
    final stamp = cancelled ? _timeService.now : null;
    await _repository.setCancelledAt(id, stamp);

    final stamps = {id: stamp};
    ref.read(dashboardControllerProvider.notifier).applyCancellation(stamps);
    ref
        .read(serviceLandingControllerProvider.notifier)
        .applyCancellation(stamps);
    ref.read(agendaControllerProvider.notifier).applyCancellation(stamps);
  }

  /// Marks [service] finished, or puts it back on the agenda, then patches the
  /// lists that show it.
  ///
  /// The stamp is the planned end once it has passed, else now — see
  /// `Service.markedFinished`.
  Future<void> setFinished(Service service, {required bool finished}) {
    final stamp = finished
        ? service.markedFinished(at: _timeService.now).finishedAt
        : null;
    return _runFinish(
      service.id,
      stamp,
      onWritten: finished ? () => _reportFinished(service, 'mark') : null,
    );
  }

  /// Rewrites when [service] was finished, after the user corrected it.
  Future<void> correctFinishedAt(Service service, DateTime at) => _runFinish(
    service.id,
    at,
    onWritten: () => _reportFinished(service, 'correction'),
  );

  /// The id-based form, for an undo acting on a service it no longer holds:
  /// it writes [at] exactly, null included.
  Future<void> setFinishedAtById(String id, DateTime? at) => _runFinish(id, at);

  /// A second tap while the first write runs is dropped, report included.
  Future<void> _runFinish(
    String id,
    DateTime? at, {
    void Function()? onWritten,
  }) async {
    if (id.isEmpty) return;
    await _inFlight.run(('finished', id), () async {
      await _repository.setFinishedAt(id, at);

      final stamps = {id: at};
      ref.read(dashboardControllerProvider.notifier).applyFinish(stamps);
      ref.read(serviceLandingControllerProvider.notifier).applyFinish(stamps);
      ref.read(agendaControllerProvider.notifier).applyFinish(stamps);
      onWritten?.call();
    });
  }

  void _reportFinished(Service service, String source) => unawaited(
    _analytics.log(
      AnalyticsEvent.serviceFinished,
      parameters: {'source': source, 'has_schedule': service.startTime != null},
    ),
  );
}
