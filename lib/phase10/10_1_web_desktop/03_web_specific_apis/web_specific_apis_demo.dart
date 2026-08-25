/// Phase 10.1 — Topic 03: Web-Specific APIs
///
/// Flutter Web gives you access to browser APIs that don't exist on mobile.
/// This topic covers the most important ones for real-world web apps.
///
/// Key concepts covered:
/// 1. URL strategy — hash (#) vs path-based URLs for deep linking
/// 2. URL parameters — read query params from the current URL
/// 3. Clipboard API — copy/paste rich content
/// 4. window / document JS interop — call any browser API from Dart
/// 5. HtmlElementView — embed native HTML elements inside Flutter
/// 6. Download file — trigger a browser file download from Dart
/// 7. Open URL in new tab — web equivalent of url_launcher
/// 8. LocalStorage — simple key-value persistence in the browser
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;

void main() => runApp(const _StandaloneApp());

class _StandaloneApp extends StatelessWidget {
  const _StandaloneApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Web APIs Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const WebSpecificApisDemo(),
    );
  }
}

/// Demo screen explaining web-specific APIs.
class WebSpecificApisDemo extends StatefulWidget {
  const WebSpecificApisDemo({super.key});

  @override
  State<WebSpecificApisDemo> createState() => _WebSpecificApisDemoState();
}

class _WebSpecificApisDemoState extends State<WebSpecificApisDemo> {
  // Clipboard demo
  final _copyController = TextEditingController(text: 'Hello from Flutter Web!');
  bool _copied = false;

  @override
  void dispose() {
    _copyController.dispose();
    super.dispose();
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: _copyController.text));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('03 — Web-Specific APIs'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SelectionArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── 1. URL strategy ─────────────────────────────────────────
            _header('1. URL Strategy — Hash vs Path', Colors.teal),
            _card(
              color: Colors.teal.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Hash URLs (default):', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('  myapp.com/#/home\n  myapp.com/#/profile/123',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 11)),
                  SizedBox(height: 8),
                  Text('Path URLs (recommended for production):',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('  myapp.com/home\n  myapp.com/profile/123',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 11)),
                  SizedBox(height: 8),
                  Text(
                    'Path URLs look more professional and work better with SEO. '
                    'They require server-side config: all requests must return '
                    'index.html so Flutter can handle routing client-side.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            _code('''
// main.dart — enable path URLs (removes the # from the URL)
import 'package:flutter_web_plugins/url_strategy.dart';

void main() {
  // Call BEFORE runApp
  usePathUrlStrategy();  // myapp.com/home instead of myapp.com/#/home
  runApp(const MyApp());
}

// Firebase Hosting config (firebase.json) — serve index.html for all routes:
{
  "hosting": {
    "rewrites": [
      { "source": "**", "destination": "/index.html" }
    ]
  }
}

// Netlify (_redirects file in build/web/):
// /*  /index.html  200'''),

            const SizedBox(height: 20),

            // ── 2. URL parameters ────────────────────────────────────────
            _header('2. URL Query Parameters', Colors.blue),
            _code('''
// Read query params from the current URL
// e.g. myapp.com/search?q=flutter&page=2

import 'package:flutter/foundation.dart' show kIsWeb;

// With GoRouter (recommended):
GoRoute(
  path: '/search',
  builder: (context, state) {
    final query = state.uri.queryParameters['q'] ?? '';
    final page  = int.tryParse(state.uri.queryParameters['page'] ?? '1') ?? 1;
    return SearchScreen(query: query, page: page);
  },
),

// Navigate with query params:
context.go('/search?q=flutter&page=2');

// Or with go_router named routes:
context.goNamed('search', queryParameters: {
  'q': 'flutter',
  'page': '2',
});

// Read the raw URI directly (without GoRouter):
import 'dart:html' as html;   // web only
final uri = Uri.parse(html.window.location.href);
final query = uri.queryParameters['q'];'''),

            const SizedBox(height: 20),

            // ── 3. Clipboard ──────────────────────────────────────────────
            _header('3. Clipboard API', Colors.orange),
            const Text(
              'Flutter\'s Clipboard API works cross-platform. '
              'On web it uses the browser Clipboard API.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            // Live demo
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _copyController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Text to copy',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _copied
                      ? const Chip(
                          key: ValueKey('copied'),
                          label: Text('Copied!'),
                          backgroundColor: Colors.green,
                          labelStyle: TextStyle(color: Colors.white),
                        )
                      : FilledButton.icon(
                          key: const ValueKey('copy'),
                          onPressed: _copyToClipboard,
                          icon: const Icon(Icons.copy, size: 16),
                          label: const Text('Copy'),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _code('''
// Copy to clipboard (works on all platforms including web)
import 'package:flutter/services.dart';

await Clipboard.setData(ClipboardData(text: "Hello!"));

// Paste from clipboard
final data = await Clipboard.getData(Clipboard.kTextPlain);
final text = data?.text ?? '';

// Check if clipboard has data
final hasData = await Clipboard.hasStrings();'''),

            const SizedBox(height: 20),

            // ── 4. Download file ──────────────────────────────────────────
            _header('4. Download File from Flutter Web', Colors.purple),
            _code(r'''
// Trigger a browser file download — web only
// Use package: web or dart:html

import 'dart:convert';
import 'package:web/web.dart' as web;

void downloadCsv(String csvContent, String filename) {
  // Encode content as a data URL
  final bytes = utf8.encode(csvContent);
  final blob = web.Blob(
    [bytes],
    web.BlobPropertyBag(type: 'text/csv'),
  );
  final url = web.URL.createObjectURL(blob);

  // Create a hidden <a> element and click it
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = url
    ..download = filename   // sets the download filename
    ..click();

  // Clean up the object URL after download starts
  web.URL.revokeObjectURL(url);
}

// Usage:
downloadCsv('Date,Amount,Category\n2026-08-24,45000,Food', 'transactions.csv');

// Guard for non-web platforms:
if (kIsWeb) {
  downloadCsv(content, 'export.csv');
} else {
  // Use file_picker or path_provider on mobile/desktop
}'''),

            const SizedBox(height: 20),

            // ── 5. Open URL in new tab ────────────────────────────────────
            _header('5. Open URL in New Tab', Colors.green),
            _code(r'''
// Web: open URL in a new browser tab
import 'package:web/web.dart' as web;

void openInNewTab(String url) {
  web.window.open(url, '_blank');
}

// Cross-platform (recommended):
// Use url_launcher package which handles web + mobile + desktop:
import 'package:url_launcher/url_launcher.dart';

Future<void> openUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(
      uri,
      // webOnlyWindowName: '_blank' → new tab on web
      // webOnlyWindowName: '_self'  → same tab on web
      mode: LaunchMode.externalApplication,
    );
  }
}'''),

            const SizedBox(height: 20),

            // ── 6. Dart JS interop ────────────────────────────────────────
            _header('6. Dart JS Interop (dart:js_interop)', Colors.red),
            _code(r'''
// Call any browser JS API from Dart using the modern js_interop package
// (replaces the old dart:js in Dart 3)
import 'dart:js_interop';

// Declare the JS function you want to call:
@JS('alert')
external void jsAlert(String message);

@JS('console.log')
external void jsLog(JSAny? value);

// Access window properties:
@JS('window.innerWidth')
external int get windowInnerWidth;

// Call custom JS functions defined in index.html:
// (index.html) window.myFunc = (msg) => console.log(msg);
@JS('myFunc')
external void myFunc(String msg);

// Usage:
jsAlert('Hello from Dart!');
jsLog('current width: $windowInnerWidth'.toJS);
myFunc('called from Flutter');

// Convert between Dart and JS types:
'hello'.toJS          // String → JSString
42.toJS               // int → JSNumber
true.toJS             // bool → JSBoolean
['a','b'].toJS        // List → JSArray (via .jsify())
jsString.toDart       // JSString → String'''),

            const SizedBox(height: 16),
            _card(
              color: Colors.teal.shade50,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Key Takeaways',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('• usePathUrlStrategy() removes # from URLs — do this in all web apps'),
                  Text('• GoRouter query params: state.uri.queryParameters["key"]'),
                  Text('• Clipboard.setData/getData works on all platforms including web'),
                  Text('• Download file: create Blob → createObjectURL → anchor.click()'),
                  Text('• JS interop: dart:js_interop with @JS annotation (Dart 3)'),
                  Text('• Guard web-only code with: if (kIsWeb) { ... }'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared helpers ─────────────────────────────────────────────────────────────

Widget _header(String title, Color color) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(title,
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold, color: color)),
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
                fontFamily: 'monospace',
                fontSize: 11,
                color: Color(0xFFCDD6F4))),
      ),
    );

Widget _card({required Color color, required Widget child}) => Card(
      color: color,
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    );
