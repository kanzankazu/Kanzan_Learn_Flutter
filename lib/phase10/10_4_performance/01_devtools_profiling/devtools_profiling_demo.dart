/// Phase 10.4 — Topic 01: Flutter DevTools & Profiling
///
/// You cannot optimize what you cannot measure.
/// Flutter DevTools is the official performance profiling tool.
///
/// Key concepts covered:
/// 1. How to open DevTools and connect to a running app
/// 2. Widget Rebuild Stats — find which widgets rebuild too often
/// 3. CPU Profiler — find long tasks that cause jank
/// 4. Memory Profiler — detect leaks and excessive allocations
/// 5. Performance Overlay — the built-in FPS/GPU monitor
/// 6. Timeline view — trace individual frames
/// 7. The three rules of Flutter performance: const, keys, RepaintBoundary
/// 8. Common jank causes and how to fix them
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() => runApp(const _StandaloneApp());

class _StandaloneApp extends StatelessWidget {
  const _StandaloneApp();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DevTools Profiling',
      debugShowCheckedModeBanner: false,
      // Enable performance overlay via this flag (or DevTools)
      showPerformanceOverlay: false, // set to true to see FPS bars
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), useMaterial3: true),
      home: const DevToolsProfilingDemo(),
    );
  }
}

class DevToolsProfilingDemo extends StatefulWidget {
  const DevToolsProfilingDemo({super.key});
  @override
  State<DevToolsProfilingDemo> createState() => _DevToolsProfilingDemoState();
}

class _DevToolsProfilingDemoState extends State<DevToolsProfilingDemo>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  int _frameCount = 0;
  double _fps = 0.0;
  Duration _lastTime = Duration.zero;

  // Bad: counter that causes rebuilds
  int _badCounter = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final dt = elapsed - _lastTime;
    if (dt.inMilliseconds > 0) {
      setState(() {
        _fps = 1000 / dt.inMilliseconds;
        _frameCount++;
        _lastTime = elapsed;
      });
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('01 — DevTools Profiling'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Live FPS display ──────────────────────────────────────────
          _header('Live Frame Rate', Colors.blue),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _metric('FPS', _fps.toStringAsFixed(0), _fps >= 55 ? Colors.green : Colors.red),
                  _metric('Frames', '$_frameCount', Colors.blue),
                  _metric('Target', '60', Colors.grey),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── 1. Open DevTools ─────────────────────────────────────────
          _header('1. Open DevTools', Colors.blue),
          _code(r'''
# Start your app in profile mode (closest to release performance)
flutter run --profile

# DevTools URL is printed in the terminal:
# Flutter DevTools: http://127.0.0.1:9100/...

# Or open from VS Code: Cmd+Shift+P → "Flutter: Open DevTools"
# Or from Android Studio: Flutter inspector → DevTools

# Key DevTools tabs:
# - Flutter Inspector  → widget tree, layout explorer
# - Performance        → frame timeline, CPU profiler
# - Memory             → heap usage, leaks
# - CPU Profiler       → method-level call timing
# - Network            → HTTP request/response times
# - Logging            → print() output with timestamps'''),

          const SizedBox(height: 20),

          // ── 2. Widget rebuild stats ────────────────────────────────────
          _header('2. Widget Rebuild Stats', Colors.orange),
          _code(r'''
// DevTools → Performance → Track Widget Builds
// Shows a counter next to each widget for how many times it rebuilt.
// High rebuild count = potential performance issue.

// BEFORE: Rebuilding the whole page every second
class _BadCounter extends StatefulWidget { ... }
class _BadCounterState extends State<_BadCounter> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    // This build() runs every time _count changes
    // Even the Text("Static title") rebuilds unnecessarily!
    return Column(children: [
      const Text('Static title'),  // rebuilds on EVERY count change
      Text('Count: $_count'),
      ExpensiveWidget(),            // rebuilds on EVERY count change!
    ]);
  }
}

// AFTER: Extract the changing part, make the rest const
class _GoodCounter extends StatefulWidget { ... }
class _GoodCounterState extends State<_GoodCounter> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Text('Static title'),  // const = never rebuilds ✅
      _CountDisplay(count: _count), // only this widget rebuilds ✅
      const ExpensiveWidget(),      // const = never rebuilds ✅
    ]);
  }
}

// Rule: const widgets are always cheaper than non-const.
// The Dart analyzer will warn you when const is possible.'''),

          const SizedBox(height: 20),

          // ── 3. CPU profiler ────────────────────────────────────────────
          _header('3. CPU Profiler — Find Slow Methods', Colors.red),
          _code(r'''
// DevTools → CPU Profiler → Record → interact with the app → Stop

// Reading the flame chart:
// - X axis = time (wider bar = more time spent)
// - Y axis = call stack (top is the leaf, bottom is root)
// - Look for WIDE bars that you can make narrower

// Common causes of CPU jank:
// 1. JSON parsing on the main thread
//    Fix: use Isolate.run(() => json.decode(bigString))
//
// 2. List sorting in build()
//    Fix: sort in the provider/notifier, not in build()
//
// 3. Image decoding synchronously
//    Fix: use Image.network (async) or precacheImage()
//
// 4. Computing derived state on every rebuild
//    Fix: use Riverpod provider to cache the computation

// ── Using the Timeline ─────────────────────────────────────────────
// Timeline.startSync / finishSync mark custom events in DevTools
import 'dart:developer' as dev;

Future<void> heavyOperation() async {
  dev.Timeline.startSync('MyHeavyOperation');
  try {
    // ... your code
    await Future.delayed(const Duration(milliseconds: 100));
  } finally {
    dev.Timeline.finishSync();  // appears in DevTools timeline
  }
}'''),

          const SizedBox(height: 20),

          // ── 4. RepaintBoundary ─────────────────────────────────────────
          _header('4. RepaintBoundary — Isolate Repaints', Colors.purple),
          _code(r'''
// RepaintBoundary creates a separate layer for its subtree.
// When ONLY that subtree needs repainting, Flutter skips all other layers.

// Use case: an animated widget inside a complex screen
Column(
  children: [
    const ExpensiveStaticHeader(),  // never repaints

    // Wrap the animated part in RepaintBoundary
    // Now animations here don't trigger repaint of the header
    RepaintBoundary(
      child: AnimatedProgressRing(progress: _progress),
    ),

    const ExpensiveStaticList(),    // never repaints
  ],
)

// How to know if you need it: DevTools Performance → "Show repainted areas"
// Red overlay = area being repainted on this frame
// If the entire screen is red when only a small widget changes → add RepaintBoundary'''),

          const SizedBox(height: 16),
          _card(
            color: Colors.blue.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Key Takeaways', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('• Always profile in --profile mode, NOT debug (debug is 5-10x slower)'),
                Text('• Widget rebuild stats → find widgets rebuilding 100s of times per second'),
                Text('• CPU flame chart → find wide bars (slow methods) to optimize'),
                Text('• const = never rebuilds. One const can save thousands of rebuilds/sec'),
                Text('• RepaintBoundary = isolate an animated subtree from the rest of the screen'),
                Text('• Timeline.startSync/finishSync adds custom events to the DevTools timeline'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value, Color color) => Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        ],
      );
}

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
