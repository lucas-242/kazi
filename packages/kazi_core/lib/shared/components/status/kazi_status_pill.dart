import 'package:flutter/material.dart';
import 'package:kazi_core/shared/themes/themes.dart';

/// The kind of state a [KaziStatusPill] reads as. Colours come from the
/// matching [KaziStatusColors] group, so a new kind never needs a new hex.
enum KaziStatusPillKind { success, warning, info, danger }

/// A small filled pill naming a state — "Recebido", "Pendente" — for list
/// rows where [KaziCategoryBorder]/[KaziColorDot] already carry the category
/// and this only needs to carry the status.
class KaziStatusPill extends StatelessWidget {
  const KaziStatusPill({super.key, required this.label, required this.kind});

  final String label;
  final KaziStatusPillKind kind;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final group = switch (kind) {
      KaziStatusPillKind.success => colors.success,
      KaziStatusPillKind.warning => colors.warning,
      KaziStatusPillKind.info => colors.info,
      KaziStatusPillKind.danger => colors.danger,
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KaziInsets.xs,
        vertical: KaziInsets.xxs,
      ),
      decoration: BoxDecoration(
        color: group.surface,
        borderRadius: KaziRadii.fullBorder,
      ),
      child: Text(
        label,
        style: KaziTextStyles.labelSmall.copyWith(
          color: group.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
