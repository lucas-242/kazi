import 'package:kazi/core/utils/base_notifier.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/services/domain/models/catalog_item.dart';
import 'package:kazi/features/services/domain/repositories/services_repository.dart';
import 'package:kazi/features/services/presenter/controllers/catalog_controller.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

import 'archived_catalog_state.dart';

part 'archived_catalog_controller.g.dart';

/// How many services point at each archived catalog item — the number that
/// decides whether permanent deletion is offered at all.
@riverpod
class ArchivedCatalogController extends _$ArchivedCatalogController
    with BaseNotifier<ArchivedCatalogState> {
  ServicesRepository get _servicesRepository =>
      ref.read(servicesRepositoryProvider);

  AuthService get _authService => ref.read(authServiceProvider);

  @override
  ArchivedCatalogState build() =>
      ArchivedCatalogState(status: BaseStateStatus.loading);

  Future<void> onInit() async {
    try {
      final userId = _authService.user!.uid;
      final items = ref.read(catalogControllerProvider).archivedCatalogItems;

      final counts = <String, int>{};
      for (final item in items) {
        counts[item.id] = await _servicesRepository.count(userId, item.id);
      }

      state = state.copyWith(
        status: BaseStateStatus.readyToUserInput,
        serviceCounts: counts,
      );
    } on AppError catch (exception) {
      onAppError(exception);
    } catch (exception) {
      unexpectedError(exception);
    }
  }

  Future<void> deleteCatalogItem(CatalogItem catalogItem) async {
    await ref
        .read(catalogControllerProvider.notifier)
        .deleteCatalogItem(catalogItem);
    final counts = Map<String, int>.from(state.serviceCounts)
      ..remove(catalogItem.id);
    state = state.copyWith(serviceCounts: counts);
  }
}
