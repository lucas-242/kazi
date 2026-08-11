import 'package:flutter/material.dart';
import 'package:kazi_core/shared/l10n/generated/l10n.dart';
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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
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
          color: widget.color ??
              context.colors.background.withValues(alpha: .6),
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
    // Read here rather than captured in `initState`: the label is localized, and
    // the language can change while a loading state is on screen — the settings
    // sheet closes over one. A cached string would keep typing out the old
    // language until the widget was rebuilt from scratch.
    final text = KaziLocalizations.current.loading;

    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // One more step than there are characters, so the finished word gets
          // a beat of its own before the cycle restarts.
          final characters = (_controller.value * (text.length + 1))
              .floor()
              .clamp(0, text.length);

          return Text(
            text.substring(0, characters),
            // accentInk, not the brand yellow: yellow text on Névoa is 1.4:1.
            style: KaziTextStyles.titleLarge.copyWith(
              color: context.colors.brand.text,
              fontWeight: FontWeight.w600,
            ),
          );
        },
      ),
    );
  }
}
