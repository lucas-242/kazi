import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/core/widgets/buttons/buttons.dart';
import 'package:kazi/core/widgets/custom_scaffold/custom_scaffold.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
import 'package:kazi_core/kazi_core.dart';

import '../service_types.dart';

class ServiceTypeFormPage extends StatefulWidget {
  const ServiceTypeFormPage({super.key});

  @override
  State<ServiceTypeFormPage> createState() => _ServiceTypeFormPageState();
}

class _ServiceTypeFormPageState extends State<ServiceTypeFormPage> {
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ServiceTypesCubit>();

    void onConfirm() {
      if (cubit.state.serviceType.id.isEmpty) {
        cubit.addServiceType();
      } else {
        cubit.updateServiceType();
      }
    }

    void onTapBack() {
      cubit.eraseServiceType();
      KaziNavigator.pop();
    }

    return BlocProvider.value(
      value: cubit,
      child: PopScope(
        onPopInvokedWithResult: (didPop, result) {
          cubit.eraseServiceType();
        },
        child: CustomSafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              cubit.state.serviceType.id.isEmpty
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
                          cubit.deleteServiceType(cubit.state.serviceType),
                    ),
              KaziSpacings.verticalXLg,
              BlocListener<ServiceTypesCubit, ServiceTypesState>(
                listenWhen: (previous, current) =>
                    previous.status != current.status,
                listener: (context, state) {
                  if (state.status == BaseStateStatus.success) {
                    KaziNavigator.pop();
                  }
                },
                child: BlocBuilder<ServiceTypesCubit, ServiceTypesState>(
                  builder: (context, state) =>
                      ServiceTypeFormContent(onConfirm: onConfirm),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
