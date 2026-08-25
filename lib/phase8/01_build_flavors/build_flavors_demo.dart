/// Phase 8 — Topic 01: Build Flavors
///
/// Build flavors (Android) / Schemes (iOS) let you build multiple variants
/// of the same app from one codebase — each with its own:
/// - App name and icon
/// - Bundle/package ID (so dev and prod can coexist on the same device)
/// - API base URL and environment config
/// - Firebase project
///
/// Flutter supports two complementary approaches:
///
/// ┌─────────────────────────────────────────────────────────────────────────┐
/// │ A. --dart-define / --dart-define-from-file  (simpler, no native setup) │
/// │    Values injected at compile time via Dart constants.                  │
/// │    No changes to Android/iOS project files.                             │
/// ├─────────────────────────────────────────────────────────────────────────┤
/// │ B. Native flavors (productFlavors on Android, Schemes/Targets on iOS)  │
/// │    Full control: different icons, app names, signing configs per flavor │
/// │    More setup but supports Firebase google-services.json per flavor.    │
/// └─────────────────────────────────────────────────────────────────────────┘
///
/// Key concepts covered:
/// 1. --dart-define: compile-time constants injected from the command line
/// 2. --dart-define-from-file: load all vars from a JSON file
/// 3. AppConfig pattern: single source of truth for env config in Dart
/// 4. Native Android productFlavors: package name, app name per flavor
/// 5. VS Code / Android Studio launch configs for each flavor
///
/// How to run with a flavor:
/// ```bash
/// # Using --dart-define
/// flutter run --dart-define=ENV=dev --dart-define=API_URL=https://dev.api.com
/// flutter run --dart-define=ENV=prod --dart-define=API_URL=https://api.com
///
/// # Using a JSON file (recommended for many vars)
/// flutter run --dart-define-from-file=config/dev.json
/// flutter run --dart-define-from-file=config/prod.json
/// ```
import 'package:flutter/material.dart';

/// Standalone entry point.
void main() => runApp(_StandaloneApp());

class _StandaloneApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Build Flavors Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const BuildFlavorsDemo(),
    );
  }
}

/// Demo screen explaining build flavors and --dart-define.
class BuildFlavorsDemo extends StatelessWidget {
  const BuildFlavorsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('01 — Build Flavors'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Why flavors? ───────────────────────────────────────────────────
          _card(
            color: Colors.teal.shade50,
            child: const Text(
              'Without flavors: you manually change the API URL, app name, and '
              'Firebase config every time you switch between dev and production.\n\n'
              'With flavors: one command selects the entire environment profile.',
              style: TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),

          // ── 1. --dart-define approach ──────────────────────────────────────
          _header('1. --dart-define (Simplest Approach)', Colors.teal),
          _code('''
# Run commands with different environments
flutter run --dart-define=ENV=dev --dart-define=API_URL=https://dev.api.com
flutter run --dart-define=ENV=staging --dart-define=API_URL=https://staging.api.com
flutter build apk --dart-define=ENV=prod --dart-define=API_URL=https://api.com

# Read the value in Dart — String.fromEnvironment
const env = String.fromEnvironment('ENV', defaultValue: 'dev');
const apiUrl = String.fromEnvironment('API_URL', defaultValue: 'https://dev.api.com');

// IMPORTANT: these are compile-time constants.
// They are baked into the binary — not readable at runtime from env vars.'''),

          const SizedBox(height: 16),

          // ── 2. dart-define-from-file ───────────────────────────────────────
          _header('2. --dart-define-from-file (Recommended)', Colors.green),
          const Text(
            'Keeps all environment variables in a single JSON file per environment. '
            'Much cleaner than a long --dart-define chain.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 6),
          _code('''
// config/dev.json
{
  "ENV": "dev",
  "APP_NAME": "MyApp Dev",
  "API_URL": "https://dev.api.myapp.com",
  "GOOGLE_MAPS_KEY": "AIza...dev...",
  "ENABLE_LOGGING": "true"
}

// config/prod.json
{
  "ENV": "prod",
  "APP_NAME": "MyApp",
  "API_URL": "https://api.myapp.com",
  "GOOGLE_MAPS_KEY": "AIza...prod...",
  "ENABLE_LOGGING": "false"
}

# Run / build commands
flutter run --dart-define-from-file=config/dev.json
flutter build apk --dart-define-from-file=config/prod.json
flutter build appbundle --dart-define-from-file=config/prod.json

# Add config/ to .gitignore if it contains secrets!
echo "config/*.json" >> .gitignore'''),

          const SizedBox(height: 16),

          // ── 3. AppConfig pattern ───────────────────────────────────────────
          _header('3. AppConfig — Single Source of Truth', Colors.indigo),
          _code('''
// lib/core/config/app_config.dart

/// Central configuration resolved from --dart-define compile-time constants.
///
/// Access via AppConfig.instance anywhere in the app.
/// Never read String.fromEnvironment() directly in business logic —
/// always go through this class so it is easy to mock in tests.
class AppConfig {
  AppConfig._();

  // ── Compile-time constants ─────────────────────────────────────────────
  // String.fromEnvironment reads values injected via --dart-define.
  // The defaultValue is used when running without --dart-define (e.g. IDE default run).

  static const String env = String.fromEnvironment('ENV', defaultValue: 'dev');

  static const String apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://dev.api.myapp.com',
  );

  static const bool enableLogging =
      bool.fromEnvironment('ENABLE_LOGGING', defaultValue: true);

  static const String googleMapsKey =
      String.fromEnvironment('GOOGLE_MAPS_KEY', defaultValue: '');

  // ── Derived helpers ────────────────────────────────────────────────────

  /// True when running in the production environment.
  static bool get isProd => env == 'prod';

  /// True when running in development or staging.
  static bool get isDev => env == 'dev' || env == 'staging';

  // ── Debug display ──────────────────────────────────────────────────────
  static Map<String, dynamic> toMap() => {
    'env': env,
    'apiBaseUrl': apiBaseUrl,
    'enableLogging': enableLogging,
    'isProd': isProd,
  };
}

// Usage anywhere in the app:
// final dio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));
// if (AppConfig.enableLogging) logger.d('request: ...');'''),

          const SizedBox(height: 16),

          // ── 4. VS Code launch configs ──────────────────────────────────────
          _header('4. VS Code Launch Configs', Colors.orange),
          _code('''
// .vscode/launch.json — one config per environment, no manual flag typing
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Run Dev",
      "request": "launch",
      "type": "dart",
      "args": ["--dart-define-from-file=config/dev.json"]
    },
    {
      "name": "Run Staging",
      "request": "launch",
      "type": "dart",
      "args": ["--dart-define-from-file=config/staging.json"]
    },
    {
      "name": "Run Prod",
      "request": "launch",
      "type": "dart",
      "args": ["--dart-define-from-file=config/prod.json"]
    },
    {
      "name": "Build APK (Prod)",
      "request": "launch",
      "type": "dart",
      "flutterMode": "release",
      "args": ["--dart-define-from-file=config/prod.json"]
    }
  ]
}'''),

          const SizedBox(height: 16),

          // ── 5. Native Android productFlavors ──────────────────────────────
          _header('5. Native Android productFlavors', Colors.red),
          const Text(
            'Use native flavors when you need different app icons, '
            'app names in the launcher, or separate google-services.json '
            'files per environment.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          _code(r'''
// android/app/build.gradle
android {
  flavorDimensions 'env'

  productFlavors {
    dev {
      dimension 'env'
      applicationIdSuffix '.dev'         // com.example.app.dev
      versionNameSuffix '-dev'
      resValue 'string', 'app_name', 'MyApp Dev'
    }
    staging {
      dimension 'env'
      applicationIdSuffix '.staging'
      versionNameSuffix '-staging'
      resValue 'string', 'app_name', 'MyApp Staging'
    }
    prod {
      dimension 'env'
      // No suffix — production uses the base applicationId
      resValue 'string', 'app_name', 'MyApp'
    }
  }
}

// Run commands with native flavor:
// flutter run --flavor dev -t lib/main_dev.dart
// flutter build apk --flavor prod -t lib/main.dart
// flutter build appbundle --flavor prod -t lib/main.dart

// google-services.json per flavor:
// android/app/src/dev/google-services.json
// android/app/src/prod/google-services.json'''),

          const SizedBox(height: 16),

          // ── Live: current env ──────────────────────────────────────────────
          _header('6. Live: Current Build Environment', Colors.purple),
          Card(
            color: Colors.purple.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Show the current dart-define values (or defaults)
                  _envRow('ENV', const String.fromEnvironment('ENV', defaultValue: 'dev (default)')),
                  _envRow('API_URL', const String.fromEnvironment('API_URL', defaultValue: 'https://dev.api.com (default)')),
                  _envRow('LOGGING', const String.fromEnvironment('ENABLE_LOGGING', defaultValue: 'true (default)')),
                  const SizedBox(height: 8),
                  const Text(
                    'Run with --dart-define=ENV=prod to see these values change.',
                    style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          _card(
            color: Colors.teal.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Key Takeaways', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('• --dart-define-from-file=config/env.json = cleanest approach'),
                Text('• AppConfig class = single source of truth, easy to mock'),
                Text('• .vscode/launch.json = no manual flag typing per run'),
                Text('• Native productFlavors needed for different icons/app names/google-services'),
                Text('• Never commit config files that contain real API keys / secrets'),
                Text('• Use defaultValue so the app still runs from IDE without any flags'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _envRow(String key, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 80,
              child: Text(key,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontFamily: 'monospace', fontSize: 12)),
            ),
          ],
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
