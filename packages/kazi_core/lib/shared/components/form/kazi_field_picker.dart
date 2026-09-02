import 'package:flutter/material.dart';
import 'package:kazi_core/shared/components/form/kazi_dropdown.dart';
import 'package:kazi_core/shared/components/form/kazi_field.dart';
import 'package:kazi_core/shared/components/form/kazi_field_value.dart';
import 'package:kazi_core/shared/components/form/models/dropdown_item.dart';
import 'package:kazi_core/shared/components/kazi_color_dot.dart';
import 'package:kazi_core/shared/themes/themes.dart';

/// A selection inside the app's [KaziField] box, picked from the same sheet
/// [KaziDropdown] opens.
///
/// The two differ only in the field they draw. This one is the shape the
/// screen inventory settled on: the caption stays visible next to the answer,
/// and the box has room for a [trailing] action — the "+ Novo" that creates
/// what the list could not offer.
class KaziFieldPicker extends StatelessWidget {
  const KaziFieldPicker({
    super.key,
    required this.label,
    required this.placeholder,
    required this.items,
    required this.searchLabel,
    required this.noResultsLabel,
    this.selectedItem,
    this.onChanged,
    this.validator,
    this.showSearch = false,
    this.searchHint,
    this.secondarySectionLabel,
    this.trailing,
    this.onClear,
  });

  final String label;

  /// Shown in place of the value while nothing is picked. It says what to
  /// choose, not what the field is called — the caption already does that.
  final String placeholder;

  final List<DropdownItem> items;
  final String searchLabel;
  final String noResultsLabel;
  final DropdownItem? selectedItem;
  final void Function(DropdownItem?)? onChanged;
  final String? Function(DropdownItem?)? validator;
  final bool showSearch;
  final String? searchHint;
  final String? secondarySectionLabel;

  /// An action at the end of the box, with its own tap target.
  final Widget? trailing;

  /// Drops the selection. Only meaningful on an optional field, and only shown
  /// once something is picked.
  final VoidCallback? onClear;

  Future<void> _openPicker(
    BuildContext context,
    FormFieldState<void> field,
  ) async {
    final selected = await showKaziDropdownPicker(
      context: context,
      title: label,
      items: items,
      selectedItem: selectedItem,
      showSearch: showSearch,
      searchHint: searchHint,
      searchLabel: searchLabel,
      noResultsLabel: noResultsLabel,
      secondarySectionLabel: secondarySectionLabel,
    );
    if (selected == null) return;
    field.didChange(null);
    onChanged?.call(selected);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final item = selectedItem;
    final hasSelection = item != null && item.label.isNotEmpty;

    return FormField<void>(
      validator: validator == null ? null : (_) => validator!(selectedItem),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (field) => KaziField(
        label: label,
        errorText: field.errorText,
        onTap: () => _openPicker(context, field),
        trailing: trailing,
        child: Row(
          children: [
            Expanded(
              child: KaziFieldValue(
                value: hasSelection ? item.label : null,
                placeholder: placeholder,
                leading: item?.color == null
                    ? null
                    : KaziColorDot(color: item?.color),
              ),
            ),
            if (hasSelection && onClear != null)
              InkResponse(
                onTap: onClear,
                radius: KaziSizings.iconMd,
                child: Icon(
                  Icons.close,
                  size: KaziSizings.iconSm,
                  color: colors.textMuted,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
