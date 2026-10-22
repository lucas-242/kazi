import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi_core/kazi_core.dart';

class _Event implements KaziAgendaEvent {
  _Event(this.title, this.start, this.end, {this.isAllDay = false});

  final String title;

  @override
  final DateTime start;

  @override
  final DateTime end;

  @override
  final bool isAllDay;
}

void main() {
  setUpAll(() => KaziLocalizations.load(const Locale('en')));

  final today = DateUtils.dateOnly(DateTime.now());

  Future<void> pumpAgenda(
    WidgetTester tester, {
    required KaziAgendaController controller,
    required List<_Event> events,
    ValueChanged<_Event>? onEventTap,
    ValueChanged<DateTimeRange>? onVisibleRangeChanged,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: KaziThemeSettings.light(),
        home: Scaffold(
          body: KaziAgenda<_Event>(
            controller: controller,
            events: events,
            eventBuilder: (context, event, mode) => Text(event.title),
            onEventTap: onEventTap,
            onVisibleRangeChanged: onVisibleRangeChanged,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('draws the events of the day and reports a tap on one', (
    tester,
  ) async {
    final controller = KaziAgendaController(displayDate: today);
    addTearDown(controller.dispose);
    final tapped = <_Event>[];
    final haircut = _Event(
      'Haircut',
      today.add(const Duration(hours: 2)),
      today.add(const Duration(hours: 3)),
    );

    await pumpAgenda(
      tester,
      controller: controller,
      events: [haircut],
      onEventTap: tapped.add,
    );
    await tester.tap(find.text('Haircut'));
    await tester.pump();

    expect(tapped, [haircut]);
  });

  testWidgets('draws an all-day event above the hours', (tester) async {
    final controller = KaziAgendaController(displayDate: today);
    addTearDown(controller.dispose);

    await pumpAgenda(
      tester,
      controller: controller,
      events: [_Event('Untimed', today, today, isAllDay: true)],
    );

    expect(find.text('Untimed'), findsOneWidget);
  });

  testWidgets('reports the dates on screen, and again on a mode change', (
    tester,
  ) async {
    final controller = KaziAgendaController(displayDate: today);
    addTearDown(controller.dispose);
    final ranges = <DateTimeRange>[];

    await pumpAgenda(
      tester,
      controller: controller,
      events: const [],
      onVisibleRangeChanged: ranges.add,
    );
    expect(ranges.last, DateTimeRange(start: today, end: today));

    controller.mode = KaziAgendaMode.week;
    await tester.pump();
    await tester.pump();

    expect(controller.mode, KaziAgendaMode.week);
    expect(ranges.last.duration, const Duration(days: 6));
    expect(ranges.last.start.isAfter(today), isFalse);
    expect(ranges.last.end.isBefore(today), isFalse);
  });
}
