/// Phase 7 — Topic 02: Widget Test
///
/// Widget tests (also called "component tests") verify that a Flutter widget
/// renders correctly and responds to user interactions as expected.
///
/// They run in a simulated Flutter environment — no real device needed.
/// Faster than integration tests, but can test UI logic and state changes.
///
/// Key concepts covered:
/// 1. [testWidgets()] — the widget-test equivalent of test()
/// 2. [WidgetTester] — controls the test environment (pump, tap, scroll…)
/// 3. [Finder]s — locate widgets by type, text, key, icon, tooltip…
/// 4. [pump()] — rebuild the widget tree (process one frame)
/// 5. [pumpAndSettle()] — keep pumping until no more animations/timers
/// 6. [pumpWidget()] — mount a widget into the test environment
/// 7. [find.text()] / [find.byType()] / [find.byKey()] — common finders
/// 8. [tester.tap()] / [tester.enterText()] / [tester.drag()] — interactions
/// 9. [expect(finder, findsOneWidget)] — widget-specific matchers
///
/// How to run:
/// ```bash
/// flutter test test/phase7/widget_test_example_test.dart
/// ```
library;

import 'package:flutter/material.dart';

/// Standalone entry point.
void main() => runApp(_StandaloneApp());

class _StandaloneApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Widget Test Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const WidgetTestDemo(),
    );
  }
}

/// Demo screen explaining widget test concepts.
class WidgetTestDemo extends StatelessWidget {
  const WidgetTestDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('02 — Widget Test'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            color: Colors.green.shade50,
            child: const Text(
              'Widget tests run in a headless Flutter environment — no device needed. '
              'They test that widgets render correctly and respond to interactions.\n\n'
              'Speed: Unit < Widget < Integration',
              style: TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),

          // ── 1. Basic structure ─────────────────────────────────────────
          _header('1. Basic Structure', Colors.green),
          _code('''
// test/phase7/counter_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/widgets/counter_widget.dart';

void main() {
  testWidgets('counter increments when FAB tapped', (tester) async {
    // 1. Mount the widget — wraps it in a minimal MaterialApp automatically
    await tester.pumpWidget(
      const MaterialApp(home: CounterWidget()),
    );

    // 2. Verify initial state
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // 3. Interact — tap the FloatingActionButton
    await tester.tap(find.byIcon(Icons.add));

    // 4. Rebuild — process one frame so setState takes effect
    await tester.pump();

    // 5. Verify new state
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}'''),

          const SizedBox(height: 16),

          // ── 2. Finders ────────────────────────────────────────────────
          _header('2. Finders — Locate Widgets', Colors.teal),
          _code('''
// By text content (exact match by default)
find.text('Submit')
find.text('Submit', findRichText: true) // also matches RichText spans

// By widget type
find.byType(ElevatedButton)
find.byType(TextField)

// By Key — most stable selector (use for complex UIs)
find.byKey(const Key('login_button'))
find.byKey(const ValueKey('email_field'))

// By icon
find.byIcon(Icons.add)

// By tooltip (good for IconButtons)
find.byTooltip('Delete')

// By widget instance
final myWidget = find.byWidget(specificWidgetInstance);

// Combining finders
find.descendant(
  of: find.byType(Card),          // parent
  matching: find.text('Delete'),  // child to find inside parent
)

find.ancestor(
  of: find.text('Submit'),        // child
  matching: find.byType(Form),    // ancestor to find
)'''),

          const SizedBox(height: 16),

          // ── 3. Matchers ───────────────────────────────────────────────
          _header('3. Widget Matchers', Colors.orange),
          _code('''
// Quantity matchers
expect(find.text('Hello'), findsOneWidget);   // exactly one
expect(find.text('Item'), findsNWidgets(3));  // exactly N
expect(find.text('Ghost'), findsNothing);     // zero
expect(find.byType(Card), findsAny);          // one or more

// Visibility
expect(find.text('Submit'), findsOneWidget);
// Note: findsOneWidget only checks presence in the tree,
// not visual visibility. Use findsWidgets for ≥1.

// Semantics
expect(
  tester.getSemantics(find.text('Close')),
  matchesSemantics(label: 'Close dialog', isButton: true),
);'''),

          const SizedBox(height: 16),

          // ── 4. Interactions ────────────────────────────────────────────
          _header('4. Interactions', Colors.purple),
          _code('''
// Tap a widget
await tester.tap(find.byType(ElevatedButton));
await tester.pump(); // rebuild after tap

// Enter text in a TextField
await tester.enterText(find.byType(TextField), 'hello@example.com');
await tester.pump();

// Long press
await tester.longPress(find.byKey(const Key('item_0')));
await tester.pump();

// Drag
await tester.drag(find.byType(Slider), const Offset(50, 0));
await tester.pump();

// Scroll a ListView
await tester.scrollUntilVisible(
  find.text('Item 20'),         // widget to scroll into view
  500,                          // scroll delta per step (pixels)
  scrollable: find.byType(Scrollable),
);

// Swipe to dismiss
await tester.fling(
  find.byKey(const Key('dismissible_item')),
  const Offset(300, 0),   // direction and distance
  1000,                   // velocity
);
await tester.pumpAndSettle(); // wait for dismiss animation'''),

          const SizedBox(height: 16),

          // ── 5. pump vs pumpAndSettle ───────────────────────────────────
          _header('5. pump() vs pumpAndSettle()', Colors.red),
          _card(
            color: Colors.red.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('pump()', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  'Processes exactly ONE frame. Use after synchronous state changes '
                  '(setState, simple tap).',
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 8),
                Text('pumpAndSettle()', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  'Keeps pumping frames until no more pending animations, timers, '
                  'or microtasks. Use after animations, dialogs, page transitions.',
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 8),
                Text('pump(Duration)', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  'Advances the clock by a specific duration — useful to test '
                  'time-based behavior (debounce, periodic timers).',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          _code('''
// Simple tap → one frame
await tester.tap(find.text('Increment'));
await tester.pump();                    // ✅

// Open a dialog → needs animation to finish
await tester.tap(find.text('Show Dialog'));
await tester.pumpAndSettle();           // ✅ waits for dialog open animation

// Test a debounced search (fires after 500ms)
await tester.enterText(find.byType(TextField), 'query');
await tester.pump(const Duration(milliseconds: 500)); // advance clock 500ms
expect(find.text('Results for: query'), findsOneWidget);'''),

          const SizedBox(height: 16),

          // ── 6. Testing with dependencies ───────────────────────────────
          _header('6. Providing Dependencies (Riverpod / Provider)', Colors.indigo),
          _code('''
// With Riverpod — override providers in the test
testWidgets('shows user name from provider', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        // Swap real provider with a test double
        userProvider.overrideWithValue(
          AsyncData(User(id: 1, name: 'Test User')),
        ),
      ],
      child: const MaterialApp(home: ProfileScreen()),
    ),
  );
  await tester.pumpAndSettle();

  expect(find.text('Test User'), findsOneWidget);
});

// With InheritedWidget / Provider package
testWidgets('shows cart count', (tester) async {
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => CartModel()..addItem(Item('Apple')),
      child: const MaterialApp(home: CartBadge()),
    ),
  );
  await tester.pump();

  expect(find.text('1'), findsOneWidget);
});'''),

          const SizedBox(height: 16),

          // ── 7. Live widget to test ─────────────────────────────────────
          _header('7. Live Widget — This is what tests would target', Colors.brown),
          const Text(
            'The CounterWidget below is a simple widget. '
            'Scroll down to see the test code that verifies it.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const _CounterWidget(),

          const SizedBox(height: 16),
          _code('''
// Test for the CounterWidget below ↑
testWidgets('CounterWidget: starts at 0, increments on +, decrements on -', (tester) async {
  await tester.pumpWidget(const MaterialApp(home: _CounterWidget()));

  // Initial state
  expect(find.text('0'), findsOneWidget);

  // Tap + button
  await tester.tap(find.byIcon(Icons.add));
  await tester.pump();
  expect(find.text('1'), findsOneWidget);

  // Tap - button
  await tester.tap(find.byIcon(Icons.remove));
  await tester.pump();
  expect(find.text('0'), findsOneWidget);

  // Counter should not go below 0
  await tester.tap(find.byIcon(Icons.remove));
  await tester.pump();
  expect(find.text('0'), findsOneWidget); // still 0, not -1
});'''),

          const SizedBox(height: 16),
          _card(
            color: Colors.green.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Key Takeaways', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('• testWidgets() replaces test() for UI tests'),
                Text('• pumpWidget() mounts the widget; pump() rebuilds'),
                Text('• find.byKey() is the most stable finder — assign keys to important widgets'),
                Text('• pump() = 1 frame; pumpAndSettle() = until idle'),
                Text('• Override providers/blocs in tests — never rely on real network'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sample widget that widget tests would target ───────────────────────────────

/// A simple counter widget used as the test target in this demo.
///
/// Design decisions that make this TESTABLE:
/// - All state is local (no hidden singletons)
/// - Clear key assignment for important elements
/// - No async side effects in button callbacks
class _CounterWidget extends StatefulWidget {
  const _CounterWidget();

  @override
  State<_CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<_CounterWidget> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Key helps finders locate this button unambiguously
            IconButton(
              key: const Key('decrement_button'),
              icon: const Icon(Icons.remove),
              tooltip: 'Decrement',
              onPressed: () {
                // Guard: counter must not go below 0
                if (_count > 0) setState(() => _count--);
              },
            ),
            const SizedBox(width: 16),
            Text(
              '$_count',
              key: const Key('counter_value'),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 16),
            IconButton(
              key: const Key('increment_button'),
              icon: const Icon(Icons.add),
              tooltip: 'Increment',
              onPressed: () => setState(() => _count++),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable helpers ───────────────────────────────────────────────────────────

Widget _header(String title, Color color) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(title,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
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
                fontFamily: 'monospace', fontSize: 11, color: Color(0xFFCDD6F4))),
      ),
    );

Widget _card({required Color color, required Widget child}) => Card(
      color: color,
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    );
