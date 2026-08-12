import 'package:equatable/equatable.dart';

/// One line of the catalog being assembled during the setup, before any of it
/// reaches Firestore.
///
/// It exists because the catalog screen is edited as a whole — tick, untick,
/// retype a price, override one commission — and only the final selection is
/// written. Nothing here is persisted until the setup completes.
class SetupCatalogItem extends Equatable {
  const SetupCatalogItem({
    required this.id,
    required this.name,
    required this.commissionPercent,
    this.value,
    this.selected = true,
    this.hasCustomCommission = false,
    this.existingTypeId,
  });

  /// Local identity. Presets use their position in the kit; typed services use
  /// a counter; a line standing for a type the account already has uses that
  /// type's Firestore id.
  final String id;

  final String name;

  /// Null is allowed and never blocks: plenty of people price by agreement and
  /// do not know the number by heart. They fill it in when they register the
  /// service, and outside Brazil every preset starts here.
  final double? value;

  /// The share the user keeps.
  final double commissionPercent;

  final bool selected;

  /// Whether [commissionPercent] was set for this item specifically. The
  /// commission screen applies one percentage to everything at once, and this
  /// is what keeps a per-item exception from being overwritten by it.
  final bool hasCustomCommission;

  /// The Firestore id of the service type this line already corresponds to, for
  /// an account that arrived with a catalog of its own. Null for anything the
  /// setup would be creating.
  ///
  /// It is what lets the closing screens act on a real document: without it the
  /// first service has no type to point at, and an edit made here has nothing
  /// to write back to.
  final String? existingTypeId;

  bool get isExisting => existingTypeId != null;

  SetupCatalogItem copyWith({
    String? name,
    double? Function()? value,
    double? commissionPercent,
    bool? selected,
    bool? hasCustomCommission,
  }) => SetupCatalogItem(
    id: id,
    name: name ?? this.name,
    value: value == null ? this.value : value(),
    commissionPercent: commissionPercent ?? this.commissionPercent,
    selected: selected ?? this.selected,
    hasCustomCommission: hasCustomCommission ?? this.hasCustomCommission,
    existingTypeId: existingTypeId,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    value,
    commissionPercent,
    selected,
    hasCustomCommission,
    existingTypeId,
  ];
}
