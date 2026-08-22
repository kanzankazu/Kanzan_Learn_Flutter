// Feature: phase-1-dart-language, Requirement 13: File Processor CLI
//
// File Processor — a CLI tool that reads text files and performs three modes of
// processing: statistics, line search, and text transformation.
//
// Demonstrates: Stream-based I/O, functional collection pipelines, extension methods,
// sealed Result type, enums with switch-expression exhaustiveness.
//
// Prerequisites: Dart SDK >= 3.3 (sealed class, patterns, records)

import 'dart:convert';
import 'dart:io';

// ---------------------------------------------------------------------------
// Result<T, E> — a typed outcome container
//
// NOTE: This is an intentional, educational duplication from generics_demo.dart.
// Duplicating the definition here reinforces the concept in a real-world context
// rather than importing it from a sibling file, which would introduce coupling
// between two standalone demo files. Learners encounter the pattern twice and
// understand it can live anywhere it is needed.
// ---------------------------------------------------------------------------

/// A sealed class representing the outcome of an operation that can either
/// succeed with a value of type [T] or fail with an error of type [E].
///
/// Use [Success] and [Failure] subclasses. Always handle both cases via
/// a `switch` expression to get exhaustiveness checking from the compiler.
///
/// Example:
/// ```dart
/// Result<String, String> result = readFile('path/to/file.txt');
/// switch (result) {
///   case Success(:final value): print('Content: $value');
///   case Failure(:final error): print('Error: $error');
/// }
/// ```
sealed class Result<T, E> {
  const Result();
}

/// The success case of [Result]. Carries the [value] produced by the operation.
final class Success<T, E> extends Result<T, E> {
  /// The successful output value.
  final T value;

  const Success(this.value);

  @override
  String toString() => 'Success($value)';
}

/// The failure case of [Result]. Carries the [error] that caused the failure.
final class Failure<T, E> extends Result<T, E> {
  /// The error that caused the failure.
  final E error;

  const Failure(this.error);

  @override
  String toString() => 'Failure($error)';
}

// ---------------------------------------------------------------------------
// FileStats — computed statistics for a text file
// ---------------------------------------------------------------------------

/// Statistics computed from a text file's content.
///
/// All fields are computed in a single streaming pass over the file lines.
/// [topWords] holds the top 5 most frequent lowercase words, sorted by
/// descending frequency with alphabetical ordering for ties.
class FileStats {
  /// Total number of lines in the file (including empty lines).
  final int lineCount;

  /// Total number of whitespace-separated tokens across all lines.
  final int wordCount;

  /// Number of unique non-whitespace characters that appear in the file.
  final int uniqueCharCount;

  /// Top 5 most frequent words (lowercase). Ties broken alphabetically.
  /// Each [MapEntry] has the word as key and occurrence count as value.
  final List<MapEntry<String, int>> topWords;

  const FileStats({
    required this.lineCount,
    required this.wordCount,
    required this.uniqueCharCount,
    required this.topWords,
  });

  @override
  String toString() {
    final topWordsStr = topWords.map((e) => '${e.key}(${e.value})').join(', ');
    return 'FileStats(lines: $lineCount, words: $wordCount, '
        'uniqueChars: $uniqueCharCount, topWords: [$topWordsStr])';
  }
}

// ---------------------------------------------------------------------------
// ProcessingMode — which operation the CLI should perform
// ---------------------------------------------------------------------------

/// The three processing modes the File Processor CLI supports.
///
/// Used as the first CLI argument:
///   `stats`     → compute and display file statistics
///   `search`    → find lines containing a keyword
///   `transform` → apply a text transformation to every line
enum ProcessingMode {
  /// Compute line count, word count, unique character count, and top words.
  stats,

  /// Find and print all lines containing a given keyword (case-insensitive).
  search,

  /// Transform every line: uppercase, lowercase, or reversed.
  transform;

  /// Parse a raw CLI string to a [ProcessingMode].
  ///
  /// Returns [null] if the string does not match any known mode.
  static ProcessingMode? tryParse(String raw) {
    return switch (raw.toLowerCase()) {
      'stats' => ProcessingMode.stats,
      'search' => ProcessingMode.search,
      'transform' => ProcessingMode.transform,
      _ => null,
    };
  }
}

// ---------------------------------------------------------------------------
// TransformMode — which text transformation to apply
// ---------------------------------------------------------------------------

/// The text transformation to apply when [ProcessingMode.transform] is active.
///
/// Used as the second CLI argument after `transform`:
///   `upper`   → convert every line to uppercase
///   `lower`   → convert every line to lowercase
///   `reverse` → reverse every line character by character
enum TransformMode {
  /// Convert each line to UPPERCASE.
  upper,

  /// Convert each line to lowercase.
  lower,

  /// Reverse each line character by character (e.g. "Dart" → "traD").
  reverse;

  /// Parse a raw CLI string to a [TransformMode].
  ///
  /// Returns [null] if the string does not match any known transform.
  static TransformMode? tryParse(String raw) {
    return switch (raw.toLowerCase()) {
      'upper' => TransformMode.upper,
      'lower' => TransformMode.lower,
      'reverse' => TransformMode.reverse,
      _ => null,
    };
  }

  /// Apply this transform to a single [line] of text.
  String apply(String line) => switch (this) {
        TransformMode.upper => line.toUpperCase(),
        TransformMode.lower => line.toLowerCase(),
        TransformMode.reverse => line.split('').reversed.join(),
      };
}

// ---------------------------------------------------------------------------
// TextUtils — extension on String for word/line counting
//
// These helpers are used inside the file processing pipeline instead of
// raw split() calls, keeping the pipeline expressive and readable.
// ---------------------------------------------------------------------------

/// Utility extensions on [String] used throughout the file processing pipeline.
///
/// Prefer these getters over raw `split()` calls for consistency — they
/// handle edge cases (empty strings, consecutive whitespace) uniformly.
extension TextUtils on String {
  /// Number of whitespace-separated, non-empty tokens in this string.
  ///
  /// Consecutive spaces, tabs, and newlines are treated as a single delimiter.
  /// Returns 0 for an empty string or a string with only whitespace.
  ///
  /// Example:
  /// ```dart
  /// 'hello world'.wordCount  // 2
  /// '  '.wordCount           // 0
  /// ```
  int get wordCount => split(RegExp(r'\s+')).where((t) => t.isNotEmpty).length;

  /// Number of segments when this string is split by newline characters (`\n`).
  ///
  /// A string with no `\n` returns 1 (a single line). An empty string returns 1.
  /// This matches line-counting semantics: every string has at least one line.
  ///
  /// Example:
  /// ```dart
  /// 'a\nb\nc'.lineCount  // 3
  /// 'hello'.lineCount    // 1
  /// ''.lineCount         // 1
  /// ```
  int get lineCount => split('\n').length;
}

// ---------------------------------------------------------------------------
// Shared helper: compute FileStats from a list of lines
//
// Exposed as a top-level function so unit tests can call it directly without
// reading a real file. The main() pipeline feeds Stream lines into this.
// ---------------------------------------------------------------------------

/// Compute [FileStats] from an already-collected list of [lines].
///
/// This function uses functional collection pipelines throughout — no imperative
/// `for` loops. [TextUtils] extension methods handle word/char counting.
///
/// The [topWords] result contains up to 5 entries, sorted by descending count
/// then ascending alphabetical order for ties.
FileStats computeStats(List<String> lines) {
  // Count total lines
  final lineCount = lines.length;

  // Count total words using the TextUtils extension on each line
  final wordCount = lines.fold<int>(0, (sum, line) => sum + line.wordCount);

  // Collect unique non-whitespace characters across all lines
  final uniqueChars = lines
      .expand((line) => line.split(''))
      .where((ch) => ch.trim().isNotEmpty) // exclude whitespace
      .toSet();
  final uniqueCharCount = uniqueChars.length;

  // Build word frequency map using a functional pipeline
  final wordFrequency = <String, int>{};
  for (final line in lines) {
    // Split each line into lowercase tokens and tally occurrences
    line
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .map((t) => t.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), ''))
        .where((t) => t.isNotEmpty)
        .forEach((word) => wordFrequency[word] = (wordFrequency[word] ?? 0) + 1);
  }

  // Sort by frequency descending, then alphabetically for ties; take top 5
  final topWords = wordFrequency.entries.toList()
    ..sort((a, b) {
      final byCount = b.value.compareTo(a.value); // descending count
      return byCount != 0 ? byCount : a.key.compareTo(b.key); // alpha tie-break
    });

  return FileStats(
    lineCount: lineCount,
    wordCount: wordCount,
    uniqueCharCount: uniqueCharCount,
    topWords: topWords.take(5).toList(),
  );
}

/// Parse a [ProcessingMode] from [args] at index 0.
///
/// Returns a [Failure] with a user-friendly message if parsing fails.
Result<ProcessingMode, String> parseMode(List<String> args) {
  if (args.isEmpty) {
    return const Failure('No mode provided. Usage: <stats|search|transform> [keyword] <file>');
  }
  final mode = ProcessingMode.tryParse(args[0]);
  if (mode == null) {
    return Failure('Unknown mode "${args[0]}". Expected: stats, search, or transform.');
  }
  return Success(mode);
}

/// Parse a [TransformMode] from [args] at index 1 (used when mode is `transform`).
///
/// Returns a [Failure] with a user-friendly message if parsing fails.
Result<TransformMode, String> parseTransformMode(List<String> args) {
  if (args.length < 2) {
    return Failure('transform mode requires a sub-command. Usage: transform <upper|lower|reverse> <file>');
  }
  final tm = TransformMode.tryParse(args[1]);
  if (tm == null) {
    return Failure('Unknown transform "${args[1]}". Expected: upper, lower, or reverse.');
  }
  return Success(tm);
}

/// Resolve the file path from [args] based on the [mode].
///
/// For `stats`: file is at args[1].
/// For `search`: keyword is args[1], file is at args[2].
/// For `transform`: sub-command is args[1], file is at args[2].
///
/// Returns a [Failure] if the argument is missing or the file does not exist.
Result<File, String> resolveFile(List<String> args, ProcessingMode mode) {
  final expectedIndex = switch (mode) {
    ProcessingMode.stats => 1,
    ProcessingMode.search => 2,
    ProcessingMode.transform => 2,
  };

  if (args.length <= expectedIndex) {
    return Failure('Missing file path argument at position ${expectedIndex + 1}.');
  }

  final path = args[expectedIndex];
  final file = File(path);
  if (!file.existsSync()) {
    return Failure('File not found: "$path"');
  }
  return Success(file);
}

// ---------------------------------------------------------------------------
// ParsedCommand — structured result of CLI argument parsing
// ---------------------------------------------------------------------------

/// Holds all parsed CLI inputs needed to dispatch a processing operation.
///
/// [mode]          — which operation to run (stats / search / transform)
/// [file]          — the resolved [File] to read
/// [keyword]       — search term (only set when mode is [ProcessingMode.search])
/// [transformMode] — which transformation to apply (only set for `transform`)
class ParsedCommand {
  final ProcessingMode mode;
  final File file;
  final String? keyword;
  final TransformMode? transformMode;

  const ParsedCommand({
    required this.mode,
    required this.file,
    this.keyword,
    this.transformMode,
  });
}

// ---------------------------------------------------------------------------
// parseCommand — converts raw CLI args into a typed ParsedCommand
// ---------------------------------------------------------------------------

/// Parse and validate the raw CLI argument list into a [ParsedCommand].
///
/// Expected argument layouts:
///   stats     <file>
///   search    <keyword> <file>
///   transform <upper|lower|reverse> <file>
///
/// Returns [Success<ParsedCommand, String>] when all arguments are valid.
/// Returns [Failure<ParsedCommand, String>] with a human-readable message on
/// any validation error (unknown mode, missing args, missing file, etc.).
///
/// No file system access is performed beyond existence checking.
Result<ParsedCommand, String> parseCommand(List<String> args) {
  // -- 1. Resolve processing mode ------------------------------------------
  final modeResult = parseMode(args);
  if (modeResult case Failure(:final error)) {
    return Failure(
      '$error\n\n'
      'Usage:\n'
      '  dart run file_processor.dart stats <file>\n'
      '  dart run file_processor.dart search <keyword> <file>\n'
      '  dart run file_processor.dart transform <upper|lower|reverse> <file>',
    );
  }
  final mode = (modeResult as Success<ProcessingMode, String>).value;

  // -- 2. Mode-specific argument extraction ---------------------------------
  String? keyword;
  TransformMode? transformMode;

  if (mode == ProcessingMode.search) {
    if (args.length < 2) {
      return const Failure(
        'search mode requires a keyword.\n'
        'Usage: dart run file_processor.dart search <keyword> <file>',
      );
    }
    keyword = args[1];
  }

  if (mode == ProcessingMode.transform) {
    final tmResult = parseTransformMode(args);
    if (tmResult case Failure(:final error)) {
      return Failure(error);
    }
    transformMode = (tmResult as Success<TransformMode, String>).value;
  }

  // -- 3. Resolve and check the file path -----------------------------------
  final fileResult = resolveFile(args, mode);
  if (fileResult case Failure(:final error)) {
    return Failure(error);
  }
  final file = (fileResult as Success<File, String>).value;

  return Success(ParsedCommand(
    mode: mode,
    file: file,
    keyword: keyword,
    transformMode: transformMode,
  ));
}

// ---------------------------------------------------------------------------
// _readFileAsStream — Stream<String> from a file, one line at a time
// ---------------------------------------------------------------------------

/// Open [file] and return a [Stream<String>] that emits one line per event.
///
/// Decoding pipeline:
///   File.openRead()
///     → utf8.decoder   (bytes → String, handles multi-byte chars)
///     → LineSplitter() (String → individual lines, strips newline chars)
///
/// The stream is lazy: no bytes are read until the caller subscribes (e.g.
/// via `await for` or `.toList()`).
Stream<String> _readFileAsStream(File file) {
  return file
      .openRead()
      .transform(utf8.decoder)
      .transform(const LineSplitter());
}

// ---------------------------------------------------------------------------
// _computeStats — stats mode implementation
// ---------------------------------------------------------------------------

/// Read [file] as a stream and compute [FileStats] from its contents.
///
/// The entire file is collected into a [List<String>] first so that
/// [computeStats] can perform multiple passes over the same data without
/// re-reading from disk. This is acceptable for CLI-scale files.
///
/// Returns [Success<FileStats, String>] on success, or
/// [Failure<FileStats, String>] if an [IOException] occurs while reading.
Future<Result<FileStats, String>> _computeStats(File file) async {
  try {
    final lines = await _readFileAsStream(file).toList();
    return Success(computeStats(lines));
  } on IOException catch (e) {
    // Wrap I/O errors — never let a raw exception propagate to main()
    return Failure('Failed to read "${file.path}": $e');
  }
}

// ---------------------------------------------------------------------------
// _searchLines — search mode implementation
// ---------------------------------------------------------------------------

/// Search [file] for lines containing [keyword] (case-insensitive).
///
/// Each matching line is returned as a [MapEntry] where:
///   key   — 1-based line number (int as String)
///   value — original line content
///
/// Returns [Success] with a list of matching entries (may be empty), or
/// [Failure] if an [IOException] occurs while reading the file.
Future<Result<List<MapEntry<String, String>>, String>> _searchLines(
  File file,
  String keyword,
) async {
  try {
    final keywordLower = keyword.toLowerCase();

    // Collect all lines with their 1-based index using a fold pipeline.
    // We start the accumulator with an index counter bundled in a record.
    final lines = await _readFileAsStream(file).toList();

    // Use .fold() to build matching entries in one pass (no for loops).
    // Accumulator: (currentLineNumber, accumulatedMatches)
    final (_, matches) = lines.fold<(int, List<MapEntry<String, String>>)>(
      (1, []),
      (acc, line) {
        final (lineNum, results) = acc;
        final updatedResults = line.toLowerCase().contains(keywordLower)
            ? [...results, MapEntry(lineNum.toString(), line)]
            : results;
        return (lineNum + 1, updatedResults);
      },
    );

    return Success(matches);
  } on IOException catch (e) {
    return Failure('Failed to read "${file.path}": $e');
  }
}

// ---------------------------------------------------------------------------
// _transformLines — transform mode implementation
// ---------------------------------------------------------------------------

/// Read [file] line by line and apply [transformMode] to every line.
///
/// The transformation options are:
///   upper   — every character → UPPERCASE
///   lower   — every character → lowercase
///   reverse — each line's characters reversed (e.g. "Dart" → "traD")
///
/// Returns [Success] with the list of transformed lines, or [Failure] on I/O
/// error. The caller is responsible for printing the result.
Future<Result<List<String>, String>> _transformLines(
  File file,
  TransformMode transformMode,
) async {
  try {
    // .map() maps each line through TransformMode.apply() — no for loops.
    final transformed = await _readFileAsStream(file)
        .map(transformMode.apply)
        .toList();
    return Success(transformed);
  } on IOException catch (e) {
    return Failure('Failed to read "${file.path}": $e');
  }
}

// ---------------------------------------------------------------------------
// _printStats — formatted output for stats mode
// ---------------------------------------------------------------------------

/// Print a human-readable statistics report for [stats].
void _printStats(FileStats stats, String filePath) {
  print('=== File Statistics: $filePath ===');
  print('Lines       : ${stats.lineCount}');
  print('Words       : ${stats.wordCount}');
  print('Unique chars: ${stats.uniqueCharCount} (whitespace excluded)');
  print('');
  print('Top ${stats.topWords.length} most frequent words:');
  stats.topWords.fold<int>(1, (rank, entry) {
    print('  $rank. "${entry.key}" — ${entry.value} occurrence${entry.value == 1 ? '' : 's'}');
    return rank + 1;
  });
}

// ---------------------------------------------------------------------------
// main() — entry point for the File Processor CLI
//
// Copy-paste example commands (using the bundled sample.txt):
//
//   dart run lib/phase1/mini_projects/file_processor/file_processor.dart \
//     stats lib/phase1/mini_projects/file_processor/sample.txt
//
//   dart run lib/phase1/mini_projects/file_processor/file_processor.dart \
//     search "Dart" lib/phase1/mini_projects/file_processor/sample.txt
//
//   dart run lib/phase1/mini_projects/file_processor/file_processor.dart \
//     transform upper lib/phase1/mini_projects/file_processor/sample.txt
//
//   dart run lib/phase1/mini_projects/file_processor/file_processor.dart \
//     transform reverse lib/phase1/mini_projects/file_processor/sample.txt
// ---------------------------------------------------------------------------

/// Entry point for the File Processor CLI.
///
/// Dispatches to the appropriate processing function based on the parsed mode
/// and prints results to stdout. All errors are printed to stderr with
/// [exit(1)] — no stack traces are ever shown to the user.
Future<void> main(List<String> args) async {
  // -- 1. Parse and validate all arguments ---------------------------------
  final commandResult = parseCommand(args);
  if (commandResult case Failure(:final error)) {
    stderr.writeln('Error: $error');
    exit(1);
  }
  final command = (commandResult as Success<ParsedCommand, String>).value;

  // -- 2. Dispatch to mode-specific handler --------------------------------
  switch (command.mode) {
    // ---- stats ----
    case ProcessingMode.stats:
      final result = await _computeStats(command.file);
      switch (result) {
        case Success(:final value):
          _printStats(value, command.file.path);
        case Failure(:final error):
          stderr.writeln('Error: $error');
          exit(1);
      }

    // ---- search ----
    case ProcessingMode.search:
      final keyword = command.keyword!; // guaranteed by parseCommand
      final result = await _searchLines(command.file, keyword);
      switch (result) {
        case Success(:final value):
          if (value.isEmpty) {
            // Requirement 13.6: explicit "not found" message in Indonesian
            print("Tidak ada baris yang mengandung '$keyword'");
          } else {
            print("=== Search results for '$keyword' in ${command.file.path} ===");
            // Print each match as "line N: <content>"
            value.fold<void>(null, (_, entry) {
              print('Line ${entry.key}: ${entry.value}');
            });
            print('');
            print('${value.length} match${value.length == 1 ? '' : 'es'} found.');
          }
        case Failure(:final error):
          stderr.writeln('Error: $error');
          exit(1);
      }

    // ---- transform ----
    case ProcessingMode.transform:
      final transformMode = command.transformMode!; // guaranteed by parseCommand
      final result = await _transformLines(command.file, transformMode);
      switch (result) {
        case Success(:final value):
          print('=== Transform (${transformMode.name}) applied to ${command.file.path} ===');
          print('');
          // Print each transformed line using fold to stay loop-free
          value.fold<void>(null, (_, line) => print(line));
        case Failure(:final error):
          stderr.writeln('Error: $error');
          exit(1);
      }
  }
}
