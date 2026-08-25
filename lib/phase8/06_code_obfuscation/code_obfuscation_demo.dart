/// Phase 8 — Topic 06: Code Obfuscation
///
/// Obfuscation renames Dart classes, methods, and fields to meaningless
/// symbols (a, b, c…) in the compiled binary. This makes reverse engineering
/// harder and reduces binary size slightly.
///
/// Flutter supports two obfuscation mechanisms:
///
/// ┌─────────────────────────────────────────────────────────────────────────┐
/// │ Dart obfuscation  → --obfuscate --split-debug-info                     │
/// │   • Renames Dart symbols in the compiled AOT binary                    │
/// │   • Works for all platforms (Android, iOS, macOS, Linux, Windows)      │
/// ├─────────────────────────────────────────────────────────────────────────┤
/// │ Android R8/ProGuard  → proguard-rules.pro                              │
/// │   • Minifies + obfuscates Java/Kotlin code and dependencies            │
/// │   • Removes unused code (tree-shaking for JVM layer)                   │
/// │   • Required when you use Java/Kotlin packages                         │
/// └─────────────────────────────────────────────────────────────────────────┘
///
/// IMPORTANT: --split-debug-info generates symbol map files (.symbols).
/// You MUST keep these files to de-obfuscate crash stack traces from
/// Crashlytics or Play Console. Without them, crashes are unreadable.
///
/// Key concepts covered:
/// 1. --obfuscate --split-debug-info flags
/// 2. Symbol files: what they are and where to store them
/// 3. De-obfuscating stack traces with flutter symbolize
/// 4. ProGuard / R8 rules: keep rules for reflection-based libraries
/// 5. Testing obfuscated builds: potential issues to watch for
/// 6. What obfuscation does NOT protect (it is not encryption)
import 'package:flutter/material.dart';

/// Standalone entry point.
void main() => runApp(_StandaloneApp());

class _StandaloneApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Code Obfuscation Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      home: const CodeObfuscationDemo(),
    );
  }
}

/// Demo screen explaining code obfuscation.
class CodeObfuscationDemo extends StatelessWidget {
  const CodeObfuscationDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('06 — Code Obfuscation'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── What obfuscation is and isn't ─────────────────────────────────
          _card(
            color: Colors.orange.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('What Obfuscation IS:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('• Makes reverse engineering harder and more time-consuming'),
                Text('• Renames symbols so class/method names are meaningless'),
                Text('• Slightly reduces binary size'),
                SizedBox(height: 8),
                Text('What Obfuscation is NOT:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.red)),
                Text('• NOT encryption — determined attackers can still reverse it'),
                Text('• NOT a substitute for proper API security on the backend'),
                Text('• NOT protection for secrets hardcoded in the binary'),
                Text('  → Never hardcode API keys in client code'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── 1. Dart obfuscation flags ──────────────────────────────────────
          _header('1. Dart Obfuscation Flags', Colors.brown),
          _code(r'''
# Build with Dart obfuscation
# --obfuscate          = rename Dart symbols
# --split-debug-info   = save the symbol map to a directory (REQUIRED with --obfuscate)

flutter build appbundle --release \
  --obfuscate \
  --split-debug-info=build/symbols/android

flutter build ipa --release \
  --obfuscate \
  --split-debug-info=build/symbols/ios

# The build/symbols/ directory contains .symbols files (one per architecture).
# These are NOT included in the app binary.
# Store them alongside your release — you need them to read crash reports.

# Recommended: version the symbol files alongside your release tags in git
# or upload to Firebase Crashlytics (it de-obfuscates automatically):
firebase crashlytics:symbols:upload \
  --app=YOUR_APP_ID \
  build/symbols/android/'''),

          const SizedBox(height: 16),

          // ── 2. What gets obfuscated ────────────────────────────────────────
          _header('2. What Gets Obfuscated', Colors.teal),
          _code(r'''
// Before obfuscation (readable):
class UserRepository {
  Future<User> fetchUserById(String id) async { ... }
}

// After obfuscation (in the binary — unreadable):
class a {
  Future<b> c(String d) async { ... }
}

// Stack trace BEFORE de-obfuscation (useless):
#0  a.c (package:myapp/...)
#1  b.d (package:myapp/...)

// Stack trace AFTER de-obfuscation (readable):
#0  UserRepository.fetchUserById (lib/data/user_repository.dart:42)
#1  LoginUseCase.execute (lib/domain/login_use_case.dart:18)'''),

          const SizedBox(height: 16),

          // ── 3. De-obfuscate crash traces ───────────────────────────────────
          _header('3. De-Obfuscating Stack Traces', Colors.indigo),
          _code(r'''
# flutter symbolize reads the .symbols file and translates an obfuscated trace
flutter symbolize \
  --debug-info=build/symbols/android/app.android-arm64.symbols \
  --input=crash_trace.txt

# crash_trace.txt — the obfuscated trace from Crashlytics / Play Console:
# *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
# #00 pc 0000000006c1a6e0  libapp.so (a.c+256)
# #01 pc 0000000006b92340  libapp.so (b.d+128)

# Output after symbolize:
# #00 UserRepository.fetchUserById (lib/data/user_repository.dart:42:12)
# #01 LoginUseCase.execute (lib/domain/login_use_case.dart:18:5)

# If you use Firebase Crashlytics: upload symbols and it de-obfuscates automatically
# in the dashboard — no manual step needed per crash.
firebase crashlytics:symbols:upload --app=APP_ID build/symbols/android/'''),

          const SizedBox(height: 16),

          // ── 4. Android ProGuard / R8 ───────────────────────────────────────
          _header('4. Android R8 / ProGuard Rules', Colors.red),
          const Text(
            'R8 (successor to ProGuard) minifies and obfuscates the Java/Kotlin '
            'layer. Already enabled by default in release builds via minifyEnabled.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          _code(r'''
// android/app/build.gradle
android {
  buildTypes {
    release {
      minifyEnabled true      // enable R8 minification + obfuscation
      shrinkResources true    // remove unused resources (icons, strings, etc.)
      proguardFiles \
        getDefaultProguardFile('proguard-android-optimize.txt'),
        'proguard-rules.pro'
    }
  }
}

// android/app/proguard-rules.pro
// Add -keep rules for libraries that use reflection (JSON, DI frameworks)

// Keep Gson model classes (reflection-based JSON parsing)
-keep class com.example.myapp.data.** { *; }
-keepattributes Signature
-keepattributes *Annotation*

// Keep Flutter-specific classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

// Keep Firebase (usually handled by Firebase's own consumer rules)
-keep class com.google.firebase.** { *; }

// If using Retrofit / OkHttp
-dontwarn okhttp3.**
-dontwarn retrofit2.**

// Keep enum values (R8 can strip them if they look unused)
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}'''),

          const SizedBox(height: 16),

          // ── 5. Testing obfuscated build ────────────────────────────────────
          _header('5. Testing the Obfuscated Build', Colors.purple),
          _card(
            color: Colors.purple.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Common issues after enabling obfuscation:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text(
                  '• JSON serialization fails — reflection-based parsers need -keep rules\n'
                  '• DI framework breaks — annotated classes get renamed\n'
                  '• Deep links fail — activity/service class names in AndroidManifest\n'
                  '  must match the compiled class name (they are kept automatically)\n'
                  '• Plugin crashes — most Flutter plugins already ship -keep rules\n\n'
                  'Always run a full manual smoke test on the RELEASE build before submitting.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          _code(r'''
# Install and test the actual release build on a real device before uploading:
flutter build apk --release --obfuscate --split-debug-info=build/symbols
adb install build/app/outputs/apk/release/app-release.apk

# Then manually test every critical flow:
# ✓ Login / sign up
# ✓ Network requests (JSON parsing)
# ✓ Navigation (deep links, notifications)
# ✓ In-app purchase (if applicable)
# ✓ Firebase events firing correctly'''),

          const SizedBox(height: 16),
          _card(
            color: Colors.brown.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Key Takeaways', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('• Always use --obfuscate together with --split-debug-info'),
                Text('• Store .symbols files per release — you NEED them for crash de-obfuscation'),
                Text('• Upload symbols to Crashlytics for automatic de-obfuscation in dashboard'),
                Text('• R8/ProGuard minifies the Java/Kotlin layer — add -keep rules for reflection'),
                Text('• Test the release build manually before submitting to the store'),
                Text('• Obfuscation ≠ security — never put secrets in client code'),
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
