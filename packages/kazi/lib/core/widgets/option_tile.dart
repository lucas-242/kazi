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
    this.showCheckbox = true,
    this.leading,
    this.detail,
    this.trailing,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;

  /// Radio-style screens (commission overrides, employment) show no tick — the
  /// row is a target, not a multi-select.
  final bool showCheckbox;

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
                  if (showCheckbox) ...[
                    _Tick(selected: selected),
                    KaziSpacings.horizontalXs,
                  ],
                  if (leading != null) ...[
                    leading!,
                    KaziSpacings.horizontalXs,
                  ],
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

class _Tick extends StatelessWidget {
  const _Tick({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: selected ? colors.text : Colors.transparent,
        borderRadius: KaziRadii.xsBorder,
        border: Border.all(
          color: selected ? colors.text : colors.border,
          width: 1.5,
        ),
      ),
      child: selected
          ? Icon(Icons.check, size: 14, color: colors.background)
          : null,
    );
  }
}
