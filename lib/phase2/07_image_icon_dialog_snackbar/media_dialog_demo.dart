/// # Phase 2 — Topik 7: Image, Icon, Dialog & SnackBar
///
/// Widget untuk menampilkan media dan feedback ke pengguna:
///
/// **Image:**
/// - [Image.network]: gambar dari URL internet
/// - [Image.asset]: gambar dari local assets
/// - [Image.memory]: gambar dari bytes (jarang dipakai langsung)
///
/// **Icon:**
/// - [Icon]: icon dari IconData (Material Icons, Cupertino Icons)
///
/// **Dialog:**
/// - [AlertDialog]: dialog konfirmasi (OK/Cancel)
/// - [SimpleDialog]: dialog pilihan
/// - [showDialog]: fungsi untuk menampilkan dialog
/// - [showModalBottomSheet]: sheet dari bawah layar
///
/// **SnackBar:**
/// - [SnackBar]: notifikasi singkat di bawah layar
/// - [ScaffoldMessenger.showSnackBar]: cara menampilkan SnackBar
///
/// Jalankan: `flutter run -t lib/phase2/07_image_icon_dialog_snackbar/media_dialog_demo.dart`

import 'package:flutter/material.dart';

void main() => runApp(const MediaDialogDemoApp());

class MediaDialogDemoApp extends StatelessWidget {
  const MediaDialogDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image, Icon, Dialog & SnackBar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.pink, useMaterial3: true),
      home: const MediaDialogScreen(),
    );
  }
}

class MediaDialogScreen extends StatelessWidget {
  const MediaDialogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image, Icon, Dialog & SnackBar'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('1. Image'),
            _ImageSection(),
            const SizedBox(height: 24),

            _SectionTitle('2. Icon'),
            _IconSection(),
            const SizedBox(height: 24),

            _SectionTitle('3. Dialog'),
            _DialogSection(),
            const SizedBox(height: 24),

            _SectionTitle('4. SnackBar'),
            _SnackBarSection(),
            const SizedBox(height: 24),

            _SectionTitle('5. Bottom Sheet'),
            _BottomSheetSection(),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// IMAGE SECTION
// ===========================================================================

class _ImageSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image.network — gambar dari internet
        const Text('Image.network:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            // Gambar sederhana dari URL (placeholder dummy)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                'https://picsum.photos/seed/flutter/100/100',
                width: 100,
                height: 100,
                fit: BoxFit.cover, // cropping behavior
                // loadingBuilder: tampilkan loading indicator saat gambar loading
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child; // selesai loading
                  return Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey.shade200,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                // errorBuilder: tampilkan fallback saat gambar gagal dimuat
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            // Contoh berbagai BoxFit
            _BoxFitExamples(),
          ],
        ),
        const SizedBox(height: 16),

        // CircleAvatar — wrapper khusus gambar bulat
        const Text('CircleAvatar:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            // Avatar dengan background image dari network
            const CircleAvatar(
              radius: 32,
              backgroundImage: NetworkImage('https://picsum.photos/seed/avatar/64/64'),
            ),
            // Avatar dengan initial letter (fallback saat tidak ada gambar)
            CircleAvatar(
              radius: 32,
              backgroundColor: Colors.pink.shade200,
              child: const Text('FB', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            // Avatar dengan icon
            CircleAvatar(
              radius: 32,
              backgroundColor: Colors.blue.shade100,
              child: const Icon(Icons.person, size: 32),
            ),
          ],
        ),
      ],
    );
  }
}

class _BoxFitExamples extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final fits = [
      (BoxFit.cover, 'cover'),
      (BoxFit.contain, 'contain'),
      (BoxFit.fill, 'fill'),
    ];
    return Row(
      children: fits.map((entry) {
        final (fit, label) = entry;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  'https://picsum.photos/seed/fit/80/60',
                  width: 70,
                  height: 70,
                  fit: fit,
                  errorBuilder: (_, __, ___) => Container(width: 70, height: 70, color: Colors.grey.shade200),
                ),
              ),
              Text(label, style: const TextStyle(fontSize: 10)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ===========================================================================
// ICON SECTION
// ===========================================================================

class _IconSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            // Icon standar
            const Icon(Icons.home, size: 32),
            // Icon dengan warna
            const Icon(Icons.favorite, size: 32, color: Colors.red),
            // Icon besar
            const Icon(Icons.star, size: 48, color: Colors.amber),
            // Icon dengan gradient (pakai ShaderMask)
            ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                ).createShader(bounds);
              },
              child: const Icon(Icons.flutter_dash, size: 48, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Icon di dalam container dekoratif
        Wrap(
          spacing: 8,
          children: [
            _IconBadge(icon: Icons.notifications, color: Colors.orange, label: '3'),
            _IconBadge(icon: Icons.shopping_cart, color: Colors.green, label: '12'),
            _IconBadge(icon: Icons.mail, color: Colors.blue, label: ''),
          ],
        ),
      ],
    );
  }
}

/// Icon dengan badge notifikasi di pojok kanan atas.
class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label; // badge label, kosong = tidak ada badge

  const _IconBadge({required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color),
        ),
        // Badge — muncul jika label tidak kosong
        if (label.isNotEmpty)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),
            ),
          ),
      ],
    );
  }
}

// ===========================================================================
// DIALOG SECTION
// ===========================================================================

class _DialogSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // AlertDialog — konfirmasi
        ElevatedButton(
          onPressed: () => _showAlertDialog(context),
          child: const Text('AlertDialog'),
        ),
        // Dialog dengan form
        ElevatedButton(
          onPressed: () => _showFormDialog(context),
          child: const Text('Dialog + Form'),
        ),
        // SimpleDialog — pilihan
        OutlinedButton(
          onPressed: () => _showSimpleDialog(context),
          child: const Text('SimpleDialog'),
        ),
      ],
    );
  }

  /// AlertDialog untuk konfirmasi aksi berbahaya (hapus, logout, dll).
  void _showAlertDialog(BuildContext context) {
    showDialog<bool>(
      context: context,
      // barrierDismissible: bisa tutup dengan tap di luar dialog
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.warning_amber, color: Colors.red, size: 32),
          title: const Text('Hapus Data?'),
          content: const Text('Data yang dihapus tidak bisa dikembalikan. Yakin ingin menghapus?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false), // tutup, result: false
              child: const Text('Batal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(dialogContext).pop(true), // tutup, result: true
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    ).then((result) {
      if (result == true && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data dihapus!'), backgroundColor: Colors.red),
        );
      }
    });
  }

  void _showFormDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Masukkan Nama'),
        content: TextField(
          controller: controller,
          autofocus: true, // keyboard langsung muncul
          decoration: const InputDecoration(labelText: 'Nama', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Halo, ${controller.text}!')),
                );
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSimpleDialog(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Pilih Warna Favorit'),
        children: ['Merah', 'Hijau', 'Biru', 'Kuning'].map((color) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, color),
            child: Text(color),
          );
        }).toList(),
      ),
    ).then((result) {
      if (result != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kamu pilih: $result')),
        );
      }
    });
  }
}

// ===========================================================================
// SNACKBAR SECTION
// ===========================================================================

class _SnackBarSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ElevatedButton(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('SnackBar biasa')),
          ),
          child: const Text('Basic'),
        ),
        ElevatedButton(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('File dihapus'),
              backgroundColor: Colors.red.shade700,
              duration: const Duration(seconds: 4),
              // action: tombol aksi di dalam SnackBar (misal: undo)
              action: SnackBarAction(
                label: 'UNDO',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Dibatalkan!')),
                  );
                },
              ),
            ),
          ),
          child: const Text('Dengan Undo'),
        ),
        ElevatedButton(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Tersimpan!'),
                ],
              ),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating, // melayang di atas bottomNav
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              margin: const EdgeInsets.all(16),
            ),
          ),
          child: const Text('Floating'),
        ),
      ],
    );
  }
}

// ===========================================================================
// BOTTOM SHEET SECTION
// ===========================================================================

class _BottomSheetSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        ElevatedButton(
          onPressed: () => _showModalBottomSheet(context),
          child: const Text('Modal Bottom Sheet'),
        ),
        OutlinedButton(
          onPressed: () => _showDraggableBottomSheet(context),
          child: const Text('Draggable Bottom Sheet'),
        ),
      ],
    );
  }

  void _showModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      // shape: rounding di bagian atas sheet
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle indicator
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            const Text('Share ke:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ShareOption(icon: Icons.message, label: 'WhatsApp', color: Colors.green),
                _ShareOption(icon: Icons.email, label: 'Email', color: Colors.blue),
                _ShareOption(icon: Icons.link, label: 'Salin Link', color: Colors.grey),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showDraggableBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // izinkan full height
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5, // awalnya 50% tinggi layar
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (_, scrollController) => Column(
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Drag untuk resize', style: Theme.of(context).textTheme.titleMedium),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController, // PENTING: connect ke DraggableScrollableSheet
                itemCount: 20,
                itemBuilder: (_, i) => ListTile(title: Text('Item ${i + 1}')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _ShareOption({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          radius: 28,
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
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
