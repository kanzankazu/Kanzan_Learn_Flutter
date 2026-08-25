/// Phase 10.5 — Topic 03: Feature Flags
///
/// Feature flags (a.k.a. feature toggles) decouple code deployment from
/// feature release. You ship code to production with the feature OFF,
/// then turn it on remotely — no app store update needed.
///
/// Use cases:
/// - A/B testing: show variant A to 50% of users, variant B to the other 50%
/// - Gradual rollout: enable for 10% → 50% → 100% of users
/// - Kill switch: instantly disable a broken feature
/// - Beta features: enable only for QA team or beta users
/// - Dark launch: run new code path silently, compare with old
///
/// Key concepts covered:
/// 1. Firebase Remote Config — the most common Flutter feature flag solution
/// 2. Feature flag abstraction — decouple from the specific provider
/// 3. A/B testing setup with Remote Config
/// 4. Local override — force a flag in debug mode
/// 5. Caching strategy — stale-while-revalidate
/// 6. LaunchDarkly pattern — enterprise feature management
import 'package:flutter/material.dart';

void main() => runApp(const _App());

class _App extends StatelessWidget {
  const _App();
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Feature Flags',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber), useMaterial3: true),
        home: const FeatureFlagsDemo(),
      );
}

class FeatureFlagsDemo extends StatefulWidget {
  const FeatureFlagsDemo({super.key});
  @override
  State<FeatureFlagsDemo> createState() => _FeatureFlagsDemoState();
}

class _FeatureFlagsDemoState extends State<FeatureFlagsDemo> {
  // Simulated feature flag state
  final Map<String, bool> _flags = {
    'new_payment_ui': false,
    'dark_mode_v2': true,
    'crypto_wallet': false,
    'ai_assistant': false,
    'promo_banner_v3': true,
  };

  void _toggle(String flag) => setState(() => _flags[flag] = !(_flags[flag] ?? false));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('03 — Feature Flags'), backgroundColor: Colors.amber.shade700, foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(color: Colors.amber.shade50, child: const Text(
            'Feature flags let you ship code without releasing features. '
            'Turn features on/off remotely, run A/B tests, and do gradual rollouts — '
            'all without a Play Store update.',
            style: TextStyle(fontSize: 13),
          )),
          const SizedBox(height: 16),

          // ── Live demo: flag dashboard ──────────────────────────────────
          _h('Live Demo — Feature Flag Dashboard', Colors.amber.shade700),
          ...(_flags.entries.map((e) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(e.key, style: const TextStyle(fontFamily: 'monospace')),
                  subtitle: Text(e.value ? 'ENABLED — feature is live for this user' : 'DISABLED — feature is hidden'),
                  trailing: Switch(value: e.value, onChanged: (_) => _toggle(e.key)),
                  leading: Icon(e.value ? Icons.toggle_on : Icons.toggle_off,
                      color: e.value ? Colors.green : Colors.grey, size: 28),
                ),
              ))),

          const SizedBox(height: 20),

          // ── 1. Firebase Remote Config ──────────────────────────────────
          _h('1. Firebase Remote Config Setup', Colors.orange),
          _code(r'''
# pubspec.yaml
dependencies:
  firebase_remote_config: ^5.1.3

// lib/core/config/feature_flags.dart

/// Abstraction over the feature flag provider.
/// Change from Remote Config to LaunchDarkly by swapping this impl.
abstract interface class IFeatureFlags {
  Future<void> initialize();
  bool isEnabled(String flagKey);
  T getValue<T>(String flagKey, T defaultValue);
  Future<void> refresh();
}

/// Firebase Remote Config implementation
class RemoteConfigFeatureFlags implements IFeatureFlags {
  final FirebaseRemoteConfig _config = FirebaseRemoteConfig.instance;

  @override
  Future<void> initialize() async {
    // Set default values — used before Remote Config is fetched
    await _config.setDefaults({
      'new_payment_ui':  false,
      'crypto_wallet':   false,
      'ai_assistant':    false,
      'promo_banner_v3': true,
    });

    // Fetch and activate (uses cache if fetched recently)
    await _config.fetchAndActivate();

    // Listen for real-time updates (auto-refresh when Remote Config changes)
    _config.onConfigUpdated.listen((event) async {
      await _config.activate();
      // Notify app that flags changed (e.g. invalidate Riverpod providers)
    });
  }

  @override
  bool isEnabled(String flagKey) => _config.getBool(flagKey);

  @override
  T getValue<T>(String flagKey, T defaultValue) {
    return switch (defaultValue) {
      bool()   => _config.getBool(flagKey) as T,
      int()    => _config.getInt(flagKey) as T,
      double() => _config.getDouble(flagKey) as T,
      String() => _config.getString(flagKey) as T,
      _        => defaultValue,
    };
  }

  @override
  Future<void> refresh() => _config.fetchAndActivate();
}'''),

          const SizedBox(height: 20),

          // ── 2. Riverpod integration ────────────────────────────────────
          _h('2. Feature Flags with Riverpod', Colors.blue),
          _code(r'''
// Typed, named flags — never use raw string keys in feature code
enum FeatureFlag {
  newPaymentUi('new_payment_ui'),
  cryptoWallet('crypto_wallet'),
  aiAssistant('ai_assistant'),
  promoBannerV3('promo_banner_v3');

  final String key;
  const FeatureFlag(this.key);
}

// Provider
@Riverpod(keepAlive: true)
IFeatureFlags featureFlags(FeatureFlagsRef ref) {
  final flags = RemoteConfigFeatureFlags();
  // Initialize is called in main() before runApp
  return flags;
}

// Helper provider per flag
@riverpod
bool isNewPaymentUiEnabled(IsNewPaymentUiEnabledRef ref) =>
    ref.watch(featureFlagsProvider).isEnabled(FeatureFlag.newPaymentUi.key);

// Usage in a widget:
@override
Widget build(BuildContext context, WidgetRef ref) {
  final showNewUi = ref.watch(isNewPaymentUiEnabledProvider);

  return showNewUi
      ? const NewPaymentScreen()   // new variant
      : const LegacyPaymentScreen(); // old variant
}'''),

          const SizedBox(height: 20),

          // ── 3. A/B testing ─────────────────────────────────────────────
          _h('3. A/B Testing with Remote Config', Colors.purple),
          _code(r'''
// Firebase console: create an A/B test experiment
// Experiment: "checkout_button_color"
// Variant A (50%): "blue"
// Variant B (50%): "green"

// In your app:
final buttonColor = ref.watch(featureFlagsProvider)
    .getValue('checkout_button_color', 'blue');

// Log the exposure so Firebase Analytics knows which variant the user saw
FirebaseAnalytics.instance.logEvent(
  name: 'ab_test_exposure',
  parameters: {
    'experiment': 'checkout_button_color',
    'variant': buttonColor,
  },
);

ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: buttonColor == 'green' ? Colors.green : Colors.blue,
  ),
  onPressed: _checkout,
  child: const Text('Checkout'),
)

// Firebase will show you conversion rates per variant in the A/B test dashboard.'''),

          const SizedBox(height: 20),

          // ── 4. Local override in debug ─────────────────────────────────
          _h('4. Local Override in Debug Mode', Colors.green),
          _code(r'''
// In debug builds, allow developers to override flags locally
// Useful for testing new features before they are enabled in Remote Config

class DebugFeatureFlags implements IFeatureFlags {
  final IFeatureFlags _real;
  final Map<String, dynamic> _overrides;

  DebugFeatureFlags(this._real, this._overrides);

  @override
  bool isEnabled(String key) =>
      _overrides.containsKey(key) ? _overrides[key] as bool : _real.isEnabled(key);

  // ... other methods delegate to _real
}

// In main.dart:
final flags = kDebugMode
    ? DebugFeatureFlags(
        RemoteConfigFeatureFlags(),
        {
          'new_payment_ui': true,  // always ON in debug
          'ai_assistant':   true,  // test the AI feature locally
        },
      )
    : RemoteConfigFeatureFlags();

// A debug settings screen that lets QA toggle flags manually:
// (see the live demo above ↑)'''),

          const SizedBox(height: 16),
          _card(color: Colors.amber.shade50, child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Key Takeaways', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Feature flags decouple deploy from release — ship code, release on demand'),
              Text('• Define an interface (IFeatureFlags) — swap Remote Config for LaunchDarkly anytime'),
              Text('• Use typed enums for flag keys — no raw strings in feature code'),
              Text('• A/B test: assign variants in Remote Config, log exposure to Analytics'),
              Text('• Local override in debug mode = QA can test any flag without prod access'),
              Text('• onConfigUpdated stream = real-time flag changes without app restart'),
            ],
          )),
        ],
      ),
    );
  }
}

Widget _h(String t, Color c) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(t, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: c)));
Widget _code(String s) => Container(width: double.infinity, margin: const EdgeInsets.only(bottom: 4), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF1E1E2E), borderRadius: BorderRadius.circular(6)), child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text(s, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Color(0xFFCDD6F4)))));
Widget _card({required Color color, required Widget child}) => Card(color: color, child: Padding(padding: const EdgeInsets.all(12), child: child));
