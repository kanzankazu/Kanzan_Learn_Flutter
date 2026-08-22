// Feature: phase-1-dart-language, Requirement 13: File Processor CLI
//
// Unit tests for the File Processor CLI.
//
// Coverage:
//   - TextUtils extensions:  wordCount, lineCount  (Requirements 13.3, 13.9)
//   - computeStats()         stats mode             (Requirement 13.3)
//   - TransformMode.apply()  transform mode         (Requirement 13.6)
//   - Result<T, E>           sealed container       (Requirement 13.7)
//
// Note: search-mode tests exercise the same predicate logic that the full
// _searchLines() pipeline uses (case-insensitive substring filter + line
// number tagging).  That helper will be exposed after task 15.3 completes;
// here we validate the filtering logic directly on List<String> so the
// contract is locked in before the I/O wrapper is added.
//
// Run:
//   dart test test/phase1/mini_projects/file_processor/file_processor_test.dart

import 'package:test/test.dart';

import '../../../../lib/phase1/mini_projects/file_processor/file_processor.dart';

void main() {
  // ─────────────────────────────────────────────────────────────────────────
  // TextUtils extension — wordCount
  // ─────────────────────────────────────────────────────────────────────────
  group('TextUtils.wordCount', () {
    test('empty string returns 0', () {
      expect(''.wordCount, 0);
    });

    test('whitespace-only string returns 0', () {
      expect('   '.wordCount, 0);
      expect('\t\n '.wordCount, 0);
    });

    test('single word returns 1', () {
      expect('Dart'.wordCount, 1);
    });

    test('two words separated by a single space returns 2', () {
      expect('hello world'.wordCount, 2);
    });

    test('multiple consecutive spaces count as one delimiter', () {
      expect('a   b   c'.wordCount, 3);
    });

    test('leading and trailing whitespace is ignored', () {
      expect('  hello world  '.wordCount, 2);
    });

    test('sentence with punctuation counts tokens by whitespace only', () {
      // punctuation is NOT a word boundary — 'hello,' is one token
      expect('hello, world! foo'.wordCount, 3);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // TextUtils extension — lineCount
  // ─────────────────────────────────────────────────────────────────────────
  group('TextUtils.lineCount', () {
    test('empty string returns 1 (one empty line)', () {
      // A string with no newline is considered 1 line — matches split('\n')
      expect(''.lineCount, 1);
    });

    test('string with no newline returns 1', () {
      expect('hello'.lineCount, 1);
    });

    test('single newline returns 2 segments', () {
      expect('a\nb'.lineCount, 2);
    });

    test('three lines separated by two newlines returns 3', () {
      expect('a\nb\nc'.lineCount, 3);
    });

    test('trailing newline adds an extra segment', () {
      expect('a\nb\n'.lineCount, 3);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // computeStats() — stats mode
  // ─────────────────────────────────────────────────────────────────────────
  group('computeStats()', () {
    // Minimal corpus used across multiple tests:
    //   Line 1: "Dart is fast"   → 3 words
    //   Line 2: "Dart is safe"   → 3 words
    //   Line 3: "Go is fast"     → 3 words
    // Total: 3 lines, 9 words
    // Word frequencies (after lowercasing + stripping punctuation):
    //   dart:2, is:3, fast:2, safe:1, go:1
    // Top 5 by freq desc, alpha tie-break:
    //   is(3), dart(2), fast(2), go(1), safe(1)
    final threeLines = ['Dart is fast', 'Dart is safe', 'Go is fast'];

    test('lineCount equals number of input lines', () {
      final stats = computeStats(threeLines);
      expect(stats.lineCount, 3);
    });

    test('wordCount is the sum of words across all lines', () {
      final stats = computeStats(threeLines);
      expect(stats.wordCount, 9);
    });

    test('uniqueCharCount counts distinct non-whitespace characters', () {
      // Characters present (case-sensitive, from raw text):
      // D,a,r,t,i,s,f,G,o  — but wait: 'D' and 'd' are both in the corpus?
      // Line 1: D,a,r,t, ,i,s, ,f,a,s,t
      // Line 2: D,a,r,t, ,i,s, ,s,a,f,e
      // Line 3: G,o, ,i,s, ,f,a,s,t
      // Non-whitespace unique chars: D,a,r,t,i,s,f,e,G,o → 10
      final stats = computeStats(threeLines);
      expect(stats.uniqueCharCount, 10);
    });

    test('topWords are ordered by descending frequency', () {
      final stats = computeStats(threeLines);
      expect(stats.topWords.first.key, 'is');
      expect(stats.topWords.first.value, 3);
    });

    test('topWords tie-break is alphabetical for equal frequency words', () {
      // 'dart' and 'fast' both appear 2 times — 'dart' comes first alphabetically
      final stats = computeStats(threeLines);
      final twoCount = stats.topWords.where((e) => e.value == 2).toList();
      expect(twoCount.length, 2);
      expect(twoCount[0].key, 'dart');
      expect(twoCount[1].key, 'fast');
    });

    test('topWords contains at most 5 entries', () {
      // 6 distinct words: one, two, three, four, five, six
      final manyWords = ['one two three four five six'];
      final stats = computeStats(manyWords);
      expect(stats.topWords.length, lessThanOrEqualTo(5));
    });

    test('empty input returns zero counts and empty topWords', () {
      final stats = computeStats([]);
      expect(stats.lineCount, 0);
      expect(stats.wordCount, 0);
      expect(stats.uniqueCharCount, 0);
      expect(stats.topWords, isEmpty);
    });

    test('single blank line returns correct counts', () {
      // One line with content '' — 0 words, 0 unique chars
      final stats = computeStats(['']);
      expect(stats.lineCount, 1);
      expect(stats.wordCount, 0);
      expect(stats.uniqueCharCount, 0);
    });

    test('punctuation is stripped from words before frequency count', () {
      // "hello!" and "hello," and "hello" should all count as "hello"
      final stats = computeStats(['hello! hello, hello']);
      expect(stats.topWords.first.key, 'hello');
      expect(stats.topWords.first.value, 3);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Search mode — line filtering logic
  //
  // The full _searchLines() function (task 15.3) wraps this predicate in a
  // Stream pipeline.  We test the predicate directly here by replicating the
  // same filter: case-insensitive substring match, with line numbers.
  // ─────────────────────────────────────────────────────────────────────────
  group('search mode — line filtering logic', () {
    // Helper that replicates what _searchLines() will do without the I/O layer.
    // Returns List<String> in the format "$lineNumber: $line".
    List<String> filterLines(List<String> lines, String keyword) {
      final kw = keyword.toLowerCase();
      return lines
          .asMap()
          .entries
          .where((e) => e.value.toLowerCase().contains(kw))
          .map((e) => '${e.key + 1}: ${e.value}')
          .toList();
    }

    final corpus = [
      'Dart is a modern language',  // line 1 — contains "Dart", "modern"
      'Flutter uses Dart widgets',   // line 2 — contains "Dart", "Flutter"
      'Python is also popular',      // line 3 — no "Dart"
      'dart performance is great',   // line 4 — "dart" lowercase
    ];

    test('keyword present — returns matching lines with 1-based line numbers', () {
      final result = filterLines(corpus, 'Dart');
      expect(result.length, 3); // lines 1, 2, 4
      expect(result[0], '1: Dart is a modern language');
      expect(result[1], '2: Flutter uses Dart widgets');
      expect(result[2], '4: dart performance is great');
    });

    test('search is case-insensitive', () {
      // 'DART', 'Dart', 'dart' must all find the same 3 lines
      expect(filterLines(corpus, 'DART').length, 3);
      expect(filterLines(corpus, 'dart').length, 3);
      expect(filterLines(corpus, 'Dart').length, 3);
    });

    test('keyword absent — returns empty list', () {
      final result = filterLines(corpus, 'Kotlin');
      expect(result, isEmpty);
    });

    test('partial keyword matches within a word', () {
      // 'ode' is inside 'modern'
      final result = filterLines(corpus, 'ode');
      expect(result.length, 1);
      expect(result[0], '1: Dart is a modern language');
    });

    test('all lines match when keyword is empty string', () {
      // Every line contains the empty string
      expect(filterLines(corpus, '').length, corpus.length);
    });

    test('single-line corpus with a match returns line 1', () {
      final result = filterLines(['only one line here'], 'one');
      expect(result, ['1: only one line here']);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Transform mode — TransformMode.apply()
  // ─────────────────────────────────────────────────────────────────────────
  group('TransformMode.apply()', () {
    test('upper converts line to UPPERCASE', () {
      expect(TransformMode.upper.apply('hello dart'), 'HELLO DART');
    });

    test('upper leaves an already-uppercase line unchanged', () {
      expect(TransformMode.upper.apply('HELLO'), 'HELLO');
    });

    test('lower converts line to lowercase', () {
      expect(TransformMode.lower.apply('HELLO DART'), 'hello dart');
    });

    test('lower leaves an already-lowercase line unchanged', () {
      expect(TransformMode.lower.apply('hello'), 'hello');
    });

    test('reverse reverses characters in the line', () {
      expect(TransformMode.reverse.apply('Dart'), 'traD');
    });

    test('reverse of a palindrome returns the same string', () {
      expect(TransformMode.reverse.apply('racecar'), 'racecar');
    });

    test('reverse of empty string returns empty string', () {
      expect(TransformMode.reverse.apply(''), '');
    });

    test('apply preserves mixed characters (numbers, symbols)', () {
      expect(TransformMode.upper.apply('dart3!'), 'DART3!');
      expect(TransformMode.lower.apply('DART3!'), 'dart3!');
      expect(TransformMode.reverse.apply('abc123'), '321cba');
    });

    test('all three transform modes applied to the same line', () {
      const line = 'Hello World';
      expect(TransformMode.upper.apply(line), 'HELLO WORLD');
      expect(TransformMode.lower.apply(line), 'hello world');
      expect(TransformMode.reverse.apply(line), 'dlroW olleH');
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Result<T, E> — sealed container correctness
  // ─────────────────────────────────────────────────────────────────────────
  group('Result<T, E>', () {
    test('Success carries the provided value', () {
      const result = Success<int, String>(42);
      expect(result.value, 42);
    });

    test('Failure carries the provided error', () {
      const result = Failure<int, String>('err');
      expect(result.error, 'err');
    });

    test('Success is a Result (type hierarchy)', () {
      final Result<int, String> result = Success(42);
      expect(result, isA<Result<int, String>>());
      expect(result, isA<Success<int, String>>());
    });

    test('Failure is a Result (type hierarchy)', () {
      final Result<int, String> result = Failure('oops');
      expect(result, isA<Result<int, String>>());
      expect(result, isA<Failure<int, String>>());
    });

    test('Success is not a Failure', () {
      final Result<int, String> result = Success(1);
      expect(result, isNot(isA<Failure>()));
    });

    test('Failure is not a Success', () {
      final Result<int, String> result = Failure('no');
      expect(result, isNot(isA<Success>()));
    });

    test('switch expression is exhaustive — Success branch extracts value', () {
      final Result<String, int> result = const Success('hello');
      final output = switch (result) {
        Success(:final value) => 'got: $value',
        Failure(:final error) => 'err: $error',
      };
      expect(output, 'got: hello');
    });

    test('switch expression is exhaustive — Failure branch extracts error', () {
      final Result<String, int> result = const Failure(404);
      final output = switch (result) {
        Success(:final value) => 'got: $value',
        Failure(:final error) => 'err: $error',
      };
      expect(output, 'err: 404');
    });

    test('Success with value 0 is a valid success (not confused with null)', () {
      const result = Success<int, String>(0);
      expect(result.value, 0);
    });

    test('Success with empty string is a valid success', () {
      const result = Success<String, int>('');
      expect(result.value, '');
    });

    test('Failure with empty string is a valid failure', () {
      const result = Failure<int, String>('');
      expect(result.error, '');
    });

    test('toString formats correctly for Success', () {
      expect(const Success<int, String>(42).toString(), 'Success(42)');
    });

    test('toString formats correctly for Failure', () {
      expect(const Failure<int, String>('err').toString(), 'Failure(err)');
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // parseMode() — CLI argument parsing helper
  // ─────────────────────────────────────────────────────────────────────────
  group('parseMode()', () {
    test('returns Success(stats) for "stats"', () {
      final result = parseMode(['stats', 'file.txt']);
      expect(result, isA<Success>());
      expect((result as Success).value, ProcessingMode.stats);
    });

    test('returns Success(search) for "search"', () {
      final result = parseMode(['search', 'dart', 'file.txt']);
      expect((result as Success).value, ProcessingMode.search);
    });

    test('returns Success(transform) for "transform"', () {
      final result = parseMode(['transform', 'upper', 'file.txt']);
      expect((result as Success).value, ProcessingMode.transform);
    });

    test('returns Failure for unknown mode', () {
      expect(parseMode(['unknown']), isA<Failure>());
    });

    test('returns Failure for empty args', () {
      expect(parseMode([]), isA<Failure>());
    });

    test('mode parsing is case-insensitive', () {
      expect(parseMode(['STATS', 'file.txt']), isA<Success>());
      expect(parseMode(['Stats', 'file.txt']), isA<Success>());
    });
  });
}
