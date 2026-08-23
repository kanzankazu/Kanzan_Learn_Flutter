/// # Phase 2 — Topik 10: Responsive Layout
///
/// Responsive layout = UI yang menyesuaikan diri dengan ukuran layar.
///
/// **Dua tool utama:**
/// - [MediaQuery]: informasi tentang layar (ukuran, orientation, padding)
/// - [LayoutBuilder]: rebuild widget saat ukuran parent berubah
///
/// **Breakpoint umum Flutter:**
/// - Mobile: < 600px
/// - Tablet: 600px – 1200px
/// - Desktop: > 1200px
///
/// **Teknik responsive:**
/// 1. [MediaQuery.of(context).size.width]: cek lebar layar
/// 2. [LayoutBuilder]: lebih akurat karena berbasis ukuran parent widget
/// 3. [Expanded] / [Flexible]: proporsional di Column/Row
/// 4. [Wrap]: otomatis pindah baris saat tidak muat
///
/// Jalankan: `flutter run -t lib/phase2/10_responsive_layout/responsive_demo.dart`

import 'package:flutter/material.dart';

void main() => runApp(const ResponsiveDemoApp());

class ResponsiveDemoApp extends StatelessWidget {
  const ResponsiveDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Responsive Layout',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.amber, useMaterial3: true),
      home: const ResponsiveDemoScreen(),
    );
  }
}

class ResponsiveDemoScreen extends StatelessWidget {
  const ResponsiveDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // MediaQuery — akses info layar dari sini
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final orientation = mediaQuery.orientation;
    // viewInsets: space yang di-"inset" oleh keyboard, notch, dll
    final bottomPadding = mediaQuery.viewInsets.bottom;
    // padding: safe area (notch, home bar)
    final safePadding = mediaQuery.padding;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Responsive Layout'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info layar dari MediaQuery
            _SectionTitle('1. Info dari MediaQuery'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow('Lebar layar', '${screenWidth.toStringAsFixed(0)}px'),
                    _InfoRow('Tinggi layar', '${screenHeight.toStringAsFixed(0)}px'),
                    _InfoRow('Orientasi', orientation == Orientation.portrait ? 'Portrait' : 'Landscape'),
                    _InfoRow('Keyboard bottom', '${bottomPadding.toStringAsFixed(0)}px'),
                    _InfoRow('Safe area top', '${safePadding.top.toStringAsFixed(0)}px'),
                    _InfoRow(
                      'Device type',
                      screenWidth < 600 ? '📱 Mobile' : screenWidth < 1200 ? '📟 Tablet' : '🖥️ Desktop',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Responsive grid menggunakan LayoutBuilder
            _SectionTitle('2. Responsive Grid dengan LayoutBuilder'),
            _ResponsiveGrid(),
            const SizedBox(height: 24),

            // Layout berbeda berdasarkan orientasi
            _SectionTitle('3. Layout Berbeda saat Landscape'),
            _OrientationAwareLayout(),
            const SizedBox(height: 24),

            // Wrap — otomatis pindah baris
            _SectionTitle('4. Wrap (auto wrapping)'),
            _WrapDemo(),
            const SizedBox(height: 24),

            // Padding responsif
            _SectionTitle('5. Padding Responsif'),
            _ResponsivePadding(),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// RESPONSIVE GRID
// ===========================================================================

/// Grid yang otomatis ubah jumlah kolom berdasarkan lebar layar.
class _ResponsiveGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      // builder dipanggil setiap kali ukuran parent berubah
      builder: (context, constraints) {
        // constraints.maxWidth = lebar yang tersedia untuk widget ini
        final width = constraints.maxWidth;

        // Tentukan jumlah kolom berdasarkan lebar
        final columns = width < 400 ? 2 : width < 700 ? 3 : 4;

        return GridView.builder(
          shrinkWrap: true, // penting saat di dalam SingleChildScrollView
          physics: const NeverScrollableScrollPhysics(), // scroll di-handle parent
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: 8,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2 + index * 0.07),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.grid_view),
                    Text('$columns kolom', style: const TextStyle(fontSize: 10)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ===========================================================================
// ORIENTATION AWARE LAYOUT
// ===========================================================================

class _OrientationAwareLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // OrientationBuilder — shortcut untuk cek orientasi dari ukuran
    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: isLandscape
                // Landscape: tampilkan side-by-side
                ? Row(
                    children: [
                      Expanded(child: _OrientationBox('Kiri', Colors.blue)),
                      const SizedBox(width: 8),
                      Expanded(child: _OrientationBox('Kanan', Colors.orange)),
                    ],
                  )
                // Portrait: tampilkan stacked
                : Column(
                    children: [
                      _OrientationBox('Atas (Portrait)', Colors.blue),
                      const SizedBox(height: 8),
                      _OrientationBox('Bawah (Portrait)', Colors.orange),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _OrientationBox extends StatelessWidget {
  final String label;
  final Color color;
  const _OrientationBox(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(child: Text(label)),
    );
  }
}

// ===========================================================================
// WRAP DEMO
// ===========================================================================

class _WrapDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tag-tag di bawah otomatis pindah baris saat tidak muat:', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            // Wrap: seperti Row tapi auto-wrap saat overflow
            Wrap(
              spacing: 8,  // jarak horizontal antar item
              runSpacing: 8, // jarak vertikal antar baris
              children: [
                'Flutter', 'Dart', 'Android', 'iOS', 'Firebase',
                'Riverpod', 'GoRouter', 'Dio', 'Hive', 'Clean Architecture',
              ].map((tag) => Chip(label: Text(tag))).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// RESPONSIVE PADDING
// ===========================================================================

/// Helper function untuk menghitung padding berdasarkan lebar layar.
EdgeInsets responsivePadding(double screenWidth) {
  if (screenWidth < 400) return const EdgeInsets.all(12);
  if (screenWidth < 700) return const EdgeInsets.all(16);
  return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
}

class _ResponsivePadding extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final padding = responsivePadding(width);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Padding berubah sesuai lebar layar:', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: padding, // padding responsif
              color: Colors.amber.shade100,
              child: Text(
                'Konten dengan padding responsif\n'
                'Lebar: ${width.toStringAsFixed(0)}px\n'
                'Padding: ${padding.left.toStringAsFixed(0)}px',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// HELPER WIDGETS
// ===========================================================================

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}

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
