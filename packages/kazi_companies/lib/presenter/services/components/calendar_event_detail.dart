import 'package:flutter/material.dart';
import 'package:kazi_companies/core/routes/routes.dart';
import 'package:kazi_core/kazi_core.dart';

class CalendarEventDetail extends StatelessWidget {
  const CalendarEventDetail({super.key, required this.service});
  final Service service;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.colors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KaziInsets.xs),
        side: BorderSide(color: context.colors.borderStrong),
      ),
      title: Text(
        service.serviceType?.name ?? '',
        style: KaziTextStyles.titleMedium,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${service.description}'),
          KaziSpacings.verticalMd,
          Row(
            children: [
              const Icon(Icons.person),
              KaziSpacings.horizontalXs,
              Text(service.customer?.name ?? ''),
            ],
          ),
          KaziSpacings.verticalMd,
          Row(
            children: [
              const Icon(Icons.calendar_today),
              KaziSpacings.horizontalXs,
              Text(
                KaziLocalizations.current.fromTo(
                  service.scheduledToStartAt.formatHour(),
                  service.scheduledToEndAt.formatHour(),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: context.closeDialog,
          style: TextButton.styleFrom(
            foregroundColor: context.colors.textMuted,
          ),
          child: Text(KaziLocalizations.current.close),
        ),
        TextButton(
          onPressed: () => context.navigate(Routes.services),
          child: Text(KaziLocalizations.current.details),
        ),
      ],
    );
  }
}
