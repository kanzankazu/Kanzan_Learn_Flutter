/// Entry point Phase 10.2 — Track 2: Advanced State Management
///
/// Track 2 pushes Riverpod and state management to the production level.
/// You already know Riverpod basics from Phase 3. This track covers the
/// tools that Flutter Lead developers use on large, complex apps.
///
/// **Topics:**
/// 01. Riverpod Generator  — @riverpod annotation, code-gen, build_runner
/// 02. Offline-First Advanced — sync queue, conflict resolution, connectivity_plus
/// 03. CRDT               — G-Counter, LWW-Register, OR-Set, crdt package
/// 04. State Machines      — FSM with sealed classes + Riverpod, guard transitions
///
/// **Mini Project: Collaborative Notes**
/// Offline-first notes app with CRDT-style sync, sync queue, and real-time
/// connectivity monitoring.
///
/// How to run:
/// ```bash
/// flutter run -t lib/phase10/10_2_advanced_state/main_phase10_2.dart
/// flutter run -t lib/phase10/10_2_advanced_state/mini_projects/collaborative_notes/collaborative_notes_app.dart
/// ```
import 'package:flutter/material.dart';

import '01_riverpod_generator/riverpod_generator_demo.dart';
import '02_offline_first_advanced/offline_first_advanced_demo.dart';
import '03_crdt/crdt_demo.dart';
import '04_state_machines/state_machines_demo.dart';
import 'mini_projects/collaborative_notes/collaborative_notes_app.dart';

void main() => runApp(const Phase102MenuApp());

class Phase102MenuApp extends StatelessWidget {
  const Phase102MenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phase 10.2 — Advanced State',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Phase102MenuScreen(),
    );
  }
}

class Phase102MenuScreen extends StatelessWidget {
  const Phase102MenuScreen({super.key});

  static const _topics = [
    _TopicItem('01 — Riverpod Generator',
        '@riverpod annotation, code-gen, AsyncNotifier, family, keepAlive',
        Icons.code, Colors.deepPurple, RiverpodGeneratorDemo()),
    _TopicItem('02 — Offline-First Advanced',
        'Sync queue, conflict resolution, connectivity_plus, back-off',
        Icons.cloud_sync, Colors.green, OfflineFirstAdvancedDemo()),
    _TopicItem('03 — CRDT',
        'G-Counter, LWW-Register, OR-Set, crdt package, HLC timestamps',
        Icons.merge_type, Colors.purple, CrdtDemo()),
    _TopicItem('04 — State Machines',
        'FSM sealed classes, guard transitions, testing, payment flow',
        Icons.device_hub, Colors.indigo, StateMachinesDemo()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phase 10.2 — Advanced State'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.deepPurple.shade50,
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                'Track 2 teaches you how to manage complex state at scale.\n\n'
                '• Generate providers instead of writing boilerplate\n'
                '• Build apps that work offline and sync when connected\n'
                '• Prevent conflicts with CRDT data structures\n'
                '• Model complex workflows as state machines',
                style: TextStyle(fontSize: 13, height: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ..._topics.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: t.color.withAlpha(38),
                      child: Icon(t.icon, color: t.color, size: 20),
                    ),
                    title: Text(t.label,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(t.subtitle,
                        style: const TextStyle(fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                        context, MaterialPageRoute(builder: (_) => t.dest)),
                  ),
                ),
              )),
          const Divider(height: 24),
          Card(
            color: Colors.amber.shade50,
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.amber,
                child: Icon(Icons.note, color: Colors.white),
              ),
              title: const Text('Mini Project: Collaborative Notes',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text(
                  'Offline-first with sync queue, CRDT conflict resolution, and connectivity monitoring'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CollaborativeNotesApp())),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopicItem {
  final String label, subtitle;
  final IconData icon;
  final Color color;
  final Widget dest;
  const _TopicItem(this.label, this.subtitle, this.icon, this.color, this.dest);
}
