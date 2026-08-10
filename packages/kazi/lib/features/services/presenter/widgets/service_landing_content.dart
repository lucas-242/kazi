import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:kazi/core/services/domain/time_service.dart';
import 'package:kazi/features/services/domain/services/services_service.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_state.dart';
import 'package:kazi/features/services/presenter/widgets/service_info_list.dart';
import 'package:kazi/features/services/presenter/widgets/service_list.dart';
import 'package:kazi/features/services/presenter/widgets/service_list_by_date.dart';
import 'package:kazi/features/services/presenter/widgets/service_navbar.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
import 'package:kazi_core/kazi_core.dart';

class ServiceLandingContent extends ConsumerWidget {
  const ServiceLandingContent({
    super.key,
    required this.dateKey,
    required this.dateController,
    required this.state,
  });
  final ServiceLandingState state;
  final GlobalKey<FormFieldState> dateKey;
  final MaskedTextController dateController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesService = ref.watch(servicesServiceProvider);
    final timeService = ref.watch(timeServiceProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        KaziSpacings.verticalLg,
        ServiceNavbar(dateKey: dateKey, dateController: dateController),
        KaziSpacings.verticalSm,
        ServiceInfoList(totals: state.totals),
        KaziSpacings.verticalSm,
        _ServiceList(
          state: state,
          servicesService: servicesService,
          timeService: timeService,
        ),
      ],
    );
  }
}

class _ServiceList extends StatelessWidget {
  const _ServiceList({
    required this.state,
    required this.servicesService,
    required this.timeService,
  });

  final ServiceLandingState state;
  final ServicesService servicesService;
  final TimeService timeService;

  @override
  Widget build(BuildContext context) {
    if (_showLastMonthServices(timeService)) {
      return ServiceList(
        title: KaziLocalizations.current.filteringLastMonth,
        services: state.services,
      );
    }
    if (_showServicesAreNotInCurrentMonth(timeService)) {
      return ServiceList(
        title: KaziLocalizations.current.fromTo(
          DateFormat.yMd().format(state.startDate).normalizeDate(),
          DateFormat.yMd().format(state.endDate).normalizeDate(),
        ),
        services: state.services,
      );
    }

    return ServiceListByDate(
      servicesByDateList: servicesService.groupServicesByDate(
        state.services,
        state.selectedOrderBy,
      ),
    );
  }

  bool _showLastMonthServices(TimeService timeService) =>
      state.fastSearch == FastSearch.lastMonth ||
      timeService.isRangeInLastMonth(state.startDate, state.endDate);

  bool _showServicesAreNotInCurrentMonth(TimeService timeService) =>
      !timeService.isRangeInThisMonth(state.startDate, state.endDate);
}
