/// Phase 10.1 — Mini Project: Admin Dashboard
///
/// A production-quality responsive Admin Dashboard demonstrating all
/// Track 1 (Web & Desktop) skills working together:
///
/// ┌────────────────────────────────────────────────────────────────────────┐
/// │  Skills demonstrated                                                    │
/// │                                                                         │
/// │  Responsive  3-column sidebar nav (> 1100px), rail (> 600px), drawer  │
/// │  Desktop     Master-detail, keyboard shortcuts, context menu           │
/// │  Web         SelectionArea, MouseRegion hover, custom scroll behavior  │
/// │  PWA-ready   Offline-capable architecture, installable                │
/// │  Performance Deferred loading pattern, lazy data loading              │
/// │  Custom Paint Bar charts, line sparklines, donut summary chart        │
/// └────────────────────────────────────────────────────────────────────────┘
///
/// App screens:
/// - Dashboard  — KPI cards + bar chart + recent activity
/// - Users      — Data table with sort/filter/pagination
/// - Products   — Grid view with search
/// - Orders     — List with status filter
/// - Settings   — Form with toggles
///
/// How to run (Chrome gives best web experience):
/// ```bash
/// flutter run -d chrome -t lib/phase10/10_1_web_desktop/mini_projects/dashboard_app/dashboard_app.dart
/// flutter run -d macos  -t lib/phase10/10_1_web_desktop/mini_projects/dashboard_app/dashboard_app.dart
/// ```
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

import 'screens/dashboard_screen.dart';
import 'screens/users_screen.dart';
import 'screens/products_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/settings_screen.dart';

void main() => runApp(const DashboardApp());

/// Root widget for the Admin Dashboard.
class DashboardApp extends StatelessWidget {
  const DashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Dashboard',
      debugShowCheckedModeBanner: false,
      // Dark color scheme — common for admin dashboards
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB), // indigo-600
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        // Tighter density for data-heavy screens
        visualDensity: VisualDensity.compact,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        visualDensity: VisualDensity.compact,
      ),
      themeMode: ThemeMode.system,
      home: const _DashboardShell(),
    );
  }
}

// ── Shell ──────────────────────────────────────────────────────────────────────

/// Top-level scaffold with adaptive navigation and keyboard shortcuts.
class _DashboardShell extends StatefulWidget {
  const _DashboardShell();

  @override
  State<_DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<_DashboardShell> {
  int _selectedIndex = 0;

  // Navigation destinations shared across all layout sizes
  static const _destinations = [
    _NavItem(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: 'Dashboard',
    ),
    _NavItem(
      icon: Icons.people_outlined,
      selectedIcon: Icons.people,
      label: 'Users',
    ),
    _NavItem(
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2,
      label: 'Products',
    ),
    _NavItem(
      icon: Icons.shopping_cart_outlined,
      selectedIcon: Icons.shopping_cart,
      label: 'Orders',
    ),
    _NavItem(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: 'Settings',
    ),
  ];

  // Screens — kept alive in IndexedStack so scroll positions persist
  static const _screens = [
    AdminDashboardScreen(),
    UsersScreen(),
    ProductsScreen(),
    OrdersScreen(),
    DashboardSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        // Numeric shortcuts to jump to sections: Alt+1 through Alt+5
        LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.digit1):
            const _SelectNavIntent(0),
        LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.digit2):
            const _SelectNavIntent(1),
        LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.digit3):
            const _SelectNavIntent(2),
        LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.digit4):
            const _SelectNavIntent(3),
        LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.digit5):
            const _SelectNavIntent(4),
      },
      child: Actions(
        actions: {
          _SelectNavIntent: CallbackAction<_SelectNavIntent>(
            onInvoke: (intent) =>
                setState(() => _selectedIndex = intent.index),
          ),
        },
        child: Focus(
          autofocus: true,
          child: SelectionArea(
            // Wrap everything so text is selectable on web (standard behavior)
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;

                if (w < 600) {
                  // ── Compact: BottomNavigationBar ───────────────────────
                  return Scaffold(
                    body: IndexedStack(
                      index: _selectedIndex,
                      children: _screens,
                    ),
                    bottomNavigationBar: NavigationBar(
                      selectedIndex: _selectedIndex,
                      onDestinationSelected: (i) =>
                          setState(() => _selectedIndex = i),
                      destinations: _destinations
                          .map((d) => NavigationDestination(
                                icon: Icon(d.icon),
                                selectedIcon: Icon(d.selectedIcon),
                                label: d.label,
                              ))
                          .toList(),
                    ),
                  );
                } else if (w < 1100) {
                  // ── Medium: compact NavigationRail ─────────────────────
                  return Scaffold(
                    body: Row(
                      children: [
                        NavigationRail(
                          selectedIndex: _selectedIndex,
                          onDestinationSelected: (i) =>
                              setState(() => _selectedIndex = i),
                          extended: false,
                          destinations: _destinations
                              .map((d) => NavigationRailDestination(
                                    icon: Icon(d.icon),
                                    selectedIcon: Icon(d.selectedIcon),
                                    label: Text(d.label),
                                  ))
                              .toList(),
                        ),
                        const VerticalDivider(width: 1),
                        Expanded(
                          child: IndexedStack(
                            index: _selectedIndex,
                            children: _screens,
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  // ── Wide: extended NavigationRail with labels ───────────
                  return Scaffold(
                    body: Row(
                      children: [
                        // Sidebar with labels + app branding
                        _Sidebar(
                          destinations: _destinations,
                          selectedIndex: _selectedIndex,
                          onDestinationSelected: (i) =>
                              setState(() => _selectedIndex = i),
                        ),
                        const VerticalDivider(width: 1),
                        Expanded(
                          child: IndexedStack(
                            index: _selectedIndex,
                            children: _screens,
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sidebar ────────────────────────────────────────────────────────────────────

/// Full-width sidebar with branding, nav items, and user profile.
class _Sidebar extends StatelessWidget {
  final List<_NavItem> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const _Sidebar({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 220,
      color: scheme.surface,
      child: Column(
        children: [
          // ── App branding ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.bolt,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Text('AdminKit',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: scheme.onSurface)),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // ── Nav items ───────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: destinations.length,
              itemBuilder: (_, i) {
                final dest = destinations[i];
                final isSelected = i == selectedIndex;
                return _SidebarTile(
                  icon: isSelected ? dest.selectedIcon : dest.icon,
                  label: dest.label,
                  isSelected: isSelected,
                  onTap: () => onDestinationSelected(i),
                  shortcut: 'Alt+${i + 1}',
                );
              },
            ),
          ),

          const Divider(height: 1),

          // ── User profile at the bottom ──────────────────────────────
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.blue,
                  child: Text('F',
                      style: TextStyle(
                          color: Colors.white, fontSize: 13)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Faisal Bahri',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                      Text('Admin',
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                const Icon(Icons.more_vert, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual sidebar navigation tile with hover effect.
class _SidebarTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final String shortcut;

  const _SidebarTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.shortcut,
  });

  @override
  State<_SidebarTile> createState() => _SidebarTileState();
}

class _SidebarTileState extends State<_SidebarTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Tooltip(
        message: '${widget.label}  (${widget.shortcut})',
        preferBelow: false,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            margin: const EdgeInsets.symmetric(vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? scheme.primaryContainer
                  : _hovered
                      ? scheme.surfaceContainerHighest
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  size: 18,
                  color: widget.isSelected
                      ? scheme.onPrimaryContainer
                      : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: widget.isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: widget.isSelected
                        ? scheme.onPrimaryContainer
                        : scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Intent & data models ───────────────────────────────────────────────────────

class _SelectNavIntent extends Intent {
  final int index;
  const _SelectNavIntent(this.index);
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}
