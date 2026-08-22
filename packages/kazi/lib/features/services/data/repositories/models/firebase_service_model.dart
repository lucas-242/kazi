import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/domain/models/catalog_item.dart';

class FirebaseServiceModel extends Service {
  FirebaseServiceModel({
    super.id,
    super.description,
    required super.value,
    super.commissionPercent,
    super.discountPercent,
    super.catalogItem,
    required super.catalogItemId,
    super.clientId,
    super.clientName,
    super.currency,
    super.rateDate,
    super.receivedAt,
    required super.date,
    required super.userId,
  });

  factory FirebaseServiceModel.fromMap(Map<String, dynamic> map) {
    return FirebaseServiceModel(
      id: map['id'] ?? '',
      description: map['description'],
      value: map['value']?.toDouble(),
      commissionPercent: map['commissionPercent']?.toDouble(),
      discountPercent: map['discountPercent']?.toDouble(),
      catalogItem: map['type'] != null
          ? CatalogItem.fromMap(map['type'])
          : null,
      catalogItemId: map['typeId'],
      clientId: map['clientId'],
      clientName: map['clientName'],
      currency: map['currency'] ?? '',
      rateDate: map['rateDate'] ?? '',
      // Null-guarded, unlike `date`: services written before payment tracking
      // have no such key at all. Read duck-typed, like `date`, so the tests can
      // stand a Timestamp in without pulling the Firestore SDK into them.
      receivedAt: map['receivedAt'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              map['receivedAt'].millisecondsSinceEpoch,
            ),
      date: DateTime.fromMillisecondsSinceEpoch(
        map['date'].millisecondsSinceEpoch,
      ),
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
        commissionPercent: source.commissionPercent,
        discountPercent: source.discountPercent,
        catalogItem: source.catalogItem,
        catalogItemId: source.catalogItemId,
        clientId: source.clientId,
        clientName: source.clientName,
        currency: source.currency,
        rateDate: source.rateDate,
        receivedAt: source.receivedAt,
        date: source.date,
        userId: source.userId,
      );

  /// Keys predate the rename to catalog and are read by versions already on
  /// Play. See services/README.md.
  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'value': value,
      'typeId': catalogItemId,
      'typeName': catalogItem?.name,
      'clientId': clientId,
      'clientName': clientName,
      'commissionPercent': effectiveCommissionPercent,
      // Mirror, not a second source of truth: app versions released before the
      // commission field read `discountPercent` and nothing else — and read it
      // into a non-nullable field, so omitting the key would break them
      // outright rather than merely showing the wrong share.
      'discountPercent': legacyDiscountPercent,
      'currency': currency,
      'rateDate': rateDate,
      // The client clock, never `FieldValue.serverTimestamp()`: a sentinel
      // comes back null on the local write echo, and `fromMap` would then read
      // `millisecondsSinceEpoch` off null. `createdAt` can afford the server
      // clock because the freemium limit depends on it; this is a user-facing
      // date with no security role.
      'receivedAt': receivedAt == null ? null : Timestamp.fromDate(receivedAt!),
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
    double? commissionPercent,
    double? discountPercent,
    CatalogItem? catalogItem,
    String? catalogItemId,
    String? clientId,
    String? clientName,
    String? currency,
    String? rateDate,
    DateTime? receivedAt,
    DateTime? date,
    String? userId,
  }) {
    return FirebaseServiceModel(
      id: id ?? this.id,
      description: description ?? this.description,
      value: value ?? this.value,
      commissionPercent: commissionPercent ?? this.commissionPercent,
      discountPercent: discountPercent ?? this.discountPercent,
      catalogItem: catalogItem ?? this.catalogItem,
      catalogItemId: catalogItemId ?? this.catalogItemId,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      currency: currency ?? this.currency,
      rateDate: rateDate ?? this.rateDate,
      receivedAt: receivedAt ?? this.receivedAt,
      date: date ?? this.date,
      userId: userId ?? this.userId,
    );
  }
}
