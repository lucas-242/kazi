import 'package:flutter/material.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_controller.dart';
import 'package:kazi/features/services/presenter/widgets/service_landing_content.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

class ServiceLandingPage extends ConsumerStatefulWidget {
  const ServiceLandingPage({super.key});

  @override
  ConsumerState<ServiceLandingPage> createState() => _ServiceLandingPageState();
}

class _ServiceLandingPageState extends ConsumerState<ServiceLandingPage> {
  @override
  void initState() {
    super.initState();
    final controller = ref.read(serviceLandingControllerProvider.notifier);
    Future.microtask(controller.onInit);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(serviceLandingControllerProvider);
    final controller = ref.read(serviceLandingControllerProvider.notifier);

    return Scaffold(
      body: KaziSafeArea(
        onRefresh: controller.onRefresh,
        slivers: [ServiceLandingContent(state: state)],
      ),
    );
  }
}
