import 'package:flutter/material.dart';
import 'package:kazi/features/services/domain/models/service_type.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
import 'package:kazi_core/kazi_core.dart' hide ServiceType;

class ServiceTypeCard extends ConsumerWidget {
  const ServiceTypeCard({
    super.key,
    required this.serviceType,
    required this.onTapEdit,
  });
  final Function(ServiceType) onTapEdit;
  final ServiceType serviceType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = SupportedCurrency.fromCode(
      serviceType.currency,
      fallback: ref.watch(kaziDefaultCurrencyProvider),
    );
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        serviceType.name,
        style: Theme.of(context).textTheme.titleSmall,
      ),
      subtitle: Text(
        '${NumberFormatUtils.formatPercent(serviceType.discountPercent)} ${KaziLocalizations.current.discount.toLowerCase()}',
        style: Theme.of(context).textTheme.labelSmall,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            NumberFormatUtils.formatCurrencyIn(
              serviceType.defaultValue,
              currency,
            ),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          KaziSpacings.horizontalLg,
          KaziCircularButton(
            onTap: () => onTapEdit(serviceType),
            child: const Icon(Icons.edit, size: 20),
          ),
        ],
      ),
    );
  }
}
