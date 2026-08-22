import 'package:flutter/material.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/presenter/widgets/received_badge.dart';
import 'package:kazi/features/services/services.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// One of today's services on the home: colour mark, what it was, the share the
/// user keeps, and the amount — always in the currency the service was
/// registered in, never converted.
class TodayServiceCard extends ConsumerWidget {
  const TodayServiceCard({super.key, required this.service});

  final Service service;

  /// The title falls back to the catalog item's name: a service can be
  /// registered without a description, but never without an item.
  String get _title {
    final description = service.description;
    if (description != null && description.trim().isNotEmpty) {
      return description;
    }
    return service.catalogItem?.name ?? '';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceCurrency = service.currencyOr(
      ref.watch(kaziDefaultCurrencyProvider),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => KaziNavigator.push(
          AppPage.serviceDetails,
          extra: ServiceArguments(service: service),
        ),
        child: Row(
          children: [
            Container(
              width: 5,
              height: 72,
              // No colour on the item: the card keeps its own neutral mark.
              color:
                  service.catalogItem?.colorAs ??
                  context.colors.surfaceStrong,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(KaziInsets.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: KaziInsets.xxs,
                        children: [
                          Text(
                            _title,
                            style: KaziTextStyles.labelLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              // Flexible, like the title above it: the
                              // commission label is a translated sentence, and
                              // on a phone-width card it runs past the badge.
                              Flexible(
                                child: Text(
                                  KaziLocalizations.current.commissionPercent(
                                    NumberFormatUtils.formatPercent(
                                      service.effectiveCommissionPercent,
                                    ),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: KaziTextStyles.bodyMedium.copyWith(
                                    fontSize: 15,
                                    height: 24 / 15,
                                  ),
                                ),
                              ),
                              if (service.isReceived) ...[
                                KaziSpacings.horizontalXs,
                                const ReceivedBadge(),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    KaziSpacings.horizontalMd,
                    Text(
                      NumberFormatUtils.formatCurrencyIn(
                        service.value,
                        serviceCurrency,
                      ),
                      style: KaziTextStyles.labelLarge,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
