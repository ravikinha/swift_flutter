import 'dart:io';

/// Custom syntax preprocessor for Flutter/Dart.
/// Converts:
///   print(?variable);
///     → if (variable != null) print(variable);
///
///   if (?variable)
///     → if (variable != null)
///
/// Usage:
///   dart run tools/preprocessor.dart
/// Then run your app with:
///   flutter run -t lib/generated/main.dart
///
void main() async {
  final sourceDir = Directory('lib');
  final outputDir = Directory('lib/generated');

  if (!await outputDir.exists()) {
    await outputDir.create(recursive: true);
  }

  stderr.writeln('🔍 Scanning Dart files in ${sourceDir.path}...');

  final dartFiles = sourceDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  for (final file in dartFiles) {
    final relativePath = file.path.replaceFirst('lib/', '');
    final outputPath = '${outputDir.path}/$relativePath';

    final source = await file.readAsString();
    var transformed = source;

    // Transform: print(?variable);
    transformed = transformed.replaceAllMapped(
      RegExp(r'print\s*\(\?(\w+)\);'),
          (match) => 'if (${match[1]} != null) print(${match[1]});',
    );

    // Transform: if (?variable)
    transformed = transformed.replaceAllMapped(
      RegExp(r'if\s*\(\?(\w+)\)'),
          (match) => 'if (${match[1]} != null)',
    );

    // Ensure output subdirectory exists
    final outputFile = File(outputPath);
    await outputFile.parent.create(recursive: true);

    await outputFile.writeAsString(transformed);
    stderr.writeln('✅ Processed: $relativePath');
  }

  stderr.writeln('\n✨ Done! Generated files saved in lib/generated/\n');
  stderr.writeln('➡️  To run: flutter run -t lib/generated/main.dart');
}
