/// # Phase 2 — Topik 4: Scrollable Widgets
///
/// Widget-widget untuk menampilkan konten yang bisa di-scroll:
/// - [SingleChildScrollView]: satu konten bisa di-scroll (biasanya Column panjang)
/// - [ListView]: list vertikal/horizontal. Ada beberapa varian:
///   - `ListView()`: semua item sekaligus (untuk list pendek)
///   - `ListView.builder()`: item dibuat lazy (efisien untuk list panjang)
///   - `ListView.separated()`: ada separator antar item
/// - [GridView]: tampilan grid (seperti gallery foto, product list)
///   - `GridView.count()`: jumlah kolom tetap
///   - `GridView.builder()`: lazy loading
///
/// **Kapan pakai apa:**
/// - SingleChildScrollView: halaman dengan form panjang
/// - ListView.builder: list dari API (banyak item, lazy)
/// - GridView: galeri, product grid, icon grid
///
/// Jalankan: `flutter run -t lib/phase2/04_scrollable/scrollable_demo.dart`

import 'package:flutter/material.dart';

void main() => runApp(const ScrollableDemoApp());

class ScrollableDemoApp extends StatelessWidget {
  const ScrollableDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scrollable Widgets',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.cyan, useMaterial3: true),
      home: const ScrollableDemoScreen(),
    );
  }
}

class ScrollableDemoScreen extends StatefulWidget {
  const ScrollableDemoScreen({super.key});

  @override
  State<ScrollableDemoScreen> createState() => _ScrollableDemoScreenState();
}

class _ScrollableDemoScreenState extends State<ScrollableDemoScreen> {
  /// Index tab yang aktif saat ini
  int _selectedTab = 0;

  final _tabs = ['ListView', 'GridView', 'SingleChild'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scrollable Widgets'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Row(
            children: _tabs.asMap().entries.map((e) {
              final isActive = e.key == _selectedTab;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTab = e.key),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isActive ? Theme.of(context).colorScheme.primary : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Text(
                      e.value,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
      body: [
        const _ListViewDemo(),
        const _GridViewDemo(),
        const _SingleChildScrollDemo(),
      ][_selectedTab],
    );
  }
}

// ===========================================================================
// LISTVIEW DEMO
// ===========================================================================

class _ListViewDemo extends StatelessWidget {
  const _ListViewDemo();

  // Data dummy — simulasi data dari API
  static final _items = List.generate(
    30,
    (i) => _Item(
      id: i + 1,
      title: 'Item #${i + 1}',
      subtitle: 'Deskripsi item nomor ${i + 1}',
      color: Colors.primaries[i % Colors.primaries.length],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            'ListView.builder — ${_items.length} items (lazy loading)',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Expanded(
          child: ListView.separated(
            // itemCount: jumlah item — wajib ada agar builder tahu kapan berhenti
            itemCount: _items.length,

            // separatorBuilder: widget pemisah antar item
            separatorBuilder: (_, __) => const Divider(height: 1),

            // itemBuilder: dipanggil hanya untuk item yang terlihat di layar (LAZY)
            // Efisien untuk ribuan item sekalipun — tidak semua dibuat sekaligus
            itemBuilder: (context, index) {
              final item = _items[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: item.color,
                  child: Text(
                    '${item.id}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                title: Text(item.title),
                subtitle: Text(item.subtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Tap: ${item.title}')),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ===========================================================================
// GRIDVIEW DEMO
// ===========================================================================

class _GridViewDemo extends StatelessWidget {
  const _GridViewDemo();

  // Data dummy foto/icon
  static final _photos = List.generate(
    20,
    (i) => _Photo(
      id: i + 1,
      color: Colors.primaries[i % Colors.primaries.length],
      icon: Icons.photo,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),

      // SliverGridDelegateWithFixedCrossAxisCount: jumlah kolom tetap
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,    // 3 kolom
        crossAxisSpacing: 8,  // jarak horizontal antar item
        mainAxisSpacing: 8,   // jarak vertikal antar item
        childAspectRatio: 1,  // rasio lebar:tinggi setiap item (1 = kotak)
      ),

      itemCount: _photos.length,
      itemBuilder: (context, index) {
        final photo = _photos[index];
        return Container(
          decoration: BoxDecoration(
            color: photo.color.withOpacity(0.7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(photo.icon, color: Colors.white, size: 32),
              const SizedBox(height: 4),
              Text(
                'Photo ${photo.id}',
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ===========================================================================
// SINGLE CHILD SCROLL VIEW DEMO
// ===========================================================================

/// SingleChildScrollView berguna untuk halaman dengan form panjang
/// atau konten yang mungkin overflow saat keyboard muncul.
class _SingleChildScrollDemo extends StatelessWidget {
  const _SingleChildScrollDemo();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // physics: menentukan behavior scroll
      // BouncingScrollPhysics = gaya iOS (bounce di ujung)
      // ClampingScrollPhysics = gaya Android (no bounce)
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Form Panjang', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text(
            'SingleChildScrollView membungkus Column panjang agar bisa di-scroll '
            'saat konten melebihi ukuran layar. Berguna untuk form, artikel, dan '
            'halaman settings.',
          ),
          const SizedBox(height: 16),

          // Simulasi form field yang panjang
          ...List.generate(8, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Field ${i + 1}',
                  hintText: 'Isi field ${i + 1}',
                  border: const OutlineInputBorder(),
                ),
              ),
            );
          }),

          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// DATA MODELS
// ===========================================================================

class _Item {
  final int id;
  final String title;
  final String subtitle;
  final Color color;
  const _Item({required this.id, required this.title, required this.subtitle, required this.color});
}

class _Photo {
  final int id;
  final Color color;
  final IconData icon;
  const _Photo({required this.id, required this.color, required this.icon});
}
