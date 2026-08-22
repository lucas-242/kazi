import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:kazi/core/services/domain/time_service.dart';
import 'package:kazi/features/services/domain/models/service_view.dart';
import 'package:kazi/features/services/domain/services/service_organizer.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_state.dart';
import 'package:kazi/features/services/presenter/widgets/service_filter_chips.dart';
import 'package:kazi/features/services/presenter/widgets/service_list.dart';
import 'package:kazi/features/services/presenter/widgets/service_list_by_date.dart';
import 'package:kazi/features/services/presenter/widgets/service_navbar.dart';
import 'package:kazi/features/services/presenter/widgets/service_summary_content.dart';
import 'package:kazi/features/services/presenter/widgets/service_view_switch.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;
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
    final serviceOrganizer = ref.watch(serviceOrganizerProvider);
    final timeService = ref.watch(timeServiceProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ServiceNavbar(dateKey: dateKey, dateController: dateController),
        KaziSpacings.verticalMd,
        const ServiceViewSwitch(),
        KaziSpacings.verticalXs,
        ServiceFilterChips(dateKey: dateKey, dateController: dateController),
        KaziSpacings.verticalSm,
        // The chips stay above whatever this resolves to, so a filter that
        // empties the screen can always be undone from where it was set.
        if (state.isFilteredEmpty)
          const _FilteredEmpty()
        else if (state.view == ServiceView.summary)
          ServiceSummaryContent(state: state)
        else
          _ServiceList(
            state: state,
            serviceOrganizer: serviceOrganizer,
            timeService: timeService,
          ),
      ],
    );
  }
}

/// Shown when the period has services but the chips hide all of them.
///
/// Inline rather than the full empty screen: the empty screen replaces the
/// header and the chips, which is exactly what the user needs to reach.
class _FilteredEmpty extends StatelessWidget {
  const _FilteredEmpty();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: KaziInsets.xLg),
      child: Text(
        KaziLocalizations.current.noServicesForFilters,
        style: KaziTextStyles.bodyMedium.copyWith(
          fontSize: 15,
          height: 24 / 15,
          color: context.colors.textMuted,
        ),
      ),
    );
  }
}

class _ServiceList extends StatelessWidget {
  const _ServiceList({
    required this.state,
    required this.serviceOrganizer,
    required this.timeService,
  });

  final ServiceLandingState state;
  final ServiceOrganizer serviceOrganizer;
  final TimeService timeService;

  @override
  Widget build(BuildContext context) {
    // Everything below lists what the chips left standing, so the rows and the
    // totals in the summary always describe the same set of services.
    final services = state.visibleServices;

    if (_showLastMonthServices(timeService)) {
      return ServiceList(
        title: KaziLocalizations.current.filteringLastMonth,
        services: services,
      );
    }
    if (_showServicesAreNotInCurrentMonth(timeService)) {
      return ServiceList(
        title: KaziLocalizations.current.fromTo(
          DateFormat.yMd().format(state.startDate).normalizeDate(),
          DateFormat.yMd().format(state.endDate).normalizeDate(),
        ),
        services: services,
      );
    }

    return ServiceListByDate(
      servicesByDateList: serviceOrganizer.groupServicesByDate(
        services,
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
