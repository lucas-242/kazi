import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// The one row shape the app answers a list of choices with: tap to choose,
/// everything else is trimming. Used by the guided setup and by the services
/// filter sheet.
///
/// It carries an optional trailing slot because the catalog screen needs the
/// price to be tappable on its own — a separate target from the tick.
class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.mark = OptionMark.checkbox,
    this.leading,
    this.detail,
    this.trailing,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;

  /// Which mark says the row is chosen — and whether it carries one at all.
  /// A row that is a target rather than an answer ([OptionMark.none]) shows
  /// nothing, because the mark would promise a state it never holds.
  final OptionMark mark;

  /// A mark between the tick and the label — the colour dot that identifies a
  /// service type in the filter sheet.
  final Widget? leading;

  /// Secondary text on the right, muted. For a price that is *not* editable.
  final String? detail;

  /// Replaces [detail] when the trailing area is itself interactive.
  final Widget? trailing;

  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
      child: Padding(
        padding: const EdgeInsets.only(bottom: KaziInsets.xs),
        child: Material(
          color: colors.card,
          borderRadius: KaziRadii.mdBorder,
          child: InkWell(
            onTap: onTap,
            borderRadius: KaziRadii.mdBorder,
            child: Container(
              constraints: const BoxConstraints(
                minHeight: KaziSizings.minTouchTarget,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: KaziInsets.sm,
                vertical: KaziInsets.xs,
              ),
              decoration: BoxDecoration(
                borderRadius: KaziRadii.mdBorder,
                border: Border.all(
                  color: selected ? colors.text : colors.border,
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  if (mark != OptionMark.none) ...[
                    _Mark(mark: mark, selected: selected),
                    KaziSpacings.horizontalXs,
                  ],
                  if (leading != null) ...[leading!, KaziSpacings.horizontalXs],
                  Expanded(
                    child: Text(
                      label,
                      style: KaziTextStyles.bodyMedium.copyWith(
                        color: colors.text,
                        fontWeight: selected ? FontWeight.w600 : null,
                      ),
                    ),
                  ),
                  if (trailing != null)
                    trailing!
                  else if (detail != null)
                    Text(
                      detail!,
                      style: KaziTextStyles.bodySmall.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// What a row's selection looks like.
enum OptionMark {
  /// One of several answers, several of which may be true.
  checkbox,

  /// One of several answers, exactly one of which is true.
  radio,

  /// No mark: the row is a target, not an answer.
  none,
}

class _Mark extends StatelessWidget {
  const _Mark({required this.mark, required this.selected});

  final OptionMark mark;
  final bool selected;

  static const double _size = 20;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isRadio = mark == OptionMark.radio;

    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        // A chosen radio is a ring, not a filled disc with a dot: the ring is
        // the same shape at any size and survives being drawn at 20px.
        color: selected && !isRadio ? colors.text : Colors.transparent,
        shape: isRadio ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isRadio ? null : KaziRadii.xsBorder,
        border: Border.all(
          color: selected ? colors.text : colors.border,
          width: selected && isRadio ? 5 : 1.5,
        ),
      ),
      child: selected && !isRadio
          ? Icon(Icons.check, size: 14, color: colors.background)
          : null,
    );
  }
}
