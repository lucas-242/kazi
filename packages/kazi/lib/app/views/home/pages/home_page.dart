import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kazi/app/shared/extensions/extensions.dart';
import 'package:kazi/app/shared/utils/base_state.dart';
import 'package:kazi/app/shared/widgets/buttons/buttons.dart';
import 'package:kazi/app/shared/widgets/custom_scaffold/custom_scaffold.dart';
import 'package:kazi/app/views/home/home.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
import 'package:kazi_core/kazi_core.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    final cubit = context.read<HomeCubit>();
    cubit.onInit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomSafeArea(
      onRefresh: () => context.read<HomeCubit>().onRefresh(),
      child: BlocListener<HomeCubit, HomeState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == BaseStateStatus.error) {
            KaziSnackbar.show(context, state.callbackMessage);
          }
        },
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            return state.when(
              onState: (_) => HomeContent(state: state),
              onLoading: () => const KaziLoading(),
              onNoData: () => KaziNoData(
                message: KaziLocalizations.current.noServicesHome,
                navbar: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    PillButton(
                      onTap: () => context.navigateTo(AppPage.addServices),
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
