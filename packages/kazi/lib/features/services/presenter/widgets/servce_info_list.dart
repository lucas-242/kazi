import 'package:flutter/material.dart';
import 'package:kazi/core/widgets/info_card.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
import 'package:kazi_core/kazi_core.dart';

class ServiceInfoList extends StatelessWidget {
  const ServiceInfoList({
    super.key,
    required this.totalValue,
    required this.totalDiscounted,
    required this.totalWithDiscount,
  });
  final double totalValue;
  final double totalDiscounted;
  final double totalWithDiscount;

  @override
  Widget build(BuildContext context) {
    final cardWidth = context.width * .57;
    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(right: KaziInsets.lg),
        children: [
          InfoCard(
            title: NumberFormatUtils.formatCurrency(context, totalWithDiscount),
            subtitle: KaziLocalizations.current.myBalance,
            icon: KaziSvgAssets.services,
            color: KaziColors.green,
            width: cardWidth,
          ),
          KaziSpacings.horizontalXs,
          InfoCard(
            title: NumberFormatUtils.formatCurrency(context, totalDiscounted),
            subtitle: KaziLocalizations.current.discounts,
            icon: KaziSvgAssets.fire,
            color: KaziColors.orange,
            width: cardWidth,
          ),
          KaziSpacings.horizontalXs,
          InfoCard(
            title: NumberFormatUtils.formatCurrency(context, totalValue),
            subtitle: KaziLocalizations.current.totalReceived,
            icon: KaziSvgAssets.rocket,
            color: KaziColors.blue,
            width: cardWidth,
          ),
        ],
      ),
    );
  }
}
