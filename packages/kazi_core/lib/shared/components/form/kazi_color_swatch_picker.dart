import 'package:flutter/material.dart';
import 'package:kazi_core/shared/l10n/generated/l10n.dart';
import 'package:kazi_core/shared/themes/themes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Optional colour field: the brandbook category colours plus "no colour".
///
/// Deliberately a fixed palette rather than a free picker — the category hexes
/// are an identity set, chosen to stay legible on both brightnesses, and an
/// arbitrary hex would break that contract.
class KaziColorSwatchPicker extends StatelessWidget {
  const KaziColorSwatchPicker({
    super.key,
    this.selected,
    required this.onChanged,
    this.swatchSize = 36,
    this.isScrollable = false,
  });

  /// The currently chosen colour, or null for "no colour".
  final Color? selected;

  /// Emits the chosen colour, or null when the user picks "no colour".
  final ValueChanged<Color?> onChanged;

  final double swatchSize;

  final bool isScrollable;

  @override
  Widget build(BuildContext context) {
    final List<Color> categories = context.colors.categories;

    final swatches = <Widget>[
      for (var index = 0; index < categories.length; index++)
        _Swatch(
          color: context.colors.category(index),
          isSelected: selected == context.colors.category(index),
          size: swatchSize,
          onTap: () => onChanged(context.colors.category(index)),
        ),
      _Swatch(
        color: null,
        isSelected: selected == null,
        size: swatchSize,
        label: KaziLocalizations.current.noColor,
        onTap: () => onChanged(null),
      ),
    ];

    if (!isScrollable) {
      return Wrap(
        spacing: KaziInsets.sm,
        runSpacing: KaziInsets.sm,
        children: swatches,
      );
    }

    final int selectedIndex = categories.indexWhere(
      (color) => color == selected,
    );

    return _ScrollingSwatches(
      swatches: swatches,
      swatchSize: swatchSize,
      revealIndex: selectedIndex < 0 ? null : selectedIndex,
    );
  }
}

/// A single row that fades out at whichever edge still has swatches behind
/// it, so a clipped palette reads as "more this way" rather than as the end.
class _ScrollingSwatches extends StatefulWidget {
  const _ScrollingSwatches({
    required this.swatches,
    required this.swatchSize,
    this.revealIndex,
  });

  final List<Widget> swatches;
  final double swatchSize;

  /// The swatch to centre on open; null opens at the start. "No colour" is
  /// never revealed — it sits last, so a new item would open at the end.
  final int? revealIndex;

  @override
  State<_ScrollingSwatches> createState() => _ScrollingSwatchesState();
}

class _ScrollingSwatchesState extends State<_ScrollingSwatches> {
  final _controller = ScrollController();

  /// 0 when that edge is flush with the content, 1 once a full fade width of
  /// swatches is hidden past it.
  double _leadingFade = 0;
  double _trailingFade = 0;

  static const double _edgeOpacity = 0.45;

  double get _fadeWidth => widget.swatchSize * 0.75;
  double get _itemExtent => widget.swatchSize + KaziInsets.sm;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _revealSelected());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _revealSelected() {
    final int? index = widget.revealIndex;
    if (index == null || !_controller.hasClients) return;
    final ScrollPosition position = _controller.position;
    final double centred = index * _itemExtent -
        (position.viewportDimension - widget.swatchSize) / 2;
    _controller.jumpTo(
      centred.clamp(position.minScrollExtent, position.maxScrollExtent),
    );
  }

  bool _updateFades(Notification notification) {
    final ScrollMetrics? metrics = switch (notification) {
      ScrollMetricsNotification(:final metrics) => metrics,
      ScrollUpdateNotification(:final metrics) => metrics,
      _ => null,
    };
    if (metrics == null) return false;

    final double leading = (metrics.extentBefore / _fadeWidth).clamp(0, 1);
    final double trailing = (metrics.extentAfter / _fadeWidth).clamp(0, 1);
    if (leading != _leadingFade || trailing != _trailingFade) {
      setState(() {
        _leadingFade = leading;
        _trailingFade = trailing;
      });
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.swatchSize + KaziInsets.xs,
      child: NotificationListener<Notification>(
        onNotification: _updateFades,
        child: ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (bounds) {
            final double stop = (_fadeWidth / bounds.width).clamp(0, 0.5);
            return LinearGradient(
              colors: [
                Colors.black.withValues(
                  alpha: 1 - _leadingFade * (1 - _edgeOpacity),
                ),
                Colors.black,
                Colors.black,
                Colors.black.withValues(
                  alpha: 1 - _trailingFade * (1 - _edgeOpacity),
                ),
              ],
              stops: [0, stop, 1 - stop, 1],
            ).createShader(bounds);
          },
          child: ListView.separated(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            itemCount: widget.swatches.length,
            separatorBuilder: (_, __) => KaziSpacings.horizontalSm,
            itemBuilder: (_, index) => Center(child: widget.swatches[index]),
          ),
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.isSelected,
    required this.size,
    required this.onTap,
    this.label,
  });

  final Color? color;
  final bool isSelected;
  final double size;
  final VoidCallback onTap;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final Color background = color ?? context.colors.surfaceStrong;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color:
                  isSelected ? context.colors.focusRing : context.colors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          padding: const EdgeInsets.all(1),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: color == null
                  ? Icon(
                      LucideIcons.ban,
                      size: size / 2,
                      color: context.colors.textMuted,
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
