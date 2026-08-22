import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:kazi/core/services/domain/analytics_event.dart';
import 'package:kazi/core/services/domain/analytics_service.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/dashboard/presenter/controllers/dashboard_controller.dart';
import 'package:kazi/features/onboarding/domain/models/checklist_step.dart';
import 'package:kazi/features/services/domain/repositories/catalog_item_repository.dart';
import 'package:kazi/features/services/domain/repositories/services_repository.dart';
import 'package:kazi/features/settings/domain/repositories/user_settings_repository.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

part 'checklist_controller.g.dart';

class ChecklistState extends Equatable {
  const ChecklistState({this.completed = const {}, this.isVisible = false});

  final Set<ChecklistStep> completed;
  final bool isVisible;

  int get doneCount => completed.length;

  bool isDone(ChecklistStep step) => completed.contains(step);

  @override
  List<Object?> get props => [completed, isVisible];
}

/// The five-step trail on the home, and the rules for when it is there at all.
@Riverpod(keepAlive: true)
class ChecklistController extends _$ChecklistController {
  /// Past this many registered services the trail disappears whether or not it
  /// was finished: someone who has clearly got the hang of it does not need a
  /// to-do list on their home screen.
  static const int _experiencedServices = 10;

  static const int _habitServices = 3;

  UserSettingsRepository get _userSettings =>
      ref.read(userSettingsRepositoryProvider);

  ServicesRepository get _servicesRepository =>
      ref.read(servicesRepositoryProvider);

  CatalogItemRepository get _catalogItemRepository =>
      ref.read(catalogItemRepositoryProvider);

  AnalyticsService get _analytics => ref.read(analyticsServiceProvider);

  AuthService get _authService => ref.read(authServiceProvider);

  @override
  Future<ChecklistState> build() async {
    final userId = _authService.user?.uid;
    if (userId == null) return const ChecklistState();

    // Recomputed whenever the home reloads, which is what makes a step tick
    // itself off right after the service that completed it.
    ref.watch(dashboardControllerProvider);

    try {
      final settings = await _userSettings.get(userId);

      // Only for people the setup actually ran for. Someone already using the
      // app never saw it, and putting a "build your catalog" checklist on
      // their home would tell them the app has no idea who they are.
      if (!settings.hasResolvedSetup) return const ChecklistState();

      final serviceCount = await _servicesRepository.count(userId);
      final itemCount = (await _catalogItemRepository.get(userId)).length;

      final completed = <ChecklistStep>{
        if (itemCount > 0) ChecklistStep.catalog,
        if (serviceCount >= 1) ChecklistStep.firstService,
        if (serviceCount >= _habitServices) ChecklistStep.threeServices,
        for (final step in ChecklistStep.values)
          if (step.isRecorded &&
              settings.completedOnboardingSteps.contains(step.key))
            step,
      };

      final isFinished = completed.length == ChecklistStep.values.length;

      return ChecklistState(
        completed: completed,
        isVisible:
            !isFinished && serviceCount < _experiencedServices,
      );
    } catch (exception) {
      // A card that fails to load is not worth an error on the home screen.
      Log.error(exception);
      return const ChecklistState();
    }
  }

  /// Records a step the user's data cannot answer on its own.
  ///
  /// Safe to call on every occurrence: already-recorded steps short-circuit,
  /// so marking a tenth service as received costs nothing.
  Future<void> markStep(ChecklistStep step) async {
    assert(step.isRecorded, 'Derived steps are never marked by hand');

    final userId = _authService.user?.uid;
    final current = state.asData?.value;
    if (userId == null || current == null) return;
    if (current.isDone(step)) return;

    try {
      await _userSettings.markOnboardingStep(userId, step.key);
      unawaited(
        _analytics.log(
          AnalyticsEvent.checklistStepCompleted,
          parameters: {'step': step.key},
        ),
      );
      ref.invalidateSelf();
    } catch (exception) {
      Log.error(exception);
    }
  }
}
