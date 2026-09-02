import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_controller.dart';
import 'package:kazi/features/services/presenter/widgets/service_landing_content.dart';
import 'package:kazi/features/services/presenter/widgets/service_filter_chips.dart';
import 'package:kazi/features/services/presenter/widgets/service_navbar.dart';
import 'package:kazi/features/services/presenter/widgets/service_view_switch.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;
import 'package:kazi_core/kazi_core.dart';

class ServiceLandingPage extends ConsumerStatefulWidget {
  const ServiceLandingPage({super.key});

  @override
  ConsumerState<ServiceLandingPage> createState() => _ServiceLandingPageState();
}

class _ServiceLandingPageState extends ConsumerState<ServiceLandingPage> {
  final dateKey = GlobalKey<FormFieldState>();
  final dateController = MaskedTextController(
    text: 'dd/MM/yyyy - dd/MM/yyyy',
    mask: '00/00/0000 - 00/00/0000',
  );

  @override
  void initState() {
    super.initState();
    final controller = ref.read(serviceLandingControllerProvider.notifier);
    final state = ref.read(serviceLandingControllerProvider);
    dateController.text =
        '${DateFormat.yMd().format(state.startDate).normalizeDate()} - ${DateFormat.yMd().format(state.endDate).normalizeDate()}';
    Future.microtask(controller.onInit);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(serviceLandingControllerProvider);
    final controller = ref.read(serviceLandingControllerProvider.notifier);

    return Scaffold(
      body: KaziSafeArea(
        isScrollView: state.status != BaseStateStatus.noData,
        onRefresh: controller.onRefresh,
        child: switch (state.status) {
          // The bar, the switch and the chips stay live above every one of
          // these: loading is per surface, and a filter that emptied the
          // screen has to be undoable from where it was set.
          BaseStateStatus.loading when state.services.isEmpty => _Surface(
            dateKey: dateKey,
            dateController: dateController,
            child: const KaziSkeletonList(),
          ),
          BaseStateStatus.error => _Surface(
            dateKey: dateKey,
            dateController: dateController,
            child: KaziError(
              message: KaziLocalizations.current.errorToGetServices,
              onRetry: controller.onRefresh,
            ),
          ),
          BaseStateStatus.noData => Column(
            children: [
              ServiceNavbar(dateKey: dateKey, dateController: dateController),
              Expanded(
                child: KaziEmpty(
                  message: KaziLocalizations.current.noServices,
                  description: KaziLocalizations.current.noServicesDescription,
                  scrollable: true,
                  action: KaziPillButton(
                    onTap: () => KaziNavigator.push(AppPage.addServices),
                    child: Text(KaziLocalizations.current.newService),
                  ),
                ),
              ),
            ],
          ),
          _ => ServiceLandingContent(
            state: state,
            dateController: dateController,
            dateKey: dateKey,
          ),
        },
      ),
    );
  }
}

/// The chrome that outlives whatever is loading or failing under it: the
/// header, the List/Summary switch and the chips. Only the area below them is
/// ever replaced.
class _Surface extends StatelessWidget {
  const _Surface({
    required this.dateKey,
    required this.dateController,
    required this.child,
  });

  final GlobalKey<FormFieldState<dynamic>> dateKey;
  final MaskedTextController dateController;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ServiceNavbar(dateKey: dateKey, dateController: dateController),
        KaziSpacings.verticalMd,
        const ServiceViewSwitch(),
        const KaziBandDivider(),
        ServiceFilterChips(dateKey: dateKey, dateController: dateController),
        KaziSpacings.verticalMd,
        child,
      ],
    );
  }
}
