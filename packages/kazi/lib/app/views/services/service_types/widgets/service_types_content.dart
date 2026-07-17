import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/widgets/buttons/buttons.dart';
import 'package:kazi/app/views/services/service_types/service_types.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
import 'package:kazi_core/kazi_core.dart';

class ServiceTypesContent extends StatelessWidget {
  const ServiceTypesContent({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ServiceTypesCubit>();
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BackAndPill(
            text: KaziLocalizations.current.serviceTypes,
            pillText: KaziLocalizations.current.newType,
            onTapPill: () => KaziNavigator.push(AppPage.addServiceType),
            onTapBack: () => KaziNavigator.navigate(AppPage.profile),
          ),
          KaziSpacings.verticalXLg,
          Card(
            child: Padding(
              padding: const EdgeInsets.only(
                left: KaziInsets.lg,
                right: KaziInsets.lg,
                top: KaziInsets.xs,
                bottom: KaziInsets.sm,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cubit.state.serviceTypes.length,
                itemBuilder: (context, index) => ServiceTypeCard(
                  serviceType: cubit.state.serviceTypes[index],
                  onTapEdit: (serviceType) {
                    cubit.changeServiceType(serviceType);
                    KaziNavigator.push(AppPage.addServiceType);
                  },
                ),
                separatorBuilder: (context, index) => const Divider(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
