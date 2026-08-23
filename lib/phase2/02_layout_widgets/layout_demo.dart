/// # Phase 2 — Topik 2: Layout Widgets
///
/// Widget-widget untuk mengatur posisi & ukuran elemen di Flutter:
/// - [Column]: susun widget secara vertikal (atas → bawah)
/// - [Row]: susun widget secara horizontal (kiri → kanan)
/// - [Stack]: tumpuk widget di atas satu sama lain
/// - [Expanded]: isi sisa ruang yang tersedia di Column/Row
/// - [Flexible]: mirip Expanded tapi lebih fleksibel (bisa lebih kecil)
///
/// **Konsep penting:**
/// Column & Row punya dua sumbu:
/// - Main axis (sumbu utama): arah susunan (vertikal untuk Column, horizontal untuk Row)
/// - Cross axis (sumbu silang): arah tegak lurus dari main axis
///
/// Jalankan: `flutter run -t lib/phase2/02_layout_widgets/layout_demo.dart`

import 'package:flutter/material.dart';

void main() => runApp(const LayoutDemoApp());

class LayoutDemoApp extends StatelessWidget {
  const LayoutDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Layout Widgets Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const LayoutDemoScreen(),
    );
  }
}

class LayoutDemoScreen extends StatelessWidget {
  const LayoutDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Layout Widgets'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('1. Column — vertikal'),
            _ColumnDemo(),
            const SizedBox(height: 24),

            _SectionTitle('2. Row — horizontal'),
            _RowDemo(),
            const SizedBox(height: 24),

            _SectionTitle('3. Stack — tumpukan'),
            _StackDemo(),
            const SizedBox(height: 24),

            _SectionTitle('4. Expanded vs Flexible'),
            _ExpandedFlexibleDemo(),
            const SizedBox(height: 24),

            _SectionTitle('5. MainAxisAlignment & CrossAxisAlignment'),
            _AlignmentDemo(),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// COLUMN DEMO
// ===========================================================================

class _ColumnDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          // mainAxisAlignment: mengatur posisi di sumbu vertikal
          mainAxisAlignment: MainAxisAlignment.start,
          // crossAxisAlignment: mengatur posisi di sumbu horizontal
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ColorBox(color: Colors.red.shade200, label: 'Anak 1'),
            const SizedBox(height: 4), // spasi antar item
            _ColorBox(color: Colors.green.shade200, label: 'Anak 2'),
            const SizedBox(height: 4),
            _ColorBox(color: Colors.blue.shade200, label: 'Anak 3'),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// ROW DEMO
// ===========================================================================

class _RowDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          // mainAxisAlignment: mengatur posisi di sumbu horizontal
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          // crossAxisAlignment: mengatur posisi di sumbu vertikal
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _ColorBox(color: Colors.orange.shade200, label: 'Kiri'),
            _ColorBox(color: Colors.purple.shade200, label: 'Tengah', height: 60),
            _ColorBox(color: Colors.pink.shade200, label: 'Kanan'),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// STACK DEMO
// ===========================================================================

class _StackDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: 150,
          child: Stack(
            children: [
              // Layer paling bawah
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(child: Text('Layer bawah (full)')),
              ),
              // Layer tengah — di atas layer bawah
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  width: 80,
                  height: 80,
                  color: Colors.orange.shade300,
                  child: const Center(child: Text('Tengah', textAlign: TextAlign.center)),
                ),
              ),
              // Layer atas — pojok kanan bawah
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade400,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Top layer', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// EXPANDED & FLEXIBLE DEMO
// ===========================================================================

class _ExpandedFlexibleDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expanded: mengisi sisa ruang SEPENUHNYA
            const Text('Expanded (flex: 1, 2, 1):'),
            const SizedBox(height: 4),
            SizedBox(
              height: 40,
              child: Row(
                children: [
                  // flex menentukan proporsi — 1:2:1 artinya 25%:50%:25%
                  Expanded(
                    child: _ColorBox(color: Colors.red.shade200, label: '1'),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    flex: 2, // ambil 2x lebih besar dari flex:1
                    child: _ColorBox(color: Colors.green.shade200, label: '2'),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _ColorBox(color: Colors.blue.shade200, label: '1'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Flexible: hanya mengambil ruang yang dibutuhkan (tidak paksa penuh)
            const Text('Flexible (fit: loose — tidak paksa penuh):'),
            const SizedBox(height: 4),
            SizedBox(
              height: 40,
              child: Row(
                children: [
                  // Flexible dengan fit: FlexFit.loose tidak paksa child expand
                  Flexible(
                    child: _ColorBox(color: Colors.orange.shade200, label: 'Flex'),
                  ),
                  const SizedBox(width: 4),
                  // Widget biasa tanpa Expanded/Flexible — ambil ukuran natural
                  _ColorBox(color: Colors.purple.shade200, label: 'Fixed'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// ALIGNMENT DEMO
// ===========================================================================

class _AlignmentDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Contoh MainAxisAlignment yang berbeda-beda
    final alignments = [
      (MainAxisAlignment.start, 'start'),
      (MainAxisAlignment.center, 'center'),
      (MainAxisAlignment.end, 'end'),
      (MainAxisAlignment.spaceBetween, 'spaceBetween'),
      (MainAxisAlignment.spaceAround, 'spaceAround'),
      (MainAxisAlignment.spaceEvenly, 'spaceEvenly'),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: alignments.map((entry) {
            final (alignment, label) = entry;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  Container(
                    color: Colors.grey.shade100,
                    child: Row(
                      mainAxisAlignment: alignment,
                      children: const [
                        _Dot(Colors.red),
                        _Dot(Colors.green),
                        _Dot(Colors.blue),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ===========================================================================
// HELPER WIDGETS
// ===========================================================================

/// Kotak berwarna sederhana untuk visualisasi layout.
class _ColorBox extends StatelessWidget {
  final Color color;
  final String label;
  final double height;

  const _ColorBox({
    required this.color,
    required this.label,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: color,
      child: Center(
        child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

/// Titik kecil berwarna untuk visualisasi alignment.
class _Dot extends StatelessWidget {
  final Color color;
  const _Dot(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
