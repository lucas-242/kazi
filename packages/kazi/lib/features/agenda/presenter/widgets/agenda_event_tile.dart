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

  /// How much of the name a one-line tile keeps, so the client and the time
  /// still fit after it.
  static const _compactNameLength = 14;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final service = entry.service;
    final state = service.scheduleStateAt(now);
    final isQuiet =
        state == ScheduleState.finished || state == ScheduleState.cancelled;

    final title = service.catalogItem?.name ?? '';
    final details = [
      if (service.clientName case final String client when client.isNotEmpty)
        client,
      if (!entry.isAllDay) _timeLabel,
    ];

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
      label: [title, ...details, ?_stateWord(state)].join(', '),
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
            final scaler = MediaQuery.textScalerOf(context);
            final titleLine = _lineHeight(scaler, titleStyle);
            final detailLine = _lineHeight(scaler, detailsStyle);
            final isCompact =
                mode == KaziAgendaMode.month ||
                entry.isAllDay ||
                details.isEmpty ||
                constraints.maxHeight < titleLine + detailLine;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state == ScheduleState.finished) ...[
                  Icon(LucideIcons.check, size: 12, color: colors.textMuted),
                  const SizedBox(width: 2),
                ],
                Expanded(
                  child: isCompact
                      ? Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: details.isEmpty
                                    ? title
                                    : _shortened(title),
                                style: titleStyle,
                              ),
                              for (final detail in details)
                                TextSpan(text: ' · $detail'),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: detailsStyle,
                        )
                      : _Stacked(
                          title: title,
                          details: details,
                          titleStyle: titleStyle,
                          detailsStyle: detailsStyle,
                          height: constraints.maxHeight,
                          titleLine: titleLine,
                          detailLine: detailLine,
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static double _lineHeight(TextScaler scaler, TextStyle style) =>
      scaler.scale(style.fontSize!) * style.height!;

  static String _shortened(String name) {
    final characters = name.characters;
    if (characters.length <= _compactNameLength) return name;
    return '${characters.take(_compactNameLength - 1).string.trimRight()}…';
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

/// The name over as many lines as the tile leaves it, then the client and the
/// time — each on its own line when there is room, else sharing one.
class _Stacked extends StatelessWidget {
  const _Stacked({
    required this.title,
    required this.details,
    required this.titleStyle,
    required this.detailsStyle,
    required this.height,
    required this.titleLine,
    required this.detailLine,
  });

  final String title;
  final List<String> details;
  final TextStyle titleStyle;
  final TextStyle detailsStyle;
  final double height;
  final double titleLine;
  final double detailLine;

  @override
  Widget build(BuildContext context) {
    final detailLines = [
      if (height >= titleLine + detailLine * details.length)
        ...details
      else
        details.join(' · '),
    ];
    final titleLines = ((height - detailLine * detailLines.length) / titleLine)
        .floor()
        .clamp(1, 3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: titleLines,
          overflow: TextOverflow.ellipsis,
          style: titleStyle,
        ),
        for (final line in detailLines)
          Text(
            line,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: detailsStyle,
          ),
      ],
    );
  }
}
