/// # Phase 2 — Topik 6: Button Widgets, AppBar & Scaffold
///
/// **Scaffold** adalah kerangka halaman Flutter — menyediakan:
/// - `appBar`: header di atas
/// - `body`: konten utama
/// - `floatingActionButton`: tombol melayang (FAB)
/// - `bottomNavigationBar`: navigasi bawah
/// - `drawer`: menu panel geser dari kiri
///
/// **Jenis Button di Flutter (Material 3):**
/// - [ElevatedButton]: tombol utama dengan bayangan
/// - [FilledButton]: tombol solid tanpa bayangan (M3 primary action)
/// - [OutlinedButton]: tombol dengan border, tanpa background
/// - [TextButton]: tombol teks saja (minimal)
/// - [IconButton]: tombol icon bulat
/// - [FloatingActionButton]: tombol melayang
///
/// Jalankan: `flutter run -t lib/phase2/06_buttons_scaffold/buttons_demo.dart`

import 'package:flutter/material.dart';

void main() => runApp(const ButtonsDemoApp());

class ButtonsDemoApp extends StatelessWidget {
  const ButtonsDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buttons & Scaffold',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.deepOrange, useMaterial3: true),
      home: const ButtonsDemoScreen(),
    );
  }
}

class ButtonsDemoScreen extends StatefulWidget {
  const ButtonsDemoScreen({super.key});

  @override
  State<ButtonsDemoScreen> createState() => _ButtonsDemoScreenState();
}

class _ButtonsDemoScreenState extends State<ButtonsDemoScreen> {
  int _fabCount = 0;
  int _selectedNavIndex = 0;

  void _showSnack(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Klik: $label'), duration: const Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ─────────────────────────────────────────────────────────────────
      // APPBAR
      // ─────────────────────────────────────────────────────────────────
      appBar: AppBar(
        title: const Text('Buttons & Scaffold'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // leading: icon/tombol di kiri AppBar (biasanya back button atau menu)
        leading: IconButton(
          icon: const Icon(Icons.menu),
          tooltip: 'Buka Drawer',
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        // actions: list tombol di kanan AppBar
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Cari',
            onPressed: () => _showSnack('Search'),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            tooltip: 'Menu',
            onPressed: () => _showSnack('More'),
          ),
        ],
      ),

      // ─────────────────────────────────────────────────────────────────
      // DRAWER
      // ─────────────────────────────────────────────────────────────────
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepOrange),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person)),
                  SizedBox(height: 8),
                  Text('Faisal Bahri', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text('flutter@dev.com', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () => Navigator.pop(context),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),

      // ─────────────────────────────────────────────────────────────────
      // BODY
      // ─────────────────────────────────────────────────────────────────
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FAB counter display
            if (_fabCount > 0)
              Card(
                color: Colors.deepOrange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text('FAB diklik $_fabCount kali'),
                ),
              ),
            if (_fabCount > 0) const SizedBox(height: 16),

            _SectionTitle('ElevatedButton'),
            _ButtonRow(children: [
              ElevatedButton(onPressed: () => _showSnack('Elevated'), child: const Text('Default')),
              ElevatedButton.icon(
                onPressed: () => _showSnack('Elevated + icon'),
                icon: const Icon(Icons.star),
                label: const Text('With Icon'),
              ),
              ElevatedButton(onPressed: null, child: const Text('Disabled')), // null = disabled
            ]),
            const SizedBox(height: 16),

            _SectionTitle('FilledButton (M3 — primary action)'),
            _ButtonRow(children: [
              FilledButton(onPressed: () => _showSnack('Filled'), child: const Text('Default')),
              FilledButton.icon(
                onPressed: () => _showSnack('Filled + icon'),
                icon: const Icon(Icons.send),
                label: const Text('Send'),
              ),
              FilledButton(onPressed: null, child: const Text('Disabled')),
            ]),
            const SizedBox(height: 16),

            _SectionTitle('OutlinedButton'),
            _ButtonRow(children: [
              OutlinedButton(onPressed: () => _showSnack('Outlined'), child: const Text('Default')),
              OutlinedButton.icon(
                onPressed: () => _showSnack('Outlined + icon'),
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
              ),
            ]),
            const SizedBox(height: 16),

            _SectionTitle('TextButton'),
            _ButtonRow(children: [
              TextButton(onPressed: () => _showSnack('Text'), child: const Text('Default')),
              TextButton.icon(
                onPressed: () => _showSnack('Text + icon'),
                icon: const Icon(Icons.info),
                label: const Text('Info'),
              ),
            ]),
            const SizedBox(height: 16),

            _SectionTitle('IconButton'),
            _ButtonRow(children: [
              IconButton(icon: const Icon(Icons.favorite), tooltip: 'Like', onPressed: () => _showSnack('Like')),
              IconButton.filled(icon: const Icon(Icons.share), tooltip: 'Share', onPressed: () => _showSnack('Share')),
              IconButton.filledTonal(icon: const Icon(Icons.bookmark), tooltip: 'Save', onPressed: () => _showSnack('Save')),
              IconButton.outlined(icon: const Icon(Icons.delete), tooltip: 'Delete', onPressed: () => _showSnack('Delete')),
            ]),
            const SizedBox(height: 16),

            _SectionTitle('Custom Styled Button'),
            ElevatedButton(
              onPressed: () => _showSnack('Custom style'),
              // Kustomisasi style via ButtonStyle
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: const Text('Custom Style Button'),
            ),
            const SizedBox(height: 24),

            _SectionTitle('SegmentedButton (M3)'),
            _SegmentedButtonDemo(),
          ],
        ),
      ),

      // ─────────────────────────────────────────────────────────────────
      // FLOATING ACTION BUTTON
      // ─────────────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _fabCount++),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),

      // ─────────────────────────────────────────────────────────────────
      // BOTTOM NAVIGATION BAR
      // ─────────────────────────────────────────────────────────────────
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedNavIndex,
        onDestinationSelected: (i) => setState(() => _selectedNavIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.explore), label: 'Explore'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _SegmentedButtonDemo extends StatefulWidget {
  @override
  State<_SegmentedButtonDemo> createState() => _SegmentedButtonDemoState();
}

class _SegmentedButtonDemoState extends State<_SegmentedButtonDemo> {
  Set<String> _selected = {'day'};

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'day', label: Text('Day'), icon: Icon(Icons.wb_sunny)),
        ButtonSegment(value: 'week', label: Text('Week'), icon: Icon(Icons.view_week)),
        ButtonSegment(value: 'month', label: Text('Month'), icon: Icon(Icons.calendar_month)),
      ],
      selected: _selected,
      onSelectionChanged: (Set<String> newSelection) {
        setState(() => _selected = newSelection);
      },
    );
  }
}

// ===========================================================================
// HELPER WIDGETS
// ===========================================================================

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey.shade600)),
    );
  }
}

class _ButtonRow extends StatelessWidget {
  final List<Widget> children;
  const _ButtonRow({required this.children});

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 8, runSpacing: 8, children: children);
  }
}
