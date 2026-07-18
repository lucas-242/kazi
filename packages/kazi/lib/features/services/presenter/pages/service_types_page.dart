import 'package:flutter/material.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/services/presenter/controllers/service_types_controller.dart';
import 'package:kazi/features/services/presenter/controllers/service_types_state.dart';
import 'package:kazi/features/services/presenter/widgets/service_type_no_data_navbar.dart';
import 'package:kazi/features/services/presenter/widgets/service_types_content.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
import 'package:kazi_core/kazi_core.dart';

class ServiceTypesPage extends ConsumerStatefulWidget {
  const ServiceTypesPage({super.key});

  @override
  ConsumerState<ServiceTypesPage> createState() => _ServiceTypesPageState();
}

class _ServiceTypesPageState extends ConsumerState<ServiceTypesPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(serviceTypesControllerProvider.notifier).onInit(),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ServiceTypesState>(serviceTypesControllerProvider, (
      previous,
      current,
    ) {
      if (previous?.status != current.status &&
          current.status == BaseStateStatus.error) {
        KaziSnackbar.show(context, current.callbackMessage);
      }
    });

    final state = ref.watch(serviceTypesControllerProvider);

    return Scaffold(
      body: KaziSafeArea(
        onRefresh: () =>
            ref.read(serviceTypesControllerProvider.notifier).getServiceTypes(),
        child: state.when(
          onState: (_) => const ServiceTypesContent(),
          onLoading: () => const KaziLoading(),
          onNoData: () => KaziNoData(
            message: KaziLocalizations.current.noServiceTypes,
            navbar: const ServiceTypeNoDataNavbar(),
          ),
        ),
      ),
    );
  }
}
