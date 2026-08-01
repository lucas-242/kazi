import 'package:flutter/material.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/widgets/info_card.dart';
import 'package:kazi/features/dashboard/presenter/controllers/dashboard_state.dart';
import 'package:kazi/features/services/presenter/widgets/service_list.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
import 'package:kazi_core/kazi_core.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key, required this.state});

  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KaziSpacings.verticalLg,
        InfoCard(
          title: NumberFormatUtils.formatCurrencyIn(
            state.totalWithDiscount,
            state.defaultCurrency,
          ),
          subtitle: KaziLocalizations.current.myBalance,
          icon: KaziSvgAssets.services,
          color: KaziColors.green,
        ),
        InfoCard(
          title: NumberFormatUtils.formatCurrencyIn(
            state.totalDiscounted,
            state.defaultCurrency,
          ),
          subtitle: KaziLocalizations.current.discounts,
          icon: KaziSvgAssets.fire,
          color: KaziColors.orange,
        ),
        InfoCard(
          title: NumberFormatUtils.formatCurrencyIn(
            state.totalValue,
            state.defaultCurrency,
          ),
          subtitle: KaziLocalizations.current.totalReceived,
          icon: KaziSvgAssets.rocket,
          color: KaziColors.blue,
        ),
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
