import 'package:kazi_core/kazi_core.dart';

enum AppPage implements KaziPage {
  initial('/', -1),
  login('/login', -1),
  forcedUpdate('/forced-update', -1),
  onboarding('/onboarding', -1),
  home('/home', 0),
  services('/services', 1),
  serviceDetails('/services/service-details', 1),
  addServices('/services/add-services', 1),
  servicesType('/services/services-type', 1),
  addServiceType('/services/services-type/add-service-type', 1),
  settings('/settings', 2),
  clients('/settings/clients', 2),
  clientDetails('/settings/clients/client-details', 2),
  addClient('/settings/clients/add-client', 2);

  const AppPage(this.route, this.pageIndex);

  /// Full, absolute location used to navigate to this page. Sub-routes keep
  /// their parent prefix so `go`/`push` resolve against the real route tree.
  @override
  final String route;

  /// Index of the bottom navigation tab this page belongs to (`-1` when the
  /// page is not part of the tab bar).
  @override
  final int pageIndex;

  /// Resolves the page owning [route] by longest matching prefix, so nested
  /// locations (e.g. `/services/add-services`) map to the most specific page.
  static AppPage fromRoute(String route) {
    final path = route.split('?').first;
    AppPage? best;
    for (final page in values) {
      final candidate = page.route;
      final matches = candidate == '/'
          ? path == '/'
          : path == candidate || path.startsWith('$candidate/');
      if (matches && (best == null || candidate.length > best.route.length)) {
        best = page;
      }
    }
    return best ?? home;
  }

  /// Resolves the first page belonging to the given bottom navigation tab.
  static AppPage fromIndex(int index) {
    return values.firstWhere((e) => e.pageIndex == index, orElse: () => home);
  }
}
