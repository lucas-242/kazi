// Aggregates the per-package `coverage/lcov.info` files that
// `melos run test:coverage` produces into a single report at the repo root.
//
// Two things it does beyond concatenating:
//
// * **Rewrites `SF:` paths.** `flutter test --coverage` writes them relative to
//   the package (`lib/foo.dart`), so three packages all claim `lib/main.dart`
//   and any viewer collapses them into one.
// * **Drops generated code.** `.g.dart`, `.mocks.dart` and `l10n/generated`
//   are written by build_runner and intl_utils, not by a person. Left in, they
//   dominate the number and it stops meaning anything.
//
// Usage: `dart run scripts/merge_coverage.dart` (or `melos run coverage:merge`).
import 'dart:io';

/// Files nobody writes by hand, so nobody can cover them on purpose.
const _generatedPatterns = [
  '.g.dart',
  '.mocks.dart',
  '.freezed.dart',
  '/generated/',
  '/l10n/',
];

void main(List<String> args) {
  final root = Directory.current;
  final packages = Directory('${root.path}/packages');

  if (!packages.existsSync()) {
    stderr.writeln('No packages/ directory found. Run this from the repo root.');
    exitCode = 1;
    return;
  }

  final merged = StringBuffer();
  var totalFiles = 0;
  var skippedFiles = 0;
  final contributing = <String>[];

  for (final entity in packages.listSync().whereType<Directory>()) {
    final packageName = entity.path.split(Platform.pathSeparator).last;
    final lcov = File('${entity.path}/coverage/lcov.info');
    if (!lcov.existsSync()) continue;

    contributing.add(packageName);
    var keepingRecord = true;

    for (final line in lcov.readAsLinesSync()) {
      if (line.startsWith('SF:')) {
        final path = line.substring(3);
        final relative = path.startsWith('/')
            ? path
            : 'packages/$packageName/$path';

        keepingRecord = !_generatedPatterns.any(relative.contains);
        if (!keepingRecord) {
          skippedFiles++;
          continue;
        }

        totalFiles++;
        merged.writeln('SF:$relative');
        continue;
      }

      if (keepingRecord) merged.writeln(line);
    }
  }

  if (contributing.isEmpty) {
    stderr.writeln(
      'No lcov.info found in any package. Run `melos run test:coverage` first.',
    );
    exitCode = 1;
    return;
  }

  final output = File('${root.path}/coverage/lcov.info')
    ..createSync(recursive: true)
    ..writeAsStringSync(merged.toString());

  stdout
    ..writeln('Merged coverage from: ${contributing.join(', ')}')
    ..writeln('  $totalFiles files, $skippedFiles generated files excluded')
    ..writeln('  -> ${output.path}');
}
