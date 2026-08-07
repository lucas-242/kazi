import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/domain/models/service_type.dart';
import 'package:kazi/features/services/domain/repositories/service_type_repository.dart';
import 'package:kazi/features/services/domain/repositories/services_repository.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/services/domain/services/services_service.dart';
import 'package:kazi/core/utils/base_notifier.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceTypeRepository, ServiceType;

import 'dashboard_state.dart';

part 'dashboard_controller.g.dart';

@Riverpod(keepAlive: true)
class DashboardController extends _$DashboardController
    with BaseNotifier<DashboardState> {
  ServicesRepository get _serviceProvidedRepository =>
      ref.read(servicesRepositoryProvider);

  ServiceTypeRepository get _serviceTypeRepository =>
      ref.read(serviceTypeRepositoryProvider);

  AuthService get _authService => ref.read(authServiceProvider);

  ServicesService get _servicesService => ref.read(servicesServiceProvider);

  @override
  DashboardState build() {
    // Recompute totals when the user switches their profile default currency.
    ref.listen(kaziDefaultCurrencyProvider, (_, next) {
      state = state.copyWith(defaultCurrency: next);
    });
    return DashboardState(
      status: BaseStateStatus.loading,
      defaultCurrency: ref.read(kaziDefaultCurrencyProvider),
    );
  }

  Future<void> onInit() async {
    try {
      final result = await Future.wait<dynamic>([
        _getServiceTypes(),
        _getServices(),
      ]);

      await _handleServices(result[1]);
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

  Future<List<Service>> _getServices() async {
    final today = _servicesService.now;
    final result = await _serviceProvidedRepository.get(
      _authService.user!.uid,
      today,
    );
    return result;
  }

  Future<void> onRefresh() async {
    try {
      state = state.copyWith(status: BaseStateStatus.loading);
      final result = await _getServices();
      _handleServices(result);
    } on AppError catch (exception) {
      onAppError(exception);
    } catch (exception) {
      unexpectedError(exception);
    }
  }

  Future<void> _handleServices(List<Service> services) async {
    try {
      final types = await _getServiceTypes();
      var newServices = _servicesService.addServiceTypeToServices(
        services,
        types,
      );

      // Rates first: ordering by value and summing both need every service
      // expressed in the same currency.
      final rateBook = await _loadRateBook(newServices);

      newServices = _servicesService.orderServices(
        newServices,
        state.selectedOrderBy,
        currency: state.defaultCurrency,
        rateBook: rateBook,
      );

      final newStatus = services.isEmpty
          ? BaseStateStatus.noData
          : BaseStateStatus.success;

      state = state.copyWith(
        status: newStatus,
        services: newServices,
        rateBook: rateBook,
      );
    } on AppError catch (exception) {
      onAppError(exception);
    } catch (exception) {
      unexpectedError(exception);
    }
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
}
