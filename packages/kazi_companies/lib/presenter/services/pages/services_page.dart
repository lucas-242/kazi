import 'package:flutter/material.dart';
import 'package:kazi_companies/core/routes/routes.dart';
import 'package:kazi_companies/presenter/services/components/calendar_event_detail.dart';
import 'package:kazi_core/kazi_core.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  @override
  Widget build(BuildContext context) {
    return KaziSafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                KaziLocalizations.current.services,
                style: KaziTextStyles.headlineMedium,
              ),
              KaziCircularButton(
                child: const Icon(Icons.add),
                onTap: () => context.openDialog(
                  child: const SizedBox(
                    height: 500,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: KaziCalendar(
              services: _getServices(),
              onTap: _onTapCalendar,
            ),
          ),
        ],
      ),
    );
  }

  void _onTapCalendar(KaziCalendarTapDetails details) {
    if (details.targetElement != KaziCalendarElement.appointment) return;

    final appointment = details.appointments?.first;
    if (appointment is Service) {
      context.openDialog(
        barrierColor: Colors.transparent,
        child: CalendarEventDetail(service: appointment),
      );
    }
  }

  List<Service> _getServices() => [
        Service.toCreate(
          description: 'Unha de Gel',
          value: 100,
          scheduledToStartAt: DateTime(2025, 4, 23, 13),
          scheduledToEndAt: DateTime(2025, 4, 23, 16, 30),
          catalogItem: const CatalogItem(
            id: 1,
            name: 'Unha de Gel',
            userId: 1,
            defaultValue: 100,
            discountPercent: 10,
            defaultDuration: Duration(hours: 1, minutes: 30),
            color: 'FF6AC3B1',
          ),
          employeeId: 1,
          customer: _getUser('Ana'),
        ),
        Service.toCreate(
          description: 'Lash Lift',
          value: 100,
          scheduledToStartAt: DateTime(2025, 4, 23, 09, 30),
          scheduledToEndAt: DateTime(2025, 4, 23, 11, 30),
          catalogItem: const CatalogItem(
            id: 1,
            name: 'Lash Lift',
            userId: 1,
            defaultValue: 100,
            discountPercent: 10,
            defaultDuration: Duration(hours: 2),
            color: 'FF5786FF',
          ),
          employeeId: 1,
          customer: _getUser('Márcia'),
        ),
        Service.toCreate(
          description: 'Design de Sobrancelhas',
          value: 100,
          scheduledToStartAt: DateTime(2025, 4, 22, 10, 30),
          scheduledToEndAt: DateTime(2025, 4, 22, 11),
          catalogItem: const CatalogItem(
            id: 1,
            name: 'Design de Sobrancelhas',
            userId: 1,
            defaultValue: 100,
            discountPercent: 10,
            defaultDuration: Duration(minutes: 30),
            color: 'FFFE8B58',
          ),
          employeeId: 1,
          customer: _getUser('Jupira'),
        ),
      ];

  User _getUser(String name) => User(
        id: 1,
        name: name,
        email: '',
        userType: UserType.client,
        identifier: '',
        birthDate: DateTime.now(),
        authToken: '',
        refreshToken: '',
        authExpires: DateTime.now(),
      );
}
