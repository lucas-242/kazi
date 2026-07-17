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
  DashboardState build() => DashboardState(status: BaseStateStatus.loading);

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
      newServices = _servicesService.orderServices(
        newServices,
        state.selectedOrderBy,
      );

      final newStatus = services.isEmpty
          ? BaseStateStatus.noData
          : BaseStateStatus.success;

      state = state.copyWith(status: newStatus, services: newServices);
    } on AppError catch (exception) {
      onAppError(exception);
    } catch (exception) {
      unexpectedError(exception);
    }
  }
}
