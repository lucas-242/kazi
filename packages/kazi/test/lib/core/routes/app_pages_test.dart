import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/routes/app_pages.dart';

void main() {
  group('AppPage.fromRoute', () {
    test('resolves each tab root to its own page', () {
      expect(AppPage.fromRoute('/home'), AppPage.home);
      expect(AppPage.fromRoute('/services'), AppPage.services);
      expect(AppPage.fromRoute('/clients'), AppPage.clients);
      expect(AppPage.fromRoute('/settings'), AppPage.settings);
    });

    test('prefers the most specific page over its parent', () {
      expect(AppPage.fromRoute('/services/add-services'), AppPage.addServices);
      expect(
        AppPage.fromRoute('/clients/client-details'),
        AppPage.clientDetails,
      );
      expect(AppPage.fromRoute('/clients/add-client'), AppPage.addClient);
      expect(AppPage.fromRoute('/settings/catalog'), AppPage.serviceCatalog);
      expect(
        AppPage.fromRoute('/settings/catalog/add'),
        AppPage.addCatalogItem,
      );
      expect(
        AppPage.fromRoute('/settings/catalog/details'),
        AppPage.catalogItemDetails,
      );
    });

    test('keeps sub-routes on the tab that owns them', () {
      // Clients left `/settings/*` and the catalogue moved into it: a sub-route
      // resolving to the wrong tab is what leaves the bar highlighting a
      // destination the person is not on.
      expect(AppPage.clientDetails.pageIndex, AppPage.clients.pageIndex);
      expect(AppPage.addClient.pageIndex, AppPage.clients.pageIndex);
      expect(AppPage.serviceCatalog.pageIndex, AppPage.settings.pageIndex);
      expect(AppPage.addCatalogItem.pageIndex, AppPage.settings.pageIndex);
      expect(AppPage.catalogItemDetails.pageIndex, AppPage.settings.pageIndex);
      expect(AppPage.addServices.pageIndex, AppPage.services.pageIndex);
    });

    test('ignores the query string', () {
      expect(AppPage.fromRoute('/clients?search=ana'), AppPage.clients);
    });

    test('falls back to home for an unknown location', () {
      expect(AppPage.fromRoute('/nope'), AppPage.home);
    });
  });

  group('AppPage.fromIndex', () {
    test('maps each bottom navigation index to its tab root', () {
      expect(AppPage.fromIndex(0), AppPage.home);
      expect(AppPage.fromIndex(1), AppPage.services);
      expect(AppPage.fromIndex(2), AppPage.clients);
      expect(AppPage.fromIndex(3), AppPage.settings);
    });
  });

  test('every tab index has exactly one root, in bar order', () {
    // The shell builds its branches in this order, so a gap or a duplicate here
    // silently points a tab at the wrong branch.
    final roots = [
      AppPage.home,
      AppPage.services,
      AppPage.clients,
      AppPage.settings,
    ];
    for (final (index, page) in roots.indexed) {
      expect(page.pageIndex, index, reason: '${page.name} sits on tab $index');
    }
  });
}
