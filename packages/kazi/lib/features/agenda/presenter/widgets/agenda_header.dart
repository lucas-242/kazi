import 'package:flutter/material.dart';
import 'package:kazi/core/constants/form_keys.dart';
import 'package:kazi/features/agenda/presenter/controllers/agenda_state.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// The period on screen, the ways to move through time, and the mode switch.
class AgendaHeader extends StatelessWidget {
  const AgendaHeader({
    super.key,
    required this.state,
    required this.onPickDate,
    required this.onPrevious,
    required this.onToday,
    required this.onNext,
    required this.onChangeMode,
  });

  final AgendaState state;
  final ValueChanged<DateTime> onPickDate;
  final VoidCallback onPrevious;
  final VoidCallback onToday;
  final VoidCallback onNext;
  final ValueChanged<KaziAgendaMode> onChangeMode;

  /// How far ahead the date picker reaches: bookings are made for the future,
  /// unlike the form's past-facing service dates.
  static const _yearsAhead = 5;

  @override
  Widget build(BuildContext context) {
    final l10n = KaziLocalizations.current;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _pickDate(context),
                borderRadius: KaziRadii.xsBorder,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: KaziInsets.xs),
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          _periodLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: KaziTextStyles.titleMedium,
                        ),
                      ),
                      KaziSpacings.horizontalXs,
                      const Icon(LucideIcons.chevronDown, size: 18),
                    ],
                  ),
                ),
              ),
            ),
            KaziCircularButton.plain(
              onTap: onPrevious,
              semantics: l10n.agendaPrevious,
              child: const Icon(LucideIcons.chevronLeft, size: 18),
            ),
            KaziTextButton(onTap: onToday, child: Text(l10n.today)),
            KaziCircularButton.plain(
              onTap: onNext,
              semantics: l10n.agendaNext,
              child: const Icon(LucideIcons.chevronRight, size: 18),
            ),
          ],
        ),
        KaziSpacings.verticalSm,
        KaziSegmentedControl<KaziAgendaMode>(
          selected: state.mode,
          onChanged: onChangeMode,
          segments: [
            KaziSegment(value: KaziAgendaMode.day, label: l10n.agendaDay),
            KaziSegment(value: KaziAgendaMode.week, label: l10n.agendaWeek),
            KaziSegment(value: KaziAgendaMode.month, label: l10n.agendaMonth),
          ],
        ),
      ],
    );
  }

  /// A month on screen also shows the edges of its neighbours, so the month
  /// it is about is the one in the middle of the grid.
  DateTime get _focusedDay {
    final first = state.firstVisibleDay;
    final days = state.lastVisibleDay.difference(first).inDays;
    return DateTime(first.year, first.month, first.day + days ~/ 2);
  }

  String get _periodLabel {
    final first = state.firstVisibleDay;
    final last = state.lastVisibleDay;

    final label = switch (state.mode) {
      KaziAgendaMode.day => DateFormat.MMMMEEEEd().format(first),
      KaziAgendaMode.week =>
        '${DateFormat.MMMd().format(first)} – ${DateFormat.MMMd().format(last)}',
      KaziAgendaMode.month => DateFormat.yMMMM().format(_focusedDay),
    };
    return label.capitalize();
  }

  Future<void> _pickDate(BuildContext context) async {
    final firstDate = FormKeys.formStartDate;
    final lastDate = DateTime(DateTime.now().year + _yearsAhead);
    final focused = _focusedDay;
    final picked = await showDatePicker(
      context: context,
      // The grid can be swiped past either bound; the picker refuses that.
      initialDate: focused.isBefore(firstDate)
          ? firstDate
          : focused.isAfter(lastDate)
          ? lastDate
          : focused,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null) onPickDate(picked);
  }
}
