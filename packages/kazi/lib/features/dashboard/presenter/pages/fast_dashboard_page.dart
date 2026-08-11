import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/dashboard/presenter/controllers/dashboard_controller.dart';
import 'package:kazi/features/dashboard/presenter/controllers/dashboard_state.dart';
import 'package:kazi/features/auth/domain/models/app_user.dart';
import 'package:kazi/features/dashboard/presenter/widgets/today_service_card.dart';
import 'package:kazi/features/services/presenter/widgets/partial_totals_note.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

/// The home: the cycle's money on a graphite panel, then what was done today.
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
      // The status bar sits on the money panel, not on the page, so the icon
      // brightness is derived from the panel. Hardcoding "light icons" was
      // right for the graphite panel but wrong the moment the panel changes,
      // and it also blackened the navigation bar in dark mode.
      value: context.colors.overlayOn(context.colors.money.surface),
      child: Scaffold(
        // The button that registers a service belongs to the shell now, so it
        // sits in the same place on every tab.
        //
        // The graphite panel runs behind the status bar, so the top inset is
        // dropped here — KaziSafeArea's own SafeArea would otherwise leave a
        // strip of page background above it — and re-applied inside the panel.
        body: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: KaziSafeArea(
            isLoading: state.status == BaseStateStatus.loading,
            padding: EdgeInsets.zero,
            onRefresh: () =>
                ref.read(dashboardControllerProvider.notifier).onRefresh(),
            // No empty screen: with nothing registered the panel still reports
            // the cycle (zeroed) and the daily list says it is empty.
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

  /// "Hoje · 4 serviços · R$ 435".
  ///
  /// The day's subtotal lives in the section header, next to the list it
  /// describes: its job is operational — confirming nothing went unregistered —
  /// not emotional. That is why it is here and not at the top of the screen.
  ///
  /// The gross, not the commission: [TodayServiceCard] shows each service's
  /// gross, so a commission subtotal would not add up to the visible rows.
  /// When a rate is missing the amount is dropped rather than understated,
  /// the same discipline `sharePercent` already follows.
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
              // the page surface, not for a dark one. Guarded rather than let
              // the note collapse itself, so the gap goes away with it.
              if (state.totals.isPartial) ...[
                PartialTotalsNote(totals: state.totals),
                KaziSpacings.verticalMd,
              ],
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

/// The second way into the menu, alongside the tab.
///
/// Two doors to the same room on purpose: when the Agenda takes the fourth
/// seat in the bar, the menu loses its tab and this becomes the only way in —
/// so it has to already be a habit by then.
class _MenuAvatar extends StatelessWidget {
  const _MenuAvatar({required this.user});

  final AppUser? user;

  /// First letter of the name, or of the e-mail when a display name is missing.
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

/// The graphite panel: "Graphite carries the money."
class _CyclePanel extends ConsumerWidget {
  const _CyclePanel({required this.state, required this.topInset});

  final DashboardState state;

  /// Status bar height: the panel paints under it, so it pads its content by it.
  final double topInset;

  /// "Agosto · fecha em 22 dias".
  ///
  /// The month is the one the cycle's window **opens** in, so a cycle running
  /// 6 Aug → 5 Sep reads "Agosto". Naming it after the payday would label that
  /// same window "Setembro", which is not the work it covers. Without the
  /// closing countdown the amount above floats free of any reference.
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totals = state.totals;
    final sharePercent = state.sharePercent;

    // The other side of the brand's promise: what the work was worth, under
    // what she keeps of it. The share goes here rather than on its own line —
    // for someone paid on commission it is the most reassuring number here.
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
                  // Upper-cased at the call site: `tag` is the brandbook's
                  // eyebrow style and the only place caps are allowed, and
                  // Flutter has no text-transform.
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
          // What she takes home for the cycle — the number she cannot work out
          // in her head, with a different commission on each of 32 services,
          // and the one that becomes money in her account. The gross moved to
          // the line below it.
          //
          // Scaled down rather than wrapped or ellipsised: six digits in
          // Archivo 800 at 32px do not fit 360dp, and a truncated amount is
          // worse than a smaller one.
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
          Text(
            generatedLine,
            style: KaziTextStyles.labelLarge.copyWith(
              color: context.colors.money.accent,
              fontWeight: FontWeight.w400,
            ),
          ),
          // Only once something has actually been paid: a permanent "R$ 0 já
          // recebidos" would read as a problem rather than as absence.
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
