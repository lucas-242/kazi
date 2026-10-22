import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// A service as the agenda places it. See agenda/README.md.
class AgendaEntry implements KaziAgendaEvent {
  AgendaEntry(this.service);

  final Service service;

  @override
  bool get isAllDay => service.startsAt == null;

  @override
  DateTime get start => service.startsAt ?? service.date;

  @override
  DateTime get end {
    if (isAllDay) return service.date;

    final drawnEnd = service.isCancelled
        ? service.endsAt
        : service.finishedAt ?? service.endsAt;
    if (drawnEnd == null || drawnEnd.isBefore(start)) return start;
    return drawnEnd;
  }

  /// Timed, still ahead or under way, and with no end to draw.
  bool get hasOpenEnd =>
      !isAllDay &&
      !service.isCancelled &&
      !service.isFinished &&
      service.duration == null;

  /// Whether any of the entry falls on the days from [first] to [last].
  bool fallsWithin(DateTime first, DateTime last) {
    final firstDay = DateTime(first.year, first.month, first.day);
    final dayAfterLast = DateTime(last.year, last.month, last.day + 1);

    return start.isBefore(dayAfterLast) &&
        (!start.isBefore(firstDay) || end.isAfter(firstDay));
  }
}
