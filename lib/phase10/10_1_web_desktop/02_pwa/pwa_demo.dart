/// Phase 10.1 — Topic 02: Progressive Web App (PWA)
///
/// A PWA is a web app that can be installed on the user's device like a
/// native app — with an icon on the home screen, offline support, and
/// full-screen mode without the browser chrome.
///
/// Flutter Web supports PWA out of the box. The generated project includes:
/// - web/manifest.json     → app name, icon, colors for the install prompt
/// - web/index.html        → registers the service worker
/// - web/flutter_service_worker.js → generated at build time by Flutter
///
/// Key concepts covered:
/// 1. manifest.json — what every field means
/// 2. Service Worker — what it does, how Flutter generates it
/// 3. Install prompt — how to detect and trigger the "Add to Home Screen" prompt
/// 4. Offline support — cache strategies: cache-first vs network-first
/// 5. App icons — required sizes for all platforms
/// 6. Lighthouse audit — how to measure PWA score
/// 7. Push notifications via service worker (architecture overview)
import 'package:flutter/material.dart';

void main() => runApp(const _StandaloneApp());

class _StandaloneApp extends StatelessWidget {
  const _StandaloneApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PWA Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const PwaDemo(),
    );
  }
}

/// Demo screen explaining PWA concepts for Flutter Web.
class PwaDemo extends StatelessWidget {
  const PwaDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('02 — Progressive Web App'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SelectionArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _card(
              color: Colors.indigo.shade50,
              child: const Text(
                'A PWA lets users install your Flutter Web app on any device — '
                'Android, iOS, Windows, macOS, Chrome OS — from the browser. '
                'No app store required. Works offline. Looks and feels native.',
                style: TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),

            // ── 1. manifest.json ────────────────────────────────────────
            _header('1. manifest.json', Colors.indigo),
            const Text(
              'The manifest tells browsers how to present your app when installed.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            _code('''{
  "name": "Flutter Finance Manager",     // full name (shown in app drawer)
  "short_name": "Finance",               // short name (shown under icon)
  "start_url": ".",                      // URL to open on launch
  "display": "standalone",              // hides browser UI (standalone = native feel)
  "background_color": "#1B8A5A",        // splash screen color
  "theme_color": "#1B8A5A",             // toolbar/status bar color on Android
  "description": "Track your finances",
  "orientation": "portrait-primary",   // lock orientation (or "any")
  "icons": [
    { "src": "icons/Icon-192.png", "sizes": "192x192", "type": "image/png" },
    { "src": "icons/Icon-512.png", "sizes": "512x512", "type": "image/png" },
    // Maskable icon (safe zone for adaptive icons on Android)
    { "src": "icons/Icon-maskable-192.png", "sizes": "192x192",
      "type": "image/png", "purpose": "maskable" },
    { "src": "icons/Icon-maskable-512.png", "sizes": "512x512",
      "type": "image/png", "purpose": "maskable" }
  ],
  "screenshots": [
    // Optional: shown in Chrome's install dialog
    { "src": "screenshots/home.png", "sizes": "1280x720", "type": "image/png",
      "form_factor": "wide" }
  ]
}

// display options:
// "standalone" → no browser UI (recommended for apps)
// "minimal-ui" → minimal browser controls
// "fullscreen" → completely full screen (games)
// "browser"    → normal browser tab (no install benefit)'''),

            const SizedBox(height: 20),

            // ── 2. Service Worker ────────────────────────────────────────
            _header('2. Service Worker — Offline First', Colors.teal),
            _card(
              color: Colors.teal.shade50,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('What a service worker does:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text(
                    '• Intercepts every network request from the app\n'
                    '• Can serve cached responses when offline\n'
                    '• Can pre-cache app assets at install time\n'
                    '• Runs in a separate background thread (not the UI thread)\n'
                    '• Flutter generates flutter_service_worker.js automatically',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            _code(r'''
// Flutter builds flutter_service_worker.js automatically.
// It uses a "cache first, then network" strategy by default.
//
// Cache strategies:
//
// CACHE FIRST (Flutter default):
//   1. Check cache → if found, return immediately
//   2. Fetch from network → update cache
//   → Best for: static assets, app shell (JS, CSS, fonts)
//
// NETWORK FIRST:
//   1. Try network → if success, cache and return
//   2. On failure, fallback to cache
//   → Best for: API data, dynamic content
//
// STALE WHILE REVALIDATE:
//   1. Return cached version immediately (fast!)
//   2. Fetch fresh version in background → update cache for next visit
//   → Best for: content that updates but doesn't need to be real-time

// Flutter's generated service worker handles ALL Flutter Web assets.
// For custom API caching, add a custom service worker:

// web/custom_service_worker.js
self.addEventListener('fetch', (event) => {
  // Only cache GET requests to our API
  if (event.request.method === 'GET' &&
      event.request.url.includes('/api/')) {
    event.respondWith(
      caches.open('api-cache-v1').then((cache) =>
        fetch(event.request)
          .then((response) => {
            cache.put(event.request, response.clone());
            return response;
          })
          .catch(() => cache.match(event.request))
      )
    );
  }
});'''),

            const SizedBox(height: 20),

            // ── 3. Install prompt ────────────────────────────────────────
            _header('3. Install Prompt Detection', Colors.orange),
            _code(r'''
// Dart/Flutter cannot directly trigger the install prompt.
// Use js interop to listen for the browser's beforeinstallprompt event.

// web/index.html — capture the prompt event before Flutter loads
<script>
  let _installPrompt;
  window.addEventListener('beforeinstallprompt', (e) => {
    e.preventDefault();                    // prevent auto-prompt
    _installPrompt = e;                    // save for later
    // Notify Flutter that install is available
    window.dispatchEvent(new CustomEvent('installAvailable'));
  });

  // Expose a function Flutter can call to trigger the prompt
  window.triggerInstallPrompt = () => {
    if (_installPrompt) {
      _installPrompt.prompt();
      _installPrompt.userChoice.then((result) => {
        console.log('User choice:', result.outcome); // 'accepted' or 'dismissed'
        _installPrompt = null;
      });
    }
  };
</script>

// In Flutter — call the JS function:
import 'package:web/web.dart' as web;
// or: import 'dart:js_interop';

@JS('triggerInstallPrompt')
external void triggerInstallPrompt();

// Show an install banner when available:
ElevatedButton(
  onPressed: () => triggerInstallPrompt(),
  child: const Text('Install App'),
)'''),

            const SizedBox(height: 20),

            // ── 4. App icon requirements ─────────────────────────────────
            _header('4. App Icon Requirements', Colors.green),
            _card(
              color: Colors.green.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Required icon sizes:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  _iconRow('192x192', 'Standard icon — used on home screen (Android)'),
                  _iconRow('512x512', 'High-res icon — used in app store listing, splash'),
                  _iconRow('maskable 192x192',
                      'Adaptive icon (Android 8+) — keep content in 80% center "safe zone"'),
                  _iconRow('maskable 512x512', 'Maskable hi-res version'),
                  _iconRow('apple-touch-icon 180x180',
                      'iOS home screen icon — add to web/index.html'),
                  const SizedBox(height: 8),
                  const Text(
                    'Use flutter_launcher_icons package to generate all sizes automatically:',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            _code('''
# pubspec.yaml
dev_dependencies:
  flutter_launcher_icons: ^0.14.1

flutter_icons:
  android: true
  ios: true
  web:
    generate: true
    image_path: "assets/icon/icon.png"
    background_color_hex: "#1B8A5A"   # for maskable icons
    theme_color_hex: "#1B8A5A"
  windows:
    generate: true
    image_path: "assets/icon/icon.png"

# Run:
dart run flutter_launcher_icons'''),

            const SizedBox(height: 20),

            // ── 5. Lighthouse audit ───────────────────────────────────────
            _header('5. Lighthouse PWA Audit', Colors.purple),
            _card(
              color: Colors.purple.shade50,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('How to get a 100 PWA score:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text(
                    '1. Open Chrome DevTools → Lighthouse tab\n'
                    '2. Select "Progressive Web App" category\n'
                    '3. Click "Generate report"\n\n'
                    'Checklist for 100:\n'
                    '• HTTPS (required — use Firebase Hosting or Netlify)\n'
                    '• manifest.json with all required fields\n'
                    '• Service worker registered\n'
                    '• Icons: 192px AND 512px\n'
                    '• start_url responds with 200 (even offline)\n'
                    '• viewport meta tag in index.html\n'
                    '• Splash screen fields in manifest',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── 6. Build and deploy ───────────────────────────────────────
            _header('6. Build & Deploy', Colors.red),
            _code(r'''
# Build Flutter Web for production
flutter build web --release

# Output: build/web/
# ├── index.html
# ├── main.dart.js          ← your compiled Dart code
# ├── flutter_service_worker.js
# ├── manifest.json
# ├── icons/
# └── flutter.js

# Deploy to Firebase Hosting (free, HTTPS, CDN):
firebase init hosting
# → set public directory to "build/web"
# → configure as SPA: yes
flutter build web --release && firebase deploy

# Deploy to Netlify:
# 1. Connect GitHub repo
# 2. Build command: flutter build web --release
# 3. Publish directory: build/web

# Verify PWA installability:
# Open Chrome → DevTools → Application tab → Manifest
# Look for "Add to Home Screen" prompt in the browser'''),

            const SizedBox(height: 16),
            _card(
              color: Colors.indigo.shade50,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Key Takeaways',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('• manifest.json: name, short_name, display=standalone, icons (192 + 512)'),
                  Text('• Flutter auto-generates the service worker — handles offline for the app shell'),
                  Text('• Use beforeinstallprompt JS event to show a custom install button'),
                  Text('• Maskable icons prevent white borders on Android adaptive icons'),
                  Text('• flutter build web --release → build/web/ → deploy to Firebase/Netlify'),
                  Text('• Run Lighthouse audit to verify PWA compliance before launch'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconRow(String size, String description) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 130,
              child: Text(size,
                  style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: Text(description,
                  style: const TextStyle(fontSize: 11)),
            ),
          ],
        ),
      );
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
