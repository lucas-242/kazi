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

  Service booking({DateTime? cancelledAt, DateTime? finishedAt}) => Service(
    userId: userMock.uid,
    date: day,
    catalogItem: catalogItemMock.copyWith(name: 'Corte'),
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
  }) async {
    await pumpPage(
      tester,
      Scaffold(
        body: SizedBox(
          width: 200,
          height: height,
          child: AgendaEventTile(
            entry: AgendaEntry(service),
            mode: KaziAgendaMode.day,
            now: now,
          ),
        ),
      ),
    );
  }

  String label(WidgetTester tester) =>
      tester.getSemantics(find.byType(AgendaEventTile)).label;

  testWidgets('a tall tile names the item, the time and the client', (
    tester,
  ) async {
    await pumpTile(tester, booking(), now: DateTime(2026, 10, 22, 9));

    expect(find.text('Corte'), findsOneWidget);
    expect(find.text('14:00–15:00 · Ana'), findsOneWidget);
  });

  testWidgets('a short tile keeps only the item', (tester) async {
    await pumpTile(
      tester,
      booking(),
      now: DateTime(2026, 10, 22, 9),
      height: 20,
    );

    expect(find.text('Corte'), findsOneWidget);
    expect(find.textContaining('Ana'), findsNothing);
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
