/// # Entry Point Phase 2 — Flutter Fundamentals
///
/// Jalankan file ini untuk membuka menu interaktif Phase 2:
/// ```
/// flutter run -t lib/phase2/main_phase2.dart
/// ```
///
/// Setiap topik bisa diakses langsung dari menu ini, ATAU dijalankan
/// secara individual dengan perintah di bawah masing-masing topik.

import 'package:flutter/material.dart';

// Import semua demo screen dari topik-topik Phase 2
import '01_stateless_stateful/stateless_stateful_demo.dart' as t01;
import '02_layout_widgets/layout_demo.dart' as t02;
import '03_container_decoration/container_demo.dart' as t03;
import '04_scrollable/scrollable_demo.dart' as t04;
import '05_input_widgets/input_demo.dart' as t05;
import '06_buttons_scaffold/buttons_demo.dart' as t06;
import '07_image_icon_dialog_snackbar/media_dialog_demo.dart' as t07;
import '08_custom_widget/custom_widget_demo.dart' as t08;
import '09_theming/theming_demo.dart' as t09;
import '10_responsive_layout/responsive_demo.dart' as t10;
import '11_animation/animation_demo.dart' as t11;
import 'mini_projects/profile_card/profile_card_app.dart' as mp01;
import 'mini_projects/calculator/calculator_app.dart' as mp02;
import 'mini_projects/recipe_app/recipe_app.dart' as mp03;

void main() {
  runApp(const Phase2MenuApp());
}

/// Root widget menu Phase 2.
class Phase2MenuApp extends StatelessWidget {
  const Phase2MenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phase 2 — Flutter Fundamentals',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const Phase2MenuScreen(),
    );
  }
}

// ===========================================================================
// DATA — Daftar semua topik dan mini project
// ===========================================================================

/// Model untuk satu item di menu.
class _MenuItem {
  final String number;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget destination; // screen tujuan saat item di-tap

  const _MenuItem({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.destination,
  });
}

/// Daftar semua topik Phase 2.
final _topics = <_MenuItem>[
  _MenuItem(
    number: '01',
    title: 'StatelessWidget & StatefulWidget',
    subtitle: 'Dua jenis widget dasar + lifecycle',
    icon: Icons.widgets_outlined,
    color: Colors.indigo,
    destination: const t01.DemoScreen(),
  ),
  _MenuItem(
    number: '02',
    title: 'Layout Widgets',
    subtitle: 'Column, Row, Stack, Expanded, Flexible',
    icon: Icons.view_quilt_outlined,
    color: Colors.teal,
    destination: const t02.LayoutDemoScreen(),
  ),
  _MenuItem(
    number: '03',
    title: 'Container & BoxDecoration',
    subtitle: 'Padding, margin, border, shadow, gradient',
    icon: Icons.crop_square_outlined,
    color: Colors.deepPurple,
    destination: const t03.ContainerDemoScreen(),
  ),
  _MenuItem(
    number: '04',
    title: 'Scrollable Widgets',
    subtitle: 'ListView, GridView, SingleChildScrollView',
    icon: Icons.view_list_outlined,
    color: Colors.cyan,
    destination: const t04.ScrollableDemoScreen(),
  ),
  _MenuItem(
    number: '05',
    title: 'Input Widgets',
    subtitle: 'TextField, Form, validasi, controller',
    icon: Icons.text_fields,
    color: Colors.green,
    destination: const t05.InputDemoScreen(),
  ),
  _MenuItem(
    number: '06',
    title: 'Buttons & Scaffold',
    subtitle: 'ElevatedButton, FAB, AppBar, Drawer, BottomNav',
    icon: Icons.smart_button_outlined,
    color: Colors.deepOrange,
    destination: const t06.ButtonsDemoScreen(),
  ),
  _MenuItem(
    number: '07',
    title: 'Image, Icon, Dialog & SnackBar',
    subtitle: 'Media, feedback UI, bottom sheet',
    icon: Icons.image_outlined,
    color: Colors.pink,
    destination: const t07.MediaDialogScreen(),
  ),
  _MenuItem(
    number: '08',
    title: 'Custom Widget',
    subtitle: 'Extract, composition, slot pattern, component library',
    icon: Icons.extension_outlined,
    color: Colors.purple,
    destination: const t08.CustomWidgetScreen(),
  ),
  _MenuItem(
    number: '09',
    title: 'Theming',
    subtitle: 'ThemeData, ColorScheme M3, dark mode',
    icon: Icons.palette_outlined,
    color: Colors.indigo,
    destination: const t09.ThemingDemoScreen(
      themeMode: ThemeMode.light,
      onToggleTheme: _noop,
      onChangeColor: _noopColor,
      currentColor: Colors.indigo,
    ),
  ),
  _MenuItem(
    number: '10',
    title: 'Responsive Layout',
    subtitle: 'MediaQuery, LayoutBuilder, OrientationBuilder',
    icon: Icons.devices_outlined,
    color: Colors.amber,
    destination: const t10.ResponsiveDemoScreen(),
  ),
  _MenuItem(
    number: '11',
    title: 'Animasi Dasar',
    subtitle: 'AnimatedContainer, Hero, AnimatedSwitcher, Tween',
    icon: Icons.animation,
    color: Colors.deepPurple,
    destination: const t11.AnimationDemoScreen(),
  ),
];

/// Daftar mini project Phase 2.
final _miniProjects = <_MenuItem>[
  _MenuItem(
    number: 'MP1',
    title: 'Profile Card App',
    subtitle: 'Layout, custom widget, styling',
    icon: Icons.person_outline,
    color: Colors.blue,
    destination: const mp01.ProfileCardApp(),
  ),
  _MenuItem(
    number: 'MP2',
    title: 'Calculator App',
    subtitle: 'StatefulWidget, Grid, business logic',
    icon: Icons.calculate_outlined,
    color: Colors.orange,
    destination: const mp02.CalculatorApp(),
  ),
  _MenuItem(
    number: 'MP3',
    title: 'Recipe App (UI)',
    subtitle: 'ListView, detail screen, Hero animation',
    icon: Icons.restaurant_menu_outlined,
    color: Colors.green,
    destination: const mp03.RecipeApp(),
  ),
];

// Dummy callback untuk topik 09 (theming dikelola di App-level)
void _noop() {}
void _noopColor(Color _) {}

// ===========================================================================
// MENU SCREEN
// ===========================================================================

class Phase2MenuScreen extends StatelessWidget {
  const Phase2MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phase 2', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text('Flutter Fundamentals', style: TextStyle(fontSize: 12)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header progress
          _ProgressHeader(),
          const SizedBox(height: 16),

          // Bagian topik
          _ListHeader(title: '📚 Topik (${_topics.length} materi)'),
          const SizedBox(height: 8),
          ..._topics.map((item) => _TopicCard(item: item)),
          const SizedBox(height: 24),

          // Bagian mini project
          _ListHeader(title: '🏗️ Mini Projects'),
          const SizedBox(height: 8),
          ..._miniProjects.map((item) => _TopicCard(item: item, isMiniProject: true)),
          const SizedBox(height: 24),

          // Tips cara belajar
          _TipsCard(),
        ],
      ),
    );
  }
}

// ===========================================================================
// COMPONENT WIDGETS
// ===========================================================================

/// Header dengan progress bar Phase 2.
class _ProgressHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🟡 Sedang Berjalan',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Akumulasi: Phase 0 (Dart CLI) + Phase 1 (Dart Advanced) + Phase 2 (Flutter UI)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 12),
            // Progress bar topik
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: 0, // update saat progress bertambah
                minHeight: 8,
                backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.2),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '0 / ${_topics.length} topik selesai',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListHeader extends StatelessWidget {
  final String title;
  const _ListHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold));
  }
}

/// Card untuk satu topik/mini project.
class _TopicCard extends StatelessWidget {
  final _MenuItem item;
  final bool isMiniProject;

  const _TopicCard({required this.item, this.isMiniProject = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: item.color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: isMiniProject
                ? Icon(item.icon, color: item.color, size: 22)
                : Text(
                    item.number,
                    style: TextStyle(
                      color: item.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
          ),
        ),
        title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(item.subtitle, style: const TextStyle(fontSize: 12)),
        trailing: Icon(Icons.chevron_right, color: item.color),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => item.destination,
            settings: RouteSettings(name: item.title),
          ),
        ),
      ),
    );
  }
}

/// Kartu tips cara pakai repo ini.
class _TipsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('💡 Tips Belajar', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const _TipRow('Baca comment di setiap file — sudah ada penjelasan detail'),
            const _TipRow('Coba ubah nilai/parameter dan lihat efeknya (hot reload!)'),
            const _TipRow('Setelah paham demo, kerjakan mini project dari nol'),
            const _TipRow('Jalankan demo individual: flutter run -t lib/phase2/0X_*/demo.dart'),
          ],
        ),
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final String text;
  const _TipRow(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Colors.amber)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
