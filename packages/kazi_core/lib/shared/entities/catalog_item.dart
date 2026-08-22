import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

class CatalogItem extends Equatable {
  const CatalogItem({
    required this.id,
    required this.name,
    required this.userId,
    required this.defaultValue,
    required this.discountPercent,
    required this.defaultDuration,
    required this.color,
  });

  final int id;
  final String name;
  final double defaultValue;
  final double discountPercent;
  final Duration defaultDuration;
  final String color;
  final int userId;

  Color get colorAs => Color.fromARGB(
        int.parse(color.substring(0, 2), radix: 16),
        int.parse(color.substring(2, 4), radix: 16),
        int.parse(color.substring(4, 6), radix: 16),
        int.parse(color.substring(6, 8), radix: 16),
      );

  CatalogItem copyWith({
    int? id,
    String? name,
    double? defaultValue,
    double? discountPercent,
    Duration? defaultDuration,
    String? color,
    int? userId,
  }) {
    return CatalogItem(
      id: id ?? this.id,
      name: name ?? this.name,
      defaultValue: defaultValue ?? this.defaultValue,
      discountPercent: discountPercent ?? this.discountPercent,
      defaultDuration: defaultDuration ?? this.defaultDuration,
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
        color,
        userId,
      ];
}
