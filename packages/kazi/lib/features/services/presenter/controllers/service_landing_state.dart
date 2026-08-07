import 'package:equatable/equatable.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/domain/models/service_totals.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

class ServiceLandingState extends BaseState with Equatable {
  ServiceLandingState({
    required super.status,
    List<Service>? services,
    super.callbackMessage,
    required this.startDate,
    required this.endDate,
    this.fastSearch = FastSearch.month,
    this.selectedOrderBy = OrderBy.alphabetical,
    this.didFiltersChange = false,
    this.defaultCurrency = SupportedCurrency.usd,
    this.rateBook = const RateBook.empty(),
  }) : services = services ?? [];
  final DateTime startDate;
  final DateTime endDate;
  final FastSearch fastSearch;
  final OrderBy selectedOrderBy;
  final List<Service> services;
  final bool didFiltersChange;

  /// Currency the totals are expressed in (the user's profile default).
  final SupportedCurrency defaultCurrency;

  /// Rate snapshots covering the dates of [services].
  final RateBook rateBook;

  ServiceTotals get totals => ServiceTotals.from(
    services,
    currency: defaultCurrency,
    rateBook: rateBook,
  );

  @override
  ServiceLandingState copyWith({
    BaseStateStatus? status,
    String? callbackMessage,
    List<Service>? services,
    DateTime? startDate,
    DateTime? endDate,
    FastSearch? fastSearch,
    OrderBy? selectedOrderBy,
    bool? didFiltersChange,
    SupportedCurrency? defaultCurrency,
    RateBook? rateBook,
  }) {
    return ServiceLandingState(
      status: status ?? this.status,
      callbackMessage: callbackMessage ?? this.callbackMessage,
      services: services ?? this.services,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      fastSearch: fastSearch ?? this.fastSearch,
      selectedOrderBy: selectedOrderBy ?? this.selectedOrderBy,
      didFiltersChange: didFiltersChange ?? this.didFiltersChange,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      rateBook: rateBook ?? this.rateBook,
    );
  }

  @override
  List<Object?> get props => [
    startDate,
    endDate,
    fastSearch,
    selectedOrderBy,
    services,
    didFiltersChange,
    defaultCurrency,
    rateBook,
    status,
    callbackMessage,
  ];
}
