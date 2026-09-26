import 'dart:async';
import 'dart:ui' show VoidCallback;

import 'package:kazi/core/services/domain/analytics_event.dart';
import 'package:kazi/core/services/domain/analytics_service.dart';
import 'package:kazi/features/onboarding/domain/models/onboarding_hint.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

part 'hint_controller.g.dart';

/// Decides whether a contextual hint may appear, and remembers that it did.
/// See `core/INTERRUPTIONS.md`.
@Riverpod(keepAlive: true)
class HintController extends _$HintController {
  bool _isSlotTaken = false;

  /// The anchors on screen, in mount order — which is what decides who teaches
  /// first when two hints share a screen.
  final _waiting = <VoidCallback>[];

  /// Without it the screen's second hint takes the first one's place inside a
  /// frame, which reads as a flicker rather than as a second step.
  static const _gapBetweenHints = Duration(seconds: 1);

  Timer? _offer;

  final _startup = Completer<void>();

  AnalyticsService get _analytics => ref.read(analyticsServiceProvider);

  @override
  void build() {
    ref.onDispose(() => _offer?.cancel());
  }

  /// Completes once the opening's interruptions are over. A bubble pointing at
  /// a widget behind a modal points at nothing.
  Future<void> get startupSettled => _startup.future;

  void markStartupSettled() {
    if (!_startup.isCompleted) _startup.complete();
  }

  Future<bool> shouldShow(OnboardingHint hint) async {
    if (_isSlotTaken) return false;
    if (KaziCoachMark.isShowing) return false;

    try {
      final storage = await ref.read(localStorageProvider.future);
      return !(await storage.read<bool>(hint.storageKey) ?? false);
    } catch (exception) {
      // A hint that cannot check itself does not appear; showing it on every
      // launch would be worse.
      Log.error(exception);
      return false;
    }
  }

  /// Takes the single hint slot, reporting whether it was free. Check and
  /// claim are one synchronous step: two anchors racing on a frame both pass
  /// [shouldShow] before either shows.
  bool claimSlot() {
    if (_isSlotTaken || KaziCoachMark.isShowing) return false;
    _isSlotTaken = true;
    return true;
  }

  void releaseSlot() {
    _isSlotTaken = false;
    _offer?.cancel();
    if (_waiting.isEmpty) return;
    _offer = Timer(_gapBetweenHints, _offerSlot);
  }

  void _offerSlot() {
    // A copy: the anchor that takes the offer shows from inside this loop.
    for (final offer in List.of(_waiting)) {
      offer();
    }
  }

  void waitForSlot(VoidCallback onOffered) => _waiting.add(onOffered);

  void stopWaitingForSlot(VoidCallback onOffered) {
    _waiting.remove(onOffered);
    // An offer outliving the last anchor is a timer nothing will answer.
    if (_waiting.isEmpty) _offer?.cancel();
  }

  /// Spends [hint], for **every** take-down and not only for "Got it": a hint
  /// that survived the back gesture came back on every visit to its screen.
  /// [byUser] changes nothing but the analytics.
  Future<void> markSeen(
    OnboardingHint hint, {
    required bool byUser,
  }) async {
    if (byUser) {
      unawaited(
        _analytics.log(
          AnalyticsEvent.hintDismissed,
          parameters: {'hint': hint.name},
        ),
      );
    }

    try {
      final storage = await ref.read(localStorageProvider.future);
      await storage.write(hint.storageKey, true);
    } catch (exception) {
      Log.error(exception);
    } finally {
      // After the write: the offer reaches this hint's own anchor too, and it
      // must find the key already there.
      releaseSlot();
    }
  }
}
