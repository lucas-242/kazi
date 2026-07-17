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

import 'service_landing_state.dart';

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
  ServiceLandingState build() => ServiceLandingState(
    status: BaseStateStatus.loading,
    startDate: _servicesService.now,
    endDate: _servicesService.now,
  );

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
      services = _servicesService.orderServices(
        services,
        state.selectedOrderBy,
      );

      final newStatus = fetchResult.isEmpty
          ? BaseStateStatus.noData
          : BaseStateStatus.success;
      state = state.copyWith(
        status: newStatus,
        services: services,
        startDate: startDate,
        endDate: endDate,
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
    );
    onInit();
  }

  void onChangeOrderBy(OrderBy orderBy) {
    final services = _servicesService.orderServices(state.services, orderBy);
    state = state.copyWith(services: services, selectedOrderBy: orderBy);
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
