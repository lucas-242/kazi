import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/domain/models/service_type.dart';

class FirebaseServiceModel extends Service {
  FirebaseServiceModel({
    super.id,
    super.description,
    required super.value,
    required super.discountPercent,
    super.type,
    required super.typeId,
    super.clientId,
    super.clientName,
    super.currency,
    super.rates,
    required super.date,
    required super.userId,
  });

  factory FirebaseServiceModel.fromMap(Map<String, dynamic> map) {
    return FirebaseServiceModel(
      id: map['id'] ?? '',
      description: map['description'],
      value: map['value']?.toDouble(),
      discountPercent: map['discountPercent']?.toDouble(),
      type: map['type'] != null ? ServiceType.fromMap(map['type']) : null,
      typeId: map['typeId'],
      clientId: map['clientId'],
      clientName: map['clientName'],
      currency: map['currency'] ?? '',
      rates: _ratesFromMap(map['rates']),
      date: DateTime.fromMillisecondsSinceEpoch(
          map['date'].millisecondsSinceEpoch,),
      userId: map['userId'],
    );
  }

  factory FirebaseServiceModel.fromJson(String source) =>
      FirebaseServiceModel.fromMap(json.decode(source));

  factory FirebaseServiceModel.fromService(Service source) =>
      FirebaseServiceModel(
        id: source.id,
        description: source.description,
        value: source.value,
        discountPercent: source.discountPercent,
        type: source.type,
        typeId: source.typeId,
        clientId: source.clientId,
        clientName: source.clientName,
        currency: source.currency,
        rates: source.rates,
        date: source.date,
        userId: source.userId,
      );

  static Map<String, double>? _ratesFromMap(dynamic raw) {
    if (raw is! Map) return null;
    return raw.map(
      (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'value': value,
      'typeId': typeId,
      'typeName': type?.name,
      'clientId': clientId,
      'clientName': clientName,
      'discountPercent': discountPercent,
      'currency': currency,
      'rates': rates,
      'date': Timestamp.fromDate(date),
      'userId': userId,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  FirebaseServiceModel copyWith({
    String? id,
    String? description,
    double? value,
    double? discountPercent,
    ServiceType? type,
    String? typeId,
    String? clientId,
    String? clientName,
    String? currency,
    Map<String, double>? rates,
    DateTime? date,
    String? userId,
  }) {
    return FirebaseServiceModel(
      id: id ?? this.id,
      description: description ?? this.description,
      value: value ?? this.value,
      discountPercent: discountPercent ?? this.discountPercent,
      type: type ?? this.type,
      typeId: typeId ?? this.typeId,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      currency: currency ?? this.currency,
      rates: rates ?? this.rates,
      date: date ?? this.date,
      userId: userId ?? this.userId,
    );
  }
}
