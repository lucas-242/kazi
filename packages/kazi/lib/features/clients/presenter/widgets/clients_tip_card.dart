import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// A quiet reminder at the bottom of the clients list — never dismissible,
/// never blocking, just a nudge that shows up once there is at least one
/// client to read it next to.
class ClientsTipCard extends StatelessWidget {
  const ClientsTipCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = KaziLocalizations.current;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KaziInsets.sm),
      decoration: BoxDecoration(
        color: colors.brand.surface,
        borderRadius: KaziRadii.mdBorder,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            LucideIcons.users,
            color: colors.brand.onSurface,
          ),
          KaziSpacings.horizontalSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.clientsTipTitle,
                  style: KaziTextStyles.labelLarge.copyWith(
                    color: colors.brand.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                KaziSpacings.verticalXxs,
                Text(
                  l10n.clientsTipDescription,
                  style: KaziTextStyles.labelSmall.copyWith(
                    color: colors.brand.onSurface.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
