import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/features/app_update/presenter/pages/forced_update_page.dart';
import 'package:kazi_core/kazi_core.dart';

export 'domain/models/app_update_info.dart';
export 'presenter/controllers/app_update_controller.dart';
export 'presenter/controllers/app_update_state.dart';
export 'presenter/widgets/optional_update_dialog.dart';

abstract final class AppUpdateRoutes {
  static List<RouteBase> get routes => [
    GoRoute(
      path: AppPage.forcedUpdate.route,
      builder: (_, _) => const ForcedUpdatePage(),
    ),
  ];
}
