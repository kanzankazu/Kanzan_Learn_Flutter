// Feature: phase-1-dart-language, Property 16: Validates Requirements 13.3, 13.9
//
// Property-Based Tests for TextUtils extension methods: wordCount and lineCount.
//
// Property 16: Text statistics functions are pure functions of their input.
//   - For any string [text], wordCount == the number of non-empty whitespace-delimited tokens
//   - For any string [text], lineCount == the number of '\n'-separated segments
//   - Both are deterministic: calling with the same input always returns the same value
//   - wordCount returns 0 for "" and whitespace-only strings
//   - lineCount returns 1 for "" (a string with no newlines is still 1 segment)
//
// Minimum 100 iterations with seeded random generators for reproducibility.
//
// Run:
//   dart test test/phase1/mini_projects/file_processor/file_processor_pbt_test.dart

import 'dart:math';

import 'package:test/test.dart';

import '../../../../lib/phase1/mini_projects/file_processor/file_processor.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Random string generators
// ─────────────────────────────────────────────────────────────────────────────

/// Simple list of words used to build random multi-line text.
const _wordBank = [
  'dart', 'flutter', 'stream', 'future', 'async', 'null', 'safety',
  'isolate', 'record', 'mixin', 'sealed', 'class', 'extension', 'generic',
  'pattern', 'hello', 'world', 'test', 'property', 'based', 'language',
  'function', 'variable', 'type', 'enum', 'switch', 'case', 'when',
];

/// Builds a random multi-line string.
///
/// Each "line" is 0–5 words joined by various whitespace (space, tab, or
/// multiple spaces), and lines are separated by '\n'. Occasionally a line is
/// empty (blank line) to cover edge cases.
///
/// [maxLines]  — maximum number of lines in the result (1–20)
/// [maxWords]  — maximum words per line (0–5)
String _randomMultilineText(Random rng, {int maxLines = 10, int maxWords = 5}) {
  final lineCount = rng.nextInt(maxLines) + 1; // at least 1 line
  final lines = List.generate(lineCount, (lineIndex) {
    // 20% chance of generating an empty/blank line
    if (rng.nextDouble() < 0.2) return '';

    final wordCount = rng.nextInt(maxWords + 1); // 0..maxWords
    final words = List.generate(wordCount, (_) {
      return _wordBank[rng.nextInt(_wordBank.length)];
    });

    // Join with varied whitespace: single space, tab, or double space
    final separators = List.generate(max(0, wordCount - 1), (_) {
      final choice = rng.nextInt(3);
      return switch (choice) {
        0 => ' ',
        1 => '\t',
        _ => '  ', // double space
      };
    });

    // Interleave words and separators
    if (words.isEmpty) return '';
    final buf = StringBuffer(words[0]);
    for (var i = 1; i < words.length; i++) {
      buf.write(separators[i - 1]);
      buf.write(words[i]);
    }

    // Occasionally add leading/trailing whitespace to test trim robustness
    if (rng.nextDouble() < 0.15) return '  ${buf.toString()}';
    if (rng.nextDouble() < 0.15) return '${buf.toString()}  ';
    return buf.toString();
  });

  return lines.join('\n');
}

// ─────────────────────────────────────────────────────────────────────────────
// Reference implementations (manual ground truth for property checking)
// ─────────────────────────────────────────────────────────────────────────────

/// Reference implementation of wordCount: split on any whitespace run,
/// keep only non-empty tokens.
///
/// This mirrors what TextUtils.wordCount does, expressed independently so the
/// test does not just re-invoke the same code path.
int _referenceWordCount(String text) {
  return text.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).length;
}

/// Reference implementation of lineCount: count '\n'-separated segments.
///
/// This matches TextUtils.lineCount semantics: every string has at least 1
/// segment, so the empty string returns 1, not 0.
int _referenceLineCount(String text) {
  return text.split('\n').length;
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  // Fixed seed so failures are reproducible. If a counter-example is found,
  // use the failing seed value to replay the exact same sequence.
  const seed = 42;

  // ─────────────────────────────────────────────────────────────────────────
  // Edge case: empty string
  // ─────────────────────────────────────────────────────────────────────────
  group('TextUtils edge cases — empty string', () {
    // wordCount of empty string must be 0 (no tokens)
    test('wordCount("") == 0', () {
      expect(''.wordCount, equals(0));
    });

    // lineCount of empty string: "".split('\n') == [""], length == 1
    // This is consistent with the definition: a file with 0 bytes still has
    // 1 (empty) line.
    test('lineCount("") == 1 (empty string is one empty segment)', () {
      expect(''.lineCount, equals(1));
    });

    // Whitespace-only strings have no words
    test('wordCount of whitespace-only string == 0', () {
      for (final ws in ['   ', '\t', '\n', ' \t \n ']) {
        expect(ws.wordCount, equals(0),
            reason: 'Expected wordCount 0 for whitespace-only "$ws"');
      }
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // PBT-13 Property 16a: wordCount matches reference implementation
  // ─────────────────────────────────────────────────────────────────────────
  group('PBT-13 Property 16a — wordCount matches reference for random strings', () {
    test('100 iterations: text.wordCount == reference split count', () {
      final rng = Random(seed);
      const iterations = 100;

      for (var i = 0; i < iterations; i++) {
        final text = _randomMultilineText(rng);

        final actual = text.wordCount;
        final expected = _referenceWordCount(text);

        expect(
          actual,
          equals(expected),
          reason: 'Iteration $i: wordCount mismatch for input:\n'
              '"""\n$text\n"""\n'
              'Got: $actual, Expected: $expected',
        );
      }
    });

    // Additional pass with more varied input sizes
    test('100 iterations: larger texts up to 20 lines × 5 words', () {
      final rng = Random(seed + 1);
      const iterations = 100;

      for (var i = 0; i < iterations; i++) {
        final text = _randomMultilineText(rng, maxLines: 20, maxWords: 5);

        final actual = text.wordCount;
        final expected = _referenceWordCount(text);

        expect(
          actual,
          equals(expected),
          reason: 'Iteration $i (large): wordCount mismatch',
        );
      }
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // PBT-13 Property 16b: lineCount matches reference implementation
  // ─────────────────────────────────────────────────────────────────────────
  group('PBT-13 Property 16b — lineCount matches reference for random strings', () {
    test('100 iterations: text.lineCount == reference newline count', () {
      final rng = Random(seed);
      const iterations = 100;

      for (var i = 0; i < iterations; i++) {
        final text = _randomMultilineText(rng);

        final actual = text.lineCount;
        final expected = _referenceLineCount(text);

        expect(
          actual,
          equals(expected),
          reason: 'Iteration $i: lineCount mismatch for input:\n'
              '"""\n$text\n"""\n'
              'Got: $actual, Expected: $expected',
        );
      }
    });

    // Verify lineCount correlates with explicit newline insertion
    test('100 iterations: N newlines in string → lineCount == N + 1', () {
      final rng = Random(seed + 2);
      const iterations = 100;

      for (var i = 0; i < iterations; i++) {
        // Build a string with exactly k newlines
        final k = rng.nextInt(15); // 0..14 newlines
        final segments = List.generate(k + 1, (idx) {
          final wordCount = rng.nextInt(4); // 0..3 words per segment
          return List.generate(
            wordCount,
            (_) => _wordBank[rng.nextInt(_wordBank.length)],
          ).join(' ');
        });
        final text = segments.join('\n');

        // text has exactly k '\n' characters → lineCount == k + 1
        expect(
          text.lineCount,
          equals(k + 1),
          reason: 'Iteration $i: expected lineCount ${k + 1} for string with '
              '$k newlines',
        );
      }
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // PBT-13 Property 16c: determinism — same input always returns same output
  // ─────────────────────────────────────────────────────────────────────────
  group('PBT-13 Property 16c — both functions are deterministic', () {
    test('100 iterations: calling wordCount twice on same input yields same result', () {
      final rng = Random(seed + 3);
      const iterations = 100;

      for (var i = 0; i < iterations; i++) {
        final text = _randomMultilineText(rng);

        // Call twice — result must be identical
        final first = text.wordCount;
        final second = text.wordCount;

        expect(
          first,
          equals(second),
          reason: 'Iteration $i: wordCount is non-deterministic for input:\n'
              '"""\n$text\n"""',
        );
      }
    });

    test('100 iterations: calling lineCount twice on same input yields same result', () {
      final rng = Random(seed + 4);
      const iterations = 100;

      for (var i = 0; i < iterations; i++) {
        final text = _randomMultilineText(rng);

        final first = text.lineCount;
        final second = text.lineCount;

        expect(
          first,
          equals(second),
          reason: 'Iteration $i: lineCount is non-deterministic for input:\n'
              '"""\n$text\n"""',
        );
      }
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // PBT-13 Property 16d: structural consistency between wordCount and lineCount
  // ─────────────────────────────────────────────────────────────────────────
  group('PBT-13 Property 16d — structural consistency properties', () {
    // Concatenating two strings with a newline between them:
    // lineCount(a + '\n' + b) == lineCount(a) + lineCount(b)
    test('100 iterations: lineCount(a + "\\n" + b) == lineCount(a) + lineCount(b)', () {
      final rng = Random(seed + 5);
      const iterations = 100;

      for (var i = 0; i < iterations; i++) {
        final a = _randomMultilineText(rng, maxLines: 5);
        final b = _randomMultilineText(rng, maxLines: 5);
        final combined = '$a\n$b';

        expect(
          combined.lineCount,
          equals(a.lineCount + b.lineCount),
          reason: 'Iteration $i: lineCount concatenation property failed',
        );
      }
    });

    // wordCount of a single-word string (no whitespace) must be 1
    test('100 iterations: single-word strings have wordCount == 1', () {
      final rng = Random(seed + 6);
      const iterations = 100;

      for (var i = 0; i < iterations; i++) {
        final word = _wordBank[rng.nextInt(_wordBank.length)];
        expect(
          word.wordCount,
          equals(1),
          reason: 'Iteration $i: single word "$word" should have wordCount 1',
        );
      }
    });
  });
}
