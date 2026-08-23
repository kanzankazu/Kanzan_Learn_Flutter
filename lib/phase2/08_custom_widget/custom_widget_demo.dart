/// # Phase 2 — Topik 8: Custom Widget (Extract & Composition)
///
/// **Mengapa perlu custom widget?**
/// Saat kode Flutter mulai panjang dan ada bagian yang berulang,
/// saatnya extract ke widget sendiri.
///
/// **Dua teknik utama:**
/// 1. **Extract Widget**: pindahkan bagian `build()` ke class/function baru
/// 2. **Composition**: gabungkan widget kecil untuk membentuk widget kompleks
///
/// **Aturan praktis:**
/// - Widget yang muncul >1 kali → extract ke class
/// - Widget yang terlalu panjang di `build()` → extract ke method/class
/// - Widget yang bisa dipakai di banyak screen → jadikan "shared widget"
///
/// **Widget vs Function:**
/// - Prefer class (StatelessWidget) vs function builder
/// - Class: Flutter bisa optimize, punya identity, bisa const
/// - Function: tidak bisa dioptimasi secara terpisah oleh Flutter
///
/// Jalankan: `flutter run -t lib/phase2/08_custom_widget/custom_widget_demo.dart`

import 'package:flutter/material.dart';

void main() => runApp(const CustomWidgetDemoApp());

class CustomWidgetDemoApp extends StatelessWidget {
  const CustomWidgetDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Widget Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.purple, useMaterial3: true),
      home: const CustomWidgetScreen(),
    );
  }
}

class CustomWidgetScreen extends StatelessWidget {
  const CustomWidgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Widget & Composition'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('1. Widget Hasil Extract'),
            _ExtractExample(),
            const SizedBox(height: 24),

            _SectionTitle('2. Composition Pattern'),
            _CompositionExample(),
            const SizedBox(height: 24),

            _SectionTitle('3. Widget dengan Slot (slot pattern)'),
            _SlotPatternExample(),
            const SizedBox(height: 24),

            _SectionTitle('4. Reusable Component Library'),
            _ComponentLibraryExample(),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// 1. EXTRACT EXAMPLE
// ===========================================================================
// Contoh SEBELUM dan SESUDAH extract.
// Lihat bagaimana kode jadi lebih bersih setelah di-extract.

/// SEBELUM: semua kode inline di dalam build() — susah dibaca
/// SESUDAH: di-extract ke widget [StatsCard] — reusable dan readable

class _ExtractExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Widget yang sama dipakai 3x — tidak perlu copy-paste kodenya
        Expanded(child: StatsCard(value: '42', label: 'Posts', icon: Icons.article, color: Colors.blue)),
        const SizedBox(width: 8),
        Expanded(child: StatsCard(value: '1.2K', label: 'Followers', icon: Icons.people, color: Colors.pink)),
        const SizedBox(width: 8),
        Expanded(child: StatsCard(value: '89', label: 'Following', icon: Icons.person_add, color: Colors.green)),
      ],
    );
  }
}

/// Kartu statistik yang bisa dipakai berulang dengan data berbeda.
///
/// Dengan extract ini, kita bisa:
/// - Reuse di tempat lain hanya dengan passing parameter berbeda
/// - Ubah style sekali → berubah di semua tempat
/// - Test widget ini secara terpisah
class StatsCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const StatsCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// 2. COMPOSITION PATTERN
// ===========================================================================

/// Composition: gabungkan widget-widget kecil menjadi widget yang lebih besar.
class _CompositionExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ProfileCard dibangun dari Avatar + UserInfo + ActionButtons
    return const ProfileCard(
      name: 'Faisal Bahri',
      bio: 'Android & Flutter Developer 📱',
      followers: 1250,
      isFollowing: false,
    );
  }
}

/// ProfileCard = gabungan dari beberapa widget kecil.
///
/// Ini contoh composition:
/// - [UserAvatar] untuk gambar profil
/// - [UserInfo] untuk nama dan bio
/// - [FollowButton] untuk tombol follow
class ProfileCard extends StatefulWidget {
  final String name;
  final String bio;
  final int followers;
  final bool isFollowing;

  const ProfileCard({
    super.key,
    required this.name,
    required this.bio,
    required this.followers,
    required this.isFollowing,
  });

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  late bool _isFollowing;
  late int _followers;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.isFollowing;
    _followers = widget.followers;
  }

  void _toggleFollow() {
    setState(() {
      _isFollowing = !_isFollowing;
      _followers += _isFollowing ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Widget kecil: Avatar
                UserAvatar(name: widget.name),
                const SizedBox(width: 12),
                // Widget kecil: Info nama & bio
                Expanded(child: UserInfo(name: widget.name, bio: widget.bio)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$_followers followers', style: Theme.of(context).textTheme.bodySmall),
                // Widget kecil: tombol follow
                FollowButton(isFollowing: _isFollowing, onTap: _toggleFollow),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget kecil: Avatar pengguna.
class UserAvatar extends StatelessWidget {
  final String name;
  final double radius;

  const UserAvatar({super.key, required this.name, this.radius = 28});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: Text(
        name[0].toUpperCase(),
        style: TextStyle(
          fontSize: radius * 0.7,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

/// Widget kecil: Info nama dan bio.
class UserInfo extends StatelessWidget {
  final String name;
  final String bio;

  const UserInfo({super.key, required this.name, required this.bio});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        Text(bio, style: Theme.of(context).textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

/// Widget kecil: Tombol follow dengan state toggle.
class FollowButton extends StatelessWidget {
  final bool isFollowing;
  final VoidCallback onTap; // VoidCallback = void Function()

  const FollowButton({super.key, required this.isFollowing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return isFollowing
        ? OutlinedButton(onPressed: onTap, child: const Text('Mengikuti'))
        : FilledButton(onPressed: onTap, child: const Text('Ikuti'));
  }
}

// ===========================================================================
// 3. SLOT PATTERN (children as parameters)
// ===========================================================================

/// Slot pattern: widget menerima child widget sebagai parameter.
///
/// Pattern ini sangat fleksibel — parent widget menentukan "kerangka"
/// tapi konten di dalam bisa disesuaikan dari luar.
class _SlotPatternExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // InfoCard menerima title + body sebagai slot
        InfoCard(
          title: const Text('Tip Hari Ini'),
          body: const Text('Composition > Inheritance. Susun widget kecil-kecil daripada buat satu widget raksasa.'),
          footer: TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.thumb_up_outlined),
            label: const Text('Helpful'),
          ),
        ),
        const SizedBox(height: 8),
        InfoCard(
          title: Row(
            children: const [
              Icon(Icons.warning_amber, color: Colors.orange),
              SizedBox(width: 4),
              Text('Perhatian'),
            ],
          ),
          body: const Text('Jangan lupa dispose controller dan focusNode di StatefulWidget!'),
        ),
      ],
    );
  }
}

/// Widget "kerangka kartu" dengan slot title, body, dan footer (opsional).
///
/// Pattern ini disebut "slot" atau "named children" — widget parent
/// tidak peduli isi title/body/footer itu apa, terserah yang memakai.
class InfoCard extends StatelessWidget {
  final Widget title;
  final Widget body;
  final Widget? footer; // nullable = opsional

  const InfoCard({
    super.key,
    required this.title,
    required this.body,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Slot title
            DefaultTextStyle(
              style: Theme.of(context).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold),
              child: title,
            ),
            const SizedBox(height: 4),
            // Slot body
            DefaultTextStyle(
              style: Theme.of(context).textTheme.bodySmall!,
              child: body,
            ),
            // Slot footer — hanya tampil jika ada
            if (footer != null) ...[
              const Divider(height: 16),
              Align(alignment: Alignment.centerRight, child: footer!),
            ],
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// 4. COMPONENT LIBRARY EXAMPLE
// ===========================================================================

class _ComponentLibraryExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Chip / Tag komponen reusable
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            AppChip(label: 'Flutter', color: Colors.blue),
            AppChip(label: 'Dart', color: Colors.teal),
            AppChip(label: 'Android', color: Colors.green),
            AppChip(label: 'Compose', color: Colors.purple),
          ],
        ),
        const SizedBox(height: 12),
        // Status badge
        Wrap(
          spacing: 8,
          children: [
            StatusBadge.success(label: 'Aktif'),
            StatusBadge.warning(label: 'Menunggu'),
            StatusBadge.error(label: 'Gagal'),
            StatusBadge.info(label: 'Draft'),
          ],
        ),
        const SizedBox(height: 12),
        // Loading button (simulasi async operation)
        const _LoadingButtonDemo(),
      ],
    );
  }
}

/// Chip/tag kecil yang bisa dipakai di mana saja.
class AppChip extends StatelessWidget {
  final String label;
  final Color color;

  const AppChip({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }
}

/// Badge status dengan factory constructor untuk tiap state.
///
/// Named constructor pattern: StatusBadge.success(), .warning(), .error(), .info()
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const StatusBadge({super.key, required this.label, required this.color, required this.icon});

  // Factory constructor — buat instance dengan konfigurasi preset
  factory StatusBadge.success({required String label}) =>
      StatusBadge(label: label, color: Colors.green, icon: Icons.check_circle);

  factory StatusBadge.warning({required String label}) =>
      StatusBadge(label: label, color: Colors.orange, icon: Icons.warning);

  factory StatusBadge.error({required String label}) =>
      StatusBadge(label: label, color: Colors.red, icon: Icons.error);

  factory StatusBadge.info({required String label}) =>
      StatusBadge(label: label, color: Colors.blue, icon: Icons.info);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}

/// Tombol yang menunjukkan loading state saat proses async berjalan.
class _LoadingButtonDemo extends StatefulWidget {
  const _LoadingButtonDemo();

  @override
  State<_LoadingButtonDemo> createState() => _LoadingButtonDemoState();
}

class _LoadingButtonDemoState extends State<_LoadingButtonDemo> {
  bool _isLoading = false;

  Future<void> _simulateAsync() async {
    setState(() => _isLoading = true);
    // Simulasi operasi async (misal: API call)
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return LoadingButton(
      isLoading: _isLoading,
      onPressed: _isLoading ? null : _simulateAsync,
      label: 'Simpan Data',
    );
  }
}

/// Tombol reusable dengan built-in loading indicator.
class LoadingButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;
  final String label;

  const LoadingButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        child: isLoading
            ? const SizedBox(
                height: 20, width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(label),
      ),
    );
  }
}

// ===========================================================================
// HELPER
// ===========================================================================

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
