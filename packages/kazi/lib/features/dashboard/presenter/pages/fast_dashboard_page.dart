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

/// The home: the month's money on a graphite panel, then what was done today.
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
      // Light icons: the status bar now sits on graphite, and the app's light
      // theme would otherwise paint them dark on dark. statusBarColor covers
      // the devices that predate edge-to-edge, where the panel cannot show
      // through on its own. Only status bar fields are set — the preset
      // `SystemUiOverlayStyle.light` would also blacken the navigation bar.
      value: SystemUiOverlayStyle(
        statusBarColor: context.kaziColors.moneySurface,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
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
            // the month (zeroed) and the daily list says it is empty.
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

  @override
  Widget build(BuildContext context) {
    final todayServices = state.todayServices;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MonthPanel(state: state, topInset: topInset),
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
                KaziLocalizations.current.todaysServices.toUpperCase(),
                style: KaziTextStyles.tag,
              ),
              KaziSpacings.verticalMd,
              if (todayServices.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: KaziInsets.lg),
                  child: Text(
                    KaziLocalizations.current.noServicesToday,
                    style: KaziTextStyles.support,
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
              backgroundColor: context.kaziColors.accentSurface,
              foregroundImage: (user?.thereIsPhoto ?? false)
                  ? NetworkImage(user!.photoUrl!)
                  : null,
              child: Text(
                _initial,
                style: KaziTextStyles.labelMd.copyWith(
                  color: context.kaziColors.onAccentSurface,
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
class _MonthPanel extends ConsumerWidget {
  const _MonthPanel({required this.state, required this.topInset});

  final DashboardState state;

  /// Status bar height: the panel paints under it, so it pads its content by it.
  final double topInset;

  String _monthAndYear(BuildContext context) {
    final date = state.referenceDate ?? DateTime.now();
    final locale = Localizations.localeOf(context).toString();
    final formatted = DateFormat.yMMMM(locale).format(date);
    // Only the first letter: `capitalize()` would title-case every word, and
    // pt/es render this as "novembro de 2026".
    return formatted.isEmpty
        ? formatted
        : '${formatted[0].toUpperCase()}${formatted.substring(1)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totals = state.totals;
    final sharePercent = state.sharePercent;

    final toReceive = NumberFormatUtils.formatCurrencyIn(
      totals.withDiscount,
      totals.currency,
    );
    final toReceiveLine = sharePercent == null
        ? '${KaziLocalizations.current.toReceive}: $toReceive'
        : '${KaziLocalizations.current.toReceive}: $toReceive'
              ' . ${NumberFormatUtils.formatPercent(sharePercent.roundToDouble())}';

    return Container(
      width: context.width,
      padding: EdgeInsets.fromLTRB(
        KaziInsets.lg,
        KaziInsets.lg + topInset,
        KaziInsets.lg,
        KaziInsets.lg,
      ),
      decoration: BoxDecoration(
        color: context.kaziColors.moneySurface,
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
                  _monthAndYear(context),
                  style: KaziTextStyles.support.copyWith(
                    color: context.kaziColors.onMoneySurface,
                  ),
                ),
              ),
              _MenuAvatar(user: ref.watch(authServiceProvider).user),
            ],
          ),
          KaziSpacings.verticalLg,
          Text(
            NumberFormatUtils.formatCurrencyIn(totals.value, totals.currency),
            style: KaziTextStyles.money.copyWith(
              color: context.kaziColors.onMoneySurface,
            ),
          ),
          KaziSpacings.verticalLg,
          Text(
            toReceiveLine,
            style: KaziTextStyles.labelLg.copyWith(
              color: context.kaziColors.moneyAccent,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
