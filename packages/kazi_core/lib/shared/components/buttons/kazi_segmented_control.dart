import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart';

/// One option of a [KaziSegmentedControl].
class KaziSegment<T> {
  const KaziSegment({required this.value, required this.label, this.wrap});

  final T value;
  final String label;

  /// Wraps the drawn segment, for something that has to anchor on it — a
  /// coach mark, a tap probe.
  final Widget Function(Widget segment)? wrap;
}

/// Mutually exclusive faces of one screen, side by side at equal widths.
///
/// Shaped unlike [KaziChip] on purpose: chips filter what is on screen, a
/// segment picks how it is shown.
class KaziSegmentedControl<T> extends StatelessWidget {
  const KaziSegmentedControl({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
  });

  final List<KaziSegment<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KaziInsets.xxs),
      decoration: BoxDecoration(
        color: context.colors.surfaceMuted,
        borderRadius: KaziRadii.smBorder,
      ),
      child: Row(
        children: [
          for (final segment in segments)
            Expanded(child: _wrapped(segment)),
        ],
      ),
    );
  }

  Widget _wrapped(KaziSegment<T> segment) {
    final drawn = _Segment(
      label: segment.label,
      isSelected: segment.value == selected,
      onTap: () => onChanged(segment.value),
    );
    return segment.wrap?.call(drawn) ?? drawn;
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: true,
      selected: isSelected,
      child: Material(
        color: isSelected ? colors.card : Colors.transparent,
        borderRadius: KaziRadii.xsBorder,
        child: InkWell(
          onTap: onTap,
          borderRadius: KaziRadii.xsBorder,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: KaziInsets.xs),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: KaziTextStyles.labelMedium.copyWith(
                color: isSelected ? colors.text : colors.textMuted,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
