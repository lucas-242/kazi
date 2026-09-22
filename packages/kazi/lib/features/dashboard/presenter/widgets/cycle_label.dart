import 'package:flutter/material.dart';
import 'package:kazi/core/utils/period_label.dart';
import 'package:kazi/features/dashboard/presenter/controllers/dashboard_state.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// The billing cycle's exact window, e.g. "6 ago - 5 set". Plain text, not a
/// button — the Payment Cycle setting is what picks the window. See README.md.
class CycleLabel extends StatelessWidget {
  const CycleLabel({super.key, required this.state});

  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final range = state.cycleRange;
    if (range == null) return const SizedBox.shrink();

    final label = periodRangeLabel(range.start, range.end);

    return Semantics(
      label: '${KaziLocalizations.current.period.capitalize()}: $label',
      excludeSemantics: true,
      child: Text(
        label,
        style: KaziTextStyles.labelMedium.copyWith(
          color: context.colors.textMuted,
        ),
      ),
    );
  }
}
