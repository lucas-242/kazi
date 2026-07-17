import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kazi/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:kazi/features/dashboard/widgets/home_content.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/core/widgets/buttons/buttons.dart';
import 'package:kazi/core/widgets/custom_scaffold/custom_scaffold.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
import 'package:kazi_core/kazi_core.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    final cubit = context.read<DashboardCubit>();
    cubit.onInit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomSafeArea(
      onRefresh: () => context.read<DashboardCubit>().onRefresh(),
      child: BlocListener<DashboardCubit, DashboardState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == BaseStateStatus.error) {
            KaziSnackbar.show(context, state.callbackMessage);
          }
        },
        child: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            return state.when(
              onState: (_) => DashboardContent(state: state),
              onLoading: () => const KaziLoading(),
              onNoData: () => KaziNoData(
                message: KaziLocalizations.current.noServicesHome,
                navbar: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    PillButton(
                      onTap: () => KaziNavigator.push(AppPage.addServices),
                      child: Text(KaziLocalizations.current.newService),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
