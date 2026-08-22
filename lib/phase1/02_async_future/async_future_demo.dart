// ============================================================
// PHASE 1 — Async/Await and Future
// ============================================================
// Purpose: Demonstrates Dart's asynchronous programming model using
//          Future, async/await, error handling, parallel execution,
//          and method chaining.
//
// Feature: phase-1-dart-language, Requirement 2: Async/Await and Future
//
// Run with: dart run lib/phase1/02_async_future/async_future_demo.dart
// Prerequisites: Phase 0 complete (especially Error Handling)
// Dart SDK: >= 3.0.0
//
// Key concept:
//   A Future<T> is a placeholder for a value that isn't available yet.
//   It is Dart's equivalent of a Promise in JavaScript. The async/await
//   syntax makes asynchronous code look and read like synchronous code.
// ============================================================

import 'dart:async';

/// The [Stopwatch] used across all sections to show [+Xms] timestamps.
/// Started at the very beginning of [main] so all timestamps are
/// relative to program launch.
late Stopwatch _sw;

/// Returns a formatted timestamp string like [+42ms] relative to when
/// the program started.
String get _ts => '[+${_sw.elapsedMilliseconds}ms]';

/// Entry point. Must be [async] so we can [await] each demo section
/// sequentially from the top level.
Future<void> main() async {
  _sw = Stopwatch()..start();

  print('=== Async/Await & Future Demo ===\n');

  _demoCreatingFutures();
  await _demoAwaitKeyword();
  await _demoErrorHandling();
  await _demoFutureWait();
  await _demoMethodChaining();
  await _demoSyncVsAsync();

  print('\n=== Demo complete. ===');
}

// ============================================================
// SECTION 1: Creating Futures
// ============================================================
// There are three common ways to create a Future:
//   1. Future.value()   — already-resolved future with a known value
//   2. Future.delayed() — resolves after a Duration
//   3. async function   — any function marked async returns a Future

/// Demonstrates the three ways to create a Future.
/// This section is synchronous — it just shows construction, not awaiting.
void _demoCreatingFutures() {
  print('--- Creating Futures ---');

  // 1. Future.value() — wraps an already-known value in a Future.
  //    Useful when you need to return a Future<T> from an interface
  //    but you already have the value synchronously.
  final Future<int> immediateValue = Future.value(42);
  print('Future.value(42) created: $immediateValue');

  // 2. Future.delayed() — resolves after a given duration.
  //    This is the async equivalent of a sleep/timer.
  final Future<String> delayedValue = Future.delayed(
    const Duration(milliseconds: 100),
    () => 'I arrived late!',
  );
  print('Future.delayed(100ms) created: $delayedValue');

  // 3. An async function always returns a Future — even if no await
  //    is used inside. The return value is automatically wrapped.
  Future<double> computeCircleArea(double radius) async {
    return 3.14159 * radius * radius;
  }

  final Future<double> areaFuture = computeCircleArea(5.0);
  print('async fn returned Future: $areaFuture');

  print(''); // blank line between sections
}

// ============================================================
// SECTION 2: Await Keyword — Sequential Execution
// ============================================================
// The [await] keyword pauses the current async function until the
// Future resolves. Crucially, it does NOT block the Dart event loop
// — other events can still run while waiting.
//
// Sequential awaits prove that order is preserved even with delays.

/// Demonstrates that [await] preserves execution order.
///
/// Despite using delays, Step 1 always prints before Step 2,
/// which always prints before Step 3.
Future<void> _demoAwaitKeyword() async {
  print('--- Await: Sequential Execution ---');
  print('$_ts Starting sequential steps...');

  // Step 1: fetch a simulated user ID (50ms delay)
  final userId = await _simulateFetch('userId', 50, 'user_123');
  print('$_ts Step 1 resolved: userId = $userId');

  // Step 2: fetch profile based on userId (80ms delay)
  // The fact that we have userId here PROVES sequential ordering worked:
  // we couldn't reference it if Step 1 hadn't completed first.
  final profile = await _simulateFetch('profile', 80, 'Alice (id: $userId)');
  print('$_ts Step 2 resolved: profile = $profile');

  // Step 3: fetch preferences (30ms delay)
  final prefs = await _simulateFetch('preferences', 30, 'darkMode=true');
  print('$_ts Step 3 resolved: prefs = $prefs');

  print('$_ts All steps done — total runtime reflects 50+80+30=160ms minimum\n');
}

// ============================================================
// SECTION 3: Error Handling with try/catch
// ============================================================
// Futures can fail. When they do, the error is thrown at the [await]
// site and can be caught with a standard try/catch block — exactly
// the same as synchronous error handling from Phase 0.

/// Demonstrates catching errors from failed Futures.
Future<void> _demoErrorHandling() async {
  print('--- Error Handling with try/catch ---');

  // Happy path — Future resolves successfully
  try {
    final result = await _simulateFetch('data', 20, 'success_value');
    print('$_ts Happy path: result = $result');
  } on Exception catch (e) {
    print('$_ts Should not reach here: $e');
  }

  // Error path — Future rejects with an exception
  try {
    await _simulateFailure('Network timeout after 30s');
    print('$_ts Should not reach here');
  } on TimeoutException catch (e) {
    // Catching a specific exception type first (most specific wins)
    print('$_ts Caught TimeoutException: ${e.message}');
  } on Exception catch (e) {
    print('$_ts Caught generic Exception: $e');
  }

  // FormatException — a different error type to show type-specific catch
  try {
    await _simulateFormatError();
    print('$_ts Should not reach here');
  } on FormatException catch (e) {
    print('$_ts Caught FormatException: ${e.message}');
  } finally {
    // finally always runs, whether or not an error occurred
    print('$_ts finally block ran (cleanup goes here)');
  }

  // ----------------------------------------------------------------
  // UNHANDLED EXCEPTION (commented out — would terminate the program)
  // ----------------------------------------------------------------
  // If you DON'T wrap an awaited Future in try/catch, and it throws,
  // the exception propagates up the call stack. If no caller catches
  // it, the program terminates with an Unhandled Exception error.
  //
  // Example (do NOT run this without a try/catch):
  //
  //   await _simulateFailure('boom'); // throws, no catch → program dies
  //
  // In Flutter, unhandled Future errors are reported to FlutterError.onError.
  // In CLI Dart, they crash the process.
  // ----------------------------------------------------------------

  print('');
}

// ============================================================
// SECTION 4: Future.wait — Parallel Execution
// ============================================================
// Sequential awaits run one after another. If the operations are
// independent, that wastes time. Future.wait() launches all Futures
// concurrently and waits for ALL of them to complete.
//
// The timestamp comparison proves parallel execution:
//   Sequential:  50 + 80 + 30 = 160ms minimum
//   Parallel:    max(50, 80, 30) = 80ms minimum

/// Demonstrates parallel execution with [Future.wait].
///
/// Timestamps prove that independent operations run concurrently,
/// not one after another.
Future<void> _demoFutureWait() async {
  print('--- Future.wait: Parallel Execution ---');

  // --- Sequential approach (for comparison) ---
  final seqStart = _sw.elapsedMilliseconds;

  final r1 = await _simulateFetch('userSeq', 50, 'user_A');
  final r2 = await _simulateFetch('orderSeq', 80, 'order_99');
  final r3 = await _simulateFetch('cartSeq', 30, 'cart_5');

  final seqDuration = _sw.elapsedMilliseconds - seqStart;
  print('$_ts Sequential: got $r1, $r2, $r3 in ~${seqDuration}ms');

  // --- Parallel approach with Future.wait ---
  final parStart = _sw.elapsedMilliseconds;

  // All three Futures are created BEFORE any await — they start immediately.
  final results = await Future.wait([
    _simulateFetch('userPar', 50, 'user_A'),
    _simulateFetch('orderPar', 80, 'order_99'),
    _simulateFetch('cartPar', 30, 'cart_5'),
  ]);

  final parDuration = _sw.elapsedMilliseconds - parStart;
  // results is a List<String>, ordered to match the input list
  print(
    '$_ts Parallel: got ${results[0]}, ${results[1]}, ${results[2]} '
    'in ~${parDuration}ms',
  );
  print(
    '$_ts Speedup: sequential ~${seqDuration}ms vs parallel ~${parDuration}ms '
    '(expect ~2x faster)\n',
  );

  // Future.wait with error handling — if ANY future throws, Future.wait
  // throws too. Use a try/catch around the whole await.
  try {
    await Future.wait([
      _simulateFetch('ok1', 20, 'value1'),
      _simulateFailure('one of the parallel ops failed'),
      _simulateFetch('ok2', 20, 'value2'),
    ]);
  } on TimeoutException catch (e) {
    print('$_ts Future.wait caught failure: ${e.message}');
  }

  print('');
}

// ============================================================
// SECTION 5: Method Chaining — .then() / .catchError() / .whenComplete()
// ============================================================
// Before async/await syntax, Futures were handled with callback chains.
// You may still encounter this style in older Dart code or third-party
// libraries. Understanding it helps you read and maintain legacy code.
//
//   .then(onValue)          — called when Future resolves successfully
//   .catchError(onError)    — called when Future throws (like catch)
//   .whenComplete(callback) — called regardless of success/failure (like finally)

/// Demonstrates the older Future callback-chain style.
Future<void> _demoMethodChaining() async {
  print('--- Method Chaining: .then/.catchError/.whenComplete ---');

  // Successful chain — .then runs, .catchError is skipped, .whenComplete runs
  final Future<void> successChain = _simulateFetch('resource', 40, 'loaded!')
      .then((value) {
        print('$_ts .then: got "$value"');
      })
      .catchError((Object error) {
        print('$_ts .catchError: $error (should NOT print in happy path)');
      })
      .whenComplete(() {
        print('$_ts .whenComplete: always runs after then/catchError');
      });

  await successChain;

  // Failed chain — .then is skipped, .catchError runs, .whenComplete runs
  final Future<void> failedChain = _simulateFailure('intentional error')
      .then((_) {
        print('$_ts .then: should NOT print for error path');
      })
      .catchError((Object error) {
        print('$_ts .catchError: caught "$error"');
        // Return null (void) to recover from the error — chain continues
      })
      .whenComplete(() {
        print('$_ts .whenComplete: runs even after an error\n');
      });

  await failedChain;

  // NOTE: For new code, prefer async/await with try/catch/finally.
  //       It's more readable and easier to reason about than chained callbacks.
}

// ============================================================
// SECTION 6: Sync vs Async Timing
// ============================================================
// This section makes the non-blocking nature of Dart's event loop visible.
// Synchronous code runs first, then the event loop picks up resolved Futures.

/// Demonstrates how async scheduling interleaves with synchronous code.
///
/// The [+Xms] timestamps reveal that synchronous work happens
/// before any Future callback runs, even if the Future resolves "immediately".
Future<void> _demoSyncVsAsync() async {
  print('--- Sync vs Async Timing ---');
  print('$_ts [sync] Starting — registering two async operations');

  // These Futures are created now, but their callbacks run LATER —
  // after all current synchronous code in this function finishes.
  final f1 = Future.value('future_1_result').then((v) {
    print('$_ts [async] Future.value resolved: $v');
  });

  final f2 = Future.delayed(const Duration(milliseconds: 10), () {
    print('$_ts [async] Future.delayed(10ms) resolved');
  });

  print('$_ts [sync] Both futures registered — sync code continues...');
  print('$_ts [sync] Doing some synchronous work here...');
  print('$_ts [sync] Still synchronous — futures have NOT resolved yet');

  // Only after the await do we yield back to the event loop,
  // letting resolved Futures run their callbacks.
  await f1;
  await f2;

  print('$_ts [sync] All futures done — async work completed\n');

  // Expected output pattern:
  //   [+Xms] [sync] Starting...
  //   [+Xms] [sync] Both futures registered...
  //   [+Xms] [sync] Doing some synchronous work...
  //   [+Xms] [sync] Still synchronous...
  //   [+Xms] [async] Future.value resolved    ← runs after sync block ends
  //   [+Xms] [async] Future.delayed resolved  ← runs after 10ms
  //   [+Xms] [sync] All futures done
  //
  // This proves: Dart's event loop is non-blocking. Synchronous code
  // always runs to completion before any Future callback can execute.
}

// ============================================================
// PRIVATE HELPERS
// ============================================================

/// Simulates an async data-fetch operation with an artificial [delay].
///
/// In real apps, [delay] represents network latency, disk I/O, etc.
/// Returns [value] after [delay] milliseconds.
Future<String> _simulateFetch(String name, int delayMs, String value) {
  return Future.delayed(Duration(milliseconds: delayMs), () => value);
}

/// Simulates a failed Future that throws a [TimeoutException].
///
/// Used to demonstrate error handling — callers should wrap in try/catch.
Future<void> _simulateFailure(String message) {
  return Future.delayed(
    const Duration(milliseconds: 10),
    () => throw TimeoutException(message),
  );
}

/// Simulates a Future that throws a [FormatException].
Future<void> _simulateFormatError() {
  return Future.delayed(
    const Duration(milliseconds: 10),
    () => throw const FormatException('Invalid JSON: unexpected token'),
  );
}
