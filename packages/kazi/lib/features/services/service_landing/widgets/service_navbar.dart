import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/widgets/buttons/buttons.dart';
import 'package:kazi/core/widgets/texts/texts.dart';
import 'package:kazi/features/services/services.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
import 'package:kazi_core/kazi_core.dart';

class ServiceNavbar extends StatelessWidget {
  const ServiceNavbar({
    super.key,
    required this.dateKey,
    required this.dateController,
  });

  final GlobalKey<FormFieldState<dynamic>> dateKey;
  final TextEditingController dateController;

  @override
  Widget build(BuildContext context) {
    final serviceCubit = context.read<ServiceLandingCubit>();

    return TextWithTrailing(
      text: KaziLocalizations.current.services,
      trailing: Row(
        children: [
          CircularButton(
            onTap: () => showModalBottomSheet(
              context: context,
              useRootNavigator: true,
              isScrollControlled: true,
              builder: (context) => OrderByBottomSheet(
                selectedOption: serviceCubit.state.selectedOrderBy,
                onPressed: (orderBy) {
                  KaziNavigator.pop();
                  serviceCubit.onChangeOrderBy(orderBy);
                },
              ),
            ),
            child: const Icon(Icons.swap_vert, size: 18),
          ),
          KaziSpacings.horizontalXs,
          CircularButton(
            showCircularIndicator: serviceCubit.state.didFiltersChange,
            onTap: () => showModalBottomSheet(
              context: context,
              useRootNavigator: true,
              isScrollControlled: true,
              builder: (context) => FiltersBottomSheet(
                dateKey: dateKey,
                dateController: dateController,
              ),
            ),
            child: const Icon(Icons.filter_list_alt, size: 18),
          ),
          KaziSpacings.horizontalXs,
          PillButton(
            onTap: () => KaziNavigator.push(AppPage.addServices),
            child: Text(KaziLocalizations.current.newService),
          ),
        ],
      ),
    );
  }
}
