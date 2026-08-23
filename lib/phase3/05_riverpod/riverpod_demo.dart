/// Demo 05 — Riverpod: Provider, StateNotifier, AsyncNotifier.
///
/// **Concepts covered:**
/// 1. `Provider` → stores a read-only / computed value
/// 2. `StateProvider` → stores a simple mutable value
/// 3. `StateNotifierProvider` → complex state with logic outside the widget
/// 4. `FutureProvider` → async data (API calls, DB queries)
/// 5. `StreamProvider` → real-time data (WebSocket, Firestore)
/// 6. `ConsumerWidget` and `ConsumerStatefulWidget` → how to listen to providers
/// 7. `ref.watch()` vs `ref.read()` vs `ref.listen()`
///
/// **Quick reference:**
/// - `ref.watch(provider)` → subscribe; rebuilds widget when value changes (use in build())
/// - `ref.read(provider)` → get value once without subscribing (use in event handlers)
/// - `ref.listen(provider, callback)` → side effect when value changes
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 1. Provider — read-only / computed value
// ─────────────────────────────────────────────────────────────────────────────

/// Simple Provider — a static value that never changes.
/// Good for: constants, config, service instances.
final greetingProvider = Provider<String>((ref) {
  return 'Welcome to Riverpod!';
});

// ─────────────────────────────────────────────────────────────────────────────
// 2. StateProvider — mutable primitive value
// ─────────────────────────────────────────────────────────────────────────────

/// StateProvider for a simple counter.
/// Good for: toggles, counters, selected indexes.
final counterProvider = StateProvider<int>((ref) => 0);

/// StateProvider for theme mode (dark/light).
final isDarkModeProvider = StateProvider<bool>((ref) => false);

// ─────────────────────────────────────────────────────────────────────────────
// 3. StateNotifierProvider — complex state with logic
// ─────────────────────────────────────────────────────────────────────────────

/// Todo item model.
class TodoItem {
  final String id;
  final String title;
  final bool isDone;

  const TodoItem({required this.id, required this.title, this.isDone = false});

  /// copyWith — the safe way to update an immutable object.
  TodoItem copyWith({String? title, bool? isDone}) {
    return TodoItem(id: id, title: title ?? this.title, isDone: isDone ?? this.isDone);
  }
}

/// StateNotifier for the todo list.
/// Logic lives here, not in the widget — more testable and maintainable.
class TodoNotifier extends StateNotifier<List<TodoItem>> {
  // super([]) = initial state = empty list
  TodoNotifier() : super([]);

  /// Add a new todo.
  void add(String title) {
    // Always create a new list — never mutate the existing one!
    // This is the required immutable pattern for StateNotifier.
    state = [
      ...state,
      TodoItem(id: DateTime.now().millisecondsSinceEpoch.toString(), title: title),
    ];
  }

  /// Toggle the done/undone status.
  void toggle(String id) {
    state = state.map((item) => item.id == id ? item.copyWith(isDone: !item.isDone) : item).toList();
  }

  /// Remove a todo.
  void remove(String id) {
    state = state.where((item) => item.id != id).toList();
  }
}

/// Provider for TodoNotifier.
final todoProvider = StateNotifierProvider<TodoNotifier, List<TodoItem>>((ref) {
  return TodoNotifier();
});

/// Derived provider — computed from todoProvider.
/// Riverpod automatically re-computes when todoProvider changes.
final completedCountProvider = Provider<int>((ref) {
  final todos = ref.watch(todoProvider);
  return todos.where((t) => t.isDone).length;
});

// ─────────────────────────────────────────────────────────────────────────────
// 4. FutureProvider — async data
// ─────────────────────────────────────────────────────────────────────────────

/// FutureProvider that simulates fetching data from an API.
/// The AsyncValue<T> return type automatically handles loading/data/error states.
final weatherProvider = FutureProvider<String>((ref) async {
  // Simulate network delay
  await Future.delayed(const Duration(seconds: 2));

  // Simulate response
  return '⛅ Jakarta: 28°C, Cloudy';
});

// ─────────────────────────────────────────────────────────────────────────────
// 5. StreamProvider — real-time data
// ─────────────────────────────────────────────────────────────────────────────

/// StreamProvider that emits a new value every second.
/// In a real app: Firestore stream, WebSocket, etc.
final tickerProvider = StreamProvider<int>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (i) => i + 1).take(60);
});

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

/// Entry point for the Riverpod demo. ProviderScope is already in main_phase3.dart,
/// but we wrap again here so the demo can run standalone.
class RiverpodDemo extends StatelessWidget {
  const RiverpodDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: Consumer(
        builder: (context, ref, _) {
          final isDark = ref.watch(isDarkModeProvider);
          return MaterialApp(
            title: 'Riverpod Demo',
            debugShowCheckedModeBanner: false,
            theme: isDark ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true),
            home: const _RiverpodMenuScreen(),
          );
        },
      ),
    );
  }
}

/// Menu for selecting a Riverpod demo section.
class _RiverpodMenuScreen extends ConsumerWidget {
  const _RiverpodMenuScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riverpod Demo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Toggle dark mode via StateProvider
          IconButton(
            icon: Icon(ref.watch(isDarkModeProvider) ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => ref.read(isDarkModeProvider.notifier).state =
                !ref.read(isDarkModeProvider),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('1. Provider (read-only)', const _ProviderSection()),
          _section('2. StateProvider (primitive)', const _StateProviderSection()),
          _section('3. StateNotifier (todo list)', const _StateNotifierSection()),
          _section('4. FutureProvider (async)', const _FutureProviderSection()),
          _section('5. StreamProvider (real-time)', const _StreamProviderSection()),
        ],
      ),
    );
  }

  Widget _section(String title, Widget child) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: [Padding(padding: const EdgeInsets.all(12), child: child)],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Provider demo — read-only value.
class _ProviderSection extends ConsumerWidget {
  const _ProviderSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch() → subscribe to provider; widget rebuilds when value changes
    final greeting = ref.watch(greetingProvider);
    return Text('Value from greetingProvider:\n"$greeting"');
  }
}

/// StateProvider demo — counter and toggle.
class _StateProviderSection extends ConsumerWidget {
  const _StateProviderSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);

    return Column(
      children: [
        Text('Counter: $count', style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton(
              // ref.read() in an event handler — doesn't subscribe, just gets the notifier
              onPressed: () => ref.read(counterProvider.notifier).state--,
              child: const Icon(Icons.remove),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: () => ref.read(counterProvider.notifier).state++,
              child: const Icon(Icons.add),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: () => ref.read(counterProvider.notifier).state = 0,
              child: const Text('Reset'),
            ),
          ],
        ),
      ],
    );
  }
}

/// StateNotifier demo — todo list.
class _StateNotifierSection extends ConsumerStatefulWidget {
  const _StateNotifierSection();

  @override
  ConsumerState<_StateNotifierSection> createState() => _StateNotifierSectionState();
}

class _StateNotifierSectionState extends ConsumerState<_StateNotifierSection> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todos = ref.watch(todoProvider);
    final completedCount = ref.watch(completedCountProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add todo input
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'New todo...',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    ref.read(todoProvider.notifier).add(value);
                    _controller.clear();
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  ref.read(todoProvider.notifier).add(_controller.text);
                  _controller.clear();
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('$completedCount/${todos.length} completed'),
        const SizedBox(height: 4),

        // Todo list
        if (todos.isEmpty)
          const Text('No todos yet. Add one above!')
        else
          ...todos.map(
            (todo) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Checkbox(
                value: todo.isDone,
                onChanged: (_) => ref.read(todoProvider.notifier).toggle(todo.id),
              ),
              title: Text(
                todo.title,
                style: TextStyle(
                  decoration: todo.isDone ? TextDecoration.lineThrough : null,
                  color: todo.isDone ? Colors.grey : null,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                onPressed: () => ref.read(todoProvider.notifier).remove(todo.id),
              ),
            ),
          ),
      ],
    );
  }
}

/// FutureProvider demo — loading/data/error state.
class _FutureProviderSection extends ConsumerWidget {
  const _FutureProviderSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // AsyncValue.when() → handles all states at once (loading/data/error)
    final weather = ref.watch(weatherProvider);

    return weather.when(
      loading: () => const Row(
        children: [
          SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
          SizedBox(width: 8),
          Text('Fetching weather data...'),
        ],
      ),
      data: (data) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weather data: $data'),
          const SizedBox(height: 8),
          // refresh → re-fetch the data
          OutlinedButton(
            onPressed: () => ref.refresh(weatherProvider),
            child: const Text('Refresh'),
          ),
        ],
      ),
      error: (err, _) => Text('Error: $err', style: const TextStyle(color: Colors.red)),
    );
  }
}

/// StreamProvider demo — real-time ticker.
class _StreamProviderSection extends ConsumerWidget {
  const _StreamProviderSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticker = ref.watch(tickerProvider);

    return ticker.when(
      loading: () => const Text('Waiting for first tick...'),
      data: (seconds) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tick #$seconds',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text('Stream emits a new value every second.'),
          const Text('Widget rebuilds automatically without setState!'),
        ],
      ),
      error: (err, _) => Text('Error: $err'),
    );
  }
}
