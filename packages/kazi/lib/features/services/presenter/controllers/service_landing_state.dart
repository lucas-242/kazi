import 'package:equatable/equatable.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/services/domain/models/receipt_filter.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/domain/models/service_breakdown.dart';
import 'package:kazi/features/services/domain/models/service_totals.dart';
import 'package:kazi/features/services/domain/models/service_view.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

/// Distinguishes "no client selected" from "clear the selected client" in
/// [ServiceLandingState.copyWith], where a plain null argument is
/// indistinguishable from an omitted one.
const Object _unset = Object();

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
    this.view = ServiceView.list,
    this.receiptFilter = ReceiptFilter.all,
    this.clientId,
  }) : services = services ?? [];
  final DateTime startDate;
  final DateTime endDate;
  final FastSearch fastSearch;
  final OrderBy selectedOrderBy;

  /// Everything fetched for the period. The two chip filters below narrow it
  /// in memory; see [visibleServices].
  final List<Service> services;
  final bool didFiltersChange;

  /// Currency the totals are expressed in (the user's profile default).
  final SupportedCurrency defaultCurrency;

  /// Rate snapshots covering the dates of [services].
  final RateBook rateBook;

  /// Which representation of [visibleServices] is on screen.
  final ServiceView view;

  final ReceiptFilter receiptFilter;

  /// Narrows the list to a single client. Null means every client.
  final String? clientId;

  /// What the user is actually looking at: [services] after the receipt and
  /// client chips. Everything downstream — the list, the totals, the
  /// breakdowns and the bulk "mark as received" — reads this, so the numbers
  /// always describe the rows on screen.
  List<Service> get visibleServices => services
      .where(
        (service) =>
            receiptFilter.allows(service) &&
            (clientId == null || service.clientId == clientId),
      )
      .toList();

  ServiceTotals get totals => ServiceTotals.from(
    visibleServices,
    currency: defaultCurrency,
    rateBook: rateBook,
  );

  ServiceBreakdown breakdownByType(String untypedLabel) =>
      ServiceBreakdown.byType(
        visibleServices,
        currency: defaultCurrency,
        rateBook: rateBook,
        untypedLabel: untypedLabel,
      );

  ServiceBreakdown get breakdownByClient => ServiceBreakdown.byClient(
    visibleServices,
    currency: defaultCurrency,
    rateBook: rateBook,
  );

  bool get hasSecondaryFilters =>
      receiptFilter != ReceiptFilter.all || clientId != null;

  /// The period has services but the chips hide all of them — the case that
  /// must keep the chips on screen instead of falling through to the empty
  /// screen, or there would be no way back.
  bool get isFilteredEmpty => services.isNotEmpty && visibleServices.isEmpty;

  /// Clients that actually have a service in this period, for the picker.
  ///
  /// Derived from the fetched list rather than from the clients repository:
  /// offering a client with nothing to show would be a filter that can only
  /// empty the screen. Ordered by name.
  List<({String id, String name})> get filterableClients {
    final byId = <String, String>{};

    for (final service in services) {
      final id = service.clientId;
      final name = service.clientName;
      if (id == null || id.isEmpty || name == null || name.isEmpty) continue;
      byId.putIfAbsent(id, () => name);
    }

    return byId.entries
        .map((entry) => (id: entry.key, name: entry.value))
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

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
    ServiceView? view,
    ReceiptFilter? receiptFilter,
    Object? clientId = _unset,
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
      view: view ?? this.view,
      receiptFilter: receiptFilter ?? this.receiptFilter,
      clientId: clientId == _unset ? this.clientId : clientId as String?,
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
    view,
    receiptFilter,
    clientId,
    status,
    callbackMessage,
  ];
}
