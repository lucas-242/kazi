import 'package:flutter/material.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/presenter/widgets/received_badge.dart';
import 'package:kazi/features/services/services.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

/// One of today's services on the home: colour mark, what it was, the share the
/// user keeps, and the amount — always in the currency the service was
/// registered in, never converted.
class TodayServiceCard extends ConsumerWidget {
  const TodayServiceCard({super.key, required this.service});

  final Service service;

  /// The title falls back to the type's name: a service can be registered
  /// without a description, but never without a type.
  String get _title {
    final description = service.description;
    if (description != null && description.trim().isNotEmpty) {
      return description;
    }
    return service.type?.name ?? '';
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
              // No colour on the type: the card keeps its own neutral mark.
              color:
                  service.type?.colorAs ??
                  context.colorsScheme.surfaceContainerHighest,
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
                            style: KaziTextStyles.labelLg,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              Text(
                                KaziLocalizations.current.commissionPercent(
                                  NumberFormatUtils.formatPercent(
                                    service.effectiveCommissionPercent,
                                  ),
                                ),
                                style: KaziTextStyles.support,
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
                      style: KaziTextStyles.labelLg,
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
