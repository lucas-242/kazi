import 'package:flutter/material.dart';
import 'package:kazi_core/shared/themes/themes.dart';

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
  late final Animation<int> _animation;
  static const String _text = 'Carregando...';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = StepTween(begin: 0, end: _text.length).animate(_controller);
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
          color: widget.color ??
              context.colorsScheme.surface.withValues(alpha: .6),
          child: SizedBox.expand(child: _buildText()),
        ),
      );
    }

    return Container(
      height: widget.height ?? context.height * .7,
      color: widget.color,
      child: _buildText(),
    );
  }

  Widget _buildText() {
    return Center(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final frame = _text.substring(0, _animation.value);
          return Text(
            frame,
            // accentInk, not the brand yellow: yellow text on Névoa is 1.4:1.
            style: KaziTextStyles.titleLg.copyWith(
              color: context.kaziColors.accentInk,
              fontWeight: FontWeight.w600,
            ),
          );
        },
      ),
    );
  }
}
