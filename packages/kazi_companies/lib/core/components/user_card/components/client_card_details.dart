import 'package:flutter/material.dart';
import 'package:kazi_companies/core/components/badge_label.dart';
import 'package:kazi_companies/core/components/most_used_services.dart';
import 'package:kazi_core/kazi_core.dart';

class ClientCardDetails extends StatelessWidget {
  const ClientCardDetails({super.key, required this.clientInfo});
  final ClientInfo clientInfo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(KaziInsets.md),
          decoration: BoxDecoration(
            color: context.colorsScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(KaziInsets.xs),
          ),
          child: clientInfo.serviceHistory.isEmpty
              ? SizedBox(
                  width: context.width,
                  child: const Text(
                    'Ainda não realizou serviço',
                    style: KaziTextStyles.titleSm,
                  ),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Último Serviço',
                            style: KaziTextStyles.md,
                          ),
                          KaziSpacings.verticalXs,
                          Text(
                            clientInfo.lastServiceName,
                            style: KaziTextStyles.md
                                .copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            clientInfo.lastServiceDateFormatted,
                            style: KaziTextStyles.md,
                          ),
                        ],
                      ),
                    ),
                    KaziSpacings.horizontalSm,
                    BadgeLabel(
                      text: clientInfo.isLastServiceLate
                          ? '+${clientInfo.daysSinceLastService} dias'
                          : 'Recente',
                      icon: clientInfo.isLastServiceLate
                          ? Icons.schedule
                          : Icons.check,
                      color: clientInfo.isLastServiceLate
                          ? context.colorsScheme.onErrorContainer
                          : context.kaziColors.onSuccessContainer,
                    ),
                  ],
                ),
        ),
        KaziSpacings.verticalSm,
        if (clientInfo.serviceHistory.isNotEmpty) ...[
          const Text('Serviços Mais Realizados', style: KaziTextStyles.md),
          KaziSpacings.verticalSm,
          MostUsedServices(items: clientInfo.mostUsedServices),
        ],
      ],
    );
  }
}
