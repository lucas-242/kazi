import 'package:flutter/material.dart';
import 'package:kazi_companies/core/components/badge_label.dart';
import 'package:kazi_core/kazi_core.dart';

class ServicesHistory extends StatelessWidget {
  const ServicesHistory({super.key, required this.clientInfo});
  final ClientInfo clientInfo;

  @override
  Widget build(BuildContext context) {
    const historyLength = 5;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(KaziInsets.xLg),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Histórico de Serviços',
                  style: KaziTextStyles.headlineSmall,
                ),
                if (clientInfo.isLastServiceLate)
                  BadgeLabel(
                    text: 'Último serviço há mais de 20 dias',
                    icon: Icons.warning,
                    color: context.colors.danger.onSurface,
                  ),
              ],
            ),
            KaziSpacings.verticalMd,
            ...clientInfo.serviceHistory.take(historyLength).map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(
                      bottom: KaziInsets.sm,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          spacing: KaziInsets.xs,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              color: context.colors.brand.text,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.serviceName,
                                  style: KaziTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Por ${item.professionalName}',
                                  style: KaziTextStyles.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          item.formattedDate,
                          style: KaziTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
            Align(
              child: KaziTextButton(
                onTap: () {},
                child: const Text('Ver histórico completo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
