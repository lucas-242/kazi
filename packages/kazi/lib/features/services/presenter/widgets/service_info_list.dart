import 'package:flutter/material.dart';
import 'package:kazi/core/widgets/info_card.dart';
import 'package:kazi/features/services/domain/models/service_totals.dart';
import 'package:kazi/features/services/presenter/widgets/mark_received_bar.dart';
import 'package:kazi/features/services/presenter/widgets/partial_totals_note.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

class ServiceInfoList extends StatelessWidget {
  const ServiceInfoList({super.key, required this.totals});

  final ServiceTotals totals;

  @override
  Widget build(BuildContext context) {
    final cardWidth = context.width * .57;
    final roles = context.kaziColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(right: KaziInsets.lg),
            children: [
              InfoCard(
                title: NumberFormatUtils.formatCurrencyIn(
                  totals.commission,
                  totals.currency,
                ),
                subtitle: KaziLocalizations.current.myBalance,
                icon: KaziSvgAssets.services,
                color: roles.success,
                onColor: roles.onSuccess,
                width: cardWidth,
              ),
              KaziSpacings.horizontalXs,
              InfoCard(
                title: NumberFormatUtils.formatCurrencyIn(
                  totals.withheld,
                  totals.currency,
                ),
                subtitle: KaziLocalizations.current.discounts,
                icon: KaziSvgAssets.fire,
                color: roles.warning,
                onColor: roles.onWarning,
                width: cardWidth,
              ),
              KaziSpacings.horizontalXs,
              InfoCard(
                title: NumberFormatUtils.formatCurrencyIn(
                  totals.value,
                  totals.currency,
                ),
                subtitle: KaziLocalizations.current.grossValue,
                icon: KaziSvgAssets.rocket,
                color: roles.info,
                onColor: roles.onInfo,
                width: cardWidth,
              ),
            ],
          ),
        ),
        PartialTotalsNote(totals: totals),
        MarkReceivedBar(totals: totals),
      ],
    );
  }
}
