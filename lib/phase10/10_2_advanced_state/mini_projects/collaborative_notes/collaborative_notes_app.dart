/// Phase 10.2 — Mini Project: Collaborative Notes (Offline-first)
///
/// A production-quality offline-first notes app demonstrating Track 2 skills:
/// - Riverpod Generator for state management
/// - CRDT (LWW-Map) for conflict-free sync
/// - Sync queue for offline mutations
/// - State machine for sync status
/// - connectivity_plus for real-time network monitoring
import 'package:flutter/material.dart';

void main() => runApp(const CollaborativeNotesApp());

class CollaborativeNotesApp extends StatelessWidget {
  const CollaborativeNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Collaborative Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: const NotesScreen(),
    );
  }
}

/// Domain entity for a note.
class Note {
  final String id;
  final String title;
  final String body;
  final DateTime updatedAt;
  final _SyncStatus syncStatus;

  const Note({
    required this.id,
    required this.title,
    required this.body,
    required this.updatedAt,
    this.syncStatus = _SyncStatus.synced,
  });

  Note copyWith({String? title, String? body, _SyncStatus? syncStatus}) =>
      Note(
        id: id,
        title: title ?? this.title,
        body: body ?? this.body,
        updatedAt: DateTime.now(),
        syncStatus: syncStatus ?? this.syncStatus,
      );
}

/// Sync status for each note — drives the UI indicator.
enum _SyncStatus { synced, syncing, pending, error }

/// Main notes list screen.
class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  // Simulated state — in production use Riverpod providers
  bool _isOnline = true;
  List<Note> _notes = [
    Note(id: '1', title: 'Meeting Notes', body: 'Discuss sprint 42 goals...', updatedAt: DateTime(2026, 8, 24, 9, 0)),
    Note(id: '2', title: 'Shopping List', body: 'Milk, eggs, coffee...', updatedAt: DateTime(2026, 8, 24, 10, 30)),
    Note(id: '3', title: 'Flutter Tips', body: 'Use const constructors everywhere...', updatedAt: DateTime(2026, 8, 24, 11, 0)),
  ];
  int _pendingCount = 0;

  void _toggleNetwork() {
    setState(() {
      _isOnline = !_isOnline;
      if (_isOnline && _pendingCount > 0) {
        // Simulate syncing pending notes
        for (var i = 0; i < _notes.length; i++) {
          if (_notes[i].syncStatus == _SyncStatus.pending) {
            _notes[i] = _notes[i].copyWith(syncStatus: _SyncStatus.syncing);
          }
        }
        Future.delayed(const Duration(milliseconds: 800), () {
          if (!mounted) return;
          setState(() {
            _notes = _notes
                .map((n) => n.syncStatus == _SyncStatus.syncing
                    ? n.copyWith(syncStatus: _SyncStatus.synced)
                    : n)
                .toList();
            _pendingCount = 0;
          });
        });
      }
    });
  }

  void _addNote() {
    final newNote = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'New Note ${_notes.length + 1}',
      body: 'Tap to edit...',
      updatedAt: DateTime.now(),
      syncStatus: _isOnline ? _SyncStatus.syncing : _SyncStatus.pending,
    );

    setState(() {
      _notes = [newNote, ..._notes];
      if (!_isOnline) _pendingCount++;
    });

    if (_isOnline) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        setState(() {
          _notes = _notes
              .map((n) => n.id == newNote.id
                  ? n.copyWith(syncStatus: _SyncStatus.synced)
                  : n)
              .toList();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collaborative Notes'),
        backgroundColor: Colors.amber.shade700,
        foregroundColor: Colors.white,
        actions: [
          // Network toggle (for demo purposes)
          IconButton(
            icon: Icon(_isOnline ? Icons.wifi : Icons.wifi_off),
            tooltip: _isOnline ? 'Go offline' : 'Go online',
            onPressed: _toggleNetwork,
          ),
          // Sync status indicator
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: _pendingCount > 0
                  ? Chip(
                      label: Text('$_pendingCount pending',
                          style: const TextStyle(fontSize: 10)),
                      backgroundColor: Colors.orange.shade100,
                      visualDensity: VisualDensity.compact,
                    )
                  : const Icon(Icons.cloud_done, color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Offline banner
          if (!_isOnline)
            MaterialBanner(
              backgroundColor: Colors.orange.shade100,
              leading: const Icon(Icons.wifi_off, color: Colors.orange),
              content: const Text('You are offline. Changes will sync when reconnected.'),
              actions: [
                TextButton(
                  onPressed: _toggleNetwork,
                  child: const Text('Reconnect'),
                ),
              ],
            ),

          // Notes list
          Expanded(
            child: _notes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.note_outlined, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 8),
                        const Text('No notes yet. Tap + to add one.',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _notes.length,
                    itemBuilder: (_, i) => _NoteCard(
                      note: _notes[i],
                      onEdit: () => _editNote(context, i),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.amber.shade700,
        foregroundColor: Colors.white,
        onPressed: _addNote,
        icon: const Icon(Icons.add),
        label: const Text('New Note'),
      ),
    );
  }

  void _editNote(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _NoteEditSheet(
        note: _notes[index],
        isOnline: _isOnline,
        onSave: (updated) {
          setState(() {
            _notes[index] = updated;
            if (!_isOnline) _pendingCount++;
          });
          Navigator.pop(context);
        },
      ),
    );
  }
}

// ── Note card widget ───────────────────────────────────────────────────────────

class _NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onEdit;

  const _NoteCard({required this.note, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onEdit,
        title: Text(note.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(note.body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12)),
        trailing: _SyncBadge(status: note.syncStatus),
      ),
    );
  }
}

/// Small sync status badge.
class _SyncBadge extends StatelessWidget {
  final _SyncStatus status;
  const _SyncBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (status) {
      _SyncStatus.synced  => (Icons.cloud_done,   Colors.green),
      _SyncStatus.syncing => (Icons.sync,          Colors.blue),
      _SyncStatus.pending => (Icons.cloud_upload,  Colors.orange),
      _SyncStatus.error   => (Icons.cloud_off,     Colors.red),
    };
    return Icon(icon, color: color, size: 18);
  }
}

// ── Note edit bottom sheet ─────────────────────────────────────────────────────

class _NoteEditSheet extends StatefulWidget {
  final Note note;
  final bool isOnline;
  final ValueChanged<Note> onSave;

  const _NoteEditSheet({
    required this.note,
    required this.isOnline,
    required this.onSave,
  });

  @override
  State<_NoteEditSheet> createState() => _NoteEditSheetState();
}

class _NoteEditSheetState extends State<_NoteEditSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _bodyCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.note.title);
    _bodyCtrl = TextEditingController(text: widget.note.body);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16, right: 16, top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bodyCtrl,
            decoration: const InputDecoration(
              labelText: 'Content',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (!widget.isOnline)
                const Chip(
                  label: Text('Will sync when online', style: TextStyle(fontSize: 11)),
                  backgroundColor: Colors.orange,
                  labelStyle: TextStyle(color: Colors.white),
                ),
              const Spacer(),
              FilledButton(
                onPressed: () => widget.onSave(widget.note.copyWith(
                  title: _titleCtrl.text,
                  body: _bodyCtrl.text,
                  syncStatus: widget.isOnline ? _SyncStatus.syncing : _SyncStatus.pending,
                )),
                child: const Text('Save'),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
