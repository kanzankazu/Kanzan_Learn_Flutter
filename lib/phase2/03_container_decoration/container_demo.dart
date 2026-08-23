/// # Phase 2 — Topik 3: Container & BoxDecoration
///
/// [Container] adalah widget serbaguna yang bisa:
/// - Mengatur ukuran (width, height)
/// - Menambah padding & margin
/// - Memberi warna latar belakang
/// - Membuat border, shadow, border radius
/// - Mengubah bentuk (rounded, circle, dll)
///
/// [BoxDecoration] adalah class yang mendekorasi Container, bisa dipakai untuk:
/// - Warna solid atau gradient
/// - Border dan border radius
/// - Box shadow
/// - Background image
///
/// **Perbedaan padding vs margin:**
/// - padding: spasi di DALAM container (antara border dan konten)
/// - margin: spasi di LUAR container (antara container dan elemen lain)
///
/// Jalankan: `flutter run -t lib/phase2/03_container_decoration/container_demo.dart`

import 'package:flutter/material.dart';

void main() => runApp(const ContainerDemoApp());

class ContainerDemoApp extends StatelessWidget {
  const ContainerDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Container & BoxDecoration',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
      home: const ContainerDemoScreen(),
    );
  }
}

class ContainerDemoScreen extends StatelessWidget {
  const ContainerDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Container & BoxDecoration'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('1. Container Dasar'),
            _BasicContainerDemo(),
            const SizedBox(height: 24),

            _SectionTitle('2. Padding vs Margin'),
            _PaddingMarginDemo(),
            const SizedBox(height: 24),

            _SectionTitle('3. BoxDecoration — Warna & Border'),
            _BorderDemo(),
            const SizedBox(height: 24),

            _SectionTitle('4. BoxDecoration — Border Radius'),
            _BorderRadiusDemo(),
            const SizedBox(height: 24),

            _SectionTitle('5. BoxDecoration — Shadow'),
            _ShadowDemo(),
            const SizedBox(height: 24),

            _SectionTitle('6. BoxDecoration — Gradient'),
            _GradientDemo(),
            const SizedBox(height: 24),

            _SectionTitle('7. Contoh Nyata: Card Profil Custom'),
            _CustomProfileCard(),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// DEMOS
// ===========================================================================

/// Container paling dasar dengan ukuran dan warna.
class _BasicContainerDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Container dengan warna saja
        Container(
          width: 80,
          height: 80,
          color: Colors.blue.shade200,
          child: const Center(child: Text('color')),
        ),
        const SizedBox(width: 8),
        // Container tanpa ukuran — mengikuti ukuran child
        Container(
          color: Colors.green.shade200,
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Text('wrap child'),
          ),
        ),
        const SizedBox(width: 8),
        // Container double.infinity — lebar penuh
        Expanded(
          child: Container(
            height: 80,
            color: Colors.orange.shade200,
            child: const Center(child: Text('full width')),
          ),
        ),
      ],
    );
  }
}

/// Perbedaan padding (dalam) vs margin (luar).
class _PaddingMarginDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            const Text('padding: 16', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Container(
              color: Colors.yellow.shade100,
              // padding: spasi di dalam border
              padding: const EdgeInsets.all(16),
              child: Container(width: 40, height: 40, color: Colors.orange),
            ),
          ],
        ),
        Column(
          children: [
            const Text('margin: 16', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Container(
              color: Colors.yellow.shade100,
              child: Container(
                width: 40,
                height: 40,
                // margin: spasi di luar border
                margin: const EdgeInsets.all(16),
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// BoxDecoration dengan berbagai style border.
class _BorderDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Warna solid
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: Colors.indigo.shade100,
            // BoxDecoration TIDAK bisa pakai `color` di Container sekaligus
            // karena akan conflict — pakai decoration.color saja
          ),
          child: const Center(child: Text('solid')),
        ),
        // Border tipis
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.indigo, width: 2),
          ),
          child: const Center(child: Text('border')),
        ),
        // Border beda tiap sisi
        Container(
          width: 80, height: 80,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.red, width: 4),
              bottom: BorderSide(color: Colors.blue, width: 4),
              left: BorderSide(color: Colors.green, width: 2),
              right: BorderSide(color: Colors.orange, width: 2),
            ),
          ),
          child: const Center(child: Text('multi\nborder', textAlign: TextAlign.center)),
        ),
      ],
    );
  }
}

/// BoxDecoration dengan berbagai border radius.
class _BorderRadiusDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _DecoratedBox(
          label: 'radius: 8',
          decoration: BoxDecoration(
            color: Colors.teal.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        _DecoratedBox(
          label: 'radius: 24',
          decoration: BoxDecoration(
            color: Colors.teal.shade300,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        _DecoratedBox(
          label: 'pill',
          decoration: BoxDecoration(
            color: Colors.teal.shade400,
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        // Circle: pakai BoxShape.circle (bukan borderRadius)
        _DecoratedBox(
          label: 'circle',
          decoration: BoxDecoration(
            color: Colors.teal.shade200,
            shape: BoxShape.circle, // ← ini yang bikin lingkaran sempurna
          ),
        ),
        // Custom radius per sudut
        _DecoratedBox(
          label: 'custom\ncorner',
          decoration: BoxDecoration(
            color: Colors.teal.shade100,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
        ),
      ],
    );
  }
}

/// BoxDecoration dengan shadow.
class _ShadowDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _DecoratedBox(
          label: 'no shadow',
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        _DecoratedBox(
          label: 'soft shadow',
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4), // geser: x=0, y=4 (ke bawah)
              ),
            ],
          ),
        ),
        _DecoratedBox(
          label: 'hard shadow',
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 2,
                offset: Offset(4, 4), // geser kanan-bawah
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// BoxDecoration dengan gradient.
class _GradientDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Linear gradient — dari kiri ke kanan
        Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: const LinearGradient(
              colors: [Colors.blue, Colors.purple],
              // begin & end menentukan arah gradient
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: const Center(
            child: Text('Linear Gradient', style: TextStyle(color: Colors.white)),
          ),
        ),
        const SizedBox(height: 8),
        // Radial gradient — dari tengah ke luar
        Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: const RadialGradient(
              colors: [Colors.yellow, Colors.orange, Colors.red],
              radius: 1.5, // radius gradient
            ),
          ),
          child: const Center(
            child: Text('Radial Gradient', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}

/// Contoh nyata: card profil dibuat dari Container + BoxDecoration.
class _CustomProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade400, Colors.indigo.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar dengan border putih
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.3),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Center(
              child: Text('FB', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Faisal Bahri', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text('Android Developer', style: TextStyle(color: Colors.white70)),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.white60, size: 14),
                  Text(' Jakarta, ID', style: TextStyle(color: Colors.white60, fontSize: 12)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// HELPER WIDGETS
// ===========================================================================

class _DecoratedBox extends StatelessWidget {
  final String label;
  final BoxDecoration decoration;

  const _DecoratedBox({required this.label, required this.decoration});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: decoration,
      child: Center(
        child: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
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
