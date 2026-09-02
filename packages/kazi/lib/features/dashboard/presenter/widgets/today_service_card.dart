import 'package:flutter/material.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/presenter/widgets/received_mark.dart';
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
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              KaziCategoryBar(color: service.catalogItem?.colorAs),
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
                            Text.rich(
                              TextSpan(
                                text: KaziLocalizations.current
                                    .commissionPercent(
                                      NumberFormatUtils.formatPercent(
                                        service.effectiveCommissionPercent,
                                      ),
                                    ),
                                children: [
                                  if (service.isReceived)
                                    receivedMarkSpan(context),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: KaziTextStyles.bodyMedium.copyWith(
                                fontSize: 15,
                                height: 24 / 15,
                              ),
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
      ),
    );
  }
}
