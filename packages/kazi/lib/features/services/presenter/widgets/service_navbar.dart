import 'package:flutter/material.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/widgets/buttons/buttons.dart';
import 'package:kazi/core/widgets/texts/texts.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_controller.dart';
import 'package:kazi/features/services/presenter/pages/service_filters_page.dart';
import 'package:kazi/features/services/presenter/widgets/order_by_bottom_sheet.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
import 'package:kazi_core/kazi_core.dart';

class ServiceNavbar extends ConsumerWidget {
  const ServiceNavbar({
    super.key,
    required this.dateKey,
    required this.dateController,
  });

  final GlobalKey<FormFieldState<dynamic>> dateKey;
  final TextEditingController dateController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceState = ref.watch(serviceLandingControllerProvider);
    final serviceController = ref.read(
      serviceLandingControllerProvider.notifier,
    );

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
                selectedOption: serviceState.selectedOrderBy,
                onPressed: (orderBy) {
                  KaziNavigator.pop();
                  serviceController.onChangeOrderBy(orderBy);
                },
              ),
            ),
            child: const Icon(Icons.swap_vert, size: 18),
          ),
          KaziSpacings.horizontalXs,
          CircularButton(
            showCircularIndicator: serviceState.didFiltersChange,
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
