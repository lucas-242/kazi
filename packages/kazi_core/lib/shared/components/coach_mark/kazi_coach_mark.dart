import 'package:flutter/material.dart';
import 'package:kazi_core/shared/components/buttons/kazi_text_button.dart';
import 'package:kazi_core/shared/l10n/generated/l10n.dart';
import 'package:kazi_core/shared/themes/themes.dart';

/// A one-off hint anchored to the thing it is talking about.
///
/// Deliberately not a dialog: it dims the screen only enough to lead the eye,
/// leaves a halo around the real widget, and dismisses on any tap. A hint that
/// takes the whole screen stops being a hint and becomes an interruption.
///
/// Shown through [show], which owns a single overlay entry — so two hints can
/// never stack, whatever the callers do.
abstract final class KaziCoachMark {
  static OverlayEntry? _entry;

  static bool get isShowing => _entry != null;

  /// Anchors a bubble to the widget behind [anchorKey].
  ///
  /// Does nothing when another hint is already up, or when the anchor is not
  /// laid out — a hint pointing at nothing is worse than no hint.
  static void show(
    BuildContext context, {
    required GlobalKey anchorKey,
    required String title,
    required String message,
    VoidCallback? onDismiss,
  }) {
    if (_entry != null) return;

    final anchor = _boundsOf(anchorKey);
    if (anchor == null) return;

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    void dismiss() {
      _entry?.remove();
      _entry = null;
      onDismiss?.call();
    }

    _entry = OverlayEntry(
      builder: (overlayContext) => _CoachMarkOverlay(
        anchor: anchor,
        title: title,
        message: message,
        onDismiss: dismiss,
      ),
    );

    overlay.insert(_entry!);
  }

  /// Removes the hint without running its dismissal callback. For a screen
  /// being torn down under it.
  static void hide() {
    _entry?.remove();
    _entry = null;
  }

  static Rect? _boundsOf(GlobalKey key) {
    final render = key.currentContext?.findRenderObject();
    if (render is! RenderBox || !render.hasSize) return null;
    return render.localToGlobal(Offset.zero) & render.size;
  }
}

class _CoachMarkOverlay extends StatelessWidget {
  const _CoachMarkOverlay({
    required this.anchor,
    required this.title,
    required this.message,
    required this.onDismiss,
  });

  final Rect anchor;
  final String title;
  final String message;
  final VoidCallback onDismiss;

  /// How far the halo extends past the anchor on each side.
  static const double _haloPadding = 6;

  /// Gap between the halo and the bubble.
  static const double _bubbleGap = KaziInsets.sm;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final size = MediaQuery.sizeOf(context);
    final halo = anchor.inflate(_haloPadding);

    // Above the anchor when there is room, below it otherwise. Anchors in this
    // app sit low (the FAB, a list row), so above is the common case.
    final showAbove = halo.top > size.height * 0.4;

    return Semantics(
      container: true,
      liveRegion: true,
      label: '$title. $message',
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: onDismiss,
              behavior: HitTestBehavior.opaque,
              child: ColoredBox(color: colors.scrim),
            ),
          ),
          Positioned.fromRect(
            rect: halo,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: colors.brand.fill, spreadRadius: 4),
                    BoxShadow(
                      color: colors.brand.fill.withValues(alpha: 0.28),
                      spreadRadius: 12,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: KaziInsets.md,
            right: KaziInsets.md,
            top: showAbove ? null : halo.bottom + _bubbleGap,
            bottom: showAbove
                ? size.height - halo.top + _bubbleGap
                : null,
            child: _Bubble(
              title: title,
              message: message,
              onDismiss: onDismiss,
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.title,
    required this.message,
    required this.onDismiss,
  });

  final String title;
  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: colors.card,
      borderRadius: KaziRadii.mdBorder,
      child: Padding(
        padding: const EdgeInsets.all(KaziInsets.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: KaziTextStyles.titleSmall.copyWith(color: colors.text),
            ),
            KaziSpacings.verticalXxs,
            Text(
              message,
              style: KaziTextStyles.bodySmall.copyWith(
                color: colors.textMuted,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: KaziTextButton(
                onTap: onDismiss,
                color: colors.brand.text,
                child: Text(KaziLocalizations.current.hintGotIt),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
