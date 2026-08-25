/// Phase 6 — Topic 02: Slivers
///
/// "Slivers" are the building blocks of Flutter's scrolling system.
/// Every scrollable widget you've used (ListView, GridView, SingleChildScrollView)
/// is secretly composed of slivers under the hood.
///
/// Why learn slivers directly?
/// - Build complex scroll effects that standard widgets can't express
/// - Combine lists + grids + headers in a single smooth scroll
/// - Create collapsing app bars (SliverAppBar)
/// - Add pinned/floating section headers
///
/// Key concepts covered:
/// 1. [CustomScrollView] — the root that hosts a list of slivers
/// 2. [SliverAppBar] — collapsible/expandable app bar tied to scroll
/// 3. [SliverList] — lazy list (like ListView but composable)
/// 4. [SliverGrid] — lazy grid (like GridView but composable)
/// 5. [SliverPersistentHeader] — sticky header that stays pinned while scrolling
/// 6. [SliverToBoxAdapter] — wraps a regular widget inside a sliver context
/// 7. [SliverPadding] — adds padding around another sliver
///
/// How to run:
/// ```bash
/// flutter run -t lib/phase6/main_phase6.dart
/// ```

import 'package:flutter/material.dart';

/// Standalone entry point so this file can be run directly:
/// ```bash
/// flutter run -t phase6/02_slivers/slivers_demo.dart
/// ```
void main() => runApp(_StandaloneApp());

/// Minimal app wrapper used only when running this file directly.
class _StandaloneApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SliversDemo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const SliversDemo(),
    );
  }
}


/// Demo screen that uses [CustomScrollView] to combine several sliver types.
class SliversDemo extends StatelessWidget {
  const SliversDemo({super.key});

  // Sample data for the list and grid sections
  static const _listItems = [
    'SliverList item 1 — rendered lazily as you scroll',
    'SliverList item 2 — only built when visible',
    'SliverList item 3 — delegate controls how items are built',
    'SliverList item 4 — SliverChildBuilderDelegate = lazy',
    'SliverList item 5 — SliverChildListDelegate = all at once (avoid for long lists)',
  ];

  static const _gridColors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.teal,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.pink,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── No regular AppBar here — the SliverAppBar takes its place ────────
      body: CustomScrollView(
        // CustomScrollView is the root that orchestrates all slivers.
        // It reports scroll position to each child, letting them
        // expand/collapse/pin accordingly.
        slivers: [
          // ── 1. SliverAppBar ─────────────────────────────────────────────
          // Expands when scrolled to top, collapses as you scroll down.
          SliverAppBar(
            title: const Text('02 — Slivers'),
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            // expandedHeight: how tall the flexible space is when fully open
            expandedHeight: 180,
            // pinned: true keeps the collapsed bar visible at the top
            pinned: true,
            // floating: true makes the bar reappear as soon as you scroll up
            floating: false,
            // snap: only works with floating:true; snaps bar fully open/closed
            snap: false,
            flexibleSpace: FlexibleSpaceBar(
              // Background content shown when the bar is expanded
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.teal, Colors.cyan],
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 40), // avoid overlap with status bar
                      Icon(Icons.view_list, color: Colors.white, size: 48),
                      SizedBox(height: 8),
                      Text(
                        'Scroll down to see the app bar collapse',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── 2. SliverToBoxAdapter ────────────────────────────────────────
          // Wraps any regular (Box) widget so it can live inside CustomScrollView.
          // Use this for one-off widgets between slivers (headers, banners, etc.)
          const SliverToBoxAdapter(
            child: _SectionTitle(
              title: '① SliverList',
              subtitle: 'Lazy vertical list — items built on demand as they scroll into view',
              color: Colors.teal,
            ),
          ),

          // ── 3. SliverList ────────────────────────────────────────────────
          // Equivalent to ListView, but composable inside CustomScrollView.
          // SliverChildBuilderDelegate builds items lazily (recommended).
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _ListCard(
                number: index + 1,
                text: _listItems[index],
              ),
              childCount: _listItems.length,
            ),
          ),

          // ── 4. SliverPadding around a section title ──────────────────────
          // SliverPadding adds padding around another sliver.
          SliverPadding(
            padding: const EdgeInsets.only(top: 16),
            sliver: SliverToBoxAdapter(
              child: _SectionTitle(
                title: '② SliverGrid',
                subtitle: 'Lazy grid — crossAxisCount controls columns',
                color: Colors.indigo,
              ),
            ),
          ),

          // ── 5. SliverGrid ────────────────────────────────────────────────
          // Equivalent to GridView, composable inside CustomScrollView.
          // SliverGridDelegateWithFixedCrossAxisCount = fixed column count.
          // SliverGridDelegateWithMaxCrossAxisExtent = fixed max tile width.
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,      // 3 columns
              mainAxisSpacing: 8,     // vertical gap between rows
              crossAxisSpacing: 8,    // horizontal gap between columns
              childAspectRatio: 1.2,  // width / height of each tile
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _GridTile(
                color: _gridColors[index],
                index: index + 1,
              ),
              childCount: _gridColors.length,
            ),
          ),

          // ── 6. SliverPersistentHeader ────────────────────────────────────
          // A header that can be pinned (stays at top while its section scrolls).
          // Requires a custom delegate that extends SliverPersistentHeaderDelegate.
          SliverPersistentHeader(
            pinned: true, // stays visible while the section below is scrolling
            delegate: _PinnedHeaderDelegate(
              title: '③ SliverPersistentHeader (Pinned)',
              color: Colors.deepPurple,
            ),
          ),

          // Content below the pinned header
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.deepPurple.withOpacity(0.1),
                  child: Text('${index + 1}',
                      style: const TextStyle(color: Colors.deepPurple)),
                ),
                title: Text('Item below pinned header — #${index + 1}'),
                subtitle: const Text(
                    'Scroll up slowly to watch the persistent header stick'),
              ),
              childCount: 10,
            ),
          ),

          // ── Bottom padding so content isn't hidden behind system nav ─────
          const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
        ],
      ),
    );
  }
}

// ── Sliver Persistent Header Delegate ─────────────────────────────────────────

/// Custom delegate for [SliverPersistentHeader].
///
/// You must extend [SliverPersistentHeaderDelegate] and implement:
/// - [build]          — the actual widget for the header
/// - [maxExtent]      — maximum height (when fully expanded)
/// - [minExtent]      — minimum height (when fully collapsed / pinned)
/// - [shouldRebuild]  — whether to rebuild when delegate changes
class _PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final Color color;

  const _PinnedHeaderDelegate({required this.title, required this.color});

  // Both min and max are the same → this header doesn't resize (no parallax).
  // If you want a stretchy header, set maxExtent > minExtent.
  @override
  double get minExtent => 48;

  @override
  double get maxExtent => 48;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // shrinkOffset: how much the header has shrunk from maxExtent (0 → maxExtent)
    // overlapsContent: true when content scrolls under the header
    return Container(
      color: color,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  /// Rebuild only when [title] or [color] changes.
  @override
  bool shouldRebuild(_PinnedHeaderDelegate old) =>
      old.title != title || old.color != color;
}

// ── Helper widgets ─────────────────────────────────────────────────────────────

/// Section header placed between slivers via SliverToBoxAdapter.
class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          Text(subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const Divider(height: 12),
        ],
      ),
    );
  }
}

/// Card item for the SliverList section.
class _ListCard extends StatelessWidget {
  final int number;
  final String text;

  const _ListCard({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.teal.shade100,
                child: Text('$number',
                    style: const TextStyle(color: Colors.teal, fontSize: 12)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
            ],
          ),
        ),
      ),
    );
  }
}

/// Colored tile for the SliverGrid section.
class _GridTile extends StatelessWidget {
  final Color color;
  final int index;

  const _GridTile({required this.color, required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          '$index',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }
}
