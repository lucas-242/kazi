import 'package:flutter/material.dart';
import 'package:kazi_core/shared/components/form/kazi_text_form_field.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class KaziDateRangePicker extends StatelessWidget {
  const KaziDateRangePicker({
    super.key,
    required this.controller,
    required this.onChange,
    required this.startRange,
    required this.endRange,
    required this.firstDate,
    required this.lastDate,
    required this.label,
  });
  final TextEditingController controller;
  final String label;
  final DateTime startRange;
  final DateTime endRange;
  final DateTime firstDate;
  final DateTime lastDate;
  final void Function(DateTimeRange) onChange;

  @override
  Widget build(BuildContext context) {
    void onChangeDatePicker(DateTimeRange? date) {
      if (date != null) {
        onChange(date);
      }
    }

    return KaziTextFormField(
      labelText: label,
      keyboardType: TextInputType.datetime,
      suffixIcon: Icon(LucideIcons.calendar),
      controller: controller,
      readOnly: true,
      onTap: () {
        showDateRangePicker(
          context: context,
          initialDateRange: DateTimeRange(
            start: startRange,
            end: endRange,
          ),
          firstDate: firstDate,
          lastDate: lastDate,
        ).then((value) => onChangeDatePicker(value));
      },
    );
  }
}
