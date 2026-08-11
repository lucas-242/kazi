import 'package:flutter/material.dart';
import 'package:kazi/features/subscription/domain/freemium_limits.dart';
import 'package:kazi/features/subscription/domain/models/user_tier.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

class PlanComparison extends StatelessWidget {
  const PlanComparison({super.key});

  @override
  Widget build(BuildContext context) {
    final free = FreemiumLimits.forTier(UserTier.newFree);
    final l10n = KaziLocalizations.current;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _PlanCard(
            title: l10n.freePlan,
            highlighted: false,
            lines: [
              l10n.freeLimitServices(free.maxServicesPerMonth),
              l10n.freeLimitTypes(free.maxServiceTypes),
              l10n.freeLimitClients(free.maxClients),
              l10n.freeLimitAds,
            ],
          ),
        ),
        KaziSpacings.horizontalSm,
        Expanded(
          child: _PlanCard(
            title: l10n.premiumPlan,
            highlighted: true,
            lines: [
              l10n.featureUnlimitedServices,
              l10n.featureUnlimitedTypes,
              l10n.featureUnlimitedClients,
              l10n.featureNoAds,
            ],
          ),
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.lines,
    required this.highlighted,
  });

  final String title;
  final List<String> lines;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final borderColor = highlighted
        ? context.colors.brand.text
        : context.colors.border;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: highlighted ? 2 : 1),
        borderRadius: BorderRadius.circular(KaziInsets.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.all(KaziInsets.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: KaziTextStyles.titleMedium.copyWith(
                color: highlighted ? context.colors.brand.textStrong : null,
              ),
            ),
            KaziSpacings.verticalSm,
            for (final line in lines) ...[
              _PlanLine(line, highlighted: highlighted),
              KaziSpacings.verticalXs,
            ],
          ],
        ),
      ),
    );
  }
}

class _PlanLine extends StatelessWidget {
  const _PlanLine(this.text, {required this.highlighted});

  final String text;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          highlighted ? Icons.check_circle : Icons.check,
          size: 16,
          color: highlighted
              ? context.colors.brand.text
              : context.colors.textMuted,
        ),
        KaziSpacings.horizontalXs,
        Expanded(child: Text(text, style: KaziTextStyles.bodySmall)),
      ],
    );
  }
}
