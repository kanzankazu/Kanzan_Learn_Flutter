/// Phase 6 — Topic 07: Internationalization (i18n)
///
/// Internationalization = preparing your app to support multiple languages
/// and locales (date formats, number formats, text direction, etc.)
///
/// Flutter's official i18n stack:
///   flutter_localizations package  → built-in locale data (dates, numbers)
///   intl package                   → message formatting, date/number/plural
///   flutter gen-l10n               → code-gen from ARB files
///
/// Key concepts covered:
/// 1. ARB files (Application Resource Bundle) — the source of truth for strings
/// 2. [AppLocalizations] — generated class; access strings via context
/// 3. [MaterialApp.localizationsDelegates] — registers delegates
/// 4. [MaterialApp.supportedLocales] — declares which locales the app supports
/// 5. Locale switching at runtime — override via [Locale]
/// 6. [Intl.message] — mark strings for extraction
/// 7. Date/Number formatting with [DateFormat] and [NumberFormat]
///
/// NOTE: This file demonstrates the CONCEPTS and setup without requiring
/// code-gen. Strings are inline here to keep the demo self-contained.
/// In a real project you'd run `flutter gen-l10n` to generate AppLocalizations.
///
/// How to run:
/// ```bash
/// flutter run -t lib/phase6/main_phase6.dart
/// ```

import 'package:flutter/material.dart';

/// Standalone entry point so this file can be run directly:
/// ```bash
/// flutter run -t phase6/07_internationalization/internationalization_demo.dart
/// ```
void main() => runApp(_StandaloneApp());

/// Minimal app wrapper used only when running this file directly.
class _StandaloneApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InternationalizationDemo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const InternationalizationDemo(),
    );
  }
}


/// Demo screen for internationalization concepts.
class InternationalizationDemo extends StatefulWidget {
  const InternationalizationDemo({super.key});

  @override
  State<InternationalizationDemo> createState() =>
      _InternationalizationDemoState();
}

class _InternationalizationDemoState extends State<InternationalizationDemo> {
  // Active locale for the live demo section
  Locale _locale = const Locale('en');

  // Item count for pluralization demo
  int _itemCount = 1;

  @override
  Widget build(BuildContext context) {
    // Resolve the strings for the currently selected locale
    final strings = _AppStrings.of(_locale);

    return Scaffold(
      appBar: AppBar(
        title: const Text('07 — Internationalization'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── 1. ARB file format ─────────────────────────────────────────
          _header('1. ARB Files — Source of Truth', Colors.deepOrange),
          const Text(
            'Each locale has one .arb file in lib/l10n/. '
            'flutter gen-l10n reads them and generates a type-safe AppLocalizations class.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          _codeSnippet(
            '// lib/l10n/app_en.arb\n'
            '{\n'
            '  "@@locale": "en",\n'
            '  "appTitle": "My App",\n'
            '  "@appTitle": { "description": "App name shown in the title bar" },\n'
            '\n'
            '  "greeting": "Hello, {name}!",\n'
            '  "@greeting": {\n'
            '    "description": "Greeting message with user name",\n'
            '    "placeholders": {\n'
            '      "name": { "type": "String" }\n'
            '    }\n'
            '  },\n'
            '\n'
            '  "itemCount": "{count, plural, =0{No items} =1{1 item} other{{count} items}}",\n'
            '  "@itemCount": {\n'
            '    "placeholders": { "count": { "type": "int" } }\n'
            '  }\n'
            '}\n'
            '\n'
            '// lib/l10n/app_id.arb (Indonesian)\n'
            '{\n'
            '  "@@locale": "id",\n'
            '  "appTitle": "Aplikasi Saya",\n'
            '  "greeting": "Halo, {name}!",\n'
            '  "itemCount": "{count, plural, =0{Tidak ada item} =1{1 item} other{{count} item}}"\n'
            '}',
          ),

          const SizedBox(height: 20),

          // ── 2. pubspec setup ─────────────────────────────────────────────
          _header('2. pubspec.yaml Setup', Colors.brown),
          _codeSnippet(
            '# pubspec.yaml\n'
            'dependencies:\n'
            '  flutter_localizations:\n'
            '    sdk: flutter\n'
            '  intl: ^0.20.1    # date/number formatting + message extraction\n'
            '\n'
            'flutter:\n'
            '  generate: true   # enables flutter gen-l10n\n'
            '\n'
            '# l10n.yaml (in project root)\n'
            'arb-dir: lib/l10n\n'
            'template-arb-file: app_en.arb\n'
            'output-localization-file: app_localizations.dart\n'
            'output-class: AppLocalizations',
          ),

          const SizedBox(height: 20),

          // ── 3. MaterialApp wiring ────────────────────────────────────────
          _header('3. Wire Up MaterialApp', Colors.indigo),
          _codeSnippet(
            'MaterialApp(\n'
            '  // Delegates provide localized resources (widgets, cupertino, material)\n'
            '  localizationsDelegates: const [\n'
            '    AppLocalizations.delegate,             // your generated strings\n'
            '    GlobalMaterialLocalizations.delegate,  // Material widget strings\n'
            '    GlobalWidgetsLocalizations.delegate,   // text direction\n'
            '    GlobalCupertinoLocalizations.delegate, // Cupertino widgets\n'
            '  ],\n'
            '  // Declare all locales the app supports\n'
            '  supportedLocales: AppLocalizations.supportedLocales,\n'
            '  // Optional: force a specific locale (e.g. from user settings)\n'
            '  locale: _currentLocale,\n'
            '  home: const HomeScreen(),\n'
            ')',
          ),

          const SizedBox(height: 20),

          // ── 4. Using strings in code ─────────────────────────────────────
          _header('4. Using Strings in Widgets', Colors.green),
          _codeSnippet(
            '// Access strings via context (from the generated class)\n'
            'final l10n = AppLocalizations.of(context)!;\n'
            '\n'
            'Text(l10n.appTitle)           // simple string\n'
            'Text(l10n.greeting(\'Faisal\'))  // with placeholder\n'
            'Text(l10n.itemCount(3))        // with plural\n'
            '\n'
            '// Shorthand extension (add to your own codebase):\n'
            'extension BuildContextL10n on BuildContext {\n'
            '  AppLocalizations get l10n => AppLocalizations.of(this)!;\n'
            '}\n'
            '// Usage: context.l10n.appTitle',
          ),

          const SizedBox(height: 20),

          // ── 5. Live demo: locale switching ───────────────────────────────
          _header('5. Live Demo — Locale Switching', Colors.teal),
          const Text(
            'Switch the locale below to see strings change. '
            'In a real app you\'d store the user\'s preference in SharedPreferences '
            'and pass it to MaterialApp.locale.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 10),

          // Locale chips
          Wrap(
            spacing: 8,
            children: _AppStrings.supportedLocales.map((locale) {
              return ChoiceChip(
                label: Text(
                    _AppStrings.localeName(locale),
                    style: const TextStyle(fontSize: 12)),
                selected: _locale == locale,
                onSelected: (_) => setState(() => _locale = locale),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Live string demo card
          Card(
            color: Colors.teal.shade50,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _demoRow('App title', strings.appTitle),
                  _demoRow('Greeting', strings.greeting('Faisal')),
                  _demoRow('Direction', strings.textDirection),
                  const Divider(),
                  // Plural demo
                  Row(
                    children: [
                      const Text('Item count:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () =>
                            setState(() => _itemCount = (_itemCount - 1).clamp(0, 99)),
                      ),
                      Text('$_itemCount',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => setState(() => _itemCount++),
                      ),
                    ],
                  ),
                  Text(
                    strings.itemCount(_itemCount),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── 6. Date and Number formatting ────────────────────────────────
          _header('6. Date & Number Formatting (intl)', Colors.purple),
          const Text(
            'The intl package formats dates and numbers according to locale.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          _codeSnippet(
            'import \'package:intl/intl.dart\';\n'
            '\n'
            'final now = DateTime.now();\n'
            '\n'
            '// Date formatting\n'
            'DateFormat.yMMMMd(\'en\').format(now) // "August 24, 2026"\n'
            'DateFormat.yMMMMd(\'id\').format(now) // "24 Agustus 2026"\n'
            'DateFormat(\'dd/MM/yyyy\').format(now) // "24/08/2026"\n'
            '\n'
            '// Number formatting\n'
            'NumberFormat.currency(locale: \'id\', symbol: \'Rp\').format(1500000)\n'
            '// → "Rp1.500.000,00"\n'
            '\n'
            'NumberFormat.decimalPattern(\'en\').format(1500000)\n'
            '// → "1,500,000"\n'
            '\n'
            '// Percent\n'
            'NumberFormat.percentPattern(\'en\').format(0.85) // "85%"',
          ),

          const SizedBox(height: 20),

          // ── 7. RTL support ────────────────────────────────────────────────
          _header('7. RTL (Right-to-Left) Languages', Colors.red),
          Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Arabic, Hebrew, Persian are RTL. Flutter handles most layout '
                    'automatically when the locale is RTL — Row becomes reversed, '
                    'TextAlign.start becomes right-aligned.',
                    style: TextStyle(fontSize: 13),
                  ),
                  SizedBox(height: 8),
                  Text('Rules for RTL-safe code:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('• Use start/end instead of left/right in EdgeInsets'),
                  Text('• Use TextAlign.start/end instead of left/right'),
                  Text('• Use Directionality.of(context) to check current direction'),
                  Text('• Test in an Arabic locale: MaterialApp(locale: Locale("ar"))'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _codeSnippet(
            '// ✅ RTL-safe padding\n'
            'EdgeInsetsDirectional.only(start: 16, end: 8)\n'
            '\n'
            '// ❌ Not RTL-safe\n'
            'EdgeInsets.only(left: 16, right: 8)  // left/right are fixed!\n'
            '\n'
            '// Check direction at runtime\n'
            'final isRtl = Directionality.of(context) == TextDirection.rtl;',
          ),

          const SizedBox(height: 24),
          Card(
            color: Colors.deepOrange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Key Takeaways',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('• ARB files = source of truth for all user-facing strings'),
                  Text('• flutter gen-l10n generates type-safe AppLocalizations'),
                  Text('• Register delegates + supportedLocales in MaterialApp'),
                  Text('• Use intl package for dates, numbers, and plurals'),
                  Text('• Use EdgeInsetsDirectional for RTL-safe padding'),
                  Text('• Store locale preference in SharedPreferences'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _demoRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 90,
              child: Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13)),
            ),
            Expanded(
              child: Text(value, style: const TextStyle(fontSize: 13)),
            ),
          ],
        ),
      );

  Widget _header(String title, Color color) => Padding(
        padding: const EdgeInsets.only(bottom: 4, top: 4),
        child: Text(title,
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: color)),
      );

  Widget _codeSnippet(String code) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2E),
          borderRadius: BorderRadius.circular(6),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(code,
              style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: Color(0xFFCDD6F4))),
        ),
      );
}

// ── Inline string table (replaces generated AppLocalizations for this demo) ─────

/// Simulates a generated AppLocalizations class.
///
/// In a real project this would be auto-generated by `flutter gen-l10n`.
/// Here we define strings inline to keep the demo self-contained.
class _AppStrings {
  final String appTitle;
  final String Function(String name) greeting;
  final String Function(int count) itemCount;
  final String textDirection;

  const _AppStrings({
    required this.appTitle,
    required this.greeting,
    required this.itemCount,
    required this.textDirection,
  });

  // ── Locale table ───────────────────────────────────────────────────────

  static final _table = <Locale, _AppStrings>{
    const Locale('en'): _AppStrings(
      appTitle: 'My App',
      greeting: (name) => 'Hello, $name!',
      itemCount: (n) => n == 0
          ? 'No items'
          : n == 1
              ? '1 item'
              : '$n items',
      textDirection: 'Left-to-Right (LTR)',
    ),
    const Locale('id'): _AppStrings(
      appTitle: 'Aplikasi Saya',
      greeting: (name) => 'Halo, $name!',
      itemCount: (n) => n == 0
          ? 'Tidak ada item'
          : n == 1
              ? '1 item'
              : '$n item',
      textDirection: 'Kiri-ke-Kanan (LTR)',
    ),
    const Locale('ja'): _AppStrings(
      appTitle: '私のアプリ',
      greeting: (name) => 'こんにちは、$name！',
      itemCount: (n) => n == 0 ? 'アイテムなし' : '$n 個のアイテム',
      textDirection: '左から右 (LTR)',
    ),
    const Locale('ar'): _AppStrings(
      appTitle: 'تطبيقي',
      greeting: (name) => 'مرحباً، $name!',
      itemCount: (n) => n == 0
          ? 'لا توجد عناصر'
          : n == 1
              ? 'عنصر واحد'
              : '$n عناصر',
      textDirection: 'من اليمين إلى اليسار (RTL)',
    ),
  };

  static _AppStrings of(Locale locale) =>
      _table[locale] ?? _table[const Locale('en')]!;

  static List<Locale> get supportedLocales => _table.keys.toList();

  static String localeName(Locale locale) {
    switch (locale.languageCode) {
      case 'en': return '🇬🇧 English';
      case 'id': return '🇮🇩 Indonesian';
      case 'ja': return '🇯🇵 Japanese';
      case 'ar': return '🇸🇦 Arabic (RTL)';
      default:   return locale.languageCode;
    }
  }
}
