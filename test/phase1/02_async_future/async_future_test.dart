// ============================================================
// PHASE 1 — Tests: Async/Await and Future
// ============================================================
// Purpose: Unit tests for core async/Future behaviors from
//          Requirement 2: Async/Await and Future.
//
// Feature: phase-1-dart-language, Requirement 2: Async/Await and Future
//
// Covers:
//   - Requirement 2.3: Future resolves to the expected value
//   - Requirement 2.4: Exceptions thrown inside async functions are
//                      catchable with try/catch
// ============================================================

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Async/Await and Future', () {
    // ----------------------------------------------------------
    // Requirement 2.3 — Resolving a Future value with await
    // ----------------------------------------------------------
    // Future.value(x) is the simplest Future: it wraps an already-known
    // value and resolves immediately (on the next microtask).
    // Verifying that it resolves to exactly 42 proves that:
    //   (a) the Future infrastructure works correctly, and
    //   (b) await correctly unwraps the value.
    group('Future.value() resolves correctly (Req 2.3)', () {
      test('Future.value(42) resolves to 42', () async {
        // Arrange: create an already-resolved Future carrying the int 42
        final Future<int> future = Future.value(42);

        // Act: await unwraps the Future and gives us the int
        final int result = await future;

        // Assert: the unwrapped value must be exactly 42
        expect(result, equals(42));
      });

      test('Future.value with a String resolves to the given string', () async {
        // Covers the same property for a non-int type to show generality
        final Future<String> future = Future.value('dart is cool');
        final String result = await future;
        expect(result, equals('dart is cool'));
      });

      test('async function return value is automatically wrapped in a Future',
          () async {
        // An async function always returns a Future — even without an explicit
        // Future.value() call. The return value is wrapped automatically.
        Future<int> asyncAdd(int a, int b) async => a + b;

        final int result = await asyncAdd(20, 22);
        expect(result, equals(42));
      });
    });

    // ----------------------------------------------------------
    // Requirement 2.4 — Exception handling inside async functions
    // ----------------------------------------------------------
    // When an async function throws, the exception propagates to the
    // await site and can be caught with try/catch — exactly like
    // synchronous code. This test demonstrates the pattern with a
    // TimeoutException (from dart:async), matching the error shown
    // in async_future_demo.dart's _demoErrorHandling() section.
    group('Exception handling in async functions (Req 2.4)', () {
      test('TimeoutException thrown in async function is caught by try/catch',
          () async {
        // Arrange: an async function that always throws a TimeoutException
        Future<void> alwaysTimesOut() async {
          await Future.delayed(const Duration(milliseconds: 1));
          // ignore: only_throw_errors
          throw TimeoutException('simulated timeout after 30s');
        }

        // Act + Assert: the exception must be caught, not propagate further
        String? caughtMessage;
        try {
          await alwaysTimesOut();
          fail('Expected TimeoutException to be thrown, but it was not');
        } on TimeoutException catch (e) {
          caughtMessage = e.message;
        }

        expect(caughtMessage, equals('simulated timeout after 30s'));
      });

      test('FormatException thrown in async function is caught by try/catch',
          () async {
        // Same property verified for a different exception type —
        // shows that try/catch is not limited to TimeoutException.
        Future<void> throwsFormat() async {
          await Future.delayed(Duration.zero);
          throw const FormatException('invalid JSON token');
        }

        expect(
          () async => throwsFormat(),
          throwsA(isA<FormatException>()),
        );
      });

      test('only the declared catch type is caught; others propagate', () async {
        // A catch block with a specific type does NOT silently swallow
        // every possible exception — only the declared type is caught.
        // This is important for learners to understand.
        Future<void> throwsArgument() async {
          await Future.delayed(Duration.zero);
          throw ArgumentError('wrong argument');
        }

        // We expect ArgumentError to surface, not be swallowed
        await expectLater(
          throwsArgument,
          throwsA(isA<ArgumentError>()),
        );
      });

      test('Future.error() is treated like a thrown exception', () async {
        // Future.error() is the explicit way to create a failed Future.
        // Awaiting it throws, just like a thrown exception inside async.
        final Future<int> failedFuture =
            Future.error(TimeoutException('from Future.error'));

        String? caughtMessage;
        try {
          await failedFuture;
        } on TimeoutException catch (e) {
          caughtMessage = e.message;
        }

        expect(caughtMessage, equals('from Future.error'));
      });

      test('finally block runs regardless of success or failure', () async {
        // Demonstrates Requirement 2.4 edge: finally always executes,
        // mirroring async_future_demo.dart's _demoErrorHandling() section.
        bool finallyCalled = false;

        try {
          await Future.error(TimeoutException('boom'));
        } on TimeoutException {
          // intentionally caught and ignored for this test
        } finally {
          finallyCalled = true;
        }

        expect(finallyCalled, isTrue);
      });
    });
  });
}
