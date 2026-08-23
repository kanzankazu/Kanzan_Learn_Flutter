/// Demo 07 — BLoC (Business Logic Component).
///
/// **Concepts covered:**
/// 1. BLoC architecture: Event → Bloc → State → UI
/// 2. `Bloc<Event, State>` — for complex logic with many events
/// 3. `Cubit<State>` — simplified BLoC without event classes
/// 4. `BlocProvider` — provides a Bloc to the widget tree
/// 5. `BlocBuilder` — rebuilds widget when state changes
/// 6. `BlocListener` — side effects (snackbar, navigation) on state change
/// 7. `BlocConsumer` — combines Builder + Listener
/// 8. `MultiBlocProvider` — provides multiple Blocs at once
///
/// **BLoC vs Riverpod (summary):**
/// - BLoC: UI → add(Event) → Bloc → emit(State) → UI (event-driven, strict)
/// - Riverpod: UI → ref.read(notifier).method() → state → UI (direct, flexible)
///
/// **When to use BLoC:**
/// - Large teams that need an audit trail of all state changes
/// - Complex state with many transitions (wizards, onboarding)
/// - Enterprise / fintech that requires high predictability
///
/// **How to run:**
/// ```bash
/// flutter run -t lib/phase3/07_bloc/bloc_demo.dart
/// ```
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 1. CUBIT — simplified BLoC (without event classes)
//
// Cubit is suitable for simple state. No need to define event classes —
// call methods on the Cubit directly from the UI.
// ─────────────────────────────────────────────────────────────────────────────

/// Counter Cubit. Simplest possible — no events needed.
/// Compare with Riverpod: similar to StateNotifier but uses emit().
class CounterCubit extends Cubit<int> {
  // super(0) = initial state
  CounterCubit() : super(0);

  void increment() => emit(state + 1); // emit() = how to update state in BLoC/Cubit
  void decrement() => emit(state - 1);
  void reset() => emit(0);
}

/// Theme mode Cubit.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light);

  void toggle() => emit(
        state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. BLOC — full event-driven pattern
//
// BLoC is suitable for complex state. Every state change MUST go through an event.
// This makes the flow more predictable and easier to debug / test.
// ─────────────────────────────────────────────────────────────────────────────

// ── Events ───────────────────────────────────────────────────────────────────

/// Base class for all TodoBloc events.
/// `sealed` = the compiler knows all subclasses → exhaustive switch is possible.
sealed class TodoEvent {}

/// Event: add a new todo.
final class TodoAdded extends TodoEvent {
  final String title;
  TodoAdded(this.title);
}

/// Event: toggle the done status.
final class TodoToggled extends TodoEvent {
  final String id;
  TodoToggled(this.id);
}

/// Event: remove a todo.
final class TodoRemoved extends TodoEvent {
  final String id;
  TodoRemoved(this.id);
}

/// Event: change the display filter.
final class TodoFilterChanged extends TodoEvent {
  final TodoFilter filter;
  TodoFilterChanged(this.filter);
}

/// Event: load initial data (simulated from "database").
final class TodosLoaded extends TodoEvent {}

// ── State ─────────────────────────────────────────────────────────────────────

/// Filter enum.
enum TodoFilter { all, active, done }

/// Todo model — immutable.
class TodoItem {
  final String id;
  final String title;
  final bool isDone;

  const TodoItem({required this.id, required this.title, this.isDone = false});

  TodoItem copyWith({bool? isDone}) =>
      TodoItem(id: id, title: title, isDone: isDone ?? this.isDone);
}

/// State for TodoBloc.
/// In BLoC pattern, state should be immutable and have a copyWith method.
class TodoState {
  final List<TodoItem> todos;
  final TodoFilter filter;
  final bool isLoading;

  const TodoState({
    this.todos = const [],
    this.filter = TodoFilter.all,
    this.isLoading = false,
  });

  /// copyWith — the safe way to update immutable state.
  TodoState copyWith({
    List<TodoItem>? todos,
    TodoFilter? filter,
    bool? isLoading,
  }) {
    return TodoState(
      todos: todos ?? this.todos,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Derived getter — filtered todos based on current filter.
  List<TodoItem> get filteredTodos => switch (filter) {
        TodoFilter.all => todos,
        TodoFilter.active => todos.where((t) => !t.isDone).toList(),
        TodoFilter.done => todos.where((t) => t.isDone).toList(),
      };

  int get completedCount => todos.where((t) => t.isDone).length;
}

// ── Bloc ──────────────────────────────────────────────────────────────────────

/// TodoBloc — the core of the todo feature.
///
/// Event registration pattern:
/// ```dart
/// on<EventType>((event, emit) { ... });
/// ```
/// Each event type gets one handler.
/// emit() → updates the state, triggers rebuild in BlocBuilder.
class TodoBloc extends Bloc<TodoEvent, TodoState> {
  TodoBloc() : super(const TodoState()) {
    // Register a handler for each event
    on<TodosLoaded>(_onTodosLoaded);
    on<TodoAdded>(_onTodoAdded);
    on<TodoToggled>(_onTodoToggled);
    on<TodoRemoved>(_onTodoRemoved);
    on<TodoFilterChanged>(_onFilterChanged);
  }

  /// Load initial data — simulates an async fetch from DB/API.
  Future<void> _onTodosLoaded(
    TodosLoaded event,
    Emitter<TodoState> emit,
  ) async {
    // Emit loading state first
    emit(state.copyWith(isLoading: true));

    // Simulate network/DB delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Emit data after loading
    emit(
      state.copyWith(
        isLoading: false,
        todos: [
          TodoItem(id: '1', title: 'Learn BLoC pattern', isDone: true),
          TodoItem(id: '2', title: 'Compare BLoC vs Riverpod'),
          TodoItem(id: '3', title: 'Build a mini project'),
        ],
      ),
    );
  }

  void _onTodoAdded(TodoAdded event, Emitter<TodoState> emit) {
    final newTodo = TodoItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: event.title,
    );
    emit(state.copyWith(todos: [...state.todos, newTodo]));
  }

  void _onTodoToggled(TodoToggled event, Emitter<TodoState> emit) {
    final updated = state.todos
        .map((t) => t.id == event.id ? t.copyWith(isDone: !t.isDone) : t)
        .toList();
    emit(state.copyWith(todos: updated));
  }

  void _onTodoRemoved(TodoRemoved event, Emitter<TodoState> emit) {
    emit(
      state.copyWith(
        todos: state.todos.where((t) => t.id != event.id).toList(),
      ),
    );
  }

  void _onFilterChanged(TodoFilterChanged event, Emitter<TodoState> emit) {
    emit(state.copyWith(filter: event.filter));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. BlocObserver — global logger for all events & state changes
//
// Very useful for debugging during development.
// In a real app, you could send logs to Crashlytics/Analytics.
// ─────────────────────────────────────────────────────────────────────────────

class AppBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    debugPrint('[BLoC] ${bloc.runtimeType} → event: ${event.runtimeType}');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    debugPrint('[BLoC] ${bloc.runtimeType} → state: ${transition.nextState.runtimeType}');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    debugPrint('[BLoC] ${bloc.runtimeType} → error: $error');
    super.onError(bloc, error, stackTrace);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  // Register the global BlocObserver — logs all events to the console
  Bloc.observer = AppBlocObserver();

  runApp(const BlocDemoApp());
}

class BlocDemoApp extends StatelessWidget {
  const BlocDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiBlocProvider — provides all Blocs at the root of the app.
    // Similar to ProviderScope in Riverpod.
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => CounterCubit()),
        BlocProvider(
          // Immediately trigger load when the Bloc is created
          create: (_) => TodoBloc()..add(TodosLoaded()),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'BLoC Demo',
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
              useMaterial3: true,
            ),
            darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.indigo,
                brightness: Brightness.dark,
              ),
            ),
            home: const _BlocMenuScreen(),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Menu screen
// ─────────────────────────────────────────────────────────────────────────────

class _BlocMenuScreen extends StatelessWidget {
  const _BlocMenuScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BLoC Demo'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Toggle dark mode via ThemeCubit
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, mode) => IconButton(
              icon: Icon(mode == ThemeMode.light ? Icons.dark_mode : Icons.light_mode),
              onPressed: () => context.read<ThemeCubit>().toggle(),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card('1. Cubit (simple counter)', const _CubitCounterSection()),
          _card('2. BlocBuilder (todo list)', const _BlocBuilderSection()),
          _card('3. BlocListener (side effects)', const _BlocListenerSection()),
          _card('4. BlocConsumer (builder + listener)', const _BlocConsumerSection()),
          _card('5. BLoC vs Riverpod comparison', const _ComparisonSection()),
        ],
      ),
    );
  }

  Widget _card(String title, Widget child) {
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
// Section 1 — Cubit (counter)
// ─────────────────────────────────────────────────────────────────────────────

class _CubitCounterSection extends StatelessWidget {
  const _CubitCounterSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Cubit = BLoC without event classes.\n'
          'Call methods directly, just like Riverpod StateNotifier.',
        ),
        const SizedBox(height: 12),
        // BlocBuilder<CubitType, StateType> → rebuilds when state changes
        BlocBuilder<CounterCubit, int>(
          builder: (context, count) {
            return Column(
              children: [
                Text(
                  '$count',
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // context.read<T>() = get Bloc/Cubit without subscribing
                    // Same as ref.read() in Riverpod
                    FilledButton(
                      onPressed: () => context.read<CounterCubit>().decrement(),
                      child: const Icon(Icons.remove),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: () => context.read<CounterCubit>().increment(),
                      child: const Icon(Icons.add),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () => context.read<CounterCubit>().reset(),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        const Text(
          '💡 Check the console — BlocObserver logs every state change!',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section 2 — BlocBuilder (todo list)
// ─────────────────────────────────────────────────────────────────────────────

class _BlocBuilderSection extends StatefulWidget {
  const _BlocBuilderSection();

  @override
  State<_BlocBuilderSection> createState() => _BlocBuilderSectionState();
}

class _BlocBuilderSectionState extends State<_BlocBuilderSection> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // BlocBuilder<BlocType, StateType>
    // buildWhen: optional — only rebuild when condition is met (optimization)
    return BlocBuilder<TodoBloc, TodoState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Row(
            children: [
              SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
              SizedBox(width: 8),
              Text('Loading todos...'),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter chips
            Wrap(
              spacing: 6,
              children: TodoFilter.values.map((f) {
                final label = switch (f) {
                  TodoFilter.all => 'All',
                  TodoFilter.active => 'Active',
                  TodoFilter.done => 'Done',
                };
                return FilterChip(
                  label: Text(label),
                  selected: state.filter == f,
                  // add(Event) = how to send an event to the BLoC
                  // Same as ref.read(notifier).method() in Riverpod
                  onSelected: (_) => context.read<TodoBloc>().add(TodoFilterChanged(f)),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),

            // Add todo input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: const InputDecoration(
                      hintText: 'New todo...',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (v) {
                      if (v.isNotEmpty) {
                        context.read<TodoBloc>().add(TodoAdded(v));
                        _ctrl.clear();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    if (_ctrl.text.isNotEmpty) {
                      context.read<TodoBloc>().add(TodoAdded(_ctrl.text));
                      _ctrl.clear();
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('${state.completedCount}/${state.todos.length} completed'),
            const SizedBox(height: 8),

            // Todo list
            if (state.filteredTodos.isEmpty)
              const Text('No todos.', style: TextStyle(color: Colors.grey))
            else
              ...state.filteredTodos.map(
                (todo) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Checkbox(
                    value: todo.isDone,
                    onChanged: (_) =>
                        context.read<TodoBloc>().add(TodoToggled(todo.id)),
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
                    onPressed: () =>
                        context.read<TodoBloc>().add(TodoRemoved(todo.id)),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section 3 — BlocListener (side effects)
// ─────────────────────────────────────────────────────────────────────────────

/// BlocListener — does NOT rebuild UI. Only runs side effects.
/// Examples: show a SnackBar, navigate, vibrate, play a sound.
///
/// The key difference from BlocBuilder:
/// - BlocBuilder → for updating UI
/// - BlocListener → for side effects (runs once, not a rebuild)
class _BlocListenerSection extends StatelessWidget {
  const _BlocListenerSection();

  @override
  Widget build(BuildContext context) {
    return BlocListener<CounterCubit, int>(
      // listenWhen: optional — only trigger the listener when condition is met
      listenWhen: (prev, curr) => curr != 0 && curr % 5 == 0,
      listener: (context, count) {
        // Side effect — show a SnackBar every multiple of 5
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 Counter reached $count!'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'BlocListener does not rebuild the UI.\n'
            'It only runs a side effect when state changes.\n\n'
            '👇 Tap + until you reach a multiple of 5 — watch the SnackBar appear.',
          ),
          const SizedBox(height: 12),
          BlocBuilder<CounterCubit, int>(
            builder: (context, count) => Row(
              children: [
                Text('Counter: $count', style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: () => context.read<CounterCubit>().increment(),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section 4 — BlocConsumer (Builder + Listener combined)
// ─────────────────────────────────────────────────────────────────────────────

/// BlocConsumer = BlocBuilder + BlocListener in one widget.
/// Use when you need both a UI rebuild AND a side effect from the same state.
class _BlocConsumerSection extends StatelessWidget {
  const _BlocConsumerSection();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CounterCubit, int>(
      // listenWhen & buildWhen can be controlled independently
      listenWhen: (prev, curr) => curr < 0,
      listener: (context, count) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Counter should not be negative!'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 1),
          ),
        );
      },
      builder: (context, count) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'BlocConsumer = BlocBuilder + BlocListener.\n'
              'Try pressing - until the counter goes negative → see the warning SnackBar.',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: count < 0 ? Colors.red : null,
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: () => context.read<CounterCubit>().decrement(),
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => context.read<CounterCubit>().increment(),
                  child: const Icon(Icons.add),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => context.read<CounterCubit>().reset(),
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section 5 — BLoC vs Riverpod comparison
// ─────────────────────────────────────────────────────────────────────────────

class _ComparisonSection extends StatelessWidget {
  const _ComparisonSection();

  @override
  Widget build(BuildContext context) {
    const rows = [
      ['Boilerplate', 'High (event+state+bloc)', 'Low (notifier+provider)'],
      ['How to update state', 'add(Event)', 'ref.read(n).method()'],
      ['Rebuild widget', 'BlocBuilder', 'ref.watch()'],
      ['Side effect', 'BlocListener', 'ref.listen()'],
      ['Async (API)', 'emit() in handler', 'FutureProvider'],
      ['Global logger', 'BlocObserver ✅', 'Riverpod DevTools'],
      ['Testing', 'blocTest() helper', 'ProviderContainer'],
      ['Large teams', '✅ Better fit', '✅ Works'],
      ['Solo / startup', '⚠️ Verbose', '✅ More efficient'],
    ];

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2.5),
        1: FlexColumnWidth(2.5),
        2: FlexColumnWidth(2.5),
      },
      border: TableBorder.all(color: Colors.grey.shade300),
      children: [
        // Header
        TableRow(
          decoration: BoxDecoration(color: Colors.indigo.shade50),
          children: ['Aspect', 'BLoC', 'Riverpod'].map((h) => Padding(
            padding: const EdgeInsets.all(6),
            child: Text(h, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          )).toList(),
        ),
        ...rows.map(
          (row) => TableRow(
            children: row.map((cell) => Padding(
              padding: const EdgeInsets.all(6),
              child: Text(cell, style: const TextStyle(fontSize: 11)),
            )).toList(),
          ),
        ),
      ],
    );
  }
}
