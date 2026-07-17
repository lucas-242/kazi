import 'package:flutter/material.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/core/widgets/buttons/buttons.dart';
import 'package:kazi/core/widgets/custom_scaffold/custom_scaffold.dart';
import 'package:kazi/features/services/presenter/controllers/service_types_controller.dart';
import 'package:kazi/features/services/presenter/controllers/service_types_state.dart';
import 'package:kazi/features/services/presenter/widgets/service_type_form_content.dart';
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

    void onTapBack() {
      controller.eraseServiceType();
      KaziNavigator.pop();
    }

    ref.listen<ServiceTypesState>(serviceTypesControllerProvider, (
      previous,
      current,
    ) {
      if (previous?.status != current.status &&
          current.status == BaseStateStatus.success) {
        KaziNavigator.pop();
      }
    });

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        controller.eraseServiceType();
      },
      child: CustomSafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            state.serviceType.id.isEmpty
                ? BackAndPill(
                    text: KaziLocalizations.current.newServiceType,
                    onTapBack: () => onTapBack(),
                  )
                : BackAndPill(
                    text: KaziLocalizations.current.editServiceType,
                    pillText: KaziLocalizations.current.delete,
                    backgroundColor: context.colorsScheme.error,
                    onTapBack: () => onTapBack(),
                    onTapPill: () =>
                        controller.deleteServiceType(state.serviceType),
                  ),
            KaziSpacings.verticalXLg,
            ServiceTypeFormContent(onConfirm: onConfirm),
          ],
        ),
      ),
    );
  }
}
