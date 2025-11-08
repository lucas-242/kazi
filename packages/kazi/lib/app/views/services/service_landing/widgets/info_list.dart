import 'package:flutter/material.dart';
import 'package:kazi/app/shared/l10n/generated/l10n.dart';
import 'package:kazi/app/shared/themes/themes.dart';
import 'package:kazi/app/views/services/widgets/info_card.dart';
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
          subtitle: AppLocalizations.current.myBalance,
          icon: AppAssets.services,
          color: KaziColors.green,
          width: cardWidth,
        ),
        KaziSpacings.horizontalXs,
        InfoCard(
          title: NumberFormatUtils.formatCurrency(context, totalDiscounted),
          subtitle: AppLocalizations.current.discounts,
          icon: AppAssets.fire,
          color: KaziColors.orange,
          width: cardWidth,
        ),
        KaziSpacings.horizontalXs,
        InfoCard(
          title: NumberFormatUtils.formatCurrency(context, totalValue),
          subtitle: AppLocalizations.current.totalReceived,
          icon: AppAssets.rocket,
          color: KaziColors.blue,
          width: cardWidth,
        ),
      ],
    );
  }
}
