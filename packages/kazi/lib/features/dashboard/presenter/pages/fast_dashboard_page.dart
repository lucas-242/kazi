import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/core/utils/period_label.dart';
import 'package:kazi/core/widgets/ads/ad_block.dart';
import 'package:kazi/features/dashboard/presenter/controllers/dashboard_controller.dart';
import 'package:kazi/features/dashboard/presenter/controllers/dashboard_state.dart';
import 'package:kazi/features/onboarding/presenter/widgets/active_user_nudges.dart';
import 'package:kazi/features/onboarding/presenter/widgets/onboarding_checklist_card.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/domain/models/service_totals.dart';
import 'package:kazi/features/services/domain/models/service_view.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_controller.dart';
import 'package:kazi/features/services/presenter/widgets/partial_totals_note.dart';
import 'package:kazi/features/services/presenter/widgets/service_card.dart';
import 'package:kazi/features/services/services.dart';
import 'package:kazi/features/settings/domain/models/billing_cycle.dart';
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
    // Only the very first fetch has nothing to show behind it — a refresh
    // already has a page's worth of valid data, and blocking the whole
    // screen for that reads as slower than it is. `referenceDate` is null
    // exactly until the first fetch resolves, loading or not.
    final isFirstLoad =
        state.status == BaseStateStatus.loading && state.referenceDate == null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.colors.overlayOn(context.colors.background),
      child: Scaffold(
        body: KaziSafeArea(
          // Zero: `_DashboardContent` applies its own 16px page margin.
          // `KaziSafeArea`'s own default (24px) would otherwise stack with
          // it, doubling the gap from the screen edge.
          padding: EdgeInsets.zero,
          onRefresh: () =>
              ref.read(dashboardControllerProvider.notifier).onRefresh(),
          child: isFirstLoad
              ? const _DashboardSkeleton()
              : _DashboardContent(state: state),
        ),
      ),
    );
  }
}

/// Shaped like the real page rather than a spinner over it — the same
/// `KaziSkeleton`/`KaziSkeletonList` blocks the Clients and Services lists
/// already use, so the home stops being the one screen in the app that
/// blanks itself while loading. Everything outside it (nav bar, FAB) stays
/// live, on purpose — see `KaziSkeletonList`'s own doc.
class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          KaziInsets.md,
          KaziInsets.lg + KaziInsets.xxs,
          KaziInsets.md,
          KaziInsets.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                KaziSkeleton(width: 84, height: 20),
                KaziSkeleton(
                  width: 72,
                  height: 20,
                  borderRadius: KaziRadii.fullBorder,
                ),
              ],
            ),
            KaziSpacings.verticalMd,
            const KaziSkeleton(
              width: double.infinity,
              height: 172,
              borderRadius: KaziRadii.lgBorder,
            ),
            KaziSpacings.verticalMd,
            const Row(
              children: [
                Expanded(
                  child: KaziSkeleton(width: double.infinity, height: 72),
                ),
                KaziSpacings.horizontalSm,
                Expanded(
                  child: KaziSkeleton(width: double.infinity, height: 72),
                ),
                KaziSpacings.horizontalSm,
                Expanded(
                  child: KaziSkeleton(width: double.infinity, height: 72),
                ),
              ],
            ),
            KaziSpacings.verticalMd,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(KaziInsets.sm),
              decoration: BoxDecoration(
                color: context.colors.surfaceMuted,
                borderRadius: KaziRadii.lgBorder,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: KaziInsets.xs),
                    child: KaziSkeleton(width: 132, height: 14),
                  ),
                  KaziSpacings.verticalSm,
                  KaziSkeletonList(count: 3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardContent extends ConsumerWidget {
  const _DashboardContent({required this.state});

  final DashboardState state;

  /// Takes the day's services and totals already resolved by [build], rather
  /// than reading `state.todayServices`/`state.todayTotals` again — each is
  /// its own un-cached filter/sum over every service, and `build` already
  /// needs both for the list below this heading.
  String _todayHeading(List<Service> todayServices, ServiceTotals totals) {
    final heading = KaziLocalizations.current.todaySection(
      todayServices.length,
    );
    if (todayServices.isEmpty || totals.isPartial) return heading;

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
    // Read once and threaded through below: `totals`/`todayServices` are
    // plain un-cached getters (each a full pass over `state.services`), and
    // this page reads every one of them more than once in a build.
    final totals = state.totals;
    final todayServices = state.todayServices;
    final todayTotals = ServiceTotals.from(
      todayServices,
      currency: state.defaultCurrency,
      rateBook: state.rateBook,
    );
    final hasNothing = state.services.isEmpty;
    final bannerPolicy = ref.watch(bannerAdPolicyProvider);

    return ColoredBox(
      color: context.colors.background,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          KaziInsets.md,
          KaziInsets.lg + KaziInsets.xxs,
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
            if (totals.isPartial) ...[
              PartialTotalsNote(totals: totals),
              KaziSpacings.verticalMd,
            ],
            _StaggerIn(
              index: 0,
              child: _EarningsCard(state: state, totals: totals),
            ),
            const SizedBox(height: KaziInsets.md + KaziInsets.xxs),
            const _StaggerIn(index: 1, child: _QuickActionsRow()),
            KaziSpacings.verticalMd,
            const OnboardingChecklistCard(),
            const ActiveUserNudges(),
            if (hasNothing)
              _NothingToShow()
            else
              _StaggerIn(
                index: 2,
                // A tray, not rows loose on the page background: below the
                // black card the whole screen was reading as bare text and
                // hairline-bordered rows with nothing tying them together as
                // a group. `colors.surfaceMuted` sits a step off the page
                // background, so `ServiceCard`'s own `colors.card` rows still
                // read as distinct cards *inside* it, not folded into it.
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(KaziInsets.sm),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceMuted,
                    borderRadius: KaziRadii.lgBorder,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: KaziInsets.xs,
                        ),
                        child: _TodayHeading(
                          heading: _todayHeading(todayServices, todayTotals),
                        ),
                      ),
                      KaziSpacings.verticalSm,
                      if (todayServices.isEmpty)
                        KaziNoResults(
                          message: KaziLocalizations.current.noServicesToday,
                          messageStyle: KaziTextStyles.titleSmall,
                          icon: LucideIcons.coffee,
                        )
                      else
                        for (final (position, service)
                            in todayServices.indexed) ...[
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
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Fades and lifts a section into place once, [index] setting how far behind
/// the first one it starts. Never replays on its own: `initState` only runs
/// once for this Element's position in the tree, so a rebuild from marking a
/// service received, switching periods or pulling to refresh leaves it alone
/// — this is a first-paint entrance, not a per-update flourish.
class _StaggerIn extends StatefulWidget {
  const _StaggerIn({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<_StaggerIn> createState() => _StaggerInState();
}

class _StaggerInState extends State<_StaggerIn> {
  static const _stagger = Duration(milliseconds: 70);
  static const _duration = Duration(milliseconds: 320);

  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(_stagger * widget.index, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Read here, not in `initState`, which runs before this Element has a
    // stable set of inherited dependencies to read from.
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final visible = _visible || reduceMotion;
    final duration = reduceMotion ? Duration.zero : _duration;

    return AnimatedSlide(
      offset: visible ? Offset.zero : const Offset(0, 0.06),
      duration: duration,
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: duration,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// The billing cycle's exact window, e.g. "6 ago - 5 set" or "Setembro 2026"
/// for a cycle that happens to span a whole month. Plain text, not a button
/// — the Payment Cycle setting in Ajustes is what picks the window now, so
/// nothing here should read as tappable. See README.md.
class _CycleLabel extends StatelessWidget {
  const _CycleLabel({required this.state});

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

/// Nothing in the current cycle — not the same thing as an account with no
/// services ever, so it reads like the "nothing today" tray below it
/// (`KaziNoResults`, the coffee mark), not like the brand's first-run
/// `KaziEmpty` block: data missing from *this* cut, per `KaziNoResults`'s
/// own doc, is exactly what an empty cycle is.
class _NothingToShow extends StatelessWidget {
  const _NothingToShow();

  @override
  Widget build(BuildContext context) {
    return KaziNoResults(
      icon: LucideIcons.coffee,
      message: KaziLocalizations.current.noServicesYet,
      description: KaziLocalizations.current.noServicesYetDescription,
      actionLabel: KaziLocalizations.current.newService,
      onAction: () => KaziNavigator.push(AppPage.addServices),
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
      padding: const EdgeInsets.all(KaziInsets.md),
      decoration: BoxDecoration(
        color: colors.danger.surface,
        // The rest of the page moved to the card's own lg radius (the
        // earnings card, the today tray) — a small-radius strip here was the
        // one thing still speaking the flatter, pre-redesign language.
        borderRadius: KaziRadii.lgBorder,
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

/// The floating black card: this cycle's commission on top, and — one tap
/// away — how much of it has actually landed. The breakdown starts collapsed
/// so the amount on top is the only number competing for attention; the
/// chevron beside it is what reveals Received/Pending. Sits inside the page's
/// own padding like any other card — there is no edge-to-edge panel and no
/// status-bar bleed here any more.
class _EarningsCard extends StatefulWidget {
  const _EarningsCard({required this.state, required this.totals});

  final DashboardState state;

  /// `state.totals`, resolved once by `_DashboardContent.build` — `totals`
  /// is a plain getter that re-sums every service on each read, and this
  /// page already needed it for [PartialTotalsNote] and the partial check
  /// above this card.
  final ServiceTotals totals;

  @override
  State<_EarningsCard> createState() => _EarningsCardState();
}

/// "Seus ganhos este mês" only fits a monthly cycle — whoever is paid
/// fortnightly or weekly reads a label that names a window they are not
/// looking at. Named per [BillingCycleType] instead, so the card's own
/// headline stays coherent with whatever the Payment Cycle setting produced.
/// Null (nothing fetched yet) falls back to the monthly wording, the app's
/// long-standing default.
String _earningsEyebrow(BillingCycleType? type) {
  final l10n = KaziLocalizations.current;
  return switch (type) {
    BillingCycleType.fortnightly => l10n.earningsThisFortnight,
    BillingCycleType.weekly => l10n.earningsThisWeek,
    BillingCycleType.custom => l10n.earningsThisCycle,
    BillingCycleType.monthly || null => l10n.earningsThisMonth,
  };
}

class _EarningsCardState extends State<_EarningsCard> {
  bool _expanded = false;

  /// The bucket under the finger — tap, hold or drag. Lives here, not inside
  /// [_EarningsSparkline], so a tap anywhere else on this card (the amount,
  /// the toggle, the breakdown) can clear it: those are true siblings of the
  /// chart's own gesture region, not its ancestor, so wrapping them carries
  /// no risk of a tap on a bar *also* firing the clear — an ancestor
  /// wrapping the chart itself would.
  int? _selectedBucketIndex;

  /// Resolved once per genuine change to [_EarningsCard.state] rather than
  /// on every build: toggling `_expanded` alone rebuilds this widget without
  /// a new `state`, and `_periodTotals` is a full pass over every service to
  /// re-bucket for a chart whose data has not actually changed.
  late _PeriodTrend _trend = _periodTotals(widget.state);

  @override
  void didUpdateWidget(_EarningsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _trend = _periodTotals(widget.state);
      // A period switch can shrink or reshuffle the buckets entirely; a
      // selection from the previous chart has nothing reliable to point at.
      _selectedBucketIndex = null;
    }
  }

  void _onToggleExpanded() {
    HapticFeedback.selectionClick();
    setState(() => _expanded = !_expanded);
  }

  void _onSelectBucket(int? index) {
    if (index != _selectedBucketIndex) {
      setState(() => _selectedBucketIndex = index);
    }
  }

  void _clearSelection() {
    if (_selectedBucketIndex != null) {
      setState(() => _selectedBucketIndex = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final totals = widget.totals;
    final pending = totals.pendingCommission;
    final trend = _trend;

    // The shadow lives on this outer box, unclipped: a `Container` cannot
    // clip its own content to rounded corners *and* paint a shadow that
    // extends past those corners — the clip would cut the shadow off too.
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: KaziRadii.lgBorder,
        boxShadow: [
          BoxShadow(
            color: colors.money.surface.withValues(alpha: 0.16),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: KaziRadii.lgBorder,
        child: DecoratedBox(
          // A faint sheen, not a second colour: top-left a touch lighter than
          // the card's own black, fading back into it — depth without
          // drifting from the brand's flat graphite.
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(colors.money.surface, Colors.white, 0.05)!,
                colors.money.surface,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Symmetric margins, nothing reserved on the right: the toggle
              // used to sit centered over this whole section, which meant
              // every line in it — including the amount and the chart —
              // gave up space on the right so the toggle never sat on top of
              // them. It now sits beside the eyebrow-and-amount column
              // specifically (vertically centred against *both* of them,
              // `Row`'s own default cross-axis alignment — centring it on
              // the eyebrow alone read as sitting too high), while the chart
              // is this Column's own sibling below the row, so it keeps the
              // full width regardless of where the toggle sits.
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  KaziInsets.lg,
                  KaziInsets.lg - KaziInsets.xxs,
                  KaziInsets.lg,
                  KaziInsets.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _clearSelection,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _earningsEyebrow(widget.state.cycleType),
                                  style: KaziTextStyles.labelMedium.copyWith(
                                    color: colors.money.onSurface.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ),
                                KaziSpacings.verticalXs,
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: _AnimatedAmount(
                                    value: totals.commission,
                                    currency: totals.currency,
                                    style: KaziTextStyles.amount.copyWith(
                                      color: colors.money.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _ExpandToggle(
                            expanded: _expanded,
                            onTap: _onToggleExpanded,
                          ),
                        ],
                      ),
                    ),
                    if (trend.buckets.length > 2) ...[
                      KaziSpacings.verticalSm,
                      _EarningsSparkline(
                        trend: trend,
                        expanded: _expanded,
                        currency: totals.currency,
                        textColor: colors.money.onSurface.withValues(
                          alpha: 0.7,
                        ),
                        receivedColor: colors.money.accent,
                        pendingColor: colors.money.onSurface.withValues(
                          alpha: 0.35,
                        ),
                        selectedIndex: _selectedBucketIndex,
                        onSelect: _onSelectBucket,
                      ),
                    ],
                  ],
                ),
              ),
              // The same shade the card already used for this panel before
              // the breakdown became collapsible — a dropdown revealing
              // detail still reads as a step below the headline, just one
              // shade of black, not the page's own neutral surface.
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _clearSelection,
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  child: !_expanded
                      ? const SizedBox(width: double.infinity)
                      : Container(
                          width: double.infinity,
                          // Horizontal inset matches the box's own left/right
                          // margins above, so Received/Pending line up with
                          // the eyebrow and the toggle instead of hugging the
                          // edges.
                          padding: const EdgeInsets.symmetric(
                            horizontal: KaziInsets.lg,
                            vertical: KaziInsets.sm,
                          ),
                          color: colors.money.surfaceMuted,
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: _Stat(
                                    label:
                                        KaziLocalizations.current.statReceived,
                                    amount: totals.receivedCommission,
                                    currency: totals.currency,
                                    color: colors.money.onSurface,
                                    labelColor: colors.money.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                                const _StatDivider(),
                                Expanded(
                                  child: _Stat(
                                    label:
                                        KaziLocalizations.current.statPending,
                                    amount: pending,
                                    currency: totals.currency,
                                    color: colors.money.onSurface,
                                    labelColor: colors.money.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One bucket's own commission, split by whether it landed yet, and the
/// stretch of the period it covers — for [_EarningsSparkline], which stacks
/// the split when the card is expanded and names the stretch on tap.
typedef _BucketTotal = ({
  double received,
  double pending,
  DateTime start,
  DateTime end,
});

/// The period's shape, resolved once: which [_BucketGranularity] applies and
/// each bucket's own totals — [_EarningsSparkline] needs both, the second to
/// draw and the first to know how to name whichever bucket is tapped.
typedef _PeriodTrend = ({
  _BucketGranularity granularity,
  List<_BucketTotal> buckets,
});

/// One bucket's own commission across the selected period, for
/// [_EarningsSparkline] — a shape, not a precise ledger, so a service whose
/// rate cannot be resolved is silently dropped from its bucket rather than
/// flagged: [PartialTotalsNote] already owns that conversation.
///
/// Per bucket, not a running total: a cumulative line only ever rises and
/// looks much the same shape regardless of the period, telling the user
/// nothing a single number couldn't. Which stretches were busy is the thing
/// a bar chart answers and a line does not.
///
/// The bucket itself widens with the period rather than the chart
/// disappearing past some fixed span: a day a bucket up to two months, a
/// week up to a year, a month beyond that — a hand-picked range can run from
/// 2020 to today, and a chart that vanishes for exactly the ranges someone
/// reaches for "all-time" totals is a chart nobody can rely on.
_PeriodTrend _periodTotals(DashboardState state) {
  final range = state.cycleRange;
  if (range == null) {
    return (granularity: _BucketGranularity.day, buckets: const []);
  }

  final start = DateTime(range.start.year, range.start.month, range.start.day);
  final end = DateTime(range.end.year, range.end.month, range.end.day);
  final totalDays = end.difference(start).inDays;
  if (totalDays < 2) {
    return (granularity: _BucketGranularity.day, buckets: const []);
  }

  final granularity = totalDays <= 60
      ? _BucketGranularity.day
      : totalDays <= 365
      ? _BucketGranularity.week
      : _BucketGranularity.month;

  final bucketCount = switch (granularity) {
    _BucketGranularity.day => totalDays + 1,
    _BucketGranularity.week => (totalDays ~/ 7) + 1,
    _BucketGranularity.month =>
      (end.year - start.year) * 12 + (end.month - start.month) + 1,
  };

  DateTime bucketStart(int i) => switch (granularity) {
    _BucketGranularity.day => DateTime(start.year, start.month, start.day + i),
    _BucketGranularity.week => DateTime(
      start.year,
      start.month,
      start.day + i * 7,
    ),
    _BucketGranularity.month => DateTime(start.year, start.month + i),
  };

  // The last bucket's end is clamped to the period's own end: a trailing
  // partial week or month must not claim days the period never covered.
  DateTime bucketEnd(int i) {
    final natural = switch (granularity) {
      _BucketGranularity.day => bucketStart(i),
      _BucketGranularity.week => DateTime(
        start.year,
        start.month,
        start.day + i * 7 + 6,
      ),
      _BucketGranularity.month => DateTime(start.year, start.month + i + 1, 0),
    };
    return natural.isAfter(end) ? end : natural;
  }

  final received = List<double>.filled(bucketCount, 0);
  final pending = List<double>.filled(bucketCount, 0);
  for (final service in state.services) {
    final converted = service.convert(
      service.commissionValue,
      to: state.defaultCurrency,
      fallback: state.defaultCurrency,
      rateBook: state.rateBook,
    );
    if (converted == null) continue;

    final day = DateTime(
      service.date.year,
      service.date.month,
      service.date.day,
    );
    final index = switch (granularity) {
      _BucketGranularity.day => day.difference(start).inDays,
      _BucketGranularity.week => day.difference(start).inDays ~/ 7,
      _BucketGranularity.month =>
        (day.year - start.year) * 12 + (day.month - start.month),
    };
    if (index < 0 || index >= bucketCount) continue;
    if (service.isReceived) {
      received[index] += converted;
    } else {
      pending[index] += converted;
    }
  }

  return (
    granularity: granularity,
    buckets: [
      for (var i = 0; i < bucketCount; i++)
        (
          received: received[i],
          pending: pending[i],
          start: bucketStart(i),
          end: bucketEnd(i),
        ),
    ],
  );
}

enum _BucketGranularity { day, week, month }

/// [bucket]'s stretch in the user's words: a day names itself, a week or a
/// month names its span — short enough for a one-line tooltip, exact enough
/// to say which one was tapped.
String _bucketDateLabel(_BucketGranularity granularity, _BucketTotal bucket) {
  String short(DateTime date) =>
      '${date.day} ${date.monthName().substring(0, 3)}';

  return switch (granularity) {
    _BucketGranularity.day => short(bucket.start),
    _BucketGranularity.week =>
      bucket.start.month == bucket.end.month
          ? '${bucket.start.day}-${bucket.end.day} '
                '${bucket.end.monthName().substring(0, 3)}'
          : '${short(bucket.start)} - ${short(bucket.end)}',
    _BucketGranularity.month =>
      '${bucket.start.monthName()} ${bucket.start.year}',
  };
}

/// The period's shape in one glance: one bar per bucket (day, week or month,
/// set by [_periodTotals]), height proportional to that bucket's own
/// commission. Reads at a size too small for axes or labels to mean anything
/// on its own — touching a bar is what supplies the missing exactness, in a
/// caption above the row rather than a floating tooltip that would have to
/// dodge the amount above it.
///
/// Collapsed, each bar is one solid mark — Received and Pending are not the
/// question yet. Expanded, the same bars split into the two, in the same
/// colours the breakdown below already uses: the "something more" the chart
/// gains on expand is the same detail the numbers beside it just revealed,
/// not a decoration unrelated to what the tap was for.
///
/// A controlled component: [selectedIndex] and [onSelect] live in
/// `_EarningsCardState`, not here, so a tap on the *rest* of the card (the
/// amount, the toggle, the breakdown) can clear the selection — a sibling of
/// this chart's own gesture region can do that safely; an ancestor wrapping
/// the chart itself could not, without also swallowing the very tap meant to
/// select a bar. See `_EarningsCardState._selectedBucketIndex`.
class _EarningsSparkline extends StatelessWidget {
  const _EarningsSparkline({
    required this.trend,
    required this.expanded,
    required this.currency,
    required this.textColor,
    required this.receivedColor,
    required this.pendingColor,
    required this.selectedIndex,
    required this.onSelect,
  });

  final _PeriodTrend trend;
  final bool expanded;
  final SupportedCurrency currency;
  final Color textColor;
  final Color receivedColor;
  final Color pendingColor;
  final int? selectedIndex;
  final ValueChanged<int?> onSelect;

  int _bucketAt(double dx, double width) {
    final slotWidth = width / trend.buckets.length;
    return (dx / slotWidth).floor().clamp(0, trend.buckets.length - 1);
  }

  String _caption(_BucketTotal bucket) {
    final label = _bucketDateLabel(trend.granularity, bucket);
    final total = bucket.received + bucket.pending;
    if (!expanded || total <= 0) {
      return '$label · ${NumberFormatUtils.formatCurrencyIn(total, currency)}';
    }

    final l10n = KaziLocalizations.current;
    return '$label · ${l10n.statReceived} '
        '${NumberFormatUtils.formatCurrencyIn(bucket.received, currency)}'
        ' · ${l10n.statPending} '
        '${NumberFormatUtils.formatCurrencyIn(bucket.pending, currency)}';
  }

  @override
  Widget build(BuildContext context) {
    final buckets = trend.buckets;
    // Clamped, not asserted: a period switch can shrink the bucket count
    // while a selection from the old chart is still around for one frame.
    final selected = selectedIndex != null && selectedIndex! < buckets.length
        ? buckets[selectedIndex!]
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          alignment: Alignment.topLeft,
          child: selected == null
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(bottom: KaziInsets.xxs),
                  child: Text(
                    _caption(selected),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: KaziTextStyles.labelSmall.copyWith(color: textColor),
                  ),
                ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            void selectAt(Offset local) =>
                onSelect(_bucketAt(local.dx, constraints.maxWidth));

            return Semantics(
              // One region describing whichever bucket is selected (or the
              // instruction to touch one), not a label per bar: the bars
              // are painted, not separate widgets, so per-bar semantics
              // would need hand-built `SemanticsNode`s for a chart this
              // small. A screen reader still gets the exact figure a sighted
              // user gets by dragging a finger across it.
              label: selected == null
                  ? KaziLocalizations.current.earningsChartHint
                  : _caption(selected),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                // Fires on first touch, not only once a drag is recognized —
                // the same finger-down that might become a scrub already
                // picks a bar, so there is no dead first tap.
                onTapDown: (details) => selectAt(details.localPosition),
                onHorizontalDragStart: (details) =>
                    selectAt(details.localPosition),
                // Passing the finger across the row keeps swapping in
                // whichever bucket sits under it — a scrub, not a sequence
                // of separate taps.
                onHorizontalDragUpdate: (details) =>
                    selectAt(details.localPosition),
                child: SizedBox(
                  width: double.infinity,
                  height: 32,
                  // `AnimatedSwitcher` lays its child out inside a `Stack`,
                  // which hands it *loose* constraints even though this
                  // whole tree is already sized exactly — a bare
                  // `CustomPaint` under loose constraints, with no child and
                  // no explicit size, collapses to zero rather than filling
                  // the space. `SizedBox.expand` forces it back to fill
                  // whatever the Stack actually gave it.
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: SizedBox.expand(
                      key: ValueKey(expanded),
                      child: CustomPaint(
                        painter: _SparklinePainter(
                          buckets: buckets,
                          expanded: expanded,
                          selectedIndex: selectedIndex,
                          receivedColor: receivedColor,
                          pendingColor: pendingColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.buckets,
    required this.expanded,
    required this.selectedIndex,
    required this.receivedColor,
    required this.pendingColor,
  });

  final List<_BucketTotal> buckets;
  final bool expanded;
  final int? selectedIndex;
  final Color receivedColor;
  final Color pendingColor;

  /// The slice of each day's own width the bar itself fills — the rest is
  /// the gap that lets each day read as a separate mark, not one solid block.
  static const _barWidthFraction = 0.55;

  /// Kept visible even at zero, at this fraction of the chart's height — a
  /// quiet day should still mark its place in the row, not vanish from it.
  static const _minHeightFraction = 0.06;

  @override
  void paint(Canvas canvas, Size size) {
    final totals = [
      for (final bucket in buckets) bucket.received + bucket.pending,
    ];
    final maxValue = totals.reduce((a, b) => a > b ? a : b);
    final range = maxValue <= 0 ? 1.0 : maxValue;
    final slotWidth = size.width / buckets.length;
    final barWidth = slotWidth * _barWidthFraction;
    final minHeight = size.height * _minHeightFraction;

    final paint = Paint();
    for (var i = 0; i < buckets.length; i++) {
      final total = totals[i];
      final barHeight = (total / range * size.height).clamp(
        minHeight,
        size.height,
      );
      final left = slotWidth * i + (slotWidth - barWidth) / 2;
      final top = size.height - barHeight;
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(left, top, barWidth, barHeight),
        topLeft: const Radius.circular(2),
        topRight: const Radius.circular(2),
      );

      if (!expanded || total <= 0) {
        canvas.drawRRect(
          rect,
          // A bucket with nothing in it reads as a faint mark, not the same
          // weight as one that actually earned something.
          paint
            ..color = total <= 0
                ? receivedColor.withValues(alpha: 0.18)
                : receivedColor,
        );
      } else {
        // Stacked: received from the baseline up, pending capping it off in
        // a paler tone — the same split the numbers below spell out, read
        // here as one shape per bucket instead of two columns for the whole
        // period.
        canvas.save();
        canvas.clipRRect(rect);
        final pendingHeight = barHeight * (buckets[i].pending / total);
        canvas
          ..drawRect(
            Rect.fromLTWH(left, top, barWidth, barHeight - pendingHeight),
            paint..color = receivedColor,
          )
          ..drawRect(
            Rect.fromLTWH(left, top, barWidth, pendingHeight),
            paint..color = pendingColor,
          );
        canvas.restore();
      }

      if (i == selectedIndex) {
        canvas.drawCircle(
          Offset(left + barWidth / 2, top - 4),
          2,
          paint..color = receivedColor,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      !identical(oldDelegate.buckets, buckets) ||
      oldDelegate.expanded != expanded ||
      oldDelegate.selectedIndex != selectedIndex ||
      oldDelegate.receivedColor != receivedColor ||
      oldDelegate.pendingColor != pendingColor;
}

/// A money [Text] that counts to a new [value] instead of jumping to it — the
/// number the user cannot work out in their head is worth a beat of motion
/// when it changes, on load and after a period switch alike.
class _AnimatedAmount extends StatelessWidget {
  const _AnimatedAmount({
    required this.value,
    required this.currency,
    required this.style,
  });

  final double value;
  final SupportedCurrency currency;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, animated, child) => Text(
        NumberFormatUtils.formatCurrencyIn(animated, currency),
        style: style,
        maxLines: 1,
      ),
    );
  }
}

/// The chevron that reveals the stat breakdown, flipping upside down when
/// open rather than rotating sideways — the same "open/closed" convention
/// as the onboarding checklist's own disclosure arrow.
class _ExpandToggle extends StatelessWidget {
  const _ExpandToggle({required this.expanded, required this.onTap});

  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: true,
      label: KaziLocalizations.current.details,
      child: InkWell(
        borderRadius: KaziRadii.fullBorder,
        onTap: onTap,
        // The icon itself stays small; the tappable area around it does not
        // — 32px (24px icon + 4px padding each side) missed taps often
        // enough to notice. `minTouchTarget` centers the same icon inside a
        // proper 48px target without changing how the chevron looks.
        child: SizedBox(
          width: KaziSizings.minTouchTarget,
          height: KaziSizings.minTouchTarget,
          child: Center(
            child: AnimatedRotation(
              turns: expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                LucideIcons.chevronDown,
                size: KaziSizings.iconMd,
                color: colors.money.onSurface,
              ),
            ),
          ),
        ),
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

/// One column of the earnings card's Received/Pending breakdown.
class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.amount,
    required this.currency,
    required this.color,
    required this.labelColor,
  });

  final String label;
  final double amount;
  final SupportedCurrency currency;
  final Color color;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: _AnimatedAmount(
            value: amount,
            currency: currency,
            // Tabular figures here too, same as `KaziTextStyles.amount`
            // itself: Received and Pending sit side by side, and digits that
            // do not keep their column make the pair look uneven even when
            // the values are not.
            style: KaziTextStyles.titleSmall.copyWith(
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        KaziSpacings.verticalXxs,
        Text(
          label,
          style: KaziTextStyles.labelSmall.copyWith(color: labelColor),
        ),
      ],
    );
  }
}
