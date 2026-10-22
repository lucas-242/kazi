import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/features/agenda/presenter/pages/agenda_page.dart';
import 'package:kazi_core/kazi_core.dart';

export 'presenter/pages/agenda_page.dart';

abstract final class AgendaRoutes {
  static GoRoute shellRoute() => GoRoute(
    path: AppPage.agenda.route,
    builder: (_, _) => const AgendaPage(),
  );
}
