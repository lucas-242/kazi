import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// Marks a service as already paid for. A small mark rather than a colour
/// change on the row — see README.md.
class ReceivedBadge extends StatelessWidget {
  const ReceivedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KaziInsets.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: colors.success.surface,
        borderRadius: KaziRadii.fullBorder,
      ),
      child: Text(
        KaziLocalizations.current.received.toUpperCase(),
        style: KaziTextStyles.tag.copyWith(
          color: colors.success.onSurface,
          fontSize: 9,
        ),
      ),
    );
  }
}
