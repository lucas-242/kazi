import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

/// The page the person is looking at, as an [AppPage] name.
///
/// Read from `GoRouter.state`, never from `routerDelegate.currentConfiguration`:
/// the latter reports the last *declarative* match, so every full-screen route
/// pushed onto the root navigator answers with the tab underneath it.
///
/// Takes a factory so it serves both a `Ref` and a `WidgetRef`, and answers
/// `'unknown'` rather than throwing — a controller under test has no router.
String currentScreenName(GoRouter Function() router) {
  try {
    return AppPage.fromRoute(router().state.uri.path).name;
  } catch (_) {
    return 'unknown';
  }
}
