/// Phase 10.3 — Topic 04: Plugin Development & pub.dev Publishing
///
/// A Flutter plugin packages a platform channel into a reusable package
/// that other Flutter apps can add to their pubspec.yaml.
///
/// Types of plugins:
/// - Federated plugin: separate packages per platform (recommended)
/// - Inline plugin: all platforms in one package
/// - FFI plugin: pure C/Dart without Kotlin/Swift
///
/// Key concepts covered:
/// 1. Federated plugin structure — app-facing / platform-interface / implementations
/// 2. Creating a plugin with flutter create --template=plugin
/// 3. The platform interface package — defines the contract
/// 4. Platform implementations — android, ios, web, desktop
/// 5. Testing plugins — mock platform interface
/// 6. pub.dev publishing checklist
/// 7. Version management and CHANGELOG.md
import 'package:flutter/material.dart';

void main() => runApp(const _StandaloneApp());

class _StandaloneApp extends StatelessWidget {
  const _StandaloneApp();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plugin Development',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal), useMaterial3: true),
      home: const PluginDevelopmentDemo(),
    );
  }
}

class PluginDevelopmentDemo extends StatelessWidget {
  const PluginDevelopmentDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('04 — Plugin Development'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── 1. Plugin types ───────────────────────────────────────────
          _header('1. Plugin Structure Types', Colors.teal),
          _card(
            color: Colors.teal.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Federated (recommended for pub.dev plugins):', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('  my_plugin/                  ← app-facing API'),
                Text('  my_plugin_platform_interface/ ← abstract contract'),
                Text('  my_plugin_android/           ← Android impl'),
                Text('  my_plugin_ios/               ← iOS impl'),
                Text('  my_plugin_web/               ← Web impl'),
                SizedBox(height: 8),
                Text('Inline (simpler, one package):', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('  my_plugin/  → contains android/, ios/ subfolders'),
                SizedBox(height: 8),
                Text('FFI plugin (no native method channel):', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('  my_plugin/  → calls C library via dart:ffi directly'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── 2. Create a plugin ────────────────────────────────────────
          _header('2. Create a Plugin', Colors.blue),
          _code(r'''
# Create an inline plugin (simplest start):
flutter create --template=plugin --platforms=android,ios,web my_battery_plugin
cd my_battery_plugin

# Creates:
# my_battery_plugin/
# ├── lib/
# │   └── my_battery_plugin.dart       ← Dart API (auto-generated boilerplate)
# ├── android/
# │   └── src/main/kotlin/...Plugin.kt ← Android implementation
# ├── ios/
# │   └── Classes/...Plugin.swift      ← iOS implementation
# ├── example/                         ← Example app to test the plugin
# ├── test/
# │   └── my_battery_plugin_test.dart  ← Unit tests with mock channel
# └── pubspec.yaml

# Create a federated plugin:
flutter create --template=plugin_ffi my_ffi_plugin  # FFI variant
# Or manually split into separate packages (see section 4)

# Run the example app to test:
cd example && flutter run'''),

          const SizedBox(height: 20),

          // ── 3. Platform interface ─────────────────────────────────────
          _header('3. Platform Interface Pattern', Colors.orange),
          _code(r'''
// my_battery_plugin_platform_interface/lib/my_battery_plugin_platform_interface.dart
// This is the ABSTRACT CONTRACT that all platform implementations must fulfill.

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class MyBatteryPluginPlatform extends PlatformInterface {
  // Token prevents others from subclassing outside the package
  static final Object _token = Object();

  MyBatteryPluginPlatform() : super(token: _token);

  // The default implementation (used if no platform-specific impl registered)
  static MyBatteryPluginPlatform _instance = _MethodChannelBatteryPlugin();

  static MyBatteryPluginPlatform get instance => _instance;

  static set instance(MyBatteryPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  // Abstract methods — all platforms must implement these
  Future<int?> getBatteryLevel() => throw UnimplementedError();
  Stream<int> get batteryLevelStream => throw UnimplementedError();
}

// The app-facing package just delegates to the platform instance:
// my_battery_plugin/lib/my_battery_plugin.dart
class MyBatteryPlugin {
  static Future<int?> getBatteryLevel() =>
      MyBatteryPluginPlatform.instance.getBatteryLevel();

  static Stream<int> get batteryLevelStream =>
      MyBatteryPluginPlatform.instance.batteryLevelStream;
}'''),

          const SizedBox(height: 20),

          // ── 4. Testing the plugin ─────────────────────────────────────
          _header('4. Testing with Mock Platform', Colors.purple),
          _code(r'''
// test/my_battery_plugin_test.dart

class MockMyBatteryPlugin extends Mock
    implements MyBatteryPluginPlatform {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MyBatteryPlugin', () {
    late MockMyBatteryPlugin mockPlatform;

    setUp(() {
      mockPlatform = MockMyBatteryPlugin();
      // Replace real platform with mock
      MyBatteryPluginPlatform.instance = mockPlatform;
    });

    test('getBatteryLevel returns mocked level', () async {
      when(() => mockPlatform.getBatteryLevel())
          .thenAnswer((_) async => 78);

      final level = await MyBatteryPlugin.getBatteryLevel();

      expect(level, equals(78));
      verify(() => mockPlatform.getBatteryLevel()).called(1);
    });
  });
}'''),

          const SizedBox(height: 20),

          // ── 5. pub.dev publishing ─────────────────────────────────────
          _header('5. pub.dev Publishing Checklist', Colors.red),
          _card(
            color: Colors.red.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Required for good pub.dev score:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...const [
                  'README.md with badges, installation, usage, example',
                  'CHANGELOG.md with version history',
                  'LICENSE file (MIT, BSD-3, or Apache-2.0 for open source)',
                  'pubspec.yaml: description, homepage, repository, issue_tracker',
                  'dartdoc comments on every public class and method',
                  'example/ app that demonstrates every feature',
                  'test/ with ≥ 80% coverage on the Dart API layer',
                  'flutter pub publish --dry-run (fix all warnings first)',
                  'Semantic versioning: MAJOR.MINOR.PATCH',
                  'Topics in pubspec.yaml for discoverability',
                ].map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(children: [
                        const Icon(Icons.check_box_outline_blank, size: 14, color: Colors.grey),
                        const SizedBox(width: 6),
                        Expanded(child: Text(item, style: const TextStyle(fontSize: 11))),
                      ]),
                    )),
              ],
            ),
          ),
          _code(r'''
# Publish to pub.dev:
flutter pub publish --dry-run   # check for issues first
flutter pub publish             # actually publish

# pubspec.yaml for a plugin:
name: my_battery_plugin
description: A Flutter plugin for reading battery information.
version: 1.0.0
homepage: https://github.com/kanzankazu/my_battery_plugin
repository: https://github.com/kanzankazu/my_battery_plugin
issue_tracker: https://github.com/kanzankazu/my_battery_plugin/issues

topics:
  - battery
  - hardware
  - android
  - ios

flutter:
  plugin:
    platforms:
      android:
        package: com.kanzankazu.my_battery_plugin
        pluginClass: MyBatteryPlugin
      ios:
        pluginClass: MyBatteryPlugin'''),

          const SizedBox(height: 16),
          _card(
            color: Colors.teal.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Key Takeaways', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('• Federated = separate package per platform — recommended for popular plugins'),
                Text('• Platform interface = abstract contract all platforms must implement'),
                Text('• Test the Dart API with a mock platform — never test with real native'),
                Text('• flutter pub publish --dry-run catches score issues before going public'),
                Text('• Topics in pubspec.yaml improve discoverability on pub.dev'),
                Text('• CHANGELOG.md is required for a good pub.dev score'),
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
