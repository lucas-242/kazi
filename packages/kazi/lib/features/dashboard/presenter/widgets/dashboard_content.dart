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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoCard(
            title: NumberFormatUtils.formatCurrency(
              context,
              state.totalWithDiscount,
            ),
            subtitle: KaziLocalizations.current.myBalance,
            icon: KaziSvgAssets.services,
            color: KaziColors.green,
          ),
          InfoCard(
            title: NumberFormatUtils.formatCurrency(
              context,
              state.totalDiscounted,
            ),
            subtitle: KaziLocalizations.current.discounts,
            icon: KaziSvgAssets.fire,
            color: KaziColors.orange,
          ),
          InfoCard(
            title: NumberFormatUtils.formatCurrency(context, state.totalValue),
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
      ),
    );
  }
}
