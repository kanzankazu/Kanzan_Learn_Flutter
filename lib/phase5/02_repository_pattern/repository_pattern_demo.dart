/// Demo 02 — Repository Pattern.
///
/// The Repository Pattern separates data access logic from business logic.
/// Instead of your ViewModel/Presenter calling `dio.get(...)` or `db.query(...)`
/// directly, it calls `repository.getUsers()` — a clean, testable abstraction.
///
/// **The pattern has three parts:**
/// 1. **Abstract repository** (interface) — defines WHAT operations are available.
///    Lives in the **domain** layer.
/// 2. **Concrete repositories** (implementations) — define HOW data is fetched.
///    Lives in the **data** layer. One per data source (API, local DB, cache).
/// 3. **Consumer** (ViewModel/UseCase) — depends only on the abstract repository.
///    Never imports a specific implementation.
///
/// **Why is this valuable?**
/// - Swap API → Firebase without touching the UI or business logic
/// - Use a mock repository in tests (no real network calls needed)
/// - Add caching: repository tries cache first, falls back to API
/// - Multiple data sources (offline + online) in one place
///
/// **Repository vs Service:**
/// Repository = data access abstraction (get/save/delete entities).
/// Service = business operations (sendPasswordResetEmail, calculateDiscount).
///
/// How to run: `flutter run -t lib/phase5/02_repository_pattern/repository_pattern_demo.dart`
library;

import 'dart:async';

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Domain layer — entities and abstract repository
// ─────────────────────────────────────────────────────────────────────────────

/// A domain entity — a plain Dart object with no framework dependencies.
/// This is the model your business logic works with.
/// It should NOT contain JSON parsing, DB column names, or API field names
/// — those details belong in the data layer.
class User {
  final int id;
  final String name;
  final String email;
  final String role; // 'admin' | 'user'

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  @override
  String toString() => 'User($id, $name, $email, $role)';
}

/// Abstract repository — the contract that all data sources must fulfill.
///
/// This interface lives in the DOMAIN layer. It describes what the app
/// needs from a data source, without specifying WHERE the data comes from.
///
/// The key benefit: anything that wants users (ViewModel, UseCase, test)
/// only depends on this interface — not on Dio, SQLite, Firebase, or anything else.
abstract class UserRepository {
  /// Returns all users. May throw on network/database failure.
  Future<List<User>> getAll();

  /// Returns a single user by ID. Returns null if not found.
  Future<User?> getById(int id);

  /// Saves a user (insert or update). Returns the saved entity.
  Future<User> save(User user);

  /// Removes a user by ID.
  Future<void> delete(int id);
}

// ─────────────────────────────────────────────────────────────────────────────
// Data layer — concrete implementations
// ─────────────────────────────────────────────────────────────────────────────

/// In-memory repository — perfect for demos, prototypes, and unit tests.
///
/// Uses a simple Map<int, User> as the "database".
/// No network calls, no file I/O — instant and reliable.
///
/// In a real app, you'd have:
/// - [ApiUserRepository] → fetches from a REST API via Dio
/// - [HiveUserRepository] → stores in local Hive boxes
/// - [FirebaseUserRepository] → reads/writes Firestore documents
/// All three implement [UserRepository] — the ViewModel doesn't care which one.
class InMemoryUserRepository implements UserRepository {
  /// Internal store — a Map with user ID as key.
  final Map<int, User> _store = {
    1: const User(id: 1, name: 'Alice Johnson', email: 'alice@example.com', role: 'admin'),
    2: const User(id: 2, name: 'Bob Smith', email: 'bob@example.com', role: 'user'),
    3: const User(id: 3, name: 'Carol White', email: 'carol@example.com', role: 'user'),
  };

  int _nextId = 4; // auto-increment counter for new users

  @override
  Future<List<User>> getAll() async {
    // Simulate async behavior — real repositories are always async
    await Future.delayed(const Duration(milliseconds: 300));
    return _store.values.toList();
  }

  @override
  Future<User?> getById(int id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _store[id]; // returns null if not found — safe, no throw
  }

  @override
  Future<User> save(User user) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final toSave = user.id == 0
        ? User(id: _nextId++, name: user.name, email: user.email, role: user.role)
        : user;
    _store[toSave.id] = toSave;
    return toSave;
  }

  @override
  Future<void> delete(int id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _store.remove(id);
  }
}

/// Simulated "slow API" repository — demonstrates the same interface
/// but with longer delays to mimic real network latency.
///
/// Swap this in for [InMemoryUserRepository] and the UI behaves identically —
/// just slower. The ViewModel doesn't know or care.
class SlowApiUserRepository implements UserRepository {
  final Map<int, User> _data = {
    1: const User(id: 1, name: 'Alice (from API)', email: 'alice@api.com', role: 'admin'),
    2: const User(id: 2, name: 'Bob (from API)', email: 'bob@api.com', role: 'user'),
  };

  @override
  Future<List<User>> getAll() async {
    await Future.delayed(const Duration(seconds: 2)); // simulates real API latency
    return _data.values.toList();
  }

  @override
  Future<User?> getById(int id) async {
    await Future.delayed(const Duration(seconds: 1));
    return _data[id];
  }

  @override
  Future<User> save(User user) async {
    await Future.delayed(const Duration(seconds: 1));
    _data[user.id] = user;
    return user;
  }

  @override
  Future<void> delete(int id) async {
    await Future.delayed(const Duration(seconds: 1));
    _data.remove(id);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Presentation layer — ViewModel that depends only on the abstraction
// ─────────────────────────────────────────────────────────────────────────────

/// ViewModel for the user list screen.
///
/// This class only depends on [UserRepository] — the abstract interface.
/// It doesn't know if data comes from memory, an API, or a database.
/// That's exactly what the Repository Pattern achieves.
///
/// In a real app, this would be a Riverpod Notifier or BLoC.
/// Here we use [ChangeNotifier] for simplicity (no additional packages needed).
class UserViewModel extends ChangeNotifier {
  /// Injected via constructor — see Dependency Inversion Principle (SOLID-D).
  final UserRepository _repository;

  UserViewModel(this._repository);

  // ── State ────────────────────────────────────────────────────────────────
  List<User> _users = [];
  bool _isLoading = false;
  String? _error;

  List<User> get users => List.unmodifiable(_users); // defensive copy
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ── Commands ─────────────────────────────────────────────────────────────

  /// Loads all users from the repository.
  Future<void> loadAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _users = await _repository.getAll();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Creates a new user with a random name for demo purposes.
  Future<void> addUser() async {
    final names = ['Diana', 'Eve', 'Frank', 'Grace', 'Henry'];
    final name = names[_users.length % names.length];
    final newUser = User(
      id: 0, // 0 = let repository assign the real ID
      name: name,
      email: '${name.toLowerCase()}@example.com',
      role: 'user',
    );

    try {
      final saved = await _repository.save(newUser);
      _users = [..._users, saved]; // immutable update
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Deletes a user by ID.
  Future<void> deleteUser(int id) async {
    try {
      await _repository.delete(id);
      _users = _users.where((u) => u.id != id).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

class RepositoryPatternDemo extends StatelessWidget {
  const RepositoryPatternDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Repository Pattern Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const _RepositoryScreen(),
    );
  }
}

class _RepositoryScreen extends StatefulWidget {
  const _RepositoryScreen();

  @override
  State<_RepositoryScreen> createState() => _RepositoryScreenState();
}

class _RepositoryScreenState extends State<_RepositoryScreen> {
  /// Start with the fast in-memory repository.
  /// Toggle to the slow API repo to see the same ViewModel with a different backend.
  bool _useSlowApi = false;

  late UserViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _buildViewModel();
  }

  /// Rebuilds the ViewModel with a different repository implementation.
  /// The ViewModel code is IDENTICAL — only the constructor argument changes.
  void _buildViewModel() {
    _viewModel?.removeListener(_onViewModelChanged);
    final repo = _useSlowApi
        ? SlowApiUserRepository() as UserRepository
        : InMemoryUserRepository();
    _viewModel = UserViewModel(repo);
    _viewModel.addListener(_onViewModelChanged);
    _viewModel.loadAll();
  }

  void _onViewModelChanged() => setState(() {});

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Repository Pattern'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Swap repository without changing the ViewModel
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Slow API', style: TextStyle(fontSize: 12)),
                Switch(
                  value: _useSlowApi,
                  onChanged: (v) {
                    setState(() => _useSlowApi = v);
                    _buildViewModel();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Explanation banner
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.teal.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _useSlowApi
                      ? '⏳ Slow API repository — simulates 2s network latency'
                      : '⚡ In-memory repository — instant responses',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const Text(
                  '💡 Toggle the switch to swap backends. '
                  'The ViewModel and UI code stay IDENTICAL — only the '
                  'constructor argument changes.',
                  style: TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),

          // User list
          Expanded(
            child: _viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _viewModel.error != null
                    ? Center(
                        child: Text('Error: ${_viewModel.error}',
                            style: const TextStyle(color: Colors.red)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _viewModel.users.length,
                        itemBuilder: (context, index) {
                          final user = _viewModel.users[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: user.role == 'admin'
                                    ? Colors.teal
                                    : Colors.grey.shade300,
                                child: Text(
                                  user.name[0],
                                  style: TextStyle(
                                    color: user.role == 'admin'
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                              title: Text(user.name),
                              subtitle: Text('${user.email} • ${user.role}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.red),
                                onPressed: () => _viewModel.deleteUser(user.id),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _viewModel.isLoading ? null : _viewModel.addUser,
        icon: const Icon(Icons.person_add),
        label: const Text('Add User'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
    );
  }
}
