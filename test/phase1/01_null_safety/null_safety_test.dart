// Feature: phase-1-dart-language, Requirement 1: Null Safety
//
// Unit tests for null safety helper functions.
//
// Validates the behaviour of `??` (default value) and `??=`
// (assign-if-null) — the two most commonly used null-safety operators
// in production Dart code.
//
// Requirements covered: 1.4 (??), 1.6 (??=)
//
// HOW TO RUN:
//   flutter test test/phase1/01_null_safety/null_safety_test.dart

import 'package:flutter_test/flutter_test.dart';

// ─────────────────────────────────────────────
// Helper functions — mirror the demo's logic.
// These are pure functions: no I/O, no network, no side effects.
// ─────────────────────────────────────────────

/// Returns [name] if non-null, otherwise returns `'Anonymous'`.
///
/// Mirrors the demo's `??` section (Requirement 1.4).
String getDisplayName(String? name) => name ?? 'Anonymous';

/// Returns [port] if non-null, otherwise returns the [defaultPort].
///
/// Generic numeric variant — demonstrates `??` with non-string types.
int getServerPort(int? port, {int defaultPort = 8080}) =>
    port ?? defaultPort;

/// Assigns [value] to [target] only when [target] is null.
///
/// Returns the final value of [target] after the conditional assignment.
/// Mirrors the demo's `??=` section (Requirement 1.6).
String assignIfNull(String? target, String value) {
  target ??= value; // assigns only when target is null
  return target;
}

/// Demonstrates ??= idempotency: calling it twice on a non-null variable
/// must leave the original value unchanged.
///
/// Returns a record `(firstResult, secondResult)` so the test can verify
/// both values.
(String, String) doubleAssignIfNull(String? initial, String value) {
  initial ??= value; // first call — assigns if null
  final first = initial;
  initial ??= 'should never appear'; // second call — must NOT overwrite
  return (first, initial);
}

// ─────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────

void main() {
  group('Null Safety — ?? operator (Requirement 1.4)', () {
    // ── String variant ──────────────────────────────────────────────────

    test('returns default when input is null', () {
      // When the nullable argument IS null, ?? must return the right-hand side.
      const String? nullInput = null;
      expect(getDisplayName(nullInput), equals('Anonymous'));
    });

    test('returns original value when input is non-null', () {
      // When the nullable argument is non-null, ?? must return it unchanged.
      const String nonNullInput = 'Faisal Bahri';
      expect(getDisplayName(nonNullInput), equals('Faisal Bahri'));
    });

    test('returns original value even when it is an empty string', () {
      // Empty string is non-null — ?? must NOT replace it with the default.
      const String? emptyString = '';
      expect(getDisplayName(emptyString), equals(''));
    });

    // ── Numeric variant ──────────────────────────────────────────────────

    test('returns default port when port is null', () {
      expect(getServerPort(null), equals(8080));
    });

    test('returns provided port when port is non-null', () {
      expect(getServerPort(3000), equals(3000));
    });

    test('returns port 0 (non-null zero) without replacing with default', () {
      // Zero is a valid non-null integer — must not be treated as "missing".
      expect(getServerPort(0), equals(0));
    });
  });

  group('Null Safety — ??= operator (Requirement 1.6)', () {
    test('assigns value when target is null', () {
      // ??= must write the value when the variable is currently null.
      final result = assignIfNull(null, 'computed result');
      expect(result, equals('computed result'));
    });

    test('does NOT overwrite when target is already non-null', () {
      // ??= must leave the existing value intact.
      final result = assignIfNull('original', 'should be ignored');
      expect(result, equals('original'));
    });

    test('second ??= call never overwrites a value assigned by the first call',
        () {
      // After the first ??= assigns (because initial was null), the second
      // ??= must see a non-null target and skip the assignment entirely.
      final (first, second) = doubleAssignIfNull(null, 'first assignment');

      expect(first, equals('first assignment'),
          reason: 'first ??= should assign when target is null');
      expect(second, equals('first assignment'),
          reason: 'second ??= must not overwrite an already-assigned value');
    });

    test('second ??= call is a no-op when initial value was already non-null',
        () {
      // When the variable starts non-null, BOTH calls must leave it unchanged.
      final (first, second) = doubleAssignIfNull('preset', 'should be ignored');

      expect(first, equals('preset'));
      expect(second, equals('preset'));
    });
  });
}
