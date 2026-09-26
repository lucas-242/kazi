import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart';

/// The one row allowed to carry the brand colour as a soft wash — the menu
/// has no FAB, so the screen's single yellow is free.
///
/// Two states, same shape: a call to action for a free user, a status card
/// for a subscribed one. Never disappears once payments are on, so premium
/// users have somewhere to see the plan is active.
class KaziProBanner extends StatelessWidget {
  const KaziProBanner({super.key, required this.isPremium, this.onTap});

  final bool isPremium;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = KaziLocalizations.current;

    return Padding(
      padding: const EdgeInsets.only(bottom: KaziInsets.xs),
      child: Material(
        color: colors.brand.surface,
        borderRadius: KaziRadii.smBorder,
        child: InkWell(
          onTap: onTap,
          borderRadius: KaziRadii.smBorder,
          child: Container(
            constraints: const BoxConstraints(
              minHeight: KaziSizings.minTouchTarget,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: KaziInsets.md,
              vertical: KaziInsets.sm,
            ),
            child: Row(
              children: [
                Icon(LucideIcons.crown, color: colors.brand.onSurface),
                KaziSpacings.horizontalSm,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.kaziProTitle,
                        style: KaziTextStyles.titleSmall.copyWith(
                          color: colors.brand.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (!isPremium) ...[
                        KaziSpacings.verticalXxs,
                        Text(
                          l10n.kaziProDescription,
                          style: KaziTextStyles.labelSmall.copyWith(
                            color: colors.brand.onSurface.withValues(
                              alpha: 0.75,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isPremium)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: KaziInsets.xs,
                      vertical: KaziInsets.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: colors.success.surface,
                      borderRadius: KaziRadii.fullBorder,
                    ),
                    child: Text(
                      l10n.kaziProActive,
                      style: KaziTextStyles.labelSmall.copyWith(
                        color: colors.success.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  Icon(LucideIcons.chevronRight, color: colors.brand.onSurface),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
