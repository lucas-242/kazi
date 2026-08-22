import 'dart:async';
import 'dart:ui';

import 'package:kazi/core/services/domain/analytics_event.dart';
import 'package:kazi/features/services/domain/models/catalog_item.dart';
import 'package:kazi/features/services/domain/repositories/catalog_item_repository.dart';
import 'package:kazi/features/services/domain/repositories/services_repository.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/subscription/presenter/controllers/paywall_prompt_controller.dart';
import 'package:kazi/core/utils/base_notifier.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

import 'catalog_state.dart';

part 'catalog_controller.g.dart';

@Riverpod(keepAlive: true)
class CatalogController extends _$CatalogController
    with BaseNotifier<CatalogState> {
  CatalogItemRepository get _catalogItemRepository =>
      ref.read(catalogItemRepositoryProvider);

  ServicesRepository get _serviceRepository =>
      ref.read(servicesRepositoryProvider);

  AuthService get _authService => ref.read(authServiceProvider);

  SupportedCurrency get _defaultCurrency =>
      ref.read(kaziDefaultCurrencyProvider);

  @override
  CatalogState build() => CatalogState(
    userId: _authService.user!.uid,
    status: BaseStateStatus.loading,
  );

  Future<void> onInit() async {
    try {
      final items = await _fetchCatalogItems();

      final status = items.isEmpty
          ? BaseStateStatus.noData
          : BaseStateStatus.readyToUserInput;

      state = state.copyWith(status: status, catalogItems: items);
    } on AppError catch (exception) {
      onAppError(exception);
    } catch (exception) {
      unexpectedError(exception);
    }
  }

  Future<List<CatalogItem>> _fetchCatalogItems() async {
    final result = await _catalogItemRepository.get(_authService.user!.uid);
    return result;
  }

  Future<void> getCatalogItems() async {
    try {
      state = state.copyWith(status: BaseStateStatus.loading);
      final result = await _fetchCatalogItems();
      final newStatus = result.isEmpty
          ? BaseStateStatus.noData
          : BaseStateStatus.readyToUserInput;

      state = state.copyWith(status: newStatus, catalogItems: result);
    } on AppError catch (exception) {
      onAppError(exception);
    } catch (exception) {
      unexpectedError(exception);
    }
  }

  Future<void> addCatalogItem() async {
    try {
      _checkServiceValidity();

      final gate = await ref
          .read(freemiumGuardProvider)
          .checkAddCatalogItem(state.catalogItems.length);
      if (gate.isBlocked) {
        unawaited(
          ref
              .read(analyticsServiceProvider)
              .log(
                AnalyticsEvent.limitReached,
                parameters: {
                  'limit_type': gate.blockedBy!.name,
                  'form': 'service_type',
                },
              ),
        );
        ref
            .read(paywallPromptControllerProvider.notifier)
            .promptFor(gate.blockedBy!);
        return;
      }

      state = state.copyWith(status: BaseStateStatus.loading);
      final result = await _catalogItemRepository.add(_withDefaultCurrency());
      final newList = List<CatalogItem>.from(state.catalogItems)..add(result);
      state = state.copyWith(
        status: BaseStateStatus.success,
        catalogItems: newList,
        catalogItem: CatalogItem(userId: _authService.user!.uid),
      );
      unawaited(
        ref
            .read(analyticsServiceProvider)
            .log(
              AnalyticsEvent.catalogItemCreated,
              parameters: const {'source': 'catalog'},
            ),
      );
      await ref
          .read(creationAdCoordinatorProvider.future)
          .then((coordinator) => coordinator.onCreationAction());
    } on AppError catch (exception) {
      onAppError(exception);
    } catch (exception) {
      unexpectedError(exception);
    }
  }

  Future<void> updateCatalogItem() async {
    try {
      _checkServiceValidity(state.catalogItem.id);
      state = state.copyWith(status: BaseStateStatus.loading);
      await _catalogItemRepository.update(_withDefaultCurrency());
      final newList = await _fetchCatalogItems();

      state = state.copyWith(
        status: BaseStateStatus.success,
        catalogItems: newList,
        catalogItem: CatalogItem(userId: _authService.user!.uid),
      );
    } on AppError catch (exception) {
      onAppError(exception);
    } catch (exception) {
      unexpectedError(exception);
    }
  }

  Future<void> deleteCatalogItem(CatalogItem catalogItem) async {
    try {
      state = state.copyWith(status: BaseStateStatus.loading);
      await _checkCatalogItemIsInUse(catalogItem.id);
      await _catalogItemRepository.delete(catalogItem.id);
      final newList = await _fetchCatalogItems();

      state = state.copyWith(
        status: BaseStateStatus.success,
        catalogItems: newList,
      );
    } on AppError catch (exception) {
      onAppError(exception);
    } catch (exception) {
      unexpectedError(exception);
    }
  }

  /// Appends an already-created catalog item to the in-memory list (used by the
  /// service form's quick-add) so it shows up without a refetch. No-ops while the
  /// list is still loading — [onInit]/[getCatalogItems] will fetch it fresh.
  void appendCatalogItem(CatalogItem item) {
    if (state.status == BaseStateStatus.loading) return;
    if (state.catalogItems.any((existing) => existing.id == item.id)) return;
    final newList = List<CatalogItem>.from(state.catalogItems)..add(item);
    state = state.copyWith(
      status: BaseStateStatus.readyToUserInput,
      catalogItems: newList,
    );
  }

  void eraseCatalogItem() {
    state = state.copyWith(
      catalogItem: CatalogItem(userId: _authService.user!.uid),
    );
  }

  void changeCatalogItem(CatalogItem catalogItem) {
    state = state.copyWith(catalogItem: catalogItem);
  }

  void changeCatalogItemName(String value) {
    state = state.copyWith(
      catalogItem: state.catalogItem.copyWith(name: value),
    );
  }

  void changeCatalogItemDefaultValue(double value) => state = state.copyWith(
    catalogItem: state.catalogItem.copyWith(defaultValue: value),
  );

  /// Sets the share of a service's value the user receives. Written to
  /// `commissionPercent`, never back to the legacy `discountPercent`, so an
  /// edited item stops depending on the old field entirely.
  void changeCatalogItemCommissionPercent(double value) =>
      state = state.copyWith(
        catalogItem: state.catalogItem.copyWith(commissionPercent: value),
      );

  void changeCatalogItemCurrency(SupportedCurrency currency) =>
      state = state.copyWith(
        catalogItem: state.catalogItem.copyWith(currency: currency.isoCode),
      );

  /// Sets (or clears, with null) the colour identifying the item. Clearing means
  /// storing an empty string — `copyWith` treats null as "keep what you have".
  void changeCatalogItemColor(Color? color) => state = state.copyWith(
    catalogItem: state.catalogItem.copyWith(
      color: color == null ? '' : KaziHexColor.encode(color),
    ),
  );

  /// Ensures the item being saved carries a concrete currency, defaulting to
  /// the user's profile currency when unset.
  CatalogItem _withDefaultCurrency() => state.catalogItem.currency.isEmpty
      ? state.catalogItem.copyWith(currency: _defaultCurrency.isoCode)
      : state.catalogItem;

  void _checkServiceValidity([String? idToExclude]) {
    if (state.catalogItem.name.isEmpty) {
      throw ClientError(
        KaziLocalizations.current.requiredProperty(
          KaziLocalizations.current.catalogItem,
        ),
      );
    }
    if (state.catalogItems
        .where((item) => item.id != idToExclude)
        .map((e) => e.name)
        .contains(state.catalogItem.name)) {
      throw ClientError(
        KaziLocalizations.current.alreadyExists(
          KaziLocalizations.current.catalogItem,
        ),
      );
    }
  }

  Future<void> _checkCatalogItemIsInUse(String catalogItemId) async {
    final userId = _authService.user!.uid;
    final count = await _serviceRepository.count(userId, catalogItemId);
    if (count > 0) {
      throw ClientError(KaziLocalizations.current.errorCantDeleteCatalogItem);
    }
  }
}
