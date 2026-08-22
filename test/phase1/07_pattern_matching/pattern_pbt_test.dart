// ============================================================
// PHASE 1 — Pattern Matching & Sealed Class: Property-Based Tests
// ============================================================
// Feature: phase-1-dart-language, Property 9 / Property 10:
//   Validates Requirements 7.3, 10.5, 7.7
//
// Properties tested:
//   Property 9  — Type pattern dispatch routes to the correct sealed subtype (Req 7.3)
//   Property 10 — Record construction-then-destructuring is a round-trip (Req 10.5, 7.7)
//
// Approach: manual random generation with dart:math Random,
// seeded per test group for deterministic replays on failure.
// Each property runs a minimum of 100 iterations.
// ============================================================

import 'dart:math';

import 'package:belajar_1/phase1/07_pattern_matching/pattern_matching_demo.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Shape factory helpers ────────────────────────────────────

/// Returns a random [Circle] with radius in the range (0.1, 100.0].
Circle _randomCircle(Random rng) {
  // Keep radius > 0 to avoid degenerate shapes.
  return Circle(rng.nextDouble() * 99.9 + 0.1);
}

/// Returns a random [Rectangle] with width and height each in (0.1, 100.0].
Rectangle _randomRectangle(Random rng) {
  return Rectangle(
    rng.nextDouble() * 99.9 + 0.1,
    rng.nextDouble() * 99.9 + 0.1,
  );
}

/// Returns a random [Triangle] with base and height each in (0.1, 100.0].
Triangle _randomTriangle(Random rng) {
  return Triangle(
    rng.nextDouble() * 99.9 + 0.1,
    rng.nextDouble() * 99.9 + 0.1,
  );
}

/// Returns one of {Circle, Rectangle, Triangle} chosen uniformly at random.
Shape _randomShape(Random rng) {
  final selector = rng.nextInt(3);
  return switch (selector) {
    0 => _randomCircle(rng),
    1 => _randomRectangle(rng),
    _ => _randomTriangle(rng),
  };
}

// ── Record pair helpers ──────────────────────────────────────

/// Returns a random int in the range [-1000, 1000].
int _randomInt(Random rng) => rng.nextInt(2001) - 1000;

/// Returns a random printable ASCII string of length 0–20.
String _randomString(Random rng) {
  final length = rng.nextInt(21); // 0..20 chars
  // Use printable ASCII range 33–126 ('!' to '~') to avoid whitespace/control chars.
  return String.fromCharCodes(
    List.generate(length, (_) => rng.nextInt(94) + 33),
  );
}

// ── Property label helpers ───────────────────────────────────

/// Returns the name of the concrete type dispatched to by a switch expression.
/// This is the function under test for Property 9.
String _dispatchShape(Shape shape) => switch (shape) {
      Circle() => 'Circle',
      Rectangle() => 'Rectangle',
      Triangle() => 'Triangle',
    };

// ── Test suite ───────────────────────────────────────────────

void main() {
  // ──────────────────────────────────────────────────────────
  // Property 9 — Type pattern dispatch routes to the correct sealed subtype
  // ──────────────────────────────────────────────────────────
  // Feature: phase-1-dart-language, Property 9: Validates Requirements 7.3
  //
  // For every Shape instance (Circle, Rectangle, Triangle),
  // a switch expression with type patterns must route to exactly the case
  // matching the runtime type — no misrouting, no missing cases.
  //
  // The sealed class guarantee ensures exhaustiveness at compile time,
  // but we verify runtime routing behaviour across all three subtypes
  // with randomised inputs to confirm no subtype is silently aliased.
  // ──────────────────────────────────────────────────────────
  group('Property 9 — Type pattern dispatch routes to correct sealed subtype (Req 7.3)', () {
    // Feature: phase-1-dart-language, Property 9: Validates Requirements 7.3

    test('every Circle routes only to the Circle case', () {
      final rng = Random(9);
      const iterations = 100;

      for (var i = 0; i < iterations; i++) {
        final shape = _randomCircle(rng);
        final dispatched = _dispatchShape(shape);

        expect(
          dispatched,
          equals('Circle'),
          reason:
              'iteration $i: Circle(radius=${shape.radius}) must dispatch '
              'to "Circle", got "$dispatched"',
        );
      }
    });

    test('every Rectangle routes only to the Rectangle case', () {
      final rng = Random(91);
      const iterations = 100;

      for (var i = 0; i < iterations; i++) {
        final shape = _randomRectangle(rng);
        final dispatched = _dispatchShape(shape);

        expect(
          dispatched,
          equals('Rectangle'),
          reason:
              'iteration $i: Rectangle(${shape.width}×${shape.height}) must dispatch '
              'to "Rectangle", got "$dispatched"',
        );
      }
    });

    test('every Triangle routes only to the Triangle case', () {
      final rng = Random(92);
      const iterations = 100;

      for (var i = 0; i < iterations; i++) {
        final shape = _randomTriangle(rng);
        final dispatched = _dispatchShape(shape);

        expect(
          dispatched,
          equals('Triangle'),
          reason:
              'iteration $i: Triangle(base=${shape.base}, h=${shape.height}) must dispatch '
              'to "Triangle", got "$dispatched"',
        );
      }
    });

    test('mixed random shapes always route to their own type (100+ iterations)', () {
      // This test generates all three subtypes in random order, ensuring no
      // cross-subtype misrouting can hide among a single-type test run.
      final rng = Random(93);
      const iterations = 300; // 100 per subtype on average

      for (var i = 0; i < iterations; i++) {
        final shape = _randomShape(rng);

        // Ground truth: Dart's own runtimeType property.
        final expectedLabel = shape.runtimeType.toString();
        final dispatched = _dispatchShape(shape);

        expect(
          dispatched,
          equals(expectedLabel),
          reason:
              'iteration $i: shape of type $expectedLabel dispatched to "$dispatched"',
        );
      }
    });

    test('dispatch result is stable — same shape dispatches to the same case twice', () {
      // Verifies that dispatch is deterministic (no randomness inside the switch).
      final rng = Random(94);
      const iterations = 100;

      for (var i = 0; i < iterations; i++) {
        final shape = _randomShape(rng);
        final first = _dispatchShape(shape);
        final second = _dispatchShape(shape);

        expect(
          second,
          equals(first),
          reason:
              'iteration $i: dispatching the same shape twice must return '
              'the same label',
        );
      }
    });

    test('field destructuring inside type pattern extracts correct values', () {
      // Verifies that the type pattern not only routes to the right case
      // but also destructures field values correctly.
      final rng = Random(95);
      const iterations = 100;

      for (var i = 0; i < iterations; i++) {
        final shape = _randomShape(rng);

        // Extract a numeric "signature" from each shape using type patterns
        // with field destructuring — then verify against direct field access.
        final extractedSignature = switch (shape) {
          // :var radius shorthand binds the `radius` field directly.
          Circle(:var radius) => radius,
          Rectangle(:var width, :var height) => width + height,
          Triangle(:var base, :var height) => base + height,
        };

        // Compute the same signature directly (without switch) as ground truth.
        final directSignature = switch (shape.runtimeType.toString()) {
          'Circle' => (shape as Circle).radius,
          'Rectangle' => (shape as Rectangle).width + (shape as Rectangle).height,
          _ => (shape as Triangle).base + (shape as Triangle).height,
        };

        expect(
          extractedSignature,
          closeTo(directSignature, 1e-10),
          reason:
              'iteration $i: destructured fields must equal direct field access',
        );
      }
    });
  });

  // ──────────────────────────────────────────────────────────
  // Property 10 — Record construction-then-destructuring is a round-trip
  // ──────────────────────────────────────────────────────────
  // Feature: phase-1-dart-language, Property 10: Validates Requirements 10.5, 7.7
  //
  // For any two values a: A and b: B,
  //   constructing r = (a, b) then destructuring var (x, y) = r
  //   must yield x == a and y == b.
  //
  // Same holds for named records:
  //   constructing r = (first: a, second: b) then accessing r.first
  //   must equal a.
  //
  // This is the identity (round-trip) property for the Record container.
  // ──────────────────────────────────────────────────────────
  group('Property 10 — Record round-trip: construct then destructure (Req 10.5, 7.7)', () {
    // Feature: phase-1-dart-language, Property 10: Validates Requirements 10.5, 7.7

    test('positional record (int, String) round-trip via var (x, y) = r', () {
      final rng = Random(10);
      const iterations = 100;

      for (var i = 0; i < iterations; i++) {
        final a = _randomInt(rng);
        final b = _randomString(rng);

        // Construct a positional record.
        final r = (a, b);

        // Destructure the record into separate variables.
        final (int x, String y) = r;

        expect(
          x,
          equals(a),
          reason:
              'iteration $i: first positional field must round-trip: '
              'a=$a, destructured x=$x',
        );
        expect(
          y,
          equals(b),
          reason:
              'iteration $i: second positional field must round-trip: '
              'b="$b", destructured y="$y"',
        );
      }
    });

    test('positional record fields accessed via .\$1 and .\$2 match originals', () {
      final rng = Random(101);
      const iterations = 100;

      for (var i = 0; i < iterations; i++) {
        final a = _randomInt(rng);
        final b = _randomString(rng);

        final r = (a, b);

        // Direct field access alternative to destructuring.
        expect(
          r.$1,
          equals(a),
          reason: 'iteration $i: r.\$1 must equal a=$a',
        );
        expect(
          r.$2,
          equals(b),
          reason: 'iteration $i: r.\$2 must equal b="$b"',
        );
      }
    });

    test('named record ({first: a, second: b}) round-trip via field access', () {
      final rng = Random(102);
      const iterations = 100;

      for (var i = 0; i < iterations; i++) {
        final a = _randomInt(rng);
        final b = _randomString(rng);

        // Construct a named record.
        final ({int first, String second}) r = (first: a, second: b);

        // Access by name — the canonical round-trip for named records.
        expect(
          r.first,
          equals(a),
          reason:
              'iteration $i: named field "first" must round-trip: '
              'a=$a, r.first=${r.first}',
        );
        expect(
          r.second,
          equals(b),
          reason:
              'iteration $i: named field "second" must round-trip: '
              'b="$b", r.second="${r.second}"',
        );
      }
    });

    test('named record destructuring in switch pattern round-trips fields', () {
      // Validates that named records can be destructured inside a switch,
      // which is the pattern-matching form mentioned in Requirement 7.7.
      final rng = Random(103);
      const iterations = 100;

      for (var i = 0; i < iterations; i++) {
        final a = _randomInt(rng);
        final b = _randomString(rng);

        final r = (first: a, second: b);

        // Destructure named record inside a switch expression.
        final (int extractedA, String extractedB) = switch (r) {
          // Named field pattern: `:var fieldName` extracts r.fieldName.
          (first: var fa, second: var fb) => (fa, fb),
        };

        expect(
          extractedA,
          equals(a),
          reason:
              'iteration $i: switch-destructured "first" must equal a=$a',
        );
        expect(
          extractedB,
          equals(b),
          reason:
              'iteration $i: switch-destructured "second" must equal b="$b"',
        );
      }
    });

    test('positional record equality: two records with same values are equal', () {
      // Records in Dart have structural (value) equality — two records
      // with the same fields and values are == regardless of identity.
      final rng = Random(104);
      const iterations = 100;

      for (var i = 0; i < iterations; i++) {
        final a = _randomInt(rng);
        final b = _randomString(rng);

        final r1 = (a, b);
        final r2 = (a, b); // different object, same values

        expect(
          r1,
          equals(r2),
          reason:
              'iteration $i: records with identical values must be equal',
        );
      }
    });

    test('positional record inequality: different values produce unequal records', () {
      final rng = Random(105);
      const iterations = 100;

      for (var i = 0; i < iterations; i++) {
        // Generate two distinct integers.
        final a = _randomInt(rng);
        var b = _randomInt(rng);
        // Ensure b != a to guarantee the records differ.
        if (b == a) b = a + 1;

        final r1 = (a, 'same');
        final r2 = (b, 'same');

        expect(
          r1,
          isNot(equals(r2)),
          reason:
              'iteration $i: records with different first fields must not be equal '
              'r1=($a, "same"), r2=($b, "same")',
        );
      }
    });

    test('nested record round-trip preserves inner record values', () {
      // Edge case: a record whose second field is itself a String
      // produced by converting an int — verifies no type coercion occurs.
      final rng = Random(106);
      const iterations = 100;

      for (var i = 0; i < iterations; i++) {
        final n = _randomInt(rng);
        final label = 'item-$n'; // deterministic string derived from n

        final r = (n, label);
        final (int extractedN, String extractedLabel) = r;

        expect(extractedN, equals(n));
        expect(extractedLabel, equals('item-$n'));
        expect(extractedLabel, equals(label));
      }
    });
  });
}
