import 'package:flutter/material.dart';
import 'package:kazi_core/shared/components/form/kazi_field.dart';
import 'package:kazi_core/shared/components/form/kazi_field_value.dart';
import 'package:kazi_core/shared/l10n/generated/l10n.dart';
import 'package:kazi_core/shared/utils/date_format_utils.dart';

/// A date inside the app's [KaziField] box: the day, or the placeholder saying
/// there is none yet, with the calendar behind a tap.
///
/// It never shows a text mask. A date typed digit by digit is the slowest way
/// to answer a question the calendar answers in one tap, and the mask let
/// through days that do not exist.
class KaziFieldDate extends StatelessWidget {
  const KaziFieldDate({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.firstDate,
    required this.lastDate,
    this.placeholder,
    this.validator,
  });

  final String label;

  /// Null renders [placeholder] and opens the calendar on today.
  final DateTime? value;

  final void Function(DateTime) onChanged;
  final DateTime firstDate;
  final DateTime lastDate;

  /// Defaults to "Escolher".
  final String? placeholder;

  final String? Function(DateTime?)? validator;

  Future<void> _pick(BuildContext context, FormFieldState<void> field) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked == null) return;
    field.didChange(null);
    onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final date = value;

    return FormField<void>(
      // The value lives in [value]; this field only carries the error.
      validator: validator == null ? null : (_) => validator!(value),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (field) => KaziField(
        label: label,
        errorText: field.errorText,
        onTap: () => _pick(context, field),
        child: KaziFieldValue(
          value: date == null
              ? null
              : DateFormatUtils.day(
                  date,
                  locale: Localizations.localeOf(context).toString(),
                ),
          placeholder: placeholder ?? KaziLocalizations.current.pickDate,
        ),
      ),
    );
  }
}
