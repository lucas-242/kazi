import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/clients/domain/models/client_entry.dart';
import 'package:kazi/features/clients/domain/repositories/clients_repository.dart';
import 'package:kazi/features/clients/presenter/controllers/clients_controller.dart';
import 'package:kazi/features/services/presenter/controllers/catalog_controller.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_controller.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

import '../mocks/client_mocks.dart';
import '../utils/pump_app.dart';

/// Pull to refresh on the list screens, in the two states that need it most
/// and where there is nothing left on screen to drag: empty, and failed.
void main() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  const servicesIcon = Icons.format_list_bulleted;
  const clientsIcon = Icons.person_outline;

  Future<void> tapTab(WidgetTester tester, IconData icon) async {
    await tester.tap(find.byIcon(icon));
    await settle(tester);
  }

  /// Drags the empty screen down far enough to arm the indicator.
  Future<void> pullDown(WidgetTester tester, Finder scrollable) async {
    await tester.fling(scrollable, const Offset(0, 400), 1000);
    await settle(tester);
  }

  testWidgets('the empty clients tab refreshes when pulled', (tester) async {
    final app = TestAppHarness();

    await app.pump(tester);
    await tapTab(tester, clientsIcon);

    expect(find.byType(KaziEmpty), findsOneWidget);

    await app.seedClient(name: 'Ana');
    await pullDown(tester, find.byType(KaziEmpty));

    expect(app.container.read(clientsControllerProvider).clients, hasLength(1));
    expect(find.text('Ana'), findsOneWidget);
  });

  testWidgets('the empty services tab refreshes when pulled', (tester) async {
    final app = TestAppHarness();

    await app.pump(tester);
    await tapTab(tester, servicesIcon);

    // A period with nothing is a cut, not an account: the tab says so with
    // the chips still above it, never with the brand empty screen.
    expect(find.byType(KaziNoResults), findsOneWidget);
    expect(find.byType(KaziEmpty), findsNothing);

    final catalogItemId = await app.seedCatalogItem(name: 'Manicure');
    await app.seedService(
      catalogItemId: catalogItemId,
      catalogItemName: 'Manicure',
      date: today,
    );
    await pullDown(tester, find.byType(KaziNoResults));

    expect(
      app.container.read(serviceLandingControllerProvider).services,
      hasLength(1),
    );
  });

  testWidgets('the empty catalogue renders and refreshes when pulled', (
    tester,
  ) async {
    final app = TestAppHarness();

    await app.pump(tester);
    KaziNavigator.push(AppPage.serviceCatalog);
    await settle(tester);

    expect(find.byType(KaziEmpty), findsOneWidget);

    await app.seedCatalogItem(name: 'Manicure');
    await pullDown(tester, find.byType(KaziEmpty));

    expect(
      app.container.read(catalogControllerProvider).activeCatalogItems,
      hasLength(1),
    );
  });

  testWidgets('a client list that failed to load refreshes when pulled', (
    tester,
  ) async {
    final repository = _FailsOnceClientsRepository();
    final app = TestAppHarness(
      overrides: [clientsRepositoryProvider.overrideWithValue(repository)],
    );

    await app.pump(tester);
    await tapTab(tester, clientsIcon);

    expect(
      app.container.read(clientsControllerProvider).status,
      BaseStateStatus.error,
    );
    // A failed read is its own state now, with the reassurance and the retry —
    // not the empty state, which would claim the account has no clients.
    expect(find.byType(KaziError), findsOneWidget);

    await pullDown(tester, find.byType(KaziError));

    expect(app.container.read(clientsControllerProvider).clients, hasLength(1));
    expect(find.text('Ana'), findsOneWidget);
  });
}

/// Fails the first listing and serves one client from then on: the state the
/// error message replaces the list in, and what pulling it down has to recover.
class _FailsOnceClientsRepository extends Fake implements ClientsRepository {
  bool _failed = false;

  @override
  Future<List<ClientEntry>> getAllActiveClients(String ownerId) async {
    if (!_failed) {
      _failed = true;
      throw ExternalError('failed');
    }
    return [clientEntryMock(id: '1', name: 'Ana')];
  }

  @override
  Future<int> countActive(String ownerId) async => 1;

  @override
  Future<int> countArchived(String ownerId) async => 0;
}
