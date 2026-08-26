// Kanzan Learn Flutter — Hub Utama
//
// File ini adalah pintu masuk utama ke semua phase pembelajaran.
// Jalankan dengan: `flutter run -t lib/main.dart`
//
// Catatan:
// - Phase 0 & 1 adalah CLI apps (Dart murni) — harus dijalankan dengan:
//     dart run lib/phase0/main_phase0.dart
//     dart run lib/phase1/main_phase1.dart
// - Phase 2–10 bisa dibuka langsung dari menu ini.
import 'package:flutter/material.dart';

// Phase 2–9 imports (Flutter apps)
import 'phase2/main_phase2.dart' as phase2;
import 'phase3/main_phase3.dart' as phase3;
import 'phase4/main_phase4.dart' as phase4;
import 'phase5/main_phase5.dart' as phase5;
import 'phase6/main_phase6.dart' as phase6;
import 'phase7/main_phase7.dart' as phase7;
import 'phase8/main_phase8.dart' as phase8;
import 'phase9/main_phase9.dart' as phase9;

// Phase 10 — Specialization tracks
import 'phase10/10_1_web_desktop/main_phase10_1.dart' as phase10_1;
import 'phase10/10_2_advanced_state/main_phase10_2.dart' as phase10_2;
import 'phase10/10_3_native_interop/main_phase10_3.dart' as phase10_3;
import 'phase10/10_4_performance/main_phase10_4.dart' as phase10_4;
import 'phase10/10_5_super_app/main_phase10_5.dart' as phase10_5;
import 'phase10/10_6_backend/main_phase10_6.dart' as phase10_6;
import 'phase10/10_7_ai_ml/main_phase10_7.dart' as phase10_7;

void main() {
  runApp(const KanzanLearnFlutterApp());
}

/// Root app — langsung menampilkan Hub screen.
class KanzanLearnFlutterApp extends StatelessWidget {
  const KanzanLearnFlutterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kanzan Learn Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HubScreen(),
    );
  }
}

// ============================================================
// Data model untuk tiap phase
// ============================================================

/// Representasi satu phase di hub menu.
class _PhaseEntry {
  final String label;
  final String subtitle;
  final String track;
  final Color color;
  final IconData icon;

  /// [app] adalah widget root dari phase tersebut.
  /// Null berarti CLI-only (tidak bisa dibuka sebagai Flutter widget).
  final Widget? app;

  /// Perintah CLI untuk phase yang tidak bisa dibuka sebagai Flutter app.
  final String? cliCommand;

  const _PhaseEntry({
    required this.label,
    required this.subtitle,
    required this.track,
    required this.color,
    required this.icon,
    this.app,
    this.cliCommand,
  });
}

// ============================================================
// Daftar semua phase
// ============================================================

/// Semua phase dari Phase 0 sampai Phase 10 terdaftar di sini.
///
/// Untuk menambah phase baru:
/// 1. Import main file-nya di bagian atas
/// 2. Tambah entry baru ke list ini
const List<_PhaseEntry> _phases = [
  _PhaseEntry(
    label: 'Phase 0',
    subtitle: 'Fondasi Pemrograman Dart',
    track: 'Beginner',
    color: Color(0xFF4CAF50),
    icon: Icons.code,
    // CLI only — tidak bisa di-embed sebagai Flutter widget
    cliCommand: 'dart run lib/phase0/main_phase0.dart',
  ),
  _PhaseEntry(
    label: 'Phase 1',
    subtitle: 'Dart Language (Null Safety, Async, Generics)',
    track: 'Beginner',
    color: Color(0xFF8BC34A),
    icon: Icons.terminal,
    cliCommand: 'dart run lib/phase1/main_phase1.dart',
  ),
  _PhaseEntry(
    label: 'Phase 2',
    subtitle: 'Flutter Fundamentals',
    track: 'Beginner',
    color: Color(0xFF03A9F4),
    icon: Icons.widgets,
    app: phase2.Phase2MenuApp(),
  ),
  _PhaseEntry(
    label: 'Phase 3',
    subtitle: 'State Management & Navigation',
    track: 'Intermediate',
    color: Color(0xFF9C27B0),
    icon: Icons.account_tree,
    app: phase3.Phase3MenuApp(),
  ),
  _PhaseEntry(
    label: 'Phase 4',
    subtitle: 'Networking & Data',
    track: 'Intermediate',
    color: Color(0xFFFF5722),
    icon: Icons.cloud,
    app: phase4.Phase4MenuApp(),
  ),
  _PhaseEntry(
    label: 'Phase 5',
    subtitle: 'Architecture & Clean Code',
    track: 'Intermediate',
    color: Color(0xFF795548),
    icon: Icons.architecture,
    app: phase5.Phase5MenuApp(),
  ),
  _PhaseEntry(
    label: 'Phase 6',
    subtitle: 'Advanced Flutter',
    track: 'Advanced',
    color: Color(0xFFE91E63),
    icon: Icons.auto_awesome,
    app: phase6.Phase6MenuApp(),
  ),
  _PhaseEntry(
    label: 'Phase 7',
    subtitle: 'Testing',
    track: 'Advanced',
    color: Color(0xFF009688),
    icon: Icons.bug_report,
    app: phase7.Phase7MenuApp(),
  ),
  _PhaseEntry(
    label: 'Phase 8',
    subtitle: 'Deployment & DevOps',
    track: 'Advanced',
    color: Color(0xFF607D8B),
    icon: Icons.rocket_launch,
    app: phase8.Phase8MenuApp(),
  ),
  _PhaseEntry(
    label: 'Phase 9',
    subtitle: 'Portfolio & Job Ready',
    track: 'Expert',
    color: Color(0xFFFF9800),
    icon: Icons.work,
    app: phase9.Phase9MenuApp(),
  ),
  _PhaseEntry(
    label: 'Phase 10.1',
    subtitle: 'Web & Desktop',
    track: 'Expert — Specialization',
    color: Color(0xFF00BCD4),
    icon: Icons.web,
    app: phase10_1.Phase101MenuApp(),
  ),
  _PhaseEntry(
    label: 'Phase 10.2',
    subtitle: 'Advanced State Management',
    track: 'Expert — Specialization',
    color: Color(0xFF673AB7),
    icon: Icons.layers,
    app: phase10_2.Phase102MenuApp(),
  ),
  _PhaseEntry(
    label: 'Phase 10.3',
    subtitle: 'Native Interop',
    track: 'Expert — Specialization',
    color: Color(0xFF2196F3),
    icon: Icons.phone_android,
    app: phase10_3.Phase103MenuApp(),
  ),
  _PhaseEntry(
    label: 'Phase 10.4',
    subtitle: 'Performance',
    track: 'Expert — Specialization',
    color: Color(0xFFF44336),
    icon: Icons.speed,
    app: phase10_4.Phase104MenuApp(),
  ),
  _PhaseEntry(
    label: 'Phase 10.5',
    subtitle: 'Super App Architecture',
    track: 'Expert — Specialization',
    color: Color(0xFF3F51B5),
    icon: Icons.apps,
    app: phase10_5.Phase105MenuApp(),
  ),
  _PhaseEntry(
    label: 'Phase 10.6',
    subtitle: 'Backend Integration',
    track: 'Expert — Specialization',
    color: Color(0xFFE91E63),
    icon: Icons.dns,
    app: phase10_6.Phase106MenuApp(),
  ),
  _PhaseEntry(
    label: 'Phase 10.7',
    subtitle: 'AI / ML Mobile',
    track: 'Expert — Specialization',
    color: Color(0xFFFF5722),
    icon: Icons.psychology,
    app: phase10_7.Phase107MenuApp(),
  ),
];

// ============================================================
// Hub Screen
// ============================================================

/// Layar utama yang menampilkan semua phase dalam bentuk card.
class HubScreen extends StatelessWidget {
  const HubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Kanzan Learn Flutter',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary,
                      colorScheme.secondary,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Info strip: Phase 0 & 1 CLI notice
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _CliNoticeCard(),
            ),
          ),

          // Phase cards
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList.separated(
              itemCount: _phases.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _PhaseCard(entry: _phases[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Komponen UI
// ============================================================

/// Card info bahwa Phase 0 & 1 harus dijalankan via CLI.
class _CliNoticeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: colorScheme.onSecondaryContainer, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Phase 0 & 1 adalah CLI apps. Jalankan lewat terminal, bukan dari menu ini.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card satu phase — bisa di-tap untuk buka app atau lihat CLI command.
class _PhaseCard extends StatelessWidget {
  final _PhaseEntry entry;

  const _PhaseCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCli = entry.app == null;

    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isCli
            ? () => _showCliDialog(context)
            : () => _openPhase(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon badge
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: entry.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(entry.icon, color: entry.color, size: 28),
              ),
              const SizedBox(width: 14),

              // Label & subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          entry.label,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // CLI badge
                        if (isCli)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorScheme.tertiaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'CLI',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onTertiaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entry.subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Track label
                    Text(
                      entry.track,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: entry.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow / CLI icon
              Icon(
                isCli ? Icons.terminal : Icons.arrow_forward_ios,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Buka phase sebagai full-screen Flutter app.
  void _openPhase(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => entry.app!),
    );
  }

  /// Tampilkan dialog berisi CLI command untuk phase CLI-only.
  void _showCliDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${entry.label} — CLI Only'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Phase ini adalah Dart CLI. Jalankan perintah ini di terminal:'),
            const SizedBox(height: 12),
            // Command box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                entry.cliCommand ?? '',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
