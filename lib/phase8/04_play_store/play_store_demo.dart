/// Phase 8 — Topic 04: Play Store Publishing
///
/// Publishing to the Play Store involves three steps:
/// 1. Build a signed AAB (Android App Bundle)
/// 2. Create a Play Console listing with metadata
/// 3. Submit through a release track (internal → closed → open → production)
///
/// AAB vs APK:
/// - AAB (recommended) = smaller download for users (Play optimizes per device)
/// - APK = single file, larger, works for direct install and older tooling
///
/// Release tracks:
/// internal → closed testing → open testing → production
/// Each track can have different user groups and rollout percentages.
///
/// Key concepts covered:
/// 1. Build commands: flutter build appbundle / apk
/// 2. Version naming: versionCode (int) + versionName (string)
/// 3. Play Console listing: screenshots, descriptions, content rating
/// 4. Release tracks and staged rollouts (e.g. 10% → 50% → 100%)
/// 5. Pre-launch report: Play automatically tests your app on real devices
/// 6. App Bundle Explorer: Play shows exactly what each device will download
/// 7. Release checklist before submitting
import 'package:flutter/material.dart';

/// Standalone entry point.
void main() => runApp(_StandaloneApp());

class _StandaloneApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Play Store Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const PlayStoreDemo(),
    );
  }
}

/// Demo screen covering Play Store publishing process.
class PlayStoreDemo extends StatelessWidget {
  const PlayStoreDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('04 — Play Store'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── 1. Build commands ──────────────────────────────────────────────
          _header('1. Build Commands', Colors.green.shade700),
          _code(r'''
# Build Android App Bundle (recommended for Play Store)
flutter build appbundle --release

# With flavor + dart-define
flutter build appbundle --release \
  --flavor prod \
  --dart-define-from-file=config/prod.json

# Output: build/app/outputs/bundle/release/app-release.aab

# Build APK (for direct install or non-Play distribution)
flutter build apk --release --split-per-abi
# --split-per-abi = one APK per architecture (smaller downloads)
# Output: build/app/outputs/apk/release/
#   app-arm64-v8a-release.apk   (most modern phones)
#   app-armeabi-v7a-release.apk (older phones)
#   app-x86_64-release.apk      (emulators)

# Check APK size BEFORE uploading
ls -lh build/app/outputs/bundle/release/app-release.aab
# Also run: flutter build apk --analyze-size for a detailed breakdown'''),

          const SizedBox(height: 16),

          // ── 2. Version management ──────────────────────────────────────────
          _header('2. Version Management', Colors.teal),
          _code(r'''
# pubspec.yaml
version: 1.2.3+45
#        ^^^^^^^ versionName (shown to users: "1.2.3")
#               ^^ versionCode (internal int, must increment EVERY release: 45)

# Rules:
# - versionCode MUST be greater than the previous release. Never reuse.
# - versionName is just a label — can be any string, shown in app info.
# - Common versioning: MAJOR.MINOR.PATCH+BUILD
#   1.0.0+1  → 1.0.1+2 → 1.1.0+3 → 2.0.0+4

# Override at build time (useful in CI):
flutter build appbundle \
  --build-name=1.2.3 \
  --build-number=45

# Auto-increment build number in CI using the git commit count:
BUILD_NUMBER=$(git rev-list --count HEAD)
flutter build appbundle --build-number=$BUILD_NUMBER'''),

          const SizedBox(height: 16),

          // ── 3. Play Console setup ──────────────────────────────────────────
          _header('3. Play Console Setup Checklist', Colors.orange),
          _ChecklistCard(items: const [
            'Create app at play.google.com/console → All apps → Create app',
            'App name (30 chars max), default language, app or game, free or paid',
            'Short description: 80 chars — hook users immediately',
            'Full description: 4000 chars — use keywords naturally',
            'App icon: 512×512 PNG, no alpha channel',
            'Feature graphic: 1024×500 PNG (shown in Play Store banner)',
            'Screenshots: min 2, max 8 per device type (phone required)',
            'Phone screenshots: 16:9 or 9:16, min 320px on short side',
            'Tablet screenshots: optional but boosts ranking',
            'Privacy policy URL (required for apps that collect any data)',
            'Content rating: complete the questionnaire',
            'Target audience and content: confirm age group',
            'Data safety section: declare what data you collect and why',
          ]),

          const SizedBox(height: 16),

          // ── 4. Release tracks ──────────────────────────────────────────────
          _header('4. Release Tracks & Staged Rollout', Colors.purple),
          _card(
            color: Colors.purple.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Track hierarchy (safest to broadest):',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text(
                  '① Internal testing  — up to 100 testers, instant publish\n'
                  '② Closed testing    — limited group (alpha/beta testers)\n'
                  '③ Open testing      — anyone can opt in\n'
                  '④ Production        — all users, optional staged rollout\n\n'
                  'Staged rollout: deploy to 10% of users first, monitor Crashlytics, '
                  'then increase to 50% → 100%. Halt if crash rate spikes.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── 5. Pre-launch report ───────────────────────────────────────────
          _header('5. Pre-Launch Report', Colors.red),
          _card(
            color: Colors.red.shade50,
            child: const Text(
              'When you upload to the internal or closed track, Play automatically '
              'runs your app on ~20 real devices (various Android versions) and '
              'reports crashes, ANRs, and accessibility issues BEFORE you publish.\n\n'
              'Check the Pre-launch report tab in Play Console before promoting '
              'to production.',
              style: TextStyle(fontSize: 13),
            ),
          ),

          const SizedBox(height: 16),

          // ── 6. Release checklist ───────────────────────────────────────────
          _header('6. Pre-Release Checklist', Colors.brown),
          _ChecklistCard(items: const [
            'flutter analyze → 0 errors',
            'flutter test → all passing',
            'Manual smoke test on a real device (not just emulator)',
            'Version code incremented from last release',
            'API URL set to production (not dev/staging)',
            'Logging disabled in release build',
            'Firebase pointing to production project',
            'ProGuard / R8 rules not breaking any functionality',
            'Tested on at least one low-end device (Android 8, 2GB RAM)',
            'Release notes written (what changed in this version)',
            'Screenshots updated if UI changed significantly',
          ]),

          const SizedBox(height: 16),
          _card(
            color: Colors.green.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Key Takeaways', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('• flutter build appbundle → .aab file (smaller than APK for users)'),
                Text('• versionCode MUST increase every upload — never reuse'),
                Text('• Use staged rollout: 10% → 50% → 100% with monitoring'),
                Text('• Check Pre-launch report before promoting to production'),
                Text('• Internal track = instant publish (great for team testing)'),
                Text('• --split-per-abi for APKs gives smaller files per architecture'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Renders a visual checklist card.
class _ChecklistCard extends StatelessWidget {
  final List<String> items;
  const _ChecklistCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items
              .map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_box_outline_blank,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(item,
                                style: const TextStyle(fontSize: 12))),
                      ],
                    ),
                  ))
              .toList(),
        ),
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
