import 'package:flutter/material.dart';
import 'package:kazi/app/models/service.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/widgets/ads/ad_block.dart';
import 'package:kazi/app/views/services/services.dart';
import 'package:kazi/app/views/services/widgets/service_card.dart';
import 'package:kazi_core/shared/navigation/kazi_navigator.dart';

class ServiceListContent extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: canScroll
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      itemBuilder: (context, index) {
        if (index != 0 && index % 2 == 0) {
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
      },
      separatorBuilder: (context, index) => const Divider(),
    );
  }
}
