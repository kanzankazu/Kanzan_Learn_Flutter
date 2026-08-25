/// Phase 10.1 — Topic 06: Flutter Web Performance
///
/// Flutter Web has unique performance considerations compared to mobile:
/// - JavaScript compilation (dart2js) adds startup overhead
/// - Two rendering backends: CanvasKit vs HTML (skwasm in Flutter 3.x)
/// - Bundle size matters for load time
/// - Web-specific profiling tools (Lighthouse, Chrome DevTools)
///
/// Key concepts covered:
/// 1. CanvasKit vs HTML renderer — when to use which
/// 2. Skwasm — the new WebAssembly renderer (Flutter 3.22+)
/// 3. Tree-shaking and deferred loading
/// 4. App startup optimization
/// 5. Web-specific profiling — Lighthouse, Chrome DevTools
/// 6. Image optimization for web
/// 7. Code splitting with deferred imports
/// 8. Build flags — --web-renderer, --dart-define, release vs profile mode
import 'package:flutter/material.dart';

void main() => runApp(const _StandaloneApp());

class _StandaloneApp extends StatelessWidget {
  const _StandaloneApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Web Performance Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const WebPerformanceDemo(),
    );
  }
}

/// Demo screen explaining Flutter Web performance optimization.
class WebPerformanceDemo extends StatelessWidget {
  const WebPerformanceDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('06 — Web Performance'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: SelectionArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── 1. Renderers ─────────────────────────────────────────────
            _header('1. Flutter Web Renderers', Colors.red.shade700),
            _rendererComparisonTable(),
            _code(r'''
# Build with specific renderer:
flutter build web --web-renderer canvaskit  # CanvasKit (default for release)
flutter build web --web-renderer html       # HTML (faster startup, smaller bundle)
flutter build web --web-renderer skwasm     # WebAssembly (Flutter 3.22+ default)

# Run in dev with renderer:
flutter run -d chrome --web-renderer html

# Auto (default): uses canvaskit on desktop, html on mobile
flutter build web --web-renderer auto

# Check current renderer at runtime:
import 'package:flutter/foundation.dart';
print(defaultTargetPlatform);  // TargetPlatform.macOS on Chrome

# Skwasm (recommended for 3.22+):
# - Multithreaded rendering via Web Workers
# - ~2x faster rendering than CanvasKit
# - Slightly larger initial download but faster runtime
# - Requires COOP/COEP headers from the server'''),

            const SizedBox(height: 20),

            // ── 2. Bundle size ────────────────────────────────────────────
            _header('2. Bundle Size & Tree Shaking', Colors.orange),
            _card(
              color: Colors.orange.shade50,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Typical bundle sizes:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text(
                    'HTML renderer:     ~1.5 MB  gzipped\n'
                    'CanvasKit renderer: ~2.5 MB  gzipped\n'
                    'Skwasm:            ~1.8 MB  gzipped\n\n'
                    'Flutter tree-shakes unused Dart code automatically.\n'
                    'Unused icons from the Material symbols font are the\n'
                    'biggest hidden cost — see section 3.',
                    style: TextStyle(fontFamily: 'monospace', fontSize: 11),
                  ),
                ],
              ),
            ),
            _code(r'''
# Analyze your bundle size:
flutter build web --release --analyze-size
# Opens a Dart DevTools treemap showing what's taking space

# Or: build with source maps and open in Chrome DevTools Coverage tab
flutter build web --release --source-maps

# Check gzipped size:
du -sh build/web/main.dart.js
gzip -k build/web/main.dart.js && du -sh build/web/main.dart.js.gz'''),

            const SizedBox(height: 20),

            // ── 3. Icon font optimization ─────────────────────────────────
            _header('3. Icon Font Optimization (Big Win)', Colors.teal),
            _code(r'''
// The Material Icons font is ~1.5MB uncompressed.
// Flutter tree-shakes it to only include icons you use.
// But you must tell it WHICH icons to keep.

// pubspec.yaml — list only the icons your app actually uses:
flutter:
  fonts:
    - family: MaterialIcons
      fonts:
        - asset: fonts/MaterialIcons-Regular.otf

// Even better: use a custom icon font with only your icons
// Tools: fluttericon.com, icomoon.io

// For Material Symbols (variable fonts), use the package:
dependencies:
  material_symbols_icons: ^4.2794.0

// This loads only the symbols you import — zero unused bytes.

// Avoid:
import 'package:flutter/material.dart';
Icon(Icons.home)           // imports the whole icon set

// Prefer (with material_symbols_icons):
import 'package:material_symbols_icons/symbols.dart';
Icon(Symbols.home)         // only "home" is included in the bundle'''),

            const SizedBox(height: 20),

            // ── 4. Deferred loading ───────────────────────────────────────
            _header('4. Deferred Loading (Code Splitting)', Colors.purple),
            _code(r'''
// Load heavy screens/libraries lazily — only when first navigated to.
// Reduces initial bundle size → faster first paint.

// 1. Mark the import as deferred
import 'package:myapp/screens/analytics_screen.dart' deferred as analytics;

// 2. Load before first use
Future<void> _openAnalytics() async {
  // Downloads and initializes the deferred library
  await analytics.loadLibrary();
  // Now safe to use
  if (mounted) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => analytics.AnalyticsScreen(),
    ));
  }
}

// 3. Show a loading indicator while loading
FutureBuilder(
  future: analytics.loadLibrary(),
  builder: (context, snapshot) {
    if (snapshot.connectionState != ConnectionState.done) {
      return const CircularProgressIndicator();
    }
    return analytics.AnalyticsScreen();
  },
)

// Good candidates for deferred loading:
// - Heavy admin screens rarely visited
// - Chart libraries (fl_chart, syncfusion)
// - PDF generation screens
// - Any screen that loads >500KB of additional code'''),

            const SizedBox(height: 20),

            // ── 5. Startup optimization ───────────────────────────────────
            _header('5. Startup Optimization', Colors.indigo),
            _code(r'''
// Flutter Web startup sequence:
// 1. Browser downloads index.html (instant)
// 2. Browser downloads flutter.js (~20KB)
// 3. flutter.js downloads main.dart.js (~2MB gzipped)
// 4. Flutter initializes (parses WASM/JS, sets up rendering)
// 5. Your main() runs → runApp()
// 6. First frame renders

// Optimizations:

// A. Custom loading screen (index.html)
// Show a native HTML splash while Flutter loads:
<!-- web/index.html -->
<div id="loading">
  <img src="icons/Icon-192.png" />
  <p>Loading...</p>
</div>
<script>
  window.addEventListener('flutter-first-frame', () => {
    document.getElementById('loading').remove();
  });
</script>

// B. Preload fonts
<!-- web/index.html -->
<link rel="preload" href="fonts/MaterialIcons-Regular.otf" as="font" crossorigin>

// C. Service worker pre-caches assets
// Flutter generates this automatically — all assets cached on first visit.
// Second visit: instant load from cache.

// D. Use --release mode (obvious but important)
// Debug mode is 5-10x slower than release on web.
flutter build web --release       // always for production
flutter run -d chrome --release   // test release performance locally'''),

            const SizedBox(height: 20),

            // ── 6. Profiling ──────────────────────────────────────────────
            _header('6. Profiling Web Performance', Colors.green),
            _code(r'''
# Lighthouse audit (in Chrome DevTools → Lighthouse):
# → Performance score
# → First Contentful Paint (FCP): target < 1.8s
# → Largest Contentful Paint (LCP): target < 2.5s
# → Total Blocking Time (TBT): target < 200ms
# → Cumulative Layout Shift (CLS): target < 0.1

# Flutter DevTools for web:
flutter run -d chrome --profile    # profile mode (closer to release)
# Open Chrome DevTools → Performance tab → record while interacting
# Look for:
# - Long tasks (> 50ms) that block the main thread
# - Excessive repaints (enable "Show paint flashing" in DevTools)
# - Memory leaks (Memory tab → take heap snapshot)

# Check actual rendered performance:
flutter run -d chrome --release --web-renderer canvaskit
# Open Flutter DevTools (printed in terminal): localhost:9100
# → Widget Rebuild Stats → which widgets rebuild too often
# → Rendering → frames above 16ms budget'''),

            const SizedBox(height: 20),

            // ── 7. Image optimization ─────────────────────────────────────
            _header('7. Image Optimization for Web', Colors.brown),
            _code(r'''
// Web images need different treatment than mobile:
// Use WebP format (smaller than PNG/JPEG, same quality)
// Use responsive images (serve the right size per screen density)

// CachedNetworkImage — works on web too:
CachedNetworkImage(
  imageUrl: 'https://cdn.example.com/photo.webp',
  placeholder: (_, __) => const CircularProgressIndicator(),
  errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
)

// For local assets — use WebP:
// flutter pub run flutter_native_splash:create  (auto-converts)
// Or: convert with cwebp CLI: cwebp input.png -o output.webp

// Serve responsive images via CDN URL params:
// Cloudinary: https://res.cloudinary.com/demo/image/upload/w_400/photo.jpg
// imgix:      https://demo.imgix.net/photo.jpg?w=400&auto=format

// Blur-up technique (show tiny placeholder while loading):
Image.network(
  highResUrl,
  frameBuilder: (context, child, frame, wasSync) {
    if (wasSync || frame != null) return child;
    return FadeInImage.memoryNetwork(
      placeholder: kTransparentImage,   // 1x1 transparent PNG
      image: highResUrl,
      fadeInDuration: const Duration(milliseconds: 300),
    );
  },
)'''),

            const SizedBox(height: 16),
            _card(
              color: Colors.red.shade50,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Key Takeaways',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('• Use skwasm renderer for Flutter 3.22+ (fastest, WebAssembly)'),
                  Text('• tree-shaking handles unused Dart code — icons are the main leak'),
                  Text('• Deferred imports split large features into separate chunks'),
                  Text('• Custom HTML loading screen hides Flutter\'s cold-start delay'),
                  Text('• flutter build web --release → always for production'),
                  Text('• Lighthouse audit: target FCP < 1.8s, LCP < 2.5s'),
                  Text('• Convert images to WebP — ~30% smaller than PNG at same quality'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rendererComparisonTable() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(1.5),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
            3: FlexColumnWidth(1),
          },
          border: TableBorder.all(color: Colors.grey.shade300),
          children: [
            _tableRow(['', 'HTML', 'CanvasKit', 'Skwasm'], header: true),
            _tableRow(['Bundle size', '~1.5MB', '~2.5MB', '~1.8MB']),
            _tableRow(['Startup', 'Fast', 'Slow', 'Medium']),
            _tableRow(['Rendering FPS', 'Medium', 'High', 'Highest']),
            _tableRow(['Text quality', 'Browser', 'Pixel-perfect', 'Pixel-perfect']),
            _tableRow(['Threading', 'Single', 'Single', 'Multi (Workers)']),
            _tableRow(['Best for', 'Content apps', 'Complex UI', 'All apps (3.22+)']),
          ],
        ),
      ),
    );
  }

  TableRow _tableRow(List<String> cells, {bool header = false}) {
    return TableRow(
      decoration: header
          ? BoxDecoration(color: Colors.red.shade50)
          : null,
      children: cells
          .map((c) => Padding(
                padding: const EdgeInsets.all(6),
                child: Text(c,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: header
                            ? FontWeight.bold
                            : FontWeight.normal)),
              ))
          .toList(),
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
