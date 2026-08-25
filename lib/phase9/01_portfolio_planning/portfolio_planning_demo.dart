/// Phase 9 — Topic 01: Portfolio Planning
///
/// A portfolio is NOT just a collection of code — it is your argument to a
/// recruiter that you can build real apps, write clean code, and ship.
///
/// This topic covers:
/// 1. What makes a strong Flutter portfolio vs a weak one
/// 2. How to choose which projects to build
/// 3. Project structure every portfolio app must have
/// 4. GitHub profile setup: pinned repos, profile README, badges
/// 5. App store presence: why published apps stand out
/// 6. The recruiter's checklist — what they actually look at
/// 7. Common portfolio mistakes and how to avoid them
///
/// Key question to ask yourself before adding any project:
///   "Does this demonstrate a skill that a Flutter dev job requires?"
/// If the answer is no — don't include it.
import 'package:flutter/material.dart';

/// Standalone entry point — run this file to see the concepts.
void main() => runApp(const _StandaloneApp());

class _StandaloneApp extends StatelessWidget {
  const _StandaloneApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portfolio Planning',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const PortfolioPlanningDemo(),
    );
  }
}

/// Interactive guide to planning a strong Flutter portfolio.
class PortfolioPlanningDemo extends StatefulWidget {
  const PortfolioPlanningDemo({super.key});

  @override
  State<PortfolioPlanningDemo> createState() => _PortfolioPlanningDemoState();
}

class _PortfolioPlanningDemoState extends State<PortfolioPlanningDemo> {
  // Track which checklist items have been completed by the learner.
  // Each key maps to a checklist category, each value is a list of checked bools.
  final Map<String, List<bool>> _checklists = {
    'project_quality': List.filled(7, false),
    'github_profile': List.filled(6, false),
    'app_structure': List.filled(8, false),
  };

  /// Toggle a checklist item on / off.
  void _toggle(String category, int index) {
    setState(() => _checklists[category]![index] = !_checklists[category]![index]);
  }

  /// Count how many items in a category are checked.
  int _score(String category) =>
      _checklists[category]!.where((v) => v).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('01 — Portfolio Planning'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Overview ──────────────────────────────────────────────────────
          _card(
            color: Colors.deepPurple.shade50,
            child: const Text(
              'Phase 9 goal: build 2–3 production-quality apps that prove '
              'you can solve real problems with Flutter.\n\n'
              'Quality beats quantity. One polished app with clean architecture, '
              'tests, and a published APK is worth more than ten tutorial clones.',
              style: TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(height: 20),

          // ── 1. Strong vs weak portfolio ───────────────────────────────────
          _header('1. Strong vs Weak Portfolio', Colors.deepPurple),
          _comparisonTable(
            leftTitle: '❌ Weak',
            rightTitle: '✅ Strong',
            rows: const [
              ('Tutorial clones (TodoApp, Counter)', 'Solves a real problem you care about'),
              ('Hardcoded JSON data', 'Real API integration (REST/Firebase)'),
              ('setState everywhere', 'Riverpod / BLoC with proper state management'),
              ('No error handling', 'Loading / error / success states on every screen'),
              ('No tests at all', '≥ 70% unit test coverage on business logic'),
              ('README is just "flutter run"', 'Screenshots, GIF demo, features list, setup'),
              ('Flat file structure', 'Clean Architecture: data / domain / presentation'),
            ],
          ),
          const SizedBox(height: 20),

          // ── 2. Recommended portfolio apps ─────────────────────────────────
          _header('2. Recommended Portfolio Apps', Colors.indigo),
          const Text(
            'Pick 2–3 from different domains so you show breadth of skill.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          ..._portfolioApps.map((app) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(app.emoji,
                            style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(app.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                        // Difficulty badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: app.difficultyColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: app.difficultyColor),
                          ),
                          child: Text(app.difficulty,
                              style: TextStyle(
                                  fontSize: 10, color: app.difficultyColor)),
                        ),
                      ]),
                      const SizedBox(height: 6),
                      // Skills demonstrated as chips
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: app.skills
                            .map((s) => Chip(
                                  label: Text(s,
                                      style: const TextStyle(fontSize: 10)),
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              )),

          const SizedBox(height: 20),

          // ── 3. Interactive checklist: project quality ──────────────────────
          _header('3. Project Quality Checklist', Colors.teal),
          const Text(
            'Every portfolio app should pass this checklist before you publish it.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          _checklistSection(
            category: 'project_quality',
            items: const [
              'Clean Architecture (data / domain / presentation layers)',
              'Dependency injection via get_it or Riverpod providers',
              'Proper error handling: loading / error / success on every async call',
              'Unit tests for all use cases and repository logic (≥ 70% coverage)',
              'No hardcoded strings — use constants or l10n',
              'Works offline (at least shows cached data with a stale indicator)',
              'Signed release APK available for download (or published on Play Store)',
            ],
          ),

          const SizedBox(height: 20),

          // ── 4. Interactive checklist: GitHub profile ───────────────────────
          _header('4. GitHub Profile Checklist', Colors.green),
          _checklistSection(
            category: 'github_profile',
            items: const [
              'Profile README with photo, bio, skills, and contact',
              'Pinned repos: only your 3–6 best projects',
              'Each repo has a clear description (shown under the repo name)',
              'Each repo has topics/tags (flutter, dart, riverpod, etc.)',
              'Consistent commit history (regular activity, not all on one day)',
              'At least one repo has a CI badge (passing)',
            ],
          ),

          const SizedBox(height: 20),

          // ── 5. Required files per repo ─────────────────────────────────────
          _header('5. Required Files in Every Portfolio Repo', Colors.orange),
          _checklistSection(
            category: 'app_structure',
            items: const [
              'README.md — screenshots/GIF, features, setup, architecture diagram',
              'LICENSE (MIT for open source)',
              '.gitignore — excludes build/, *.jks, key.properties, .env',
              'pubspec.yaml — proper app name, description, version',
              'lib/core/config/app_config.dart — centralized env config',
              'lib/core/error/ — custom exceptions and error handling',
              'test/ — at minimum unit tests for domain layer',
              'CHANGELOG.md or GitHub Releases with version history',
            ],
          ),

          const SizedBox(height: 20),

          // ── 6. README template ─────────────────────────────────────────────
          _header('6. Portfolio README Template', Colors.red),
          _code('''
# 💰 Personal Finance Manager

> Track income, expenses, budgets, and net worth — all in one app.
> Built with Flutter · Clean Architecture · Riverpod · Firebase

[![CI](https://github.com/username/finance-app/actions/workflows/ci.yml/badge.svg)](...)
[![Coverage](https://codecov.io/gh/username/finance-app/badge.svg)](...)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B)](https://flutter.dev)

## 📱 Screenshots

| Home | Transactions | Budget | Analytics |
|------|-------------|--------|-----------|
| ![home](screenshots/home.png) | ![tx](screenshots/tx.png) | ... | ... |

## ✨ Features

- Multi-wallet (cash, bank, e-wallet)
- Real-time Firebase sync
- Budget limits with alerts
- Monthly trend charts (fl_chart)
- Export to CSV / PDF
- Offline-first with Isar local DB

## 🏗️ Architecture

Clean Architecture (data / domain / presentation)
State management: Riverpod
DI: get_it + injectable

## 🚀 Getting Started

\`\`\`bash
git clone https://github.com/username/finance-app
cd finance-app
cp .env.example .env   # add your Firebase config
flutter pub get
flutter run
\`\`\`

## 🧪 Tests

\`\`\`bash
flutter test --coverage
\`\`\`

Coverage: ≥ 80% on domain layer

## 📄 License

MIT © 2026 Your Name'''),

          const SizedBox(height: 20),

          // ── Progress summary ───────────────────────────────────────────────
          Card(
            color: Colors.deepPurple.shade50,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  const Text('Your Progress',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _scoreCircle(
                          'Project\nQuality',
                          _score('project_quality'),
                          _checklists['project_quality']!.length,
                          Colors.teal),
                      _scoreCircle(
                          'GitHub\nProfile',
                          _score('github_profile'),
                          _checklists['github_profile']!.length,
                          Colors.green),
                      _scoreCircle(
                          'App\nStructure',
                          _score('app_structure'),
                          _checklists['app_structure']!.length,
                          Colors.orange),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Checklist section builder ────────────────────────────────────────────

  /// Renders an interactive checklist for a given category.
  Widget _checklistSection({
    required String category,
    required List<String> items,
  }) {
    final checks = _checklists[category]!;
    final done = checks.where((v) => v).length;

    return Card(
      child: Column(
        children: [
          // Progress bar at the top of the card
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: done / items.length,
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('$done/${items.length}',
                    style: const TextStyle(
                        fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          // Individual check items
          ...items.asMap().entries.map((e) => CheckboxListTile(
                dense: true,
                value: checks[e.key],
                onChanged: (_) => _toggle(category, e.key),
                title: Text(e.value, style: const TextStyle(fontSize: 12)),
                controlAffinity: ListTileControlAffinity.leading,
              )),
        ],
      ),
    );
  }

  // ── Score circle widget ──────────────────────────────────────────────────

  Widget _scoreCircle(
      String label, int score, int total, Color color) {
    final pct = total == 0 ? 0.0 : score / total;
    return Column(
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: pct,
                strokeWidth: 6,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(color),
              ),
              Center(
                child: Text('$score/$total',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: color)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  // ── Comparison table ─────────────────────────────────────────────────────

  Widget _comparisonTable({
    required String leftTitle,
    required String rightTitle,
    required List<(String, String)> rows,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(1),
          },
          border: TableBorder.all(color: Colors.grey.shade200),
          children: [
            TableRow(
              decoration: const BoxDecoration(color: Color(0xFFF3E5F5)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(leftTitle,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(rightTitle,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            ...rows.map((r) => TableRow(children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(r.$1,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.red)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(r.$2,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.green)),
                  ),
                ])),
          ],
        ),
      ),
    );
  }
}

// ── Portfolio app data ─────────────────────────────────────────────────────────

/// Describes a portfolio project idea.
class _PortfolioApp {
  final String emoji;
  final String name;
  final String difficulty;
  final Color difficultyColor;
  final List<String> skills;

  const _PortfolioApp({
    required this.emoji,
    required this.name,
    required this.difficulty,
    required this.difficultyColor,
    required this.skills,
  });
}

/// List of recommended portfolio projects from the roadmap.
const _portfolioApps = [
  _PortfolioApp(
    emoji: '💰',
    name: 'Personal Finance Manager',
    difficulty: 'Hard',
    difficultyColor: Colors.red,
    skills: [
      'Clean Architecture',
      'Riverpod',
      'Firebase',
      'fl_chart',
      'Isar/SQLite',
      'Export CSV',
      'Unit Tests',
    ],
  ),
  _PortfolioApp(
    emoji: '💬',
    name: 'Chat App (WhatsApp-like)',
    difficulty: 'Hard',
    difficultyColor: Colors.red,
    skills: [
      'Firebase Realtime',
      'Push Notifications',
      'Media upload',
      'Read receipts',
      'Deep links',
    ],
  ),
  _PortfolioApp(
    emoji: '🛍️',
    name: 'E-Commerce App',
    difficulty: 'Hard',
    difficultyColor: Colors.red,
    skills: [
      'Product catalog',
      'Cart + checkout',
      'Payment UI',
      'Order history',
      'Search + filter',
    ],
  ),
  _PortfolioApp(
    emoji: '🌤️',
    name: 'Weather App (Advanced)',
    difficulty: 'Medium',
    difficultyColor: Colors.orange,
    skills: [
      'REST API',
      'Location',
      'Custom Painter charts',
      'Slivers',
      'Offline cache',
    ],
  ),
  _PortfolioApp(
    emoji: '💪',
    name: 'Fitness Tracker',
    difficulty: 'Medium',
    difficultyColor: Colors.orange,
    skills: [
      'Custom Painter rings',
      'Background service',
      'FCM reminders',
      'Health SDK',
      'Charts',
    ],
  ),
  _PortfolioApp(
    emoji: '📰',
    name: 'News Reader App',
    difficulty: 'Easy',
    difficultyColor: Colors.green,
    skills: [
      'Pagination',
      'Hive bookmarks',
      'CachedNetworkImage',
      'WebView',
      'Share',
    ],
  ),
];

// ── Shared helpers ─────────────────────────────────────────────────────────────

Widget _header(String title, Color color) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(title,
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold, color: color)),
    );

Widget _code(String code) => Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(6),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(code,
            style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: Color(0xFFCDD6F4))),
      ),
    );

Widget _card({required Color color, required Widget child}) => Card(
      color: color,
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    );
