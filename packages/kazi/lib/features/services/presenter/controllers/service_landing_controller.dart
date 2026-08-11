import 'package:kazi/features/services/domain/models/receipt_filter.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/domain/models/service_type.dart';
import 'package:kazi/features/services/domain/models/service_view.dart';
import 'package:kazi/features/services/domain/repositories/service_type_repository.dart';
import 'package:kazi/features/services/domain/repositories/services_repository.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/services/domain/services/services_service.dart';
import 'package:kazi/core/utils/base_notifier.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceTypeRepository, ServiceType;

import 'service_landing_state.dart';
import 'service_receipt_controller.dart';

part 'service_landing_controller.g.dart';

@Riverpod(keepAlive: true)
class ServiceLandingController extends _$ServiceLandingController
    with BaseNotifier<ServiceLandingState> {
  ServicesRepository get _serviceProvidedRepository =>
      ref.read(servicesRepositoryProvider);

  ServiceTypeRepository get _serviceTypeRepository =>
      ref.read(serviceTypeRepositoryProvider);

  AuthService get _authService => ref.read(authServiceProvider);

  ServicesService get _servicesService => ref.read(servicesServiceProvider);

  @override
  ServiceLandingState build() {
    // Recompute totals when the user switches their profile default currency.
    ref.listen(kaziDefaultCurrencyProvider, (_, next) {
      state = state.copyWith(defaultCurrency: next);
    });
    return ServiceLandingState(
      status: BaseStateStatus.loading,
      startDate: _servicesService.now,
      endDate: _servicesService.now,
      defaultCurrency: ref.read(kaziDefaultCurrencyProvider),
    );
  }

  /// Rate snapshots for every date present in [services]. Fail-open: an empty
  /// book still renders, with the totals flagged as incomplete.
  Future<RateBook> _loadRateBook(List<Service> services) async {
    try {
      final history = await ref.read(exchangeRateHistoryServiceProvider.future);
      return await history.bookFor(
        services.map((service) => service.effectiveRateDate),
      );
    } catch (_) {
      return const RateBook.empty();
    }
  }

  Future<void> onInit() async {
    try {
      final range = _servicesService.getRangeDateByFastSearch(state.fastSearch);
      final startDate = range['startDate']!;
      final endDate = range['endDate']!;
      final result = await _getServices(startDate, endDate);
      _handleGetServices(result, startDate, endDate);
    } on AppError catch (exception) {
      onAppError(exception);
    } catch (exception) {
      unexpectedError(exception);
    }
  }

  Future<List<Service>> _getServices(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final result = await _serviceProvidedRepository.get(
      _authService.user!.uid,
      startDate,
      endDate,
    );
    return result;
  }

  Future<void> _handleGetServices(
    List<Service> fetchResult, [
    DateTime? startDate,
    DateTime? endDate,
  ]) async {
    try {
      final types = await _getServiceTypes();
      var services = _servicesService.addServiceTypeToServices(
        fetchResult,
        types,
      );
      // Rates first: ordering by value and summing both need every service
      // expressed in the same currency.
      final rateBook = await _loadRateBook(services);

      services = _servicesService.orderServices(
        services,
        state.selectedOrderBy,
        currency: state.defaultCurrency,
        rateBook: rateBook,
      );

      final newStatus = fetchResult.isEmpty
          ? BaseStateStatus.noData
          : BaseStateStatus.success;
      state = state.copyWith(
        status: newStatus,
        services: services,
        startDate: startDate,
        endDate: endDate,
        rateBook: rateBook,
      );
    } on AppError catch (exception) {
      onAppError(exception);
    } catch (exception) {
      unexpectedError(exception);
    }
  }

  Future<List<ServiceType>> _getServiceTypes() async {
    final result = await _serviceTypeRepository.get(_authService.user!.uid);
    return result;
  }

  Future<void> onRefresh() async {
    try {
      state = state.copyWith(status: BaseStateStatus.loading);
      final range = _servicesService.getRangeDateByFastSearch(state.fastSearch);
      final startDate = range['startDate']!;
      final endDate = range['endDate']!;
      final result = await _getServices(startDate, endDate);
      _handleGetServices(result, startDate, endDate);
    } on AppError catch (exception) {
      onAppError(exception);
    } catch (exception) {
      unexpectedError(exception);
    }
  }

  Future<void> deleteService(Service service) async {
    try {
      state = state.copyWith(status: BaseStateStatus.loading);
      await _serviceProvidedRepository.delete(service.id);
      final newList = await _getServices(state.startDate, state.endDate);
      _handleGetServices(newList);
    } on AppError catch (exception) {
      onAppError(exception);
    } catch (exception) {
      unexpectedError(exception);
    }
  }

  Future<void> onApplyFilters([
    FastSearch? fastSearch,
    DateTime? startDate,
    DateTime? endDate,
  ]) async {
    if (fastSearch != null && fastSearch != FastSearch.custom) {
      await _onChageSelectedFastSearch(fastSearch);
    } else if (startDate != null && endDate != null) {
      await _onChangeDate(startDate, endDate);
    }
  }

  Future<void> _onChageSelectedFastSearch(FastSearch fastSearch) async {
    try {
      if (fastSearch == state.fastSearch) return;

      final range = _servicesService.getRangeDateByFastSearch(fastSearch);

      state = state.copyWith(
        status: BaseStateStatus.loading,
        fastSearch: fastSearch,
        startDate: range['startDate']!,
        endDate: range['endDate']!,
        didFiltersChange: true,
      );
      final fetchResult = await _getServices(
        range['startDate']!,
        range['endDate']!,
      );
      _handleGetServices(fetchResult);
    } on AppError catch (exception) {
      onAppError(exception);
    } catch (exception) {
      unexpectedError(exception);
    }
  }

  Future<void> _onChangeDate(DateTime startDate, DateTime endDate) async {
    try {
      state = state.copyWith(
        status: BaseStateStatus.loading,
        startDate: startDate,
        endDate: endDate,
        fastSearch: FastSearch.custom,
        didFiltersChange: true,
      );
      final fetchResult = await _getServices(startDate, endDate);
      _handleGetServices(fetchResult, startDate, endDate);
    } on AppError catch (exception) {
      onAppError(exception);
    } catch (exception) {
      unexpectedError(exception);
    }
  }

  Future<void> onCleanFilters() async {
    state = ServiceLandingState(
      status: BaseStateStatus.loading,
      startDate: _servicesService.now,
      endDate: _servicesService.now,
      defaultCurrency: state.defaultCurrency,
      rateBook: state.rateBook,
      // Carried over: clearing filters is about what is listed, not about how
      // it is represented. Snapping back to the list would be a second,
      // unasked-for change.
      view: state.view,
    );
    onInit();
  }

  /// Flips between the list and the summary. Same services, same filters —
  /// nothing is refetched.
  void onChangeView(ServiceView view) {
    if (view == state.view) return;
    state = state.copyWith(view: view);
  }

  /// Both chip filters run over the list already in memory, so neither
  /// re-queries Firestore; the period is the only thing the query knows about.
  void onChangeReceiptFilter(ReceiptFilter receiptFilter) {
    if (receiptFilter == state.receiptFilter) return;
    state = state.copyWith(
      receiptFilter: receiptFilter,
      didFiltersChange: true,
    );
  }

  /// Narrows to one client, or to every client when [clientId] is null.
  void onSelectClient(String? clientId) {
    if (clientId == state.clientId) return;
    state = state.copyWith(
      clientId: clientId,
      didFiltersChange: state.didFiltersChange || clientId != null,
    );
  }

  void onChangeOrderBy(OrderBy orderBy) {
    final services = _servicesService.orderServices(
      state.services,
      orderBy,
      currency: state.defaultCurrency,
      rateBook: state.rateBook,
    );
    state = state.copyWith(services: services, selectedOrderBy: orderBy);
  }

  /// Applies payment stamps already written by `ServiceReceiptController`,
  /// patching the in-memory list instead of refetching. Ids not in this list
  /// are ignored, so the same call can be broadcast to every list.
  void applyReceipt(Map<String, DateTime?> stamps) {
    if (stamps.isEmpty) return;

    state = state.copyWith(
      services: [
        for (final service in state.services)
          if (!stamps.containsKey(service.id))
            service
          else if (stamps[service.id] case final DateTime at)
            service.markedReceivedAt(at)
          else
            service.notReceived(),
      ],
    );
  }

  /// Stamps every service currently listed that is still owed.
  ///
  /// Deliberately scoped to `state.visibleServices` — what the user can see —
  /// rather than to the billing cycle or to everything fetched: this tab has a
  /// window of its own, and the receipt and client chips narrow it further.
  /// Stamping beyond the visible list would pay off services the user never
  /// looked at, and the button's own count is drawn from the same list.
  ///
  /// Skips the already-received, or the batch would rewrite their stamps and
  /// move people's payment dates.
  Future<List<String>> markListedAsReceived() async {
    final pending = state.visibleServices.where(
      (service) => !service.isReceived,
    );
    return ref
        .read(serviceReceiptControllerProvider.notifier)
        .setReceived(pending.toList(), received: true);
  }

  Future<void> onChangeServices() async {
    try {
      state = state.copyWith(status: BaseStateStatus.loading);
      final result = await _getServices(state.startDate, state.endDate);
      _handleGetServices(result);
    } on AppError catch (exception) {
      onAppError(exception);
    } catch (exception) {
      unexpectedError(exception);
    }
  }
}
