/// Phase 7 — Topic 03: Integration Test
///
/// Integration tests run the FULL app on a real device or emulator.
/// They test end-to-end user flows — from tapping the first screen
/// all the way through to a final result.
///
/// Characteristics:
/// - Slowest of the three test types (seconds per test, not milliseconds)
/// - Most realistic — same environment as production
/// - Best for critical user journeys: login, checkout, onboarding
///
/// Flutter's integration test package: `integration_test`
/// (built into Flutter SDK — no separate install needed)
///
/// Key concepts covered:
/// 1. [IntegrationTestWidgetsFlutterBinding.ensureInitialized()] — required setup
/// 2. [testWidgets()] — same API as widget tests, but runs on real device
/// 3. Driving the full app with [app.main()]
/// 4. [IntegrationTestWidgetsFlutterBinding.instance.reportData] — attach metadata
/// 5. Running on CI: [flutter test integration_test/]
/// 6. Screenshot capture during integration tests
/// 7. Comparing integration tests vs widget tests — when to use which
///
/// How to run:
/// ```bash
/// # On a connected device/emulator
/// flutter test integration_test/app_test.dart
///
/// # On all devices
/// flutter test integration_test/
/// ```
library;

import 'package:flutter/material.dart';

/// Standalone entry point.
void main() => runApp(_StandaloneApp());

class _StandaloneApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Integration Test Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const IntegrationTestDemo(),
    );
  }
}

/// Demo screen explaining integration test concepts.
class IntegrationTestDemo extends StatelessWidget {
  const IntegrationTestDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('03 — Integration Test'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Overview ────────────────────────────────────────────────────
          _card(
            color: Colors.deepOrange.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Test Pyramid', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text(
                  '▲ Integration  — few, slow, high confidence (full app)\n'
                  '■ Widget       — moderate, medium speed (component)\n'
                  '● Unit         — many, fast, isolated (function/class)\n\n'
                  'Write mostly unit tests, some widget tests, few integration tests.',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── 1. Project setup ─────────────────────────────────────────────
          _header('1. Project Setup', Colors.deepOrange),
          _code('''
# pubspec.yaml
dev_dependencies:
  integration_test:
    sdk: flutter       # already in Flutter SDK, no version needed
  flutter_test:
    sdk: flutter

# File location: integration_test/ (NOT test/)
# integration_test/
# ├── app_test.dart          ← full app flow tests
# └── login_flow_test.dart   ← specific flow tests'''),

          const SizedBox(height: 16),

          // ── 2. Basic integration test ────────────────────────────────────
          _header('2. Basic Integration Test', Colors.red),
          _code('''
// integration_test/app_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:myapp/main.dart' as app;

void main() {
  // REQUIRED: must be the first line — sets up the binding with the device
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('full login flow', (tester) async {
    // 1. Boot the entire app — same as tapping the icon on the device
    app.main();
    await tester.pumpAndSettle(); // wait for splash / startup animations

    // 2. Verify we land on the login screen
    expect(find.text('Login'), findsOneWidget);

    // 3. Fill in the form
    await tester.enterText(
      find.byKey(const Key('email_field')),
      'test@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('password_field')),
      'password123',
    );

    // 4. Submit
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle(); // wait for navigation + API response

    // 5. Verify we reached the home screen
    expect(find.text('Welcome, Test User'), findsOneWidget);
  });
}'''),

          const SizedBox(height: 16),

          // ── 3. Page Object Model ─────────────────────────────────────────
          _header('3. Page Object Model (POM)', Colors.purple),
          const Text(
            'Extract page interactions into helper classes to avoid duplicating '
            'finder logic across test files.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 6),
          _code('''
// test_helpers/login_page.dart
class LoginPage {
  final WidgetTester tester;
  LoginPage(this.tester);

  // All finders in one place — change the Key here, tests stay unchanged
  Finder get emailField => find.byKey(const Key('email_field'));
  Finder get passwordField => find.byKey(const Key('password_field'));
  Finder get loginButton => find.byKey(const Key('login_button'));

  Future<void> fillEmail(String email) async {
    await tester.enterText(emailField, email);
    await tester.pump();
  }

  Future<void> fillPassword(String password) async {
    await tester.enterText(passwordField, password);
    await tester.pump();
  }

  Future<void> tapLogin() async {
    await tester.tap(loginButton);
    await tester.pumpAndSettle();
  }

  // Convenience: fill and submit in one call
  Future<void> loginAs(String email, String password) async {
    await fillEmail(email);
    await fillPassword(password);
    await tapLogin();
  }
}

// Usage in test file — clean and readable:
testWidgets('valid credentials navigate to home', (tester) async {
  app.main();
  await tester.pumpAndSettle();

  final loginPage = LoginPage(tester);
  await loginPage.loginAs('user@test.com', 'pass123');

  expect(find.text('Home'), findsOneWidget);
});'''),

          const SizedBox(height: 16),

          // ── 4. Screenshot capture ────────────────────────────────────────
          _header('4. Screenshot Capture', Colors.teal),
          _code('''
// Capture a screenshot at any point during the test
// Useful for visual regression or just debugging CI failures
testWidgets('capture home screen', (tester) async {
  app.main();
  await tester.pumpAndSettle();

  // takeScreenshot stores the PNG as a test artifact
  await binding.takeScreenshot('home_screen');
  // On Firebase Test Lab, screenshots appear in the test results dashboard
});

// Access the binding instance at the top of main():
final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();'''),

          const SizedBox(height: 16),

          // ── 5. Running on CI ─────────────────────────────────────────────
          _header('5. Running on CI / Firebase Test Lab', Colors.indigo),
          _code('''
# Run on a locally connected device/emulator
flutter test integration_test/

# Build for Firebase Test Lab (Android)
flutter build apk --debug
flutter build apk --debug --target=integration_test/app_test.dart \\
  --flavor staging

# GitHub Actions — run integration tests on emulator
- name: Run integration tests
  uses: reactivecircus/android-emulator-runner@v2
  with:
    api-level: 34
    script: flutter test integration_test/

# Firebase Test Lab
gcloud firebase test android run \\
  --type instrumentation \\
  --app build/app/outputs/apk/debug/app-debug.apk \\
  --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk'''),

          const SizedBox(height: 16),

          // ── 6. Widget vs Integration ─────────────────────────────────────
          _header('6. Widget Test vs Integration Test', Colors.brown),
          _card(
            color: Colors.brown.shade50,
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
              },
              border: TableBorder.all(color: Colors.brown.shade200),
              children: const [
                TableRow(
                  decoration: BoxDecoration(color: Color(0xFFEFEBE9)),
                  children: [
                    _TableCell('', bold: true),
                    _TableCell('Widget Test', bold: true),
                    _TableCell('Integration Test', bold: true),
                  ],
                ),
                TableRow(children: [
                  _TableCell('Speed'),
                  _TableCell('Fast (~ms)'),
                  _TableCell('Slow (~sec)'),
                ]),
                TableRow(children: [
                  _TableCell('Device'),
                  _TableCell('Simulated'),
                  _TableCell('Real device'),
                ]),
                TableRow(children: [
                  _TableCell('Network'),
                  _TableCell('Mocked'),
                  _TableCell('Real / mocked'),
                ]),
                TableRow(children: [
                  _TableCell('Best for'),
                  _TableCell('Single widget'),
                  _TableCell('Full user flow'),
                ]),
              ],
            ),
          ),

          const SizedBox(height: 16),
          _card(
            color: Colors.deepOrange.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Key Takeaways', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('• IntegrationTestWidgetsFlutterBinding.ensureInitialized() — first line always'),
                Text('• Files go in integration_test/ (not test/)'),
                Text('• Use Page Object Model to keep test code DRY'),
                Text('• takeScreenshot() captures visual artifacts for CI dashboards'),
                Text('• Keep integration tests small: 1 test = 1 critical user journey'),
                Text('• Run: flutter test integration_test/ on a connected device'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple table cell helper for the comparison table.
class _TableCell extends StatelessWidget {
  final String text;
  final bool bold;
  const _TableCell(this.text, {this.bold = false});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(6),
        child: Text(
          text,
          style: TextStyle(
              fontSize: 11,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal),
        ),
      );
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
