import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/services/domain/error_kind.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

void main() {
  test('a refusal by a rule is a business rule', () {
    expect(ErrorKind.of(ClientError('x')), ErrorKind.businessRule);
  });

  test('an exception is external', () {
    expect(ErrorKind.of(ExternalError('x')), ErrorKind.external);
    expect(ErrorKind.of(const FormatException()), ErrorKind.external);
  });

  test('an error is a bug', () {
    expect(ErrorKind.of(StateError('x')), ErrorKind.unexpected);
    expect(ErrorKind.of(ArgumentError()), ErrorKind.unexpected);
  });
}
