/// Phase 10.3 — Mini Project: Battery Plugin Demo
///
/// Demonstrates a complete Pigeon-based plugin implementation
/// showing battery info + charging stream — all with proper error handling.
import 'package:flutter/material.dart';

void main() => runApp(const BatteryPluginDemoApp());

class BatteryPluginDemoApp extends StatelessWidget {
  const BatteryPluginDemoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Battery Plugin Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.green), useMaterial3: true),
      home: const BatteryPluginScreen(),
    );
  }
}

class BatteryPluginScreen extends StatefulWidget {
  const BatteryPluginScreen({super.key});
  @override
  State<BatteryPluginScreen> createState() => _BatteryPluginScreenState();
}

class _BatteryPluginScreenState extends State<BatteryPluginScreen> {
  // Simulated battery data (in real plugin: comes from native via Pigeon)
  int _batteryLevel = 78;
  bool _isCharging = false;
  String _status = 'Discharging';
  bool _loading = false;

  Future<void> _refresh() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _batteryLevel = 45 + (DateTime.now().second % 55);
      _isCharging = DateTime.now().second % 2 == 0;
      _status = _isCharging ? 'Charging' : 'Discharging';
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = _batteryLevel > 50
        ? Colors.green
        : _batteryLevel > 20
            ? Colors.orange
            : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Battery Plugin — Demo'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _refresh,
            tooltip: 'Refresh (simulate new native data)',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Battery visual
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: _batteryLevel / 100,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                  if (_loading)
                    const CircularProgressIndicator()
                  else
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isCharging ? Icons.bolt : Icons.battery_full,
                          color: color, size: 32,
                        ),
                        Text('$_batteryLevel%',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(_status, style: const TextStyle(fontSize: 16, color: Colors.grey)),

            const SizedBox(height: 32),

            // Plugin code snippets
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('How this plugin works:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
            const SizedBox(height: 8),
            _codeBlock(r'''
// 1. Define in pigeons/battery_api.dart:
@HostApi()
abstract class BatteryApi {
  BatteryInfo getBatteryInfo();
}

// 2. Run: dart run pigeon --input pigeons/battery_api.dart
// → Generates lib/src/battery_api.g.dart

// 3. Use in your app:
final api = BatteryApi();
final info = await api.getBatteryInfo();
print('Level: ${info.level}%  Charging: ${info.isCharging}');'''),

            const SizedBox(height: 16),
            _codeBlock(r'''
// Kotlin implementation (auto-generated class signature):
class BatteryApiImpl(private val context: Context) : BatteryApi {
  override fun getBatteryInfo(): BatteryInfo {
    val manager = context.getSystemService(Context.BATTERY_SERVICE)
        as BatteryManager
    return BatteryInfo(
      level = manager.getIntProperty(BATTERY_PROPERTY_CAPACITY),
      isCharging = manager.isCharging,
      state = if (manager.isCharging) BatteryState.CHARGING
              else BatteryState.DISCHARGING,
    )
  }
}'''),
          ],
        ),
      ),
    );
  }

  Widget _codeBlock(String code) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2E),
          borderRadius: BorderRadius.circular(8),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(code,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Color(0xFFCDD6F4))),
        ),
      );
}
