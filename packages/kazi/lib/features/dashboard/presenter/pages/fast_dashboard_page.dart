import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/core/widgets/ads/ad_block.dart';
import 'package:kazi/features/dashboard/presenter/controllers/dashboard_controller.dart';
import 'package:kazi/features/dashboard/presenter/controllers/dashboard_state.dart';
import 'package:kazi/features/onboarding/presenter/widgets/active_user_nudges.dart';
import 'package:kazi/features/onboarding/presenter/widgets/onboarding_checklist_card.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/domain/models/service_view.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_controller.dart';
import 'package:kazi/features/services/presenter/widgets/partial_totals_note.dart';
import 'package:kazi/features/services/presenter/widgets/service_card.dart';
import 'package:kazi/features/services/services.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// The home: a plain greeting header, the cycle's money on a floating card,
/// then what was done today. Layout and content decisions are in
/// `features/dashboard/README.md`.
class FastDashboardPage extends ConsumerStatefulWidget {
  const FastDashboardPage({super.key});

  @override
  ConsumerState<FastDashboardPage> createState() => _SimpleDashboardPageState();
}

class _SimpleDashboardPageState extends ConsumerState<FastDashboardPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(dashboardControllerProvider.notifier).onInit(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardControllerProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.colors.overlayOn(context.colors.background),
      child: Scaffold(
        body: KaziSafeArea(
          isLoading: state.status == BaseStateStatus.loading,
          // Zero: `_DashboardContent` applies its own 16px page margin.
          // `KaziSafeArea`'s own default (24px) would otherwise stack with
          // it, doubling the gap from the screen edge.
          padding: EdgeInsets.zero,
          onRefresh: () =>
              ref.read(dashboardControllerProvider.notifier).onRefresh(),
          child: _DashboardContent(state: state),
        ),
      ),
    );
  }
}

class _DashboardContent extends ConsumerWidget {
  const _DashboardContent({required this.state});

  final DashboardState state;

  String _todayHeading(DashboardState state) {
    final services = state.todayServices;
    final heading = KaziLocalizations.current.todaySection(services.length);
    final totals = state.todayTotals;

    if (services.isEmpty || totals.isPartial) return heading;

    return '$heading · '
        '${NumberFormatUtils.formatCurrencyIn(totals.commission, totals.currency)}';
  }

  Widget _todayRow(Service service, {required bool isFollowedByBanner}) {
    final card = ServiceCard(
      service: service,
      onTap: () => KaziNavigator.push(
        AppPage.serviceDetails,
        extra: ServiceArguments(service: service),
      ),
    );
    if (!isFollowedByBanner) return card;

    return AdBlock(
      key: ValueKey('ad-${service.id}'),
      // The card theme's bottom margin already spaces the banner from the card
      // above; this mirrors it below.
      padding: const EdgeInsets.only(bottom: KaziInsets.sm),
      borderRadius: KaziRadii.mdBorder,
      child: card,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayServices = state.todayServices;
    final hasNothing = state.services.isEmpty;
    final bannerPolicy = ref.watch(bannerAdPolicyProvider);

    return ColoredBox(
      color: context.colors.background,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          KaziInsets.md,
          KaziInsets.lg,
          KaziInsets.md,
          KaziInsets.md,
        ),
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
                _CycleLabel(state: state),
              ],
            ),
            KaziSpacings.verticalMd,
            if (state.status == BaseStateStatus.error) ...[
              _ErrorBand(message: state.callbackMessage),
              KaziSpacings.verticalMd,
            ],
            if (state.totals.isPartial) ...[
              PartialTotalsNote(totals: state.totals),
              KaziSpacings.verticalMd,
            ],
            _EarningsCard(state: state),
            KaziSpacings.verticalMd,
            const _QuickActionsRow(),
            KaziSpacings.verticalMd,
            const OnboardingChecklistCard(),
            const ActiveUserNudges(),
            if (hasNothing)
              _NothingToShow()
            else ...[
              _TodayHeading(heading: _todayHeading(state)),
              KaziSpacings.verticalMd,
              if (todayServices.isEmpty)
                KaziNoResults(
                  message: KaziLocalizations.current.noServicesToday,
                  messageStyle: KaziTextStyles.titleSmall,
                  icon: LucideIcons.coffee,
                )
              else
                for (final (position, service) in todayServices.indexed) ...[
                  if (position > 0) KaziSpacings.verticalXs,
                  _todayRow(
                    service,
                    isFollowedByBanner: bannerPolicy.shouldShowAfter(
                      position,
                      total: todayServices.length,
                    ),
                  ),
                ],
            ],
          ],
        ),
      ),
    );
  }
}

/// The period being shown, e.g. "September 2026". Switching periods is not
/// wired up yet — the chevron marks room for it, but nothing responds to a
/// tap here today.
class _CycleLabel extends StatelessWidget {
  const _CycleLabel({required this.state});

  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final start =
        state.cycleRange?.start ?? state.referenceDate ?? DateTime.now();
    final locale = Localizations.localeOf(context).toString();
    final label = '${start.monthName(locale)} ${start.year}';

    return Row(
      children: [
        Text(
          label,
          style: KaziTextStyles.labelMedium.copyWith(
            color: context.colors.textMuted,
          ),
        ),
        Icon(
          LucideIcons.chevronDown,
          size: 16,
          color: context.colors.textMuted,
        ),
      ],
    );
  }
}

class _TodayHeading extends ConsumerWidget {
  const _TodayHeading({required this.heading});

  final String heading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(child: Text(heading.toUpperCase(), style: KaziTextStyles.tag)),
        KaziTextButton(
          onTap: () {
            unawaited(
              ref
                  .read(serviceLandingControllerProvider.notifier)
                  .openServices(
                    view: ServiceView.list,
                    period: FastSearch.today,
                  ),
            );
            KaziNavigator.navigate(AppPage.services);
          },
          child: Text(KaziLocalizations.current.seeInList),
        ),
      ],
    );
  }
}

class _NothingToShow extends StatelessWidget {
  const _NothingToShow();

  @override
  Widget build(BuildContext context) {
    return KaziEmpty(
      message: KaziLocalizations.current.noServicesYet,
      description: KaziLocalizations.current.noServicesYetDescription,
      action: KaziElevatedButton.label(
        onTap: () => KaziNavigator.push(AppPage.addServices),
        label: KaziLocalizations.current.newService,
      ),
    );
  }
}

class _ErrorBand extends ConsumerWidget {
  const _ErrorBand({required this.message});

  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KaziInsets.sm),
      decoration: BoxDecoration(
        color: colors.danger.surface,
        borderRadius: KaziRadii.smBorder,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message.isEmpty
                  ? KaziLocalizations.current.errorToGetServices
                  : message,
              style: KaziTextStyles.labelSmall.copyWith(
                color: colors.danger.onSurface,
              ),
            ),
          ),
          KaziSpacings.horizontalSm,
          KaziTextButton(
            onTap: ref.read(dashboardControllerProvider.notifier).onRefresh,
            color: colors.danger.onSurface,
            child: Text(KaziLocalizations.current.tryAgain),
          ),
        ],
      ),
    );
  }
}

/// The floating black card: this cycle's commission, and how much of it has
/// actually landed. Sits inside the page's own padding like any other card —
/// there is no edge-to-edge panel and no status-bar bleed here any more.
class _EarningsCard extends StatelessWidget {
  const _EarningsCard({required this.state});

  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final totals = state.totals;
    final pending = totals.commission - totals.receivedCommission;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.money.surface,
        borderRadius: KaziRadii.lgBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(KaziInsets.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  KaziLocalizations.current.earningsThisMonth,
                  style: KaziTextStyles.labelMedium.copyWith(
                    color: colors.money.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                KaziSpacings.verticalXs,
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    NumberFormatUtils.formatCurrencyIn(
                      totals.commission,
                      totals.currency,
                    ),
                    style: KaziTextStyles.amount.copyWith(
                      color: colors.money.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // A visually distinct sub-panel, one shade lighter than the amount
          // above it — the stat breakdown reads as supporting detail, not a
          // continuation of the headline.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(KaziInsets.sm),
            color: colors.money.surfaceMuted,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _Stat(
                      label: KaziLocalizations.current.statGenerated,
                      amount: totals.value,
                      currency: totals.currency,
                    ),
                  ),
                  const _StatDivider(),
                  Expanded(
                    child: _Stat(
                      label: KaziLocalizations.current.statReceived,
                      amount: totals.receivedCommission,
                      currency: totals.currency,
                    ),
                  ),
                  const _StatDivider(),
                  Expanded(
                    child: _Stat(
                      label: KaziLocalizations.current.statPending,
                      amount: pending,
                      currency: totals.currency,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: KaziInsets.xs),
      child: VerticalDivider(
        width: 1,
        thickness: 1,
        color: context.colors.money.onSurface.withValues(alpha: 0.15),
      ),
    );
  }
}

/// The three big primary actions below the cycle panel: register a service,
/// add a client, or jump to the catalog — all real destinations, so there is
/// nothing here that looks tappable and does nothing.
class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    final l10n = KaziLocalizations.current;

    return Row(
      children: [
        Expanded(
          child: KaziQuickActionButton(
            icon: LucideIcons.plus,
            label: l10n.newService,
            onTap: () => KaziNavigator.push(AppPage.addServices),
          ),
        ),
        Expanded(
          child: KaziQuickActionButton(
            icon: LucideIcons.userPlus,
            label: l10n.addClient,
            onTap: () => KaziNavigator.push(AppPage.addClient),
            isPrimary: false,
          ),
        ),
        Expanded(
          child: KaziQuickActionButton(
            icon: LucideIcons.layoutGrid,
            label: l10n.catalogItems,
            onTap: () => KaziNavigator.push(AppPage.serviceCatalog),
            isPrimary: false,
          ),
        ),
      ],
    );
  }
}

/// One column of the cycle panel's Generated/Received/Pending breakdown.
class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.amount,
    required this.currency,
  });

  final String label;
  final double amount;
  final SupportedCurrency currency;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            NumberFormatUtils.formatCurrencyIn(amount, currency),
            style: KaziTextStyles.titleSmall.copyWith(
              color: colors.money.onSurface,
            ),
            maxLines: 1,
          ),
        ),
        KaziSpacings.verticalXxs,
        Text(
          label,
          style: KaziTextStyles.labelSmall.copyWith(
            color: colors.money.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
