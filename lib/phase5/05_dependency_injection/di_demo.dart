/// Demo 05 — Dependency Injection with get_it.
///
/// Dependency Injection (DI) is the practice of providing dependencies to a class
/// FROM OUTSIDE rather than letting the class create them internally.
///
/// We already practiced DI manually in Demos 02–04 (constructor injection).
/// get_it is a SERVICE LOCATOR that acts as a global registry for your dependencies.
/// Instead of manually passing every dependency through constructors across 5 layers,
/// you register them once and look them up anywhere.
///
/// **Three DI approaches in Flutter:**
/// 1. **Manual (constructor)** — most explicit, good for small apps
/// 2. **get_it service locator** — simple global registry, no code gen needed
/// 3. **Riverpod providers** — reactive DI built into the state management system
///
/// **get_it registration types:**
/// - `registerFactory<T>()` — creates a NEW instance every time `get<T>()` is called
/// - `registerSingleton<T>()` — creates ONE instance immediately, reused forever
/// - `registerLazySingleton<T>()` — creates ONE instance on first access, then reuses
///
/// **When to use which:**
/// - Factory → ViewModels (each screen gets a fresh instance)
/// - Singleton → Services, repositories (shared state across the app)
/// - LazySingleton → Services that are expensive to create (Dio, Hive)
///
/// How to run: `flutter run -t lib/phase5/05_dependency_injection/di_demo.dart`
library;

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Dependencies to register
// ─────────────────────────────────────────────────────────────────────────────

/// A simple logger service — one instance should be shared across the app.
/// Perfect for a singleton.
class LoggerService {
  final List<String> _logs = [];

  void log(String message) {
    final entry = '[${DateTime.now().toString().substring(11, 19)}] $message';
    _logs.add(entry);
    debugPrint(entry);
  }

  List<String> get logs => List.unmodifiable(_logs);
  void clear() => _logs.clear();
}

/// An analytics service — also a singleton (one tracker per app session).
class AnalyticsService {
  final LoggerService _logger;

  /// Takes a [LoggerService] as a constructor argument — DI at work.
  /// get_it resolves this automatically when registering.
  AnalyticsService(this._logger);

  void track(String event, [Map<String, String>? params]) {
    final paramStr = params?.entries.map((e) => '${e.key}=${e.value}').join(', ') ?? '';
    _logger.log('📊 Analytics: $event${paramStr.isNotEmpty ? " ($paramStr)" : ""}');
  }
}

/// Repository with a fake database.
/// Singleton — one shared data store for the app.
class NoteRepository {
  final LoggerService _logger;
  final List<String> _notes = ['First note', 'Second note'];

  NoteRepository(this._logger);

  List<String> getAll() {
    _logger.log('📂 Repository: fetching ${_notes.length} notes');
    return List.unmodifiable(_notes);
  }

  void add(String note) {
    _notes.add(note);
    _logger.log('📂 Repository: added "$note"');
  }

  void delete(int index) {
    final deleted = _notes.removeAt(index);
    _logger.log('📂 Repository: deleted "$deleted"');
  }
}

/// ViewModel — created fresh per screen (factory registration).
///
/// Each time a screen navigates to the notes screen, it gets a FRESH ViewModel.
/// But the underlying [NoteRepository] and [LoggerService] are shared singletons.
class NoteViewModel extends ChangeNotifier {
  final NoteRepository _repository;
  final AnalyticsService _analytics;

  NoteViewModel(this._repository, this._analytics);

  List<String> get notes => _repository.getAll();

  void addNote(String note) {
    if (note.trim().isEmpty) return;
    _repository.add(note.trim());
    _analytics.track('note_added', {'length': note.length.toString()});
    notifyListeners();
  }

  void deleteNote(int index) {
    _repository.delete(index);
    _analytics.track('note_deleted');
    notifyListeners();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Service Locator setup (the get_it container)
// ─────────────────────────────────────────────────────────────────────────────

/// The global service locator instance.
///
/// In a real app this lives in a separate `injection_container.dart` file.
/// Convention: name it `sl` (service locator) or `getIt`.
final GetIt sl = GetIt.instance;

/// Registers all dependencies in the correct order.
///
/// CRITICAL: Register dependencies BEFORE registering things that depend on them.
/// get_it will throw if you try to resolve something that isn't registered yet.
///
/// Call this ONCE at app startup in `main()` before `runApp()`.
void setupDependencies() {
  // 1. Register leaf dependencies first (things with no dependencies)
  //    registerLazySingleton → created on first access, then reused
  sl.registerLazySingleton<LoggerService>(() => LoggerService());

  // 2. Register things that depend on leaf dependencies
  sl.registerLazySingleton<AnalyticsService>(
    () => AnalyticsService(sl<LoggerService>()), // sl<T>() resolves a registered type
  );

  sl.registerLazySingleton<NoteRepository>(
    () => NoteRepository(sl<LoggerService>()),
  );

  // 3. Register ViewModels as factories — new instance per use
  //    registerFactory → a NEW NoteViewModel every time you call sl<NoteViewModel>()
  sl.registerFactory<NoteViewModel>(
    () => NoteViewModel(
      sl<NoteRepository>(),    // resolves the shared singleton
      sl<AnalyticsService>(),  // resolves the shared singleton
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  // Register all dependencies before the UI starts
  setupDependencies();
  runApp(const DiDemoApp());
}

class DiDemoApp extends StatelessWidget {
  const DiDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DI with get_it Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const _DiDemoScreen(),
    );
  }
}

class _DiDemoScreen extends StatelessWidget {
  const _DiDemoScreen();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('DI with get_it'),
          backgroundColor: Colors.green,
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
              Tab(icon: Icon(Icons.note), text: 'Notes'),
              Tab(icon: Icon(Icons.list_alt), text: 'Logs'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _NotesTab(),
            _LogsTab(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notes tab
// ─────────────────────────────────────────────────────────────────────────────

class _NotesTab extends StatefulWidget {
  const _NotesTab();

  @override
  State<_NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends State<_NotesTab> {
  // sl<NoteViewModel>() — get_it resolves all dependencies automatically.
  // This creates a FRESH ViewModel instance (factory registration).
  // But the underlying Repository and Logger are shared singletons.
  late final NoteViewModel _vm = sl<NoteViewModel>();
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vm.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _vm.dispose(); // dispose the ChangeNotifier
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.green.shade50,
          child: const Text(
            '💡 Each time this tab is rebuilt, sl<NoteViewModel>() creates a FRESH '
            'ViewModel (factory). But the Repository & Logger are SHARED singletons — '
            'check the Logs tab to see all operations.',
            style: TextStyle(fontSize: 11),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
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
                  onSubmitted: (v) {
                    _vm.addNote(v);
                    _ctrl.clear();
                  },
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {
                  _vm.addNote(_ctrl.text);
                  _ctrl.clear();
                },
                child: const Text('Add'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _vm.notes.length,
            itemBuilder: (context, index) => Card(
              child: ListTile(
                title: Text(_vm.notes[index]),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _vm.deleteNote(index),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Logs tab
// ─────────────────────────────────────────────────────────────────────────────

/// Shows the shared LoggerService output.
///
/// The LoggerService is a SINGLETON — the same instance that NoteRepository
/// and AnalyticsService use. This tab reads from that shared instance.
class _LogsTab extends StatefulWidget {
  const _LogsTab();

  @override
  State<_LogsTab> createState() => _LogsTabState();
}

class _LogsTabState extends State<_LogsTab> {
  // Same singleton instance — shared across the entire app
  final _logger = sl<LoggerService>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.green.shade50,
          child: const Text(
            'These logs come from the shared LoggerService singleton. '
            'Repository and Analytics both use the same instance.',
            style: TextStyle(fontSize: 11),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Text('${_logger.logs.length} log entries',
                  style: const TextStyle(color: Colors.grey)),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () {
                  _logger.clear();
                  setState(() {});
                },
                icon: const Icon(Icons.clear_all, size: 18),
                label: const Text('Clear'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _logger.logs.isEmpty
              ? const Center(
                  child: Text('No logs yet — add or delete a note.',
                      style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _logger.logs.length,
                  // Reverse — newest first
                  itemBuilder: (context, index) {
                    final reversedIndex = _logger.logs.length - 1 - index;
                    final log = _logger.logs[reversedIndex];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        log,
                        style: const TextStyle(
                            fontFamily: 'monospace', fontSize: 12),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
