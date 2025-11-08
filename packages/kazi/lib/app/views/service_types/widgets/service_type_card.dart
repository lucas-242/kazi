import 'package:flutter/material.dart';
import 'package:kazi/app/models/service_type.dart';
import 'package:kazi/app/shared/l10n/generated/l10n.dart';
import 'package:kazi/app/shared/themes/themes.dart';
import 'package:kazi/app/shared/utils/number_format_helper.dart';
import 'package:kazi/app/shared/widgets/buttons/buttons.dart';
import 'package:kazi_core/kazi_core.dart' hide ServiceType;

class ServiceTypeCard extends StatelessWidget {
  const ServiceTypeCard({
    super.key,
    required this.serviceType,
    required this.onTapEdit,
  });
  final Function(ServiceType) onTapEdit;
  final ServiceType serviceType;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(serviceType.name, style: context.titleSmall),
      subtitle: Text(
        '${NumberFormatHelper.formatPercent(serviceType.discountPercent)} ${AppLocalizations.current.discount.toLowerCase()}',
        style: context.labelSmall,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            NumberFormatHelper.formatCurrency(
              context,
              serviceType.defaultValue,
            ),
            style: context.titleSmall,
          ),
          KaziSpacings.horizontalLg,
          CircularButton(
            onTap: () => onTapEdit(serviceType),
            child: const Icon(Icons.edit, size: 20),
          ),
        ],
      ),
    );
  }
}
