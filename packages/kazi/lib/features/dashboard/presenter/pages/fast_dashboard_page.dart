import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/dashboard/presenter/controllers/dashboard_controller.dart';
import 'package:kazi/features/dashboard/presenter/controllers/dashboard_state.dart';
import 'package:kazi/features/auth/domain/models/app_user.dart';
import 'package:kazi/features/dashboard/presenter/widgets/today_service_card.dart';
import 'package:kazi/features/onboarding/domain/models/checklist_step.dart';
import 'package:kazi/features/onboarding/presenter/controllers/checklist_controller.dart';
import 'package:kazi/features/onboarding/presenter/widgets/active_user_nudges.dart';
import 'package:kazi/features/onboarding/presenter/widgets/onboarding_checklist_card.dart';
import 'package:kazi/features/services/domain/models/service_view.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_controller.dart';
import 'package:kazi/features/services/presenter/widgets/partial_totals_note.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// The home: the cycle's money on a graphite panel, then what was done today.
/// Layout and content decisions are in `features/dashboard/README.md`.
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
    ref.listen<DashboardState>(dashboardControllerProvider, (
      previous,
      current,
    ) {
      if (previous?.status != current.status &&
          current.status == BaseStateStatus.error) {
        KaziSnackbar.show(context, current.callbackMessage);
      }
    });

    final state = ref.watch(dashboardControllerProvider);
    // Read before the padding is removed below, so the panel can pay it back.
    final topInset = context.topPadding;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Derived from the panel the status bar sits on, never hardcoded.
      value: context.colors.overlayOn(context.colors.money.surface),
      child: Scaffold(
        // The panel runs behind the status bar, so the top inset is dropped
        // here and re-applied inside the panel.
        body: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: KaziSafeArea(
            isLoading: state.status == BaseStateStatus.loading,
            padding: EdgeInsets.zero,
            onRefresh: () =>
                ref.read(dashboardControllerProvider.notifier).onRefresh(),
            child: _DashboardContent(state: state, topInset: topInset),
          ),
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.state, required this.topInset});

  final DashboardState state;

  /// Status bar height, handed down because the ambient padding was removed.
  final double topInset;

  /// "Hoje · 4 serviços · R$ 435" — the gross, dropped entirely when a rate is
  /// missing rather than understated. See README.md.
  String _todayHeading(DashboardState state) {
    final services = state.todayServices;
    final heading = KaziLocalizations.current.todaySection(services.length);
    final totals = state.todayTotals;

    if (services.isEmpty || totals.isPartial) return heading;

    return '$heading · '
        '${NumberFormatUtils.formatCurrencyIn(totals.value, totals.currency)}';
  }

  @override
  Widget build(BuildContext context) {
    final todayServices = state.todayServices;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CyclePanel(state: state, topInset: topInset),
        Padding(
          padding: const EdgeInsets.all(KaziInsets.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Off the graphite panel on purpose: the note's ink is tuned for
              // the page surface. Guarded here so the gap goes with it.
              if (state.totals.isPartial) ...[
                PartialTotalsNote(totals: state.totals),
                KaziSpacings.verticalMd,
              ],
              const OnboardingChecklistCard(),
              const ActiveUserNudges(),
              Text(
                _todayHeading(state).toUpperCase(),
                style: KaziTextStyles.tag,
              ),
              KaziSpacings.verticalMd,
              if (todayServices.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: KaziInsets.lg),
                  child: Text(
                    KaziLocalizations.current.noServicesToday,
                    style: KaziTextStyles.bodyMedium.copyWith(
                      fontSize: 15,
                      height: 24 / 15,
                    ),
                  ),
                )
              else
                for (final service in todayServices)
                  TodayServiceCard(service: service),
            ],
          ),
        ),
      ],
    );
  }
}

/// The second way into the menu, alongside the tab. See README.md.
class _MenuAvatar extends StatelessWidget {
  const _MenuAvatar({required this.user});

  final AppUser? user;

  /// First letter of the name, or of the e-mail when the name is missing.
  String get _initial {
    final source = (user?.name.isNotEmpty ?? false)
        ? user!.name
        : (user?.email ?? '');
    return source.isEmpty ? '?' : source.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: KaziLocalizations.current.menu,
      child: InkResponse(
        onTap: () => KaziNavigator.navigate(AppPage.settings),
        radius: KaziSizings.minTouchTarget / 2,
        child: SizedBox.square(
          dimension: KaziSizings.minTouchTarget,
          child: Center(
            child: CircleAvatar(
              radius: 14,
              backgroundColor: context.colors.brand.fill,
              foregroundImage: (user?.thereIsPhoto ?? false)
                  ? NetworkImage(user!.photoUrl!)
                  : null,
              child: Text(
                _initial,
                style: KaziTextStyles.labelMedium.copyWith(
                  color: context.colors.brand.onFill,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The cycle's money, on the graphite panel. See README.md.
class _CyclePanel extends ConsumerWidget {
  const _CyclePanel({required this.state, required this.topInset});

  final DashboardState state;

  /// Status bar height: the panel paints under it, so it pads its content by it.
  final double topInset;

  /// "Agosto · fecha em 22 dias" — the month the cycle **opens** in, not the
  /// payday month.
  String _cycleLabel(BuildContext context) {
    final start =
        state.cycleRange?.start ?? state.referenceDate ?? DateTime.now();
    final locale = Localizations.localeOf(context).toString();
    final month = DateFormat.MMMM(locale).format(start);
    // Only the first letter: `capitalize()` would title-case every word, and
    // pt/es render months lower-case.
    final named = month.isEmpty
        ? month
        : '${month[0].toUpperCase()}${month.substring(1)}';

    final days = state.daysUntilClose;
    if (days == null) return named;

    return '$named · ${KaziLocalizations.current.cycleClosesIn(days)}';
  }

  /// Opens the services tab already showing the summary. The view is state on
  /// a keepAlive controller, so no route parameter is involved and the tab
  /// keeps whatever period the user last set on it.
  void _openSummary(WidgetRef ref) {
    ref
        .read(serviceLandingControllerProvider.notifier)
        .onChangeView(ServiceView.summary);
    unawaited(
      ref
          .read(checklistControllerProvider.notifier)
          .markStep(ChecklistStep.seeSummary),
    );
    KaziNavigator.navigate(AppPage.services);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totals = state.totals;
    final sharePercent = state.sharePercent;

    final generated = KaziLocalizations.current.cycleGeneratedIn(
      state.services.length,
      NumberFormatUtils.formatCurrencyIn(totals.value, totals.currency),
    );
    final generatedLine = sharePercent == null
        ? generated
        : '${NumberFormatUtils.formatPercent(sharePercent.roundToDouble())}'
              ' $generated';

    return Container(
      width: context.width,
      padding: EdgeInsets.fromLTRB(
        KaziInsets.lg,
        KaziInsets.lg + topInset,
        KaziInsets.lg,
        KaziInsets.lg,
      ),
      decoration: BoxDecoration(
        color: context.colors.money.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(KaziRadii.sm),
          bottomRight: Radius.circular(KaziRadii.sm),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  // Upper-cased at the call site: Flutter has no text-transform.
                  _cycleLabel(context).toUpperCase(),
                  style: KaziTextStyles.tag.copyWith(
                    color: context.colors.money.onSurface,
                  ),
                ),
              ),
              _MenuAvatar(user: ref.watch(authServiceProvider).user),
            ],
          ),
          KaziSpacings.verticalLg,
          // Scaled down rather than wrapped or ellipsised: six digits do not
          // fit 360dp, and a truncated amount is worse than a smaller one.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              NumberFormatUtils.formatCurrencyIn(
                totals.commission,
                totals.currency,
              ),
              style: KaziTextStyles.amount.copyWith(
                color: context.colors.money.onSurface,
              ),
            ),
          ),
          KaziSpacings.verticalLg,
          InkWell(
            onTap: () => _openSummary(ref),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    generatedLine,
                    style: KaziTextStyles.labelLarge.copyWith(
                      color: context.colors.money.accent,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                KaziSpacings.horizontalXxs,
                Icon(
                  Icons.chevron_right,
                  size: KaziSizings.iconSm,
                  color: context.colors.money.accent,
                ),
              ],
            ),
          ),
          // Only once something has been paid; a permanent zero reads as a
          // problem rather than as absence.
          if (totals.hasReceived) ...[
            KaziSpacings.verticalXs,
            Text(
              KaziLocalizations.current.alreadyReceived(
                NumberFormatUtils.formatCurrencyIn(
                  totals.receivedCommission,
                  totals.currency,
                ),
              ),
              style: KaziTextStyles.bodyMedium.copyWith(
                fontSize: 15,
                height: 24 / 15,
                color: context.colors.money.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
