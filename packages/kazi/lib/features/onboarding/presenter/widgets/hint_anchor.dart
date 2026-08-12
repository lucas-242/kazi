import 'package:flutter/material.dart';
import 'package:kazi/features/onboarding/domain/models/onboarding_hint.dart';
import 'package:kazi/features/onboarding/presenter/controllers/hint_controller.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

/// Wraps the widget a hint points at, and shows the hint once the widget is
/// actually on screen.
///
/// Everything that makes a hint safe lives here rather than at each of the four
/// call sites: it waits for layout, asks whether the hint is still owed, claims
/// the one-per-session slot, and records the dismissal.
class HintAnchor extends ConsumerStatefulWidget {
  const HintAnchor({
    super.key,
    required this.hint,
    required this.child,
    this.enabled = true,
  });

  final OnboardingHint hint;
  final Widget child;

  /// Extra condition on top of "not seen yet" — the filters hint waits for a
  /// history worth filtering, for instance.
  final bool enabled;

  @override
  ConsumerState<HintAnchor> createState() => _HintAnchorState();
}

class _HintAnchorState extends ConsumerState<HintAnchor> {
  final _anchorKey = GlobalKey();
  bool _attempted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShow());
  }

  @override
  void didUpdateWidget(HintAnchor oldWidget) {
    super.didUpdateWidget(oldWidget);
    // `enabled` can flip after the first frame — the services list only earns
    // its hint once enough records exist.
    if (widget.enabled && !oldWidget.enabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShow());
    }
  }

  @override
  void dispose() {
    // The anchor is going away; a bubble pointing at where it used to be is
    // worse than no bubble.
    KaziCoachMark.hide();
    super.dispose();
  }

  Future<void> _maybeShow() async {
    if (_attempted || !widget.enabled) return;
    _attempted = true;

    final controller = ref.read(hintControllerProvider.notifier);
    if (!await controller.shouldShow(widget.hint)) return;
    if (!mounted) return;

    // Claimed before showing, so a second anchor mounting on the same frame
    // finds the slot taken rather than stacking a second bubble.
    controller.claimSession();

    KaziCoachMark.show(
      context,
      anchorKey: _anchorKey,
      title: widget.hint.title,
      message: widget.hint.message,
      onDismiss: () => controller.markSeen(widget.hint),
    );
  }

  @override
  Widget build(BuildContext context) =>
      KeyedSubtree(key: _anchorKey, child: widget.child);
}
