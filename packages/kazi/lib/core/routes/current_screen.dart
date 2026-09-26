import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// The page the person is looking at, or null while the router has no match.
///
/// Read from `GoRouter.state`, never from `routerDelegate.currentConfiguration`:
/// the latter reports the last *declarative* match, so every full-screen route
/// pushed onto the root navigator answers with the tab underneath it.
///
/// Takes a factory so it serves both a `Ref` and a `WidgetRef`, and answers
/// null rather than throwing — a controller under test has no router.
AppPage? currentAppPage(GoRouter Function() router) {
  try {
    return AppPage.fromRoute(router().state.uri.path);
  } catch (_) {
    return null;
  }
}

/// [currentAppPage] as an analytics-safe screen name.
String currentScreenName(GoRouter Function() router) =>
    currentAppPage(router)?.name ?? 'unknown';
