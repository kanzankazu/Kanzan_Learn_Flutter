/// Entry point Phase 6 — Advanced Flutter.
///
/// Phase 6 moves beyond UI basics into the tools that separate a Flutter developer
/// who "can build screens" from one who "can build anything".
///
/// **Topics:**
/// 1. Custom Painter — draw anything with Canvas: arcs, paths, charts
/// 2. Slivers        — the scroll primitives: SliverAppBar, SliverList, SliverGrid,
///                     SliverPersistentHeader
/// 3. Advanced Animation — AnimationController, Tween, CurvedAnimation, Stagger
/// 4. Platform Channels  — MethodChannel (one-shot) + EventChannel (stream)
///                         to call native Kotlin/Swift code
/// 5. Responsive & Adaptive — MediaQuery, LayoutBuilder, breakpoints,
///                             phone vs tablet navigation patterns
/// 6. Accessibility — Semantics, MergeSemantics, ExcludeSemantics,
///                    live regions, touch targets
/// 7. Internationalization — ARB files, flutter gen-l10n, intl package,
///                           locale switching, RTL support
///
/// **Mini project (Phase 7 prep):**
/// A Fitness Tracker App shell that combines Custom Painter (progress chart),
/// Slivers (collapsing header), and Responsive layout — run it separately:
/// ```bash
/// flutter run -t lib/phase6/mini_projects/fitness_tracker/fitness_tracker_app.dart
/// ```
///
/// How to run this menu:
/// ```bash
/// flutter run -t lib/phase6/main_phase6.dart
/// ```

import 'package:flutter/material.dart';

import '01_custom_painter/custom_painter_demo.dart';
import '02_slivers/slivers_demo.dart';
import '03_advanced_animation/advanced_animation_demo.dart';
import '04_platform_channels/platform_channels_demo.dart';
import '05_responsive_adaptive/responsive_adaptive_demo.dart';
import '06_accessibility/accessibility_demo.dart';
import '07_internationalization/internationalization_demo.dart';

void main() => runApp(const Phase6MenuApp());

/// Root widget for the Phase 6 menu.
class Phase6MenuApp extends StatelessWidget {
  const Phase6MenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phase 6 — Advanced Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const Phase6MenuScreen(),
    );
  }
}

/// Menu screen listing all Phase 6 topics.
class Phase6MenuScreen extends StatelessWidget {
  const Phase6MenuScreen({super.key});

  // ── Topic definitions ──────────────────────────────────────────────────────
  // Each entry: (label, subtitle, icon, accent color, destination widget)
  static const _topics = [
    _TopicItem(
      '01 — Custom Painter',
      'Draw shapes, progress arcs, bar charts via Canvas API',
      Icons.brush,
      Colors.orange,
      CustomPainterDemo(),
    ),
    _TopicItem(
      '02 — Slivers',
      'SliverAppBar, SliverList, SliverGrid, SliverPersistentHeader',
      Icons.view_list,
      Colors.teal,
      SliversDemo(),
    ),
    _TopicItem(
      '03 — Advanced Animation',
      'AnimationController + Tween + CurvedAnimation + Stagger',
      Icons.animation,
      Colors.deepPurple,
      AdvancedAnimationDemo(),
    ),
    _TopicItem(
      '04 — Platform Channels',
      'MethodChannel (one-shot) + EventChannel (stream)',
      Icons.cable,
      Colors.brown,
      PlatformChannelsDemo(),
    ),
    _TopicItem(
      '05 — Responsive & Adaptive',
      'MediaQuery, LayoutBuilder, phone vs tablet layouts',
      Icons.devices,
      Colors.indigo,
      ResponsiveAdaptiveDemo(),
    ),
    _TopicItem(
      '06 — Accessibility',
      'Semantics, MergeSemantics, ExcludeSemantics, touch targets',
      Icons.accessibility,
      Colors.green,
      AccessibilityDemo(),
    ),
    _TopicItem(
      '07 — Internationalization',
      'ARB files, gen-l10n, intl, locale switching, RTL',
      Icons.language,
      Colors.deepOrange,
      InternationalizationDemo(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phase 6 — Advanced Flutter'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Phase summary card ─────────────────────────────────────────
          Card(
            color: Colors.orange.shade50,
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Phase 6 covers the "advanced" skills that unlock after you can '
                'build screens fluently. Custom drawing, scroll magic, native bridges, '
                'multi-device layouts, screen reader support, and multi-language apps.\n\n'
                'After this phase: Phase 7 (Testing) makes everything you built here '
                'provably correct.',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Topic list ─────────────────────────────────────────────────
          ..._topics.map((topic) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: topic.color.withOpacity(0.15),
                    child: Icon(topic.icon, color: topic.color, size: 22),
                  ),
                  title: Text(
                    topic.label,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    topic.subtitle,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => topic.destination),
                  ),
                ),
              ),
            );
          }),

          const Divider(height: 24),

          // ── Mini project entry ─────────────────────────────────────────
          Card(
            color: Colors.orange.shade50,
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.orange,
                child: Icon(Icons.fitness_center, color: Colors.white),
              ),
              title: const Text(
                'Mini Project: Fitness Tracker App',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Custom Painter progress chart + Slivers + Responsive layout',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const _MiniProjectInfo(),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Quick nav reminder ────────────────────────────────────────
          Card(
            color: Colors.grey.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('How to run each topic directly:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text(
                    'flutter run -t lib/phase6/main_phase6.dart',
                    style: TextStyle(fontFamily: 'monospace', fontSize: 12),
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

// ── Mini project redirect screen ──────────────────────────────────────────────

/// Shows how to run the Fitness Tracker mini project.
class _MiniProjectInfo extends StatelessWidget {
  const _MiniProjectInfo();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Project Info'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.fitness_center, size: 56, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              'Fitness Tracker App',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'This mini project is coming in the next iteration. '
              'It will combine:\n\n'
              '• Custom Painter for animated workout progress rings\n'
              '• Slivers for the collapsing workout header\n'
              '• Responsive layout for phone and tablet\n'
              '• Accessible semantics for all interactive elements\n'
              '• Animated workout timer with stagger entry',
              style: TextStyle(fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 24),
            const Text(
              'Once available, run it with:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const SelectableText(
                'flutter run -t lib/phase6/mini_projects/fitness_tracker/fitness_tracker_app.dart',
                style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Color(0xFFCDD6F4)),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data model for menu items ──────────────────────────────────────────────────

/// Holds metadata for a single topic tile in the menu.
class _TopicItem {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget destination;

  const _TopicItem(
      this.label, this.subtitle, this.icon, this.color, this.destination);
}
