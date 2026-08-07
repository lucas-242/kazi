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
  }) : selectedOrderBy = selectedOrderBy ?? OrderBy.dateDesc,
       services = services ?? const [];
  final List<Service> services;
  final OrderBy selectedOrderBy;

  /// Currency the aggregated totals are expressed in (the user's profile
  /// default). Each service is converted into it before summing, so
  /// mixed-currency services aggregate correctly.
  final SupportedCurrency defaultCurrency;

  /// Rate snapshots covering the dates of [services].
  final RateBook rateBook;

  ServiceTotals get totals => ServiceTotals.from(
    services,
    currency: defaultCurrency,
    rateBook: rateBook,
  );

  @override
  DashboardState copyWith({
    BaseStateStatus? status,
    String? callbackMessage,
    List<Service>? services,
    OrderBy? selectedOrderBy,
    SupportedCurrency? defaultCurrency,
    RateBook? rateBook,
  }) {
    return DashboardState(
      status: status ?? this.status,
      callbackMessage: callbackMessage ?? this.callbackMessage,
      services: services ?? this.services,
      selectedOrderBy: selectedOrderBy ?? this.selectedOrderBy,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      rateBook: rateBook ?? this.rateBook,
    );
  }

  @override
  List<Object?> get props => [
    services,
    selectedOrderBy,
    defaultCurrency,
    rateBook,
    status,
    callbackMessage,
  ];
}
