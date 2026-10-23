import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/agenda/domain/models/agenda_entry.dart';
import 'package:kazi/features/agenda/presenter/widgets/agenda_event_tile.dart';
import 'package:kazi/features/services/domain/models/clock_time.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

import '../../../../../mocks/mocks.dart';
import '../../../../../utils/pump_page.dart';
import '../../../../../utils/test_helper.dart';

void main() {
  TestHelper.loadAppLocalizations();

  final day = DateTime(2026, 10, 22);

  Service booking({
    String name = 'Corte',
    DateTime? cancelledAt,
    DateTime? finishedAt,
  }) => Service(
    userId: userMock.uid,
    date: day,
    catalogItem: catalogItemMock.copyWith(name: name),
    clientName: 'Ana',
    startTime: const ClockTime(14, 0),
    duration: const Duration(hours: 1),
    cancelledAt: cancelledAt,
    finishedAt: finishedAt,
  );

  Future<void> pumpTile(
    WidgetTester tester,
    Service service, {
    required DateTime now,
    double height = 60,
    KaziAgendaMode mode = KaziAgendaMode.day,
  }) async {
    await pumpPage(
      tester,
      Scaffold(
        body: SizedBox(
          width: 200,
          height: height,
          child: AgendaEventTile(
            entry: AgendaEntry(service),
            mode: mode,
            now: now,
          ),
        ),
      ),
    );
  }

  String label(WidgetTester tester) =>
      tester.getSemantics(find.byType(AgendaEventTile)).label;

  testWidgets('an hour-long tile puts the client and the time under the item', (
    tester,
  ) async {
    await pumpTile(
      tester,
      booking(),
      now: DateTime(2026, 10, 22, 9),
      height: 56,
    );

    expect(find.text('Corte'), findsOneWidget);
    expect(find.text('Ana · 14:00–15:00'), findsOneWidget);
  });

  testWidgets('a taller tile gives the client and the time a line each', (
    tester,
  ) async {
    await pumpTile(
      tester,
      booking(),
      now: DateTime(2026, 10, 22, 9),
      height: 80,
    );

    expect(find.text('Corte'), findsOneWidget);
    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('14:00–15:00'), findsOneWidget);
  });

  testWidgets('a tall tile wraps a long name instead of dropping the rest', (
    tester,
  ) async {
    const name = 'Coloração completa com hidratação profunda';
    await pumpTile(
      tester,
      booking(name: name),
      now: DateTime(2026, 10, 22, 9),
      height: 100,
    );

    final title = tester.widget<Text>(find.text(name));
    expect(title.maxLines, greaterThan(1));
    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('14:00–15:00'), findsOneWidget);
  });

  testWidgets('a short tile keeps the client and the time on one line', (
    tester,
  ) async {
    await pumpTile(
      tester,
      booking(),
      now: DateTime(2026, 10, 22, 9),
      height: 28,
    );

    expect(find.text('Corte · Ana · 14:00–15:00'), findsOneWidget);
  });

  testWidgets('a short tile cuts a long name so the rest still shows', (
    tester,
  ) async {
    await pumpTile(
      tester,
      booking(name: 'Coloração completa'),
      now: DateTime(2026, 10, 22, 9),
      height: 28,
    );

    expect(find.text('Coloração com… · Ana · 14:00–15:00'), findsOneWidget);
  });

  testWidgets('the month view uses the one-line form', (tester) async {
    await pumpTile(
      tester,
      booking(),
      now: DateTime(2026, 10, 22, 9),
      mode: KaziAgendaMode.month,
    );

    expect(find.text('Corte · Ana · 14:00–15:00'), findsOneWidget);
  });

  testWidgets('a service past its end says it is overdue', (tester) async {
    await pumpTile(tester, booking(), now: DateTime(2026, 10, 22, 16));

    expect(label(tester), contains('overdue'));
  });

  testWidgets('a cancelled service is struck through', (tester) async {
    await pumpTile(
      tester,
      booking(cancelledAt: DateTime(2026, 10, 21)),
      now: DateTime(2026, 10, 22, 9),
    );

    final title = tester.widget<Text>(find.text('Corte'));
    expect(title.style?.decoration, TextDecoration.lineThrough);
  });

  testWidgets('a finished service carries the check', (tester) async {
    await pumpTile(
      tester,
      booking(finishedAt: DateTime(2026, 10, 22, 15)),
      now: DateTime(2026, 10, 22, 16),
    );

    expect(find.byIcon(LucideIcons.check), findsOneWidget);
    expect(label(tester), contains('finished'));
  });
}
