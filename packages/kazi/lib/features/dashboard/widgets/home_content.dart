import 'package:flutter/material.dart';
import 'package:kazi/core/constants/app_assets.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/widgets/buttons/buttons.dart';
import 'package:kazi/features/services/services.dart';
import 'package:kazi/features/dashboard/cubit/dashboard_cubit.dart';
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
            icon: AppAssets.services,
            color: KaziColors.green,
          ),
          InfoCard(
            title: NumberFormatUtils.formatCurrency(
              context,
              state.totalDiscounted,
            ),
            subtitle: KaziLocalizations.current.discounts,
            icon: AppAssets.fire,
            color: KaziColors.orange,
          ),
          InfoCard(
            title: NumberFormatUtils.formatCurrency(context, state.totalValue),
            subtitle: KaziLocalizations.current.totalReceived,
            icon: AppAssets.rocket,
            color: KaziColors.blue,
          ),
          KaziSpacings.verticalXs,
          TitleAndPill(
            title: KaziLocalizations.current.lastServices,
            pillText: KaziLocalizations.current.newService,
            onTap: () => KaziNavigator.push(AppPage.addServices),
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
