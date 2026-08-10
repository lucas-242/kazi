import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/domain/models/service_type.dart';
import 'package:kazi_core/shared/models/errors.dart';

class ErrorWithMessage<T extends AppError> extends CustomMatcher {
  ErrorWithMessage(this.message)
    : super(
        'Error should be ${T.runtimeType} with message: $message',
        'Error and message',
        throwsA(predicate((e) => e is T && e.message == message)),
      );
  final String message;
}

class IsTheSameServiceType extends Matcher {
  IsTheSameServiceType(this.compareObject, {this.checkEqualsId = false});
  final ServiceType compareObject;
  final bool checkEqualsId;

  @override
  bool matches(Object? item, Map matchState) {
    final serviceType = item as ServiceType;

    final isEquals =
        (checkEqualsId
            ? serviceType.id == compareObject.id
            : serviceType.id.isNotEmpty) &&
        serviceType.name == compareObject.name &&
        serviceType.effectiveCommissionPercent ==
            compareObject.effectiveCommissionPercent &&
        serviceType.defaultValue == compareObject.defaultValue &&
        // Compared explicitly: a round-trip that dropped the colour would
        // otherwise pass.
        serviceType.color == compareObject.color &&
        serviceType.userId == compareObject.userId;

    return isEquals;
  }

  @override
  Description describe(Description description) {
    return description.add('ServiceType is equals to another one');
  }
}

class IsTheSameService extends Matcher {
  IsTheSameService(this.compareObject, {this.checkEqualsId = false});
  final Service compareObject;
  final bool checkEqualsId;

  @override
  bool matches(Object? item, Map matchState) {
    final service = item as Service;

    // Every persisted field is compared. The fields below the line were added
    // after this matcher was written and were silently excluded, which meant a
    // repository round-trip that dropped them still matched — the same hazard
    // [IsTheSameServiceType] calls out for the colour.
    //
    // `type` is deliberately still excluded: `toMap` writes `typeName` while
    // `fromMap` reads `type`, so it never round-trips. That asymmetry predates
    // this and is not what these tests are guarding.
    final isEquals =
        (checkEqualsId
            ? service.id == compareObject.id
            : service.id.isNotEmpty) &&
        service.description == compareObject.description &&
        service.effectiveCommissionPercent ==
            compareObject.effectiveCommissionPercent &&
        service.value == compareObject.value &&
        service.date == compareObject.date &&
        service.typeId == compareObject.typeId &&
        service.userId == compareObject.userId &&
        service.clientId == compareObject.clientId &&
        service.clientName == compareObject.clientName &&
        service.currency == compareObject.currency &&
        service.rateDate == compareObject.rateDate &&
        service.receivedAt == compareObject.receivedAt;

    return isEquals;
  }

  @override
  Description describe(Description description) {
    return description.add('Service is equals to another one');
  }
}
