import 'package:flutter/material.dart';
import 'package:kazi/app/models/service.dart';
import 'package:kazi/app/shared/themes/themes.dart';
import 'package:kazi/app/views/services/services.dart';
import 'package:kazi_core/kazi_core.dart' hide Service;

class ServiceList extends StatelessWidget {
  const ServiceList({
    super.key,
    required this.services,
    this.canScroll = false,
    this.title,
    this.expandList = false,
  });

  final List<Service> services;
  final bool canScroll;
  final String? title;
  final bool expandList;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.only(
          left: KaziInsets.lg,
          right: KaziInsets.lg,
          top: title == null ? KaziInsets.xs : KaziInsets.lg,
          bottom: KaziInsets.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null)
              Column(
                children: [
                  Text(title!.capitalize(), style: context.titleSmall),
                  KaziSpacings.verticalLg,
                ],
              ),
            expandList
                ? Expanded(
                    child: ServiceListContent(
                      services: services,
                      canScroll: canScroll,
                    ),
                  )
                : ServiceListContent(services: services, canScroll: canScroll),
          ],
        ),
      ),
    );
  }
}
