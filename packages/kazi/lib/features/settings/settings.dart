import 'package:kazi/features/clients/clients.dart';
import 'package:kazi/features/settings/presenter/pages/settings_page.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi_core/kazi_core.dart';

abstract final class SettingsRoutes {
  static GoRoute shellRoute() => GoRoute(
    path: AppPage.settings.route,
    builder: (_, _) => const SettingsPage(),
    routes: [ClientsRoutes.route()],
  );
}
