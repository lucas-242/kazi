import 'package:flutter/widgets.dart';
import 'package:kazi_core/kazi_core.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

typedef KaziCalendarTapDetails = CalendarTapDetails;

typedef KaziCalendarElement = CalendarElement;

class ServiceCalendarDataSource extends CalendarDataSource {
  ServiceCalendarDataSource(List<Service> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) => _getService(index).scheduledToStartAt;

  @override
  DateTime getEndTime(int index) => _getService(index).scheduledToEndAt;

  @override
  String getSubject(int index) => _getService(index).serviceType?.name ?? '';

  // A CalendarDataSource has no BuildContext, so it cannot read
  // `context.colors` and has to name a set. Reading it off the light set is
  // exact rather than a compromise: categories are identity rather than state,
  // so the six marks are the same hexes in both brightnesses.
  @override
  Color getColor(int index) =>
      _getService(index).serviceType?.colorAs ?? KaziColors.light.category(0);

  @override
  bool isAllDay(int index) => false;

  Service _getService(int index) {
    final dynamic service = appointments![index];
    late final Service serviceData;

    if (service is Service) {
      serviceData = service;
    }

    return serviceData;
  }
}
