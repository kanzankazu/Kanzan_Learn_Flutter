/// Phase 7 — Topic 06: Golden Test (Screenshot Comparison)
///
/// Golden tests capture a widget as a PNG image ("golden file") and compare
/// future renders against it. If the rendered output differs by even one pixel,
/// the test fails — making golden tests a reliable visual regression safety net.
///
/// When to use:
/// - Design system components (buttons, cards, chips)
/// - Complex custom-painted widgets
/// - Screens that must look identical across releases
///
/// When NOT to use:
/// - Dynamic content (timestamps, network images, user avatars)
/// - Screens with animation — screenshot at a fixed point instead
///
/// Key concepts covered:
/// 1. [matchesGoldenFile()] — the golden assertion
/// 2. Generating golden files: [flutter test --update-goldens]
/// 3. Font loading in golden tests (required for accurate text rendering)
/// 4. CI strategy — commit goldens, fail on diff, update intentionally
/// 5. [RepaintBoundary] — capture only part of the screen
/// 6. Alleycat / golden_toolkit — popular helper packages
/// 7. Handling platform-specific rendering differences
///
/// How to run:
/// ```bash
/// # First run — generate the golden files
/// flutter test test/phase7/golden_test_example_test.dart --update-goldens
///
/// # Subsequent runs — compare against saved goldens
/// flutter test test/phase7/golden_test_example_test.dart
/// ```
library;

import 'package:flutter/material.dart';

/// Standalone entry point.
void main() => runApp(_StandaloneApp());

class _StandaloneApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Golden Test Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: const GoldenTestDemo(),
    );
  }
}

/// Demo screen explaining golden test concepts.
class GoldenTestDemo extends StatelessWidget {
  const GoldenTestDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('06 — Golden Test'),
        backgroundColor: Colors.amber.shade700,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            color: Colors.amber.shade50,
            child: const Text(
              'Golden tests capture a widget as a PNG image and compare future '
              'renders against it pixel-by-pixel. Any visual change — intentional '
              'or accidental — will fail the test.',
              style: TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),

          // ── 1. Basic golden test ──────────────────────────────────────────
          _header('1. Basic Golden Test', Colors.amber.shade700),
          _code('''
// test/phase7/primary_button_golden_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('PrimaryButton golden', (tester) async {
    // Load custom fonts — required for pixel-accurate text rendering
    // Without this, golden files will have wrong font rendering
    await loadAppFonts(); // see section 3 for implementation

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(
          body: Center(
            child: PrimaryButton(
              label: 'Submit',
              onPressed: () {},
            ),
          ),
        ),
      ),
    );

    // matchesGoldenFile — first run: CREATES the file
    //                     subsequent runs: COMPARES against the file
    await expectLater(
      find.byType(PrimaryButton),
      matchesGoldenFile('goldens/primary_button_default.png'),
    );
  });

  testWidgets('PrimaryButton disabled golden', (tester) async {
    await loadAppFonts();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            // Test different states — each state gets its own golden file
            child: PrimaryButton(label: 'Submit', onPressed: null),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(PrimaryButton),
      matchesGoldenFile('goldens/primary_button_disabled.png'),
    );
  });
}'''),

          const SizedBox(height: 16),

          // ── 2. Update goldens ─────────────────────────────────────────────
          _header('2. Generating & Updating Golden Files', Colors.orange),
          _card(
            color: Colors.orange.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('When to run --update-goldens:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text('• First time creating a golden test (no PNG exists yet)'),
                Text('• After an intentional visual change (new design)'),
                Text('• NEVER run it to "fix" a test that should fail'),
                SizedBox(height: 8),
                Text('Workflow:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('1. Make intentional design change'),
                Text('2. Run flutter test --update-goldens'),
                Text('3. Visually review the new PNG in your diff tool'),
                Text('4. Commit the updated PNG with the code change'),
              ],
            ),
          ),
          _code('''
# Generate / update golden files
flutter test test/golden/ --update-goldens

# Then run normally to confirm they match
flutter test test/golden/

# In CI — never run --update-goldens, just compare:
- name: Golden tests
  run: flutter test test/golden/
# If they fail, a developer must intentionally update them locally'''),

          const SizedBox(height: 16),

          // ── 3. Font loading ───────────────────────────────────────────────
          _header('3. Font Loading (Critical for Accuracy)', Colors.red),
          const Text(
            'Without custom font loading, Flutter falls back to a default font '
            'that looks different from your app\'s actual fonts. This makes '
            'golden images useless for text-heavy widgets.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          _code('''
// test/helpers/fonts.dart
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Load all fonts declared in pubspec.yaml into the test environment.
///
/// Call this at the start of any golden test that renders text.
Future<void> loadAppFonts() async {
  // Tell Flutter test to load font files from the filesystem
  TestWidgetsFlutterBinding.ensureInitialized();

  // Load each font family declared in your pubspec.yaml
  final fontLoader = FontLoader('Roboto');
  fontLoader.addFont(
    File('assets/fonts/Roboto-Regular.ttf').readAsBytes().then(
      (bytes) => ByteData.view(bytes.buffer),
    ),
  );
  await fontLoader.load();
}

// Alternative: use the golden_toolkit package which handles this automatically
// https://pub.dev/packages/golden_toolkit'''),

          const SizedBox(height: 16),

          // ── 4. golden_toolkit ─────────────────────────────────────────────
          _header('4. golden_toolkit Package (Recommended)', Colors.teal),
          _code('''
# pubspec.yaml
dev_dependencies:
  golden_toolkit: ^0.15.0
  flutter_test:
    sdk: flutter'''),
          const SizedBox(height: 6),
          _code('''
// test/phase7/button_golden_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

void main() {
  // loadAppFonts() is provided by golden_toolkit automatically
  GoldenToolkit.runWithConfiguration(
    () {
      // testGoldens = testWidgets + automatic font loading
      testGoldens('PrimaryButton states', (tester) async {
        await tester.pumpWidgetBuilder(
          // GoldenBuilder generates a grid of multiple variants
          GoldenBuilder.grid(columns: 2, widthToHeightRatio: 1)
            ..addScenario('Default', PrimaryButton(label: 'Submit', onPressed: () {}))
            ..addScenario('Disabled', PrimaryButton(label: 'Submit', onPressed: null))
            ..addScenario('Loading', PrimaryButton(label: 'Submit', isLoading: true, onPressed: () {}))
            ..addScenario('Error', PrimaryButton(label: 'Submit', isError: true, onPressed: () {})),
        );

        // One golden file with all 4 states in a grid — easy to compare
        await screenMatchesGolden(tester, 'primary_button_all_states');
      });
    },
    config: GoldenToolkitConfiguration(
      // Where to store golden files
      fileNameFactory: (name) => Uri.parse('test/goldens/\$name.png'),
    ),
  );
}'''),

          const SizedBox(height: 16),

          // ── 5. CI strategy ────────────────────────────────────────────────
          _header('5. CI Strategy', Colors.indigo),
          _card(
            color: Colors.indigo.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Problem:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  'Different OS / Flutter version → slightly different pixel rendering '
                  '→ golden tests fail in CI even when nothing changed visually.',
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 8),
                Text('Solutions:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('1. Generate goldens in CI using a Docker image with a fixed Flutter version'),
                Text('2. Use a pixel tolerance threshold (golden_toolkit supports this)'),
                Text('3. Only run golden tests on Linux CI — most consistent renderer'),
                Text('4. Store goldens per-platform: goldens/linux/, goldens/macos/'),
              ],
            ),
          ),
          _code(r'''
// golden_toolkit: allow up to 0.5% pixel difference
await screenMatchesGolden(
  tester,
  'home_screen',
  customPump: (tester) => tester.pumpAndSettle(),
);

// In flutter_test — manual tolerance via comparator
FlutterGoldenFileComparator.goldenTestsUrl = Uri.parse('goldens/');

// Generate goldens only on Linux (most stable)
// In GitHub Actions:
if: runner.os == 'Linux'
run: flutter test test/golden/ --update-goldens'''),

          const SizedBox(height: 16),

          // ── 6. The widget we'd test ───────────────────────────────────────
          _header('6. Example Widget (Golden Target)', Colors.brown),
          const Text(
            'This StatusBadge is a perfect golden test candidate — '
            'it has multiple visual states and must look consistent.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusBadge(label: 'Active', color: Colors.green),
              _StatusBadge(label: 'Pending', color: Colors.orange),
              _StatusBadge(label: 'Failed', color: Colors.red),
              _StatusBadge(label: 'Cancelled', color: Colors.grey),
            ],
          ),

          const SizedBox(height: 16),
          _card(
            color: Colors.amber.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Key Takeaways', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('• matchesGoldenFile() = pixel-perfect comparison'),
                Text('• flutter test --update-goldens = regenerate PNGs'),
                Text('• Load fonts before golden tests or text renders incorrectly'),
                Text('• golden_toolkit makes multi-variant golden tests easy'),
                Text('• Commit golden files to git — they are the source of truth'),
                Text('• Run golden tests on one OS only (Linux) for CI consistency'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Sample widget suitable for golden testing — stable visual output.
class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ── Shared helpers ─────────────────────────────────────────────────────────────

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
