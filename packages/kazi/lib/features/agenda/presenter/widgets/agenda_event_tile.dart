import 'package:flutter/material.dart';
import 'package:kazi/features/agenda/domain/models/agenda_entry.dart';
import 'package:kazi/features/services/domain/models/schedule_state.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// One service on the agenda grid. Its look follows the service's schedule
/// state; see agenda/README.md.
class AgendaEventTile extends StatelessWidget {
  const AgendaEventTile({
    super.key,
    required this.entry,
    required this.mode,
    required this.now,
  });

  final AgendaEntry entry;
  final KaziAgendaMode mode;
  final DateTime now;

  /// Below this the tile has room for one line only.
  static const _twoLineHeight = 34.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final service = entry.service;
    final state = service.scheduleStateAt(now);
    final isQuiet =
        state == ScheduleState.finished || state == ScheduleState.cancelled;

    final title = service.catalogItem?.name ?? '';
    final details = [
      if (!entry.isAllDay) _timeLabel,
      if (service.clientName case final String client when client.isNotEmpty)
        client,
    ].join(' · ');

    final titleStyle = KaziTextStyles.labelMedium.copyWith(
      color: isQuiet ? colors.textMuted : colors.text,
      fontWeight: FontWeight.w600,
      decoration: state == ScheduleState.cancelled
          ? TextDecoration.lineThrough
          : null,
    );
    final detailsStyle = KaziTextStyles.labelSmall.copyWith(
      color: colors.textMuted,
    );

    return Semantics(
      button: true,
      label: [title, details, ?_stateWord(state)].join(', '),
      excludeSemantics: true,
      child: Container(
        margin: const EdgeInsets.all(1),
        padding: const EdgeInsets.symmetric(
          horizontal: KaziInsets.xxs,
          vertical: 2,
        ),
        decoration: ShapeDecoration(
          color: isQuiet ? colors.surfaceMuted : colors.card,
          shape: KaziCategoryBorder(
            color: state == ScheduleState.overdue
                ? colors.danger.fill
                : colors.border,
            categoryColor: service.catalogItem?.colorAs ?? colors.surfaceStrong,
            radius: const Radius.circular(KaziRadii.xs),
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final fitsTwoLines =
                mode != KaziAgendaMode.month &&
                !entry.isAllDay &&
                constraints.maxHeight >= _twoLineHeight;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state == ScheduleState.finished) ...[
                  Icon(LucideIcons.check, size: 12, color: colors.textMuted),
                  const SizedBox(width: 2),
                ],
                Expanded(
                  child: fitsTwoLines
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: titleStyle,
                            ),
                            if (details.isNotEmpty)
                              Text(
                                details,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: detailsStyle,
                              ),
                          ],
                        )
                      : Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: titleStyle,
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// "14:00–15:30"; just "14:00" when the booking has no end to show.
  String get _timeLabel {
    final format = DateFormat.Hm();
    final start = format.format(entry.start);
    if (entry.hasOpenEnd || !entry.end.isAfter(entry.start)) return start;
    return '$start–${format.format(entry.end)}';
  }

  String? _stateWord(ScheduleState state) {
    final l10n = KaziLocalizations.current;
    return switch (state) {
      ScheduleState.inProgress => l10n.agendaInProgress,
      ScheduleState.overdue => l10n.agendaOverdue,
      ScheduleState.finished => l10n.agendaFinished,
      ScheduleState.cancelled => l10n.statusCancelled.toLowerCase(),
      ScheduleState.untimed => l10n.noTime.toLowerCase(),
      ScheduleState.upcoming => null,
    };
  }
}
