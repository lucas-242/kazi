import 'package:kazi/features/services/domain/services/service_organizer.dart';
import 'package:kazi/features/settings/presenter/controllers/billing_cycle_controller.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart';

import 'service_filters_state.dart';

part 'service_filters_controller.g.dart';

@riverpod
class ServiceFiltersController extends _$ServiceFiltersController {
  ServiceOrganizer get _serviceOrganizer => ref.read(serviceOrganizerProvider);

  @override
  ServiceFiltersState build({
    required DateTime startDate,
    required DateTime endDate,
    required FastSearch fastSearch,
  }) => ServiceFiltersState(
    startDate: startDate,
    endDate: endDate,
    fastSearch: fastSearch,
  );

  void onChangeDate(DateTime startDate, DateTime endDate) {
    final finalEndDate = endDate.lastHourOfDay;
    state = ServiceFiltersState(
      startDate: startDate,
      endDate: finalEndDate,
      fastSearch: FastSearch.custom,
    );
  }

  void onChangeFastSearch(FastSearch fastSearch) {
    final range = _serviceOrganizer.getRangeDateByFastSearch(fastSearch);
    state = ServiceFiltersState(
      startDate: range['startDate']!,
      endDate: range['endDate']!,
      fastSearch: fastSearch,
    );
  }

  /// Narrows the list to the window the home reports on.
  ///
  /// This is the path that makes "the salon paid the cycle" two taps: filter to
  /// the cycle, then mark what is listed as received. Without it the only way
  /// to see exactly the cycle would be to retype its dates by hand, since
  /// `FastSearch.fortnight` means the 1st–15th and disagrees with a fortnightly
  /// cycle anchored anywhere else.
  ///
  /// Awaits [billingCycleControllerProvider] rather than reading
  /// [billingCycleProvider]'s synchronous fallback, which would resolve the
  /// calendar month on a cold start and then correct itself — the same flash
  /// of the wrong window the dashboard avoids for the same reason.
  Future<void> onSelectCurrentCycle() async {
    final cycle = await ref.read(billingCycleControllerProvider.future);
    final range = cycle.currentCycle(_serviceOrganizer.now);

    state = ServiceFiltersState(
      startDate: range.start,
      endDate: range.end,
      fastSearch: FastSearch.custom,
      isCurrentCycle: true,
    );
  }
}
