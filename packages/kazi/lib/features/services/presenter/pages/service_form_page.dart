import 'package:flutter/material.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/dashboard/presenter/controllers/dashboard_controller.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/presenter/controllers/service_form_controller.dart';
import 'package:kazi/features/services/presenter/controllers/service_form_state.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_controller.dart';
import 'package:kazi/features/services/presenter/widgets/service_form_content.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

class ServiceFormPage extends ConsumerStatefulWidget {
  const ServiceFormPage({super.key, this.service});

  final Service? service;

  @override
  ConsumerState<ServiceFormPage> createState() => _ServiceFormPageState();
}

class _ServiceFormPageState extends ConsumerState<ServiceFormPage> {
  bool isCreating(Service? service) => service?.id.isEmpty ?? true;

  void onConfirm(Service service) {
    final provider = serviceFormControllerProvider(service: widget.service);
    if (isCreating(service)) {
      ref.read(provider.notifier).addService();
    } else {
      ref.read(provider.notifier).updateService();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = serviceFormControllerProvider(service: widget.service);

    ref.listen<AsyncValue<ServiceFormState>>(provider, (previous, current) {
      final previousStatus = previous?.asData?.value.status;
      final currentStatus = current.asData?.value.status;
      if (previousStatus == currentStatus) return;

      if (currentStatus == BaseStateStatus.success) {
        ref.read(serviceLandingControllerProvider.notifier).onChangeServices();
        ref.read(dashboardControllerProvider.notifier).onRefresh();
        KaziNavigator.pop();
      } else if (currentStatus == BaseStateStatus.error) {
        final message = current.asData?.value.callbackMessage ?? '';
        if (message.isNotEmpty) {
          KaziSnackbar.show(context, message);
        }
      }
    });

    final asyncState = ref.watch(provider);
    final state = asyncState.asData?.value;

    return Scaffold(
      appBar: KaziAppBar(
        title: isCreating(widget.service)
            ? KaziLocalizations.current.newService.capitalize()
            : KaziLocalizations.current.editService.capitalize(),
      ),
      body: KaziSafeArea(
        isLoading:
            state == null || state.status != BaseStateStatus.readyToUserInput,
        child: state == null
            ? const SizedBox.shrink()
            : ServiceFormContent(
                service: widget.service,
                isCreating: isCreating(widget.service),
                onConfirm: () => onConfirm(state.service),
              ),
      ),
    );
  }
}
