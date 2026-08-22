import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/features/clients/presenter/controllers/client_details_controller.dart';
import 'package:kazi/features/clients/presenter/controllers/clients_controller.dart';
import 'package:kazi/features/clients/presenter/pages/client_details_page.dart';
import 'package:kazi/features/clients/presenter/pages/client_form_page.dart';
import 'package:kazi/features/clients/presenter/pages/clients_page.dart';
import 'package:kazi/features/subscription/domain/freemium_limits.dart';
import 'package:kazi/features/subscription/domain/models/user_tier.dart';
import 'package:kazi/features/subscription/presenter/widgets/paywall_view.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

import '../utils/pump_app.dart';

/// The clients tab end to end: list, create, open, delete.
void main() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  Future<void> openTheTab(WidgetTester tester, TestAppHarness app) async {
    await tester.tap(find.byIcon(Icons.person_outline));
    await settle(tester);
  }

  Future<void> openTheForm(WidgetTester tester, TestAppHarness app) async {
    await openTheTab(tester, app);
    await tester.tap(find.byType(FloatingActionButton));
    await settle(tester);
  }

  /// Types into the form's four text fields, in the order they are laid out:
  /// CPF/CNPJ, name, phone, e-mail.
  Future<void> fillForm(
    WidgetTester tester, {
    String identifier = '12345678900',
    required String name,
    String phone = '11999999999',
    String email = 'ana@test.com',
  }) async {
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), identifier);
    await tester.enterText(fields.at(1), name);
    await tester.enterText(fields.at(2), phone);
    await tester.enterText(fields.at(3), email);
    await settle(tester);
  }

  Future<void> save(WidgetTester tester) async {
    await tester.tap(find.text(KaziLocalizations.current.save));
    await settle(tester);
  }

  testWidgets('the tab lists the clients already stored', (tester) async {
    final app = TestAppHarness();
    await app.seedClient(name: 'Ana');
    await app.seedClient(name: 'Bruna');

    await app.pump(tester);
    await openTheTab(tester, app);

    expect(app.location, AppPage.clients.route);
    expect(find.byType(ClientsPage), findsOneWidget);
    expect(app.container.read(clientsControllerProvider).clients, hasLength(2));
    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('Bruna'), findsOneWidget);
  });

  testWidgets('an empty tab says so', (tester) async {
    final app = TestAppHarness();

    await app.pump(tester);
    await openTheTab(tester, app);

    expect(find.byType(KaziNoData), findsOneWidget);
  });

  testWidgets('the FAB opens the client form', (tester) async {
    final app = TestAppHarness();

    await app.pump(tester);
    await openTheForm(tester, app);

    expect(app.location, AppPage.addClient.route);
    expect(find.byType(ClientFormPage), findsOneWidget);
  });

  testWidgets('creating a client writes it and shows it in the list', (
    tester,
  ) async {
    final app = TestAppHarness();

    await app.pump(tester);
    await openTheForm(tester, app);
    await fillForm(tester, name: 'Ana');
    await save(tester);

    final written = await app.firestore.collection('clients').get();
    expect(written.docs, hasLength(1));
    expect(written.docs.single.data()['name'], 'Ana');
    expect(written.docs.single.data()['ownerId'], TestAppHarness.testUser.uid);

    expect(app.location, AppPage.clients.route);
    expect(
      app.container
          .read(clientsControllerProvider)
          .clients
          .single
          .info
          .user
          .name,
      'Ana',
    );
  });

  testWidgets('a client with no name is refused and nothing is written', (
    tester,
  ) async {
    final app = TestAppHarness();

    await app.pump(tester);
    await openTheForm(tester, app);
    await fillForm(tester, name: '');
    await save(tester);

    final written = await app.firestore.collection('clients').get();
    expect(written.docs, isEmpty);
    expect(app.location, AppPage.addClient.route);
  });

  testWidgets('opening a client shows its details and service history', (
    tester,
  ) async {
    final app = TestAppHarness();
    final clientId = await app.seedClient(name: 'Ana');
    final catalogItemId = await app.seedCatalogItem(name: 'Manicure');
    await app.seedService(
      catalogItemId: catalogItemId,
      catalogItemName: 'Manicure',
      date: today,
      clientId: clientId,
      clientName: 'Ana',
    );

    await app.pump(tester);
    await openTheTab(tester, app);
    await tester.tap(find.text('Ana'));
    await settle(tester);

    expect(app.location, AppPage.clientDetails.route);
    expect(find.byType(ClientDetailsPage), findsOneWidget);

    final details = app.container.read(
      clientDetailsControllerProvider(clientId: clientId),
    );
    expect(details.client?.info.user.name, 'Ana');
    expect(details.serviceHistory, hasLength(1));
    expect(details.serviceHistory.single.serviceName, 'Manicure');
  });

  testWidgets('deleting a client drops it from the list', (tester) async {
    final app = TestAppHarness();
    await app.seedClient(name: 'Ana');
    await app.seedClient(name: 'Bruna');

    await app.pump(tester);
    await openTheTab(tester, app);

    await tester.longPress(find.text('Ana'));
    await settle(tester);
    await tester.tap(find.text(KaziLocalizations.current.delete).last);
    await settle(tester);

    expect(app.container.read(clientsControllerProvider).clients, hasLength(1));
    expect(find.text('Ana'), findsNothing);
    expect(find.text('Bruna'), findsOneWidget);
  });

  testWidgets('a deleted client keeps its document, deactivated', (
    tester,
  ) async {
    // The service history still points at it, so the document survives with
    // every personal field wiped.
    final app = TestAppHarness();
    await app.seedClient(name: 'Ana');

    await app.pump(tester);
    await openTheTab(tester, app);
    await tester.longPress(find.text('Ana'));
    await settle(tester);
    await tester.tap(find.text(KaziLocalizations.current.delete).last);
    await settle(tester);

    final stored = await app.firestore.collection('clients').get();
    expect(stored.docs, hasLength(1));
    expect(stored.docs.single.data()['active'], isFalse);
    expect(stored.docs.single.data()['name'], '');
  });

  testWidgets('a free user at the client limit gets the paywall', (
    tester,
  ) async {
    final app = TestAppHarness(isPremium: false);
    final limit = FreemiumLimits.forTier(UserTier.newFree).maxClients;
    for (var index = 0; index < limit; index++) {
      await app.seedClient(name: 'Client $index');
    }

    await app.pump(tester);
    await openTheForm(tester, app);
    await fillForm(tester, name: 'One too many');
    await save(tester);

    expect(find.byType(PaywallView), findsOneWidget);
    final written = await app.firestore.collection('clients').get();
    expect(written.docs, hasLength(limit));
  });
}
