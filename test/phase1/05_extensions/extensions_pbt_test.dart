// ============================================================
// PHASE 1 — Property-Based Tests for Extension Methods
// ============================================================
// Feature: phase-1-dart-language, Property 8: Validates Requirements 5.2, 5.3, 5.4
//
// Property 8: Extension methods are semantically equivalent to their
//             inline implementations.
//
// For every input value of the extended type, calling the extension
// must produce the exact same result as writing the equivalent inline
// expression by hand. This proves the extensions add no accidental
// behavior beyond what their documentation claims.
//
// Three sub-properties are tested:
//   8a. String.capitalize  — equiv. to isEmpty?s:s[0].toUpperCase()+s.substring(1)
//   8b. int.isEven         — equiv. to n % 2 == 0
//   8c. List<T>.second     — equiv. to list[1] when length >= 2
//
// Run with:
//   flutter test test/phase1/05_extensions/extensions_pbt_test.dart
//
// Dart SDK: >= 3.0.0
// ============================================================

import 'dart:math';

import 'package:belajar_1/phase1/05_extensions/extensions_demo.dart'
    show StringUtils, IntUtils, ListUtils;
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Random generators
// ---------------------------------------------------------------------------
//
// All generators accept a [Random] instance so every iteration is driven by
// the same seeded PRNG — if a failure is found the seed can be fixed to replay
// the exact failing case.

/// Returns a random [String] of length 0–19 drawn from printable ASCII
/// characters (codepoints 32–126).
///
/// The range deliberately includes:
///   - Empty string (length 0)      → tests the early-return branch
///   - Single-char strings           → tests both upper- and lower-case first char
///   - Strings that already start upper-case (e.g., "Hello")
///   - Strings with non-letter first chars (digits, punctuation)
///
/// Using a bounded printable-ASCII set keeps the output human-readable when
/// a failure is logged, while still exercising edge cases that matter for
/// `capitalize`.
String _randomString(Random rng) {
  final length = rng.nextInt(20); // 0..19
  return String.fromCharCodes(
    List.generate(length, (_) => rng.nextInt(95) + 32), // ASCII 32..126
  );
}

/// Returns a random [int] in the range -10 000..10 000.
///
/// Covers negative numbers (even/odd), zero, small positives/negatives, and
/// large values — all important for exercising `isEven`.
int _randomInt(Random rng) {
  return rng.nextInt(20001) - 10000; // -10000..10000
}

/// Returns a random [List<int>] with at least 2 elements (length 2–20).
///
/// `list.second` is only defined for length >= 2, so all generated lists
/// satisfy the precondition. Elements are drawn from -1000..1000.
List<int> _randomListAtLeastTwo(Random rng) {
  final length = rng.nextInt(19) + 2; // 2..20
  return List.generate(length, (_) => rng.nextInt(2001) - 1000);
}

// ---------------------------------------------------------------------------
// Inline reference implementations
// ---------------------------------------------------------------------------
//
// These mirror exactly what the doc-comments on each extension promise.
// The PBT compares the extension output to these expressions rather than
// to each other, so any divergence pinpoints the extension as the bug.

/// Inline equivalent of [StringUtils.capitalize].
String _inlineCapitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// Inline equivalent of [IntUtils.isEven].
bool _inlineIsEven(int n) => n % 2 == 0;

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // Fixed seed: any counter-example can be replicated by running the test
  // again with the same seed. Change this to `null` for fully random runs.
  const int seed = 42;

  // Minimum iterations required by the spec.
  const int iterations = 100;

  group('PBT-8 — Extension methods are semantically equivalent to inline '
      'implementations', () {
    // -----------------------------------------------------------------------
    // 8a: String.capitalize
    // -----------------------------------------------------------------------
    test(
      '8a: String.capitalize equals inline isEmpty?s:s[0].toUpperCase()+s.substring(1)',
      () {
        // Feature: phase-1-dart-language, Property 8a: Validates Requirements 5.2
        final rng = Random(seed);

        for (int i = 0; i < iterations; i++) {
          final s = _randomString(rng);

          final extensionResult = s.capitalize; // via StringUtils extension
          final inlineResult = _inlineCapitalize(s); // reference expression

          expect(
            extensionResult,
            equals(inlineResult),
            reason: 'capitalize mismatch on input: ${_quote(s)} '
                '(iteration $i)',
          );
        }
      },
    );

    // Edge cases for capitalize that the random generator might miss:
    test('8a edge cases: empty string, single char, already-upper first char',
        () {
      // Feature: phase-1-dart-language, Property 8a edge cases
      final cases = ['', 'a', 'A', 'hello', 'WORLD', '1abc', ' space'];
      for (final s in cases) {
        expect(
          s.capitalize,
          equals(_inlineCapitalize(s)),
          reason: 'capitalize mismatch on: ${_quote(s)}',
        );
      }
    });

    // -----------------------------------------------------------------------
    // 8b: int.isEven
    // -----------------------------------------------------------------------
    test(
      '8b: int.isEven (extension getter) equals n % 2 == 0',
      () {
        // Feature: phase-1-dart-language, Property 8b: Validates Requirements 5.3
        final rng = Random(seed);

        for (int i = 0; i < iterations; i++) {
          final n = _randomInt(rng);

          final extensionResult = n.isEven; // via IntUtils extension
          final inlineResult = _inlineIsEven(n); // reference expression

          expect(
            extensionResult,
            equals(inlineResult),
            reason: 'isEven mismatch on input: $n (iteration $i)',
          );
        }
      },
    );

    // Edge cases: zero, 1, -1, min/max typical boundary
    test('8b edge cases: 0, 1, -1, -2, large even, large odd', () {
      // Feature: phase-1-dart-language, Property 8b edge cases
      final cases = [0, 1, -1, -2, 100, 101, -100, -101];
      for (final n in cases) {
        expect(
          n.isEven,
          equals(_inlineIsEven(n)),
          reason: 'isEven mismatch on: $n',
        );
      }
    });

    // -----------------------------------------------------------------------
    // 8c: List<T>.second
    // -----------------------------------------------------------------------
    test(
      '8c: List<T>.second equals list[1] for lists with length >= 2',
      () {
        // Feature: phase-1-dart-language, Property 8c: Validates Requirements 5.4
        final rng = Random(seed);

        for (int i = 0; i < iterations; i++) {
          final list = _randomListAtLeastTwo(rng);

          final extensionResult = list.second; // via ListUtils extension (T?)
          final inlineResult = list[1]; // reference expression

          // The extension returns T? — it will be non-null here because
          // length >= 2, so we compare the unwrapped value.
          expect(
            extensionResult,
            equals(inlineResult),
            reason: 'second mismatch on list: $list (iteration $i)',
          );
        }
      },
    );

    // Edge cases for second: exactly 2 elements, second element is null-like,
    // large list (second is still index 1, not last)
    test('8c edge cases: 2-element list, large list', () {
      // Feature: phase-1-dart-language, Property 8c edge cases
      final twoElement = [10, 20];
      expect(twoElement.second, equals(twoElement[1]));

      final largeList = List.generate(100, (i) => i * 3);
      expect(largeList.second, equals(largeList[1]));
    });

    // Verify second returns null for lists shorter than 2 (boundary of precondition)
    test('8c boundary: second returns null for empty list and single-element '
        'list', () {
      expect(<int>[].second, isNull);
      expect([42].second, isNull);
    });
  });
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Wraps [s] in single quotes for readable failure messages.
String _quote(String s) => "'$s'";
