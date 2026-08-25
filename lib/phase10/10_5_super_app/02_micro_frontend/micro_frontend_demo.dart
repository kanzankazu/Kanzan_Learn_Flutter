/// Phase 10.5 — Topic 02: Micro-Frontend Architecture
///
/// Micro-frontend = each feature team ships an independent module that
/// the shell app composes into one app at runtime.
///
/// Key concepts covered:
/// 1. Feature module contract — the interface every module must implement
/// 2. Shell app — discovers and hosts modules
/// 3. Dynamic routing — each module registers its own routes
/// 4. Lazy module loading — deferred imports for code splitting
/// 5. Module isolation — each module has its own DI scope
/// 6. Shared design system — one source of truth for UI components
/// 7. Module registry pattern
import 'package:flutter/material.dart';

void main() => runApp(const _App());

class _App extends StatelessWidget {
  const _App();
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Micro-Frontend',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo), useMaterial3: true),
        home: const MicroFrontendDemo(),
      );
}

class MicroFrontendDemo extends StatelessWidget {
  const MicroFrontendDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('02 — Micro-Frontend'), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(color: Colors.indigo.shade50, child: const Text(
            'Micro-frontend splits a monolithic app into independently deployable '
            'feature modules.\n\n'
            'Shell app = the frame. Feature modules = the content. '
            'Each module is its own Flutter package, developed and tested independently.',
            style: TextStyle(fontSize: 13),
          )),
          const SizedBox(height: 16),

          // ── 1. Feature module contract ─────────────────────────────────
          _h('1. Feature Module Contract', Colors.indigo),
          _code(r'''
// packages/core/lib/module.dart

/// Every feature module MUST implement this interface.
/// The shell app only knows about this contract — never about the module internals.
abstract interface class FeatureModule {
  /// Unique identifier for this module (used in routing and DI)
  String get moduleId;

  /// Human-readable display name
  String get displayName;

  /// Icon shown in the navigation rail / bottom bar
  IconData get icon;

  /// Register this module's Riverpod providers, services, etc.
  /// Called once when the shell app initializes.
  void register(ProviderContainer container);

  /// The routes this module contributes to the app router.
  /// Shell app merges all module routes into a single GoRouter.
  List<RouteBase> get routes;

  /// The entry-point widget for this module's main screen.
  Widget get homeWidget;

  /// Optional: deep link prefixes this module handles
  List<String> get deepLinkPrefixes => const [];

  /// Optional: background tasks to run on app start
  Future<void> onAppStart() async {}
}'''),

          const SizedBox(height: 20),

          // ── 2. Module registration ─────────────────────────────────────
          _h('2. Module Registry + Shell App', Colors.blue),
          _code(r'''
// packages/app/lib/main.dart

// Shell app: imports module packages, registers them, builds the router
void main() {
  // Register all feature modules
  ModuleRegistry.register([
    WalletModule(),   // from package:feature_wallet
    PromoModule(),    // from package:feature_promo
    SettingsModule(), // from package:feature_settings
  ]);

  runApp(
    ProviderScope(
      child: const ShellApp(),
    ),
  );
}

// packages/app/lib/module_registry.dart
class ModuleRegistry {
  static final List<FeatureModule> _modules = [];

  static void register(List<FeatureModule> modules) {
    _modules.addAll(modules);
  }

  static List<FeatureModule> get all => List.unmodifiable(_modules);

  // Build a GoRouter from all registered module routes
  static GoRouter buildRouter() {
    return GoRouter(
      routes: [
        ShellRoute(
          builder: (_, state, child) => ShellScaffold(child: child),
          routes: _modules.expand((m) => m.routes).toList(),
        ),
      ],
    );
  }
}'''),

          const SizedBox(height: 20),

          // ── 3. Feature module implementation ───────────────────────────
          _h('3. Feature Module Implementation', Colors.teal),
          _code(r'''
// packages/feature_wallet/lib/wallet_module.dart

class WalletModule implements FeatureModule {
  @override String get moduleId => 'wallet';
  @override String get displayName => 'Wallet';
  @override IconData get icon => Icons.account_balance_wallet;

  @override
  void register(ProviderContainer container) {
    // Register wallet-specific services in the DI container
    // These providers are only available when wallet is registered
    container.read(walletServiceProvider);  // initialize eagerly
  }

  @override
  List<RouteBase> get routes => [
    GoRoute(
      path: '/wallet',
      builder: (_, __) => const WalletHomeScreen(),
      routes: [
        GoRoute(path: 'transfer', builder: (_, __) => const TransferScreen()),
        GoRoute(path: 'history',  builder: (_, __) => const HistoryScreen()),
      ],
    ),
  ];

  @override
  Widget get homeWidget => const WalletHomeScreen();

  @override
  List<String> get deepLinkPrefixes => ['/wallet'];
}

// Other teams follow the SAME interface:
class PromoModule implements FeatureModule { ... }
class SettingsModule implements FeatureModule { ... }'''),

          const SizedBox(height: 20),

          // ── 4. Shell scaffold ──────────────────────────────────────────
          _h('4. Shell Scaffold — Dynamic Navigation', Colors.orange),
          _code(r'''
// packages/app/lib/shell_scaffold.dart

class ShellScaffold extends ConsumerWidget {
  final Widget child;
  const ShellScaffold({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modules = ModuleRegistry.all;
    final currentPath = GoRouterState.of(context).uri.path;

    // Find currently active module
    final activeIndex = modules.indexWhere(
        (m) => currentPath.startsWith('/${m.moduleId}'));

    return LayoutBuilder(builder: (context, constraints) {
      // Adaptive layout (same pattern as Track 1)
      if (constraints.maxWidth < 600) {
        return Scaffold(
          body: child,
          bottomNavigationBar: NavigationBar(
            selectedIndex: activeIndex.clamp(0, modules.length - 1),
            onDestinationSelected: (i) => context.go('/${modules[i].moduleId}'),
            destinations: modules.map((m) => NavigationDestination(
              icon: Icon(m.icon),
              label: m.displayName,
            )).toList(),
          ),
        );
      }

      // Wide: NavigationRail with labels
      return Scaffold(body: Row(children: [
        NavigationRail(
          selectedIndex: activeIndex.clamp(0, modules.length - 1),
          onDestinationSelected: (i) => context.go('/${modules[i].moduleId}'),
          extended: constraints.maxWidth > 1000,
          destinations: modules.map((m) => NavigationRailDestination(
            icon: Icon(m.icon),
            label: Text(m.displayName),
          )).toList(),
        ),
        Expanded(child: child),
      ]));
    });
  }
}'''),

          const SizedBox(height: 16),
          _card(color: Colors.indigo.shade50, child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Key Takeaways', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• FeatureModule interface = contract between shell and features'),
              Text('• Shell app imports modules but knows nothing about their internals'),
              Text('• Each module contributes routes, providers, and a home widget'),
              Text('• ModuleRegistry.buildRouter() merges all module routes into one GoRouter'),
              Text('• Feature teams can develop/test modules independently'),
              Text('• Add a new feature = create package + implement FeatureModule + register'),
            ],
          )),
        ],
      ),
    );
  }
}

Widget _h(String t, Color c) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(t, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: c)));
Widget _code(String s) => Container(width: double.infinity, margin: const EdgeInsets.only(bottom: 4), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF1E1E2E), borderRadius: BorderRadius.circular(6)), child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text(s, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Color(0xFFCDD6F4)))));
Widget _card({required Color color, required Widget child}) => Card(color: color, child: Padding(padding: const EdgeInsets.all(12), child: child));
