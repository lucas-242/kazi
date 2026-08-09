import 'dart:ui';

class DropdownItem {
  DropdownItem({
    String? label,
    this.auxValue,
    this.searchTerms,
    this.color,
    required this.value,
  }) : label = label ?? value.toString();
  final String label;
  final String value;

  final String? auxValue;

  /// Colour mark shown beside the item, for lists whose entries carry an
  /// identifying colour (service types). Null renders no mark.
  ///
  /// Deliberately outside `==`/[hashCode], for the same reason as [searchTerms]:
  /// callers build the `selectedItem` by hand, and a colour taking part in
  /// identity would stop the picker from recognizing the current selection.
  final Color? color;

  /// Extra text the picker's search matches on, for items whose [label] is too
  /// terse to type (a currency listed as `BRL (R$)` still answers to "real").
  /// Deliberately outside `==`/[hashCode]: it is a search hint, not identity,
  /// and callers build the `selectedItem` without it.
  final String? searchTerms;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    final DropdownItem otherItem = other as DropdownItem;
    return label == otherItem.label &&
        value == otherItem.value &&
        auxValue == otherItem.auxValue;
  }

  @override
  int get hashCode => Object.hash(label, value, auxValue);
}
