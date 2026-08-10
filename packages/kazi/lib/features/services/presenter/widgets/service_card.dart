import 'package:flutter/material.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/presenter/widgets/received_badge.dart';
import 'package:kazi_core/kazi_core.dart' hide Service;

class ServiceCard extends ConsumerWidget {
  const ServiceCard({super.key, required this.onTap, required this.service});
  final VoidCallback onTap;
  final Service service;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defaultCurrency = ref.watch(kaziDefaultCurrencyProvider);
    final serviceCurrency = service.currencyOr(defaultCurrency);

    return InkWell(
      onTap: onTap,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text('${service.type?.name}', style: KaziTextStyles.titleSm),
        subtitle: Row(
          children: [
            Text(
              DateFormat.yMd().format(service.date).normalizeDate(),
              style: KaziTextStyles.labelSm,
            ),
            if (service.isReceived) ...[
              KaziSpacings.horizontalXs,
              const ReceivedBadge(),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  NumberFormatUtils.formatCurrencyIn(
                    service.value,
                    serviceCurrency,
                  ),
                  style: KaziTextStyles.titleSm,
                ),
                Text(
                  NumberFormatUtils.formatCurrencyIn(
                    service.commissionValue,
                    serviceCurrency,
                  ),
                  style: KaziTextStyles.titleSm.copyWith(
                    color: context.kaziColors.onSuccessContainer,
                  ),
                ),
              ],
            ),
            KaziSpacings.horizontalLg,
            Icon(
              Icons.chevron_right,
              color: context.colorsScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
