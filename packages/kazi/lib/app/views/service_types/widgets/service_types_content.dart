import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kazi/app/shared/extensions/extensions.dart';
import 'package:kazi/app/shared/l10n/generated/l10n.dart';
import 'package:kazi/app/shared/widgets/buttons/buttons.dart';
import 'package:kazi/app/views/service_types/service_types.dart';
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
            text: AppLocalizations.current.serviceTypes,
            pillText: AppLocalizations.current.newType,
            onTapPill: () => context.navigateTo(AppPage.addServiceType),
            onTapBack: () => context.navigateTo(AppPage.profile),
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
                    context.navigateTo(AppPage.addServiceType);
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
