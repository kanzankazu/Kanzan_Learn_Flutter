/// Phase 8 — Topic 02: App Signing
///
/// Every app published to the Play Store or App Store must be digitally signed.
/// Signing proves the APK/AAB came from you and hasn't been tampered with.
/// The OS also uses the signing key to verify updates — users can only receive
/// updates signed with the SAME key as the version they have installed.
///
/// CRITICAL: If you lose your keystore, you can NEVER update your app.
/// Back it up in at least 2 secure locations (password manager + encrypted drive).
///
/// Key concepts covered:
/// 1. Android keystore: keytool, key.properties, build.gradle wiring
/// 2. key.properties: keeps signing config out of source control
/// 3. build.gradle signingConfigs: reference key.properties at build time
/// 4. iOS: Xcode automatic signing vs manual provisioning profiles
/// 5. CI signing: ENCODED_KEYSTORE environment variable approach
/// 6. Play App Signing: Google manages the upload key risk
///
/// How to create a keystore:
/// ```bash
/// keytool -genkey -v \
///   -keystore ~/keys/my-release-key.jks \
///   -alias my-key-alias \
///   -keyalg RSA \
///   -keysize 2048 \
///   -validity 10000
/// ```
import 'package:flutter/material.dart';

/// Standalone entry point.
void main() => runApp(_StandaloneApp());

class _StandaloneApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Signing Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const AppSigningDemo(),
    );
  }
}

/// Demo screen explaining app signing for Android and iOS.
class AppSigningDemo extends StatelessWidget {
  const AppSigningDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('02 — App Signing'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Why signing matters ────────────────────────────────────────────
          _card(
            color: Colors.red.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('⚠️  WARNING: Keystore = Your Identity',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.red)),
                SizedBox(height: 6),
                Text(
                  'If you lose your Android keystore, you CANNOT push updates '
                  'to existing users. You would need to publish a new app with '
                  'a new package name. Back it up immediately and store it in '
                  'at least two separate secure locations.',
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── 1. Create Android keystore ─────────────────────────────────────
          _header('1. Create Android Keystore', Colors.indigo),
          _code(r'''
# Create a keystore file (run this ONCE — store the result securely)
keytool -genkey -v \
  -keystore ~/keys/my-release-key.jks \
  -alias my-key-alias \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000

# You will be prompted for:
# - Keystore password (remember this!)
# - Key alias password  (can be same as keystore)
# - Name, org, city, country

# Verify the keystore was created
keytool -list -v -keystore ~/keys/my-release-key.jks

# NEVER commit ~/keys/ to git. Add to .gitignore:
echo "*.jks" >> .gitignore
echo "*.keystore" >> .gitignore
echo "android/key.properties" >> .gitignore'''),

          const SizedBox(height: 16),

          // ── 2. key.properties ─────────────────────────────────────────────
          _header('2. key.properties (Secrets File)', Colors.teal),
          const Text(
            'Store signing credentials in a separate file — '
            'NEVER hardcode them directly in build.gradle.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          _code('''
# android/key.properties   ← add this file to .gitignore!
storePassword=your_keystore_password
keyPassword=your_key_password
keyAlias=my-key-alias
storeFile=/Users/yourname/keys/my-release-key.jks
# On CI: use an absolute path or an env var for storeFile'''),

          const SizedBox(height: 16),

          // ── 3. build.gradle wiring ─────────────────────────────────────────
          _header('3. Wire Up build.gradle', Colors.orange),
          _code(r'''
// android/app/build.gradle

// Step 1: Load key.properties at the top of the file
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // Step 2: Define the signing config using properties from key.properties
    signingConfigs {
        release {
            keyAlias     keystoreProperties['keyAlias']
            keyPassword  keystoreProperties['keyPassword']
            storeFile    keystoreProperties['storeFile'] ?
                             file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            // Step 3: Apply the signing config to the release build
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt'),
                          'proguard-rules.pro'
        }
    }
}

// Build the release AAB:
// flutter build appbundle   → uses the release signingConfig above'''),

          const SizedBox(height: 16),

          // ── 4. CI signing ──────────────────────────────────────────────────
          _header('4. CI Signing (GitHub Actions)', Colors.purple),
          const Text(
            'On CI there is no local keystore file. Encode it as Base64, '
            'store as a secret, decode at build time.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          _code(r'''
# Step 1: Encode your keystore as Base64 (run locally, copy output)
base64 -i ~/keys/my-release-key.jks | pbcopy   # macOS (copies to clipboard)
# Paste as GitHub Secret: KEYSTORE_BASE64

# Step 2: GitHub Actions workflow
- name: Decode keystore
  run: |
    echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 --decode \
      > android/app/release-key.jks

- name: Build release AAB
  env:
    KEY_ALIAS:     ${{ secrets.KEY_ALIAS }}
    KEY_PASSWORD:  ${{ secrets.KEY_PASSWORD }}
    STORE_FILE:    android/app/release-key.jks
    STORE_PASSWORD: ${{ secrets.STORE_PASSWORD }}
  run: |
    # Create key.properties from env vars at build time
    cat > android/key.properties <<EOF
    storeFile=$STORE_FILE
    storePassword=$STORE_PASSWORD
    keyAlias=$KEY_ALIAS
    keyPassword=$KEY_PASSWORD
    EOF
    flutter build appbundle --release'''),

          const SizedBox(height: 16),

          // ── 5. Play App Signing ────────────────────────────────────────────
          _header('5. Play App Signing (Recommended)', Colors.green),
          _card(
            color: Colors.green.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('How it works:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text(
                  '1. You upload with an "upload key" (your keystore)\n'
                  '2. Google re-signs with their managed "app signing key"\n'
                  '3. If you lose your upload key, Google can reset it\n'
                  '4. The final APK delivered to users is signed by Google',
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 8),
                Text(
                  'Opt in at: Play Console → Your app → Setup → App signing',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── 6. iOS signing overview ────────────────────────────────────────
          _header('6. iOS Signing Overview', Colors.red),
          _code('''
# iOS signing is managed through Xcode and Apple Developer Portal.
# Flutter hands off to Xcode for the actual signing step.

# Automatic signing (easiest — for development):
# In Xcode: Runner → Signing & Capabilities → Automatically manage signing ✅
# Xcode downloads the right provisioning profile automatically.

# Manual signing (required for CI):
# 1. Download .p12 certificate from Apple Developer Portal
# 2. Download .mobileprovision profile
# 3. Install both on the CI machine
# 4. Set CODE_SIGN_IDENTITY and PROVISIONING_PROFILE in Xcode build settings

# Build release IPA:
flutter build ipa --release
# → build/ios/ipa/Runner.ipa

# Or using xcodebuild directly (for more control):
xcodebuild -workspace ios/Runner.xcworkspace \\
  -scheme Runner \\
  -configuration Release \\
  -archivePath build/ios/Runner.xcarchive \\
  archive'''),

          const SizedBox(height: 16),
          _card(
            color: Colors.indigo.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Key Takeaways', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('• BACK UP your keystore — losing it = losing your app'),
                Text('• key.properties must be in .gitignore — never commit credentials'),
                Text('• CI: encode keystore as Base64 → GitHub Secret → decode at build time'),
                Text('• Play App Signing removes the risk of losing your upload key'),
                Text('• iOS: Automatic signing for dev, manual for CI/release'),
                Text('• Keystore validity = 10000 days ≈ 27 years (use a large number)'),
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
