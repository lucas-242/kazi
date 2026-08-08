import 'package:flutter/material.dart';
import 'package:kazi_companies/core/components/badge_label.dart';
import 'package:kazi_core/kazi_core.dart';

class MostUsedServices extends StatelessWidget {
  const MostUsedServices({super.key, required this.items});

  final Map<String, int> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: items.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: KaziInsets.xxs),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  items.keys.elementAt(index),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              KaziSpacings.horizontalXs,
              BadgeLabel(
                text: '${items.values.elementAt(index)}x',
                color: context.kaziColors.accentInk,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
