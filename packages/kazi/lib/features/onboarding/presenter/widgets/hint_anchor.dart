import 'package:flutter/material.dart';
import 'package:kazi/features/onboarding/domain/models/onboarding_hint.dart';
import 'package:kazi/features/onboarding/presenter/controllers/hint_controller.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// Wraps the widget a hint points at and owns every rule about when the hint
/// may appear, so the call sites carry nothing but this wrapper.
/// See `core/INTERRUPTIONS.md`.
class HintAnchor extends ConsumerStatefulWidget {
  const HintAnchor({
    super.key,
    required this.hint,
    required this.child,
    this.enabled = true,
    this.radius,
  });

  final OnboardingHint hint;
  final Widget child;

  /// The anchor's own corner radius, which the ring repeats. Null rings it as
  /// a stadium, which is what a circle, a pill and an icon button want.
  final double? radius;

  /// Extra condition on top of "not seen yet" — the filters hint waits for a
  /// history worth filtering, for instance.
  final bool enabled;

  @override
  ConsumerState<HintAnchor> createState() => _HintAnchorState();
}

class _HintAnchorState extends ConsumerState<HintAnchor> {
  final _anchorKey = GlobalKey();
  bool _attempting = false;
  bool _showing = false;

  /// go_router keeps inactive shell branches laid out and measurable, so the
  /// ticker mode is the only thing that notices the user is on another tab.
  bool _isOnScreen = true;

  /// Held rather than read on demand: `dispose` uses it, and `ref` is no
  /// longer readable by then.
  late final HintController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ref.read(hintControllerProvider.notifier);
    _controller.waitForSlot(_onSlotOffered);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShow());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isOnScreen = TickerMode.valuesOf(context).enabled;
    if (isOnScreen == _isOnScreen) return;

    _isOnScreen = isOnScreen;
    if (isOnScreen) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShow());
    } else {
      _retract();
    }
  }

  @override
  void didUpdateWidget(HintAnchor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled == oldWidget.enabled) return;

    if (widget.enabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShow());
    } else {
      _retract();
    }
  }

  @override
  void dispose() {
    _controller.stopWaitingForSlot(_onSlotOffered);
    _retract();
    super.dispose();
  }

  void _onSlotOffered() => _maybeShow();

  bool get _canShow =>
      mounted &&
      widget.enabled &&
      _isOnScreen &&
      (ModalRoute.of(context)?.isCurrent ?? true);

  Future<void> _maybeShow() async {
    if (_attempting || _showing || !_canShow) return;
    _attempting = true;

    try {
      await _controller.startupSettled;
      if (!mounted || !_canShow) return;

      if (!await _controller.shouldShow(widget.hint)) return;
      if (!mounted || !_canShow) return;

      if (!_controller.claimSlot()) return;

      final isShown = KaziCoachMark.show(
        context,
        owner: this,
        anchorKey: _anchorKey,
        title: widget.hint.title,
        message: widget.hint.message,
        anchorRadius: widget.radius,
        onDismiss: () => _spend(byUser: true),
        onLost: () => _spend(byUser: false),
      );

      // The mark refuses an anchor it cannot measure; keeping the slot would
      // cost every later hint its turn.
      if (!isShown) {
        _controller.releaseSlot();
        return;
      }
      _showing = true;
    } finally {
      _attempting = false;
    }
  }

  void _retract() {
    if (!_showing) return;
    KaziCoachMark.hide(owner: this);
    _spend(byUser: false);
  }

  void _spend({required bool byUser}) {
    _showing = false;
    _controller.markSeen(widget.hint, byUser: byUser);
  }

  @override
  Widget build(BuildContext context) =>
      KeyedSubtree(key: _anchorKey, child: widget.child);
}
