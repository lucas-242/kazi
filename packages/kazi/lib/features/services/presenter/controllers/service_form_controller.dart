import 'dart:async';
import 'dart:ui';

import 'package:kazi/core/utils/base_notifier.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/clients/domain/models/client_entry.dart';
import 'package:kazi/features/clients/domain/repositories/clients_repository.dart';
import 'package:kazi/features/clients/presenter/controllers/clients_controller.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/domain/models/service_type.dart';
import 'package:kazi/features/services/domain/repositories/service_type_repository.dart';
import 'package:kazi/features/services/domain/repositories/services_repository.dart';
import 'package:kazi/features/services/presenter/controllers/service_types_controller.dart';
import 'package:kazi/features/subscription/domain/freemium_gate.dart';
import 'package:kazi/features/subscription/domain/freemium_guard.dart';
import 'package:kazi/features/subscription/presenter/controllers/paywall_prompt_controller.dart';
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

  FreemiumGuard get _freemiumGuard => ref.read(freemiumGuardProvider);

  SupportedCurrency get _defaultCurrency =>
      ref.read(kaziDefaultCurrencyProvider);

  void _promptPaywall(LimitType limit) =>
      ref.read(paywallPromptControllerProvider.notifier).promptFor(limit);

  Future<ExchangeRateHistoryService> get _rateHistory =>
      ref.read(exchangeRateHistoryServiceProvider.future);

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

  Service _withDefaultCurrency(Service service) => service.currency.isEmpty
      ? service.copyWith(currency: _defaultCurrency.isoCode)
      : service;

  /// Stamps the currency and the rate snapshot the value is anchored to.
  ///
  /// The anchor follows the service's own date, not the moment it was typed in,
  /// so backdating a service converts with the rate that actually applied then.
  /// It is recomputed on every save because an edit can change either the date
  /// or the currency.
  Future<Service> _withRateAnchor(Service service) async {
    final withCurrency = _withDefaultCurrency(service);

    try {
      final history = await _rateHistory;
      return withCurrency.copyWith(
        rateDate: await history.resolveDateKey(withCurrency.date),
      );
    } catch (_) {
      // Offline: record the service's own day, which resolves once the shared
      // history covers it.
      return withCurrency.copyWith(
        rateDate: ExchangeRates.dateKeyOf(withCurrency.date),
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
        // Null means the user hit the picker's clear button. It needs the
        // explicit unlink, because `copyWith` cannot write a null.
        service: dropdownItem == null
            ? current.service.withoutClient()
            : current.service.copyWith(
                clientId: dropdownItem.value,
                // Denormalize the name so the service keeps a historical
                // snapshot of who it was performed for (see
                // [Service.clientName]).
                clientName: dropdownItem.label,
              ),
      ),
    );
  }

  Future<void> quickAddServiceType({
    required String name,
    double? defaultValue,
    double? commissionPercent,
    Color? color,
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

    final gate = await _freemiumGuard.checkAddServiceType(
      current.serviceTypes.length,
    );
    if (gate.isBlocked) {
      _promptPaywall(gate.blockedBy!);
      return;
    }

    final created = await _serviceTypeRepository.add(
      ServiceType(
        userId: current.userId,
        name: trimmedName,
        defaultValue: defaultValue,
        commissionPercent: commissionPercent,
        currency: _defaultCurrency.isoCode,
        color: color == null ? '' : KaziHexColor.encode(color),
      ),
    );

    final newTypes = List<ServiceType>.from(current.serviceTypes)..add(created);
    final typeCurrency = created.currency.isEmpty
        ? _defaultCurrency.isoCode
        : created.currency;
    state = AsyncData(
      current.copyWith(
        serviceTypes: newTypes,
        service: current.service.copyWith(
          type: created,
          typeId: created.id,
          value: created.defaultValue,
          // Concrete, never null: a service the user never opens the commission
          // field on must be worth all of its value, not none of it.
          commissionPercent: created.effectiveCommissionPercent ?? 100,
          currency: typeCurrency,
        ),
      ),
    );

    ref
        .read(serviceTypesControllerProvider.notifier)
        .appendServiceType(created);

    // Counts toward the ad frequency but never surfaces the ad inline: the user
    // is still filling out the service form.
    await ref
        .read(creationAdCoordinatorProvider.future)
        .then((coordinator) => coordinator.onCreationAction(canShowNow: false));
  }

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

    final gate = await _freemiumGuard.checkAddClient(current.userId);
    if (gate.isBlocked) {
      _promptPaywall(gate.blockedBy!);
      return;
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

    // Counts toward the ad frequency but never surfaces the ad inline: the user
    // is still filling out the service form.
    await ref
        .read(creationAdCoordinatorProvider.future)
        .then((coordinator) => coordinator.onCreationAction(canShowNow: false));
  }

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

      final gate = await _freemiumGuard.checkAddServices(
        current.userId,
        current.quantity,
      );
      if (gate.isBlocked) {
        _promptPaywall(gate.blockedBy!);
        return;
      }

      state = AsyncData(current.copyWith(status: BaseStateStatus.loading));
      final latest = state.asData?.value;
      if (latest == null) return;
      final serviceToSave = await _withRateAnchor(latest.service);
      await _servicesRepository.add(serviceToSave, latest.quantity);
      await _denormalizeLastService(latest);
      final reviewManager = await ref.read(inAppReviewManagerProvider.future);
      await reviewManager.onServiceCreated();
      await ref
          .read(creationAdCoordinatorProvider.future)
          .then((coordinator) => coordinator.onCreationAction());
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
      final serviceToSave = await _withRateAnchor(latest.service);
      await _servicesRepository.update(serviceToSave);
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
    final commission = _getDefaultCommissionToService(
      current,
      dropdownItem.value,
    );
    final serviceType = current.serviceTypes.firstWhere(
      (st) => st.id == dropdownItem.value,
    );
    // A service defaults to the currency of its type (which itself falls back
    // to the user's profile currency when unset).
    final typeCurrency = serviceType.currency.isEmpty
        ? _defaultCurrency.isoCode
        : serviceType.currency;
    state = AsyncData(
      current.copyWith(
        service: current.service.copyWith(
          type: serviceType,
          typeId: dropdownItem.value,
          // Start from the type's saved value; fall back to the default (0)
          // when the type has none configured, rather than keeping a stale one.
          value: defaultValue ?? 0,
          // A type with no commission configured means the user keeps
          // everything — 100, never 0, which would zero the service out.
          commissionPercent: commission ?? 100,
          currency: typeCurrency,
        ),
      ),
    );
  }

  void onChangeServiceCurrency(SupportedCurrency currency) {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        service: current.service.copyWith(currency: currency.isoCode),
      ),
    );
  }

  double? _getDefaultValueToService(ServiceFormState current, String typeId) {
    final serviceType = current.serviceTypes.firstWhere(
      (st) => st.id == typeId,
    );
    return serviceType.defaultValue;
  }

  double? _getDefaultCommissionToService(
    ServiceFormState current,
    String typeId,
  ) {
    final serviceType = current.serviceTypes.firstWhere(
      (st) => st.id == typeId,
    );
    return serviceType.effectiveCommissionPercent;
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

  void onChangeServiceCommission(double value) {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        service: current.service.copyWith(commissionPercent: value),
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
