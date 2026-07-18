import 'package:flutter/material.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/widgets/sub_nav_bar.dart';
import 'package:kazi/features/services/presenter/controllers/service_types_controller.dart';
import 'package:kazi/features/services/presenter/widgets/service_type_card.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
import 'package:kazi_core/kazi_core.dart';

class ServiceTypesContent extends ConsumerWidget {
  const ServiceTypesContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(serviceTypesControllerProvider.notifier);
    final state = ref.watch(serviceTypesControllerProvider);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SubNavBar(
            title: KaziLocalizations.current.serviceTypes,
            pills: [
              KaziCircularButton(
                onTap: () => KaziNavigator.push(AppPage.addServiceType),
                child: const Icon(Icons.add),
              ),
            ],
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
                itemCount: state.serviceTypes.length,
                itemBuilder: (context, index) => ServiceTypeCard(
                  serviceType: state.serviceTypes[index],
                  onTapEdit: (serviceType) {
                    controller.changeServiceType(serviceType);
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
