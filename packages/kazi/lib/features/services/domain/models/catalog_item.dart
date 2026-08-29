import 'dart:convert';
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:kazi_core/kazi_core.dart' hide Service, CatalogItem;

class CatalogItem extends Equatable {
  const CatalogItem({
    this.id = '',
    this.name = '',
    this.defaultValue,
    this.commissionPercent,
    this.discountPercent,
    this.currency = '',
    this.color = '',
    this.archivedAt,
    required this.userId,
  });

  factory CatalogItem.fromMap(Map<String, dynamic> map) {
    final archivedAt = map['archivedAt'];

    return CatalogItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      defaultValue: map['defaultValue']?.toDouble(),
      commissionPercent: map['commissionPercent']?.toDouble(),
      discountPercent: map['discountPercent']?.toDouble(),
      // Legacy docs have no currency: empty string means "use profile default".
      currency: map['currency'] ?? '',
      color: map['color'] ?? '',
      archivedAt: archivedAt is DateTime
          ? archivedAt
          : archivedAt is String
          ? DateTime.tryParse(archivedAt)
          : null,
      userId: map['userId'] ?? '',
    );
  }

  factory CatalogItem.fromJson(String source) =>
      CatalogItem.fromMap(json.decode(source));
  final String id;
  final String name;
  final double? defaultValue;

  /// Share of a service's value the user actually receives, in percentage
  /// points. Null means the user does not work on commission for this item,
  /// and services of it are worth their full value — see
  /// [effectiveCommissionPercent].
  final double? commissionPercent;

  /// Legacy: the cut *withheld* from the user, written by app versions that
  /// modelled this as a discount. Never written as the source of truth any
  /// more — only read, and only when [commissionPercent] is absent.
  final double? discountPercent;

  /// ISO code of the currency services of this item default to. Empty means the
  /// user's profile default currency should be used.
  final String currency;

  /// `AARRGGBB` hex of the colour identifying this item across the app. Empty
  /// means the user did not pick one, and the UI falls back to its default mark.
  final String color;

  /// When the user archived this item, or null while it is active. Absence is
  /// the active state, so documents written before archiving existed need no
  /// migration. See core/archiving.md.
  final DateTime? archivedAt;

  final String userId;

  bool get isArchived => archivedAt != null;

  /// [color] as a [Color], or null when unset — or corrupt, since a bad value
  /// means the same thing to the UI as no value at all.
  Color? get colorAs => KaziHexColor.tryParse(color);

  /// The commission this item configures, resolving legacy items that only
  /// carry a [discountPercent] — a 40% discount always meant the user kept 60%.
  /// Null when the item configures no commission at all, which services of it
  /// read as "keep everything" (see [Service.effectiveCommissionPercent]).
  double? get effectiveCommissionPercent =>
      commissionPercent ??
      (discountPercent == null ? null : 100 - discountPercent!);

  /// What [effectiveCommissionPercent] leaves behind, for the legacy mirror
  /// below. Null only when nothing is configured either way.
  double? get legacyDiscountPercent =>
      commissionPercent == null ? discountPercent : 100 - commissionPercent!;

  /// Deliberately omits `archivedAt`: `update` writes only the keys listed
  /// here, so editing an archived item cannot bring it back. Archiving and
  /// restoring go through the repository's own methods.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'defaultValue': defaultValue,
      'commissionPercent': commissionPercent,
      // Mirror, not a second source of truth: app versions released before the
      // commission field read `discountPercent` and nothing else, so dropping
      // the key would make them treat every edited item as a 0% discount.
      'discountPercent': legacyDiscountPercent,
      'currency': currency,
      'color': color,
      'userId': userId,
    };
  }

  String toJson() => json.encode(toMap());

  CatalogItem copyWith({
    String? id,
    String? name,
    double? defaultValue,
    double? commissionPercent,
    double? discountPercent,
    String? currency,
    String? color,
    DateTime? archivedAt,
    String? userId,
  }) {
    return CatalogItem(
      id: id ?? this.id,
      name: name ?? this.name,
      defaultValue: defaultValue ?? this.defaultValue,
      commissionPercent: commissionPercent ?? this.commissionPercent,
      discountPercent: discountPercent ?? this.discountPercent,
      currency: currency ?? this.currency,
      color: color ?? this.color,
      archivedAt: archivedAt ?? this.archivedAt,
      userId: userId ?? this.userId,
    );
  }

  /// The active form of this item. A separate method because [copyWith] reads
  /// null as "keep what you have" and so cannot clear [archivedAt].
  CatalogItem restored() => CatalogItem(
    id: id,
    name: name,
    defaultValue: defaultValue,
    commissionPercent: commissionPercent,
    discountPercent: discountPercent,
    currency: currency,
    color: color,
    userId: userId,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    defaultValue,
    commissionPercent,
    discountPercent,
    currency,
    color,
    archivedAt,
    userId,
  ];
}
