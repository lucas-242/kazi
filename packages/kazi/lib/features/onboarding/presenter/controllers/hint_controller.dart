import 'dart:async';

import 'package:kazi/core/services/domain/analytics_event.dart';
import 'package:kazi/core/services/domain/analytics_service.dart';
import 'package:kazi/features/onboarding/domain/models/onboarding_hint.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

part 'hint_controller.g.dart';

/// Decides whether a contextual hint may appear, and remembers that it did.
///
/// Two rules, both from experience with hints that outstay their welcome:
/// **at most one per session**, and "Got it" means never again.
@Riverpod(keepAlive: true)
class HintController extends _$HintController {
  /// Reset only by restarting the app, which is what makes "one per session"
  /// hold across navigation.
  bool _shownThisSession = false;

  AnalyticsService get _analytics => ref.read(analyticsServiceProvider);

  @override
  void build() {}

  /// Whether [hint] should be shown right now.
  Future<bool> shouldShow(OnboardingHint hint) async {
    if (_shownThisSession) return false;
    if (KaziCoachMark.isShowing) return false;

    try {
      final storage = await ref.read(localStorageProvider.future);
      return !(await storage.read<bool>(hint.storageKey) ?? false);
    } catch (exception) {
      // A hint that cannot check itself simply does not appear. Showing it on
      // every launch would be worse than never showing it.
      Log.error(exception);
      return false;
    }
  }

  /// Claims this session's single hint slot. Call immediately before showing,
  /// so two anchors racing on the same frame cannot both win.
  void claimSession() => _shownThisSession = true;

  Future<void> markSeen(OnboardingHint hint) async {
    unawaited(
      _analytics.log(
        AnalyticsEvent.hintDismissed,
        parameters: {'hint': hint.name},
      ),
    );

    try {
      final storage = await ref.read(localStorageProvider.future);
      await storage.write(hint.storageKey, true);
    } catch (exception) {
      Log.error(exception);
    }
  }
}
