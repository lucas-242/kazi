import 'package:flutter/material.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi_core/kazi_core.dart' hide Service;

class ServiceCard extends ConsumerWidget {
  const ServiceCard({super.key, required this.onTap, required this.service});
  final VoidCallback onTap;
  final Service service;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defaultCurrency = ref.watch(kaziDefaultCurrencyProvider);
    final serviceCurrency = service.currencyOr(defaultCurrency);
    final showConversion = serviceCurrency != defaultCurrency;
    final convertedValue = service.convert(
      service.valueWithDiscount,
      to: defaultCurrency,
      fallback: defaultCurrency,
    );

    return InkWell(
      onTap: onTap,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text('${service.type?.name}', style: KaziTextStyles.titleSm),
        subtitle: Text(
          DateFormat.yMd().format(service.date).normalizeDate(),
          style: KaziTextStyles.labelSm,
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
                    service.valueWithDiscount,
                    serviceCurrency,
                  ),
                  style: KaziTextStyles.titleSm.copyWith(
                    color: KaziColors.green,
                  ),
                ),
                if (showConversion)
                  Text(
                    '≈ ${NumberFormatUtils.formatCurrencyIn(convertedValue, defaultCurrency)}',
                    style: KaziTextStyles.labelSm.copyWith(
                      color: KaziColors.grey,
                    ),
                  ),
              ],
            ),
            KaziSpacings.horizontalLg,
            const Icon(Icons.chevron_right, color: KaziColors.grey),
          ],
        ),
      ),
    );
  }
}
