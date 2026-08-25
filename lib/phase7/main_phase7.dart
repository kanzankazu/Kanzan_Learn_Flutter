/// Entry point Phase 7 — Testing.
///
/// Phase 7 teaches you how to verify that everything you built in phases 1–6
/// actually works correctly — and keeps working as the codebase grows.
///
/// Good tests are your safety net: they let you refactor, add features, and
/// fix bugs with confidence, knowing you'll catch regressions automatically.
///
/// **Topics:**
/// 1. Unit Test       — test(), expect(), matchers, setUp/tearDown, async tests
/// 2. Widget Test     — testWidgets(), Finder, pump/pumpAndSettle, interactions
/// 3. Integration Test— full app on real device, IntegrationTestWidgetsFlutterBinding
/// 4. Mocking         — mockito vs mocktail, when/verify, Mock vs Fake
/// 5. Code Coverage   — flutter test --coverage, genhtml, CI enforcement
/// 6. Golden Test     — matchesGoldenFile, --update-goldens, golden_toolkit
///
/// **Test pyramid:**
/// ```
///    ▲  Integration  — few, slow, full confidence
///   ■■■ Widget       — moderate, medium speed
///  ●●●●● Unit        — many, fast, isolated
/// ```
///
/// How to run the demo app:
/// ```bash
/// flutter run -t lib/phase7/main_phase7.dart
/// ```
///
/// How to run the actual tests (in test/phase7/):
/// ```bash
/// flutter test test/phase7/
/// flutter test --coverage
/// ```
import 'package:flutter/material.dart';

import '01_unit_test/unit_test_demo.dart';
import '02_widget_test/widget_test_demo.dart';
import '03_integration_test/integration_test_demo.dart';
import '04_mocking/mocking_demo.dart';
import '05_code_coverage/code_coverage_demo.dart';
import '06_golden_test/golden_test_demo.dart';

void main() => runApp(const Phase7MenuApp());

/// Root widget for Phase 7 menu.
class Phase7MenuApp extends StatelessWidget {
  const Phase7MenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phase 7 — Testing',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const Phase7MenuScreen(),
    );
  }
}

/// Menu listing all Phase 7 topics.
class Phase7MenuScreen extends StatelessWidget {
  const Phase7MenuScreen({super.key});

  static const _topics = [
    _TopicItem(
      '01 — Unit Test',
      'test(), expect(), matchers, group, setUp/tearDown, async',
      Icons.science,
      Colors.blue,
      UnitTestDemo(),
    ),
    _TopicItem(
      '02 — Widget Test',
      'testWidgets(), Finder, pump/pumpAndSettle, interactions',
      Icons.widgets,
      Colors.green,
      WidgetTestDemo(),
    ),
    _TopicItem(
      '03 — Integration Test',
      'Full app on real device, IntegrationTestWidgetsFlutterBinding',
      Icons.phonelink,
      Colors.deepOrange,
      IntegrationTestDemo(),
    ),
    _TopicItem(
      '04 — Mocking',
      'mockito vs mocktail, when/verify, Mock vs Fake vs Stub',
      Icons.swap_horiz,
      Colors.purple,
      MockingDemo(),
    ),
    _TopicItem(
      '05 — Code Coverage',
      'flutter test --coverage, genhtml, CI thresholds',
      Icons.bar_chart,
      Colors.cyan,
      CodeCoverageDemo(),
    ),
    _TopicItem(
      '06 — Golden Test',
      'matchesGoldenFile, --update-goldens, golden_toolkit',
      Icons.image,
      Colors.amber,
      GoldenTestDemo(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phase 7 — Testing'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Phase summary ─────────────────────────────────────────────
          Card(
            color: Colors.blue.shade50,
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Phase 7 is about confidence. Tests let you ship fast without '
                'breaking things. After this phase you\'ll be able to write unit, '
                'widget, and integration tests — and enforce coverage in CI.\n\n'
                'The real test files are in test/phase7/. '
                'The files in lib/phase7/ explain the concepts interactively.',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Topic list ────────────────────────────────────────────────
          ..._topics.map((topic) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: topic.color.withOpacity(0.15),
                      child: Icon(topic.icon, color: topic.color, size: 22),
                    ),
                    title: Text(topic.label,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
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

          // ── Quick command reference ───────────────────────────────────
          Card(
            color: Colors.grey.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Quick Commands',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  SelectableText(
                    'flutter test                    # run all tests\n'
                    'flutter test test/phase7/       # run phase7 tests only\n'
                    'flutter test --coverage         # with coverage\n'
                    'flutter test --name "login"     # filter by test name\n'
                    'flutter test --update-goldens   # regenerate golden files',
                    style: TextStyle(fontFamily: 'monospace', fontSize: 11),
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
