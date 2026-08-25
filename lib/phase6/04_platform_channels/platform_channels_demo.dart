/// Phase 6 — Topic 04: Platform Channels
///
/// Platform Channels are Flutter's bridge between Dart code and native code
/// (Kotlin/Java on Android, Swift/ObjC on iOS).
///
/// Why you need them:
/// - Access hardware or OS APIs not yet wrapped by any package
/// - Call native SDKs from vendors (banking, biometrics, DRM, etc.)
/// - Reuse existing native code you or your team already wrote
///
/// Channel types:
/// ┌─────────────────────────┬──────────────────────────────────────────────┐
/// │ MethodChannel           │ One-shot call: Dart calls native → native    │
/// │                         │ responds. Like a function call.              │
/// ├─────────────────────────┼──────────────────────────────────────────────┤
/// │ EventChannel            │ Continuous stream: native pushes events to   │
/// │                         │ Dart. Like a Stream<T>.                      │
/// ├─────────────────────────┼──────────────────────────────────────────────┤
/// │ BasicMessageChannel     │ Arbitrary back-and-forth messaging.           │
/// └─────────────────────────┴──────────────────────────────────────────────┘
///
/// Key concepts covered:
/// 1. MethodChannel — setup, invokeMethod, handle on native side
/// 2. EventChannel — setup, receiveBroadcastStream, native StreamHandler
/// 3. Pigeon — code-gen approach for type-safe channels (concept overview)
/// 4. Error handling — PlatformException
///
/// NOTE: This demo **simulates** native calls on the Dart side because we can't
/// actually run Kotlin/Swift here. All native snippets are shown as code examples.
///
/// How to run:
/// ```bash
/// flutter run -t lib/phase6/main_phase6.dart
/// ```

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart'; // MethodChannel, EventChannel, PlatformException

/// Standalone entry point so this file can be run directly:
/// ```bash
/// flutter run -t phase6/04_platform_channels/platform_channels_demo.dart
/// ```
void main() => runApp(_StandaloneApp());

/// Minimal app wrapper used only when running this file directly.
class _StandaloneApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlatformChannelsDemo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      home: const PlatformChannelsDemo(),
    );
  }
}

/// Demo screen explaining Platform Channels with interactive simulations.
class PlatformChannelsDemo extends StatefulWidget {
  const PlatformChannelsDemo({super.key});

  @override
  State<PlatformChannelsDemo> createState() => _PlatformChannelsDemoState();
}

class _PlatformChannelsDemoState extends State<PlatformChannelsDemo> {
  // ── MethodChannel simulation ───────────────────────────────────────────────
  // In a real app this would call native. Here we simulate the response.
  String _batteryLevel = '—';
  bool _loadingBattery = false;

  // ── EventChannel simulation ────────────────────────────────────────────────
  // In a real app this stream comes from the native EventChannel.
  // Here we use a Dart StreamController to simulate it.
  StreamSubscription<int>? _stepSub;
  int _stepCount = 0;
  bool _listening = false;
  StreamController<int>? _fakeStepStream;

  @override
  void dispose() {
    _stepSub?.cancel();
    _fakeStepStream?.close();
    super.dispose();
  }

  // ── Simulate MethodChannel call ────────────────────────────────────────────
  /// In a real app you'd write:
  /// ```dart
  /// const _channel = MethodChannel('com.example.app/battery');
  /// final level = await _channel.invokeMethod<int>('getBatteryLevel');
  /// ```
  Future<void> _getBatteryLevel() async {
    setState(() => _loadingBattery = true);

    // Simulate network/native latency
    await Future.delayed(const Duration(milliseconds: 800));

    // Simulate a PlatformException to show error handling
    // In reality the native side throws this when something goes wrong.
    try {
      // Pretend native returned 78
      const simulatedResult = 78;
      setState(() => _batteryLevel = '$simulatedResult%');
    } on PlatformException catch (e) {
      // PlatformException carries a code + message from native side
      setState(() => _batteryLevel = 'Error: ${e.code} — ${e.message}');
    } finally {
      setState(() => _loadingBattery = false);
    }
  }

  // ── Simulate EventChannel stream ───────────────────────────────────────────
  /// In a real app you'd write:
  /// ```dart
  /// const _events = EventChannel('com.example.app/steps');
  /// final stream = _events.receiveBroadcastStream();
  /// _stepSub = stream.cast<int>().listen((count) => setState(() => _stepCount = count));
  /// ```
  void _startListening() {
    _fakeStepStream?.close();
    _fakeStepStream = StreamController<int>();
    _stepCount = 0;

    // Emit a new step count every second (simulates hardware sensor)
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_fakeStepStream?.isClosed ?? true) {
        timer.cancel();
        return;
      }
      _fakeStepStream!.add(_stepCount + _randomStep());
    });

    _stepSub = _fakeStepStream!.stream.listen((count) {
      setState(() => _stepCount = count);
    });

    setState(() => _listening = true);
  }

  void _stopListening() {
    _stepSub?.cancel();
    _stepSub = null;
    _fakeStepStream?.close();
    _fakeStepStream = null;
    setState(() => _listening = false);
  }

  // Simple pseudo-random step increment (1–10)
  int _step = 0;
  int _randomStep() {
    _step = (_step * 6364136223846793005 + 1442695040888963407) & 0x7FFFFFFF;
    return (_step % 10) + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('04 — Platform Channels'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Architecture overview ────────────────────────────────────────
          Card(
            color: Colors.brown.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Architecture',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text(
                    'Dart ←→ Platform Channel ←→ Native (Kotlin / Swift)\n\n'
                    'Channels are identified by a String name (like a URL).\n'
                    'Both sides register on the same name to communicate.\n'
                    'All messages cross the channel as binary (Uint8List) '
                    'and are automatically encoded/decoded by the StandardMessageCodec.',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Section 1: MethodChannel ─────────────────────────────────────
          _header('1. MethodChannel — One-shot call', Colors.brown),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.battery_full, size: 48, color: Colors.green),
                  const SizedBox(height: 8),
                  Text(
                    _batteryLevel,
                    style: const TextStyle(
                        fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _loadingBattery
                      ? const CircularProgressIndicator()
                      : FilledButton.icon(
                          style: FilledButton.styleFrom(
                              backgroundColor: Colors.brown),
                          onPressed: _getBatteryLevel,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Get Battery Level'),
                        ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _codeSnippet(
            '// ── DART SIDE ──────────────────────────────────────────────\n'
            'const _channel = MethodChannel(\'com.example.app/battery\');\n'
            '\n'
            'Future<void> getBattery() async {\n'
            '  try {\n'
            '    // invokeMethod sends the call to native, waits for response\n'
            '    final level = await _channel.invokeMethod<int>(\'getBatteryLevel\');\n'
            '    setState(() => _batteryLevel = \'\$level%\');\n'
            '  } on PlatformException catch (e) {\n'
            '    // Native threw an exception\n'
            '    print(\'Error: \${e.code} — \${e.message}\');\n'
            '  }\n'
            '}\n'
            '\n'
            '// ── KOTLIN SIDE (android/app/src/main/.../MainActivity.kt) ─\n'
            'class MainActivity : FlutterActivity() {\n'
            '  override fun configureFlutterEngine(engine: FlutterEngine) {\n'
            '    super.configureFlutterEngine(engine)\n'
            '    MethodChannel(engine.dartExecutor.binaryMessenger,\n'
            '                  "com.example.app/battery")\n'
            '      .setMethodCallHandler { call, result ->\n'
            '        if (call.method == "getBatteryLevel") {\n'
            '          val level = getBatteryLevel()   // native impl\n'
            '          if (level != -1) result.success(level)\n'
            '          else result.error("UNAVAILABLE", "No battery.", null)\n'
            '        } else result.notImplemented()\n'
            '      }\n'
            '  }\n'
            '}',
          ),

          const SizedBox(height: 24),

          // ── Section 2: EventChannel ──────────────────────────────────────
          _header('2. EventChannel — Continuous stream', Colors.deepOrange),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.directions_walk, size: 48, color: Colors.deepOrange),
                  const SizedBox(height: 8),
                  Text(
                    '$_stepCount steps',
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _listening ? '🟢 Listening to step sensor...' : '⚪ Not listening',
                    style: TextStyle(
                        color: _listening ? Colors.green : Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton(
                        style: FilledButton.styleFrom(
                            backgroundColor: Colors.deepOrange),
                        onPressed: _listening ? null : _startListening,
                        child: const Text('Start'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: _listening ? _stopListening : null,
                        child: const Text('Stop'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _codeSnippet(
            '// ── DART SIDE ──────────────────────────────────────────────\n'
            'const _events = EventChannel(\'com.example.app/steps\');\n'
            '\n'
            '// receiveBroadcastStream returns a Stream from native\n'
            'final stream = _events.receiveBroadcastStream();\n'
            '_stepSub = stream.cast<int>().listen(\n'
            '  (count) => setState(() => _stepCount = count),\n'
            '  onError: (e) => print(\'Stream error: \$e\'),\n'
            ');\n'
            '\n'
            '// ── KOTLIN SIDE ─────────────────────────────────────────────\n'
            'EventChannel(messenger, "com.example.app/steps")\n'
            '  .setStreamHandler(object : EventChannel.StreamHandler {\n'
            '    var eventSink: EventChannel.EventSink? = null\n'
            '    var timer: Timer? = null\n'
            '\n'
            '    override fun onListen(args: Any?, sink: EventChannel.EventSink) {\n'
            '      eventSink = sink\n'
            '      // Push new step count every second\n'
            '      timer = Timer.scheduleAtFixedRate(1000) {\n'
            '        sink.success(getStepCount())\n'
            '      }\n'
            '    }\n'
            '    override fun onCancel(args: Any?) { timer?.cancel() }\n'
            '  })',
          ),

          const SizedBox(height: 24),

          // ── Section 3: Pigeon overview ───────────────────────────────────
          _header('3. Pigeon — Type-safe code gen (overview)', Colors.teal),
          const SizedBox(height: 8),
          Card(
            color: Colors.teal.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Problem with raw MethodChannel:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '• Arguments are Map<String, dynamic> — no type safety\n'
                    '• Method names are raw Strings — typos compile fine\n'
                    '• Changes on native side break at runtime, not compile time',
                    style: TextStyle(fontSize: 13),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Pigeon solution:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Define an API in Dart → Pigeon generates Dart + Kotlin/Swift '
                    'classes automatically. Method calls become type-safe function '
                    'calls on both sides. Recommended for production channel use.',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _codeSnippet(
            '// pigeons/battery_api.dart — define the API\n'
            '@HostApi()                 // native implements it\n'
            'abstract class BatteryApi {\n'
            '  // Return type and param are fully typed — no dynamic!\n'
            '  int getBatteryLevel();\n'
            '}\n'
            '\n'
            '// Run: dart run pigeon --input pigeons/battery_api.dart\n'
            '// Generates: lib/battery_api.g.dart + android/BatteryApi.kt\n'
            '\n'
            '// Usage in Dart (generated, fully typed):\n'
            'final api = BatteryApi();\n'
            'final level = await api.getBatteryLevel(); // int, not dynamic',
          ),

          const SizedBox(height: 24),
          Card(
            color: Colors.brown.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Key Takeaways',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('• MethodChannel = one request → one response (async)'),
                  Text('• EventChannel = continuous stream (sensor, location, etc.)'),
                  Text('• Channel name must match exactly on both Dart and native side'),
                  Text('• PlatformException carries an error code — always handle it'),
                  Text('• Use Pigeon for type-safe channels in production apps'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(String title, Color color) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(title,
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: color)),
      );

  Widget _codeSnippet(String code) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2E),
          borderRadius: BorderRadius.circular(6),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(code,
              style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: Color(0xFFCDD6F4))),
        ),
      );
}
