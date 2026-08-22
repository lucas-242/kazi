import 'package:flutter/material.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/presenter/widgets/received_badge.dart';
import 'package:kazi_core/kazi_core.dart' hide Service;

/// One line of the services list: the commission as the headline, the gross as
/// the footnote, the category in the dot. See `features/services/README.md`.
///
/// ```
/// ● Alongamento em gel            R$ 81
///   Marina R. · 09 ago         de R$ 180
/// ```
class ServiceCard extends ConsumerWidget {
  const ServiceCard({super.key, required this.onTap, required this.service});
  final VoidCallback onTap;
  final Service service;

  /// "Marina R. · 09 ago", or just the date when the service has no client.
  String _subtitle() {
    final date = DateFormat.yMd().format(service.date).normalizeDate();
    final client = service.clientName ?? '';
    return client.isEmpty ? date : '$client · $date';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final defaultCurrency = ref.watch(kaziDefaultCurrencyProvider);
    final serviceCurrency = service.currencyOr(defaultCurrency);

    return Material(
      color: colors.card,
      borderRadius: KaziRadii.smBorder,
      child: InkWell(
        onTap: onTap,
        borderRadius: KaziRadii.smBorder,
        child: Container(
          constraints: const BoxConstraints(
            minHeight: KaziSizings.minTouchTarget,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: KaziInsets.md,
            vertical: KaziInsets.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: KaziRadii.smBorder,
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              KaziColorDot(color: service.type?.colorAs, size: 10),
              KaziSpacings.horizontalSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      service.type?.name ?? '',
                      style: KaziTextStyles.titleSmall,
                    ),
                    KaziSpacings.verticalXxs,
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _subtitle(),
                            style: KaziTextStyles.labelSmall.copyWith(
                              color: colors.textMuted,
                            ),
                            overflow: TextOverflow.ellipsis,
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
              KaziSpacings.horizontalSm,
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    NumberFormatUtils.formatCurrencyIn(
                      service.commissionValue,
                      serviceCurrency,
                    ),
                    style: KaziTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  KaziSpacings.verticalXxs,
                  Text(
                    KaziLocalizations.current.ofGross(
                      NumberFormatUtils.formatCurrencyIn(
                        service.value,
                        serviceCurrency,
                      ),
                    ),
                    style: KaziTextStyles.labelSmall.copyWith(
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
