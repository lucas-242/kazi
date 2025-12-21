import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kazi/app/models/service.dart';
import 'package:kazi/app/shared/extensions/extensions.dart';
import 'package:kazi/app/shared/utils/base_state.dart';
import 'package:kazi/app/shared/widgets/custom_scaffold/custom_scaffold.dart';
import 'package:kazi/app/views/service_types/widgets/service_type_no_data_navbar.dart';
import 'package:kazi/app/views/services/service_form/widgets/service_form_content.dart';
import 'package:kazi/app/views/services/services.dart';
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
        context.read<ServiceLandingCubit>().onChangeServices();
        context.back();
      } else if (currentStatus == BaseStateStatus.error) {
        final message = current.asData?.value.callbackMessage ?? '';
        if (message.isNotEmpty) {
          KaziSnackbar.show(context, message);
        }
      }
    });

    final asyncState = ref.watch(provider);
    return CustomSafeArea(
      child: SingleChildScrollView(
        child: asyncState.when(
          data: (state) {
            return state.when(
              onState: (_) {
                if (state.status == BaseStateStatus.readyToUserInput) {
                  return ServiceFormContent(
                    service: widget.service,
                    isCreating: isCreating(widget.service),
                    onConfirm: () => onConfirm(state.service),
                  );
                }

                return const KaziLoading();
              },
              onLoading: () => const KaziLoading(),
              onNoData: () => KaziNoData(
                message: KaziLocalizations.current.noServiceTypes,
                navbar: const ServiceTypeNoDataNavbar(),
              ),
            );
          },
          loading: () => const KaziLoading(),
          error: (_, __) => const KaziLoading(),
        ),
      ),
    );
  }
}
