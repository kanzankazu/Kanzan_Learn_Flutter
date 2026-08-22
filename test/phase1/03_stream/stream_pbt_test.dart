// ============================================================
// PHASE 1 — Stream: Property-Based Tests
// ============================================================
// Feature: phase-1-dart-language, Property 5-7: Validates Requirements 3.3, 3.4
//
// Properties tested:
//   Property 5 — Stream ordering via fromIterable        (Req 3.3)
//   Property 6 — Stream.where() filter correctness       (Req 3.4)
//   Property 7 — Stream.take(N) length bound             (Req 3.4)
//
// Approach: manual random generation with dart:math Random,
// seeded per test group for deterministic replays on failure.
// Each property runs a minimum of 100 iterations.
// All tests are async because Stream consumption is inherently async.
// ============================================================

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

// ── helpers ────────────────────────────────────────────────

/// Returns a random List<int> of up to [maxLen] elements drawn from [rng].
/// Clamped to avoid excessively slow tests.
List<int> _randomIntList(Random rng, {int maxLen = 50}) {
  final len = rng.nextInt(maxLen + 1); // 0..maxLen elements
  return List.generate(len, (_) => rng.nextInt(201) - 100); // -100..100
}

/// Returns one of several deterministic int predicates indexed by [selector].
/// Using a fixed pool makes each iteration's predicate reproducible.
bool Function(int) _pickPredicate(int selector) {
  final predicates = <bool Function(int)>[
    (x) => x.isEven,
    (x) => x > 0,
    (x) => x < 0,
    (x) => x.abs() > 10,
    (x) => x % 3 == 0,
    (x) => x.isOdd,
    (x) => x >= -5 && x <= 5,
    (x) => x != 0,
  ];
  return predicates[selector.abs() % predicates.length];
}

// ── test suite ─────────────────────────────────────────────

void main() {
  // ──────────────────────────────────────────────────────────
  // Property 5 — Stream values arrive in emission order
  // ──────────────────────────────────────────────────────────
  // Feature: phase-1-dart-language, Property 5: Validates Requirements 3.3
  //
  // For any List<int> converted to Stream.fromIterable,
  // consuming with `await for` must yield the exact same list
  // in the same order — no reordering, no drops, no additions.
  // ──────────────────────────────────────────────────────────
  group('Property 5 — Stream ordering via fromIterable (Req 3.3)', () {
    // Feature: phase-1-dart-language, Property 5: Validates Requirements 3.3

    test('await for yields elements in the same order as the source list',
        () async {
      final rng = Random(42);
      const iterations = 100;

      for (var i = 0; i < iterations; i++) {
        final source = _randomIntList(rng);

        // Convert list to stream — the canonical ordering test.
        // Stream.fromIterable guarantees emission in iteration order,
        // and `await for` must consume them in that same order.
        final collected = <int>[];
        await for (final value in Stream.fromIterable(source)) {
          collected.add(value);
        }

        // The collected sequence must be byte-for-byte identical to source.
        expect(
          collected,
          equals(source),
          reason:
              'iteration $i: collected stream values must equal source list '
              '(expected $source, got $collected)',
        );
      }
    });

    test('empty source list produces an empty stream', () async {
      final collected = <int>[];
      await for (final value in Stream.fromIterable(<int>[])) {
        collected.add(value);
      }
      expect(collected, isEmpty);
    });

    test('single-element stream yields exactly that element', () async {
      final rng = Random(99);
      for (var i = 0; i < 100; i++) {
        final element = rng.nextInt(201) - 100;
        final collected = <int>[];
        await for (final v in Stream.fromIterable([element])) {
          collected.add(v);
        }
        expect(collected, equals([element]),
            reason: 'iteration $i: single-element stream must yield [$element]');
      }
    });

    test('length of collected values matches source list length', () async {
      final rng = Random(13);
      for (var i = 0; i < 100; i++) {
        final source = _randomIntList(rng);
        var count = 0;
        await for (final _ in Stream.fromIterable(source)) {
          count++;
        }
        expect(count, equals(source.length),
            reason:
                'iteration $i: stream must emit exactly ${source.length} values');
      }
    });
  });

  // ──────────────────────────────────────────────────────────
  // Property 6 — Stream .where() retains only predicate-passing values
  // ──────────────────────────────────────────────────────────
  // Feature: phase-1-dart-language, Property 6: Validates Requirements 3.4
  //
  // For any stream and predicate p: int → bool,
  //   every value emitted by .where(p) satisfies p
  //   no value in the result fails p
  //   the result is a subsequence of the source in original order
  // ──────────────────────────────────────────────────────────
  group('Property 6 — Stream.where() filter correctness (Req 3.4)', () {
    // Feature: phase-1-dart-language, Property 6: Validates Requirements 3.4

    test('every element in the filtered stream satisfies the predicate',
        () async {
      final rng = Random(7);
      const iterations = 100;

      for (var i = 0; i < iterations; i++) {
        final source = _randomIntList(rng);
        final p = _pickPredicate(rng.nextInt(8));

        final filtered = await Stream.fromIterable(source).where(p).toList();

        for (final el in filtered) {
          expect(
            p(el),
            isTrue,
            reason:
                'iteration $i: element $el in filtered stream must satisfy '
                'predicate (source was $source)',
          );
        }
      }
    });

    test('no predicate-satisfying element from source is dropped', () async {
      final rng = Random(21);
      for (var i = 0; i < 100; i++) {
        final source = _randomIntList(rng);
        final p = _pickPredicate(rng.nextInt(8));

        // Ground truth: manual filter over the source list.
        final expected = [for (final x in source) if (p(x)) x];

        // Stream .where() must produce the identical subsequence.
        final fromStream =
            await Stream.fromIterable(source).where(p).toList();

        expect(
          fromStream,
          equals(expected),
          reason:
              'iteration $i: Stream.where() must match list .where() exactly '
              '(source=$source, expected=$expected, got=$fromStream)',
        );
      }
    });

    test('always-true predicate passes every element unchanged', () async {
      final rng = Random(33);
      for (var i = 0; i < 100; i++) {
        final source = _randomIntList(rng);
        final result =
            await Stream.fromIterable(source).where((_) => true).toList();
        expect(result, equals(source),
            reason:
                'iteration $i: always-true predicate must preserve all elements');
      }
    });

    test('always-false predicate produces an empty stream', () async {
      final rng = Random(55);
      for (var i = 0; i < 100; i++) {
        // Use a non-empty source to make the test meaningful.
        final source = _randomIntList(rng, maxLen: 20);
        if (source.isEmpty) continue; // skip trivial empty case

        final result =
            await Stream.fromIterable(source).where((_) => false).toList();
        expect(result, isEmpty,
            reason:
                'iteration $i: always-false predicate must yield empty stream');
      }
    });
  });

  // ──────────────────────────────────────────────────────────
  // Property 7 — Stream .take(N) emits at most N values
  // ──────────────────────────────────────────────────────────
  // Feature: phase-1-dart-language, Property 7: Validates Requirements 3.4
  //
  // For any stream emitting M values and any integer N ≥ 0,
  //   .take(N) emits exactly min(M, N) values
  //   the emitted values are the first min(M, N) elements of the source
  //   N == 0 always produces an empty stream
  // ──────────────────────────────────────────────────────────
  group('Property 7 — Stream.take(N) length bound (Req 3.4)', () {
    // Feature: phase-1-dart-language, Property 7: Validates Requirements 3.4

    test('result length equals min(source.length, N) for all N in 0–20',
        () async {
      final rng = Random(101);
      const iterations = 100;

      for (var i = 0; i < iterations; i++) {
        final source = _randomIntList(rng, maxLen: 30);
        final n = rng.nextInt(21); // 0–20 inclusive

        final result =
            await Stream.fromIterable(source).take(n).toList();

        final expectedLength = source.length < n ? source.length : n;

        expect(
          result.length,
          equals(expectedLength),
          reason:
              'iteration $i: take($n) on ${source.length}-element stream must '
              'yield $expectedLength elements, got ${result.length}',
        );
      }
    });

    test('take(0) always produces an empty stream regardless of source size',
        () async {
      final rng = Random(202);
      for (var i = 0; i < 100; i++) {
        // Use a non-empty source to confirm take(0) is not a trivial pass.
        final source = _randomIntList(rng, maxLen: 20);
        if (source.isEmpty) continue;

        final result = await Stream.fromIterable(source).take(0).toList();
        expect(result, isEmpty,
            reason: 'iteration $i: take(0) must always yield an empty stream');
      }
    });

    test('take(N) where N >= source.length emits the full source', () async {
      final rng = Random(303);
      for (var i = 0; i < 100; i++) {
        final source = _randomIntList(rng, maxLen: 15);
        // N is at least source.length, so the entire source should pass through.
        final n = source.length + rng.nextInt(11); // source.length .. source.length+10

        final result =
            await Stream.fromIterable(source).take(n).toList();

        expect(result, equals(source),
            reason:
                'iteration $i: take($n) on ${source.length}-element stream '
                'must return the full source');
      }
    });

    test('take(N) emits the first N elements of the source in order',
        () async {
      final rng = Random(404);
      for (var i = 0; i < 100; i++) {
        final source = _randomIntList(rng, maxLen: 25);
        if (source.isEmpty) continue;

        // N is always ≤ source.length here, so we get exactly the first N.
        final n = rng.nextInt(source.length) + 1; // 1..source.length

        final result =
            await Stream.fromIterable(source).take(n).toList();

        // Must be exactly the first N elements of source.
        final expected = source.sublist(0, n);
        expect(result, equals(expected),
            reason:
                'iteration $i: take($n) must equal the first $n elements of '
                'source (expected $expected, got $result)');
      }
    });
  });
}
