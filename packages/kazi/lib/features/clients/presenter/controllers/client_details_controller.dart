import 'package:kazi/core/utils/base_notifier.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/clients/domain/models/client_entry.dart';
import 'package:kazi/features/clients/domain/repositories/clients_repository.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/domain/services/service_organizer.dart';
import 'package:kazi/features/services/presenter/controllers/catalog_controller.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart' hide Service;

import 'client_details_state.dart';

part 'client_details_controller.g.dart';

@riverpod
class ClientDetailsController extends _$ClientDetailsController
    with BaseNotifier<ClientDetailsState> {
  static const int _servicesPageSize = 15;

  ClientsRepository get _clientsRepository =>
      ref.read(clientsRepositoryProvider);

  AuthService get _authService => ref.read(authServiceProvider);

  ServiceOrganizer get _serviceOrganizer => ref.read(serviceOrganizerProvider);

  String get _ownerId => _authService.user!.uid;

  /// Joins each service to its catalog item, which is what gives the history
  /// rows their name and their colour — a service stores only the id. Loads
  /// the catalog first when nothing else has: the ficha is reachable without
  /// ever passing through the catalog screen.
  Future<List<Service>> _withCatalogItems(List<Service> services) async {
    if (services.isEmpty) return services;

    var catalogItems = ref.read(catalogControllerProvider).catalogItems;
    if (catalogItems.isEmpty) {
      await ref.read(catalogControllerProvider.notifier).onInit();
      catalogItems = ref.read(catalogControllerProvider).catalogItems;
    }

    return _serviceOrganizer.addCatalogItemToServices(services, catalogItems);
  }

  /// The oldest service performed for this client, which is the date the ficha
  /// prefers over the record's own — a history entered after the fact says
  /// when the person really became a client.
  ///
  /// Costs a query only when there is more history than the loaded page: the
  /// page is ordered newest first, so a complete one already ends on it.
  Future<DateTime?> _firstServiceDate(
    String clientId,
    List<Service> history, {
    required bool hasReachedMax,
  }) async {
    if (history.isEmpty) return null;
    if (hasReachedMax) return history.last.date;

    return _clientsRepository.getFirstServiceDate(_ownerId, clientId);
  }

  @override
  ClientDetailsState build({required String clientId}) {
    _load(clientId);
    return ClientDetailsState(status: BaseStateStatus.loading);
  }

  /// Pushes an edited client into the details state so the screen shows the new
  /// data without refetching from the backend. The service history is preserved
  /// by the caller when rebuilding the entry.
  void setClient(ClientEntry entry) {
    state = state.copyWith(status: BaseStateStatus.success, client: entry);
  }

  Future<void> onRefresh() => _load(clientId);

  Future<void> _load(String clientId) async {
    try {
      final client = await _clientsRepository.getClientDetails(
        _ownerId,
        clientId,
      );
      if (client == null) {
        state = state.copyWith(status: BaseStateStatus.noData);
        return;
      }

      final history = await _withCatalogItems(
        await _clientsRepository.getServiceHistory(
          _ownerId,
          clientId,
          limit: _servicesPageSize,
        ),
      );
      final hasReachedMax = history.length < _servicesPageSize;

      state = state.copyWith(
        status: BaseStateStatus.success,
        client: client,
        serviceHistory: history,
        firstServiceDate: await _firstServiceDate(
          clientId,
          history,
          hasReachedMax: hasReachedMax,
        ),
        hasReachedMaxServices: hasReachedMax,
      );
    } on AppError catch (exception) {
      onAppError(exception);
    } catch (exception) {
      unexpectedError(exception);
    }
  }

  /// Fetches the next page of the service history and appends it to the state.
  Future<void> loadMoreServices() async {
    if (state.hasReachedMaxServices ||
        state.isLoadingMoreServices ||
        state.client == null ||
        state.serviceHistory.isEmpty) {
      return;
    }

    try {
      state = state.copyWith(isLoadingMoreServices: true);
      final newServices = await _withCatalogItems(
        await _clientsRepository.getServiceHistory(
          _ownerId,
          state.client!.id,
          limit: _servicesPageSize,
          startAfterDate: state.serviceHistory.last.date,
        ),
      );
      state = state.copyWith(
        serviceHistory: [...state.serviceHistory, ...newServices],
        hasReachedMaxServices: newServices.length < _servicesPageSize,
        isLoadingMoreServices: false,
      );
    } on AppError catch (exception) {
      state = state.copyWith(isLoadingMoreServices: false);
      onAppError(exception);
    } catch (exception) {
      state = state.copyWith(isLoadingMoreServices: false);
      unexpectedError(exception);
    }
  }
}
