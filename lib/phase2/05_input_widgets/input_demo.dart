/// # Phase 2 — Topik 5: Input Widgets
///
/// Widget-widget untuk menerima input dari pengguna:
/// - [TextField]: field input teks paling dasar
/// - [TextFormField]: TextField + validasi terintegrasi (dipakai di dalam Form)
/// - [Form]: container yang mengelola beberapa TextFormField sekaligus
///
/// **Konsep penting:**
/// - [TextEditingController]: mengakses/mengubah nilai TextField secara programatik
/// - [FocusNode]: mengontrol focus (keyboard muncul/hilang)
/// - [GlobalKey<FormState>]: key untuk Form, dipakai untuk validate & save
///
/// **Pattern yang benar:**
/// Selalu dispose controller & focusNode di `dispose()` agar tidak memory leak!
///
/// Jalankan: `flutter run -t lib/phase2/05_input_widgets/input_demo.dart`

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const InputDemoApp());

class InputDemoApp extends StatelessWidget {
  const InputDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Input Widgets Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      home: const InputDemoScreen(),
    );
  }
}

class InputDemoScreen extends StatefulWidget {
  const InputDemoScreen({super.key});

  @override
  State<InputDemoScreen> createState() => _InputDemoScreenState();
}

class _InputDemoScreenState extends State<InputDemoScreen> {
  // Key untuk Form — dipakai untuk validasi dan save semua field sekaligus
  final _formKey = GlobalKey<FormState>();

  // Controller untuk mengakses/mengubah nilai field secara programatik
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _bioController = TextEditingController();

  // FocusNode untuk mengontrol focus antar field (next field saat tekan Enter)
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true; // toggle show/hide password
  String? _submittedData; // hasil submit form

  @override
  void dispose() {
    // WAJIB dispose semua controller & focusNode — mencegah memory leak
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  /// Validasi dan submit form.
  void _submitForm() {
    // validate() menjalankan validator di semua TextFormField
    // Mengembalikan true jika semua valid
    if (_formKey.currentState!.validate()) {
      // save() memanggil onSaved callback di semua TextFormField
      _formKey.currentState!.save();

      setState(() {
        _submittedData =
            'Nama: ${_nameController.text}\n'
            'Email: ${_emailController.text}\n'
            'Bio: ${_bioController.text}';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Form berhasil disubmit!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _bioController.clear();
    setState(() => _submittedData = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Widgets'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section: TextField biasa (tanpa form)
            Text('1. TextField Biasa', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _TextFieldExamples(),
            const SizedBox(height: 24),

            // Section: Form dengan validasi
            Text('2. Form + Validasi', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildRegistrationForm(),
            const SizedBox(height: 24),

            // Hasil submit
            if (_submittedData != null) ...[
              Text('✅ Data yang disubmit:', style: Theme.of(context).textTheme.titleSmall),
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(_submittedData!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Form registrasi lengkap dengan validasi.
  Widget _buildRegistrationForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Nama
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nama Lengkap *',
              hintText: 'Masukkan nama lengkap',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next, // tombol "Next" di keyboard
            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_emailFocus),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nama tidak boleh kosong';
              }
              if (value.trim().length < 3) {
                return 'Nama minimal 3 karakter';
              }
              return null; // null = valid
            },
          ),
          const SizedBox(height: 12),

          // Email
          TextFormField(
            controller: _emailController,
            focusNode: _emailFocus,
            decoration: const InputDecoration(
              labelText: 'Email *',
              hintText: 'contoh@email.com',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress, // keyboard khusus email
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocus),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Email tidak boleh kosong';
              // Regex sederhana untuk validasi format email
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value)) return 'Format email tidak valid';
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Password dengan toggle show/hide
          TextFormField(
            controller: _passwordController,
            focusNode: _passwordFocus,
            obscureText: _obscurePassword, // sembunyikan karakter
            decoration: InputDecoration(
              labelText: 'Password *',
              hintText: 'Min. 8 karakter',
              prefixIcon: const Icon(Icons.lock),
              border: const OutlineInputBorder(),
              // Tombol toggle show/hide di ujung kanan
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Password tidak boleh kosong';
              if (value.length < 8) return 'Password minimal 8 karakter';
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Bio — multiline
          TextFormField(
            controller: _bioController,
            decoration: const InputDecoration(
              labelText: 'Bio (opsional)',
              hintText: 'Ceritakan tentang dirimu...',
              border: OutlineInputBorder(),
              alignLabelWithHint: true, // label sejajar dengan baris pertama
            ),
            maxLines: 3,      // tinggi 3 baris
            maxLength: 200,   // batas karakter
          ),
          const SizedBox(height: 16),

          // Tombol aksi
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetForm,
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// TEXTFIELD EXAMPLES (tanpa Form)
// ===========================================================================

/// Contoh berbagai variasi TextField.
class _TextFieldExamples extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // TextField minimal
        const TextField(
          decoration: InputDecoration(
            labelText: 'Minimal TextField',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),

        // TextField hanya angka
        TextField(
          decoration: const InputDecoration(
            labelText: 'Hanya angka',
            hintText: '0',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.numbers),
          ),
          keyboardType: TextInputType.number,
          // inputFormatters: filter input agar hanya menerima digit
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 8),

        // TextField dengan prefix/suffix
        const TextField(
          decoration: InputDecoration(
            labelText: 'Nominal (Rp)',
            prefixText: 'Rp ',
            suffixText: ',00',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
}
