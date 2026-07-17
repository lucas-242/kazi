import 'package:kazi/features/services/domain/services/services_service.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart';

import 'service_filters_state.dart';

part 'service_filters_controller.g.dart';

@riverpod
class ServiceFiltersController extends _$ServiceFiltersController {
  ServicesService get _servicesService => ref.read(servicesServiceProvider);

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
      didFiltersChange: true,
    );
  }

  void onChangeFastSearch(FastSearch fastSearch) {
    final range = _servicesService.getRangeDateByFastSearch(fastSearch);
    state = ServiceFiltersState(
      startDate: range['startDate']!,
      endDate: range['endDate']!,
      fastSearch: fastSearch,
      didFiltersChange: true,
    );
  }
}
