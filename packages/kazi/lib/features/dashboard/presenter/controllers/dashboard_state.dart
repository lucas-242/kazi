import 'package:equatable/equatable.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/domain/models/service_totals.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

class DashboardState extends BaseState with Equatable {
  DashboardState({
    required super.status,
    List<Service>? services,
    super.callbackMessage,
    OrderBy? selectedOrderBy,
    this.defaultCurrency = SupportedCurrency.usd,
    this.rateBook = const RateBook.empty(),
    this.referenceDate,
  }) : selectedOrderBy = selectedOrderBy ?? OrderBy.dateDesc,
       services = services ?? const [];

  /// The services of the current calendar month.
  final List<Service> services;
  final OrderBy selectedOrderBy;

  /// "Today" as seen by the app clock, so the daily slice does not depend on
  /// `DateTime.now()` being called at render time. Null until the first fetch.
  final DateTime? referenceDate;

  /// Currency the aggregated totals are expressed in (the user's profile
  /// default). Each service is converted into it before summing, so
  /// mixed-currency services aggregate correctly.
  final SupportedCurrency defaultCurrency;

  /// Rate snapshots covering the dates of [services].
  final RateBook rateBook;

  /// Totals for the whole month, every service converted into
  /// [defaultCurrency] before being summed.
  ServiceTotals get totals => ServiceTotals.from(
    services,
    currency: defaultCurrency,
    rateBook: rateBook,
  );

  /// The services performed on [referenceDate], keeping the order already
  /// applied to [services].
  List<Service> get todayServices => referenceDate == null
      ? const []
      : services
            .where((service) => service.date.calculateDifference(
                  referenceDate!,
                ) ==
                0)
            .toList();

  /// Share of the month's gross the user keeps, in percentage points. Null when
  /// there is no gross to divide by, and the UI omits the figure.
  double? get sharePercent =>
      totals.value == 0 ? null : totals.withDiscount / totals.value * 100;

  @override
  DashboardState copyWith({
    BaseStateStatus? status,
    String? callbackMessage,
    List<Service>? services,
    OrderBy? selectedOrderBy,
    SupportedCurrency? defaultCurrency,
    RateBook? rateBook,
    DateTime? referenceDate,
  }) {
    return DashboardState(
      status: status ?? this.status,
      callbackMessage: callbackMessage ?? this.callbackMessage,
      services: services ?? this.services,
      selectedOrderBy: selectedOrderBy ?? this.selectedOrderBy,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      rateBook: rateBook ?? this.rateBook,
      referenceDate: referenceDate ?? this.referenceDate,
    );
  }

  @override
  List<Object?> get props => [
    services,
    selectedOrderBy,
    defaultCurrency,
    rateBook,
    referenceDate,
    status,
    callbackMessage,
  ];
}
