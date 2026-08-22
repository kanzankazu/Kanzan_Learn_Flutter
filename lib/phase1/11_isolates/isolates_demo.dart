// ============================================================
// PHASE 1 — Isolates (Intro)
// ============================================================
// Purpose: Demonstrates how Dart Isolates enable true parallelism
//          without shared memory, and when to use them in Flutter.
//
// Run with:
//   dart run lib/phase1/11_isolates/isolates_demo.dart
//
// Prerequisites: Phase 1 — Async/Await, Future, Stream
// Dart SDK: >= 2.19.0 (Isolate.run() API)
//
// Feature: phase-1-dart-language, Requirement 11: Isolates
// ============================================================
//
// ============================================================
// WHAT IS AN ISOLATE?
//
// Dart is single-threaded per isolate. "Isolate" is the term for
// Dart's unit of concurrency — similar to a thread in other languages,
// but with crucial differences:
//
// 1. OWN HEAP MEMORY
//    Every isolate has its own garbage-collected heap. Objects in
//    one isolate cannot be directly referenced from another isolate.
//    This eliminates an entire class of concurrency bugs (race conditions,
//    deadlocks) that plague shared-memory threading models.
//
// 2. NO SHARED MUTABLE STATE
//    Because heaps are separate, there is no shared mutable state
//    between isolates. You cannot do `sharedList.add(value)` from
//    another isolate — you must send a *message* instead.
//    Immutable objects (int, String, etc.) can be transferred without
//    copying; mutable objects are deep-copied on send.
//
// 3. COMMUNICATION VIA MESSAGE PASSING (SendPort / ReceivePort)
//    Isolates talk to each other exclusively through ports:
//      - ReceivePort: created in the receiving isolate; produces a Stream
//      - SendPort: obtained from a ReceivePort; used to send messages
//    Think of ReceivePort as a mailbox and SendPort as a mailing address.
//
// 4. WHEN TO USE ISOLATES IN FLUTTER
//    Async I/O (HTTP, file read/write) does NOT need an isolate — Dart's
//    event loop already handles it without blocking the UI thread.
//    Use isolates ONLY for CPU-heavy work that would block the event loop
//    for more than ~16ms (one frame at 60fps):
//      • Parsing large JSON / XML (> ~50KB)
//      • Image / video processing
//      • Cryptographic operations (hashing, encryption)
//      • Heavy mathematical computations (physics, ML inference)
//      • Sieve of Eratosthenes for large N — used as demo below
//
//    The practical rule: if `dart:io` await is enough, skip isolates.
//    If your function blocks the event loop > 16ms, move it to an isolate.
// ============================================================

import 'dart:async';
import 'dart:isolate';

// ============================================================
// TOP-LEVEL FUNCTIONS (required by Isolate.spawn)
//
// Functions passed to Isolate.spawn / Isolate.run must be TOP-LEVEL
// (or static class methods). They cannot be closures or instance methods
// because the new isolate has no access to the spawning isolate's heap,
// so there is no "this" to close over.
// ============================================================

/// Computes all prime numbers up to [limit] using the Sieve of Eratosthenes.
///
/// This is intentionally CPU-heavy at N=50000 to demonstrate measurable
/// timing differences between blocking and isolate execution.
///
/// Must be top-level so it can be passed to [Isolate.run] and [Isolate.spawn].
List<int> _computePrimesUpTo(int limit) {
  // Create a boolean sieve where index = candidate prime
  final sieve = List<bool>.filled(limit + 1, true);
  sieve[0] = false;
  if (limit >= 1) sieve[1] = false;

  // Mark composite numbers
  for (int i = 2; i * i <= limit; i++) {
    if (sieve[i]) {
      // Mark all multiples of i starting from i*i
      for (int j = i * i; j <= limit; j += i) {
        sieve[j] = false;
      }
    }
  }

  // Collect surviving primes
  return [
    for (int i = 2; i <= limit; i++)
      if (sieve[i]) i,
  ];
}

/// Entry point for the background isolate in the bidirectional demo.
///
/// Receives a [SendPort] from the main isolate, creates its own [ReceivePort],
/// sends its own [SendPort] back to the main isolate, then processes incoming
/// messages and replies to each one.
///
/// Must be top-level so it can be passed to [Isolate.spawn].
void _heavyComputation(SendPort mainSendPort) {
  // Step B1: Create a ReceivePort so main isolate can send messages back here
  final backgroundReceivePort = ReceivePort();

  // Step B2: Send our SendPort to the main isolate so it can reach us
  mainSendPort.send(backgroundReceivePort.sendPort);

  // Step B3: Listen for messages from main isolate and reply to each
  backgroundReceivePort.listen((message) {
    if (message is Map<String, dynamic>) {
      final int msgId = message['id'] as int;
      final String payload = message['data'] as String;
      final SendPort replyPort = message['replyPort'] as SendPort;

      print('  [Background] Received message $msgId: "$payload"');

      // Simulate some work proportional to message id
      final primeCount = _computePrimesUpTo(10000 + msgId * 1000).length;

      // Step B4: Send reply back to main isolate via the reply port
      replyPort.send({
        'id': msgId,
        'result': 'Processed "$payload" → found $primeCount primes',
      });
    } else if (message == 'DONE') {
      // Step B5: Main isolate signals no more messages — clean up
      print('  [Background] Received DONE signal, closing port.');
      backgroundReceivePort.close();
    }
  });
}

// ============================================================
// SECTION 1: Isolate.run() — Simple High-Level API
//
// Isolate.run() is the easiest way to offload a computation:
//   - Creates a fresh isolate
//   - Runs the provided callback
//   - Returns the result as a Future
//   - Automatically destroys the isolate when done
//
// Available since Dart 2.19. Prefer this over Isolate.spawn() for
// one-shot computations where you just want a result back.
// ============================================================
Future<void> _demoIsolateRun() async {
  print('\n--- Section 1: Isolate.run() ---');
  print('Offloading prime sieve (N=50000) to a background isolate...');

  final stopwatch = Stopwatch()..start();

  // Hand off the computation — Isolate.run() handles all the plumbing
  final primes = await Isolate.run(() => _computePrimesUpTo(50000));

  stopwatch.stop();
  print('Isolate.run() completed in ${stopwatch.elapsedMilliseconds}ms');
  print('Found ${primes.length} primes up to 50,000');
  print('Largest prime found: ${primes.last}');
}

// ============================================================
// SECTION 2: SendPort / ReceivePort — Bidirectional Communication
//
// For long-lived isolates that exchange multiple messages, use
// Isolate.spawn() + SendPort/ReceivePort manually.
//
// Message flow:
//   Main spawns isolate → passes its SendPort
//   Background sends back its own SendPort
//   Main sends messages; Background replies via reply ports
// ============================================================
Future<void> _demoBidirectional() async {
  print('\n--- Section 2: SendPort/ReceivePort (Bidirectional) ---');

  // Step M1: Create a ReceivePort on the main isolate side.
  // The background isolate will use this to send its own SendPort to us.
  final mainReceivePort = ReceivePort();

  // Step M2: Spawn the background isolate, passing our SendPort so it can
  // reach us. _heavyComputation must be a top-level function.
  print('Spawning background isolate...');
  final isolate = await Isolate.spawn(
    _heavyComputation,
    mainReceivePort.sendPort, // background will use this to send its port back
    debugName: 'HeavyComputationIsolate',
  );

  // Step M3: Wait for the background isolate to send back its own SendPort.
  // The first message on mainReceivePort is always the background's SendPort.
  final backgroundSendPort = await mainReceivePort.first as SendPort;
  print('Established bidirectional channel.');

  // Step M4: Create a fresh ReceivePort for each outgoing message (reply ports).
  // This pattern gives each request its own dedicated response channel.
  final messages = [
    'Hello from main isolate',
    'Compute primes please',
    'Final message before shutdown',
  ];

  for (int i = 0; i < messages.length; i++) {
    // Step M5: Create a one-shot reply port for this specific message
    final replyPort = ReceivePort();

    print('\n  [Main] Sending message ${i + 1}: "${messages[i]}"');

    // Step M6: Send message with id, payload, and a reply port so background
    // knows where to send the response
    backgroundSendPort.send({
      'id': i + 1,
      'data': messages[i],
      'replyPort': replyPort.sendPort,
    });

    // Step M7: Await the single reply on this port, then close it
    final reply = await replyPort.first as Map<String, dynamic>;
    print('  [Main] Got reply for message ${reply['id']}: "${reply['result']}"');
    replyPort.close();
  }

  // Step M8: Signal the background isolate that we're done so it can close its
  // ReceivePort and terminate cleanly (no memory leak)
  backgroundSendPort.send('DONE');

  // Step M9: Give background a moment to process the DONE signal, then kill it
  await Future.delayed(const Duration(milliseconds: 100));
  isolate.kill();
  print('\nBackground isolate terminated cleanly.');
}

// ============================================================
// SECTION 3: Blocking vs Isolate Timing Comparison
//
// This section runs the same computation (prime sieve N=30000) two ways:
//   1. Blocking: runs on the main isolate's event loop (blocks everything)
//   2. Isolate:  runs in a separate isolate (main loop stays free)
//
// In Flutter context, a blocking computation > 16ms (1 frame at 60fps)
// causes the UI to stutter. The isolate version keeps the UI thread free
// so frames can be rendered while computation runs in the background.
//
// The 16ms threshold comes from: 1000ms ÷ 60 frames ≈ 16.67ms per frame.
// Any synchronous work exceeding this budget drops frames and causes jank.
// ============================================================
Future<void> _demoTimingComparison() async {
  print('\n--- Section 3: Blocking vs Isolate Timing ---');
  print(
    'Rule: anything blocking the event loop > 16ms is a candidate for Isolate.',
  );
  print('Running prime sieve N=30,000 both ways...\n');

  // --- Blocking run (on main isolate) ---
  final blockingWatch = Stopwatch()..start();
  final blockingResult = _computePrimesUpTo(30000);
  blockingWatch.stop();
  final blockingMs = blockingWatch.elapsedMilliseconds;

  // --- Isolate run ---
  final isolateWatch = Stopwatch()..start();
  final isolateResult = await Isolate.run(() => _computePrimesUpTo(30000));
  isolateWatch.stop();
  final isolateMs = isolateWatch.elapsedMilliseconds;

  // Both should produce identical prime counts — just verifying correctness
  assert(blockingResult.length == isolateResult.length);

  // ⭐ Required output format: "Blocking: Xms, Isolate: Yms"
  print('Blocking: ${blockingMs}ms, Isolate: ${isolateMs}ms');
  print('Primes found: ${blockingResult.length}');

  // Contextual interpretation for the learner
  if (blockingMs > 16) {
    print(
      'ℹ️  Blocking run (${blockingMs}ms) exceeded the 16ms frame budget → would cause jank in Flutter!',
    );
  } else {
    print(
      'ℹ️  Blocking run (${blockingMs}ms) fits within 16ms on this machine, but scales up with N.',
    );
  }

  print(
    'ℹ️  Isolate run (${isolateMs}ms) includes spawn overhead — for repeated tasks, keep the isolate alive.',
  );
}

// ============================================================
// MAIN — orchestrates all sections
// ============================================================
Future<void> main() async {
  print('========================================');
  print(' Phase 1 — Isolates (Intro) Demo');
  print('========================================');

  // Section 1: Simplest API — Isolate.run()
  await _demoIsolateRun();

  // Section 2: Full bidirectional communication via SendPort/ReceivePort
  await _demoBidirectional();

  // Section 3: Side-by-side timing comparison (outputs required format)
  await _demoTimingComparison();

  print('\n========================================');
  print(' Done! Key takeaways:');
  print('   • Isolate.run() = easiest offload for one-shot computation');
  print('   • SendPort/ReceivePort = full bidirectional control');
  print('   • 16ms rule: if it blocks > 1 frame, isolate it');
  print('   • I/O (HTTP, file) is already async — no isolate needed');
  print('========================================');
}
