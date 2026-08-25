/// Phase 8 — Topic 03: CI/CD with GitHub Actions
///
/// CI (Continuous Integration) automatically runs tests on every push/PR,
/// catching bugs before they reach production.
///
/// CD (Continuous Delivery/Deployment) automatically builds and distributes
/// the app — to internal testers (Firebase App Distribution) or the stores.
///
/// Key concepts covered:
/// 1. GitHub Actions basics: workflow, trigger, job, step, runner
/// 2. Flutter-specific actions: subosito/flutter-action
/// 3. CI workflow: checkout → setup Flutter → get deps → analyze → test
/// 4. CD workflow: build AAB → sign → upload to Play Console / App Distribution
/// 5. Caching: pub cache, Gradle cache for faster builds
/// 6. Matrix builds: test on multiple Flutter/OS combinations
/// 7. Secrets: KEYSTORE_BASE64, PLAY_STORE_JSON_KEY, FIREBASE_TOKEN
///
/// Files in this topic:
/// - This demo screen (concepts and explanations)
/// - .github/workflows/ci.yml  (see code snippets below)
/// - .github/workflows/cd.yml  (see code snippets below)
import 'package:flutter/material.dart';

/// Standalone entry point.
void main() => runApp(_StandaloneApp());

class _StandaloneApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CI/CD Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const CiCdDemo(),
    );
  }
}

/// Demo screen explaining CI/CD setup with GitHub Actions.
class CiCdDemo extends StatelessWidget {
  const CiCdDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('03 — CI/CD'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            color: Colors.blueGrey.shade50,
            child: const Text(
              'CI/CD = robot that runs your tests, builds, and distributes '
              'your app automatically every time you push code.\n\n'
              'CI → catches bugs on every PR\n'
              'CD → delivers builds to testers/stores without manual steps',
              style: TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),

          // ── 1. CI Workflow ─────────────────────────────────────────────────
          _header('1. CI Workflow — Test on Every PR', Colors.blue),
          _code(r'''
# .github/workflows/ci.yml
name: CI

on:
  pull_request:        # run on every PR
  push:
    branches: [main]   # and on every push to main

jobs:
  test:
    name: Analyze & Test
    runs-on: ubuntu-latest   # free Linux runner

    steps:
      # 1. Checkout the code
      - name: Checkout
        uses: actions/checkout@v4

      # 2. Set up Flutter (subosito/flutter-action is the standard action)
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'   # pin to a major version
          channel: stable
          cache: true               # cache the Flutter SDK between runs

      # 3. Cache pub packages — skips re-downloading on unchanged pubspec.lock
      - name: Cache pub
        uses: actions/cache@v4
        with:
          path: ~/.pub-cache
          key: ${{ runner.os }}-pub-${{ hashFiles('**/pubspec.lock') }}
          restore-keys: ${{ runner.os }}-pub-

      # 4. Install dependencies
      - name: Get dependencies
        run: flutter pub get

      # 5. Static analysis — catches type errors, lint warnings
      - name: Analyze
        run: flutter analyze --fatal-infos

      # 6. Run unit + widget tests with coverage
      - name: Test
        run: flutter test --coverage

      # 7. (Optional) Upload coverage to Codecov for a badge + PR comments
      - name: Upload coverage
        uses: codecov/codecov-action@v4
        with:
          file: coverage/lcov.info'''),

          const SizedBox(height: 16),

          // ── 2. CD Workflow ─────────────────────────────────────────────────
          _header('2. CD Workflow — Build & Distribute', Colors.green),
          _code(r'''
# .github/workflows/cd.yml
name: CD

on:
  push:
    tags:
      - 'v*'   # trigger only on version tags: v1.0.0, v1.2.3

jobs:
  build-android:
    name: Build & Upload Android
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
          channel: stable
          cache: true

      - run: flutter pub get

      # Decode keystore from Base64 secret
      - name: Decode keystore
        run: |
          echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 --decode \
            > android/app/release.jks
          # Create key.properties for build.gradle
          cat > android/key.properties << EOF
          storeFile=release.jks
          storePassword=${{ secrets.STORE_PASSWORD }}
          keyAlias=${{ secrets.KEY_ALIAS }}
          keyPassword=${{ secrets.KEY_PASSWORD }}
          EOF

      # Build release AAB (Android App Bundle — required for Play Store)
      - name: Build AAB
        run: |
          flutter build appbundle --release \
            --dart-define-from-file=config/prod.json

      # Upload to Firebase App Distribution (for internal testers)
      - name: Upload to Firebase App Distribution
        uses: wzieba/Firebase-Distribution-Github-Action@v1
        with:
          appId: ${{ secrets.FIREBASE_APP_ID }}
          token: ${{ secrets.FIREBASE_TOKEN }}
          groups: internal-testers
          file: build/app/outputs/bundle/release/app-release.aab

      # Or upload to Play Console (requires a service account JSON key)
      # - name: Upload to Play Store (internal track)
      #   uses: r0adkll/upload-google-play@v1
      #   with:
      #     serviceAccountJsonPlainText: ${{ secrets.PLAY_STORE_JSON_KEY }}
      #     packageName: com.example.myapp
      #     releaseFiles: build/app/outputs/bundle/release/app-release.aab
      #     track: internal'''),

          const SizedBox(height: 16),

          // ── 3. Caching strategy ────────────────────────────────────────────
          _header('3. Caching for Faster Builds', Colors.orange),
          _code(r'''
# Cache pub packages (saves ~1 min per run after first run)
- uses: actions/cache@v4
  with:
    path: ~/.pub-cache
    key: ${{ runner.os }}-pub-${{ hashFiles('**/pubspec.lock') }}
    restore-keys: |
      ${{ runner.os }}-pub-

# Cache Gradle (saves ~3-5 min on Android builds)
- uses: actions/cache@v4
  with:
    path: |
      ~/.gradle/caches
      ~/.gradle/wrapper
    key: ${{ runner.os }}-gradle-${{ hashFiles('**/*.gradle*', '**/gradle-wrapper.properties') }}
    restore-keys: |
      ${{ runner.os }}-gradle-

# Typical build times with caching:
# First run:           8-12 min  (download everything)
# Subsequent runs:     3-5 min   (everything cached)'''),

          const SizedBox(height: 16),

          // ── 4. Matrix builds ───────────────────────────────────────────────
          _header('4. Matrix Builds — Test Multiple Versions', Colors.purple),
          _code(r'''
# Run tests on multiple Flutter versions simultaneously
jobs:
  test:
    strategy:
      matrix:
        flutter-version: ['3.19.x', '3.22.x', '3.x']
        os: [ubuntu-latest, macos-latest]
      fail-fast: false   # don't cancel other matrix jobs if one fails

    runs-on: ${{ matrix.os }}

    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ matrix.flutter-version }}
      - run: flutter pub get
      - run: flutter test'''),

          const SizedBox(height: 16),

          // ── 5. Required secrets ────────────────────────────────────────────
          _header('5. Required GitHub Secrets', Colors.red),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(3),
                },
                border: TableBorder.all(color: Colors.grey.shade300),
                children: const [
                  TableRow(
                    decoration: BoxDecoration(color: Color(0xFFF5F5F5)),
                    children: [
                      _Cell('Secret Name', bold: true),
                      _Cell('Description', bold: true),
                    ],
                  ),
                  TableRow(children: [
                    _Cell('KEYSTORE_BASE64'),
                    _Cell('base64-encoded .jks file'),
                  ]),
                  TableRow(children: [
                    _Cell('STORE_PASSWORD'),
                    _Cell('Keystore password'),
                  ]),
                  TableRow(children: [
                    _Cell('KEY_ALIAS'),
                    _Cell('Key alias inside the keystore'),
                  ]),
                  TableRow(children: [
                    _Cell('KEY_PASSWORD'),
                    _Cell('Key password'),
                  ]),
                  TableRow(children: [
                    _Cell('FIREBASE_APP_ID'),
                    _Cell('Firebase app ID (from console)'),
                  ]),
                  TableRow(children: [
                    _Cell('FIREBASE_TOKEN'),
                    _Cell('firebase login:ci token'),
                  ]),
                  TableRow(children: [
                    _Cell('PLAY_STORE_JSON_KEY'),
                    _Cell('Service account JSON (Play Console)'),
                  ]),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          _card(
            color: Colors.blueGrey.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Key Takeaways', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('• CI workflow: analyze → test → coverage on every PR'),
                Text('• CD workflow: triggered by git tag (v1.0.0), builds + distributes'),
                Text('• subosito/flutter-action is the standard Flutter CI action'),
                Text('• Cache pub + Gradle to cut build time from 10 min to 3 min'),
                Text('• Store ALL secrets in GitHub Secrets — never hardcode in YAML'),
                Text('• Matrix builds test multiple Flutter versions automatically'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple table cell widget for the secrets table.
class _Cell extends StatelessWidget {
  final String text;
  final bool bold;
  const _Cell(this.text, {this.bold = false});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(6),
        child: Text(text,
            style: TextStyle(
                fontSize: 11,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
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
