/// Entry point Phase 9 — Portfolio & Job Ready.
///
/// Phase 9 is the culmination of the entire Zero to Hero journey.
/// You apply everything from Phases 0–8 into production-quality apps
/// that you can proudly show to any recruiter or interviewer.
///
/// **Topics:**
/// 1. Portfolio Planning      — what makes a strong portfolio, project checklist
/// 2. Clean Architecture Review — quick recap of layers, Repository, Use Cases
/// 3. Production Patterns     — AsyncState, retry, offline-first, pagination, debounce
/// 4. GitHub Best Practices   — Conventional Commits, branching, tags, profile README
/// 5. Interview Prep          — 20 Q&A covering Dart, Flutter, state, testing, patterns
///
/// **Mini Project: Personal Finance Manager**
/// A full portfolio app demonstrating all Phase 0–8 skills:
/// - Clean Architecture (data / domain / presentation)
/// - Riverpod state management
/// - Custom Painter charts (bar chart, donut chart)
/// - Slivers (collapsing app bar on dashboard)
/// - Hive local DB with offline-first support
/// - Firebase sync (architecture ready — swap local repo impl for Firebase impl)
/// - Unit tested domain layer (see test/phase9/)
/// - Production patterns: AsyncState, budget alerts, optimistic UI
///
/// How to run:
/// ```bash
/// # Topic menu
/// flutter run -t lib/phase9/main_phase9.dart
///
/// # Portfolio app directly
/// flutter run -t lib/phase9/mini_projects/personal_finance/personal_finance_app.dart
/// ```
import 'package:flutter/material.dart';

import '01_portfolio_planning/portfolio_planning_demo.dart';
import '02_clean_architecture_review/clean_architecture_review_demo.dart';
import '03_production_patterns/production_patterns_demo.dart';
import '04_github_best_practices/github_best_practices_demo.dart';
import '05_interview_prep/interview_prep_demo.dart';
import 'mini_projects/personal_finance/personal_finance_app.dart';

void main() => runApp(const Phase9MenuApp());

/// Root widget for Phase 9 menu.
class Phase9MenuApp extends StatelessWidget {
  const Phase9MenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phase 9 — Portfolio & Job Ready',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Phase9MenuScreen(),
    );
  }
}

/// Menu listing all Phase 9 topics + portfolio app launcher.
class Phase9MenuScreen extends StatelessWidget {
  const Phase9MenuScreen({super.key});

  static const _topics = [
    _TopicItem(
      '01 — Portfolio Planning',
      'What makes a strong portfolio, GitHub checklist, app ideas',
      Icons.work,
      Colors.deepPurple,
      PortfolioPlanningDemo(),
    ),
    _TopicItem(
      '02 — Clean Architecture Review',
      'Layer responsibilities, Entity/DTO, Repository, Use Cases, DI',
      Icons.architecture,
      Colors.deepOrange,
      CleanArchitectureReviewDemo(),
    ),
    _TopicItem(
      '03 — Production Patterns',
      'AsyncState, retry, offline-first, pagination, debounce, optimistic UI',
      Icons.settings_suggest,
      Colors.green,
      ProductionPatternsDemo(),
    ),
    _TopicItem(
      '04 — GitHub Best Practices',
      'Conventional Commits, branching, tags, profile README',
      Icons.code,
      Colors.blueGrey,
      GitHubBestPracticesDemo(),
    ),
    _TopicItem(
      '05 — Interview Prep',
      '20 Q&A: Dart, Flutter, state, performance, testing, patterns',
      Icons.quiz,
      Colors.indigo,
      InterviewPrepDemo(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phase 9 — Portfolio & Job Ready'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Phase summary ─────────────────────────────────────────────
          Card(
            color: Colors.deepPurple.shade50,
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                'Phase 9 is where theory becomes your career.\n\n'
                'Build 2–3 polished apps, clean up your GitHub profile, '
                'and prepare your answers for the technical interview.\n\n'
                'After Phase 9, you have a Flutter portfolio that speaks '
                'for itself.',
                style: TextStyle(fontSize: 13, height: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 16),

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
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
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

          // ── Portfolio app card ────────────────────────────────────────
          Card(
            color: Colors.green.shade50,
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF1B8A5A),
                child: Text('💰',
                    style: TextStyle(fontSize: 20)),
              ),
              title: const Text(
                'Portfolio App: Personal Finance Manager',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Full app — dashboard, transactions, wallets, '
                'budget, analytics. Clean Architecture + Custom Painter.',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PersonalFinanceApp(),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Milestone banner ──────────────────────────────────────────
          Card(
            color: Colors.deepPurple,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: const [
                  Icon(Icons.emoji_events, color: Colors.amber, size: 36),
                  SizedBox(height: 8),
                  Text(
                    '🏆 Milestone — Zero to Hero Complete',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'You started with Dart basics and now you can build, '
                    'test, and ship production-quality Flutter apps.\n'
                    "What's next? Phase 10 - choose your specialization track.",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
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
