import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/widgets/ads/ad_block.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/domain/models/service_totals.dart';
import 'package:kazi/features/services/domain/models/service_view.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_controller.dart';
import 'package:kazi/features/services/presenter/widgets/service_card.dart';
import 'package:kazi/features/services/services.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// What was done today, in a tray of its own so the rows read as a group
/// rather than as bare text below the earnings card. See README.md.
class TodaySection extends ConsumerWidget {
  const TodaySection({super.key, required this.services, required this.totals});

  final List<Service> services;

  /// The day's own totals, resolved once by the page from [services].
  final ServiceTotals totals;

  String get _heading {
    final heading = KaziLocalizations.current.todaySection(services.length);
    if (services.isEmpty || totals.isPartial) return heading;

    return '$heading · '
        '${NumberFormatUtils.formatCurrencyIn(totals.commission, totals.currency)}';
  }

  Widget _row(Service service, {required bool isFollowedByBanner}) {
    final card = ServiceCard(
      service: service,
      onTap: () => KaziNavigator.push(
        AppPage.serviceDetails,
        extra: ServiceArguments(service: service),
      ),
    );
    if (!isFollowedByBanner) return card;

    return AdBlock(
      key: ValueKey('ad-${service.id}'),
      padding: const EdgeInsets.only(bottom: KaziInsets.sm),
      borderRadius: KaziRadii.mdBorder,
      child: card,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannerPolicy = ref.watch(bannerAdPolicyProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KaziInsets.sm),
      decoration: BoxDecoration(
        color: context.colors.surfaceMuted,
        borderRadius: KaziRadii.lgBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: KaziInsets.xs),
            child: _TodayHeading(heading: _heading),
          ),
          if (services.isEmpty)
            KaziNoResults(
              message: KaziLocalizations.current.noServicesToday,
              messageStyle: KaziTextStyles.titleSmall,
              icon: LucideIcons.coffee,
            )
          else
            for (final (position, service) in services.indexed) ...[
              if (position > 0) KaziSpacings.verticalXs,
              _row(
                service,
                isFollowedByBanner: bannerPolicy.shouldShowAfter(
                  position,
                  total: services.length,
                ),
              ),
            ],
        ],
      ),
    );
  }
}

class _TodayHeading extends ConsumerWidget {
  const _TodayHeading({required this.heading});

  final String heading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(child: Text(heading.toUpperCase(), style: KaziTextStyles.tag)),
        KaziTextButton(
          onTap: () {
            unawaited(
              ref
                  .read(serviceLandingControllerProvider.notifier)
                  .openServices(
                    view: ServiceView.list,
                    period: FastSearch.today,
                  ),
            );
            KaziNavigator.navigate(AppPage.services);
          },
          child: Text(KaziLocalizations.current.seeInList),
        ),
      ],
    );
  }
}
