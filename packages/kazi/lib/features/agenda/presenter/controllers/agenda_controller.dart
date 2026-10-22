import 'package:flutter/material.dart' show DateTimeRange, DateUtils;
import 'package:kazi/core/utils/base_notifier.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/domain/repositories/catalog_item_repository.dart';
import 'package:kazi/features/services/domain/repositories/services_repository.dart';
import 'package:kazi/features/services/domain/services/service_organizer.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

import 'agenda_state.dart';

part 'agenda_controller.g.dart';

@Riverpod(keepAlive: true)
class AgendaController extends _$AgendaController
    with BaseNotifier<AgendaState> {
  ServicesRepository get _servicesRepository =>
      ref.read(servicesRepositoryProvider);

  CatalogItemRepository get _catalogItemRepository =>
      ref.read(catalogItemRepositoryProvider);

  AuthService get _authService => ref.read(authServiceProvider);

  ServiceOrganizer get _serviceOrganizer => ref.read(serviceOrganizerProvider);

  /// The day ranges already fetched, so swiping back to one costs no read.
  final List<({DateTime first, DateTime last})> _loaded = [];

  /// Bumped whenever a read in flight is abandoned; see the same field on
  /// `ServiceLandingController`.
  int _readGeneration = 0;

  int _readsInFlight = 0;

  bool _hasAbandonedRead = false;

  @override
  AgendaState build() {
    final today = DateUtils.dateOnly(ref.read(timeServiceProvider).now);
    return AgendaState(
      status: BaseStateStatus.loading,
      mode: KaziAgendaMode.day,
      firstVisibleDay: today,
      lastVisibleDay: today,
    );
  }

  void onChangeMode(KaziAgendaMode mode) {
    state = state.copyWith(mode: mode);
  }

  /// Follows the dates the agenda reports, fetching them unless an earlier
  /// visit already did.
  Future<void> onVisibleRangeChanged(DateTimeRange range) async {
    final first = DateUtils.dateOnly(range.start);
    final last = DateUtils.dateOnly(range.end);
    state = state.copyWith(firstVisibleDay: first, lastVisibleDay: last);

    final isLoaded = _loaded.any(
      (window) => !window.first.isAfter(first) && !window.last.isBefore(last),
    );
    if (isLoaded) return;

    await _load(first, last, replacing: false);
  }

  /// Forgets every window and reads the visible one again — after a write
  /// elsewhere, whose effect on the windows already held is unknown. Nothing
  /// to do while the agenda has never been opened.
  Future<void> onChangeServices() async {
    if (_loaded.isEmpty) return;
    await onRefresh();
  }

  Future<void> onRefresh() =>
      _load(state.firstVisibleDay, state.lastVisibleDay, replacing: true);

  void cancelPendingRead() {
    _readGeneration++;
    if (_readsInFlight > 0) _hasAbandonedRead = true;
  }

  Future<void> resumeAbandonedRead() async {
    if (!_hasAbandonedRead) return;
    _hasAbandonedRead = false;
    await onRefresh();
  }

  Future<void> _load(
    DateTime first,
    DateTime last, {
    required bool replacing,
  }) async {
    final generation = _readGeneration;
    _readsInFlight++;
    try {
      state = state.copyWith(status: BaseStateStatus.loading);
      final fetched = await _fetch(first, last);
      if (generation != _readGeneration) return;

      if (replacing) _loaded.clear();
      _loaded.add((first: first, last: last));
      final byId = {
        if (!replacing)
          for (final service in state.services) service.id: service,
        for (final service in fetched) service.id: service,
      };
      state = state.copyWith(
        status: BaseStateStatus.success,
        services: byId.values.toList(),
      );
    } on AppError catch (exception, trace) {
      onAppError(exception, trace);
    } catch (exception, trace) {
      unexpectedError(exception, trace);
    } finally {
      _readsInFlight--;
    }
  }

  /// The services on the days from [first] to [last], plus the ones booked
  /// earlier that run into them. See services/README.md, "Querying the
  /// agenda".
  Future<List<Service>> _fetch(DateTime first, DateTime last) async {
    final userId = _authService.user!.uid;
    final endOfLast = DateTime(last.year, last.month, last.day, 23, 59, 59);
    final endOfDayBefore = DateTime(
      first.year,
      first.month,
      first.day - 1,
      23,
      59,
      59,
    );

    final (inWindow, startedBefore, catalogItems) = await (
      _servicesRepository.get(userId, first, endOfLast),
      _servicesRepository.getMultiDay(
        userId,
        first.subtract(KaziDurationPicker.longest),
        endOfDayBefore,
      ),
      _catalogItemRepository.get(userId),
    ).wait;

    return _serviceOrganizer.addCatalogItemToServices([
      ...inWindow,
      ...startedBefore.where((service) {
        final end = service.endsAt;
        return end != null && end.isAfter(first);
      }),
    ], catalogItems);
  }

  /// Applies payment stamps already written by `ServiceStatusController`.
  /// Ids not loaded here are ignored.
  void applyReceipt(Map<String, DateTime?> stamps) => _patch(
    stamps,
    stamped: (service, at) => service.markedReceivedAt(at),
    cleared: (service) => service.notReceived(),
  );

  void applyFinish(Map<String, DateTime?> stamps) => _patch(
    stamps,
    stamped: (service, at) => service.markedFinishedAt(at),
    cleared: (service) => service.notFinished(),
  );

  void applyCancellation(Map<String, DateTime?> stamps) => _patch(
    stamps,
    stamped: (service, at) => service.markedCancelledAt(at),
    cleared: (service) => service.notCancelled(),
  );

  void _patch(
    Map<String, DateTime?> stamps, {
    required Service Function(Service service, DateTime at) stamped,
    required Service Function(Service service) cleared,
  }) {
    if (stamps.isEmpty) return;

    state = state.copyWith(
      services: [
        for (final service in state.services)
          if (!stamps.containsKey(service.id))
            service
          else if (stamps[service.id] case final DateTime at)
            stamped(service, at)
          else
            cleared(service),
      ],
    );
  }
}
