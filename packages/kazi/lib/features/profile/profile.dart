import 'package:kazi/features/clients/clients.dart';
import 'package:kazi/features/profile/presenter/pages/profile_page.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi_core/kazi_core.dart';

abstract final class ProfileRoutes {
  static GoRoute shellRoute() => GoRoute(
    path: AppPage.profile.route,
    builder: (_, _) => const ProfilePage(),
    routes: [ClientsRoutes.route()],
  );
}
