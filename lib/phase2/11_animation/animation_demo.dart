/// # Phase 2 — Topik 11: Animasi Dasar
///
/// Flutter punya 3 level animasi:
///
/// **1. Implisit (termudah)** — Flutter yang handle controller:
/// - [AnimatedContainer]: animasi properti Container (ukuran, warna, dll)
/// - [AnimatedOpacity]: fade in/out
/// - [AnimatedPadding]: animasi padding
/// - [AnimatedPositioned]: animasi posisi di Stack
/// - [AnimatedDefaultTextStyle]: animasi style teks
/// - [TweenAnimationBuilder]: animasi custom nilai
///
/// **2. Hero Animation** — transisi elemen antar screen:
/// - Widget dengan `Hero` tag yang sama akan dianimasikan saat navigasi
///
/// **3. Eksplisit (lebih kontrol)** — manual dengan AnimationController:
/// - Akan dibahas di Phase 6 (Advanced Flutter)
///
/// **Prinsip animasi:** Jangan animasi hanya demi animasi.
/// Animasi yang baik = memberikan konteks, feedback, dan delight.
///
/// Jalankan: `flutter run -t lib/phase2/11_animation/animation_demo.dart`

import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() => runApp(const AnimationDemoApp());

class AnimationDemoApp extends StatelessWidget {
  const AnimationDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animasi Dasar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
      home: const AnimationDemoScreen(),
    );
  }
}

class AnimationDemoScreen extends StatelessWidget {
  const AnimationDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animasi Dasar'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('1. AnimatedContainer'),
            const _AnimatedContainerDemo(),
            const SizedBox(height: 24),

            _SectionTitle('2. AnimatedOpacity'),
            const _AnimatedOpacityDemo(),
            const SizedBox(height: 24),

            _SectionTitle('3. AnimatedSwitcher — switch antar widget'),
            const _AnimatedSwitcherDemo(),
            const SizedBox(height: 24),

            _SectionTitle('4. TweenAnimationBuilder'),
            const _TweenDemo(),
            const SizedBox(height: 24),

            _SectionTitle('5. Hero Animation — tap untuk demo'),
            const _HeroDemo(),
            const SizedBox(height: 24),

            _SectionTitle('6. AnimatedList'),
            const _AnimatedListDemo(),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// 1. ANIMATEDCONTAINER
// ===========================================================================

/// AnimatedContainer — animasi properti Container saat berubah.
/// Cukup ubah nilai dan set `duration`, Flutter handle animasinya!
class _AnimatedContainerDemo extends StatefulWidget {
  const _AnimatedContainerDemo();

  @override
  State<_AnimatedContainerDemo> createState() => _AnimatedContainerDemoState();
}

class _AnimatedContainerDemoState extends State<_AnimatedContainerDemo> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // AnimatedContainer — semua properti yang diubah akan dianimasikan
            AnimatedContainer(
              duration: const Duration(milliseconds: 400), // durasi animasi
              curve: Curves.easeInOut, // kurva animasi (easing)
              width: _expanded ? double.infinity : 100,
              height: _expanded ? 100 : 50,
              decoration: BoxDecoration(
                color: _expanded ? Colors.deepPurple : Colors.deepPurple.shade200,
                borderRadius: BorderRadius.circular(_expanded ? 16 : 50),
              ),
              child: Center(
                child: Text(
                  _expanded ? 'Diperbesar' : 'Kecil',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => setState(() => _expanded = !_expanded),
              child: Text(_expanded ? 'Perkecil' : 'Perbesar'),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// 2. ANIMATEDOPACITY
// ===========================================================================

class _AnimatedOpacityDemo extends StatefulWidget {
  const _AnimatedOpacityDemo();

  @override
  State<_AnimatedOpacityDemo> createState() => _AnimatedOpacityDemoState();
}

class _AnimatedOpacityDemoState extends State<_AnimatedOpacityDemo> {
  bool _visible = true;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // AnimatedOpacity — fade in/out
            AnimatedOpacity(
              opacity: _visible ? 1.0 : 0.0, // 1.0 = terlihat, 0.0 = transparan
              duration: const Duration(milliseconds: 500),
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(child: Text('Widget ini di-fade', style: TextStyle(color: Colors.white))),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => setState(() => _visible = !_visible),
              child: Text(_visible ? 'Sembunyikan (fade out)' : 'Tampilkan (fade in)'),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// 3. ANIMATEDSWITCHER
// ===========================================================================

/// AnimatedSwitcher — animasi pergantian widget.
/// Ketika child berubah, widget lama fade out dan widget baru fade in.
class _AnimatedSwitcherDemo extends StatefulWidget {
  const _AnimatedSwitcherDemo();

  @override
  State<_AnimatedSwitcherDemo> createState() => _AnimatedSwitcherDemoState();
}

class _AnimatedSwitcherDemoState extends State<_AnimatedSwitcherDemo> {
  bool _showFirst = true;
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // AnimatedSwitcher — child berubah = animasi transisi
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              // transitionBuilder: custom animasi transisi (default: fade)
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _showFirst
                  // KEY penting! AnimatedSwitcher perlu key berbeda untuk detect perubahan
                  ? Container(
                      key: const ValueKey('first'),
                      height: 60,
                      width: double.infinity,
                      color: Colors.blue.shade200,
                      child: const Center(child: Text('Widget PERTAMA')),
                    )
                  : Container(
                      key: const ValueKey('second'),
                      height: 60,
                      width: double.infinity,
                      color: Colors.green.shade200,
                      child: const Center(child: Text('Widget KEDUA')),
                    ),
            ),
            const SizedBox(height: 8),
            // Counter dengan AnimatedSwitcher — efek number flip
            const Text('Counter dengan animasi:'),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
              child: Text(
                '$_counter',
                key: ValueKey(_counter), // key berubah setiap increment → trigger animasi
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => setState(() {
                    _showFirst = !_showFirst;
                    _counter++;
                  }),
                  child: const Text('Switch & Increment'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// 4. TWEENANIMATIONBUILDER
// ===========================================================================

class _TweenDemo extends StatefulWidget {
  const _TweenDemo();

  @override
  State<_TweenDemo> createState() => _TweenDemoState();
}

class _TweenDemoState extends State<_TweenDemo> {
  double _progress = 0.3;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // TweenAnimationBuilder — animasi nilai dari A ke B
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: _progress), // animasi dari 0 ke _progress
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                // builder dipanggil di setiap frame animasi dengan nilai saat ini
                return Column(
                  children: [
                    // Progress bar custom
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: value,
                        minHeight: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('${(value * 100).toStringAsFixed(0)}%'),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            // Slider untuk ubah target progress
            Slider(
              value: _progress,
              onChanged: (v) => setState(() => _progress = v),
              label: '${(_progress * 100).toStringAsFixed(0)}%',
              divisions: 10,
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// 5. HERO ANIMATION
// ===========================================================================

class _HeroDemo extends StatelessWidget {
  const _HeroDemo();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tap gambar di bawah untuk melihat Hero animation:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 8),
            // Hero widget — tag harus sama di screen asal dan tujuan
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _HeroDetailScreen())),
              child: Hero(
                tag: 'hero-box', // ← tag ini harus sama di screen tujuan
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.deepPurple, Colors.purple.shade200],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.flutter_dash, color: Colors.white, size: 40),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Screen detail untuk demo Hero animation.
class _HeroDetailScreen extends StatelessWidget {
  const _HeroDetailScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hero Detail'), backgroundColor: Colors.deepPurple.shade100),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hero widget dengan tag yang SAMA → Flutter animasikan transisi
            Hero(
              tag: 'hero-box', // tag sama dengan di screen asal
              child: Container(
                width: 200, height: 200, // ukuran lebih besar di screen detail
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple, Colors.purple.shade200],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Icon(Icons.flutter_dash, color: Colors.white, size: 100),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Hero animation!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Tekan back untuk lihat animasi kembali.'),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// 6. ANIMATEDLIST
// ===========================================================================

/// AnimatedList — ListView dengan animasi saat item ditambah/dihapus.
class _AnimatedListDemo extends StatefulWidget {
  const _AnimatedListDemo();

  @override
  State<_AnimatedListDemo> createState() => _AnimatedListDemoState();
}

class _AnimatedListDemoState extends State<_AnimatedListDemo> {
  final _listKey = GlobalKey<AnimatedListState>();
  final _items = <String>['Item 1', 'Item 2', 'Item 3'];
  int _nextId = 4;

  void _addItem() {
    final newItem = 'Item $_nextId';
    _items.add(newItem);
    // insertItem: tambah item dengan animasi
    _listKey.currentState?.insertItem(_items.length - 1, duration: const Duration(milliseconds: 300));
    _nextId++;
  }

  void _removeItem(int index) {
    final removedItem = _items[index];
    _items.removeAt(index);
    // removeItem: hapus item dengan animasi
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildItem(removedItem, animation),
      duration: const Duration(milliseconds: 300),
    );
  }

  Widget _buildItem(String item, Animation<double> animation) {
    return SlideTransition(
      position: animation.drive(
        Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeInOut)),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 2),
        child: ListTile(
          title: Text(item),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _removeItem(_items.indexOf(item)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: AnimatedList(
                key: _listKey,
                initialItemCount: _items.length,
                itemBuilder: (context, index, animation) =>
                    _buildItem(_items[index], animation),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _addItem,
              icon: const Icon(Icons.add),
              label: const Text('Tambah Item'),
            ),
          ],
        ),
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
