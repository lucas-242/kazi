import 'package:flutter/material.dart';
import 'package:kazi_companies/core/components/badge_label.dart';
import 'package:kazi_companies/core/components/user_card/components/client_card_details.dart';
import 'package:kazi_companies/core/components/user_card/components/employee_card_details.dart';
import 'package:kazi_companies/core/components/user_card/components/more_options_pop_up.dart';
import 'package:kazi_companies/core/routes/routes.dart';
import 'package:kazi_core/kazi_core.dart';

class UserCard extends StatelessWidget {
  const UserCard({
    super.key,
    required this.user,
    this.clientInfo,
    required this.onEdit,
    required this.onDelete,
  });
  final User user;
  final ClientInfo? clientInfo;
  final void Function(User) onEdit;
  final void Function(User) onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        hoverColor: KaziColors.background,
        onTap: () => _onView(context),
        child: Padding(
          padding: const EdgeInsets.all(KaziInsets.xLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      spacing: KaziInsets.sm,
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundImage: user.photoUrl != null
                              ? NetworkImage(user.photoUrl!)
                              : null,
                          child: user.photoUrl == null
                              ? const Icon(Icons.person, size: 32)
                              : null,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: KaziTextStyles.titleMd
                                    .copyWith(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              if (user.role != null)
                                Text(
                                  user.role!,
                                  style: KaziTextStyles.titleSm,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              Text(
                                user.phones.isNotEmpty ? user.phones.first : '',
                                style: KaziTextStyles.md,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                user.email,
                                style: KaziTextStyles.md,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (user.isBirthdayInMonth) ...[
                                KaziSpacings.verticalSm,
                                const BadgeLabel(
                                  text: 'Aniversário',
                                  icon: Icons.cake,
                                  color: KaziColors.orange,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: KaziInsets.xxLg),
                ],
              ),
              KaziSpacings.verticalMd,
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (clientInfo != null)
                        ClientCardDetails(clientInfo: clientInfo!)
                      else
                        EmployeeCardDetails(user: user),
                    ],
                  ),
                ),
              ),
              KaziSpacings.verticalMd,
              Row(
                children: [
                  Expanded(
                    child: KaziElevatedButton.icon(
                      onTap: () {},
                      icon: const Icon(Icons.calendar_month_sharp),
                      label: 'Agendar',
                    ),
                  ),
                  KaziSpacings.horizontalMd,
                  MoreOptionsPopup(
                    onView: () => _onView(context),
                    onEdit: () => _onEdit(context),
                    onDelete: () => onDelete(user),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onView(BuildContext context) {
    if (clientInfo != null) {
      return context.navigate(
        '${Routes.clients}/${user.id}',
        params: clientInfo,
      );
    }

    context.navigate('${Routes.employees}/${user.id}', params: user);
  }

  void _onEdit(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Editar')),
    );
  }
}
