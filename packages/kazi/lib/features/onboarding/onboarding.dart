import 'package:kazi/features/onboarding/presenter/pages/onboarding_page.dart';
import 'package:kazi/features/onboarding/presenter/pages/splash_page.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi_core/kazi_core.dart';

abstract final class OnboardingRoutes {
  static List<RouteBase> get routes => [
    GoRoute(path: AppPage.initial.route, builder: (_, _) => const SplashPage()),
    GoRoute(
      path: AppPage.onboarding.route,
      builder: (_, _) => const OnboardingPage(),
    ),
  ];
}
