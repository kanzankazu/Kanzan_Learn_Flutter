/// Phase 10.4 — Topic 04: Isolates & compute()
///
/// Flutter runs all UI and Dart code on a single thread (the main isolate).
/// Heavy work on the main thread → dropped frames → jank.
///
/// Solution: run heavy work in a separate Isolate (parallel thread).
///
/// Key concepts covered:
/// 1. The problem: blocking the main isolate causes jank
/// 2. compute() — simple one-shot off-thread work (Flutter's helper)
/// 3. Isolate.run() — same as compute(), modern API (Dart 2.19+)
/// 4. Isolate.spawn() — manual control for long-lived workers
/// 5. SendPort / ReceivePort — message passing between isolates
/// 6. Limitations: no shared memory, no Flutter widgets in isolates
/// 7. IsolateNameServer — find an isolate by name across the app
/// 8. Practical patterns: JSON parsing, image processing, crypto
import 'dart:isolate';
import 'dart:convert';
import 'package:flutter/material.dart';

void main() => runApp(const _StandaloneApp());

class _StandaloneApp extends StatelessWidget {
  const _StandaloneApp();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Isolates & compute',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal), useMaterial3: true),
      home: const IsolateComputeDemo(),
    );
  }
}

class IsolateComputeDemo extends StatefulWidget {
  const IsolateComputeDemo({super.key});
  @override
  State<IsolateComputeDemo> createState() => _IsolateComputeDemoState();
}

class _IsolateComputeDemoState extends State<IsolateComputeDemo> {
  String _result = '—';
  bool _running = false;
  int _fibN = 38;

  // ── Run heavy Fibonacci on main thread (BLOCKS UI) ─────────────────────
  Future<void> _runOnMainThread() async {
    setState(() { _running = true; _result = 'Running on main thread...'; });
    final start = DateTime.now();
    final result = _fibonacci(_fibN); // blocks the UI thread!
    final elapsed = DateTime.now().difference(start).inMilliseconds;
    setState(() {
      _running = false;
      _result = 'fib($_fibN) = $result\nTime: ${elapsed}ms (UI was FROZEN)';
    });
  }

  // ── Run heavy Fibonacci in an Isolate (does NOT block UI) ──────────────
  Future<void> _runInIsolate() async {
    setState(() { _running = true; _result = 'Running in Isolate...'; });
    final start = DateTime.now();
    // Isolate.run() is the modern way — Dart 2.19+
    final result = await Isolate.run(() => _fibonacci(38));
    final elapsed = DateTime.now().difference(start).inMilliseconds;
    setState(() {
      _running = false;
      _result = 'fib($_fibN) = $result\nTime: ${elapsed}ms (UI stayed smooth)';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('04 — Isolates & compute'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            color: Colors.teal.shade50,
            child: const Text(
              'Flutter is single-threaded. If your Dart code takes > 16ms, '
              'the UI misses a frame and the user sees jank.\n\n'
              'Isolates run Dart code in parallel — completely separate memory, '
              'communicate only via messages.',
              style: TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),

          // ── Live demo ─────────────────────────────────────────────────
          _header('Live Demo — Fibonacci(38)', Colors.teal),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Text(_result,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  if (_running)
                    const Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text('Scroll while this runs — is the UI responsive?',
                            style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    )
                  else
                    Column(
                      children: [
                        const Text('Try scrolling while each runs:',
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            OutlinedButton.icon(
                              onPressed: _runOnMainThread,
                              icon: const Icon(Icons.warning, color: Colors.red, size: 16),
                              label: const Text('Main Thread (JANK)'),
                            ),
                            const SizedBox(width: 8),
                            FilledButton.icon(
                              style: FilledButton.styleFrom(backgroundColor: Colors.teal),
                              onPressed: _runInIsolate,
                              icon: const Icon(Icons.check_circle, size: 16),
                              label: const Text('Isolate (Smooth)'),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── 1. Isolate.run ─────────────────────────────────────────────
          _header('1. Isolate.run() — One-Shot Task', Colors.blue),
          _code(r'''
// Dart 2.19+ — simplest way to run code in a separate isolate
import 'dart:isolate';

// Parse a huge JSON string without blocking the UI
Future<List<Product>> parseProducts(String jsonString) async {
  // Isolate.run() creates an isolate, runs the function, returns the result.
  // The isolate is automatically destroyed when the function completes.
  return Isolate.run(() {
    final list = json.decode(jsonString) as List;
    return list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  });
}

// IMPORTANT: The function passed to Isolate.run() must be a top-level
// or static function — NOT an instance method or closure that captures state.

// Usage:
final products = await parseProducts(hugeJsonString);
// UI stays responsive during parsing ✅'''),

          const SizedBox(height: 20),

          // ── 2. compute() ─────────────────────────────────────────────
          _header('2. compute() — Flutter Helper (Pre Dart 2.19)', Colors.orange),
          _code(r'''
// compute() is Flutter's convenience wrapper around Isolate.spawn()
// Equivalent to Isolate.run() for single-argument functions.
import 'package:flutter/foundation.dart';

// The function must be top-level or static (not a closure)
List<Product> _parseProductsIsolate(String jsonString) {
  final list = json.decode(jsonString) as List;
  return list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
}

// Call from the main thread:
final products = await compute(_parseProductsIsolate, hugeJsonString);
//                                          ↑ single argument only!
// For multiple args: wrap them in a record or a class

// Prefer Isolate.run() for Dart 2.19+ — it is more flexible.
// compute() still works and is well-documented in Flutter guides.'''),

          const SizedBox(height: 20),

          // ── 3. Long-lived Isolate ──────────────────────────────────────
          _header('3. Long-Lived Worker Isolate', Colors.purple),
          _code(r'''
// For repeatedly heavy tasks, keep an isolate alive as a worker.
// Example: real-time image processing (compress each camera frame)

class ImageProcessor {
  late final ReceivePort _resultPort;
  late final SendPort _commandPort;
  Isolate? _isolate;

  Future<void> start() async {
    _resultPort = ReceivePort();

    // Spawn the isolate, pass our receive port so it can send results back
    _isolate = await Isolate.spawn(
      _isolateWorker,            // top-level function in the isolate
      _resultPort.sendPort,      // pass our port to the isolate
    );

    // First message from the isolate is its own SendPort so WE can send to IT
    _commandPort = await _resultPort.first as SendPort;
  }

  // Send work to the isolate
  Future<Uint8List> compress(Uint8List imageBytes) async {
    final responsePort = ReceivePort();
    _commandPort.send({
      'image': imageBytes,
      'replyTo': responsePort.sendPort,
    });
    return await responsePort.first as Uint8List;
  }

  void stop() {
    _isolate?.kill();
    _resultPort.close();
  }
}

// The worker function — runs in the isolate
void _isolateWorker(SendPort mainSendPort) {
  final commandPort = ReceivePort();
  // Send our port to the main isolate so it can send us work
  mainSendPort.send(commandPort.sendPort);

  // Listen for work
  commandPort.listen((message) {
    final map = message as Map;
    final bytes = map['image'] as Uint8List;
    final replyTo = map['replyTo'] as SendPort;

    // Do the heavy work
    final compressed = _actuallyCompressImage(bytes);
    replyTo.send(compressed);  // send result back
  });
}'''),

          const SizedBox(height: 20),

          // ── 4. What can't go into an Isolate ──────────────────────────
          _header('4. Isolate Limitations', Colors.red),
          _card(
            color: Colors.red.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('❌ Cannot use in an Isolate:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('• Flutter widgets (no BuildContext, no setState)'),
                Text('• Shared mutable objects — isolates have separate memory'),
                Text('• dart:ui (Canvas, Image) — some exceptions for image ops'),
                Text('• Static variables — each isolate has its own copy'),
                SizedBox(height: 8),
                Text('✅ Good use cases for Isolates:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('• JSON parsing (large payloads)'),
                Text('• Image processing (compress, resize, filter)'),
                Text('• Crypto operations (hash, encrypt, decrypt)'),
                Text('• Database migrations (heavy SQL operations)'),
                Text('• CSV/XML parsing'),
                Text('• ML inference (if not using native SDK)'),
              ],
            ),
          ),

          const SizedBox(height: 16),
          _card(
            color: Colors.teal.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Key Takeaways', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('• Any Dart work > 16ms on the main thread = dropped frame'),
                Text('• Isolate.run() (Dart 2.19+) = simplest off-thread execution'),
                Text('• compute() = Flutter\'s helper for single-argument functions'),
                Text('• Isolate.spawn() = long-lived worker with SendPort/ReceivePort messaging'),
                Text('• Isolates share NOTHING — pass data via messages (copied, not shared)'),
                Text('• Functions passed to isolates must be top-level or static'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple recursive Fibonacci for the live demo.
/// WARNING: this is intentionally slow to demonstrate jank.
int _fibonacci(int n) => n <= 1 ? n : _fibonacci(n - 1) + _fibonacci(n - 2);

Widget _header(String t, Color c) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(t, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: c)),
    );
Widget _code(String code) => Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF1E1E2E), borderRadius: BorderRadius.circular(6)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(code, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Color(0xFFCDD6F4))),
      ),
    );
Widget _card({required Color color, required Widget child}) =>
    Card(color: color, child: Padding(padding: const EdgeInsets.all(12), child: child));
