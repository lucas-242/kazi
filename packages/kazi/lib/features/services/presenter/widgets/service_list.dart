import 'package:flutter/material.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/presenter/widgets/service_list_content.dart';
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
    return Padding(
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
                Text(title!.capitalize(), style: KaziTextStyles.titleSmall),
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
    );
  }
}
