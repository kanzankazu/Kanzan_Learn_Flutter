/// Entry point Phase 8 — Deployment & DevOps.
///
/// Phase 8 covers everything that happens AFTER you finish coding:
/// how to build, sign, test, and ship your app to the Play Store,
/// and how to monitor it in production.
///
/// **Topics:**
/// 1. Build Flavors    — --dart-define, AppConfig, native productFlavors
/// 2. App Signing      — Android keystore, key.properties, CI signing, Play App Signing
/// 3. CI/CD            — GitHub Actions, flutter analyze + test, build AAB, distribute
/// 4. Play Store       — AAB vs APK, versioning, release tracks, checklist
/// 5. Crashlytics      — FlutterError.onError, recordError, custom keys, analytics
/// 6. Code Obfuscation — --obfuscate, --split-debug-info, ProGuard, symbolize
///
/// **Milestone 3:** Production-ready — advanced + tested + published.
///
/// How to run the demo app:
/// ```bash
/// flutter run -t lib/phase8/main_phase8.dart
/// ```
import 'package:flutter/material.dart';

import '01_build_flavors/build_flavors_demo.dart';
import '02_app_signing/app_signing_demo.dart';
import '03_ci_cd/ci_cd_demo.dart';
import '04_play_store/play_store_demo.dart';
import '05_crashlytics_analytics/crashlytics_analytics_demo.dart';
import '06_code_obfuscation/code_obfuscation_demo.dart';

void main() => runApp(const Phase8MenuApp());

/// Root widget for Phase 8 menu.
class Phase8MenuApp extends StatelessWidget {
  const Phase8MenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phase 8 — Deployment & DevOps',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const Phase8MenuScreen(),
    );
  }
}

/// Menu listing all Phase 8 topics.
class Phase8MenuScreen extends StatelessWidget {
  const Phase8MenuScreen({super.key});

  static const _topics = [
    _TopicItem(
      '01 — Build Flavors',
      '--dart-define, AppConfig, native productFlavors per environment',
      Icons.build,
      Colors.teal,
      BuildFlavorsDemo(),
    ),
    _TopicItem(
      '02 — App Signing',
      'Keystore, key.properties, CI signing, Play App Signing',
      Icons.lock,
      Colors.indigo,
      AppSigningDemo(),
    ),
    _TopicItem(
      '03 — CI/CD',
      'GitHub Actions: analyze → test → build AAB → distribute',
      Icons.autorenew,
      Colors.blueGrey,
      CiCdDemo(),
    ),
    _TopicItem(
      '04 — Play Store',
      'AAB, versioning, release tracks, staged rollout, checklist',
      Icons.shop,
      Colors.green,
      PlayStoreDemo(),
    ),
    _TopicItem(
      '05 — Crashlytics & Analytics',
      'FlutterError.onError, recordError, custom keys, screen tracking',
      Icons.analytics,
      Colors.orange,
      CrashlyticsAnalyticsDemo(),
    ),
    _TopicItem(
      '06 — Code Obfuscation',
      '--obfuscate, --split-debug-info, ProGuard, flutter symbolize',
      Icons.security,
      Colors.brown,
      CodeObfuscationDemo(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phase 8 — Deployment & DevOps'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Phase summary ─────────────────────────────────────────────────
          Card(
            color: Colors.teal.shade50,
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Phase 8 turns your app from "runs on my machine" into '
                '"published on the Play Store and monitored in production".\n\n'
                'After this phase you can:\n'
                '• Build dev/staging/prod variants from one codebase\n'
                '• Sign and publish to the Play Store from CI automatically\n'
                '• Monitor crashes and usage in real time\n'
                '• Protect your code with obfuscation',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Topic list ────────────────────────────────────────────────────
          ..._topics.map((topic) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: topic.color.withOpacity(0.15),
                      child: Icon(topic.icon, color: topic.color, size: 22),
                    ),
                    title: Text(topic.label,
                        style:
                            const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(topic.subtitle,
                        style: const TextStyle(fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => topic.destination),
                    ),
                  ),
                ),
              )),

          const Divider(height: 24),

          // ── Milestone card ────────────────────────────────────────────────
          Card(
            color: Colors.teal,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: const [
                  Icon(Icons.emoji_events, color: Colors.white, size: 32),
                  SizedBox(height: 6),
                  Text(
                    '🏆 Milestone 3',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Production-ready — advanced + tested + published',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Data model for a menu item.
class _TopicItem {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget destination;

  const _TopicItem(
      this.label, this.subtitle, this.icon, this.color, this.destination);
}
