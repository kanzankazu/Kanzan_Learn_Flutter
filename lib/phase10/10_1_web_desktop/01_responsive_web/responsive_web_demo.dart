/// Phase 10.1 — Topic 01: Responsive Web
///
/// Flutter Web apps must look great at every viewport width — from a
/// 360px mobile browser to a 2560px ultrawide monitor.
///
/// This is different from Phase 6 "Responsive & Adaptive" which focused on
/// phone vs tablet. Web adds:
/// - Mouse hover states (no hover on mobile)
/// - Right-click / context menus
/// - Keyboard navigation and focus management
/// - URL-based state (users can bookmark / share any "page")
/// - Browser back/forward button expectations
/// - Text selection (users expect to copy text on web)
/// - Cursor changes (pointer on clickable items)
///
/// Key concepts covered:
/// 1. Web breakpoints — compact / medium / expanded + ultra-wide
/// 2. [MouseRegion] — hover effects for desktop/web
/// 3. [SelectionArea] — enable text selection across a subtree
/// 4. [Tooltip] improvements for web (no long-press needed)
/// 5. [ScrollConfiguration] — web scroll physics (drag vs mouse wheel)
/// 6. [FocusTraversalGroup] — logical tab order for keyboard users
/// 7. [kIsWeb] — conditional rendering for web-only features
/// 8. Fluid grids — [Wrap] + [LayoutBuilder] for masonry-style layouts
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

void main() => runApp(const _StandaloneApp());

class _StandaloneApp extends StatelessWidget {
  const _StandaloneApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Responsive Web Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ResponsiveWebDemo(),
    );
  }
}

/// Demo screen covering responsive web patterns.
class ResponsiveWebDemo extends StatelessWidget {
  const ResponsiveWebDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('01 — Responsive Web'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      // SelectionArea wraps the entire screen so users can select/copy any text.
      // Essential for web — users always expect text to be selectable.
      body: SelectionArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── 1. Web breakpoints ───────────────────────────────────────
            _header('1. Web Breakpoints', Colors.blue),
            _WebBreakpointDisplay(),
            _code('''
// Web breakpoint system (extends Material 3 breakpoints):
//
//  Compact   < 600px   → phone layout (single column)
//  Medium    600–840px → tablet / portrait
//  Expanded  840–1200px → desktop standard
//  UltraWide > 1200px  → wide monitor (max content width, centered)
//
// Key difference from mobile: ultrawide screens need a MAX WIDTH constraint.
// Without it, content stretches uncomfortably across a 27" monitor.

Widget build(BuildContext context) {
  return LayoutBuilder(builder: (_, constraints) {
    final w = constraints.maxWidth;

    // On ultra-wide screens, center the content at a max width
    if (w > 1200) {
      return Center(
        child: SizedBox(
          width: 1200,    // max content width — matches most design specs
          child: _content(),
        ),
      );
    }
    return _content();
  });
}'''),

            const SizedBox(height: 20),

            // ── 2. MouseRegion — hover effects ───────────────────────────
            _header('2. MouseRegion — Hover Effects', Colors.teal),
            const Text(
              'On web/desktop, users hover over elements before clicking. '
              'Hover states communicate interactivity.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _HoverCard(
                  title: 'Hover me',
                  subtitle: 'Watch the color change',
                  color: Colors.blue,
                ),
                _HoverCard(
                  title: 'And me too',
                  subtitle: 'Cursor becomes a pointer',
                  color: Colors.teal,
                ),
                _HoverCard(
                  title: 'Interactive',
                  subtitle: 'Scale on hover',
                  color: Colors.purple,
                  scaleOnHover: true,
                ),
              ],
            ),
            _code('''
class _HoverCard extends StatefulWidget { ... }

class _HoverCardState extends State<_HoverCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      // Change cursor to pointer — communicates this is clickable
      cursor: SystemMouseCursors.click,
      // Track hover state
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        // Slightly elevated appearance on hover
        decoration: BoxDecoration(
          color: _hovered
              ? widget.color.withOpacity(0.15)
              : Colors.white,
          boxShadow: _hovered
              ? [BoxShadow(color: widget.color.withOpacity(0.3),
                           blurRadius: 12, offset: Offset(0, 4))]
              : [],
        ),
        child: Text(widget.title),
      ),
    );
  }
}

// Cursors for different contexts:
SystemMouseCursors.click     // clickable items, buttons, links
SystemMouseCursors.text      // text fields, selectable text
SystemMouseCursors.grab      // draggable items
SystemMouseCursors.resizeRow // resize handles
SystemMouseCursors.forbidden // disabled items'''),

            const SizedBox(height: 20),

            // ── 3. SelectionArea ─────────────────────────────────────────
            _header('3. SelectionArea — Text Selection', Colors.orange),
            _code('''
// Wrap your entire page (or any subtree) in SelectionArea to allow
// users to select, copy, and search text — standard web behavior.
//
// WITHOUT SelectionArea:
// Users cannot select any text → bad UX on web
//
// WITH SelectionArea:
// All Text widgets inside become selectable automatically.

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: SelectionArea(        // ← wrap once at the top level
      child: _PageContent(),    // all Text inside is now selectable
    ),
  );
}

// Disable selection for specific widgets:
SelectionContainer.disabled(
  child: Text("This text is NOT selectable"),
)'''),

            const SizedBox(height: 20),

            // ── 4. Fluid grid ─────────────────────────────────────────────
            _header('4. Fluid Grid with Wrap', Colors.green),
            const Text(
              'Wrap automatically flows items into new rows when the width runs out. '
              'Unlike GridView, items can have different widths.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            _FluidGrid(),
            _code('''
// Wrap = fluid grid — items flow naturally, no fixed column count
LayoutBuilder(builder: (_, constraints) {
  // Calculate ideal item width based on available space
  final columns = (constraints.maxWidth / 200).floor().clamp(1, 6);
  final itemWidth = (constraints.maxWidth - (columns - 1) * 12) / columns;

  return Wrap(
    spacing: 12,      // horizontal gap between items
    runSpacing: 12,   // vertical gap between rows
    children: items.map((item) => SizedBox(
      width: itemWidth,
      child: ItemCard(item: item),
    )).toList(),
  );
})'''),

            const SizedBox(height: 20),

            // ── 5. kIsWeb guards ─────────────────────────────────────────
            _header('5. kIsWeb — Platform-Specific UI', Colors.purple),
            _code('''
import 'package:flutter/foundation.dart' show kIsWeb;

// Show different UI depending on whether we are running on web
Widget build(BuildContext context) {
  return Column(
    children: [
      // This runs on every platform
      const Text("Cross-platform content"),

      // Web-only feature (e.g. download button, share to clipboard)
      if (kIsWeb)
        ElevatedButton(
          onPressed: _downloadAsCsv,
          child: const Text("Download CSV"),
        ),

      // Mobile-only feature (e.g. share sheet)
      if (!kIsWeb)
        ElevatedButton(
          onPressed: _shareViaSheet,
          child: const Text("Share"),
        ),
    ],
  );
}

// Current platform:
print(kIsWeb);                        // true on web
print(defaultTargetPlatform);         // TargetPlatform.windows / linux / macOS
print(Theme.of(context).platform);   // same, but via BuildContext'''),

            const SizedBox(height: 20),

            // ── 6. Scroll physics ─────────────────────────────────────────
            _header('6. Web Scroll Physics', Colors.red),
            _code('''
// Web scroll uses different physics by default:
// - Desktop browser: mouse wheel scrolls (ClampingScrollPhysics)
// - Touch browser: fling scrolling (BouncingScrollPhysics)
//
// Flutter Web automatically handles this. But you can override:

ScrollConfiguration.of(context).copyWith(
  // Remove the glowing overscroll indicator (looks wrong on web)
  overscroll: false,
  // Use mouse drag for desktop browsers
  dragDevices: {
    PointerDeviceKind.mouse,
    PointerDeviceKind.touch,
    PointerDeviceKind.trackpad,
  },
)

// Apply globally in your app:
MaterialApp(
  builder: (context, child) => ScrollConfiguration(
    behavior: _WebScrollBehavior(),
    child: child!,
  ),
)

class _WebScrollBehavior extends ScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,    // allow drag-to-scroll with mouse on web
  };
}'''),

            const SizedBox(height: 16),
            _card(
              color: Colors.blue.shade50,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Key Takeaways',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('• Always cap content width at ~1200px on ultra-wide screens'),
                  Text('• Wrap every page in SelectionArea — text selection is expected on web'),
                  Text('• MouseRegion + SystemMouseCursors communicates interactivity'),
                  Text('• kIsWeb flag allows platform-specific features'),
                  Text('• Wrap widget creates fluid grids without fixed column counts'),
                  Text('• Web scroll needs dragDevices to include mouse for drag scrolling'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Live demo widgets ──────────────────────────────────────────────────────────

/// Shows the current breakpoint category based on screen width.
class _WebBreakpointDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final (label, color) = switch (w) {
        < 600 => ('Compact (< 600px)', Colors.orange),
        < 840 => ('Medium (600–840px)', Colors.blue),
        < 1200 => ('Expanded (840–1200px)', Colors.green),
        _ => ('Ultra-wide (> 1200px)', Colors.purple),
      };

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.monitor, color: color),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current breakpoint: $label',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: color)),
                Text('Width: ${w.toStringAsFixed(0)}px',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text('Running on web: $kIsWeb',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
      );
    });
  }
}

/// Card that changes appearance when hovered with the mouse.
class _HoverCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final Color color;
  final bool scaleOnHover;

  const _HoverCard({
    required this.title,
    required this.subtitle,
    required this.color,
    this.scaleOnHover = false,
  });

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      // cursor changes to a pointer hand when hovering — signals interactivity
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: (_hovered && widget.scaleOnHover) ? 1.04 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 150,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _hovered
                ? widget.color.withOpacity(0.12)
                : Colors.grey.shade50,
            border: Border.all(
              color: _hovered ? widget.color : Colors.grey.shade200,
              width: _hovered ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _hovered ? widget.color : Colors.black87)),
              const SizedBox(height: 4),
              Text(widget.subtitle,
                  style: TextStyle(
                      fontSize: 11,
                      color: _hovered
                          ? widget.color.withOpacity(0.8)
                          : Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fluid grid that re-flows as the container width changes.
class _FluidGrid extends StatelessWidget {
  static const _items = [
    ('Dashboard', Icons.dashboard, Colors.blue),
    ('Analytics', Icons.bar_chart, Colors.orange),
    ('Users', Icons.people, Colors.green),
    ('Settings', Icons.settings, Colors.purple),
    ('Reports', Icons.description, Colors.teal),
    ('Billing', Icons.payment, Colors.red),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      // Aim for ~160px wide items, at least 2 columns
      final columns =
          (constraints.maxWidth / 160).floor().clamp(2, 6);
      final itemW =
          (constraints.maxWidth - (columns - 1) * 8) / columns;

      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _items
            .map((item) => SizedBox(
                  width: itemW,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(item.$2, color: item.$3, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(item.$1,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ))
            .toList(),
      );
    });
  }
}

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

