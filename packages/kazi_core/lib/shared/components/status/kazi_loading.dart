import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kazi_core/shared/l10n/generated/l10n.dart';
import 'package:kazi_core/shared/themes/themes.dart';

/// A block-level loading state: three dots pulsing in a wave, in the brand
/// colour, with the localized "Carregando..." underneath. Used both inline
/// (a page's own content, sized by [height]) and as a full-screen scrim
/// (`.overlay`, behind [KaziBlockingLoading]).
class KaziLoading extends StatefulWidget {
  const KaziLoading({
    super.key,
    this.color,
    this.height,
  }) : isOverlay = false;

  const KaziLoading.overlay({
    super.key,
    this.color,
  })  : height = null,
        isOverlay = true;

  final Color? color;
  final double? height;
  final bool isOverlay;

  @override
  State<KaziLoading> createState() => _KaziLoadingState();
}

class _KaziLoadingState extends State<KaziLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isOverlay) {
      return AbsorbPointer(
        child: ColoredBox(
          // A scrim in the page colour rather than a fixed light wash, so the
          // overlay dims the content instead of bleaching it in dark mode.
          color:
              widget.color ?? context.colors.background.withValues(alpha: .6),
          child: SizedBox.expand(child: Center(child: _buildMark(context))),
        ),
      );
    }

    return Container(
      height: widget.height ?? context.height * .7,
      color: widget.color,
      child: Center(child: _buildMark(context)),
    );
  }

  Widget _buildMark(BuildContext context) {
    // Read here rather than captured in `initState`: the label is localized,
    // and the language can change while a loading state is on screen — the
    // settings sheet closes over one. A cached string would keep showing the
    // old language until the widget was rebuilt from scratch.
    final text = KaziLocalizations.current.loading;
    final color = context.colors.brand.fill;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        reduceMotion
            ? _DotRow(color: color, phase: null)
            : AnimatedBuilder(
                animation: _controller,
                builder: (context, _) =>
                    _DotRow(color: color, phase: _controller.value),
              ),
        KaziSpacings.verticalSm,
        Text(
          text,
          style: KaziTextStyles.labelMedium.copyWith(
            color: context.colors.textMuted,
          ),
        ),
      ],
    );
  }
}

/// Three dots, each riding its own slice of one shared sine wave — [phase]
/// null renders them at rest, for `disableAnimationsOf`.
class _DotRow extends StatelessWidget {
  const _DotRow({required this.color, required this.phase});

  final Color color;

  /// 0..1, one full lap of the wave; null skips the animation entirely.
  final double? phase;

  static const _dotCount = 3;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < _dotCount; i++) ...[
          if (i > 0) KaziSpacings.horizontalXs,
          _Dot(color: color, wave: phase == null ? 1 : _waveFor(i, phase!)),
        ],
      ],
    );
  }

  /// A 0..1 value per dot, offset by a third of the cycle from its
  /// neighbours so the three read as a single wave passing through them
  /// rather than blinking in unison.
  double _waveFor(int index, double phase) {
    final offset = index / _dotCount;
    final radians = (phase - offset) * 2 * math.pi;
    return (math.sin(radians) + 1) / 2;
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color, required this.wave});

  final Color color;
  final double wave;

  static const _size = 10.0;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.35 + 0.65 * wave,
      child: Transform.scale(
        scale: 0.55 + 0.45 * wave,
        child: Container(
          width: _size,
          height: _size,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
