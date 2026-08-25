/// Phase 8 — Topic 05: Firebase Crashlytics & Analytics
///
/// After publishing, you need to know:
/// - Crashlytics: "Is my app crashing? What is crashing? Who is affected?"
/// - Analytics:   "How are users using my app? Which features are popular?"
///
/// Both are Firebase services that integrate seamlessly with Flutter.
///
/// Key concepts covered:
/// 1. Crashlytics setup: FlutterError.onError, PlatformDispatcher, isolate errors
/// 2. Recording non-fatal errors: FirebaseCrashlytics.instance.recordError()
/// 3. Custom keys and logs: setCustomKey(), log()
/// 4. User identification: setUserIdentifier()
/// 5. Analytics setup: logEvent(), setCurrentScreen(), setUserId()
/// 6. Custom events vs predefined events
/// 7. Testing Crashlytics before release
/// 8. Dashboard: what to watch — ANR rate, crash-free sessions, event funnels
///
/// Setup prerequisites:
/// ```bash
/// dart pub global activate flutterfire_cli
/// flutterfire configure   # links your Flutter app to Firebase project
/// ```
import 'package:flutter/material.dart';

/// Standalone entry point.
void main() => runApp(_StandaloneApp());

class _StandaloneApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crashlytics & Analytics Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const CrashlyticsAnalyticsDemo(),
    );
  }
}

/// Demo screen explaining Crashlytics and Analytics setup and usage.
class CrashlyticsAnalyticsDemo extends StatelessWidget {
  const CrashlyticsAnalyticsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('05 — Crashlytics & Analytics'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── 1. Package setup ───────────────────────────────────────────────
          _header('1. Package Setup', Colors.orange),
          _code('''
# pubspec.yaml
dependencies:
  firebase_core: ^3.6.0
  firebase_crashlytics: ^4.1.3
  firebase_analytics: ^11.3.3

# Then run flutterfire configure to generate firebase_options.dart:
dart pub global activate flutterfire_cli
flutterfire configure
# → Creates lib/firebase_options.dart with your project config'''),

          const SizedBox(height: 16),

          // ── 2. Crashlytics initialization ──────────────────────────────────
          _header('2. Crashlytics — Catch ALL Errors', Colors.red),
          const Text(
            'Three error hooks are needed to catch every possible crash type.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          _code('''
// lib/main.dart

import 'dart:isolate';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ── Hook 1: Flutter framework errors (widget build errors, etc.) ──────
  FlutterError.onError = (errorDetails) {
    // recordFlutterFatalError sends it to Crashlytics AND marks it as fatal
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  // ── Hook 2: Async errors NOT caught by FlutterError ───────────────────
  // e.g. errors thrown in Future.delayed, Zone, isolate message handler
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true; // returning true = error handled, don\'t propagate
  };

  // ── Hook 3: Uncaught errors in background Isolates ────────────────────
  Isolate.current.addErrorListener(
    RawReceivePort((pair) async {
      final List<dynamic> errorAndStacktrace = pair as List<dynamic>;
      await FirebaseCrashlytics.instance.recordError(
        errorAndStacktrace.first,
        errorAndStacktrace.last as StackTrace?,
        fatal: true,
      );
    }).sendPort,
  );

  // Disable Crashlytics in dev (so you don\'t pollute production data)
  await FirebaseCrashlytics.instance
      .setCrashlyticsCollectionEnabled(!kDebugMode);

  runApp(const MyApp());
}'''),

          const SizedBox(height: 16),

          // ── 3. Non-fatal errors ────────────────────────────────────────────
          _header('3. Record Non-Fatal Errors', Colors.deepOrange),
          _code('''
// lib/core/error/error_reporter.dart

class ErrorReporter {
  static final _crashlytics = FirebaseCrashlytics.instance;

  /// Record a caught exception that did NOT crash the app.
  /// Shows in Crashlytics as a non-fatal issue — still actionable.
  static Future<void> recordError(
    Object error,
    StackTrace stack, {
    String? reason,   // human-readable context: "while fetching user profile"
  }) async {
    await _crashlytics.recordError(
      error,
      stack,
      reason: reason,
      fatal: false,   // non-fatal = user saw an error message, app kept running
    );
  }

  /// Attach arbitrary key-value context to every report.
  /// Visible in the Crashlytics dashboard alongside the crash.
  static Future<void> setContext({
    required String userId,
    required String env,
    required String appVersion,
  }) async {
    await _crashlytics.setUserIdentifier(userId);
    await _crashlytics.setCustomKey('env', env);
    await _crashlytics.setCustomKey('app_version', appVersion);
  }

  /// Add a breadcrumb log (last 64 logs appear alongside crash report).
  static void log(String message) => _crashlytics.log(message);
}

// Usage in a repository:
Future<User> fetchUser(String id) async {
  try {
    return await _api.getUser(id);
  } catch (e, stack) {
    ErrorReporter.log('fetchUser failed for id=\$id');
    await ErrorReporter.recordError(e, stack, reason: 'fetchUser id=\$id');
    rethrow;
  }
}'''),

          const SizedBox(height: 16),

          // ── 4. Analytics ───────────────────────────────────────────────────
          _header('4. Firebase Analytics', Colors.blue),
          _code('''
// lib/core/analytics/analytics_service.dart

class AnalyticsService {
  static final _analytics = FirebaseAnalytics.instance;

  // ── Screen tracking ────────────────────────────────────────────────────
  // Call this on every screen change to populate the "Screens" report.
  static Future<void> logScreen(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
    // Or set current screen (older API):
    await _analytics.setCurrentScreen(screenName: screenName);
  }

  // ── User identification ────────────────────────────────────────────────
  // Lets you see behavior per user segment in Analytics.
  static Future<void> setUser({required String userId}) async {
    await _analytics.setUserId(id: userId);
  }

  // ── Predefined events (best for Play Store / Google benchmarks) ────────
  static Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method); // 'email', 'google', etc.
  }

  static Future<void> logPurchase({
    required double value,
    required String currency,
    required String itemId,
  }) async {
    await _analytics.logPurchase(
      value: value,
      currency: currency,
      items: [AnalyticsEventItem(itemId: itemId)],
    );
  }

  // ── Custom events ──────────────────────────────────────────────────────
  static Future<void> logFeatureUsed(String featureName) async {
    await _analytics.logEvent(
      name: 'feature_used',          // snake_case, max 40 chars
      parameters: {
        'feature_name': featureName, // string param, max 100 chars
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
}

// Usage:
// AnalyticsService.logScreen('HomeScreen');
// AnalyticsService.logFeatureUsed('dark_mode_toggle');'''),

          const SizedBox(height: 16),

          // ── 5. GoRouter screen tracking ────────────────────────────────────
          _header('5. Auto Screen Tracking with GoRouter', Colors.teal),
          _code('''
// Attach FirebaseAnalyticsObserver to GoRouter for automatic screen tracking
final _router = GoRouter(
  routes: [...],
  observers: [
    FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
  ],
);

// Every GoRouter navigation automatically calls logScreenView ✅
// No manual calls needed in each screen.'''),

          const SizedBox(height: 16),

          // ── 6. Testing Crashlytics ─────────────────────────────────────────
          _header('6. Testing Crashlytics Before Release', Colors.purple),
          _code('''
// Force a test crash (ONLY in debug/internal builds — never in prod!)
ElevatedButton(
  onPressed: () => FirebaseCrashlytics.instance.crash(),
  child: const Text('Test Crash (Dev Only)'),
)

// Check: Crashlytics dashboard should show the crash within ~5 minutes.
// Make sure collection is ENABLED for your test build:
await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

// Send a test non-fatal error:
await FirebaseCrashlytics.instance.recordError(
  Exception('test non-fatal'),
  StackTrace.current,
  reason: 'manual test',
  fatal: false,
);'''),

          const SizedBox(height: 16),
          _card(
            color: Colors.orange.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Key Takeaways', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('• Three hooks needed: FlutterError.onError, PlatformDispatcher.onError, Isolate error listener'),
                Text('• Disable Crashlytics collection in kDebugMode (don\'t pollute prod data)'),
                Text('• recordError(fatal: false) for handled errors, fatal: true for crashes'),
                Text('• setCustomKey() attaches context to every crash report'),
                Text('• FirebaseAnalyticsObserver on GoRouter = automatic screen tracking'),
                Text('• Custom events: snake_case name, ≤ 40 chars, ≤ 25 params per event'),
              ],
            ),
          ),
        ],
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
