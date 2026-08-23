/// Demo 04 — Local Storage: SharedPreferences + Hive.
///
/// **Concepts covered:**
/// - SharedPreferences — simple key/value pairs (settings, flags, tokens)
/// - Hive — fast NoSQL box storage for structured objects
/// - When to use which:
///   SharedPreferences → app settings, last-seen timestamps, auth tokens
///   Hive → offline cache, user-generated content, large-ish structured data
/// - Hive TypeAdapter — how to store custom objects (not just primitives)
/// - Opening and closing boxes
///
/// **Important:** Hive boxes must be opened before use (usually at app start).
/// SharedPreferences is always available after `getInstance()`.
library;

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Hive model
// ─────────────────────────────────────────────────────────────────────────────

// In a real project you annotate with @HiveType + @HiveField and run
// build_runner to generate the TypeAdapter. Here we write it manually
// to show what the generator produces.

/// A simple note stored in Hive.
class HiveNote {
  final String id;
  final String content;
  final DateTime createdAt;

  HiveNote({required this.id, required this.content, required this.createdAt});
}

/// Manual TypeAdapter — tells Hive how to serialize/deserialize HiveNote.
class HiveNoteAdapter extends TypeAdapter<HiveNote> {
  @override
  final int typeId = 0; // unique per HiveType in your app

  @override
  HiveNote read(BinaryReader reader) {
    return HiveNote(
      id: reader.readString(),
      content: reader.readString(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
    );
  }

  @override
  void write(BinaryWriter writer, HiveNote obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.content);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hive box key
// ─────────────────────────────────────────────────────────────────────────────

const _notesBoxName = 'notes';

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

class LocalStorageDemo extends StatelessWidget {
  const LocalStorageDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Storage Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const _LocalStorageScreen(),
    );
  }
}

class _LocalStorageScreen extends StatefulWidget {
  const _LocalStorageScreen();

  @override
  State<_LocalStorageScreen> createState() => _LocalStorageScreenState();
}

class _LocalStorageScreenState extends State<_LocalStorageScreen> {
  bool _hiveReady = false;

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(HiveNoteAdapter());
    }
    await Hive.openBox<HiveNote>(_notesBoxName);
    if (mounted) setState(() => _hiveReady = true);
  }

  @override
  void dispose() {
    Hive.close(); // close all open boxes
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Local Storage'),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.settings), text: 'SharedPrefs'),
              Tab(icon: Icon(Icons.note), text: 'Hive'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const _SharedPrefsTab(),
            _hiveReady
                ? const _HiveTab()
                : const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 1 — SharedPreferences
// ─────────────────────────────────────────────────────────────────────────────

class _SharedPrefsTab extends StatefulWidget {
  const _SharedPrefsTab();

  @override
  State<_SharedPrefsTab> createState() => _SharedPrefsTabState();
}

class _SharedPrefsTabState extends State<_SharedPrefsTab> {
  SharedPreferences? _prefs;

  // Demo values stored in SharedPreferences
  String _username = '';
  bool _darkMode = false;
  int _loginCount = 0;
  String _lastLogin = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _prefs = prefs;
      _username = prefs.getString('username') ?? '';
      _darkMode = prefs.getBool('darkMode') ?? false;
      _loginCount = prefs.getInt('loginCount') ?? 0;
      _lastLogin = prefs.getString('lastLogin') ?? 'never';
    });
  }

  Future<void> _save() async {
    final prefs = _prefs!;
    await prefs.setString('username', _username);
    await prefs.setBool('darkMode', _darkMode);
    final newCount = _loginCount + 1;
    final now = DateTime.now().toString().substring(0, 19);
    await prefs.setInt('loginCount', newCount);
    await prefs.setString('lastLogin', now);
    setState(() {
      _loginCount = newCount;
      _lastLogin = now;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved to SharedPreferences!')),
      );
    }
  }

  Future<void> _clear() async {
    await _prefs!.clear();
    setState(() {
      _username = '';
      _darkMode = false;
      _loginCount = 0;
      _lastLogin = 'never';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_prefs == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SharedPreferences — key/value pairs',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Best for: settings, flags, simple strings & numbers.\n'
                  'NOT for large data or complex objects.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Username
        TextField(
          decoration: const InputDecoration(
            labelText: 'Username',
            border: OutlineInputBorder(),
          ),
          controller: TextEditingController(text: _username),
          onChanged: (v) => _username = v,
        ),
        const SizedBox(height: 12),

        // Dark mode toggle
        SwitchListTile(
          title: const Text('Dark Mode'),
          value: _darkMode,
          onChanged: (v) => setState(() => _darkMode = v),
        ),

        // Read-only stats
        ListTile(
          leading: const Icon(Icons.login),
          title: const Text('Login count'),
          trailing: Text('$_loginCount',
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        ListTile(
          leading: const Icon(Icons.access_time),
          title: const Text('Last saved'),
          trailing: Text(_lastLogin,
              style: const TextStyle(fontSize: 12)),
        ),

        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _prefs != null ? _save : null,
                icon: const Icon(Icons.save),
                label: const Text('Save'),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: _prefs != null ? _clear : null,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Clear All'),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 2 — Hive
// ─────────────────────────────────────────────────────────────────────────────

class _HiveTab extends StatefulWidget {
  const _HiveTab();

  @override
  State<_HiveTab> createState() => _HiveTabState();
}

class _HiveTabState extends State<_HiveTab> {
  final _ctrl = TextEditingController();

  Box<HiveNote> get _box => Hive.box<HiveNote>(_notesBoxName);

  void _add() {
    if (_ctrl.text.trim().isEmpty) return;
    final note = HiveNote(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: _ctrl.text.trim(),
      createdAt: DateTime.now(),
    );
    _box.put(note.id, note); // key = note.id
    _ctrl.clear();
    setState(() {}); // trigger rebuild to show new note
  }

  void _delete(String id) {
    _box.delete(id);
    setState(() {});
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder — rebuilds automatically when box changes.
    // This is the reactive pattern for Hive without Riverpod.
    return ValueListenableBuilder(
      valueListenable: _box.listenable(),
      builder: (context, box, _) {
        final notes = box.values.toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return Column(
          children: [
            // Info card
            Padding(
              padding: const EdgeInsets.all(12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hive — fast NoSQL box storage',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Best for: offline cache, notes, structured objects.\n'
                        'Persists across app restarts automatically.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text('${notes.length} notes stored',
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),

            // Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      decoration: const InputDecoration(
                        hintText: 'Type a note...',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _add(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(onPressed: _add, child: const Text('Add')),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Notes list
            Expanded(
              child: notes.isEmpty
                  ? const Center(
                      child: Text('No notes yet. Add one above!',
                          style: TextStyle(color: Colors.grey)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        return Card(
                          child: ListTile(
                            title: Text(note.content),
                            subtitle: Text(
                              note.createdAt.toString().substring(0, 19),
                              style: const TextStyle(fontSize: 11),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              onPressed: () => _delete(note.id),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
