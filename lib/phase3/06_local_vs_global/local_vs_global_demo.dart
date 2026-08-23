/// Demo 06 — Local State vs Global State.
///
/// **Concepts covered:**
/// - **Local state** → setState(), only for that specific widget
/// - **Global state** → Riverpod provider, accessible from anywhere
/// - When to use local vs global
/// - Anti-pattern: using global state for things that should stay local
///
/// **Practical rules:**
/// - Local: UI-only state (expanded/collapsed, hover, focus, selected tab)
/// - Global: business data (user, cart, todos), state shared between screens
///
/// Think of state as a circle — the smaller the circle, the better.
/// Only go global when state truly needs to be shared.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Global state — Riverpod providers
// ─────────────────────────────────────────────────────────────────────────────

/// Username — global because it's used by many different widgets.
final usernameProvider = StateProvider<String>((ref) => 'Faisal');

/// Shopping cart — global because it changes from many different pages.
class CartNotifier extends StateNotifier<List<String>> {
  CartNotifier() : super([]);

  void addItem(String item) => state = [...state, item];
  void removeItem(String item) => state = state.where((i) => i != item).toList();
  void clear() => state = [];
}

final cartProvider = StateNotifierProvider<CartNotifier, List<String>>((ref) {
  return CartNotifier();
});

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

class LocalVsGlobalDemo extends StatelessWidget {
  const LocalVsGlobalDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Local vs Global State',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
          useMaterial3: true,
        ),
        home: const _LocalVsGlobalScreen(),
      ),
    );
  }
}

class _LocalVsGlobalScreen extends StatelessWidget {
  const _LocalVsGlobalScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local vs Global State'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          // ── Local state examples ──────────────────────────────────────────
          _SectionHeader('✅ Local State — use setState()'),
          SizedBox(height: 8),
          _LocalExpandableCard(
            title: 'FAQ: What is Flutter?',
            content: 'Flutter is a cross-platform UI framework from Google '
                'that uses the Dart programming language.',
          ),
          SizedBox(height: 8),
          _LocalExpandableCard(
            title: 'FAQ: Why Riverpod?',
            content: 'Riverpod is more type-safe and testable than plain Provider.',
          ),
          SizedBox(height: 8),
          _LocalCounterExample(),
          SizedBox(height: 24),

          // ── Global state examples ─────────────────────────────────────────
          _SectionHeader('🌍 Global State — use Riverpod'),
          SizedBox(height: 8),
          _GlobalUsernameExample(),
          SizedBox(height: 8),
          _GlobalCartExample(),
          SizedBox(height: 24),

          // ── Comparison ────────────────────────────────────────────────────
          _SectionHeader('📊 When to Use Which?'),
          SizedBox(height: 8),
          _ComparisonTable(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Local state examples
// ─────────────────────────────────────────────────────────────────────────────

/// Expandable card — the expanded/collapsed state is LOCAL.
/// Only this widget cares about it; no other widget needs to know.
class _LocalExpandableCard extends StatefulWidget {
  final String title;
  final String content;
  const _LocalExpandableCard({required this.title, required this.content});

  @override
  State<_LocalExpandableCard> createState() => _LocalExpandableCardState();
}

class _LocalExpandableCardState extends State<_LocalExpandableCard> {
  // Local state — only relevant to this widget
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(widget.title),
            trailing: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
            onTap: () => setState(() => _isExpanded = !_isExpanded),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(widget.content),
            ),
        ],
      ),
    );
  }
}

/// Local counter — good for animations, form steps, etc.
class _LocalCounterExample extends StatefulWidget {
  const _LocalCounterExample();

  @override
  State<_LocalCounterExample> createState() => _LocalCounterExampleState();
}

class _LocalCounterExampleState extends State<_LocalCounterExample> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Local Counter (only for this widget)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Count: $_count', style: const TextStyle(fontSize: 18)),
                const Spacer(),
                IconButton(onPressed: () => setState(() => _count--), icon: const Icon(Icons.remove)),
                IconButton(onPressed: () => setState(() => _count++), icon: const Icon(Icons.add)),
              ],
            ),
            const Text(
              'Uses setState() — no Riverpod needed.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Global state examples
// ─────────────────────────────────────────────────────────────────────────────

/// Username — global because it's displayed in multiple places simultaneously.
/// Notice: two different widgets display the same value in sync.
class _GlobalUsernameExample extends ConsumerWidget {
  const _GlobalUsernameExample();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final username = ref.watch(usernameProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Global Username (Riverpod)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Both widgets display the same username from the same provider
            _UsernameDisplay(label: 'Header:'),
            const SizedBox(height: 4),
            _UsernameDisplay(label: 'Footer:'),
            const SizedBox(height: 8),
            // Edit username — update in one place, all widgets follow
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Change username...',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (v) =>
                        ref.read(usernameProvider.notifier).state = v,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '↑ Press Enter to update',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Change the username → Header & Footer update instantly.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small widget that displays the username — used in multiple places.
class _UsernameDisplay extends ConsumerWidget {
  final String label;
  const _UsernameDisplay({required this.label});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final username = ref.watch(usernameProvider);
    return Text('$label $username', style: const TextStyle(fontSize: 16));
  }
}

/// Shopping cart — global because items can be added from any page.
class _GlobalCartExample extends ConsumerWidget {
  const _GlobalCartExample();

  static const _availableItems = ['☕ Coffee', '🍰 Cake', '📱 Charger', '🎧 Headphones'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Shopping Cart', style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Badge(
                  label: Text('${cart.length}'),
                  child: const Icon(Icons.shopping_cart),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Add item chips
            Wrap(
              spacing: 6,
              children: _availableItems
                  .map(
                    (item) => ActionChip(
                      label: Text(item),
                      avatar: const Icon(Icons.add, size: 14),
                      onPressed: () => ref.read(cartProvider.notifier).addItem(item),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),

            // Cart contents
            if (cart.isEmpty)
              const Text('Cart is empty. Tap an item above to add.')
            else ...[
              ...cart.map(
                (item) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(item),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline, size: 18),
                    onPressed: () => ref.read(cartProvider.notifier).removeItem(item),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => ref.read(cartProvider.notifier).clear(),
                child: const Text('Clear Cart'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold));
  }
}

/// Comparison table — when to use local vs global state.
class _ComparisonTable extends StatelessWidget {
  const _ComparisonTable();

  @override
  Widget build(BuildContext context) {
    const rows = [
      ['UI toggle (expanded/collapsed)', '✅ Local', ''],
      ['Temporary form input', '✅ Local', ''],
      ['Animation state', '✅ Local', ''],
      ['User data (name, profile)', '', '✅ Global'],
      ['Shopping cart', '', '✅ Global'],
      ['Auth state (login/logout)', '', '✅ Global'],
      ['Filter shared between screens', '', '✅ Global'],
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(3),
            1: FlexColumnWidth(1.2),
            2: FlexColumnWidth(1.2),
          },
          border: TableBorder.symmetric(inside: BorderSide(color: Colors.grey.shade200)),
          children: [
            // Header
            TableRow(
              decoration: BoxDecoration(color: Colors.orange.shade50),
              children: ['State', 'Local', 'Global'].map((h) => Padding(
                padding: const EdgeInsets.all(8),
                child: Text(h, style: const TextStyle(fontWeight: FontWeight.bold)),
              )).toList(),
            ),
            // Data rows
            ...rows.map(
              (row) => TableRow(
                children: row.map((cell) => Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(cell),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
