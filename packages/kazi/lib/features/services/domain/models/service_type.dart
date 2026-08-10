import 'dart:convert';
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:kazi_core/kazi_core.dart' hide Service, ServiceType;

class ServiceType extends Equatable {
  const ServiceType({
    this.id = '',
    this.name = '',
    this.defaultValue,
    this.commissionPercent,
    this.discountPercent,
    this.currency = '',
    this.color = '',
    required this.userId,
  });

  factory ServiceType.fromMap(Map<String, dynamic> map) {
    return ServiceType(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      defaultValue: map['defaultValue']?.toDouble(),
      commissionPercent: map['commissionPercent']?.toDouble(),
      discountPercent: map['discountPercent']?.toDouble(),
      // Legacy docs have no currency: empty string means "use profile default".
      currency: map['currency'] ?? '',
      color: map['color'] ?? '',
      userId: map['userId'] ?? '',
    );
  }

  factory ServiceType.fromJson(String source) =>
      ServiceType.fromMap(json.decode(source));
  final String id;
  final String name;
  final double? defaultValue;

  /// Share of a service's value the user actually receives, in percentage
  /// points. Null means the user does not work on commission for this type,
  /// and services of it are worth their full value — see
  /// [effectiveCommissionPercent].
  final double? commissionPercent;

  /// Legacy: the cut *withheld* from the user, written by app versions that
  /// modelled this as a discount. Never written as the source of truth any
  /// more — only read, and only when [commissionPercent] is absent.
  final double? discountPercent;

  /// ISO code of the currency services of this type default to. Empty means the
  /// user's profile default currency should be used.
  final String currency;

  /// `AARRGGBB` hex of the colour identifying this type across the app. Empty
  /// means the user did not pick one, and the UI falls back to its default mark.
  final String color;
  final String userId;

  /// [color] as a [Color], or null when unset — or corrupt, since a bad value
  /// means the same thing to the UI as no value at all.
  Color? get colorAs => KaziHexColor.tryParse(color);

  /// The commission this type configures, resolving legacy types that only
  /// carry a [discountPercent] — a 40% discount always meant the user kept 60%.
  /// Null when the type configures no commission at all, which services of it
  /// read as "keep everything" (see [Service.effectiveCommissionPercent]).
  double? get effectiveCommissionPercent =>
      commissionPercent ??
      (discountPercent == null ? null : 100 - discountPercent!);

  /// What [effectiveCommissionPercent] leaves behind, for the legacy mirror
  /// below. Null only when nothing is configured either way.
  double? get legacyDiscountPercent =>
      commissionPercent == null ? discountPercent : 100 - commissionPercent!;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'defaultValue': defaultValue,
      'commissionPercent': commissionPercent,
      // Mirror, not a second source of truth: app versions released before the
      // commission field read `discountPercent` and nothing else, so dropping
      // the key would make them treat every edited type as a 0% discount.
      'discountPercent': legacyDiscountPercent,
      'currency': currency,
      'color': color,
      'userId': userId,
    };
  }

  String toJson() => json.encode(toMap());

  ServiceType copyWith({
    String? id,
    String? name,
    double? defaultValue,
    double? commissionPercent,
    double? discountPercent,
    String? currency,
    String? color,
    String? userId,
  }) {
    return ServiceType(
      id: id ?? this.id,
      name: name ?? this.name,
      defaultValue: defaultValue ?? this.defaultValue,
      commissionPercent: commissionPercent ?? this.commissionPercent,
      discountPercent: discountPercent ?? this.discountPercent,
      currency: currency ?? this.currency,
      color: color ?? this.color,
      userId: userId ?? this.userId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    defaultValue,
    commissionPercent,
    discountPercent,
    currency,
    color,
    userId,
  ];
}
