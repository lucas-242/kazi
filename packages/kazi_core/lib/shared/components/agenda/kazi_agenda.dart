import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

/// The three ways [KaziAgenda] lays time out.
enum KaziAgendaMode {
  day(CalendarView.day),
  week(CalendarView.week),
  month(CalendarView.month);

  const KaziAgendaMode(this._view);

  final CalendarView _view;
}

/// Something [KaziAgenda] can place on its grid.
///
/// [end] must not be before [start]. An [isAllDay] event is drawn in the strip
/// above the hours, on every day from [start] to [end].
abstract interface class KaziAgendaEvent {
  DateTime get start;
  DateTime get end;
  bool get isAllDay;
}

/// Drives a [KaziAgenda] from outside: which mode it shows and which dates.
///
/// Owned by the caller, who must [dispose] it.
class KaziAgendaController {
  KaziAgendaController({
    KaziAgendaMode mode = KaziAgendaMode.day,
    DateTime? displayDate,
  }) : _calendar = CalendarController()
         ..view = mode._view
         ..displayDate = displayDate ?? DateTime.now();

  final CalendarController _calendar;

  KaziAgendaMode get mode => KaziAgendaMode.values.firstWhere(
    (mode) => mode._view == _calendar.view,
    orElse: () => KaziAgendaMode.day,
  );

  set mode(KaziAgendaMode mode) => _calendar.view = mode._view;

  /// Moves the agenda to the period containing [date].
  void show(DateTime date) => _calendar.displayDate = date;

  void today() => show(DateTime.now());

  /// The next day, week or month, depending on [mode].
  void forward() => _calendar.forward?.call();

  void backward() => _calendar.backward?.call();

  void dispose() => _calendar.dispose();
}

/// A calendar of [events] by day (with its hours), week or month, painted
/// with the design system.
///
/// It has no header of its own — the screen owns the title and the mode
/// switch, driving it through [controller] — and nothing on it can be dragged
/// or resized. Taps on empty time slots do nothing.
class KaziAgenda<T extends KaziAgendaEvent> extends StatefulWidget {
  const KaziAgenda({
    super.key,
    required this.controller,
    required this.events,
    required this.eventBuilder,
    this.onEventTap,
    this.onDayTap,
    this.onVisibleRangeChanged,
  });

  final KaziAgendaController controller;
  final List<T> events;

  /// Draws one event inside the bounds the grid gives it, which in the month
  /// and week modes can be a few pixels tall.
  final Widget Function(BuildContext context, T event, KaziAgendaMode mode)
  eventBuilder;

  final ValueChanged<T>? onEventTap;

  /// A day picked as a whole: its cell in the month, its header in the week,
  /// or the "+N" of a month cell that cannot fit every event.
  final ValueChanged<DateTime>? onDayTap;

  /// The first and last dates on screen, at midnight. Called after the frame,
  /// so the listener may write to state.
  final ValueChanged<DateTimeRange>? onVisibleRangeChanged;

  @override
  State<KaziAgenda<T>> createState() => _KaziAgendaState<T>();
}

class _KaziAgendaState<T extends KaziAgendaEvent>
    extends State<KaziAgenda<T>> {
  static const _hourHeight = 56.0;

  /// Keeps a five-minute booking tall enough to read and to tap.
  static const _shortestDrawn = Duration(minutes: 30);

  late _EventDataSource<T> _dataSource = _EventDataSource(widget.events);

  @override
  void didUpdateWidget(KaziAgenda<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.events, widget.events)) {
      _dataSource = _EventDataSource(widget.events);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final firstDayIndex = MaterialLocalizations.of(context).firstDayOfWeekIndex;

    return SfCalendar(
      controller: widget.controller._calendar,
      view: widget.controller.mode._view,
      dataSource: _dataSource,
      headerHeight: 0,
      // Syncfusion counts Monday as 1 and Sunday as 7; Material, Sunday as 0.
      firstDayOfWeek: firstDayIndex == 0 ? DateTime.sunday : firstDayIndex,
      backgroundColor: colors.background,
      cellBorderColor: colors.border,
      todayHighlightColor: colors.inverse,
      todayTextStyle: KaziTextStyles.titleMedium.copyWith(
        color: colors.onInverse,
      ),
      selectionDecoration: const BoxDecoration(),
      viewHeaderStyle: ViewHeaderStyle(
        backgroundColor: colors.background,
        dayTextStyle: KaziTextStyles.labelSmall.copyWith(
          color: colors.textMuted,
        ),
        dateTextStyle: KaziTextStyles.titleMedium.copyWith(color: colors.text),
      ),
      timeSlotViewSettings: TimeSlotViewSettings(
        timeFormat: 'HH:mm',
        dayFormat: 'EEE',
        timeIntervalHeight: _hourHeight,
        minimumAppointmentDuration: _shortestDrawn,
        nonWorkingDays: const [],
        allDayPanelColor: colors.surfaceMuted,
        timeTextStyle: KaziTextStyles.labelSmall.copyWith(
          color: colors.textMuted,
        ),
      ),
      monthViewSettings: MonthViewSettings(
        appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
        dayFormat: 'EEE',
        monthCellStyle: MonthCellStyle(
          backgroundColor: colors.background,
          leadingDatesBackgroundColor: colors.background,
          trailingDatesBackgroundColor: colors.background,
          textStyle: KaziTextStyles.labelMedium.copyWith(color: colors.text),
          leadingDatesTextStyle: KaziTextStyles.labelMedium.copyWith(
            color: colors.textMuted,
          ),
          trailingDatesTextStyle: KaziTextStyles.labelMedium.copyWith(
            color: colors.textMuted,
          ),
        ),
      ),
      appointmentBuilder: _buildAppointment,
      onTap: _onTap,
      onViewChanged: _onViewChanged,
    );
  }

  Widget _buildAppointment(
    BuildContext context,
    CalendarAppointmentDetails details,
  ) {
    if (details.isMoreAppointmentRegion) {
      return _MoreEvents(count: details.appointments.length);
    }
    return widget.eventBuilder(
      context,
      details.appointments.first as T,
      widget.controller.mode,
    );
  }

  void _onTap(CalendarTapDetails details) {
    final date = details.date;
    final isMonth = widget.controller.mode == KaziAgendaMode.month;

    switch (details.targetElement) {
      case CalendarElement.appointment:
        final tapped = details.appointments?.firstOrNull;
        if (tapped is T) widget.onEventTap?.call(tapped);
      case CalendarElement.moreAppointmentRegion:
      case CalendarElement.viewHeader:
        if (date != null) widget.onDayTap?.call(date);
      case CalendarElement.calendarCell when isMonth:
        if (date != null) widget.onDayTap?.call(date);
      default:
    }
  }

  // Syncfusion calls this while it builds; a listener writing to state from
  // here would mark a widget dirty mid-build.
  void _onViewChanged(ViewChangedDetails details) {
    final dates = details.visibleDates;
    if (dates.isEmpty) return;
    final range = DateTimeRange(start: dates.first, end: dates.last);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onVisibleRangeChanged?.call(range);
    });
  }
}

class _MoreEvents extends StatelessWidget {
  const _MoreEvents({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: KaziInsets.xxs),
        child: Text(
          '+$count',
          maxLines: 1,
          style: KaziTextStyles.labelSmall.copyWith(
            color: context.colors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _EventDataSource<T extends KaziAgendaEvent>
    extends CalendarDataSource<T> {
  _EventDataSource(List<T> events) {
    appointments = events;
  }

  T _at(int index) => appointments![index] as T;

  @override
  DateTime getStartTime(int index) => _at(index).start;

  @override
  DateTime getEndTime(int index) => _at(index).end;

  @override
  bool isAllDay(int index) => _at(index).isAllDay;

  // Drawn by the builder; Syncfusion only paints this colour when no builder
  // is given.
  @override
  Color getColor(int index) => Colors.transparent;
}
