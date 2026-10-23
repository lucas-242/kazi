import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/agenda/domain/models/agenda_entry.dart';
import 'package:kazi/features/agenda/presenter/controllers/agenda_controller.dart';
import 'package:kazi/features/agenda/presenter/pages/agenda_page.dart';
import 'package:kazi/features/agenda/presenter/widgets/agenda_header.dart';
import 'package:kazi/features/services/data/repositories/firebase_services_repository.dart';
import 'package:kazi/features/services/data/repositories/models/firebase_service_model.dart';
import 'package:kazi/features/services/domain/models/catalog_item.dart';
import 'package:kazi/features/services/domain/errors/services_error.dart';
import 'package:kazi/features/services/domain/models/clock_time.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/injector.dart';
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
    fakes = TestFakes(
      auth: FakeAuthService(user: user),
      now: now,
    );
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

  testWidgets('a failed read replaces the whole agenda until a retry lands', (
    tester,
  ) async {
    await seed('Escova');
    final repository = _FailingLookback(fakes);

    await pumpPage(
      tester,
      const AgendaPage(),
      fakes: fakes,
      surfaceSize: const Size(420, 950),
      overrides: [servicesRepositoryProvider.overrideWithValue(repository)],
    );
    await settle(tester);

    expect(find.byType(KaziError), findsOneWidget);
    expect(find.byType(AgendaHeader), findsNothing);
    expect(find.byType(KaziAgenda<AgendaEntry>), findsNothing);

    repository.fails = false;
    await tester.tap(find.text(KaziLocalizations.current.tryAgain));
    await settle(tester);

    expect(find.byType(KaziError), findsNothing);
    expect(find.byType(AgendaHeader), findsOneWidget);
    expect(find.text('Escova'), findsOneWidget);
  });
}

class _FailingLookback extends FirebaseServicesRepository {
  _FailingLookback(TestFakes fakes)
    : super(fakes.firestore, fakes.crashlytics, fakes.time);

  bool fails = true;

  @override
  Future<List<Service>> getMultiDay(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (fails) throw ServicesError(ServicesFailure.load);
    return super.getMultiDay(userId, startDate, endDate);
  }
}
