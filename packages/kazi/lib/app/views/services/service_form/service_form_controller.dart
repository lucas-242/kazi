import 'dart:async';

import 'package:kazi/app/models/service.dart';
import 'package:kazi/app/models/service_type.dart';
import 'package:kazi/app/repositories/service_type_repository/service_type_repository.dart';
import 'package:kazi/app/repositories/services_repository/services_repository.dart';
import 'package:kazi/app/services/auth_service/auth_service.dart';
import 'package:kazi/app/shared/utils/base_state.dart';
import 'package:kazi/injector_container.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'service_form_state.dart';

part 'service_form_controller.g.dart';

mixin BaseCubit<T extends BaseState> on $AsyncNotifier<T> {
  void onAppError(AppError error) {
    Log.error(error.message);
    final current = state.asData?.value;
    if (current == null) {
      return;
    }
    state = AsyncData(
      current.copyWith(
            callbackMessage: error.message,
            status: BaseStateStatus.error,
          )
          as T,
    );
  }

  void unexpectedError(Object exception) {
    Log.error(exception);
    final current = state.asData?.value;
    if (current == null) {
      return;
    }
    state = AsyncData(
      current.copyWith(
            callbackMessage: KaziLocalizations.current.errorUnknowError,
            status: BaseStateStatus.error,
          )
          as T,
    );
  }
}

@riverpod
class ServiceFormController extends _$ServiceFormController
    with BaseCubit<ServiceFormState> {
  ServicesRepository get _servicesRepository =>
      serviceLocator.get<ServicesRepository>();

  ServiceTypeRepository get _serviceTypeRepository =>
      serviceLocator.get<ServiceTypeRepository>();

  AuthService get _authService => serviceLocator.get<AuthService>();

  @override
  FutureOr<ServiceFormState> build({Service? service}) async {
    try {
      final userId = _authService.user!.uid;
      final types = await _getServiceTypes(userId);

      final status = types.isEmpty
          ? BaseStateStatus.noData
          : BaseStateStatus.readyToUserInput;

      return ServiceFormState(
        status: status,
        userId: userId,
        serviceTypes: types,
        service: service,
      );
    } on AppError catch (exception) {
      final userId = _authService.user?.uid ?? '';
      return ServiceFormState(
        status: BaseStateStatus.error,
        callbackMessage: exception.message,
        userId: userId,
        service: service,
      );
    } catch (exception) {
      final userId = _authService.user?.uid ?? '';
      return ServiceFormState(
        status: BaseStateStatus.error,
        callbackMessage: KaziLocalizations.current.errorUnknowError,
        userId: userId,
        service: service,
      );
    }
  }

  Future<List<ServiceType>> _getServiceTypes(String userId) async {
    final result = await _serviceTypeRepository.get(userId);
    return result;
  }

  Future<void> addService() async {
    final current = state.asData?.value;
    if (current == null) return;

    try {
      _checkServiceValidity(current);
      state = AsyncData(current.copyWith(status: BaseStateStatus.loading));
      final latest = state.asData?.value;
      if (latest == null) return;
      await _servicesRepository.add(latest.service, latest.quantity);
      _cleanState();
    } on AppError catch (exception) {
      onAppError(exception);
    } catch (exception) {
      unexpectedError(exception);
    }
  }

  Future<void> updateService() async {
    final current = state.asData?.value;
    if (current == null) return;

    try {
      _checkServiceValidity(current);
      state = AsyncData(current.copyWith(status: BaseStateStatus.loading));
      final latest = state.asData?.value;
      if (latest == null) return;
      await _servicesRepository.update(latest.service);
      _cleanState();
    } on AppError catch (exception) {
      onAppError(exception);
    } catch (exception) {
      unexpectedError(exception);
    }
  }

  void _cleanState() {
    final current = state.asData?.value;
    if (current == null) return;
    final userId = _authService.user!.uid;
    state = AsyncData(
      current.copyWith(
        status: BaseStateStatus.success,
        quantity: 1,
        service: Service(userId: userId),
      ),
    );
  }

  void onChangeService(Service service) {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(service: service));
  }

  void onChangeServiceDescription(String value) {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(service: current.service.copyWith(description: value)),
    );
  }

  void onChangeServiceType(DropdownItem dropdownItem) {
    final current = state.asData?.value;
    if (current == null) return;
    final defaultValue = _getDefaultValueToService(current, dropdownItem.value);
    final discountValue = _getDefaultDiscountToService(
      current,
      dropdownItem.value,
    );
    state = AsyncData(
      current.copyWith(
        service: current.service.copyWith(
          typeId: dropdownItem.value,
          value: defaultValue,
          discountPercent: discountValue,
        ),
      ),
    );
  }

  double? _getDefaultValueToService(ServiceFormState current, String typeId) {
    final serviceType = current.serviceTypes.firstWhere(
      (st) => st.id == typeId,
    );
    return serviceType.defaultValue;
  }

  double? _getDefaultDiscountToService(
    ServiceFormState current,
    String typeId,
  ) {
    final serviceType = current.serviceTypes.firstWhere(
      (st) => st.id == typeId,
    );
    return serviceType.discountPercent;
  }

  void onChangeServiceValue(double value) {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(service: current.service.copyWith(value: value)),
    );
  }

  void onChangeServicesQuantity(String value) {
    final current = state.asData?.value;
    if (current == null) return;
    final finalValue = int.tryParse(value);
    state = AsyncData(current.copyWith(quantity: finalValue));
  }

  void onChangeServiceDiscount(double value) {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        service: current.service.copyWith(discountPercent: value),
      ),
    );
  }

  void onChangeServiceDate(DateTime? value) {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(service: current.service.copyWith(date: value)),
    );
  }

  void _checkServiceValidity(ServiceFormState current) {
    if (current.service.typeId.isEmpty) {
      throw ClientError(
        KaziLocalizations.current.requiredProperty(
          KaziLocalizations.current.serviceType,
        ),
      );
    }
  }
}
