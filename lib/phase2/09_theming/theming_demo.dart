/// # Phase 2 — Topic 9: Theming (ThemeData, ColorScheme, Dark Mode)
///
/// Flutter uses a centralized theming system via [ThemeData].
/// All Material widgets automatically follow the theme — no need to
/// set colors manually on every single widget.
///
/// **Why centralized theming?**
/// Imagine changing your app's primary color. Without theming you'd need
/// to update hundreds of `color: Colors.blue` lines. With theming, you
/// change one line in ThemeData and every widget updates automatically.
///
/// **Material Design 3 (M3):**
/// Google's latest design system. Flutter has full support via `useMaterial3: true`.
/// M3 ColorScheme has many color tokens: primary, secondary, tertiary, error, surface, etc.
/// Each token also has an "on-" counterpart (onPrimary, onSurface) that guarantees
/// readable contrast — you never have to calculate contrast ratios manually.
///
/// **Dark Mode:**
/// Flutter has built-in dark mode support via `themeMode` in MaterialApp.
/// Create two [ThemeData] objects — `theme` (light) and `darkTheme` (dark).
/// The OS tells Flutter which to use when `ThemeMode.system` is set.
///
/// **Key classes:**
/// - [ThemeData] → the full theme configuration
/// - [ColorScheme] → all the color tokens (generated from a seed color)
/// - [TextTheme] → typography scale (displayLarge, bodyMedium, etc.)
///
/// How to run: `flutter run -t lib/phase2/09_theming/theming_demo.dart`

import 'package:flutter/material.dart';

void main() => runApp(const ThemingDemoApp());

// ===========================================================================
// ROOT APP WITH THEMING
// ===========================================================================

/// Root widget that owns the [ThemeData] and [ThemeMode] state.
///
/// This is the recommended pattern: keep theme state at the top of the widget
/// tree so any descendant can change the theme (e.g. a settings screen deep
/// inside the app).
///
/// The key insight: [MaterialApp] is the bridge between our [ThemeData] and
/// all the Material widgets below it. Every widget calls [Theme.of(context)]
/// internally to pick up colors, typography, shapes, etc.
class ThemingDemoApp extends StatefulWidget {
  const ThemingDemoApp({super.key});

  @override
  State<ThemingDemoApp> createState() => _ThemingDemoAppState();
}

class _ThemingDemoAppState extends State<ThemingDemoApp> {
  ThemeMode _themeMode = ThemeMode.system; // follow the device OS setting
  Color _seedColor = Colors.indigo; // one seed color generates the whole ColorScheme

  /// Toggle between light and dark mode.
  /// setState() here rebuilds MaterialApp, which propagates the new themeMode
  /// down the entire widget tree — all descendants update automatically.
  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  /// Change the seed color used to generate the ColorScheme.
  /// Flutter derives ~25 color tokens from a single seed using the M3 algorithm.
  void _changeColor(Color color) {
    setState(() => _seedColor = color);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Theming Demo',
      debugShowCheckedModeBanner: false,

      // Light theme
      theme: ThemeData(
        // colorSchemeSeed: generate ColorScheme lengkap dari satu warna
        // Flutter akan otomatis generate primary, secondary, surface, dll
        colorSchemeSeed: _seedColor,
        useMaterial3: true, // aktifkan Material Design 3
        // Kustomisasi typography (opsional — ada default yang bagus)
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      // Dark theme — sama tapi dengan brightness dark
      darkTheme: ThemeData(
        colorSchemeSeed: _seedColor,
        useMaterial3: true,
        brightness: Brightness.dark, // ← ini yang membedakan light vs dark
      ),

      // ThemeMode: system (ikuti OS), light, atau dark
      themeMode: _themeMode,

      home: ThemingDemoScreen(
        themeMode: _themeMode,
        onToggleTheme: _toggleTheme,
        onChangeColor: _changeColor,
        currentColor: _seedColor,
      ),
    );
  }
}

// ===========================================================================
// DEMO SCREEN
// ===========================================================================

/// Main demo screen. Receives callbacks from the root app to modify the theme.
///
/// Notice: this widget doesn't own any theme state — it only *reads* the
/// current theme via [Theme.of(context)] and *notifies* the root when the
/// user requests a change. This is the "lift state up" pattern.
class ThemingDemoScreen extends StatelessWidget {
  /// The current theme mode — used to decide which icon to show in the AppBar.
  final ThemeMode themeMode;

  /// Callback to toggle dark/light mode. Defined in [_ThemingDemoAppState].
  final VoidCallback onToggleTheme;

  /// Callback to change the seed color. Defined in [_ThemingDemoAppState].
  final ValueChanged<Color> onChangeColor;

  /// The currently active seed color — passed to [_ColorPicker] to show selection.
  final Color currentColor;

  const ThemingDemoScreen({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
    required this.onChangeColor,
    required this.currentColor,
  });

  @override
  Widget build(BuildContext context) {
    // Theme.of(context) — access the current theme from anywhere in the tree.
    // This is how you read colors and styles without hardcoding them.
    final colorScheme = Theme.of(context).colorScheme;
    // brightness tells you if we're currently in dark or light mode
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theming & ColorScheme'),
        // inversePrimary = a light tint of the primary color.
        // Great for AppBar backgrounds — automatically readable in both modes.
        backgroundColor: colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Toggle Dark Mode',
            onPressed: onToggleTheme,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pick a seed color to regenerate the whole ColorScheme
            _SectionTitle('Pick a Theme Color'),
            _ColorPicker(currentColor: currentColor, onColorSelected: onChangeColor),
            const SizedBox(height: 24),

            // See all the color tokens that were generated from the seed
            _SectionTitle('ColorScheme Tokens'),
            _ColorSchemeGrid(colorScheme: colorScheme),
            const SizedBox(height: 24),

            // Typography scale — all the text styles available
            _SectionTitle('Typography Scale'),
            _TypographyDemo(),
            const SizedBox(height: 24),

            // Widgets that automatically follow the theme — no manual colors needed
            _SectionTitle('Widgets That Follow the Theme Automatically'),
            _ThemedWidgetsDemo(),
            const SizedBox(height: 24),

            // How to manually read the theme in your own custom widget
            _SectionTitle('Reading the Theme in a Custom Widget'),
            _CustomThemeWidget(),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// COLOR PICKER
// ===========================================================================

/// A row of colored circles that lets the user pick a seed color.
///
/// When a new color is tapped, [onColorSelected] notifies the root app,
/// which rebuilds [MaterialApp] with a new [ThemeData] generated from that seed.
/// This triggers a cascade rebuild of the entire widget tree — visually
/// everything changes color at once.
///
/// `static const _colors` — static because the list never changes; const
/// because all values are compile-time constants. This saves memory.
class _ColorPicker extends StatelessWidget {
  /// The currently active seed color (shows a checkmark on the selected dot).
  final Color currentColor;

  /// Called when the user taps a color dot.
  final ValueChanged<Color> onColorSelected;

  // static const → computed once at compile time, shared across all instances
  static const _colors = [
    Colors.indigo,
    Colors.blue,
    Colors.teal,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.pink,
    Colors.purple,
  ];

  const _ColorPicker({required this.currentColor, required this.onColorSelected});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: _colors.map((color) {
        final isSelected = color.value == currentColor.value;
        return GestureDetector(
          onTap: () => onColorSelected(color),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
              boxShadow: isSelected
                  ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)]
                  : null,
            ),
            child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
          ),
        );
      }).toList(),
    );
  }
}

// ===========================================================================
// COLORSCHEME GRID
// ===========================================================================

/// Displays all the color tokens that M3 generates from a single seed color.
///
/// **Key M3 pattern:** every "background" token has a matching "on-" token.
/// For example:
/// - `primary` (background color) + `onPrimary` (text/icon on that background)
/// - `surface` (card background)  + `onSurface` (text on cards)
///
/// You never have to manually check if text is readable on a background —
/// M3 guarantees that "on-" tokens always have sufficient contrast ratio (≥ 4.5:1).
///
/// 💡 Tip: Always use the "on-" counterpart for text/icons that sit on
/// a token background. Never hardcode Colors.white or Colors.black.
class _ColorSchemeGrid extends StatelessWidget {
  final ColorScheme colorScheme;
  const _ColorSchemeGrid({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    // Each tuple: (background color, text/icon color on that background, label)
    // The "on-" color is always readable on its matching background — guaranteed by M3.
    final pairs = [
      (colorScheme.primary, colorScheme.onPrimary, 'primary'),
      (colorScheme.secondary, colorScheme.onSecondary, 'secondary'),
      (colorScheme.tertiary, colorScheme.onTertiary, 'tertiary'),
      (colorScheme.error, colorScheme.onError, 'error'),
      (colorScheme.surface, colorScheme.onSurface, 'surface'),
      (colorScheme.primaryContainer, colorScheme.onPrimaryContainer, 'primaryContainer'),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: pairs.map((entry) {
        final (bg, fg, label) = entry;
        return Container(
          width: 100,
          height: 64,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ===========================================================================
// TYPOGRAPHY DEMO
// ===========================================================================

/// Shows the Flutter typography scale — the predefined text sizes for M3.
///
/// **Why use TextTheme instead of manual font sizes?**
/// - Consistent hierarchy across the app (displaySmall for hero text, bodyMedium for paragraphs)
/// - All styles respect the user's accessibility font size setting (system font scale)
/// - Easy to override globally in ThemeData.textTheme without touching individual widgets
///
/// **Common usage in real apps:**
/// - `displaySmall` / `headlineLarge` → hero banners, splash screens
/// - `headlineMedium` / `titleLarge`  → screen titles, card headers
/// - `bodyLarge` / `bodyMedium`       → paragraph text, descriptions
/// - `bodySmall` / `labelSmall`       → captions, hints, timestamps
/// - `labelLarge`                     → buttons (Flutter uses this internally)
class _TypographyDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the current TextTheme — automatically updates with the theme
    final tt = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('displaySmall', style: tt.displaySmall),
            Text('headlineMedium', style: tt.headlineMedium),
            Text('titleLarge', style: tt.titleLarge),
            Text('bodyLarge — ini teks normal biasa.', style: tt.bodyLarge),
            Text('bodySmall — teks kecil untuk subtitle.', style: tt.bodySmall),
            Text('labelLarge — label tombol biasanya', style: tt.labelLarge),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// THEMED WIDGETS DEMO
// ===========================================================================

/// Demonstrates that standard Material widgets pick up the theme automatically.
///
/// You don't pass any colors to Switch, Checkbox, Slider, or ProgressIndicator —
/// they read [ColorScheme.primary] from the theme internally.
///
/// **The magic:** every Material widget calls `Theme.of(context)` internally
/// during its `build()`. When the theme changes, Flutter rebuilds the widget
/// tree, and all widgets re-read the new colors automatically.
///
/// 💡 Tip: Try switching the theme color with the picker above —
/// all these widgets update instantly without any code changes.
class _ThemedWidgetsDemo extends StatefulWidget {
  @override
  State<_ThemedWidgetsDemo> createState() => _ThemedWidgetsDemoState();
}

class _ThemedWidgetsDemoState extends State<_ThemedWidgetsDemo> {
  bool _switchValue = true;
  bool _checkboxValue = true;
  double _sliderValue = 0.6;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // All of these widgets use ColorScheme.primary automatically —
            // no color argument needed. Change the seed color above to see them all update.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Switch'),
                Switch(value: _switchValue, onChanged: (v) => setState(() => _switchValue = v)),
              ],
            ),
            Row(
              children: [
                Checkbox(value: _checkboxValue, onChanged: (v) => setState(() => _checkboxValue = v!)),
                const Text('Checkbox'),
              ],
            ),
            Slider(
              value: _sliderValue,
              onChanged: (v) => setState(() => _sliderValue = v),
            ),
            const Divider(),
            // Progress indicators also follow the theme
            const CircularProgressIndicator(),
            const SizedBox(height: 8),
            const LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// CUSTOM THEME WIDGET
// ===========================================================================

/// Widget yang mengakses theme secara manual via Theme.of(context).
///
/// Gunakan ini ketika widget butuh warna/style yang tidak otomatis.
class _CustomThemeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Ambil theme dari context — JANGAN hardcode warna!
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Gunakan warna dari colorScheme — otomatis berubah saat dark mode
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Custom Widget dengan Theme',
            // Gunakan textTheme dari theme — otomatis mengikuti typography settings
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Warna container, teks, dan border semua dari ColorScheme — '
            'otomatis berubah saat dark mode aktif.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onPrimaryContainer.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// HELPER
// ===========================================================================

/// A bold section title that uses [TextTheme.titleMedium] from the current theme.
///
/// Extracting this into a separate widget demonstrates the "composition"
/// principle: reuse small widgets instead of repeating styling code.
/// If you wanted to change all section titles, you'd change this one class.
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
