import 'package:kazi/app/models/service.dart';
import 'package:kazi/app/views/services/service_types/pages/service_type_form_page.dart';
import 'package:kazi/app/views/services/service_types/pages/service_types_page.dart';
import 'package:kazi/app/views/services/services.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi_core/kazi_core.dart' hide Service;

export 'service_details/service_details.dart';
export 'service_filters/service_filters.dart';
export 'service_form/service_form.dart';
export 'service_landing/service_landing.dart';
export 'widgets/info_card.dart';
export 'widgets/order_by_bottom_sheet.dart';
export 'widgets/service_list.dart';
export 'widgets/service_list_by_date.dart';
export 'widgets/service_list_content.dart';

final class ServiceArguments extends KaziNavigationArguments {
  const ServiceArguments({super.previousPage, this.service});

  final Service? service;
}

abstract final class ServicesRoutes {
  static final GoRoute addService = GoRoute(
    path: AppPage.addServices.route,
    builder: (context, state) =>
        ServiceFormPage(service: (state.extra as ServiceArguments).service),
  );

  static final GoRoute serviceDetails = GoRoute(
    path: ':serviceId',
    builder: (context, state) =>
        ServiceDetailsPage(service: (state.extra as ServiceArguments).service!),
  );

  static final GoRoute servicesType = GoRoute(
    path: AppPage.servicesType.route,
    builder: (_, _) => const ServiceTypesPage(),
    routes: [
      GoRoute(
        path: AppPage.addServiceType.route,
        builder: (_, _) => const ServiceTypeFormPage(),
      ),
    ],
  );

  static GoRoute shellRoute() => GoRoute(
    path: AppPage.services.route,
    builder: (_, _) => const ServiceLandingPage(),
    routes: [servicesType, addService, serviceDetails],
  );

  static List<RouteBase> get nestedRoutes => [addService, serviceDetails];
}
