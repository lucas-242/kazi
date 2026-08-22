import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/features/clients/presenter/pages/clients_page.dart';
import 'package:kazi/features/dashboard/presenter/pages/fast_dashboard_page.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_controller.dart';
import 'package:kazi/features/services/presenter/pages/service_landing_page.dart';
import 'package:kazi/features/settings/presenter/pages/settings_page.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

import '../utils/pump_app.dart';

/// The four bottom-navigation branches.
///
/// They sit in a `StatefulShellRoute.indexedStack` precisely so the three tabs
/// nobody is looking at stay alive — leaving a tab and coming back must not
/// reset its filters or reload its list.
void main() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  const homeIcon = Icons.home_outlined;
  const servicesIcon = Icons.format_list_bulleted;
  const clientsIcon = Icons.person_outline;
  const menuIcon = Icons.tune;

  Future<void> tapTab(WidgetTester tester, IconData icon) async {
    await tester.tap(find.byIcon(icon));
    await settle(tester);
  }

  Future<TestAppHarness> pumpWithData(WidgetTester tester) async {
    final app = TestAppHarness();
    final typeId = await app.seedServiceType(name: 'Manicure');
    await app.seedService(typeId: typeId, typeName: 'Manicure', date: today);
    await app.seedClient(name: 'Ana');
    await app.pump(tester);
    return app;
  }

  testWidgets('every tab reaches its own screen', (tester) async {
    final app = await pumpWithData(tester);

    expect(app.location, AppPage.home.route);
    expect(find.byType(FastDashboardPage), findsOneWidget);

    await tapTab(tester, servicesIcon);
    expect(app.location, AppPage.services.route);
    expect(find.byType(ServiceLandingPage), findsOneWidget);

    await tapTab(tester, clientsIcon);
    expect(app.location, AppPage.clients.route);
    expect(find.byType(ClientsPage), findsOneWidget);

    await tapTab(tester, menuIcon);
    expect(app.location, AppPage.settings.route);
    expect(find.byType(SettingsPage), findsOneWidget);

    await tapTab(tester, homeIcon);
    expect(app.location, AppPage.home.route);
  });

  testWidgets('leaving and returning keeps the services filters', (
    tester,
  ) async {
    final app = await pumpWithData(tester);

    await tapTab(tester, servicesIcon);
    app.container
        .read(serviceLandingControllerProvider.notifier)
        .onChangeOrderBy(OrderBy.valueDesc);
    await settle(tester);

    await tapTab(tester, clientsIcon);
    await tapTab(tester, servicesIcon);

    expect(
      app.container.read(serviceLandingControllerProvider).selectedOrderBy,
      OrderBy.valueDesc,
    );
  });

  testWidgets('the loaded lists are not thrown away on a tab change', (
    tester,
  ) async {
    final app = await pumpWithData(tester);

    await tapTab(tester, servicesIcon);
    expect(
      app.container.read(serviceLandingControllerProvider).services,
      hasLength(1),
    );

    await tapTab(tester, menuIcon);
    await tapTab(tester, servicesIcon);

    expect(
      app.container.read(serviceLandingControllerProvider).services,
      hasLength(1),
    );
  });

  testWidgets('the creation button follows the tab', (tester) async {
    final app = await pumpWithData(tester);

    // Every tab but clients creates a service; clients creates a client.
    expect(find.byType(FloatingActionButton), findsOneWidget);

    await tapTab(tester, clientsIcon);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    await tester.tap(find.byType(FloatingActionButton));
    await settle(tester);
    expect(app.location, AppPage.addClient.route);
  });

  testWidgets('the menu keeps the creation button', (tester) async {
    final app = await pumpWithData(tester);

    await tapTab(tester, menuIcon);

    expect(find.byType(FloatingActionButton), findsOneWidget);
    await tester.tap(find.byType(FloatingActionButton));
    await settle(tester);
    expect(app.location, AppPage.addServices.route);
  });
}
