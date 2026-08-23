/// Entry point Phase 3 — State Management & Navigation.
///
/// Phase 3 covers two major topics that are essential in Flutter:
/// 1. **GoRouter** — modern navigation with named routes, deep linking,
///    passing data, bottom navigation, and nested navigator.
/// 2. **Riverpod** — type-safe, testable, and scalable state management.
///    Covers Provider, StateNotifierProvider, and AsyncNotifierProvider.
///
/// How to run:
/// ```bash
/// flutter run -t lib/phase3/main_phase3.dart
/// ```
///
/// Topics:
/// - 01: Named Routes & GoRouter Basics
/// - 02: Passing Data Between Screens
/// - 03: Bottom Navigation + Nested Navigator
/// - 04: Deep Linking
/// - 05: Riverpod (Provider, StateNotifier, AsyncNotifier)
/// - 06: Local State vs Global State
/// - 07: BLoC (Cubit, Bloc, BlocBuilder, BlocListener)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '01_go_router_basics/go_router_basics_demo.dart';
import '02_passing_data/passing_data_demo.dart';
import '03_bottom_nav/bottom_nav_demo.dart';
import '04_deep_linking/deep_linking_demo.dart';
import '05_riverpod/riverpod_demo.dart';
import '06_local_vs_global/local_vs_global_demo.dart';
import '07_bloc/bloc_demo.dart';

void main() {
  // ProviderScope must wrap the entire app when using Riverpod.
  // It acts as the "container" where all providers live.
  runApp(const ProviderScope(child: Phase3MenuApp()));
}

/// Root widget for the Phase 3 menu.
/// Does not use GoRouter here to keep the menu simple —
/// each demo has its own router demonstrated internally.
class Phase3MenuApp extends StatelessWidget {
  const Phase3MenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phase 3 — State & Navigation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const Phase3MenuScreen(),
    );
  }
}

/// Phase 3 topic list. Tap any item to open its demo.
class Phase3MenuScreen extends StatelessWidget {
  const Phase3MenuScreen({super.key});

  // Menu data — label, icon, and demo widget.
  static const _topics = [
    _TopicItem('01 — GoRouter Basics', Icons.route, GoRouterBasicsDemo()),
    _TopicItem('02 — Passing Data', Icons.swap_horiz, PassingDataDemo()),
    _TopicItem('03 — Bottom Nav + Nested Navigator', Icons.tab, BottomNavDemo()),
    _TopicItem('04 — Deep Linking', Icons.link, DeepLinkingDemo()),
    _TopicItem(
      '05 — Riverpod (Provider, StateNotifier, Async)',
      Icons.cloud_sync,
      RiverpodDemo(),
    ),
    _TopicItem('06 — Local vs Global State', Icons.compare_arrows, LocalVsGlobalDemo()),
    _TopicItem(
      '07 — BLoC (Cubit, Bloc, BlocBuilder, BlocListener)',
      Icons.account_tree,
      BlocDemoApp(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phase 3 — State & Navigation'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _topics.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final topic = _topics[index];
          return Card(
            child: ListTile(
              leading: Icon(topic.icon, color: Colors.indigo),
              title: Text(topic.label),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => topic.demo),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Simple model for a menu item.
class _TopicItem {
  final String label;
  final IconData icon;
  final Widget demo;
  const _TopicItem(this.label, this.icon, this.demo);
}
