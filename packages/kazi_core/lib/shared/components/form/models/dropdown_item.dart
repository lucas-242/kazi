class DropdownItem {
  DropdownItem({String? label, this.auxValue, required this.value})
      : label = label ?? value.toString();
  final String label;
  final String value;

  final String? auxValue;

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
