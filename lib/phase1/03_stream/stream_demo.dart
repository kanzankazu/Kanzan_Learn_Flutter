// ============================================================
// PHASE 1 — Stream
// ============================================================
// Purpose: Demonstrates Dart Streams — a sequence of async values
//          delivered one at a time. Streams are everywhere in Flutter:
//          user events, network responses, database updates, and more.
// Run with: dart run lib/phase1/03_stream/stream_demo.dart
// Prerequisites: Phase 0 complete + Phase 1 Topic 2 (Future/Async)
// Dart SDK: >= 3.0.0
// Feature: phase-1-dart-language, Requirement 3: Stream
// ============================================================

import 'dart:async';

/// Entry point — orchestrates all Stream demo sections.
Future<void> main() async {
  print('=== Stream Demo ===\n');

  await _demoCreatingStreams();
  await _demoAwaitForLoop();
  await _demoStreamTransformations();
  await _demoStreamController();
  _demoSingleVsBroadcast();
  await _demoStreamSubscription();

  print('\n=== Demo Complete ===');
}

// ============================================================
// SECTION 1: Creating Streams
// Three fundamental ways to create a Stream in Dart.
// ============================================================

/// Demonstrates three ways to create a Stream:
/// 1. [Stream.fromIterable] — converts an existing collection into a Stream
/// 2. [Stream.periodic] — emits values at a fixed interval
/// 3. An `async*` generator function — yields values programmatically
Future<void> _demoCreatingStreams() async {
  print('--- Creating Streams ---\n');

  // ── Method 1: Stream.fromIterable ────────────────────────
  // Converts a synchronous Iterable into an async Stream.
  // Each element is emitted as a separate async event.
  final iterableStream = Stream.fromIterable([10, 20, 30, 40, 50]);
  print('Stream.fromIterable → collecting values:');
  final iterableValues = await iterableStream.toList();
  print('  Values: $iterableValues\n');

  // ── Method 2: Stream.periodic + .take(5) ─────────────────
  // Stream.periodic emits an event every [period] duration.
  // Without .take(N) this would run FOREVER — always pair periodic with take().
  //
  // Flutter pattern: This is exactly how you poll an API at intervals
  // (e.g., "refresh data every 30 seconds, for at most 10 times"):
  //   Stream.periodic(Duration(seconds: 30), (_) => fetchData()).take(10)
  //
  // The callback receives a zero-based count; here we multiply by 100 to
  // produce [0, 100, 200, 300, 400] — a simple incrementing series.
  final periodicStream = Stream.periodic(
    const Duration(milliseconds: 50), // short interval for demo purposes
    (count) => count * 100,
  ).take(5); // REQUIRED: limits to 5 emissions; omitting this = infinite loop

  print('Stream.periodic (50ms interval, take 5) → values:');
  final periodicValues = await periodicStream.toList();
  print('  Values: $periodicValues\n');

  // ── Method 3: async* generator ───────────────────────────
  // An `async*` function is a generator that produces a Stream.
  // Use `yield` to emit values one at a time.
  // This is powerful because you can use loops, conditions, and awaits
  // inside the generator — something impossible with fromIterable.
  print('async* generator → yielding 3 values:');
  await for (final value in _countdownGenerator(3)) {
    print('  Yielded: $value');
  }
  print('');
}

/// An `async*` generator that counts down from [start] to 1.
///
/// `async*` marks this as a Stream-returning generator.
/// Each `yield` emits one value to the stream.
/// The function body can contain awaits — useful for async operations
/// between yields (e.g., fetch items from an API page by page).
Stream<String> _countdownGenerator(int start) async* {
  for (int i = start; i >= 1; i--) {
    // Simulating some async work between yields
    await Future.delayed(const Duration(milliseconds: 10));
    yield 'Countdown: $i';
  }
  yield 'GO!'; // final value after the loop
}

// ============================================================
// SECTION 2: Consuming Streams with await for
// ============================================================

/// Demonstrates consuming a Stream using an `await for` loop.
///
/// `await for` is the idiomatic way to process Stream values sequentially.
/// It suspends the loop body between each event, just like `await` on a Future.
/// The loop exits automatically when the stream closes (emits a done event).
Future<void> _demoAwaitForLoop() async {
  print('--- await for Loop ---\n');

  // A stream of 5 strings
  final messageStream = Stream.fromIterable([
    'Hello',
    'from',
    'a',
    'Dart',
    'Stream!',
  ]);

  print('Consuming stream with await for:');
  // Each iteration receives one value from the stream.
  // Execution suspends here until the next value arrives.
  await for (final word in messageStream) {
    print('  Received: $word');
  }

  // Once the stream closes, execution continues here.
  print('  Stream closed — loop finished.\n');
}

// ============================================================
// SECTION 3: Stream Transformations
// Streams support functional-style chaining, similar to collections.
// ============================================================

/// Demonstrates Stream transformation operators:
/// - `.map()` — transform each value
/// - `.where()` — filter values based on a predicate
/// - `.take(N)` — keep only the first N values
/// - `.skip(N)` — discard the first N values
Future<void> _demoStreamTransformations() async {
  print('--- Stream Transformations ---\n');

  // Source stream: integers 1 through 10
  final source = Stream.fromIterable(List.generate(10, (i) => i + 1));

  // ── .map() ───────────────────────────────────────────────
  // Transforms every emitted value. Returns a new Stream<U>.
  // This is the async equivalent of List.map().
  final mappedStream = Stream.fromIterable([1, 2, 3, 4, 5])
      .map((n) => 'item_$n'); // int → String

  print('.map() — int → String:');
  await for (final s in mappedStream) {
    print('  $s');
  }
  print('');

  // ── .where() ─────────────────────────────────────────────
  // Filters values: only values where the predicate returns true pass through.
  // Values that don't match are silently discarded.
  final evenStream = Stream.fromIterable(List.generate(10, (i) => i + 1))
      .where((n) => n.isEven); // keep only even numbers

  print('.where() — even numbers only from 1–10:');
  final evenValues = await evenStream.toList();
  print('  $evenValues\n');

  // ── .take(N) ─────────────────────────────────────────────
  // Emits at most N values, then closes the stream automatically.
  // Useful when you only need the first N events from a potentially
  // infinite or very large stream.
  final firstThree = source.take(3);

  print('.take(3) — first 3 from 1–10:');
  print('  ${await firstThree.toList()}\n');

  // ── .skip(N) ─────────────────────────────────────────────
  // Discards the first N values, then emits the rest normally.
  final skipTwo = Stream.fromIterable(List.generate(10, (i) => i + 1)).skip(7);

  print('.skip(7) — values after skipping first 7 from 1–10:');
  print('  ${await skipTwo.toList()}\n');

  // ── Chained transformations ───────────────────────────────
  // Like collection operations, Stream transforms can be chained.
  final chained = Stream.fromIterable(List.generate(20, (i) => i + 1))
      .where((n) => n % 3 == 0) // multiples of 3
      .map((n) => n * n) // square them
      .take(4); // first 4 results

  print('Chained: .where(÷3).map(square).take(4) on 1–20:');
  print('  ${await chained.toList()}\n');
}

// ============================================================
// SECTION 4: StreamController — Manual Push
// Use StreamController when you control when values are emitted.
// ============================================================

/// Demonstrates [StreamController] for creating a fully custom Stream.
///
/// Use StreamController when:
/// - Values are produced by callbacks or event handlers (not by iteration)
/// - You need to push values from outside the stream itself
/// - You're bridging a callback-based API to a Stream-based one
Future<void> _demoStreamController() async {
  print('--- StreamController ---\n');

  // Create a StreamController for integers.
  // StreamController<T> exposes a .stream (the consumer side)
  // and a .sink / .add() method (the producer side).
  final controller = StreamController<int>();

  // Collect all values emitted into a list for display
  final received = <int>[];
  final completer = Completer<void>();

  // Start listening BEFORE pushing any values
  controller.stream.listen(
    (value) {
      received.add(value);
      print('  Controller emitted: $value');
    },
    onDone: () {
      print('  Controller stream closed.');
      completer.complete();
    },
  );

  // Push 3 values manually via .add()
  controller.add(100);
  controller.add(200);
  controller.add(300);

  // ⚠️  MEMORY LEAK WARNING ──────────────────────────────────
  // Always call controller.close() when you are done pushing values.
  //
  // NOT calling close() means:
  //   1. The stream never emits the "done" event.
  //   2. The listener's onDone callback never fires.
  //   3. The StreamController (and its internal buffer) stays alive in memory.
  //   4. In Flutter, this is a common source of memory leaks — especially
  //      when controllers are created in State objects but never closed in
  //      dispose().
  //
  // Rule of thumb: every StreamController.add() sequence ends with close().
  // In Flutter State: create in initState(), close in dispose().
  controller.close();

  // Wait for the stream to finish processing
  await completer.future;
  print('  All received: $received\n');
}

// ============================================================
// SECTION 5: Single-subscription vs Broadcast Streams
// ============================================================

/// Explains the two Stream subscription modes in Dart.
///
/// This section is intentionally comment-heavy — the key insight is
/// architectural, not something you can see from output alone.
void _demoSingleVsBroadcast() {
  print('--- Single-subscription vs Broadcast ---\n');

  // ── Single-subscription Stream (the default) ─────────────────────────────
  //
  // A single-subscription Stream can only have ONE listener at a time.
  // This is the default mode for ALL Streams created with:
  //   - Stream.fromIterable()
  //   - Stream.periodic()
  //   - async* generators
  //   - StreamController() (default)
  //
  // If you try to listen to a single-subscription Stream a second time,
  // Dart throws: StateError: Stream has already been listened to.
  //
  // This happens because single-subscription streams:
  //   1. Buffer values until a listener subscribes
  //   2. Pause/resume based on the single listener's back-pressure
  //   3. Clean up resources when the listener cancels
  //
  // Attempting double-listen (DO NOT uncomment — throws StateError):
  // ─────────────────────────────────────────────────────────────────
  // final singleStream = Stream.fromIterable([1, 2, 3]);
  // singleStream.listen((v) => print('Listener 1: $v'));
  // singleStream.listen((v) => print('Listener 2: $v')); // ← StateError!
  // ─────────────────────────────────────────────────────────────────
  //
  // To fix a double-listen error: convert to a Broadcast Stream first.
  // Use .asBroadcastStream() to get a stream any number of listeners
  // can subscribe to:
  //
  //   final broadcastStream = singleStream.asBroadcastStream();
  //   broadcastStream.listen((v) => print('Listener 1: $v'));
  //   broadcastStream.listen((v) => print('Listener 2: $v')); // ✓ OK
  //
  // ── Broadcast Stream ──────────────────────────────────────────────────────
  //
  // A broadcast Stream supports MULTIPLE simultaneous listeners.
  // Key differences vs single-subscription:
  //   1. Values are NOT buffered — late subscribers miss past events
  //   2. No back-pressure — producer doesn't wait for slow listeners
  //   3. Suitable for: UI event streams, mouse clicks, keyboard input,
  //      Firebase snapshot streams, BLoC event streams in Flutter
  //
  // Create a broadcast StreamController explicitly:
  //   final controller = StreamController<int>.broadcast();
  //
  // ── Summary ───────────────────────────────────────────────────────────────
  //
  //   | Feature               | Single-subscription | Broadcast        |
  //   |-----------------------|---------------------|------------------|
  //   | Max listeners         | 1                   | unlimited        |
  //   | Buffers missed events | Yes (until listened)| No               |
  //   | Back-pressure support | Yes                 | No               |
  //   | Use case              | File I/O, HTTP body  | UI events, BLoC  |
  //   | Convert to other      | .asBroadcastStream()| (not reversible) |

  print('  [See comments in source code for Single vs Broadcast explanation]\n');
  print('  Key rule: single-subscription = 1 listener max.');
  print('  Double-listen throws StateError — use .asBroadcastStream() to fix.\n');
}

// ============================================================
// SECTION 6: StreamSubscription with callbacks
// ============================================================

/// Demonstrates [StreamSubscription] — the object returned by `.listen()`.
///
/// StreamSubscription gives you explicit control over the lifecycle of
/// listening to a stream:
/// - `onData`: called for each value
/// - `onError`: called when an error is emitted (without crashing)
/// - `onDone`: called exactly once when the stream closes
/// - `cancel()`: unsubscribe early (important for preventing memory leaks)
/// - `pause()` / `resume()`: back-pressure control
Future<void> _demoStreamSubscription() async {
  print('--- StreamSubscription ---\n');

  // A stream that emits some values and then an error, then more values.
  // StreamController lets us manually control what gets emitted.
  final controller = StreamController<int>();
  final completer = Completer<void>();

  // .listen() returns a StreamSubscription object.
  // Store it if you need to cancel, pause, or resume later.
  final StreamSubscription<int> subscription = controller.stream.listen(
    // onData: called for each successfully emitted value
    (value) {
      print('  onData   → received: $value');
    },
    // onError: called when an error is added to the stream.
    // Without this handler, errors propagate as unhandled exceptions.
    // The stream continues after onError unless cancelOnError is true.
    onError: (Object error, StackTrace stackTrace) {
      print('  onError  → caught: $error');
    },
    // onDone: called exactly once when the stream closes (controller.close()).
    // This is the verifiable "stream finished" signal.
    // In Flutter, use this to clean up UI state after an async operation finishes.
    onDone: () {
      print('  onDone   → [VERIFIED] Stream completed successfully!');
      completer.complete();
    },
    // cancelOnError: false (default) means the subscription continues
    // after an error. Set to true to auto-cancel on first error.
    cancelOnError: false,
  );

  // Emit a sequence of values and an error to exercise all callbacks
  controller.add(1);
  controller.add(2);
  controller.addError('Oops! Something went wrong'); // triggers onError
  controller.add(3);
  controller.close(); // triggers onDone

  // Wait for onDone to fire before continuing
  await completer.future;

  // Demonstrating subscription management:
  // subscription.pause()  → temporarily stops receiving events
  // subscription.resume() → resumes after pause
  // subscription.cancel() → permanently unsubscribes (call in Flutter dispose())
  //
  // The subscription is already done here since the stream closed,
  // but calling cancel() on a completed subscription is always safe.
  await subscription.cancel();
  print('\n  Subscription cancelled (safe even after stream closes).');
  print('  In Flutter: always cancel subscriptions in State.dispose().\n');
}
