import 'package:flutter/material.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/services/data/banner_ad_policy.dart';
import 'package:kazi/core/widgets/ads/ad_block.dart';
import 'package:kazi/features/services/services.dart';
import 'package:kazi/features/services/presenter/widgets/service_card.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

class ServiceListContent extends ConsumerWidget {
  const ServiceListContent({
    super.key,
    required this.services,
    required this.canScroll,
  });
  final List<Service> services;
  final bool canScroll;

  void _onTap(BuildContext context, Service service) => KaziNavigator.push(
    AppPage.serviceDetails,
    extra: ServiceArguments(service: service),
  );

  Widget _buildItem(
    BuildContext context,
    int index, {
    required BannerAdPolicy bannerPolicy,
  }) {
    if (bannerPolicy.shouldShowAt(index)) {
      return AdBlock(
        child: ServiceCard(
          service: services[index],
          onTap: () => _onTap(context, services[index]),
        ),
      );
    }

    return ServiceCard(
      key: Key('service-${services[index].id}'),
      service: services[index],
      onTap: () => _onTap(context, services[index]),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannerPolicy = ref.watch(bannerAdPolicyProvider);

    if (!canScroll) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < services.length; index++) ...[
            if (index != 0) const Divider(),
            _buildItem(context, index, bannerPolicy: bannerPolicy),
          ],
        ],
      );
    }

    return ListView.separated(
      itemCount: services.length,
      itemBuilder: (context, index) =>
          _buildItem(context, index, bannerPolicy: bannerPolicy),
      separatorBuilder: (context, index) => const Divider(),
    );
  }
}
