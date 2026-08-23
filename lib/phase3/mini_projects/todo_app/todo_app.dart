/// Mini Project Phase 3 — Multi-screen Todo App.
///
/// **What this project practices:**
/// - GoRouter with multiple screens and named routes
/// - Riverpod StateNotifierProvider for todo state management
/// - Passing data between screens (path param + extra)
/// - Todo filter (all/active/done) via StateProvider
/// - Persistent UI state (filter doesn't reset on navigation)
/// - Form validation
/// - Bottom navigation (2 tabs: Todos & Settings)
///
/// **How to run:**
/// ```bash
/// flutter run -t lib/phase3/mini_projects/todo_app/todo_app.dart
/// ```
///
/// **Architecture:**
/// ```
/// main() → ProviderScope → MaterialApp.router (GoRouter)
///   ├── /         → Shell (BottomNav)
///   │   ├── /todos        → TodoListScreen
///   │   └── /settings     → SettingsScreen
///   └── /todos/:id/edit   → EditTodoScreen (fullscreen, no bottom nav)
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────────────────────────────────────

/// Todo item model — immutable.
class Todo {
  final String id;
  final String title;
  final String note;
  final bool isDone;
  final DateTime createdAt;

  const Todo({
    required this.id,
    required this.title,
    this.note = '',
    this.isDone = false,
    required this.createdAt,
  });

  Todo copyWith({String? title, String? note, bool? isDone}) {
    return Todo(
      id: id,
      title: title ?? this.title,
      note: note ?? this.note,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Enum for display filter.
enum TodoFilter { all, active, done }

/// Filter provider — global because it's used in the list and in settings.
final todoFilterProvider = StateProvider<TodoFilter>((ref) => TodoFilter.all);

/// Username provider (used in settings and the header greeting).
final usernameProvider = StateProvider<String>((ref) => 'Faisal');

/// StateNotifier for the todo list.
class TodoListNotifier extends StateNotifier<List<Todo>> {
  TodoListNotifier()
      : super([
          // Seed data so there's content when the app first opens
          Todo(
            id: '1',
            title: 'Learn GoRouter',
            note: 'Focus on named routes and passing data',
            isDone: true,
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
          Todo(
            id: '2',
            title: 'Learn Riverpod',
            note: 'StateNotifier, FutureProvider, StreamProvider',
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
          Todo(
            id: '3',
            title: 'Build a mini project',
            createdAt: DateTime.now(),
          ),
        ]);

  /// Add a new todo.
  void add({required String title, String note = ''}) {
    state = [
      ...state,
      Todo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        note: note,
        createdAt: DateTime.now(),
      ),
    ];
  }

  /// Update an existing todo.
  void update(String id, {required String title, String note = ''}) {
    state = state
        .map((t) => t.id == id ? t.copyWith(title: title, note: note) : t)
        .toList();
  }

  /// Toggle the done status.
  void toggle(String id) {
    state = state
        .map((t) => t.id == id ? t.copyWith(isDone: !t.isDone) : t)
        .toList();
  }

  /// Remove a todo.
  void remove(String id) {
    state = state.where((t) => t.id != id).toList();
  }

  /// Remove all completed todos.
  void clearCompleted() {
    state = state.where((t) => !t.isDone).toList();
  }
}

final todoListProvider =
    StateNotifierProvider<TodoListNotifier, List<Todo>>((ref) {
  return TodoListNotifier();
});

/// Derived provider — the filtered todo list.
final filteredTodosProvider = Provider<List<Todo>>((ref) {
  final todos = ref.watch(todoListProvider);
  final filter = ref.watch(todoFilterProvider);

  return switch (filter) {
    TodoFilter.all => todos,
    TodoFilter.active => todos.where((t) => !t.isDone).toList(),
    TodoFilter.done => todos.where((t) => t.isDone).toList(),
  };
});

/// Summary stats provider.
final todoStatsProvider = Provider<({int total, int done, int active})>((ref) {
  final todos = ref.watch(todoListProvider);
  final done = todos.where((t) => t.isDone).length;
  return (total: todos.length, done: done, active: todos.length - done);
});

// ─────────────────────────────────────────────────────────────────────────────
// Router
// ─────────────────────────────────────────────────────────────────────────────

final _router = GoRouter(
  initialLocation: '/todos',
  routes: [
    // Shell route for bottom navigation (tabs: Todos + Settings)
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => _AppShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/todos',
              name: 'todos',
              builder: (context, state) => const TodoListScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              name: 'settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
    // Edit screen — fullscreen (no bottom nav)
    GoRoute(
      path: '/todos/:id/edit',
      name: 'edit-todo',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final todo = state.extra as Todo?;
        return EditTodoScreen(todoId: id, todo: todo);
      },
    ),
    // New todo screen
    GoRoute(
      path: '/todos/new',
      name: 'new-todo',
      builder: (context, state) => const EditTodoScreen(todoId: null, todo: null),
    ),
  ],
);

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  runApp(const ProviderScope(child: TodoApp()));
}

class TodoApp extends ConsumerWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Todo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shell (wrapper with bottom navigation bar)
// ─────────────────────────────────────────────────────────────────────────────

class _AppShell extends ConsumerWidget {
  final StatefulNavigationShell shell;
  const _AppShell({required this.shell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(todoStatsProvider);

    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: [
          NavigationDestination(
            icon: Badge(
              isLabelVisible: stats.active > 0,
              label: Text('${stats.active}'),
              child: const Icon(Icons.checklist_outlined),
            ),
            selectedIcon: const Icon(Icons.checklist),
            label: 'Todos',
          ),
          const NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TodoListScreen
// ─────────────────────────────────────────────────────────────────────────────

/// Main screen — todo list with filter chips.
class TodoListScreen extends ConsumerWidget {
  const TodoListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(filteredTodosProvider);
    final filter = ref.watch(todoFilterProvider);
    final stats = ref.watch(todoStatsProvider);
    final username = ref.watch(usernameProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello, $username 👋'),
            Text(
              '${stats.done}/${stats.total} completed',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        // Filter chips at the bottom of the AppBar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: TodoFilter.values.map((f) {
                final label = switch (f) {
                  TodoFilter.all => 'All (${stats.total})',
                  TodoFilter.active => 'Active (${stats.active})',
                  TodoFilter.done => 'Done (${stats.done})',
                };
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(label),
                    selected: filter == f,
                    onSelected: (_) =>
                        ref.read(todoFilterProvider.notifier).state = f,
                    selectedColor: Colors.blue.shade100,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),

      body: todos.isEmpty
          ? _EmptyState(filter: filter)
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: todos.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
              itemBuilder: (context, index) {
                final todo = todos[index];
                return _TodoTile(todo: todo);
              },
            ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/todos/new'),
        icon: const Icon(Icons.add),
        label: const Text('New Todo'),
      ),
    );
  }
}

/// Tile for a single todo item.
class _TodoTile extends ConsumerWidget {
  final Todo todo;
  const _TodoTile({required this.todo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => ref.read(todoListProvider.notifier).remove(todo.id),
      child: ListTile(
        leading: Checkbox(
          value: todo.isDone,
          onChanged: (_) =>
              ref.read(todoListProvider.notifier).toggle(todo.id),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isDone ? TextDecoration.lineThrough : null,
            color: todo.isDone ? Colors.grey : null,
          ),
        ),
        subtitle: todo.note.isNotEmpty
            ? Text(todo.note, maxLines: 1, overflow: TextOverflow.ellipsis)
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.edit_outlined),
          // Pass the todo object via extra to avoid re-fetching
          onPressed: () => context.push('/todos/${todo.id}/edit', extra: todo),
        ),
      ),
    );
  }
}

/// Empty state widget when no todos match the current filter.
class _EmptyState extends StatelessWidget {
  final TodoFilter filter;
  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    final message = switch (filter) {
      TodoFilter.all => 'No todos yet.\nTap + to add one!',
      TodoFilter.active => 'All todos are done! 🎉',
      TodoFilter.done => 'No completed todos yet.',
    };

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.checklist, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EditTodoScreen
// ─────────────────────────────────────────────────────────────────────────────

/// Screen for adding a new todo or editing an existing one.
/// Handles two scenarios: new (todoId = null) and edit (todoId provided).
class EditTodoScreen extends ConsumerStatefulWidget {
  final String? todoId;
  final Todo? todo;

  const EditTodoScreen({required this.todoId, required this.todo, super.key});

  @override
  ConsumerState<EditTodoScreen> createState() => _EditTodoScreenState();
}

class _EditTodoScreenState extends ConsumerState<EditTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _noteCtrl;

  bool get _isEditing => widget.todoId != null;

  @override
  void initState() {
    super.initState();
    // Pre-fill the form when in edit mode
    _titleCtrl = TextEditingController(text: widget.todo?.title ?? '');
    _noteCtrl = TextEditingController(text: widget.todo?.note ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    if (_isEditing) {
      ref.read(todoListProvider.notifier).update(
            widget.todoId!,
            title: _titleCtrl.text.trim(),
            note: _noteCtrl.text.trim(),
          );
    } else {
      ref.read(todoListProvider.notifier).add(
            title: _titleCtrl.text.trim(),
            note: _noteCtrl.text.trim(),
          );
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Todo' : 'New Todo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'What needs to be done?',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Title cannot be empty' : null,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteCtrl,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                hintText: 'Additional details...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: Text(_isEditing ? 'Save Changes' : 'Add Todo'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SettingsScreen
// ─────────────────────────────────────────────────────────────────────────────

/// Settings screen — change username and clear completed todos.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: ref.read(usernameProvider));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(todoStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Change name
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () {
                          if (_nameCtrl.text.trim().isNotEmpty) {
                            ref.read(usernameProvider.notifier).state =
                                _nameCtrl.text.trim();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Name updated!')),
                            );
                          }
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Stats
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Statistics', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _statRow('Total Todos', '${stats.total}'),
                  _statRow('Completed', '${stats.done}'),
                  _statRow('Active', '${stats.active}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Clear completed
          Card(
            child: ListTile(
              leading: const Icon(Icons.delete_sweep, color: Colors.red),
              title: const Text('Clear Completed Todos'),
              subtitle: Text('${stats.done} todos will be removed'),
              enabled: stats.done > 0,
              onTap: stats.done == 0
                  ? null
                  : () {
                      final count = stats.done;
                      ref.read(todoListProvider.notifier).clearCompleted();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$count completed todos removed.'),
                        ),
                      );
                    },
            ),
          ),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
