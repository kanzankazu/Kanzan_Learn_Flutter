/// Entry point Phase 10.3 — Track 3: Native Interop
///
/// Track 3 teaches you how to bridge Flutter to native platform code.
/// After this track you can write plugins, call C libraries, and build
/// features that no existing Flutter package covers.
///
/// **Topics:**
/// 01. Method & Event Channel (Advanced) — error codes, bidirectional, testing
/// 02. Pigeon — type-safe generated API classes
/// 03. Dart FFI — call C libraries directly without Kotlin/Swift
/// 04. Plugin Development — federated structure, platform interface, pub.dev
///
/// **Mini Project: Battery Plugin**
/// A complete Pigeon-based plugin showing battery level + charging stream.
import 'package:flutter/material.dart';

import '01_method_event_channel/method_event_channel_advanced_demo.dart';
import '02_pigeon/pigeon_demo.dart';
import '03_dart_ffi/dart_ffi_demo.dart';
import '04_plugin_development/plugin_development_demo.dart';
import 'mini_projects/battery_plugin/battery_plugin_demo.dart';

void main() => runApp(const Phase103MenuApp());

class Phase103MenuApp extends StatelessWidget {
  const Phase103MenuApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phase 10.3 — Native Interop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
          useMaterial3: true),
      home: const Phase103MenuScreen(),
    );
  }
}

class Phase103MenuScreen extends StatelessWidget {
  const Phase103MenuScreen({super.key});

  static const _topics = [
    _T('01 — Advanced Channels', 'Error codes, bidirectional, timeout, testing mocks',
        Icons.cable, Colors.brown, MethodEventChannelAdvancedDemo()),
    _T('02 — Pigeon', '@HostApi/@FlutterApi, code-gen, nested types, enums',
        Icons.sync_alt, Colors.orange, PigeonDemo()),
    _T('03 — Dart FFI', 'DynamicLibrary, Pointer, Struct, Arena, ffigen',
        Icons.memory, Colors.brown, DartFfiDemo()),
    _T('04 — Plugin Development', 'Federated structure, platform interface, pub.dev',
        Icons.extension, Colors.teal, PluginDevelopmentDemo()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phase 10.3 — Native Interop'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.brown.shade50,
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                'Track 3 teaches the skills that separate Flutter developers '
                'from cross-platform mobile engineers.\n\n'
                'When no package exists for the native feature you need — '
                'you can build it yourself.',
                style: TextStyle(fontSize: 13, height: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ..._topics.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: t.color.withAlpha(38), child: Icon(t.icon, color: t.color, size: 20)),
                    title: Text(t.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(t.sub, style: const TextStyle(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => t.dest)),
                  ),
                ),
              )),
          const Divider(height: 24),
          Card(
            color: Colors.green.shade50,
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.battery_charging_full, color: Colors.white)),
              title: const Text('Mini Project: Battery Plugin', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Complete Pigeon-based plugin: battery level, charging state, stream'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BatteryPluginDemoApp())),
            ),
          ),
        ],
      ),
    );
  }
}

class _T {
  final String label, sub;
  final IconData icon;
  final Color color;
  final Widget dest;
  const _T(this.label, this.sub, this.icon, this.color, this.dest);
}
