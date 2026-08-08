import 'package:flutter/material.dart';
import 'package:kazi/features/services/domain/models/service_totals.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

/// Says out loud that a total is missing some services, rather than letting an
/// incomplete number pass for a complete one.
///
/// Shown when a service registered in another currency has no exchange rate
/// available — offline on a cold start, or a date the shared history has not
/// reached. Renders nothing when every service converted.
class PartialTotalsNote extends StatelessWidget {
  const PartialTotalsNote({super.key, required this.totals});

  final ServiceTotals totals;

  @override
  Widget build(BuildContext context) {
    if (!totals.isPartial) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: KaziInsets.xs),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 14,
            color: context.colorsScheme.onSurfaceVariant,
          ),
          KaziSpacings.horizontalXxs,
          Expanded(
            child: Text(
              KaziLocalizations.current.ratesUnavailable,
              style: KaziTextStyles.labelSm,
            ),
          ),
        ],
      ),
    );
  }
}
