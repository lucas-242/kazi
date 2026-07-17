import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/core/widgets/custom_scaffold/custom_scaffold.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_controller.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_state.dart';
import 'package:kazi/features/services/presenter/widgets/service_landing_content.dart';
import 'package:kazi/features/services/presenter/widgets/service_navbar.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
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
    ref.listen<ServiceLandingState>(serviceLandingControllerProvider, (
      previous,
      current,
    ) {
      if (previous?.status != current.status &&
          current.status == BaseStateStatus.error) {
        KaziSnackbar.show(context, current.callbackMessage);
      }
    });

    final state = ref.watch(serviceLandingControllerProvider);

    return CustomSafeArea(
      padding: const EdgeInsets.only(top: KaziInsets.lg),
      onRefresh: () =>
          ref.read(serviceLandingControllerProvider.notifier).onRefresh(),
      child: state.when(
        onState: (_) => ServiceLandingContent(
          state: state,
          dateController: dateController,
          dateKey: dateKey,
        ),
        onLoading: () => const Padding(
          padding: EdgeInsets.symmetric(horizontal: KaziInsets.lg),
          child: KaziLoading(),
        ),
        onNoData: () => Padding(
          padding: const EdgeInsets.symmetric(horizontal: KaziInsets.lg),
          child: KaziNoData(
            message: KaziLocalizations.current.noServices,
            navbar: ServiceNavbar(
              dateKey: dateKey,
              dateController: dateController,
            ),
          ),
        ),
      ),
    );
  }
}
