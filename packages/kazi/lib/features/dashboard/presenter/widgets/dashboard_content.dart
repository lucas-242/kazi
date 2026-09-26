import 'package:flutter/material.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/dashboard/presenter/controllers/dashboard_state.dart';
import 'package:kazi/features/dashboard/presenter/widgets/cycle_label.dart';
import 'package:kazi/features/dashboard/presenter/widgets/dashboard_skeleton.dart';
import 'package:kazi/features/dashboard/presenter/widgets/earnings_card.dart';
import 'package:kazi/features/dashboard/presenter/widgets/error_band.dart';
import 'package:kazi/features/dashboard/presenter/widgets/quick_actions_row.dart';
import 'package:kazi/features/dashboard/presenter/widgets/stagger_in.dart';
import 'package:kazi/features/dashboard/presenter/widgets/today_section.dart';
import 'package:kazi/features/onboarding/presenter/widgets/active_user_nudges.dart';
import 'package:kazi/features/onboarding/presenter/widgets/onboarding_checklist_card.dart';
import 'package:kazi/features/services/domain/models/service_totals.dart';
import 'package:kazi/features/services/presenter/widgets/partial_totals_note.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key, required this.state});

  /// Also used by [DashboardSkeleton], so the loading state does not change
  /// shape once real content lands.
  static const pagePadding = EdgeInsets.fromLTRB(
    KaziInsets.md,
    KaziInsets.lg + KaziInsets.xxs,
    KaziInsets.md,
    KaziInsets.md,
  );

  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    // Read once and threaded down: `totals` and `todayServices` are un-cached
    // getters, each a full pass over every service. See README.md.
    final totals = state.totals;
    final todayServices = state.todayServices;
    final todayTotals = ServiceTotals.from(
      todayServices,
      currency: state.defaultCurrency,
      rateBook: state.rateBook,
    );

    return ColoredBox(
      color: context.colors.background,
      child: Padding(
        padding: pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                KaziSvg(
                  KaziSvgAssets.logoExtended,
                  height: 20,
                  color: context.colors.text,
                ),
                CycleLabel(state: state),
              ],
            ),
            KaziSpacings.verticalMd,
            if (state.status == BaseStateStatus.error) ...[
              ErrorBand(message: state.callbackMessage),
              KaziSpacings.verticalMd,
            ],
            if (totals.isPartial) ...[
              PartialTotalsNote(totals: totals),
              KaziSpacings.verticalMd,
            ],
            StaggerIn(
              index: 0,
              child: EarningsCard(state: state, totals: totals),
            ),
            const SizedBox(height: KaziInsets.md + KaziInsets.xxs),
            const StaggerIn(index: 1, child: QuickActionsRow()),
            KaziSpacings.verticalMd,
            const OnboardingChecklistCard(),
            const ActiveUserNudges(),
            if (state.services.isEmpty)
              KaziNoResults(
                icon: LucideIcons.coffee,
                message: KaziLocalizations.current.noServicesYet,
                description: KaziLocalizations.current.noServicesYetDescription,
                actionLabel: KaziLocalizations.current.newService,
                onAction: () => KaziNavigator.push(AppPage.addServices),
              )
            else
              StaggerIn(
                index: 2,
                child: TodaySection(
                  services: todayServices,
                  totals: todayTotals,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
