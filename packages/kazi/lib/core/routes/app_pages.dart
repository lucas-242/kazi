import 'package:kazi_core/kazi_core.dart';

enum AppPage implements KaziPage {
  initial('/', -1),
  onboarding('/onboarding', 0),
  home('/home', 1),
  services('/services', 2),
  serviceDetails('/service-details', 3),
  profile('/profile', 6),
  addServices('/add-services', 7),
  servicesType('/services-type', 7),
  addServiceType('/add-service-type', 8),
  login('/login', 11);

  const AppPage(this.route, this.pageIndex);

  @override
  final String route;

  @override
  final int pageIndex;

  static AppPage fromRoute(String route) {
    return values.firstWhere(
      (e) => route.startsWith(e.route),
      orElse: () => home,
    );
  }

  static AppPage fromIndex(int index) {
    return values.firstWhere((e) => e.index == index, orElse: () => home);
  }
}
