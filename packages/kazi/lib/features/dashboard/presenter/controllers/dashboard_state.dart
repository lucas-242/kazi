import 'package:equatable/equatable.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/core/utils/date_range.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/domain/models/service_totals.dart';
import 'package:kazi/features/settings/domain/models/billing_cycle.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

class DashboardState extends BaseState with Equatable {
  DashboardState({
    required super.status,
    List<Service>? services,
    super.callbackMessage,
    OrderBy? selectedOrderBy,
    this.defaultCurrency = SupportedCurrency.usd,
    this.rateBook = const RateBook.empty(),
    this.referenceDate,
    this.cycleRange,
    this.cycleType,
    this.daysUntilClose,
  }) : selectedOrderBy = selectedOrderBy ?? OrderBy.dateDesc,
       services = services ?? const [];

  /// The services of the current billing cycle — the one window the home
  /// reports on, set entirely by the Payment Cycle setting.
  final List<Service> services;
  final OrderBy selectedOrderBy;

  /// The cycle's resolved window. Null until the first fetch.
  final DateRange? cycleRange;

  /// Which kind of cycle [cycleRange] came from — monthly, fortnightly,
  /// weekly or custom — so the earnings card's own heading can name the
  /// window it actually is ("este mês" only fits a monthly cycle) instead of
  /// a name that happens to be wrong for whoever pays fortnightly. Null
  /// until the first fetch.
  final BillingCycleType? cycleType;

  /// Days left until the cycle is paid out.
  final int? daysUntilClose;

  /// "Today" as seen by the app clock, so the daily slice does not depend on
  /// `DateTime.now()` being called at render time. Null until the first fetch.
  final DateTime? referenceDate;

  /// Currency the aggregated totals are expressed in (the user's profile
  /// default). Each service is converted into it before summing, so
  /// mixed-currency services aggregate correctly.
  final SupportedCurrency defaultCurrency;

  /// Rate snapshots covering the dates of [services].
  final RateBook rateBook;

  /// Totals for the whole cycle, every service converted into
  /// [defaultCurrency] before being summed.
  ///
  /// Not cached here: this class mixes in [Equatable], which the analyzer
  /// treats as `@immutable`, so a memoizing field on it trades one warning
  /// for another. A caller that needs this more than once in a build should
  /// read it once and pass the result down — see `_DashboardContent.build`.
  ServiceTotals get totals => ServiceTotals.from(
    services,
    currency: defaultCurrency,
    rateBook: rateBook,
  );

  /// Totals for [todayServices] alone, for the daily section header.
  ServiceTotals get todayTotals => ServiceTotals.from(
    todayServices,
    currency: defaultCurrency,
    rateBook: rateBook,
  );

  /// The services performed on [referenceDate], keeping the order already
  /// applied to [services].
  List<Service> get todayServices => referenceDate == null
      ? const []
      : services
            .where(
              (service) =>
                  service.date.calculateDifference(referenceDate!) == 0,
            )
            .toList();

  @override
  DashboardState copyWith({
    BaseStateStatus? status,
    String? callbackMessage,
    List<Service>? services,
    OrderBy? selectedOrderBy,
    SupportedCurrency? defaultCurrency,
    RateBook? rateBook,
    DateTime? referenceDate,
    DateRange? cycleRange,
    BillingCycleType? cycleType,
    int? daysUntilClose,
  }) {
    return DashboardState(
      status: status ?? this.status,
      callbackMessage: callbackMessage ?? this.callbackMessage,
      services: services ?? this.services,
      selectedOrderBy: selectedOrderBy ?? this.selectedOrderBy,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      rateBook: rateBook ?? this.rateBook,
      referenceDate: referenceDate ?? this.referenceDate,
      cycleRange: cycleRange ?? this.cycleRange,
      cycleType: cycleType ?? this.cycleType,
      daysUntilClose: daysUntilClose ?? this.daysUntilClose,
    );
  }

  @override
  List<Object?> get props => [
    services,
    selectedOrderBy,
    defaultCurrency,
    rateBook,
    referenceDate,
    cycleRange,
    cycleType,
    daysUntilClose,
    status,
    callbackMessage,
  ];
}
