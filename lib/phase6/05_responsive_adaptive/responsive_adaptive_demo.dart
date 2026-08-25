/// Phase 6 — Topic 05: Responsive & Adaptive Layout
///
/// **Responsive** = the layout *resizes and reflows* to fit any screen size.
/// **Adaptive**   = the layout *changes its widget type / pattern* based on
///                  the platform or screen category (phone vs tablet vs desktop).
///
/// Rule of thumb:
/// - Phone → single column, bottom nav bar
/// - Tablet (>= 600px) → two column, side rail or drawer
/// - Desktop (>= 1200px) → three column, full sidebar
///
/// Flutter's tools for responsive/adaptive layout:
/// 1. [MediaQuery]       — screen size, orientation, pixel density, text scale
/// 2. [LayoutBuilder]    — available width/height within a specific parent widget
/// 3. [Flexible] / [Expanded] — fill proportional space in Row/Column
/// 4. [FractionallySizedBox] — size relative to parent (e.g. 50% width)
/// 5. [AdaptiveLayout] (flutter_adaptive_scaffold pkg) — recommended for nav patterns
///
/// Key breakpoints (Material Design 3):
///   Compact  < 600px   → phone portrait
///   Medium   600–840px → phone landscape / small tablet
///   Expanded > 840px   → tablet / desktop
///
/// How to run:
/// ```bash
/// flutter run -t lib/phase6/main_phase6.dart
/// ```

import 'package:flutter/material.dart';

/// Standalone entry point so this file can be run directly:
/// ```bash
/// flutter run -t phase6/05_responsive_adaptive/responsive_adaptive_demo.dart
/// ```
void main() => runApp(_StandaloneApp());

/// Minimal app wrapper used only when running this file directly.
class _StandaloneApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ResponsiveAdaptiveDemo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const ResponsiveAdaptiveDemo(),
    );
  }
}


/// Demo screen that shows responsive techniques side by side.
class ResponsiveAdaptiveDemo extends StatefulWidget {
  const ResponsiveAdaptiveDemo({super.key});

  @override
  State<ResponsiveAdaptiveDemo> createState() => _ResponsiveAdaptiveDemoState();
}

class _ResponsiveAdaptiveDemoState extends State<ResponsiveAdaptiveDemo> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // ── MediaQuery: read device metrics ─────────────────────────────────────
    // Always read once per build, not inside callbacks.
    final mq = MediaQuery.of(context);
    final screenW = mq.size.width;
    final screenH = mq.size.height;
    final isLandscape = mq.orientation == Orientation.landscape;

    // ── Breakpoint classification ────────────────────────────────────────────
    // Use a helper function so the logic is reusable everywhere.
    final layout = _LayoutSize.of(screenW);

    return Scaffold(
      appBar: AppBar(
        title: const Text('05 — Responsive & Adaptive'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      // ── Adaptive navigation pattern ──────────────────────────────────────
      // Phone: BottomNavigationBar
      // Tablet/wide: NavigationRail on the side
      body: layout == _LayoutSize.compact
          ? _PhoneLayout(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (i) => setState(() => _selectedIndex = i),
              screenW: screenW,
              screenH: screenH,
              isLandscape: isLandscape,
            )
          : _TabletLayout(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (i) => setState(() => _selectedIndex = i),
              screenW: screenW,
              screenH: screenH,
              layout: layout,
            ),
    );
  }
}

// ── Layout helpers ─────────────────────────────────────────────────────────────

/// Breakpoint enum following Material Design 3 guidelines.
enum _LayoutSize {
  compact,  // < 600px  — phone
  medium,   // 600–840  — small tablet / phone landscape
  expanded; // > 840px  — tablet / desktop

  /// Factory: classifies a width into a [_LayoutSize].
  static _LayoutSize of(double width) {
    if (width < 600) return compact;
    if (width < 840) return medium;
    return expanded;
  }
}

// ── Phone layout (compact) ─────────────────────────────────────────────────────

/// Phone layout uses a [BottomNavigationBar] and a single-column body.
class _PhoneLayout extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final double screenW;
  final double screenH;
  final bool isLandscape;

  const _PhoneLayout({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.screenW,
    required this.screenH,
    required this.isLandscape,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Main content ───────────────────────────────────────────────
        Expanded(
          child: _ContentArea(
            selectedIndex: selectedIndex,
            screenW: screenW,
            screenH: screenH,
            isLandscape: isLandscape,
          ),
        ),
        // ── Bottom navigation bar (phone pattern) ─────────────────────
        NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
            NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ],
    );
  }
}

// ── Tablet / wide layout ───────────────────────────────────────────────────────

/// Tablet layout uses a [NavigationRail] on the side and shows content in columns.
class _TabletLayout extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final double screenW;
  final double screenH;
  final _LayoutSize layout;

  const _TabletLayout({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.screenW,
    required this.screenH,
    required this.layout,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ── Side rail (tablet pattern) ─────────────────────────────────
        // On expanded screens we can show labels on the rail (extended=true).
        NavigationRail(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          // Show labels only on wide screens
          extended: layout == _LayoutSize.expanded,
          destinations: const [
            NavigationRailDestination(
                icon: Icon(Icons.home), label: Text('Home')),
            NavigationRailDestination(
                icon: Icon(Icons.search), label: Text('Search')),
            NavigationRailDestination(
                icon: Icon(Icons.person), label: Text('Profile')),
          ],
        ),
        const VerticalDivider(width: 1),
        // ── Content fills remaining width ─────────────────────────────
        Expanded(
          child: _ContentArea(
            selectedIndex: selectedIndex,
            screenW: screenW,
            screenH: screenH,
            isLandscape: true, // tablet is always "wide"
          ),
        ),
      ],
    );
  }
}

// ── Content area ───────────────────────────────────────────────────────────────

/// The main content that shows all responsive technique demonstrations.
class _ContentArea extends StatelessWidget {
  final int selectedIndex;
  final double screenW;
  final double screenH;
  final bool isLandscape;

  const _ContentArea({
    required this.selectedIndex,
    required this.screenW,
    required this.screenH,
    required this.isLandscape,
  });

  @override
  Widget build(BuildContext context) {
    final layout = _LayoutSize.of(screenW);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── 1. MediaQuery info ─────────────────────────────────────────
        _section('1. MediaQuery', Colors.teal),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow('Screen width', '${screenW.toStringAsFixed(0)} px'),
                _infoRow('Screen height', '${screenH.toStringAsFixed(0)} px'),
                _infoRow('Orientation', isLandscape ? 'Landscape' : 'Portrait'),
                _infoRow('Breakpoint', layout.name.toUpperCase()),
                _infoRow('Pixel ratio', MediaQuery.of(context).devicePixelRatio.toStringAsFixed(2)),
                _infoRow('Text scale', MediaQuery.of(context).textScaler.scale(1).toStringAsFixed(2)),
                _infoRow('Padding top (safe area)', '${MediaQuery.of(context).padding.top.toStringAsFixed(0)} px'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        _codeSnippet(
          'final mq = MediaQuery.of(context);\n'
          'final width = mq.size.width;           // screen width in logical px\n'
          'final height = mq.size.height;\n'
          'final isLandscape = mq.orientation == Orientation.landscape;\n'
          'final safeTop = mq.padding.top;        // status bar height\n'
          'final textScale = mq.textScaler.scale(1); // user\'s font size pref\n'
          'final pixelRatio = mq.devicePixelRatio;',
        ),

        const SizedBox(height: 20),

        // ── 2. LayoutBuilder ──────────────────────────────────────────
        _section('2. LayoutBuilder', Colors.indigo),
        const Text(
          'LayoutBuilder gives you the AVAILABLE space inside a specific parent, '
          'not the full screen. Useful inside cards, sidebars, dialogs, etc.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        // Constrain this to 60% width to show LayoutBuilder measuring parent
        FractionallySizedBox(
          widthFactor: 0.65,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // constraints.maxWidth is the available width of THIS widget
              final w = constraints.maxWidth;
              return Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  border: Border.all(color: Colors.indigo),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Available: ${w.toStringAsFixed(0)} px\n'
                  '(65% of parent)',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.indigo, fontSize: 12),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        _codeSnippet(
          'LayoutBuilder(\n'
          '  builder: (context, constraints) {\n'
          '    // constraints.maxWidth = available width (not screen width!)\n'
          '    if (constraints.maxWidth < 400) return _NarrowLayout();\n'
          '    return _WideLayout();\n'
          '  },\n'
          ')',
        ),

        const SizedBox(height: 20),

        // ── 3. Responsive grid ────────────────────────────────────────
        _section('3. Responsive Grid (columns by width)', Colors.green),
        LayoutBuilder(
          builder: (context, constraints) {
            // Adjust column count based on available width
            final crossAxisCount = constraints.maxWidth < 400
                ? 2
                : constraints.maxWidth < 700
                    ? 3
                    : 4;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: 8,
              itemBuilder: (_, i) => Container(
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15 + i * 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text('$crossAxisCount cols',
                    style: const TextStyle(fontSize: 11)),
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        _codeSnippet(
          'LayoutBuilder(builder: (context, constraints) {\n'
          '  final cols = constraints.maxWidth < 400 ? 2\n'
          '             : constraints.maxWidth < 700 ? 3 : 4;\n'
          '  return GridView.builder(\n'
          '    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(\n'
          '      crossAxisCount: cols,\n'
          '    ),\n'
          '    ...\n'
          '  );\n'
          '})',
        ),

        const SizedBox(height: 20),

        // ── 4. Adaptive navigation pattern ───────────────────────────
        _section('4. Adaptive Navigation Pattern', Colors.orange),
        Card(
          color: Colors.orange.shade50,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current layout: ${layout.name.toUpperCase()}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('Compact  → BottomNavigationBar  (< 600px)'),
                const Text('Medium   → NavigationRail compact  (600–840px)'),
                const Text('Expanded → NavigationRail extended (> 840px)'),
                const SizedBox(height: 8),
                Text(
                  'Resize the window or rotate device to see the layout change!',
                  style: TextStyle(
                      color: Colors.orange.shade800,
                      fontStyle: FontStyle.italic,
                      fontSize: 12),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),
        Card(
          color: Colors.teal.shade50,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Key Takeaways',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('• MediaQuery = full screen size. LayoutBuilder = available parent size'),
                Text('• Breakpoints: compact < 600, medium 600–840, expanded > 840'),
                Text('• Phone → BottomNavBar. Tablet → NavigationRail. Desktop → Drawer'),
                Text('• FractionallySizedBox: set size as % of parent — no hardcoded px'),
                Text('• Always read MediaQuery once per build, not inside callbacks'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _section(String title, Color color) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(title,
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: color)),
      );

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            Text(value,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      );

  Widget _codeSnippet(String code) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.all(10),
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
}
