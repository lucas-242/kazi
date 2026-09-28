import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' show TimeOfDay;

import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/domain/models/catalog_item.dart';
import 'package:kazi/features/services/domain/models/duration_minutes.dart';

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
    super.cancelledAt,
    super.startTime,
    super.duration,
    super.finishedAt,
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
      // `typeName` is the name snapshot every service document carries. It is
      // what names the row when the catalog join cannot: the item was deleted,
      // or the catalog has not loaded. The join still upgrades this to the live
      // item, which is where the colour comes from.
      catalogItem: map['type'] != null
          ? CatalogItem.fromMap(map['type'])
          : map['typeName'] != null
          ? CatalogItem(
              id: map['typeId'] ?? '',
              userId: map['userId'] ?? '',
              name: map['typeName'],
            )
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
      cancelledAt: map['cancelledAt'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              map['cancelledAt'].millisecondsSinceEpoch,
            ),
      startTime: map['startsAt'] == null
          ? null
          : TimeOfDay.fromDateTime(
              DateTime.fromMillisecondsSinceEpoch(
                map['startsAt'].millisecondsSinceEpoch,
              ),
            ),
      duration: durationFromMinutes(map['durationMinutes']),
      finishedAt: map['finishedAt'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              map['finishedAt'].millisecondsSinceEpoch,
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
        cancelledAt: source.cancelledAt,
        startTime: source.startTime,
        duration: source.duration,
        finishedAt: source.finishedAt,
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
      // Unknown to the app versions already on Play, which read a cancelled
      // service as an ordinary one. Nothing they show breaks; they simply do
      // not know it was called off.
      'cancelledAt': cancelledAt == null
          ? null
          : Timestamp.fromDate(cancelledAt!),
      // The whole moment rather than the time of day the model keeps, so the
      // agenda can be queried by when services start. See services/README.md.
      'startsAt': startsAt == null ? null : Timestamp.fromDate(startsAt!),
      'durationMinutes': duration?.inMinutes,
      'finishedAt': finishedAt == null ? null : Timestamp.fromDate(finishedAt!),
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
    DateTime? cancelledAt,
    TimeOfDay? startTime,
    Duration? duration,
    DateTime? finishedAt,
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
      cancelledAt: cancelledAt ?? this.cancelledAt,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      finishedAt: finishedAt ?? this.finishedAt,
      date: date ?? this.date,
      userId: userId ?? this.userId,
    );
  }
}
