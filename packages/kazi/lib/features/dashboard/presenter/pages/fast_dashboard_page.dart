import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/auth/domain/models/app_user.dart';
import 'package:kazi/features/dashboard/presenter/controllers/dashboard_controller.dart';
import 'package:kazi/features/dashboard/presenter/controllers/dashboard_state.dart';
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
    final state = ref.watch(dashboardControllerProvider);
    // Read before the padding is removed below, so the panel can pay it back.
    final topInset = context.topPadding;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.colors.overlayOn(context.colors.money.surface),
      child: Scaffold(
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

class _DashboardContent extends ConsumerWidget {
  const _DashboardContent({required this.state, required this.topInset});

  final DashboardState state;

  /// Status bar height, handed down because the ambient padding was removed.
  final double topInset;

  String _todayHeading(DashboardState state) {
    final services = state.todayServices;
    final heading = KaziLocalizations.current.todaySection(services.length);
    final totals = state.todayTotals;

    if (services.isEmpty || totals.isPartial) return heading;

    return '$heading · '
        '${NumberFormatUtils.formatCurrencyIn(totals.value, totals.currency)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayServices = state.todayServices;
    // Nothing in the whole cycle is an account with nothing, and gets the
    // invitation. A day with nothing on it, in a cycle that has services, is
    // just a quiet day — the brand block there would read as an empty account
    // every morning.
    final hasNothing = state.services.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CyclePanel(state: state, topInset: topInset),
        Padding(
          padding: const EdgeInsets.all(KaziInsets.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // A band above the content, never in place of it: the cycle
              // total keeps the last value it knew rather than blanking.
              if (state.status == BaseStateStatus.error) ...[
                _ErrorBand(message: state.callbackMessage),
                KaziSpacings.verticalMd,
              ],
              if (state.totals.isPartial) ...[
                PartialTotalsNote(totals: state.totals),
                KaziSpacings.verticalMd,
              ],
              const OnboardingChecklistCard(),
              const ActiveUserNudges(),
              if (hasNothing)
                _NothingRegisteredYet()
              else ...[
                _TodayHeading(heading: _todayHeading(state)),
                KaziSpacings.verticalMd,
                if (todayServices.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: KaziInsets.lg,
                    ),
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
                KaziSpacings.verticalMd,
                _SeeSummaryRow(state: state),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// The day's line of work, and the way into the same day on the list. Every
/// "ver mais" in the app lands on the services tab with a filter applied — no
/// shortcut opens a screen of its own.
class _TodayHeading extends ConsumerWidget {
  const _TodayHeading({required this.heading});

  final String heading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: Text(
            // Upper-cased at the call site: Flutter has no text-transform.
            heading.toUpperCase(),
            style: KaziTextStyles.tag,
          ),
        ),
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

/// The last line of the home, and the second door into the summary.
class _SeeSummaryRow extends ConsumerWidget {
  const _SeeSummaryRow({required this.state});

  final DashboardState state;

  String _month(BuildContext context) {
    final start =
        state.cycleRange?.start ?? state.referenceDate ?? DateTime.now();
    final locale = Localizations.localeOf(context).toString();
    final month = DateFormat.MMMM(locale).format(start);

    // Only the first letter: `capitalize()` would title-case every word, and
    // pt/es render months lower-case.
    return month.isEmpty
        ? month
        : '${month[0].toUpperCase()}${month.substring(1)}';
  }

  void _open(WidgetRef ref) {
    unawaited(
      ref
          .read(serviceLandingControllerProvider.notifier)
          .openServices(view: ServiceView.summary),
    );
    unawaited(
      ref
          .read(checklistControllerProvider.notifier)
          .markStep(ChecklistStep.seeSummary),
    );
    KaziNavigator.navigate(AppPage.services);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;

    return Material(
      color: colors.card,
      borderRadius: KaziRadii.smBorder,
      child: InkWell(
        onTap: () => _open(ref),
        borderRadius: KaziRadii.smBorder,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            minHeight: KaziSizings.minTouchTarget,
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: KaziRadii.smBorder,
            border: Border.all(color: colors.border),
          ),
          child: Text(
            KaziLocalizations.current.seeSummaryOf(_month(context)),
            style: KaziTextStyles.labelLarge.copyWith(color: colors.brand.text),
          ),
        ),
      ),
    );
  }
}

/// An account with nothing in it. It invites rather than reports — the panel
/// above is already reporting a zero, and a second zero would only confirm it.
class _NothingRegisteredYet extends StatelessWidget {
  const _NothingRegisteredYet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: KaziInsets.xLg),
      child: KaziEmpty(
        message: KaziLocalizations.current.registerFirstService,
        description: KaziLocalizations.current.registerFirstServiceDescription,
        action: KaziPillButton(
          onTap: () => KaziNavigator.push(AppPage.addServices),
          child: Text(KaziLocalizations.current.newService),
        ),
      ),
    );
  }
}

/// A read that failed, said in one line above content that is still usable.
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

/// The second way into the menu, alongside the tab. See README.md.
class _MenuAvatar extends StatelessWidget {
  const _MenuAvatar({required this.user});

  final AppUser? user;

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

  String _cycleLabel(BuildContext context) {
    final start =
        state.cycleRange?.start ?? state.referenceDate ?? DateTime.now();
    final locale = Localizations.localeOf(context).toString();
    final month = DateFormat.MMMM(locale).format(start);
    final named = month.isEmpty
        ? month
        : '${month[0].toUpperCase()}${month.substring(1)}';

    final days = state.daysUntilClose;
    if (days == null) return named;

    return '$named · ${KaziLocalizations.current.cycleClosesIn(days)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totals = state.totals;

    final generatedLine =
        '${KaziLocalizations.current.yourEarnings} · '
        '${KaziLocalizations.current.cycleGeneratedIn(state.services.length, NumberFormatUtils.formatCurrencyIn(totals.value, totals.currency))}';

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
          // Not tappable: the way into the summary is the row at the end of
          // the day's list, which says where it goes. A number that navigates
          // on touch is a control disguised as a figure.
          Text(
            generatedLine,
            style: KaziTextStyles.labelLarge.copyWith(
              color: context.colors.money.accent,
              fontWeight: FontWeight.w400,
            ),
          ),
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
