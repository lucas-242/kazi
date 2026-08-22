import 'package:equatable/equatable.dart';
import 'package:kazi_core/kazi_core.dart';

class Service extends Equatable {
  const Service._({
    required this.id,
    required this.description,
    required this.value,
    required this.discountPercent,
    required this.catalogItem,
    required this.catalogItemId,
    required this.scheduledToStartAt,
    required this.scheduledToEndAt,
    required this.startedAt,
    required this.endedAt,
    required this.employeeId,
    required this.employee,
    required this.scheduledBy,
    required this.customerId,
    required this.customer,
  });

  Service.toCreate({
    this.description,
    this.value = 0,
    this.discountPercent = 0,
    this.catalogItem,
    this.catalogItemId = 0,
    DateTime? scheduledToStartAt,
    DateTime? scheduledToEndAt,
    this.startedAt,
    this.endedAt,
    required this.employeeId,
    this.employee,
    this.customerId,
    this.customer,
  })  : id = 0,
        scheduledBy = employeeId,
        scheduledToStartAt = scheduledToStartAt ?? _defaultDate,
        scheduledToEndAt = scheduledToEndAt ?? _defaultDate;

  static final _defaultDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  final int id;
  final String? description;
  final double value;
  final double discountPercent;
  final CatalogItem? catalogItem;
  final int catalogItemId;
  final DateTime scheduledToStartAt;
  final DateTime scheduledToEndAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int employeeId;
  final User? employee;
  final int scheduledBy;
  final int? customerId;
  final User? customer;

  double get discountValue => value * discountPercent / 100;
  double get finalValue => value - discountValue;

  Service copyWith({
    int? id,
    String? description,
    double? value,
    double? discountPercent,
    CatalogItem? catalogItem,
    int? catalogItemId,
    DateTime? scheduledToStartAt,
    DateTime? scheduledToEndAt,
    DateTime? startedAt,
    DateTime? endedAt,
    int? employeeId,
    User? employee,
    int? customerId,
    User? customer,
    int? scheduledBy,
  }) {
    return Service._(
      id: id ?? this.id,
      description: description ?? this.description,
      value: value ?? this.value,
      discountPercent: discountPercent ?? this.discountPercent,
      catalogItem: catalogItem ?? catalogItem,
      catalogItemId: catalogItemId ?? this.catalogItemId,
      scheduledToStartAt: scheduledToStartAt ?? this.scheduledToStartAt,
      scheduledToEndAt: scheduledToEndAt ?? this.scheduledToEndAt,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      employeeId: employeeId ?? this.employeeId,
      employee: employee ?? this.employee,
      customerId: customerId ?? this.customerId,
      customer: customer ?? this.customer,
      scheduledBy: scheduledBy ?? this.scheduledBy,
    );
  }

  @override
  List<Object?> get props => [
        id,
        description,
        value,
        discountPercent,
        catalogItem,
        catalogItemId,
        scheduledToStartAt,
        scheduledToEndAt,
        startedAt,
        endedAt,
        employeeId,
        employee,
        customerId,
        customer,
        scheduledBy,
      ];

  Map<String, dynamic> toJson({bool withId = false}) {
    final json = {
      'description': description,
      'value': value,
      'discountPercent': discountPercent,
      // The API's key, unchanged by the rename to catalog.
      'serviceTypeId': catalogItemId,
      'scheduledToStartAt': scheduledToStartAt.toIso8601String(),
      'scheduledToEndAt': scheduledToEndAt.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'employeeId': employeeId,
      'customerId': customerId,
      'scheduledBy': scheduledBy,
    };

    if (withId) {
      json.addEntries([MapEntry('id', id)]);
    }

    return json;
  }
}
