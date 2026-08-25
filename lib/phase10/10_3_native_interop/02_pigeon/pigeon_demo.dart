/// Phase 10.3 — Topic 02: Pigeon — Type-Safe Platform Channels
///
/// Pigeon generates type-safe Dart + Kotlin/Swift API classes from a
/// single Dart definition file. No more stringly-typed channel calls.
///
/// Key concepts covered:
/// 1. @HostApi — Flutter calls native (the most common direction)
/// 2. @FlutterApi — Native calls Flutter (callbacks, events)
/// 3. Supported types: primitives, List, Map, nested classes, enums
/// 4. Async methods — returns Future<T> automatically
/// 5. Error handling — typed exceptions propagate correctly
/// 6. Running Pigeon: dart run pigeon --input pigeons/battery_api.dart
/// 7. Using the generated code
import 'package:flutter/material.dart';

void main() => runApp(const _StandaloneApp());

class _StandaloneApp extends StatelessWidget {
  const _StandaloneApp();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pigeon Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange), useMaterial3: true),
      home: const PigeonDemo(),
    );
  }
}

class PigeonDemo extends StatelessWidget {
  const PigeonDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('02 — Pigeon'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            color: Colors.orange.shade50,
            child: const Text(
              'Pigeon replaces raw MethodChannel strings with generated, '
              'type-safe Dart + Kotlin classes.\n\n'
              'You define the API once in Dart → Pigeon writes both sides.',
              style: TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),

          // ── 1. Define the API ─────────────────────────────────────────
          _header('1. Define the API (pigeons/battery_api.dart)', Colors.orange),
          _code(r'''
// pigeons/battery_api.dart — the source of truth
// Run: dart run pigeon --input pigeons/battery_api.dart

import 'package:pigeon/pigeon.dart';

// Output config: where to write the generated files
@ConfigurePigeon(PigeonOptions(
  dartOut:        'lib/src/battery_api.g.dart',
  kotlinOut:      'android/app/src/main/kotlin/.../BatteryApi.kt',
  kotlinOptions:  KotlinOptions(package: 'com.example.battery'),
  swiftOut:       'ios/Runner/BatteryApi.swift',
))

// ── Data classes (shared between Dart and native) ──────────────────
// Pigeon generates both Dart and Kotlin/Swift classes from these.

class BatteryInfo {
  int? level;             // 0–100
  bool? isCharging;
  BatteryState? state;   // enum
}

enum BatteryState { charging, discharging, full, unknown }

// ── @HostApi — Flutter calls native ───────────────────────────────
@HostApi()
abstract class BatteryApi {
  // Async methods return Future<T> in Dart, suspend fun in Kotlin
  BatteryInfo getBatteryInfo();

  // Returns null if permission not granted
  @async
  int? getBatteryLevel();
}

// ── @FlutterApi — Native calls Flutter ────────────────────────────
@FlutterApi()
abstract class BatteryFlutterApi {
  // Native calls this when the battery level changes
  void onBatteryLevelChanged(int level);
  void onChargingStateChanged(bool isCharging);
}'''),

          const SizedBox(height: 20),

          // ── 2. Run Pigeon ──────────────────────────────────────────────
          _header('2. Generate the Code', Colors.teal),
          _code(r'''
# Run Pigeon to generate Dart + native files
dart run pigeon --input pigeons/battery_api.dart

# Output files generated automatically:
# lib/src/battery_api.g.dart          ← Dart API class
# android/.../BatteryApi.kt           ← Kotlin API class
# ios/Runner/BatteryApi.swift         ← Swift API class

# Re-run whenever you change the pigeon definition file.
# Add to CI: if battery_api.dart changes, regenerate.'''),

          const SizedBox(height: 20),

          // ── 3. Use the generated Dart API ─────────────────────────────
          _header('3. Use the Generated Dart Code', Colors.blue),
          _code(r'''
// lib/services/battery_service.dart
import 'src/battery_api.g.dart';

class BatteryService {
  final _api = BatteryApi();   // generated class — no channel strings!

  Future<int> getLevel() async {
    // Fully typed — returns int?, no dynamic
    return await _api.getBatteryLevel() ?? -1;
  }

  Future<BatteryInfo> getBatteryInfo() async {
    // BatteryInfo is a generated Dart class with typed fields
    final info = await _api.getBatteryInfo();
    return info;
    // info.level    → int?
    // info.isCharging → bool?
    // info.state    → BatteryState? (enum)
  }
}

// Benefits over raw MethodChannel:
// ✅ Type-safe: info.level is int?, not dynamic
// ✅ Compile-time errors if you misspell method names
// ✅ Both Dart and Kotlin share the same BatteryState enum
// ✅ Nested objects (BatteryInfo) are serialized/deserialized automatically'''),

          const SizedBox(height: 20),

          // ── 4. Kotlin implementation ───────────────────────────────────
          _header('4. Implement on the Kotlin Side', Colors.purple),
          _code(r'''
// android/.../MainActivity.kt
// The generated BatteryApi.kt tells you exactly what to implement

class BatteryApiImpl(private val context: Context) : BatteryApi {
  // Implement the abstract method — the signature is generated, not hand-written
  override fun getBatteryInfo(): BatteryInfo {
    val manager = context.getSystemService(Context.BATTERY_SERVICE)
        as BatteryManager
    val level = manager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
    val isCharging = manager.isCharging

    return BatteryInfo(
      level = level,
      isCharging = isCharging,
      state = if (isCharging) BatteryState.CHARGING else BatteryState.DISCHARGING
    )
  }

  override fun getBatteryLevel(callback: (Result<Long?>) -> Unit) {
    // Async method — call callback with result or error
    val level = manager.getIntProperty(...)
    callback(Result.success(level.toLong()))
  }
}

class MainActivity : FlutterActivity() {
  override fun configureFlutterEngine(engine: FlutterEngine) {
    super.configureFlutterEngine(engine)
    // Register the implementation
    BatteryApi.setUp(engine.dartExecutor.binaryMessenger, BatteryApiImpl(this))
  }
}'''),

          const SizedBox(height: 20),

          // ── 5. @FlutterApi (native → Dart callbacks) ───────────────────
          _header('5. @FlutterApi — Native Calls Flutter', Colors.red),
          _code(r'''
// For the @FlutterApi (native → Flutter callbacks),
// Flutter provides the implementation; native calls it.

// Dart side — implement the generated abstract class:
class BatteryFlutterApiImpl extends BatteryFlutterApi {
  @override
  void onBatteryLevelChanged(int level) {
    // Update Riverpod state when native fires this
    _container.read(batteryLevelProvider.notifier).update(level);
  }

  @override
  void onChargingStateChanged(bool isCharging) {
    _container.read(chargingStateProvider.notifier).update(isCharging);
  }
}

// Register in main():
BatteryFlutterApi.setUp(BatteryFlutterApiImpl());

// Kotlin side — call it whenever battery changes:
val flutterApi = BatteryFlutterApi(messenger)
batteryMonitor.onChange { level, isCharging ->
  flutterApi.onBatteryLevelChanged(level) {}
  flutterApi.onChargingStateChanged(isCharging) {}
}'''),

          const SizedBox(height: 16),
          _card(
            color: Colors.orange.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Key Takeaways', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('• Define once in Dart → Pigeon generates Dart + Kotlin + Swift'),
                Text('• @HostApi = Flutter calls native (most common)'),
                Text('• @FlutterApi = native calls Flutter (events, callbacks)'),
                Text('• Nested classes and enums are fully supported'),
                Text('• Generated code is in *.g.dart — never edit manually'),
                Text('• Add pigeon definition files to code review (they are the contract)'),
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
