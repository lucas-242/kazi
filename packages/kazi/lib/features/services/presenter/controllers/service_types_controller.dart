import 'package:kazi/features/services/domain/models/service_type.dart';
import 'package:kazi/features/services/domain/repositories/service_type_repository.dart';
import 'package:kazi/features/services/domain/repositories/services_repository.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/core/utils/base_notifier.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/injector_container.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

import 'service_types_state.dart';

part 'service_types_controller.g.dart';

@Riverpod(keepAlive: true)
class ServiceTypesController extends _$ServiceTypesController
    with BaseNotifier<ServiceTypesState> {
  ServiceTypeRepository get _serviceTypeRepository =>
      serviceLocator.get<ServiceTypeRepository>();

  ServicesRepository get _serviceRepository =>
      serviceLocator.get<ServicesRepository>();

  AuthService get _authService => serviceLocator.get<AuthService>();

  @override
  ServiceTypesState build() => ServiceTypesState(
    userId: _authService.user!.uid,
    status: BaseStateStatus.loading,
  );

  Future<void> onInit() async {
    try {
      final types = await _fetchServiceTypes();

      final status = types.isEmpty
          ? BaseStateStatus.noData
          : BaseStateStatus.readyToUserInput;

      state = state.copyWith(status: status, serviceTypes: types);
    } on AppError catch (exception) {
      onAppError(exception);
    } catch (exception) {
      unexpectedError(exception);
    }
  }

  Future<List<ServiceType>> _fetchServiceTypes() async {
    final result = await _serviceTypeRepository.get(_authService.user!.uid);
    return result;
  }

  Future<void> getServiceTypes() async {
    try {
      state = state.copyWith(status: BaseStateStatus.loading);
      final result = await _fetchServiceTypes();
      final newStatus = result.isEmpty
          ? BaseStateStatus.noData
          : BaseStateStatus.readyToUserInput;

      state = state.copyWith(status: newStatus, serviceTypes: result);
    } on AppError catch (exception) {
      onAppError(exception);
    } catch (exception) {
      unexpectedError(exception);
    }
  }

  Future<void> addServiceType() async {
    try {
      _checkServiceValidity();
      state = state.copyWith(status: BaseStateStatus.loading);
      final result = await _serviceTypeRepository.add(state.serviceType);
      final newList = List<ServiceType>.from(state.serviceTypes)..add(result);
      state = state.copyWith(
        status: BaseStateStatus.success,
        serviceTypes: newList,
        serviceType: ServiceType(userId: _authService.user!.uid),
      );
    } on AppError catch (exception) {
      onAppError(exception);
    } catch (exception) {
      unexpectedError(exception);
    }
  }

  Future<void> updateServiceType() async {
    try {
      _checkServiceValidity(state.serviceType.id);
      state = state.copyWith(status: BaseStateStatus.loading);
      await _serviceTypeRepository.update(state.serviceType);
      final newList = await _fetchServiceTypes();

      state = state.copyWith(
        status: BaseStateStatus.success,
        serviceTypes: newList,
        serviceType: ServiceType(userId: _authService.user!.uid),
      );
    } on AppError catch (exception) {
      onAppError(exception);
    } catch (exception) {
      unexpectedError(exception);
    }
  }

  Future<void> deleteServiceType(ServiceType serviceType) async {
    try {
      state = state.copyWith(status: BaseStateStatus.loading);
      await _checkServiceTypeIsInUse(serviceType.id);
      await _serviceTypeRepository.delete(serviceType.id);
      final newList = await _fetchServiceTypes();

      state = state.copyWith(
        status: BaseStateStatus.success,
        serviceTypes: newList,
      );
    } on AppError catch (exception) {
      onAppError(exception);
    } catch (exception) {
      unexpectedError(exception);
    }
  }

  void eraseServiceType() {
    state = state.copyWith(
      serviceType: ServiceType(userId: _authService.user!.uid),
    );
  }

  void changeServiceType(ServiceType serviceType) {
    state = state.copyWith(serviceType: serviceType);
  }

  void changeServiceTypeName(String value) {
    state = state.copyWith(serviceType: state.serviceType.copyWith(name: value));
  }

  void changeServiceTypeDefaultValue(double value) => state = state.copyWith(
    serviceType: state.serviceType.copyWith(defaultValue: value),
  );

  void changeServiceTypeDiscountPercent(double value) => state = state.copyWith(
    serviceType: state.serviceType.copyWith(discountPercent: value),
  );

  void _checkServiceValidity([String? idToExclude]) {
    if (state.serviceType.name.isEmpty) {
      throw ClientError(
        KaziLocalizations.current.requiredProperty(
          KaziLocalizations.current.serviceType,
        ),
      );
    }
    if (state.serviceTypes
        .where((type) => type.id != idToExclude)
        .map((e) => e.name)
        .contains(state.serviceType.name)) {
      throw ClientError(
        KaziLocalizations.current.alreadyExists(
          KaziLocalizations.current.serviceType,
        ),
      );
    }
  }

  Future<void> _checkServiceTypeIsInUse(String typeId) async {
    final userId = _authService.user!.uid;
    final count = await _serviceRepository.count(userId, typeId);
    if (count > 0) {
      throw ClientError(KaziLocalizations.current.errorCantDeleteServiceType);
    }
  }
}
