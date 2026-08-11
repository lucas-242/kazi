import 'package:flutter/material.dart';
import 'package:kazi/core/widgets/expanded_section/expanded_section.dart';
import 'package:kazi/features/services/domain/models/service_group_by_date.dart';
import 'package:kazi/features/services/presenter/widgets/service_list.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
import 'package:kazi_core/kazi_core.dart';

class ServiceDateCard extends ConsumerWidget {
  const ServiceDateCard({
    super.key,
    required this.servicesByDate,
    required this.onTap,
  });
  final ServicesGroupByDate servicesByDate;
  final VoidCallback onTap;

  String getTextDate(DateTime date, DateTime today) {
    if (date == today) {
      return KaziLocalizations.current.today;
    } else if (date.calculateDifference(today) == -1) {
      return KaziLocalizations.current.yesterday;
    }
    return DateFormat.yMMMd().format(date).normalizeDate();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(timeServiceProvider).now;
    return Card(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: KaziInsets.lg,
              right: KaziInsets.lg,
              top: KaziInsets.lg,
              bottom: !servicesByDate.isExpanded ? KaziInsets.lg : 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  getTextDate(servicesByDate.date, today).capitalize(),
                  style: KaziTextStyles.titleMedium,
                ),
                KaziCircularButton(
                  onTap: onTap,
                  child: Icon(
                    servicesByDate.isExpanded
                        ? Icons.keyboard_arrow_up_outlined
                        : Icons.keyboard_arrow_down_outlined,
                  ),
                ),
              ],
            ),
          ),
          ExpandedSection(
            isExpanded: servicesByDate.isExpanded,
            child: ServiceList(services: servicesByDate.services),
          ),
        ],
      ),
    );
  }
}
