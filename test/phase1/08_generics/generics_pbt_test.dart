// ============================================================
// PHASE 1 — Generics: Property-Based Tests
// ============================================================
// Feature: phase-1-dart-language, Property 11 / Property 12:
//   Validates Requirements 8.4, 8.5, 13.7
//
// Properties tested:
//   Property 11 — Bounded generic findMax() is consistent with compareTo  (Req 8.4)
//   Property 12 — Result<T, E> container invariant                        (Req 8.5, 13.7)
//
// Approach: manual random generation with dart:math Random,
// seeded per test group for deterministic replays on failure.
// Each property runs a minimum of 100 iterations.
// ============================================================

import 'dart:math';

import 'package:belajar_1/phase1/08_generics/generics_demo.dart';
import 'package:flutter_test/flutter_test.dart';

// ── helpers ────────────────────────────────────────────────

/// Generates a non-empty random List<int> with 1–50 elements in [-100, 100].
///
/// Non-empty is required because [findMax] throws on an empty list, and
/// Property 11 only applies to non-empty inputs.
List<int> _randomNonEmptyIntList(Random rng) {
  final length = rng.nextInt(50) + 1; // 1–50 elements
  return List.generate(length, (_) => rng.nextInt(201) - 100); // -100..100
}

/// Generates a random int in [-10_000, 10_000].
int _randomInt(Random rng) => rng.nextInt(20001) - 10000;

/// Generates a random lowercase alphanumeric string of [length] characters.
String _randomString(Random rng, {int length = 8}) {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  return String.fromCharCodes(
    List.generate(length, (_) => chars.codeUnitAt(rng.nextInt(chars.length))),
  );
}

// ── test suite ─────────────────────────────────────────────

void main() {
  // ──────────────────────────────────────────────────────────
  // Property 11 — Bounded generic findMax() is consistent with compareTo
  // ──────────────────────────────────────────────────────────
  // For any non-empty List<int>, findMax<int>(list) returns an element m
  // such that m.compareTo(x) >= 0 for every x in the list.
  // That is, no element in the list is greater than the returned value.
  // ──────────────────────────────────────────────────────────
  group('Property 11 — findMax() bounded generic sort max (Req 8.4)', () {
    // Feature: phase-1-dart-language, Property 11: Validates Requirements 8.4

    test('findMax<int> returns a value >= every element in the list', () {
      final rng = Random(42);
      const iterations = 100;

      for (var i = 0; i < iterations; i++) {
        final list = _randomNonEmptyIntList(rng);

        final m = findMax<int>(list);

        // m must be contained in the list (findMax returns an actual element)
        expect(
          list.contains(m),
          isTrue,
          reason: 'iteration $i: result $m must be an element of $list',
        );

        // m.compareTo(x) >= 0 for every x — core property assertion
        for (final x in list) {
          expect(
            m.compareTo(x),
            greaterThanOrEqualTo(0),
            reason:
                'iteration $i: max $m must satisfy $m.compareTo($x) >= 0 '
                '(list=$list)',
          );
        }
      }
    });

    test('findMax<int> result equals the standard library maximum', () {
      // Cross-validate against reduce((a, b) => a > b ? a : b),
      // which is the reference implementation for max.
      final rng = Random(77);
      const iterations = 100;

      for (var i = 0; i < iterations; i++) {
        final list = _randomNonEmptyIntList(rng);

        final ourMax = findMax<int>(list);
        final referenceMax = list.reduce((a, b) => a > b ? a : b);

        expect(
          ourMax,
          equals(referenceMax),
          reason:
              'iteration $i: findMax result must equal reduce-based max. '
              'list=$list',
        );
      }
    });

    test('findMax on a single-element list returns that element', () {
      final rng = Random(13);
      const iterations = 100;

      for (var i = 0; i < iterations; i++) {
        final element = _randomInt(rng);
        final result = findMax<int>([element]);

        expect(
          result,
          equals(element),
          reason:
              'iteration $i: single-element list max must be $element',
        );
      }
    });

    test('findMax on a list of identical elements returns that element', () {
      final rng = Random(55);
      const iterations = 100;

      for (var i = 0; i < iterations; i++) {
        final value = _randomInt(rng);
        final length = rng.nextInt(10) + 1; // 1–10 elements
        final list = List.filled(length, value);

        final result = findMax<int>(list);

        expect(
          result,
          equals(value),
          reason:
              'iteration $i: all-identical list max must be $value',
        );
      }
    });

    test('findMax throws ArgumentError on empty list', () {
      // Empty list is out of the domain — ArgumentError is the expected behavior.
      expect(
        () => findMax<int>([]),
        throwsA(isA<ArgumentError>()),
        reason: 'findMax on empty list must throw ArgumentError',
      );
    });
  });

  // ──────────────────────────────────────────────────────────
  // Property 12 — Result<T, E> container invariant
  // ──────────────────────────────────────────────────────────
  // (a) Success<T, E>(v).value == v   — value round-trip
  // (b) Failure<T, E>(e).error == e   — error round-trip
  // (c) A Success is never matched as Failure, and vice versa,
  //     in an exhaustive switch.
  // ──────────────────────────────────────────────────────────
  group('Property 12 — Result<T, E> container invariant (Req 8.5, 13.7)', () {
    // Feature: phase-1-dart-language, Property 12: Validates Requirements 8.5, 13.7

    test('Success(v).value == v for random int values', () {
      final rng = Random(101);
      const iterations = 100;

      for (var i = 0; i < iterations; i++) {
        final v = _randomInt(rng);
        final result = Success<int, String>(v);

        // (a) Value round-trip: the value stored is exactly the value passed in
        expect(
          result.value,
          equals(v),
          reason: 'iteration $i: Success($v).value must equal $v',
        );
      }
    });

    test('Failure(e).error == e for random String errors', () {
      final rng = Random(202);
      const iterations = 100;

      for (var i = 0; i < iterations; i++) {
        final e = _randomString(rng);
        final result = Failure<int, String>(e);

        // (b) Error round-trip: the error stored is exactly the error passed in
        expect(
          result.error,
          equals(e),
          reason: 'iteration $i: Failure("$e").error must equal "$e"',
        );
      }
    });

    test('Success is never dispatched to the Failure branch in an exhaustive switch', () {
      final rng = Random(303);
      const iterations = 100;

      for (var i = 0; i < iterations; i++) {
        final v = _randomInt(rng);
        final Result<int, String> result = Success<int, String>(v);

        // (c) Type dispatch correctness — Success must route to Success case only.
        // The switch is exhaustive (sealed class), so no 'default' is needed and
        // the compiler rejects any missing case at compile time.
        final branch = switch (result) {
          Success(:final value) => 'success:$value',
          Failure(:final error) => 'failure:$error',
        };

        expect(
          branch,
          startsWith('success:'),
          reason:
              'iteration $i: Success($v) must route to success branch, '
              'got: $branch',
        );

        // Also verify the value embedded in the branch string equals v
        expect(
          branch,
          equals('success:$v'),
          reason:
              'iteration $i: success branch value must embed $v',
        );
      }
    });

    test('Failure is never dispatched to the Success branch in an exhaustive switch', () {
      final rng = Random(404);
      const iterations = 100;

      for (var i = 0; i < iterations; i++) {
        final e = _randomString(rng);
        final Result<int, String> result = Failure<int, String>(e);

        // (c) Type dispatch correctness — Failure must route to Failure case only.
        final branch = switch (result) {
          Success(:final value) => 'success:$value',
          Failure(:final error) => 'failure:$error',
        };

        expect(
          branch,
          startsWith('failure:'),
          reason:
              'iteration $i: Failure("$e") must route to failure branch, '
              'got: $branch',
        );

        expect(
          branch,
          equals('failure:$e'),
          reason:
              'iteration $i: failure branch error must embed "$e"',
        );
      }
    });

    test('Success and Failure are distinct runtime types', () {
      // Type identity — a Success is never an instance of Failure
      final s = Success<int, String>(0);
      final f = Failure<int, String>('err');

      expect(s, isA<Success<int, String>>());
      expect(s, isNot(isA<Failure<int, String>>()));

      expect(f, isA<Failure<int, String>>());
      expect(f, isNot(isA<Success<int, String>>()));
    });

    test('Result<int, String> and Result<String, int> store independent values', () {
      // Both type parameters are independently preserved — no cross-contamination.
      final rng = Random(505);
      const iterations = 100;

      for (var i = 0; i < iterations; i++) {
        final intVal = _randomInt(rng);
        final strErr = _randomString(rng);

        // Success with int value
        final intSuccess = Success<int, String>(intVal);
        expect(intSuccess.value, equals(intVal));

        // Failure with String error using the int result type variant
        final strFailure = Failure<int, String>(strErr);
        expect(strFailure.error, equals(strErr));

        // Success<String, int> — flipped type params
        final strSuccess = Success<String, int>(strErr);
        expect(strSuccess.value, equals(strErr));
      }
    });
  });
}
