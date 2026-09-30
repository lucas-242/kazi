import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kazi_core/shared/components/buttons/kazi_chip.dart';
import 'package:kazi_core/shared/components/buttons/kazi_elevated_button.dart';
import 'package:kazi_core/shared/l10n/generated/l10n.dart';
import 'package:kazi_core/shared/navigation/kazi_navigator.dart';
import 'package:kazi_core/shared/themes/themes.dart';
import 'package:kazi_core/shared/utils/duration_format_utils.dart';

/// Optional length-of-time field: the common lengths as chips, one tap each,
/// and days-hours-minutes wheels behind the last chip for anything else, up
/// to 30 days.
///
/// Tapping the selected preset clears the field; the custom chip, once it
/// holds a value, names it and clears through its own cross.
class KaziDurationPicker extends StatelessWidget {
  const KaziDurationPicker({
    super.key,
    required this.selected,
    required this.onChanged,
    this.presets = defaultPresets,
  });

  static const defaultPresets = [
    Duration(minutes: 30),
    Duration(hours: 1),
    Duration(hours: 1, minutes: 30),
    Duration(hours: 2),
    Duration(hours: 2, minutes: 30),
    Duration(hours: 3),
  ];

  /// The chosen length, or null for none.
  final Duration? selected;

  /// Emits the chosen length, or null when the user clears it.
  final ValueChanged<Duration?> onChanged;

  final List<Duration> presets;

  bool get _isCustom => selected != null && !presets.contains(selected);

  Future<void> _pickCustom(BuildContext context) async {
    final picked = await KaziNavigator.showBottomSheet<Duration>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (_) => _CustomDurationSheet(initial: selected),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    // Wraps rather than scrolls: a cut-off "Outra" would hide every other
    // length.
    return Wrap(
      spacing: KaziInsets.xs,
      runSpacing: KaziInsets.xs,
      children: [
        for (final preset in presets)
          KaziChip(
            label: DurationFormatUtils.short(preset),
            isSelected: selected == preset,
            onTap: () => onChanged(selected == preset ? null : preset),
          ),
        KaziChip(
          label: _isCustom
              ? DurationFormatUtils.short(selected!)
              : KaziLocalizations.current.durationOther,
          isSelected: _isCustom,
          onTap: () => _pickCustom(context),
          onClear: _isCustom ? () => onChanged(null) : null,
        ),
      ],
    );
  }
}

class _CustomDurationSheet extends StatefulWidget {
  const _CustomDurationSheet({required this.initial});

  final Duration? initial;

  @override
  State<_CustomDurationSheet> createState() => _CustomDurationSheetState();
}

class _CustomDurationSheetState extends State<_CustomDurationSheet> {
  static const _minuteInterval = 5;
  static const _maxDays = 30;
  static const _longest = Duration(days: _maxDays, hours: 23, minutes: 55);

  late Duration _value = _normalized(
    widget.initial ?? const Duration(hours: 1),
  );

  late final _days = FixedExtentScrollController(initialItem: _value.inDays);
  late final _hours = FixedExtentScrollController(
    initialItem: _value.inHours.remainder(24),
  );
  late final _minutes = FixedExtentScrollController(
    initialItem: _value.inMinutes.remainder(60) ~/ _minuteInterval,
  );

  /// A stored length may sit off the wheel's steps or past its last day.
  static Duration _normalized(Duration duration) {
    final rounded = Duration(
      minutes: (duration.inMinutes / _minuteInterval).round() * _minuteInterval,
    );
    return rounded > _longest ? _longest : rounded;
  }

  @override
  void dispose() {
    _days.dispose();
    _hours.dispose();
    _minutes.dispose();
    super.dispose();
  }

  void _onWheelChanged() => setState(
        () => _value = Duration(
          days: _days.selectedItem,
          hours: _hours.selectedItem,
          minutes: _minutes.selectedItem * _minuteInterval,
        ),
      );

  Widget _wheel(
    FixedExtentScrollController controller,
    int count,
    String Function(int index) label,
  ) {
    return Expanded(
      child: CupertinoPicker(
        scrollController: controller,
        itemExtent: 36,
        onSelectedItemChanged: (_) => _onWheelChanged(),
        children: [
          for (var index = 0; index < count; index++)
            Center(child: Text(label(index))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = KaziLocalizations.current;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        KaziInsets.xLg,
        0,
        KaziInsets.xLg,
        KaziInsets.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.duration, style: KaziTextStyles.titleMedium),
          KaziSpacings.verticalMd,
          // The wheels read their ink from the Cupertino theme, which knows
          // nothing of the Material one — without this they stay black on dark.
          CupertinoTheme(
            data: CupertinoThemeData(
              brightness: Theme.of(context).brightness,
              textTheme: CupertinoTextThemeData(
                pickerTextStyle: KaziTextStyles.titleMedium.copyWith(
                  color: colors.text,
                ),
              ),
            ),
            child: SizedBox(
              height: 216,
              child: Row(
                children: [
                  _wheel(_days, _maxDays + 1, l10n.durationDays),
                  _wheel(_hours, 24, l10n.durationHours),
                  _wheel(
                    _minutes,
                    60 ~/ _minuteInterval,
                    (index) => l10n.durationMinutes(index * _minuteInterval),
                  ),
                ],
              ),
            ),
          ),
          KaziSpacings.verticalMd,
          KaziElevatedButton.label(
            label: l10n.confirm,
            width: double.infinity,
            // Zero is no length at all; clearing is the chip's cross.
            onTap: _value == Duration.zero
                ? null
                : () => Navigator.of(context).pop(_value),
          ),
        ],
      ),
    );
  }
}
