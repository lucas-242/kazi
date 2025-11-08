import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kazi/app/models/service.dart';
import 'package:kazi/app/shared/utils/number_format_helper.dart';
import 'package:kazi_core/kazi_core.dart' hide Service;

class ServiceCard extends StatelessWidget {
  const ServiceCard({super.key, required this.onTap, required this.service});
  final VoidCallback onTap;
  final Service service;

  @override
  Widget build(BuildContext context) {
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
            Text(
              NumberFormatHelper.formatCurrency(
                context,
                service.valueWithDiscount,
              ),
              style: KaziTextStyles.titleSm.copyWith(color: KaziColors.green),
            ),
            KaziSpacings.horizontalLg,
            const Icon(Icons.chevron_right, color: KaziColors.grey),
          ],
        ),
      ),
    );
  }
}
