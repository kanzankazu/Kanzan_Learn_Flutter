/// Entry point Phase 10.1 — Track 1: Web & Desktop
///
/// Track 1 covers everything needed to ship a Flutter app on web and desktop.
/// You already know how to build Flutter apps (Phases 0–9). This track teaches
/// the web/desktop-specific skills on top of that foundation.
///
/// **Topics:**
/// 01. Responsive Web     — breakpoints, MouseRegion, SelectionArea, fluid grid
/// 02. PWA                — manifest.json, service worker, install prompt
/// 03. Web-Specific APIs  — URL strategy, clipboard, JS interop, file download
/// 04. Desktop Layout     — adaptive nav, master-detail, keyboard shortcuts, D&D
/// 05. Dart Frog          — server-side Dart, file-based routing, middleware
/// 06. Web Performance    — renderer comparison, tree-shaking, deferred loading
///
/// **Mini Project: Admin Dashboard**
/// A full responsive admin dashboard demonstrating all Track 1 skills:
/// - Sidebar nav → NavigationRail → BottomNav based on width
/// - KPI cards with hover effects (MouseRegion)
/// - Bar chart and donut chart (Custom Painter)
/// - Data table with sort/filter/pagination (PaginatedDataTable)
/// - Keyboard shortcuts (Alt+1–5)
/// - SelectionArea for text selection on web
///
/// How to run (web recommended):
/// ```bash
/// # Topic menu
/// flutter run -d chrome -t lib/phase10/10_1_web_desktop/main_phase10_1.dart
///
/// # Dashboard directly
/// flutter run -d chrome -t lib/phase10/10_1_web_desktop/mini_projects/dashboard_app/dashboard_app.dart
/// ```
import 'package:flutter/material.dart';

import '01_responsive_web/responsive_web_demo.dart';
import '02_pwa/pwa_demo.dart';
import '03_web_specific_apis/web_specific_apis_demo.dart';
import '04_desktop_layout/desktop_layout_demo.dart';
import '05_dart_frog/dart_frog_demo.dart';
import '06_flutter_web_performance/web_performance_demo.dart';
import 'mini_projects/dashboard_app/dashboard_app.dart';

void main() => runApp(const Phase101MenuApp());

/// Root widget for Phase 10.1 menu.
class Phase101MenuApp extends StatelessWidget {
  const Phase101MenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phase 10.1 — Web & Desktop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const Phase101MenuScreen(),
    );
  }
}

/// Menu listing all Phase 10.1 topics and the mini project.
class Phase101MenuScreen extends StatelessWidget {
  const Phase101MenuScreen({super.key});

  static const _topics = [
    _TopicItem(
      '01 — Responsive Web',
      'Breakpoints, MouseRegion hover, SelectionArea, fluid grid, kIsWeb',
      Icons.web,
      Colors.blue,
      ResponsiveWebDemo(),
    ),
    _TopicItem(
      '02 — Progressive Web App',
      'manifest.json, service worker, install prompt, Lighthouse audit',
      Icons.install_mobile,
      Colors.indigo,
      PwaDemo(),
    ),
    _TopicItem(
      '03 — Web-Specific APIs',
      'URL strategy, clipboard, JS interop, file download',
      Icons.api,
      Colors.teal,
      WebSpecificApisDemo(),
    ),
    _TopicItem(
      '04 — Desktop Layout',
      'Adaptive nav, master-detail, keyboard shortcuts, drag & drop',
      Icons.desktop_windows,
      Colors.blueGrey,
      DesktopLayoutDemo(),
    ),
    _TopicItem(
      '05 — Dart Frog',
      'Server-side Dart, file-based routing, middleware, shared models',
      Icons.cloud,
      Colors.brown,
      DartFrogDemo(),
    ),
    _TopicItem(
      '06 — Web Performance',
      'CanvasKit vs Skwasm, tree-shaking, deferred loading, Lighthouse',
      Icons.speed,
      Colors.red,
      WebPerformanceDemo(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phase 10.1 — Web & Desktop'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SelectionArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Track overview ────────────────────────────────────────
            Card(
              color: Colors.blue.shade50,
              child: const Padding(
                padding: EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Track 1: Web & Desktop',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    SizedBox(height: 6),
                    Text(
                      'Build Flutter apps that work great in the browser '
                      '(Chrome, Firefox, Safari) and as native desktop apps '
                      '(Windows, macOS, Linux).\n\n'
                      'You already know Flutter. This track adds web/desktop-specific '
                      'skills: responsive layouts for large screens, mouse/keyboard '
                      'interactions, PWA installability, JS interop, and a server-side '
                      'Dart API with Dart Frog.',
                      style: TextStyle(fontSize: 13, height: 1.5),
                    ),
                    SizedBox(height: 10),
                    Text('Best run on Chrome or macOS for full experience.',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Topic list ────────────────────────────────────────────
            ..._topics.map((topic) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: topic.color.withAlpha(38),
                        child: Icon(topic.icon,
                            color: topic.color, size: 22),
                      ),
                      title: Text(topic.label,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold)),
                      subtitle: Text(topic.subtitle,
                          style: const TextStyle(fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => topic.destination),
                      ),
                    ),
                  ),
                )),

            const Divider(height: 24),

            // ── Mini project card ─────────────────────────────────────
            Card(
              color: Colors.blue.shade50,
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF2563EB),
                  child: Icon(Icons.dashboard,
                      color: Colors.white, size: 20),
                ),
                title: const Text('Mini Project: Admin Dashboard',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text(
                  'Responsive sidebar nav, KPI cards, bar/donut charts, '
                  'data table with sort/filter/pagination, keyboard shortcuts',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DashboardApp(),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Run commands ──────────────────────────────────────────
            Card(
              color: Colors.grey.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('How to Run',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    SelectableText(
                      '# Topic menu\n'
                      'flutter run -d chrome -t lib/phase10/10_1_web_desktop/main_phase10_1.dart\n\n'
                      '# Dashboard mini project (recommended on Chrome or macOS)\n'
                      'flutter run -d chrome -t lib/phase10/10_1_web_desktop/mini_projects/dashboard_app/dashboard_app.dart\n'
                      'flutter run -d macos  -t lib/phase10/10_1_web_desktop/mini_projects/dashboard_app/dashboard_app.dart\n\n'
                      '# Build for web production\n'
                      'flutter build web --release --web-renderer skwasm',
                      style: TextStyle(
                          fontFamily: 'monospace', fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
