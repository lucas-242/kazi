import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/domain/models/catalog_item.dart';
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

class IsTheSameCatalogItem extends Matcher {
  IsTheSameCatalogItem(this.compareObject, {this.checkEqualsId = false});
  final CatalogItem compareObject;
  final bool checkEqualsId;

  @override
  bool matches(Object? item, Map matchState) {
    final catalogItem = item as CatalogItem;

    final isEquals =
        (checkEqualsId
            ? catalogItem.id == compareObject.id
            : catalogItem.id.isNotEmpty) &&
        catalogItem.name == compareObject.name &&
        catalogItem.effectiveCommissionPercent ==
            compareObject.effectiveCommissionPercent &&
        catalogItem.defaultValue == compareObject.defaultValue &&
        // Compared explicitly: a round-trip that dropped the colour would
        // otherwise pass.
        catalogItem.color == compareObject.color &&
        catalogItem.userId == compareObject.userId;

    return isEquals;
  }

  @override
  Description describe(Description description) {
    return description.add('CatalogItem is equals to another one');
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
    // [IsTheSameCatalogItem] calls out for the colour.
    //
    // `type` is deliberately still excluded: `toMap` writes `catalogItemName` while
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
        service.catalogItemId == compareObject.catalogItemId &&
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
