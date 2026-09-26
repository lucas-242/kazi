import 'package:flutter/material.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/services/data/ads/banner_ad_policy.dart';
import 'package:kazi/core/widgets/ads/ad_block.dart';
import 'package:kazi/features/services/services.dart';
import 'package:kazi/features/services/presenter/widgets/service_card.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

class ServiceListContent extends ConsumerWidget {
  const ServiceListContent({
    super.key,
    required this.services,
    this.firstPosition = 0,
    this.total,
  }) : isSliver = false;

  /// The same rows as a lazy [SliverList], for a list that is the whole list
  /// on screen and the page's scroll body.
  const ServiceListContent.sliver({super.key, required this.services})
    : isSliver = true,
      firstPosition = 0,
      total = null;

  final List<Service> services;
  final bool isSliver;

  /// Where [services] start in the whole list on screen, when they are one
  /// day's slice of it. Banners are placed by that position.
  final int firstPosition;

  /// Length of the whole list on screen; null when [services] is all of it.
  final int? total;

  void _onTap(BuildContext context, Service service) => KaziNavigator.push(
    AppPage.serviceDetails,
    extra: ServiceArguments(service: service),
  );

  Widget _buildItem(
    BuildContext context,
    int index, {
    required BannerAdPolicy bannerPolicy,
  }) {
    final service = services[index];
    final row = ServiceCard(
      key: ValueKey('service-${service.id}'),
      service: service,
      onTap: () => _onTap(context, service),
    );

    final isFollowedByBanner = bannerPolicy.shouldShowAfter(
      firstPosition + index,
      total: total ?? services.length,
    );
    if (!isFollowedByBanner) return row;

    return AdBlock(
      key: ValueKey('ad-${service.id}'),
      padding: const EdgeInsets.only(top: KaziInsets.xs),
      child: row,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannerPolicy = ref.watch(bannerAdPolicyProvider);

    // A gap, not a rule: a divider between two bordered cards reads as a third.
    if (isSliver) {
      return SliverList.separated(
        itemCount: services.length,
        itemBuilder: (context, index) =>
            _buildItem(context, index, bannerPolicy: bannerPolicy),
        separatorBuilder: (context, index) => KaziSpacings.verticalXs,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < services.length; index++) ...[
          if (index != 0) KaziSpacings.verticalXs,
          _buildItem(context, index, bannerPolicy: bannerPolicy),
        ],
      ],
    );
  }
}
