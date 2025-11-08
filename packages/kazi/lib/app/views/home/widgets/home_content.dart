import 'package:flutter/material.dart';
import 'package:kazi/app/shared/constants/app_onboarding.dart';
import 'package:kazi/app/shared/extensions/extensions.dart';
import 'package:kazi/app/shared/themes/themes.dart';
import 'package:kazi/app/shared/widgets/buttons/buttons.dart';
import 'package:kazi/app/views/home/home.dart';
import 'package:kazi/app/views/services/services.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
import 'package:kazi_core/kazi_core.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key, required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoCard(
            key: AppOnboarding.stepOne,
            title: NumberFormatUtils.formatCurrency(
              context,
              state.totalWithDiscount,
            ),
            subtitle: KaziLocalizations.current.myBalance,
            icon: AppAssets.services,
            color: KaziColors.green,
          ),
          InfoCard(
            key: AppOnboarding.stepTwo,
            title: NumberFormatUtils.formatCurrency(
              context,
              state.totalDiscounted,
            ),
            subtitle: KaziLocalizations.current.discounts,
            icon: AppAssets.fire,
            color: KaziColors.orange,
          ),
          InfoCard(
            key: AppOnboarding.stepThree,
            title: NumberFormatUtils.formatCurrency(context, state.totalValue),
            subtitle: KaziLocalizations.current.totalReceived,
            icon: AppAssets.rocket,
            color: KaziColors.blue,
          ),
          KaziSpacings.verticalXs,
          TitleAndPill(
            title: KaziLocalizations.current.lastServices,
            pillText: KaziLocalizations.current.newService,
            onTap: () => context.navigateTo(AppPage.addServices),
          ),
          KaziSpacings.verticalLg,
          SizedBox(
            key: AppOnboarding.stepFour,
            height: 245,
            child: ServiceList(
              services: state.services,
              expandList: true,
              canScroll: true,
            ),
          ),
        ],
      ),
    );
  }
}
