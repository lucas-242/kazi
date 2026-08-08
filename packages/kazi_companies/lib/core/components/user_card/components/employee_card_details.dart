import 'package:flutter/material.dart';
import 'package:kazi_companies/core/components/services_badge_list.dart';
import 'package:kazi_core/kazi_core.dart';

class EmployeeCardDetails extends StatelessWidget {
  const EmployeeCardDetails({super.key, required this.user});
  final User user;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: KaziInsets.sm,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'Próximo serviço: '),
              TextSpan(
                text: DateTime.now()
                    .add(const Duration(minutes: 30))
                    .formatWithHour(),
                style: KaziTextStyles.titleSm,
              ),
            ],
          ),
        ),
        const Text('Especialidades', style: KaziTextStyles.headlineSm),
        ServicesBadgeList(user: user),
      ],
    );
  }
}
