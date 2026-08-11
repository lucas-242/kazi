import 'package:flutter/material.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/services/presenter/controllers/service_types_controller.dart';
import 'package:kazi/features/services/presenter/controllers/service_types_state.dart';
import 'package:kazi/features/services/presenter/widgets/service_type_form.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
import 'package:kazi_core/kazi_core.dart';

class ServiceTypeFormPage extends ConsumerWidget {
  const ServiceTypeFormPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(serviceTypesControllerProvider.notifier);
    final state = ref.watch(serviceTypesControllerProvider);

    void onConfirm() {
      if (state.serviceType.id.isEmpty) {
        controller.addServiceType();
      } else {
        controller.updateServiceType();
      }
    }

    ref.listen<ServiceTypesState>(serviceTypesControllerProvider, (
      previous,
      current,
    ) {
      if (previous?.status != current.status &&
          current.status == BaseStateStatus.success) {
        final wasCreating = previous?.serviceType.id.isEmpty ?? false;
        KaziNavigator.pop();
        if (wasCreating) {
          KaziNavigator.push(AppPage.addServices);
        }
      }
    });

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        controller.eraseServiceType();
      },
      child: Scaffold(
        appBar: KaziAppBar(
          title: state.serviceType.id.isEmpty
              ? KaziLocalizations.current.newServiceType.capitalize()
              : ('${KaziLocalizations.current.edit} ${state.serviceType.name}')
                    .capitalize(),
          actions: [
            if (state.serviceType.id.isNotEmpty)
              KaziCircularButton(
                onTap: () => controller.deleteServiceType(state.serviceType),
                backgroundColor: context.colors.brand.fill,
                child: Icon(
                  Icons.delete,
                  color: context.colors.brand.onFill,
                ),
              ),
            KaziSpacings.horizontalSm,
          ],
        ),
        body: KaziSafeArea(child: ServiceTypeForm(onConfirm: onConfirm)),
      ),
    );
  }
}
