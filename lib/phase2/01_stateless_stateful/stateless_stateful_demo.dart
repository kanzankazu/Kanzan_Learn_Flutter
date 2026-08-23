/// # Phase 2 — Topik 1: StatelessWidget & StatefulWidget
///
/// Dua jenis widget dasar di Flutter:
/// - [StatelessWidget]: UI statis, tidak punya state yang bisa berubah
/// - [StatefulWidget]: UI dinamis, punya state yang bisa berubah dan trigger rebuild
///
/// **Aturan sederhana:**
/// Kalau UI-mu bisa berubah setelah ditampilkan (tombol diklik, data diupdate)
/// → pakai [StatefulWidget]. Kalau tidak → pakai [StatelessWidget].
///
/// Jalankan: `flutter run -t lib/phase2/01_stateless_stateful/stateless_stateful_demo.dart`

import 'package:flutter/material.dart';

void main() {
  runApp(const StatelessStatefulDemoApp());
}

/// Root app — [StatelessWidget] karena tidak ada state yang berubah di sini.
class StatelessStatefulDemoApp extends StatelessWidget {
  const StatelessStatefulDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StatelessWidget vs StatefulWidget',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const DemoScreen(),
    );
  }
}

// ===========================================================================
// STATELESS WIDGET EXAMPLE
// ===========================================================================

/// Kartu profil sederhana — **StatelessWidget**.
///
/// Widget ini hanya menampilkan data yang diberikan via constructor.
/// Tidak ada interaksi yang mengubah tampilan — cocok untuk StatelessWidget.
class ProfileCard extends StatelessWidget {
  /// Nama yang akan ditampilkan
  final String name;

  /// Role/jabatan
  final String role;

  /// Warna kartu
  final Color color;

  const ProfileCard({
    super.key,
    required this.name,
    required this.role,
    this.color = Colors.indigo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar dengan initial huruf pertama
            CircleAvatar(
              backgroundColor: color,
              child: Text(
                name[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.titleMedium),
                Text(role, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// STATEFUL WIDGET EXAMPLE
// ===========================================================================

/// Counter dengan tombol — **StatefulWidget**.
///
/// Nilai counter berubah saat tombol diklik → butuh state → StatefulWidget.
///
/// Struktur StatefulWidget terdiri dari 2 class:
/// 1. [CounterWidget] — widget itu sendiri (immutable, seperti StatelessWidget)
/// 2. [_CounterWidgetState] — state-nya (mutable, berisi data yang bisa berubah)
class CounterWidget extends StatefulWidget {
  /// Label yang ditampilkan di atas counter
  final String label;

  const CounterWidget({super.key, required this.label});

  /// Flutter memanggil ini untuk membuat State object
  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

/// State class — prefik underscore (_) artinya private, hanya bisa dipakai di file ini.
class _CounterWidgetState extends State<CounterWidget> {
  /// Variabel state — nilainya bisa berubah
  int _count = 0;

  /// Method untuk increment — panggil [setState] agar Flutter rebuild UI
  void _increment() {
    // setState() memberitahu Flutter bahwa state berubah → UI di-rebuild
    setState(() {
      _count++;
    });
  }

  /// Method untuk decrement
  void _decrement() {
    setState(() {
      if (_count > 0) _count--; // guard: tidak boleh negatif
    });
  }

  /// Method untuk reset
  void _reset() {
    setState(() {
      _count = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Akses label dari widget (parent class) via `widget.label`
            Text(widget.label, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              '$_count',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: _count == 0 ? Colors.grey : Colors.indigo,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filled(
                  onPressed: _decrement,
                  icon: const Icon(Icons.remove),
                  tooltip: 'Kurang',
                ),
                const SizedBox(width: 8),
                TextButton(onPressed: _reset, child: const Text('Reset')),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _increment,
                  icon: const Icon(Icons.add),
                  tooltip: 'Tambah',
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
// WIDGET LIFECYCLE DEMO
// ===========================================================================

/// Demo lifecycle StatefulWidget.
///
/// Lifecycle method yang penting:
/// - [initState]: dipanggil sekali saat widget pertama kali dibuat
/// - [build]: dipanggil setiap kali setState() dipanggil
/// - [didUpdateWidget]: dipanggil saat parent widget kirim parameter baru
/// - [dispose]: dipanggil saat widget dihapus dari tree (cleanup!)
class LifecycleDemo extends StatefulWidget {
  const LifecycleDemo({super.key});

  @override
  State<LifecycleDemo> createState() => _LifecycleDemoState();
}

class _LifecycleDemoState extends State<LifecycleDemo> {
  final List<String> _log = [];
  int _rebuildCount = 0;

  @override
  void initState() {
    super.initState(); // selalu panggil super terlebih dahulu!
    _addLog('initState() — widget dibuat pertama kali');
  }

  @override
  void dispose() {
    _addLog('dispose() — widget dihapus'); // cleanup: cancel timer, close stream, dll
    super.dispose(); // selalu panggil super di akhir!
  }

  void _addLog(String message) {
    // setState tidak aman di initState sebelum build pertama,
    // tapi setelah itu aman dipanggil di mana saja.
    if (mounted) {
      setState(() {
        _log.add('• $message');
        _rebuildCount++;
      });
    }
  }

  void _triggerRebuild() {
    _addLog('build() — rebuild #$_rebuildCount dipicu oleh setState()');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Widget Lifecycle', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            // Tampilkan log lifecycle
            Container(
              height: 120,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                itemCount: _log.length,
                itemBuilder: (_, i) => Text(
                  _log[i],
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _triggerRebuild,
              child: const Text('Trigger rebuild (setState)'),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// DEMO SCREEN
// ===========================================================================

/// Screen utama yang menggabungkan semua contoh di atas.
class DemoScreen extends StatelessWidget {
  const DemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StatelessWidget & StatefulWidget'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section: StatelessWidget
            _SectionHeader(
              title: '1. StatelessWidget',
              subtitle: 'UI statis — tidak berubah setelah dibuat',
              color: Colors.green,
            ),
            const ProfileCard(name: 'Faisal Bahri', role: 'Android Developer'),
            const ProfileCard(name: 'Budi Santoso', role: 'Flutter Dev', color: Colors.teal),
            const SizedBox(height: 24),

            // Section: StatefulWidget
            _SectionHeader(
              title: '2. StatefulWidget',
              subtitle: 'UI dinamis — berubah saat state di-update via setState()',
              color: Colors.blue,
            ),
            const CounterWidget(label: 'Klik counter'),
            const SizedBox(height: 24),

            // Section: Lifecycle
            _SectionHeader(
              title: '3. Widget Lifecycle',
              subtitle: 'Urutan: initState → build → setState → build → dispose',
              color: Colors.orange,
            ),
            const LifecycleDemo(),
            const SizedBox(height: 24),

            // Ringkasan kapan pakai apa
            _SummaryCard(),
          ],
        ),
      ),
    );
  }
}

/// Header section kecil — helper widget untuk DRY principle.
class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color),
          ),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          const Divider(),
        ],
      ),
    );
  }
}

/// Kartu ringkasan kapan pakai StatelessWidget vs StatefulWidget.
class _SummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📌 Kapan pakai apa?', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const _Row(icon: '🟢', text: 'StatelessWidget: teks, icon, gambar, card statis'),
            const _Row(icon: '🔵', text: 'StatefulWidget: counter, form, toggle, animasi'),
            const _Row(icon: '💡', text: 'Prefer StatelessWidget — lebih performa'),
            const _Row(icon: '⚠️', text: 'Jangan lupa panggil setState() kalau mau update UI'),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String icon;
  final String text;
  const _Row({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text('$icon  $text'),
    );
  }
}
