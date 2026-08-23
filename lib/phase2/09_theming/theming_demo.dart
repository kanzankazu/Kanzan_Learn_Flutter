/// # Phase 2 — Topik 9: Theming (ThemeData, ColorScheme, Dark Mode)
///
/// Flutter menggunakan sistem theming terpusat lewat [ThemeData].
/// Semua widget Material secara otomatis mengikuti theme — tidak perlu
/// set warna manual di setiap widget.
///
/// **Material Design 3 (M3):**
/// Sistem design Google terbaru. Flutter support penuh lewat `useMaterial3: true`.
/// ColorScheme M3 punya banyak token warna (primary, secondary, tertiary, error, dll).
///
/// **Dark Mode:**
/// Flutter punya support dark mode bawaan lewat `themeMode` di MaterialApp.
/// Buat dua [ThemeData] — `theme` (light) dan `darkTheme` (dark).
///
/// Jalankan: `flutter run -t lib/phase2/09_theming/theming_demo.dart`

import 'package:flutter/material.dart';

void main() => runApp(const ThemingDemoApp());

// ===========================================================================
// ROOT APP dengan THEMING
// ===========================================================================

class ThemingDemoApp extends StatefulWidget {
  const ThemingDemoApp({super.key});

  @override
  State<ThemingDemoApp> createState() => _ThemingDemoAppState();
}

class _ThemingDemoAppState extends State<ThemingDemoApp> {
  ThemeMode _themeMode = ThemeMode.system; // ikuti setting device
  Color _seedColor = Colors.indigo; // warna seed untuk ColorScheme

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

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

class ThemingDemoScreen extends StatelessWidget {
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;
  final ValueChanged<Color> onChangeColor;
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
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theming & ColorScheme'),
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
            // Pilih warna seed
            _SectionTitle('Pilih Warna Tema'),
            _ColorPicker(currentColor: currentColor, onColorSelected: onChangeColor),
            const SizedBox(height: 24),

            // Tampilkan semua warna di ColorScheme
            _SectionTitle('ColorScheme Tokens'),
            _ColorSchemeGrid(colorScheme: colorScheme),
            const SizedBox(height: 24),

            // Typography
            _SectionTitle('Typography Scale'),
            _TypographyDemo(),
            const SizedBox(height: 24),

            // Widget yang otomatis mengikuti theme
            _SectionTitle('Widgets Mengikuti Theme Otomatis'),
            _ThemedWidgetsDemo(),
            const SizedBox(height: 24),

            // Custom widget yang perlu Theme.of(context)
            _SectionTitle('Akses Theme di Custom Widget'),
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

class _ColorPicker extends StatelessWidget {
  final Color currentColor;
  final ValueChanged<Color> onColorSelected;

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

class _ColorSchemeGrid extends StatelessWidget {
  final ColorScheme colorScheme;
  const _ColorSchemeGrid({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    // Pasangan warna (background + on-background)
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

class _TypographyDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
            // Semua widget ini otomatis menggunakan warna dari ColorScheme
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
            // CircularProgressIndicator — gunakan warna primary
            const CircularProgressIndicator(),
            const SizedBox(height: 8),
            // LinearProgressIndicator
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
