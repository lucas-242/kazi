import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/agenda/presenter/controllers/agenda_controller.dart';
import 'package:kazi/features/agenda/presenter/pages/agenda_page.dart';
import 'package:kazi/features/agenda/presenter/widgets/agenda_header.dart';
import 'package:kazi/features/services/data/repositories/models/firebase_service_model.dart';
import 'package:kazi/features/services/domain/models/catalog_item.dart';
import 'package:kazi/features/services/domain/models/clock_time.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

import '../../../../../utils/fakes/fake_auth_service.dart';
import '../../../../../utils/pump_app.dart';
import '../../../../../utils/pump_page.dart';
import '../../../../../utils/test_overrides.dart';

void main() {
  final now = DateTime(2026, 10, 22, 9);
  final user = TestAppHarness.testUser;

  late TestFakes fakes;

  setUp(() {
    fakes = TestFakes(auth: FakeAuthService(user: user), now: now);
    addTearDown(fakes.dispose);
  });

  Future<void> seed(String name, {ClockTime? start, Duration? duration}) async {
    final item = await fakes.firestore
        .collection('serviceTypes')
        .add(CatalogItem(userId: user.uid, name: name).toMap());
    await fakes.firestore
        .collection('services')
        .add(
          FirebaseServiceModel(
            userId: user.uid,
            catalogItemId: item.id,
            date: DateTime(2026, 10, 22),
            value: 100,
            currency: 'USD',
            startTime: start,
            duration: duration,
          ).toMap(),
        );
  }

  /// The header's period label; the grid prints dates of its own.
  Finder period(String label) => find.descendant(
    of: find.byType(AgendaHeader),
    matching: find.text(label),
  );

  Future<ProviderContainer> pumpAgenda(WidgetTester tester) async {
    final container = await pumpPage(
      tester,
      const AgendaPage(),
      fakes: fakes,
      surfaceSize: const Size(420, 950),
    );
    await settle(tester);
    return container;
  }

  testWidgets('opens on today and draws its services, timed or not', (
    tester,
  ) async {
    await seed(
      'Corte',
      start: const ClockTime(1, 0),
      duration: const Duration(hours: 1),
    );
    await seed('Escova');

    await pumpAgenda(tester);

    expect(period('Thursday, October 22'), findsOneWidget);
    expect(find.text('Corte'), findsOneWidget);
    expect(find.text('Escova'), findsOneWidget);
  });

  testWidgets('the mode switch changes the period on screen', (tester) async {
    final container = await pumpAgenda(tester);

    await tester.tap(find.text('Month'));
    await settle(tester);

    expect(period('October 2026'), findsOneWidget);
    expect(container.read(agendaControllerProvider).mode, KaziAgendaMode.month);

    await tester.tap(find.text('Week'));
    await settle(tester);

    expect(container.read(agendaControllerProvider).mode, KaziAgendaMode.week);
    final state = container.read(agendaControllerProvider);
    expect(state.lastVisibleDay.difference(state.firstVisibleDay).inDays, 6);
  });

  testWidgets('next and today move through the months', (tester) async {
    final container = await pumpAgenda(tester);
    await tester.tap(find.text('Month'));
    await settle(tester);

    await tester.tap(find.byIcon(LucideIcons.chevronRight));
    await settle(tester);
    expect(period('November 2026'), findsOneWidget);

    await tester.tap(find.text('Today'));
    await settle(tester);
    expect(period('October 2026'), findsOneWidget);
    expect(container.read(agendaControllerProvider).mode, KaziAgendaMode.month);
  });
}
