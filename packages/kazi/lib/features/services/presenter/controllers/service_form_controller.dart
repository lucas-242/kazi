import 'dart:async';

import 'package:kazi/features/clients/domain/models/client_entry.dart';
import 'package:kazi/features/clients/domain/repositories/clients_repository.dart';
import 'package:kazi/features/clients/presenter/controllers/clients_controller.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/domain/models/service_type.dart';
import 'package:kazi/features/services/domain/repositories/service_type_repository.dart';
import 'package:kazi/features/services/domain/repositories/services_repository.dart';
import 'package:kazi/features/services/presenter/controllers/service_types_controller.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/core/utils/base_notifier.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

import 'service_form_state.dart';

part 'service_form_controller.g.dart';

@riverpod
class ServiceFormController extends _$ServiceFormController
    with BaseAsyncNotifier<ServiceFormState> {
  ServicesRepository get _servicesRepository =>
      ref.read(servicesRepositoryProvider);

  ServiceTypeRepository get _serviceTypeRepository =>
      ref.read(serviceTypeRepositoryProvider);

  AuthService get _authService => ref.read(authServiceProvider);

  ClientsRepository get _clientsRepository =>
      ref.read(clientsRepositoryProvider);

  @override
  FutureOr<ServiceFormState> build({Service? service}) async {
    try {
      final userId = _authService.user!.uid;
      final types = await _getServiceTypes(userId);
      final clients = await _getClients(userId);

      // The form always renders (never an empty state): a user with no service
      // types or clients can create them inline via the quick-add sheets.
      return ServiceFormState(
        status: BaseStateStatus.readyToUserInput,
        userId: userId,
        serviceTypes: types,
        clients: clients,
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

  Future<List<ClientEntry>> _getClients(String userId) async {
    return _clientsRepository.getClients(userId, limit: 100);
  }

  void onChangeClient(DropdownItem? dropdownItem) {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        service: current.service.copyWith(
          clientId: dropdownItem?.value,
          // Denormalize the name so the service keeps a historical snapshot of
          // who it was performed for (see [Service.clientName]).
          clientName: dropdownItem?.label,
        ),
      ),
    );
  }

  /// Creates a service type from the quick-add sheet and appends it to the
  /// in-memory list (no refetch), auto-selecting it on the current service. The
  /// app-wide [ServiceTypesController] list is kept in sync as well. Throws an
  /// [AppError] on validation failure for the sheet to surface.
  Future<void> quickAddServiceType({
    required String name,
    double? defaultValue,
    double? discountPercent,
  }) async {
    final current = state.asData?.value;
    if (current == null) return;

    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ClientError(
        KaziLocalizations.current.requiredProperty(
          KaziLocalizations.current.serviceType,
        ),
      );
    }
    if (current.serviceTypes.any((type) => type.name == trimmedName)) {
      throw ClientError(
        KaziLocalizations.current.alreadyExists(
          KaziLocalizations.current.serviceType,
        ),
      );
    }

    final created = await _serviceTypeRepository.add(
      ServiceType(
        userId: current.userId,
        name: trimmedName,
        defaultValue: defaultValue,
        discountPercent: discountPercent,
      ),
    );

    final newTypes = List<ServiceType>.from(current.serviceTypes)..add(created);
    state = AsyncData(
      current.copyWith(
        serviceTypes: newTypes,
        service: current.service.copyWith(
          type: created,
          typeId: created.id,
          value: created.defaultValue,
          discountPercent: created.discountPercent,
        ),
      ),
    );

    ref.read(serviceTypesControllerProvider.notifier).appendServiceType(created);
  }

  /// Creates a client from the quick-add sheet and appends it to the in-memory
  /// list (no refetch), auto-selecting it on the current service. The app-wide
  /// [ClientsController] list is kept in sync as well. Throws an [AppError] on
  /// validation failure for the sheet to surface.
  Future<void> quickAddClient({
    required String identifier,
    required String name,
    required String phone,
  }) async {
    final current = state.asData?.value;
    if (current == null) return;

    final trimmedIdentifier = identifier.trim();
    final trimmedName = name.trim();
    final trimmedPhone = phone.trim();
    if (trimmedIdentifier.isEmpty) {
      throw ClientError(
        KaziLocalizations.current.requiredProperty(
          KaziLocalizations.current.cpfCnpj,
        ),
      );
    }
    if (trimmedName.isEmpty) {
      throw ClientError(
        KaziLocalizations.current.requiredProperty(
          KaziLocalizations.current.name,
        ),
      );
    }
    if (trimmedPhone.isEmpty) {
      throw ClientError(
        KaziLocalizations.current.requiredProperty(
          KaziLocalizations.current.phone,
        ),
      );
    }

    final user = User(
      id: 0,
      name: trimmedName,
      email: '',
      identifier: trimmedIdentifier,
      birthDate: DateTime(2000),
      userType: UserType.client,
      authToken: '',
      refreshToken: '',
      authExpires: DateTime(2100),
      phones: [trimmedPhone],
    );

    final id = await _clientsRepository.add(current.userId, user);
    final ClientEntry entry = (
      id: id,
      info: ClientInfo(
        user: user,
        lastServiceName: '',
        lastServiceDate: DateTime(2000),
        mostUsedServices: const {},
      ),
    );

    final newClients = List<ClientEntry>.from(current.clients)..add(entry);
    state = AsyncData(
      current.copyWith(
        clients: newClients,
        service: current.service.copyWith(
          clientId: id,
          clientName: trimmedName,
        ),
      ),
    );

    ref.read(clientsControllerProvider.notifier).appendClient(entry);
  }

  /// Denormalizes the just-saved service onto its client so the clients list
  /// card can show the last service without an extra query. Best-effort: any
  /// failure is swallowed by the repository.
  Future<void> _denormalizeLastService(ServiceFormState state) async {
    final clientId = state.service.clientId;
    if (clientId == null || clientId.isEmpty) return;

    final typeName = state.serviceTypes
        .where((type) => type.id == state.service.typeId)
        .map((type) => type.name)
        .firstOrNull;

    await _clientsRepository.updateLastService(
      clientId,
      typeName ?? '',
      state.service.date,
    );
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
      await _denormalizeLastService(latest);
      final reviewManager = await ref.read(inAppReviewManagerProvider.future);
      await reviewManager.onServiceCreated();
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
      await _denormalizeLastService(latest);
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
    final serviceType = current.serviceTypes.firstWhere(
      (st) => st.id == dropdownItem.value,
    );
    state = AsyncData(
      current.copyWith(
        service: current.service.copyWith(
          type: serviceType,
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
