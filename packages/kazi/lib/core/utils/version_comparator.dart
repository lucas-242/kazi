abstract class VersionComparator {
  /// Compares two semantic version strings (`major.minor.patch`), ignoring any
  /// build metadata (`+15`) or pre-release (`-beta`) suffix —
  ///
  /// e.g. `1.2.0+15` is
  /// treated as `1.2.0`.
  ///
  /// Returns a negative number when [a] < [b], zero when they are equal, and a
  /// positive number when [a] > [b]. Missing or non-numeric segments are treated
  /// as `0`, so malformed input never throws.
  static int compareVersions(String a, String b) {
    final aParts = _parse(a);
    final bParts = _parse(b);
    final length = aParts.length > bParts.length
        ? aParts.length
        : bParts.length;

    for (var i = 0; i < length; i++) {
      final aValue = i < aParts.length ? aParts[i] : 0;
      final bValue = i < bParts.length ? bParts[i] : 0;
      if (aValue != bValue) {
        return aValue < bValue ? -1 : 1;
      }
    }
    return 0;
  }

  static List<int> _parse(String version) {
    final core = version.split('+').first.split('-').first.trim();
    return core
        .split('.')
        .map((segment) => int.tryParse(segment.trim()) ?? 0)
        .toList();
  }
}
