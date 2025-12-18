import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:kazi_core/shared/services/in_app_review/kazi_in_app_review_service_impl.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'kazi_in_app_review_service_impl_test.mocks.dart';

@GenerateMocks([InAppReview])
void main() {
  late KaziInAppReviewServiceImpl service;
  late MockInAppReview mockInAppReview;

  setUp(() {
    mockInAppReview = MockInAppReview();
    service = KaziInAppReviewServiceImpl(inAppReview: mockInAppReview);
  });

  test('requestReview should call requestReview when isAvailable is true',
      () async {
    when(mockInAppReview.isAvailable()).thenAnswer((_) async => true);
    when(mockInAppReview.requestReview()).thenAnswer((_) async {});

    await service.requestReview();

    verify(mockInAppReview.isAvailable()).called(1);
    verify(mockInAppReview.requestReview()).called(1);
  });

  test('requestReview should not call requestReview when isAvailable is false',
      () async {
    when(mockInAppReview.isAvailable()).thenAnswer((_) async => false);

    await service.requestReview();

    verify(mockInAppReview.isAvailable()).called(1);
    verifyNever(mockInAppReview.requestReview());
  });

  test('requestReview should handle exception when isAvailable throws',
      () async {
    when(mockInAppReview.isAvailable()).thenThrow(Exception('Test exception'));

    expect(
      () => service.requestReview(),
      returnsNormally,
      reason: 'Should not throw when isAvailable throws',
    );
  });
}
