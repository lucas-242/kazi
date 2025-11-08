import 'package:flutter/material.dart';
import 'package:kazi/app/shared/constants/app_assets.dart';
import 'package:kazi/app/views/services/widgets/info_card.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
import 'package:kazi_core/kazi_core.dart';

class InfoList extends StatelessWidget {
  const InfoList({
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
    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: KaziInsets.lg, right: KaziInsets.lg),
      children: [
        InfoCard(
          title: NumberFormatUtils.formatCurrency(context, totalWithDiscount),
          subtitle: KaziLocalizations.current.myBalance,
          icon: AppAssets.services,
          color: KaziColors.green,
          width: cardWidth,
        ),
        KaziSpacings.horizontalXs,
        InfoCard(
          title: NumberFormatUtils.formatCurrency(context, totalDiscounted),
          subtitle: KaziLocalizations.current.discounts,
          icon: AppAssets.fire,
          color: KaziColors.orange,
          width: cardWidth,
        ),
        KaziSpacings.horizontalXs,
        InfoCard(
          title: NumberFormatUtils.formatCurrency(context, totalValue),
          subtitle: KaziLocalizations.current.totalReceived,
          icon: AppAssets.rocket,
          color: KaziColors.blue,
          width: cardWidth,
        ),
      ],
    );
  }
}
