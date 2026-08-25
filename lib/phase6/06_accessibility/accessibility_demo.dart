/// Phase 6 — Topic 06: Accessibility
///
/// Accessibility (a11y) ensures your app is usable by people with
/// visual, motor, cognitive, or hearing impairments.
///
/// Flutter renders using its own engine, so it must manually annotate
/// the semantic tree that screen readers (TalkBack on Android, VoiceOver
/// on iOS) consume. Flutter does this automatically for built-in widgets —
/// but custom widgets and custom painters need manual [Semantics] annotations.
///
/// Key concepts covered:
/// 1. [Semantics] widget — attaches a semantic description to any widget
/// 2. [MergeSemantics] — combines multiple children into a single semantic node
/// 3. [ExcludeSemantics] — hides a widget from screen readers (decorative elements)
/// 4. [Semantics.button] — marks a widget as interactive
/// 5. Color contrast — WCAG AA requires 4.5:1 for normal text, 3:1 for large text
/// 6. Touch target size — minimum 48×48 dp (Material Design guideline)
/// 7. [MediaQuery.boldText] — respects user's "bold text" system preference
/// 8. [MediaQuery.textScaler] — respects user's font size preference
///
/// How to run:
/// ```bash
/// flutter run -t lib/phase6/main_phase6.dart
/// ```

import 'package:flutter/material.dart';

/// Standalone entry point so this file can be run directly:
/// ```bash
/// flutter run -t phase6/06_accessibility/accessibility_demo.dart
/// ```
void main() => runApp(_StandaloneApp());

/// Minimal app wrapper used only when running this file directly.
class _StandaloneApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AccessibilityDemo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const AccessibilityDemo(),
    );
  }
}


/// Demo screen showcasing accessibility best practices.
class AccessibilityDemo extends StatefulWidget {
  const AccessibilityDemo({super.key});

  @override
  State<AccessibilityDemo> createState() => _AccessibilityDemoState();
}

class _AccessibilityDemoState extends State<AccessibilityDemo> {
  // Tracks the custom "like" button state for the Semantics demo
  bool _isLiked = false;

  // Counter to show how Semantics.liveRegion works
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('06 — Accessibility'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── 1. Semantics widget ──────────────────────────────────────────
          _header('1. Semantics Widget', Colors.green.shade700),
          const Text(
            'Built-in widgets (Text, IconButton, etc.) already have semantics. '
            'Custom widgets built from Container/GestureDetector need manual annotation.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 10),

          // ── Bad example: no semantics ─────────────────────────────────
          const Text('❌ Without Semantics:',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 80,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.delete, color: Colors.white),
              // Screen reader sees: nothing useful → reads as "unlabeled button"
            ),
          ),
          const SizedBox(height: 8),

          // ── Good example: with semantics ──────────────────────────────
          const Text('✅ With Semantics:',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          const SizedBox(height: 4),
          Semantics(
            // label: what the screen reader announces
            label: 'Delete item',
            // hint: additional context spoken after the label
            hint: 'Double tap to delete',
            // button: marks it as an interactive control
            button: true,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: 80,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                // ExcludeSemantics: the icon is decorative — described by parent label
                child: ExcludeSemantics(
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          _codeSnippet(
            'Semantics(\n'
            '  label: \'Delete item\',\n'
            '  hint: \'Double tap to delete\',\n'
            '  button: true,\n'
            '  child: GestureDetector(\n'
            '    onTap: () {},\n'
            '    child: Container(\n'
            '      // ExcludeSemantics: icon is decorative, already described above\n'
            '      child: ExcludeSemantics(\n'
            '        child: Icon(Icons.delete),\n'
            '      ),\n'
            '    ),\n'
            '  ),\n'
            ')',
          ),

          const SizedBox(height: 20),

          // ── 2. Toggle state announcement ─────────────────────────────────
          _header('2. Toggle State (Semantics.checked)', Colors.teal),
          const Text(
            'Interactive elements that change state should announce the new state '
            'so screen reader users know what happened.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Semantics(
            // checked: announces "checked" or "unchecked" to screen readers
            checked: _isLiked,
            label: _isLiked ? 'Liked' : 'Not liked',
            hint: 'Double tap to toggle',
            button: true,
            child: GestureDetector(
              onTap: () => setState(() => _isLiked = !_isLiked),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: _isLiked ? Colors.red.shade50 : Colors.grey.shade100,
                  border: Border.all(
                      color: _isLiked ? Colors.red : Colors.grey),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isLiked ? Icons.favorite : Icons.favorite_border,
                      color: _isLiked ? Colors.red : Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isLiked ? 'Liked' : 'Like',
                      style: TextStyle(
                          color: _isLiked ? Colors.red : Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── 3. Live regions ──────────────────────────────────────────────
          _header('3. Live Regions (Semantics.liveRegion)', Colors.indigo),
          const Text(
            'liveRegion: true tells the screen reader to announce when the '
            'content changes, even if the user did not focus that widget.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // The counter display is a live region
              Semantics(
                liveRegion: true, // announces changes automatically
                label: 'Counter value',
                child: Container(
                  width: 80,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.indigo),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$_counter',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.indigo),
                onPressed: () => setState(() => _counter++),
                child: const Text('Increment'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _codeSnippet(
            'Semantics(\n'
            '  liveRegion: true,  // screen reader announces changes automatically\n'
            '  label: \'Counter value\',\n'
            '  child: Text(\'\$_counter\'),\n'
            ')',
          ),

          const SizedBox(height: 20),

          // ── 4. MergeSemantics ────────────────────────────────────────────
          _header('4. MergeSemantics', Colors.orange),
          const Text(
            'Merges multiple semantic children into a single node. '
            'Useful for card-style items where the image + text + button '
            'should be read as one thing.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          MergeSemantics(
            // Screen reader reads: "Flutter logo, Learn Flutter, Open"
            // as a single announcement, not three separate nodes.
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Decorative image — excluded from semantics
                    ExcludeSemantics(
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.flutter_dash,
                            color: Colors.blue),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Learn Flutter',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Phase 6 — Advanced',
                              style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    // The icon button still needs a tooltip for semantics
                    IconButton(
                      tooltip: 'Open',
                      icon: const Icon(Icons.arrow_forward_ios, size: 16),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── 5. Touch target size ─────────────────────────────────────────
          _header('5. Minimum Touch Target Size', Colors.red),
          const Text(
            'Material Design requires 48×48 dp minimum touch target. '
            'Wrap small icons in a 48×48 container, or use IconButton '
            '(it already enforces minimum size).',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Column(
                children: [
                  const Text('❌ 24×24 (too small)',
                      style: TextStyle(fontSize: 11, color: Colors.red)),
                  const SizedBox(height: 4),
                  // A bare GestureDetector on a 24px icon — hard to tap!
                  GestureDetector(
                    onTap: () {},
                    child: const Icon(Icons.settings, size: 24),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Column(
                children: [
                  const Text('✅ 48×48 (correct)',
                      style: TextStyle(fontSize: 11, color: Colors.green)),
                  const SizedBox(height: 4),
                  // SizedBox forces the tap area to 48×48 even if the icon is smaller
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {},
                        child: const Icon(Icons.settings, size: 24),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Column(
                children: [
                  const Text('✅ IconButton (auto)',
                      style: TextStyle(fontSize: 11, color: Colors.green)),
                  const SizedBox(height: 4),
                  // IconButton enforces 48×48 minimum automatically
                  IconButton(
                    tooltip: 'Settings',
                    icon: const Icon(Icons.settings, size: 24),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── 6. Text scale + bold preference ─────────────────────────────
          _header('6. Respect User Font Preferences', Colors.purple),
          Card(
            color: Colors.purple.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current text scale: '
                    '${mq.textScaler.scale(1).toStringAsFixed(2)}x',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  // Use sp (scaled pixels) implicitly — Flutter Text widget
                  // already scales with textScaler unless you override it.
                  // NEVER hardcode fontSize without allowing it to scale.
                  const Text(
                    'This text respects the system font size setting. '
                    'Never use MediaQuery to PREVENT scaling — let users set '
                    'the size they need.',
                    style: TextStyle(fontSize: 13), // scales with user pref
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Avoid: Text("...", textScaler: TextScaler.noScaling)\n'
                    '→ This ignores accessibility needs.',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                        fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Key Takeaways',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('• Built-in widgets (Text, Button, etc.) already have semantics'),
                  Text('• Custom GestureDetectors need manual Semantics annotation'),
                  Text('• ExcludeSemantics for decorative images/icons'),
                  Text('• MergeSemantics combines a card row into a single read-out'),
                  Text('• liveRegion: true announces value changes automatically'),
                  Text('• Minimum touch target: 48×48 dp'),
                  Text('• Never disable text scaling — respect user accessibility settings'),
                  Text('• Test with TalkBack (Android) and VoiceOver (iOS)'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(String title, Color color) => Padding(
        padding: const EdgeInsets.only(bottom: 4, top: 4),
        child: Text(title,
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: color)),
      );

  Widget _codeSnippet(String code) => Container(
        width: double.infinity,
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
