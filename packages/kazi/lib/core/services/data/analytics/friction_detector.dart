import 'package:kazi/core/services/domain/friction_kind.dart';

/// Recognises a person struggling, from signals the app already produces, and
/// promotes the session to being recorded.
///
/// Pure and clock-injected because its thresholds are the only guesses in the
/// analytics stack, and holds no timers — every signal is pushed in by the flow
/// that produced it.
class FrictionDetector {
  FrictionDetector({required DateTime Function() now, required this.onDetected})
    : _now = now;

  /// Two of the same error this close together are a failed retry, not two
  /// unrelated problems.
  static const Duration repeatedErrorWindow = Duration(seconds: 60);

  /// Taps this close together are one gesture, not a decision.
  static const Duration rageTapWindow = Duration(seconds: 1);
  static const int rageTapThreshold = 3;

  /// The forms take well under a minute when they go well.
  static const Duration formStallThreshold = Duration(seconds: 90);

  /// One report per kind per screen, so hammering an unreachable server cannot
  /// bury the first occurrence under duplicates.
  static const Duration cooldown = Duration(minutes: 5);

  final DateTime Function() _now;

  /// Called when friction is recognised: `(kind, screen, count)`.
  final void Function(FrictionKind kind, String screen, int count) onDetected;

  final Map<String, List<DateTime>> _errors = {};
  final Map<String, List<DateTime>> _taps = {};
  final Map<String, int> _abandonedForms = {};
  final Map<String, DateTime> _lastReported = {};

  /// An error message was shown to the user.
  void onError({required String code, required String screen}) {
    final occurrences = _record(_errors, '$screen/$code', repeatedErrorWindow);
    if (occurrences >= 2) {
      _report(FrictionKind.repeatedError, screen, occurrences);
    }
  }

  /// A control was tapped. [target] must identify the control, not the gesture.
  void onTap({required String target, required String screen}) {
    final occurrences = _record(_taps, '$screen/$target', rageTapWindow);
    if (occurrences >= rageTapThreshold) {
      _report(FrictionKind.rageTap, screen, occurrences);
    }
  }

  /// A creation form was left without saving, after [elapsed] on screen.
  void onFormAbandoned({
    required String form,
    required Duration elapsed,
    required String screen,
  }) {
    final abandonments = (_abandonedForms[form] ?? 0) + 1;
    _abandonedForms[form] = abandonments;

    if (abandonments >= 2) {
      _report(FrictionKind.loop, screen, abandonments);
      return;
    }

    if (elapsed >= formStallThreshold) {
      _report(FrictionKind.formStall, screen, elapsed.inSeconds);
    }
  }

  /// They got where they were going, so a later abandonment is a fresh story.
  void onFormCompleted(String form) => _abandonedForms.remove(form);

  /// Records an occurrence and returns how many remain inside [window].
  int _record(
    Map<String, List<DateTime>> history,
    String bucket,
    Duration window,
  ) {
    final now = _now();
    final cutoff = now.subtract(window);
    final occurrences = (history[bucket] ??= [])
      ..removeWhere((at) => at.isBefore(cutoff))
      ..add(now);
    return occurrences.length;
  }

  void _report(FrictionKind kind, String screen, int count) {
    final key = '${kind.name}/$screen';
    final last = _lastReported[key];
    final now = _now();
    if (last != null && now.difference(last) < cooldown) return;
    _lastReported[key] = now;
    onDetected(kind, screen, count);
  }
}
