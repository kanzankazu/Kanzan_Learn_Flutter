/// Phase 10.3 — Topic 01: Advanced Method & Event Channel Patterns
///
/// Phase 6 covered the basics of MethodChannel + EventChannel.
/// This topic goes deeper with production patterns used in real plugins.
///
/// Key concepts covered:
/// 1. Structured error codes — never catch raw exceptions on the Dart side
/// 2. Bidirectional calls — native calling Flutter (FlutterMethodChannel)
/// 3. Timeout and cancellation — prevent infinite waits
/// 4. Channel multiplexing — one channel name, many logical operations
/// 5. StandardMethodCodec vs JSONMethodCodec — when to use each
/// 6. Testing channels — MethodChannel.setMockMethodCallHandler
/// 7. Thread safety — ensuring native calls return on the right thread
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const _StandaloneApp());

class _StandaloneApp extends StatelessWidget {
  const _StandaloneApp();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced Channels',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown), useMaterial3: true),
      home: const MethodEventChannelAdvancedDemo(),
    );
  }
}

class MethodEventChannelAdvancedDemo extends StatefulWidget {
  const MethodEventChannelAdvancedDemo({super.key});
  @override
  State<MethodEventChannelAdvancedDemo> createState() => _State();
}

class _State extends State<MethodEventChannelAdvancedDemo> {
  String _result = '—';
  bool _loading = false;

  // Simulate a channel call (mocked here since no native side)
  Future<void> _callChannel(String method) async {
    setState(() { _loading = true; _result = 'Calling $method…'; });
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {
      _loading = false;
      _result = '$method returned: {"status":"ok","data":42}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('01 — Advanced Channels'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── 1. Structured error codes ─────────────────────────────────
          _header('1. Structured Error Codes', Colors.brown),
          _code(r'''
// ❌ Bad: parse the error message string
try {
  await _channel.invokeMethod('getUser');
} on PlatformException catch (e) {
  if (e.message?.contains('not found') ?? false) { ... }
}
// Fragile: message strings can change between native SDK versions

// ✅ Good: use structured error codes
class ChannelErrorCodes {
  static const String notFound     = 'USER_NOT_FOUND';
  static const String unauthorized = 'UNAUTHORIZED';
  static const String timeout      = 'TIMEOUT';
}

try {
  await _channel.invokeMethod('getUser', {'id': '123'});
} on PlatformException catch (e) {
  switch (e.code) {
    case ChannelErrorCodes.notFound:
      return Failure(AppError.notFound('User 123 not found'));
    case ChannelErrorCodes.unauthorized:
      return Failure(AppError.auth('Session expired'));
    default:
      return Failure(AppError.unknown(e.message));
  }
}

// Kotlin native side — throw structured error:
result.error(
  "USER_NOT_FOUND",           // code
  "User with id 123 not found", // message (human-readable)
  null                          // details (optional JSON)
)'''),

          const SizedBox(height: 20),

          // ── 2. Timeout and cancellation ───────────────────────────────
          _header('2. Timeout & Cancellation', Colors.teal),
          _code(r'''
// Never leave a channel call hanging forever
// Use Future.any or timeout to cap the wait

class SafeChannel {
  static const _channel = MethodChannel('com.example/safe');
  static const _timeout = Duration(seconds: 10);

  static Future<T?> invoke<T>(String method, [dynamic args]) async {
    try {
      return await _channel
          .invokeMethod<T>(method, args)
          .timeout(_timeout, onTimeout: () {
        // Cancel the native operation if possible
        _channel.invokeMethod('cancel', {'method': method});
        throw PlatformException(
          code: 'TIMEOUT',
          message: '$method timed out after ${_timeout.inSeconds}s',
        );
      });
    } on MissingPluginException {
      // Running on a platform that doesn't support this method
      // (e.g. web or simulator without the plugin)
      debugPrint('Channel $method not available on this platform');
      return null;
    }
  }
}

// Usage:
final battery = await SafeChannel.invoke<int>('getBatteryLevel');'''),

          const SizedBox(height: 20),

          // ── 3. Bidirectional (native → Flutter) ───────────────────────
          _header('3. Native → Flutter Calls', Colors.indigo),
          _code(r'''
// Standard: Flutter calls native (most common)
// But sometimes native needs to call Flutter: e.g. push notification tapped,
// hardware button pressed, sensor threshold crossed.

// Flutter side — set up a handler for calls FROM native:
const _nativeToFlutter = MethodChannel('com.example/native_to_flutter');

void _setupNativeToFlutterHandler() {
  _nativeToFlutter.setMethodCallHandler((call) async {
    switch (call.method) {
      case 'onDeepLink':
        final url = call.arguments as String;
        _router.go(url);           // handle deep link from native
        return null;

      case 'onBiometricSuccess':
        _authNotifier.confirmBiometric();
        return null;

      default:
        throw MissingPluginException('Unknown method: ${call.method}');
    }
  });
}

// Call setMethodCallHandler in initState or in main() before runApp.

// Kotlin side — calling Flutter:
FlutterEngine.dartExecutor.binaryMessenger.let { messenger ->
  MethodChannel(messenger, "com.example/native_to_flutter")
    .invokeMethod("onDeepLink", deepLinkUrl)
}'''),

          const SizedBox(height: 20),

          // ── 4. Testing channels ───────────────────────────────────────
          _header('4. Testing Channel Calls', Colors.orange),
          _code(r'''
// In tests, intercept channel calls without a real native side
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Mock the channel — return controlled responses
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.example/battery'),
      (MethodCall call) async {
        if (call.method == 'getBatteryLevel') return 85;
        if (call.method == 'isCharging') return true;
        throw PlatformException(code: 'UNSUPPORTED', message: 'Not mocked');
      },
    );
  });

  tearDown(() {
    // Clear the mock after each test
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.example/battery'), null,
    );
  });

  test('BatteryService.getLevel returns 85', () async {
    final service = BatteryService();
    expect(await service.getLevel(), equals(85));
  });
}'''),

          const SizedBox(height: 16),

          // ── Live demo ──────────────────────────────────────────────────
          _header('Live Demo (Mocked Channel)', Colors.purple),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Text(_result, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                  const SizedBox(height: 12),
                  if (_loading) const CircularProgressIndicator()
                  else Wrap(
                    spacing: 8,
                    children: [
                      FilledButton(onPressed: () => _callChannel('getBatteryLevel'), child: const Text('Battery')),
                      FilledButton(onPressed: () => _callChannel('getDeviceInfo'), child: const Text('Device Info')),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          _card(
            color: Colors.brown.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Key Takeaways', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('• Use structured error codes — never parse error message strings'),
                Text('• Always add .timeout() to channel calls — native can hang'),
                Text('• setMethodCallHandler enables native → Flutter callbacks'),
                Text('• setMockMethodCallHandler in tests replaces real native calls'),
                Text('• MissingPluginException = method not implemented on this platform'),
              ],
            ),
          ),
        ],
      ),
    );
  }
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
