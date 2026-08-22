// ============================================================
// PHASE 1 — Collections Advanced: Property-Based Tests
// ============================================================
// Feature: phase-1-dart-language, Property 1-4: Validates Requirements 4.2, 4.3, 4.4, 4.6
//
// Properties tested:
//   Property 1 — List.map() functor law              (Req 4.2)
//   Property 2 — List.where() filter correctness     (Req 4.3)
//   Property 3 — List.fold() left fold identity      (Req 4.4)
//   Property 4 — Spread operator concatenation       (Req 4.6)
//
// Approach: manual random generation with dart:math Random,
// seeded per test group for deterministic replays on failure.
// Each property runs a minimum of 100 iterations.
// ============================================================

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

// ── helpers ────────────────────────────────────────────────

/// Returns a random List<int> of [length] elements drawn from [rng].
/// Length is clamped to [0, 50] to keep tests fast.
List<int> _randomIntList(Random rng, {int? length}) {
  final len = length ?? rng.nextInt(51); // 0–50 elements
  return List.generate(len, (_) => rng.nextInt(201) - 100); // -100..100
}

/// A set of deterministic int→int transform functions indexed by selector.
/// Using a fixed pool ensures functions are reproducible from a random index.
int Function(int) _pickTransform(int selector) {
  final transforms = <int Function(int)>[
    (x) => x * 2,
    (x) => x + 3,
    (x) => x - 7,
    (x) => x * x,
    (x) => x.abs(),
    (x) => -x,
    (x) => x % 10,
    (x) => x + 100,
  ];
  return transforms[selector.abs() % transforms.length];
}

/// Returns one of several deterministic int predicates indexed by [selector].
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
  // Property 1 — List .map() functor law
  // ──────────────────────────────────────────────────────────
  // For any List<int> and any f: int → int,
  //   mapped.length == original.length
  //   mapped[i] == f(original[i]) for every i
  // ──────────────────────────────────────────────────────────
  group('Property 1 — List.map() functor law (Req 4.2)', () {
    // Feature: phase-1-dart-language, Property 1: Validates Requirements 4.2

    test('length is preserved and each element equals f(original[i])', () {
      // Seed chosen arbitrarily; change this constant to replay a specific run.
      final rng = Random(42);
      const iterations = 100;

      for (var i = 0; i < iterations; i++) {
        final original = _randomIntList(rng);
        final f = _pickTransform(rng.nextInt(8));

        final mapped = original.map(f).toList();

        // ── Functor law 1: length preserved ──────────────────
        expect(
          mapped.length,
          equals(original.length),
          reason: 'iteration $i: .map() must not add or drop elements',
        );

        // ── Functor law 2: element-wise equality ─────────────
        for (var idx = 0; idx < original.length; idx++) {
          expect(
            mapped[idx],
            equals(f(original[idx])),
            reason:
                'iteration $i, index $idx: mapped[$idx] must equal f(original[$idx])',
          );
        }
      }
    });

    test('mapping over an empty list returns an empty list', () {
      final result = <int>[].map((x) => x * 2).toList();
      expect(result, isEmpty);
    });

    test('identity function preserves the original list exactly', () {
      final rng = Random(99);
      for (var i = 0; i < 100; i++) {
        final original = _randomIntList(rng);
        final mapped = original.map((x) => x).toList();
        expect(mapped, equals(original));
      }
    });
  });

  // ──────────────────────────────────────────────────────────
  // Property 2 — List .where() filter correctness
  // ──────────────────────────────────────────────────────────
  // For any List<int> and any predicate p: int → bool,
  //   every element in .where(p) satisfies p
  //   no element satisfying p in the original is absent from the result
  //   result is a subsequence of the original (order preserved)
  // ──────────────────────────────────────────────────────────
  group('Property 2 — List.where() filter correctness (Req 4.3)', () {
    // Feature: phase-1-dart-language, Property 2: Validates Requirements 4.3

    test('every result element satisfies the predicate', () {
      final rng = Random(7);
      for (var i = 0; i < 100; i++) {
        final original = _randomIntList(rng);
        final p = _pickPredicate(rng.nextInt(8));

        final filtered = original.where(p).toList();

        for (final el in filtered) {
          expect(
            p(el),
            isTrue,
            reason:
                'iteration $i: element $el in result must satisfy predicate',
          );
        }
      }
    });

    test('no element satisfying the predicate is dropped', () {
      final rng = Random(13);
      for (var i = 0; i < 100; i++) {
        final original = _randomIntList(rng);
        final p = _pickPredicate(rng.nextInt(8));

        final filtered = original.where(p).toList();
        final manuallyFiltered =
            [for (final x in original) if (p(x)) x];

        // Same elements in the same order
        expect(
          filtered,
          equals(manuallyFiltered),
          reason:
              'iteration $i: .where() result must match manual filter exactly',
        );
      }
    });

    test('filtering with always-true predicate returns the full list', () {
      final rng = Random(21);
      for (var i = 0; i < 100; i++) {
        final original = _randomIntList(rng);
        final result = original.where((_) => true).toList();
        expect(result, equals(original));
      }
    });

    test('filtering with always-false predicate returns empty list', () {
      final rng = Random(33);
      for (var i = 0; i < 100; i++) {
        final original = _randomIntList(rng, length: rng.nextInt(20) + 1);
        final result = original.where((_) => false).toList();
        expect(result, isEmpty);
      }
    });
  });

  // ──────────────────────────────────────────────────────────
  // Property 3 — List .fold() left fold identity
  // ──────────────────────────────────────────────────────────
  // For any List<int>, initial value v, and f: (int, int) → int,
  //   .fold(v, f) == manually applying f from left with accumulator v
  //   For empty list: .fold(v, f) == v regardless of f
  // ──────────────────────────────────────────────────────────
  group('Property 3 — List.fold() left fold identity (Req 4.4)', () {
    // Feature: phase-1-dart-language, Property 3: Validates Requirements 4.4

    test('empty list fold always returns the initial value', () {
      final rng = Random(55);
      for (var i = 0; i < 100; i++) {
        final initial = rng.nextInt(201) - 100; // -100..100
        final result = <int>[].fold(initial, (acc, el) => acc + el);
        expect(
          result,
          equals(initial),
          reason: 'iteration $i: empty list fold must return initial $initial',
        );
      }
    });

    test('fold matches sequential left application for random inputs', () {
      final rng = Random(77);

      // Pool of binary int functions to accumulate with
      final accumulators = <int Function(int, int)>[
        (acc, el) => acc + el,
        (acc, el) => acc - el,
        (acc, el) => acc * el,
        (acc, el) => acc > el ? acc : el, // max
        (acc, el) => acc < el ? acc : el, // min
        (acc, el) => acc + el.abs(),
        (acc, el) => (acc + el) % 100,
      ];

      for (var i = 0; i < 100; i++) {
        final original = _randomIntList(rng);
        final initial = rng.nextInt(201) - 100;
        final f = accumulators[rng.nextInt(accumulators.length)];

        // Dart .fold()
        final foldResult = original.fold(initial, f);

        // Manual sequential application (the ground truth)
        var manual = initial;
        for (final el in original) {
          manual = f(manual, el);
        }

        expect(
          foldResult,
          equals(manual),
          reason:
              'iteration $i: fold must equal sequential application. '
              'list=$original, initial=$initial',
        );
      }
    });

    test('single-element list fold equals f(initial, element)', () {
      final rng = Random(88);
      for (var i = 0; i < 100; i++) {
        final el = rng.nextInt(201) - 100;
        final init = rng.nextInt(201) - 100;
        final result = [el].fold(init, (acc, x) => acc + x);
        expect(result, equals(init + el));
      }
    });
  });

  // ──────────────────────────────────────────────────────────
  // Property 4 — Spread operator concatenation
  // ──────────────────────────────────────────────────────────
  // For any List<int> A and List<int> B,
  //   [...A, ...B] has length A.length + B.length
  //   [...A, ...B][i] == A[i] for i < A.length
  //   [...A, ...B][A.length + j] == B[j] for j < B.length
  //   Equivalent to List.of(A)..addAll(B)
  // ──────────────────────────────────────────────────────────
  group('Property 4 — Spread concatenation (Req 4.6)', () {
    // Feature: phase-1-dart-language, Property 4: Validates Requirements 4.6

    test('spread length equals sum of both lists lengths', () {
      final rng = Random(101);
      for (var i = 0; i < 100; i++) {
        final a = _randomIntList(rng);
        final b = _randomIntList(rng);

        final spread = [...a, ...b];

        expect(
          spread.length,
          equals(a.length + b.length),
          reason:
              'iteration $i: spread length must be ${a.length} + ${b.length}',
        );
      }
    });

    test('spread elements equal A then B in original order', () {
      final rng = Random(202);
      for (var i = 0; i < 100; i++) {
        final a = _randomIntList(rng);
        final b = _randomIntList(rng);

        final spread = [...a, ...b];
        final expected = [...a, ...b]; // same syntax — cross-check via addAll
        final manual = List<int>.of(a)..addAll(b);

        // Cross-check against .addAll (the reference implementation)
        expect(
          spread,
          equals(manual),
          reason:
              'iteration $i: spread must equal List.of(A)..addAll(B)',
        );

        // Verify A's elements are at the front
        for (var idx = 0; idx < a.length; idx++) {
          expect(
            spread[idx],
            equals(a[idx]),
            reason:
                'iteration $i, idx $idx: spread front must mirror A',
          );
        }

        // Verify B's elements follow immediately after A
        for (var idx = 0; idx < b.length; idx++) {
          expect(
            spread[a.length + idx],
            equals(b[idx]),
            reason:
                'iteration $i, idx $idx: spread tail must mirror B',
          );
        }
      }
    });

    test('spreading an empty list with a non-empty list equals the non-empty list', () {
      final rng = Random(303);
      for (var i = 0; i < 100; i++) {
        final list = _randomIntList(rng, length: rng.nextInt(20) + 1);

        expect([...list, ...<int>[]], equals(list),
            reason: 'A spread with [] on right must equal A');
        expect([...<int>[], ...list], equals(list),
            reason: 'A spread with [] on left must equal A');
      }
    });

    test('spreading two empty lists produces an empty list', () {
      final result = [...<int>[], ...<int>[]];
      expect(result, isEmpty);
    });

    test('null-aware spread ...? contributes nothing when list is null', () {
      List<int>? nullable;

      final result = [1, ...?nullable, 2];

      expect(result, equals([1, 2]),
          reason: '...? on a null list must contribute zero elements');
    });

    test('null-aware spread ...? contributes elements when list is non-null', () {
      final rng = Random(404);
      for (var i = 0; i < 100; i++) {
        List<int>? nullable = _randomIntList(rng);
        final prefix = [0];
        final suffix = [999];

        final result = [...prefix, ...?nullable, ...suffix];
        final expected = [...prefix, ...nullable, ...suffix];

        expect(result, equals(expected),
            reason:
                'iteration $i: ...? on non-null list must behave like ...');
      }
    });
  });
}
