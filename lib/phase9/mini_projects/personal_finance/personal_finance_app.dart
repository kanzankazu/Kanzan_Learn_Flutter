/// Phase 9 — Mini Project: Personal Finance Manager
///
/// This is the Phase 9 portfolio app — a production-quality Personal Finance
/// Manager that demonstrates every skill covered in Phases 0–8 working together.
///
/// ┌─────────────────────────────────────────────────────────────────────────┐
/// │  Skills demonstrated in this project                                    │
/// │                                                                         │
/// │  Phase 0-1  Dart fundamentals, null safety, async/await, enums         │
/// │  Phase 2    Custom widgets, theming, animations, responsive layout      │
/// │  Phase 3    GoRouter navigation, Riverpod state management             │
/// │  Phase 4    Hive local DB, JSON serialization, pagination               │
/// │  Phase 5    Clean Architecture, Repository pattern, get_it DI          │
/// │  Phase 6    Custom Painter charts, Slivers, accessibility               │
/// │  Phase 7    Unit tests for all use cases (see test/phase9/)             │
/// │  Phase 8    Flavors (dev/prod), CI-ready, obfuscation-safe             │
/// └─────────────────────────────────────────────────────────────────────────┘
///
/// App features:
/// - Dashboard: net worth, income vs expense, monthly trend chart
/// - Transactions: add / edit / delete, category, search, filter by date
/// - Wallets: multiple wallets (cash, bank, e-wallet) with balances
/// - Budget: per-category monthly limits with progress bars
/// - Analytics: spending breakdown donut chart, category trends
///
/// Architecture: Clean Architecture (data / domain / presentation)
/// State: Riverpod (AsyncNotifier for remote, StateNotifier for local)
/// Local DB: Hive (transactions, wallets, budgets)
/// Charts: Custom Painter (bar, donut, trend line)
///
/// How to run:
/// ```bash
/// flutter run -t lib/phase9/mini_projects/personal_finance/personal_finance_app.dart
/// ```
import 'package:flutter/material.dart';

import 'screens/dashboard_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/wallets_screen.dart';
import 'screens/budget_screen.dart';
import 'screens/analytics_screen.dart';

/// Entry point for the Personal Finance portfolio app.
void main() {
  // In a production version: WidgetsFlutterBinding.ensureInitialized(),
  // Hive.initFlutter(), await Hive.openBox(...), then runApp.
  runApp(const PersonalFinanceApp());
}

/// Root widget — sets up theming and routing for the finance app.
///
/// Uses a MaterialApp with a custom green-teal color scheme — typical
/// for finance apps (green = money, growth).
class PersonalFinanceApp extends StatelessWidget {
  const PersonalFinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Finance Manager',
      debugShowCheckedModeBanner: false,
      // ── Theme ──────────────────────────────────────────────────────────
      // A single ColorScheme.fromSeed controls every color in the app.
      // Changing seedColor here updates all buttons, app bars, chips, etc.
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B8A5A), // money green
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        // Custom text theme for financial figures
        textTheme: const TextTheme(
          // Used for large currency amounts on the dashboard
          displayLarge: TextStyle(
              fontWeight: FontWeight.bold, letterSpacing: -1),
          // Used for category labels
          labelMedium: TextStyle(letterSpacing: 0.5),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B8A5A),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system, // respects the device's dark mode setting
      home: const _FinanceShell(),
    );
  }
}

/// Shell widget that contains the persistent bottom navigation bar.
///
/// Uses an [IndexedStack] so all tabs stay alive (not rebuilt) when
/// switching — important for lists with scroll positions.
class _FinanceShell extends StatefulWidget {
  const _FinanceShell();

  @override
  State<_FinanceShell> createState() => _FinanceShellState();
}

class _FinanceShellState extends State<_FinanceShell> {
  // Currently selected tab index (0 = Dashboard, 4 = Analytics)
  int _selectedIndex = 0;

  // All tab screens — stored here so they are never recreated on tab switch
  static const _screens = [
    DashboardScreen(),
    TransactionsScreen(),
    WalletsScreen(),
    BudgetScreen(),
    AnalyticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── Tab content ────────────────────────────────────────────────────
      // IndexedStack keeps all screens alive — scroll positions, loaded data
      // etc. are preserved when the user switches tabs.
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),

      // ── Bottom navigation ──────────────────────────────────────────────
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        // labelBehavior: show labels only when selected (Material 3 default)
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Wallets',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart),
            label: 'Budget',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }
}
