import 'package:kazi/app/views/profile/pages/profile_page.dart';
import 'package:kazi/app/views/services/services.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi_core/kazi_core.dart';

abstract final class ProfileRoutes {
  static GoRoute shellRoute() => GoRoute(
    path: AppPage.profile.route,
    builder: (_, _) => const ProfilePage(),
    routes: [...ServicesRoutes.nestedRoutes],
  );
}
