import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kazi/app/shared/utils/base_state.dart';
import 'package:kazi/app/shared/widgets/custom_scaffold/custom_scaffold.dart';
import 'package:kazi/app/views/service_types/widgets/service_type_no_data_navbar.dart';
import 'package:kazi/app/views/service_types/widgets/service_types_content.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
import 'package:kazi_core/kazi_core.dart';

import '../service_types.dart';

class ServiceTypesPage extends StatelessWidget {
  const ServiceTypesPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<ServiceTypesCubit>().onInit();

    return CustomSafeArea(
      onRefresh: () => context.read<ServiceTypesCubit>().getServiceTypes(),
      child: BlocListener<ServiceTypesCubit, ServiceTypesState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == BaseStateStatus.error) {
            KaziSnackbar.show(context, state.callbackMessage);
          }
        },
        child: BlocBuilder<ServiceTypesCubit, ServiceTypesState>(
          buildWhen: (previous, current) => previous.status != current.status,
          builder: (context, state) {
            return state.when(
              onState: (_) => const ServiceTypesContent(),
              onLoading: () => const KaziLoading(),
              onNoData: () => KaziNoData(
                message: KaziLocalizations.current.noServiceTypes,
                navbar: const ServiceTypeNoDataNavbar(),
              ),
            );
          },
        ),
      ),
    );
  }
}
