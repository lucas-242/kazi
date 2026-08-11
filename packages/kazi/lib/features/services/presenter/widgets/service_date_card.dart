import 'package:flutter/material.dart';
import 'package:kazi/core/widgets/expanded_section/expanded_section.dart';
import 'package:kazi/features/services/domain/models/service_group_by_date.dart';
import 'package:kazi/features/services/presenter/widgets/service_list.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
import 'package:kazi_core/kazi_core.dart';

/// One day's services, under a collapsible date heading.
///
/// A heading and its rows, not a card wrapping cards: every row is a bordered
/// card of its own now, and a container around them would draw a second frame
/// around the first.
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                // The brandbook's eyebrow, and the only place caps are allowed.
                getTextDate(servicesByDate.date, today).toUpperCase(),
                style: KaziTextStyles.tag.copyWith(
                  color: context.colors.textMuted,
                ),
              ),
            ),
            KaziCircularButton(
              onTap: onTap,
              child: Icon(
                servicesByDate.isExpanded
                    ? Icons.keyboard_arrow_up_outlined
                    : Icons.keyboard_arrow_down_outlined,
                size: 18,
              ),
            ),
          ],
        ),
        ExpandedSection(
          isExpanded: servicesByDate.isExpanded,
          child: ServiceList(services: servicesByDate.services),
        ),
      ],
    );
  }
}
