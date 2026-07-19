import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/utils/version_comparator.dart';

void main() {
  group('VersionComparator', () {
    test('returns 0 for equal versions', () {
      expect(VersionComparator.compareVersions('1.2.0', '1.2.0'), 0);
    });

    test('returns negative when the first is older', () {
      expect(VersionComparator.compareVersions('1.2.0', '1.4.0'), lessThan(0));
      expect(VersionComparator.compareVersions('1.2.0', '2.0.0'), lessThan(0));
      expect(VersionComparator.compareVersions('1.2.0', '1.2.1'), lessThan(0));
    });

    test('returns positive when the first is newer', () {
      expect(
        VersionComparator.compareVersions('1.4.0', '1.2.0'),
        greaterThan(0),
      );
      expect(
        VersionComparator.compareVersions('2.0.0', '1.9.9'),
        greaterThan(0),
      );
    });

    test('ignores the build metadata suffix', () {
      expect(VersionComparator.compareVersions('1.2.0+15', '1.2.0'), 0);
      expect(VersionComparator.compareVersions('1.2.0+15', '1.2.0+20'), 0);
    });

    test('ignores the pre-release suffix', () {
      expect(VersionComparator.compareVersions('1.2.0-beta', '1.2.0'), 0);
    });

    test('treats missing segments as zero', () {
      expect(VersionComparator.compareVersions('1.2', '1.2.0'), 0);
      expect(VersionComparator.compareVersions('1', '1.0.1'), lessThan(0));
    });

    test('does not throw on malformed input', () {
      expect(VersionComparator.compareVersions('', '1.0.0'), lessThan(0));
      expect(VersionComparator.compareVersions('abc', '0.0.0'), 0);
    });
  });
}
