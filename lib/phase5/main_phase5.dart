/// Entry point Phase 5 — Architecture & Clean Code.
///
/// Phase 5 covers the structural principles that separate junior Flutter devs
/// from mid/senior ones. None of these topics add visible features — they all
/// improve maintainability, testability, and team scalability.
///
/// **Topics:**
/// 1. SOLID Principles — 5 design rules that guide every class you write
/// 2. Repository Pattern — abstract data access; swap backends without touching UI
/// 3. Clean Architecture — three layers (data/domain/presentation) with strict boundaries
/// 4. Use Cases — when to extract business logic and when NOT to
/// 5. Dependency Injection — get_it service locator: register once, resolve anywhere
/// 6. Error Handling — Result<T> sealed class; no uncaught exceptions in the UI
///
/// **Mini project:**
/// The Phase 4 Weather App, refactored to Clean Architecture.
/// Compare `lib/phase4/mini_projects/weather_app/` vs
/// `lib/phase5/mini_projects/weather_clean/` to see exactly what changes.
///
/// How to run:
/// ```bash
/// flutter run -t lib/phase5/main_phase5.dart
/// ```
library;

import 'package:flutter/material.dart';

import '01_solid/solid_demo.dart';
import '02_repository_pattern/repository_pattern_demo.dart';
import '03_clean_architecture/clean_architecture_demo.dart';
import '04_use_cases/use_cases_demo.dart';
import '05_dependency_injection/di_demo.dart';
import '06_error_handling/error_handling_demo.dart';

void main() => runApp(const Phase5MenuApp());

/// Root widget for Phase 5 menu.
class Phase5MenuApp extends StatelessWidget {
  const Phase5MenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phase 5 — Architecture & Clean Code',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Phase5MenuScreen(),
    );
  }
}

/// Menu that lists all Phase 5 topics with a brief description.
class Phase5MenuScreen extends StatelessWidget {
  const Phase5MenuScreen({super.key});

  static const _topics = [
    _TopicItem(
      '01 — SOLID Principles',
      'SRP, OCP, LSP, ISP, DIP — the 5 rules every class should follow',
      Icons.star,
      Colors.red,
      SolidDemo(),
    ),
    _TopicItem(
      '02 — Repository Pattern',
      'Abstract data access. Swap MySQL → Firebase without touching the UI.',
      Icons.storage,
      Colors.teal,
      RepositoryPatternDemo(),
    ),
    _TopicItem(
      '03 — Clean Architecture',
      'Data / Domain / Presentation layers. Dependencies point inward.',
      Icons.architecture,
      Colors.deepOrange,
      CleanArchitectureDemo(),
    ),
    _TopicItem(
      '04 — Use Cases',
      'When to extract business logic into a Use Case — and when NOT to.',
      Icons.work_outline,
      Colors.indigo,
      UseCasesDemo(),
    ),
    _TopicItem(
      '05 — Dependency Injection',
      'get_it service locator: register once, resolve anywhere.',
      Icons.cable,
      Colors.green,
      DiDemoApp(),
    ),
    _TopicItem(
      '06 — Error Handling',
      'Result<T> sealed class. No uncaught exceptions in the UI.',
      Icons.error_outline,
      Colors.red,
      ErrorHandlingDemo(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phase 5 — Architecture'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Phase summary
          Card(
            color: Colors.deepPurple.shade50,
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Phase 5 teaches you HOW to structure code, not just how to write it.\n'
                'These principles make your app maintainable as it grows to 50+ screens.',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Topic list
          ..._topics.asMap().entries.map((entry) {
            final t = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: t.color.withOpacity(0.15),
                    child: Icon(t.icon, color: t.color, size: 22),
                  ),
                  title: Text(t.label,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(t.subtitle,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => t.demo),
                  ),
                ),
              ),
            );
          }),

          const Divider(height: 24),

          // Mini project entry
          Card(
            color: Colors.deepPurple.shade50,
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.deepPurple,
                child: Icon(Icons.wb_cloudy, color: Colors.white),
              ),
              title: const Text('Mini Project: Weather App (Clean Architecture)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text(
                  'Phase 4 Weather App refactored — same UI, structured code'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) {
                    // Import inline to avoid circular dependency in the menu
                    return const _WeatherCleanLauncher();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple launcher that starts the mini project app within the phase5 menu.
class _WeatherCleanLauncher extends StatelessWidget {
  const _WeatherCleanLauncher();

  @override
  Widget build(BuildContext context) {
    // Navigate to the mini project's own MaterialApp
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (_) {
          // Import here to keep the main menu clean
          // In a real app use named routes or go_router
          return const _WeatherMiniProjectRedirect();
        },
      ),
    );
  }
}

/// Redirects to the mini project entry screen via its own Navigator.
class _WeatherMiniProjectRedirect extends StatelessWidget {
  const _WeatherMiniProjectRedirect();

  @override
  Widget build(BuildContext context) {
    // Directly link to the weather clean screen
    // The mini project has its own DI setup called in its own main()
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Run directly for the full experience:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const SelectableText(
              'flutter run -t lib/phase5/mini_projects/weather_clean/weather_clean_app.dart',
              style: TextStyle(fontFamily: 'monospace', fontSize: 13),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple model for a menu item.
class _TopicItem {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget demo;

  const _TopicItem(
      this.label, this.subtitle, this.icon, this.color, this.demo);
}
