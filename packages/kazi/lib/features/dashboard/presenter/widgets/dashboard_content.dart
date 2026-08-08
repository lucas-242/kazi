import 'package:flutter/material.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/widgets/info_card.dart';
import 'package:kazi/features/dashboard/presenter/controllers/dashboard_state.dart';
import 'package:kazi/features/services/presenter/widgets/partial_totals_note.dart';
import 'package:kazi/features/services/presenter/widgets/service_list.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key, required this.state});

  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final totals = state.totals;
    final roles = context.kaziColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KaziSpacings.verticalLg,
        InfoCard(
          title: NumberFormatUtils.formatCurrencyIn(
            totals.withDiscount,
            totals.currency,
          ),
          subtitle: KaziLocalizations.current.myBalance,
          icon: KaziSvgAssets.services,
          color: roles.success,
          onColor: roles.onSuccess,
        ),
        InfoCard(
          title: NumberFormatUtils.formatCurrencyIn(
            totals.discounted,
            totals.currency,
          ),
          subtitle: KaziLocalizations.current.discounts,
          icon: KaziSvgAssets.fire,
          color: roles.warning,
          onColor: roles.onWarning,
        ),
        InfoCard(
          title: NumberFormatUtils.formatCurrencyIn(
            totals.value,
            totals.currency,
          ),
          subtitle: KaziLocalizations.current.totalReceived,
          icon: KaziSvgAssets.rocket,
          color: roles.info,
          onColor: roles.onInfo,
        ),
        PartialTotalsNote(totals: totals),
        KaziSpacings.verticalXs,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              KaziLocalizations.current.lastServices.capitalize(),
              style: KaziTextStyles.titleMd,
            ),
            KaziPillButton(
              onTap: () => KaziNavigator.push(AppPage.addServices),
              child: Text(KaziLocalizations.current.newService),
            ),
          ],
        ),
        KaziSpacings.verticalLg,
        SizedBox(
          height: 245,
          child: Card(
            child: ServiceList(
              services: state.services,
              expandList: true,
              canScroll: true,
            ),
          ),
        ),
      ],
    );
  }
}
