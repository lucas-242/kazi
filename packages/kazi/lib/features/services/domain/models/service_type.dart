import 'dart:convert';
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:kazi_core/kazi_core.dart' hide Service, ServiceType;

class ServiceType extends Equatable {
  const ServiceType({
    this.id = '',
    this.name = '',
    this.defaultValue,
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

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'defaultValue': defaultValue,
      'discountPercent': discountPercent,
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
    double? discountPercent,
    String? currency,
    String? color,
    String? userId,
  }) {
    return ServiceType(
      id: id ?? this.id,
      name: name ?? this.name,
      defaultValue: defaultValue ?? this.defaultValue,
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
    discountPercent,
    currency,
    color,
    userId,
  ];
}
