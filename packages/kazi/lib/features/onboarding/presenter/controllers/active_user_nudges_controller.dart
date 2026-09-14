import 'package:equatable/equatable.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/onboarding/presenter/controllers/onboarding_controller.dart';
import 'package:kazi/features/services/domain/models/catalog_item.dart';
import 'package:kazi/features/services/domain/repositories/catalog_item_repository.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

part 'active_user_nudges_controller.g.dart';

class ActiveUserNudgesState extends Equatable {
  const ActiveUserNudgesState({this.itemsMissingCommission = const []});

  /// Types whose commission was never configured. Their value counts toward
  /// the total generated but not toward what the user receives, which makes
  /// the home understate their earnings without saying so.
  final List<CatalogItem> itemsMissingCommission;

  bool get hasCommissionGaps => itemsMissingCommission.isNotEmpty;

  @override
  List<Object?> get props => [itemsMissingCommission];
}

/// What the app asks of people who are already using it — which is as close to
/// nothing as the change allows.
///
/// Someone active opens Kazi to record a job, not to configure it: this is a
/// dismissible card on the home, never a full screen or a modal. The currency
/// and the billing cycle are not asked here — the guided setup asks every
/// account once.
@Riverpod(keepAlive: true)
class ActiveUserNudgesController extends _$ActiveUserNudgesController {
  CatalogItemRepository get _catalogItemRepository =>
      ref.read(catalogItemRepositoryProvider);

  AuthService get _authService => ref.read(authServiceProvider);

  /// Per session, not persisted: the card describes something still
  /// unresolved, and one that never returned would quietly leave the user's
  /// totals wrong forever. Fixing the commissions removes it for good.
  bool _gapsDismissed = false;

  @override
  Future<ActiveUserNudgesState> build() async {
    final segment = await ref.watch(onboardingControllerProvider.future);
    if (!segment.isActiveUser || _gapsDismissed) {
      return const ActiveUserNudgesState();
    }

    final userId = _authService.user?.uid;
    if (userId == null) return const ActiveUserNudgesState();

    try {
      final items = await _catalogItemRepository.get(userId);

      return ActiveUserNudgesState(
        itemsMissingCommission: items
            // Archived types take no new services, and the catalog the card
            // opens does not list them: there is nothing to fix.
            .where(
              (item) =>
                  !item.isArchived && item.effectiveCommissionPercent == null,
            )
            .toList(),
      );
    } catch (exception) {
      Log.error(exception);
      return const ActiveUserNudgesState();
    }
  }

  void dismissGaps() {
    _gapsDismissed = true;
    ref.invalidateSelf();
  }
}
