/// Demo 06 — Error Handling Pattern: Either / Result Sealed Class.
///
/// In Clean Architecture, repositories and use cases should NOT throw exceptions
/// into the presentation layer. Instead, they return a typed result that
/// represents either success or failure.
///
/// **Why avoid throwing in domain/data layers?**
/// - Exceptions are invisible in function signatures — callers don't know what can fail
/// - You can forget to catch them (no compile-time safety)
/// - Hard to distinguish expected failures (user not found) from bugs (null pointer)
///
/// **Two approaches:**
///
/// 1. **Sealed `Result<T>` class** (used in this demo — pure Dart, no packages)
///    ```dart
///    sealed class Result<T> { ... }
///    class Success<T> extends Result<T> { final T data; ... }
///    class Failure<T> extends Result<T> { final AppError error; ... }
///    ```
///
/// 2. **`Either<L, R>` from dartz package** (popular in the community)
///    ```dart
///    Either<Failure, User> getUser(int id);
///    ```
///    Both achieve the same goal. We use our own sealed class here to avoid
///    an extra dependency and to see exactly what the pattern looks like.
///
/// **How to read a Result:**
/// ```dart
/// final result = await repository.getUser(id);
/// switch (result) {
///   case Success(:final data) => showUser(data),
///   case Failure(:final error) => showError(error.message),
/// }
/// ```
///
/// How to run: `flutter run -t lib/phase5/06_error_handling/error_handling_demo.dart`
library;

import 'dart:math';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Result type — the core of this pattern
// ─────────────────────────────────────────────────────────────────────────────

/// A type-safe result wrapper that either holds a [Success] value or a [Failure].
///
/// This is a "sum type" or "discriminated union" — a value of type `Result<T>`
/// is guaranteed to be EITHER a Success OR a Failure. Never both, never neither.
///
/// Generic type `T` is the type of the success value (e.g. `Result<User>`,
/// `Result<List<Product>>`, `Result<void>`).
sealed class Result<T> {
  const Result();

  /// Convenience: returns true if this is a [Success].
  bool get isSuccess => this is Success<T>;

  /// Convenience: returns true if this is a [Failure].
  bool get isFailure => this is Failure<T>;

  /// Pattern-matching shorthand — calls [onSuccess] or [onFailure] and returns R.
  ///
  /// Example:
  /// ```dart
  /// final message = result.fold(
  ///   onSuccess: (user) => 'Hello, ${user.name}!',
  ///   onFailure: (error) => 'Error: ${error.message}',
  /// );
  /// ```
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(AppError error) onFailure,
  }) {
    return switch (this) {
      Success(:final data) => onSuccess(data),
      Failure(:final error) => onFailure(error),
    };
  }
}

/// The success case — holds the actual data.
class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

/// The failure case — holds a structured [AppError] instead of a raw exception.
class Failure<T> extends Result<T> {
  final AppError error;
  const Failure(this.error);
}

// ─────────────────────────────────────────────────────────────────────────────
// AppError — structured error type
// ─────────────────────────────────────────────────────────────────────────────

/// Base class for all application-level errors.
///
/// Using a class hierarchy for errors gives you:
/// 1. Type-safe error handling: `if (error is NetworkError) { ... }`
/// 2. Consistent error message display
/// 3. Extra context per error type (status code, validation field, etc.)
///
/// In a real app this would be a sealed class with more subtypes.
abstract class AppError {
  /// Human-readable message suitable for display to the user.
  String get message;
}

/// The server returned an HTTP error (4xx, 5xx).
class NetworkError extends AppError {
  final int statusCode;
  final String detail;

  NetworkError({required this.statusCode, required this.detail});

  @override
  String get message => 'Network error $statusCode: $detail';
}

/// No internet connection.
class ConnectionError extends AppError {
  @override
  String get message => 'No internet connection. Please check your network.';
}

/// The requested resource was not found.
class NotFoundError extends AppError {
  final String resource;
  NotFoundError(this.resource);

  @override
  String get message => '$resource was not found.';
}

/// User input failed validation.
class ValidationError extends AppError {
  final String field;
  final String reason;

  ValidationError({required this.field, required this.reason});

  @override
  String get message => 'Validation error on "$field": $reason';
}

/// An unexpected error (bug, parsing error, etc.).
class UnknownError extends AppError {
  final String detail;
  UnknownError(this.detail);

  @override
  String get message => 'Unexpected error: $detail';
}

// ─────────────────────────────────────────────────────────────────────────────
// Domain entity
// ─────────────────────────────────────────────────────────────────────────────

class UserProfile {
  final int id;
  final String name;
  final String email;
  final String bio;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.bio,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Repository returning Result<T> instead of throwing
// ─────────────────────────────────────────────────────────────────────────────

/// Abstract repository — the signature tells callers EXACTLY what can go wrong.
/// No need to read docs or guess what exceptions to catch.
abstract class UserProfileRepository {
  /// Returns [Success<UserProfile>] or [Failure] with a specific [AppError].
  Future<Result<UserProfile>> getById(int id);

  /// Validates and saves a profile update.
  Future<Result<UserProfile>> update(UserProfile profile);
}

/// Simulated implementation with intentional failures for demo purposes.
class FakeUserProfileRepository implements UserProfileRepository {
  static final _random = Random();
  static const _profiles = {
    1: UserProfile(id: 1, name: 'Alice Johnson', email: 'alice@example.com', bio: 'Flutter developer'),
    2: UserProfile(id: 2, name: 'Bob Smith', email: 'bob@example.com', bio: 'Backend engineer'),
    3: UserProfile(id: 3, name: 'Carol White', email: 'carol@example.com', bio: 'Product designer'),
  };

  @override
  Future<Result<UserProfile>> getById(int id) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Simulate different failure scenarios based on ID
    if (id == 99) {
      return Failure(NotFoundError('User #$id'));
    }
    if (id == 0) {
      return Failure(ValidationError(field: 'id', reason: 'ID must be positive'));
    }
    if (_random.nextInt(5) == 0) {
      // 20% chance of simulated network error
      return Failure(NetworkError(statusCode: 503, detail: 'Service temporarily unavailable'));
    }

    final profile = _profiles[id];
    if (profile == null) {
      return Failure(NotFoundError('User #$id'));
    }

    // Success! Wrap in Success<UserProfile>
    return Success(profile);
  }

  @override
  Future<Result<UserProfile>> update(UserProfile profile) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Domain validation inside the repository
    if (profile.name.trim().isEmpty) {
      return Failure(ValidationError(field: 'name', reason: 'Name cannot be empty'));
    }
    if (!profile.email.contains('@')) {
      return Failure(ValidationError(field: 'email', reason: 'Email must contain @'));
    }

    // Simulate occasional server error
    if (_random.nextBool()) {
      return Failure(ConnectionError());
    }

    return Success(profile);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

class ErrorHandlingDemo extends StatelessWidget {
  const ErrorHandlingDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Error Handling Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const _ErrorHandlingScreen(),
    );
  }
}

class _ErrorHandlingScreen extends StatefulWidget {
  const _ErrorHandlingScreen();

  @override
  State<_ErrorHandlingScreen> createState() => _ErrorHandlingScreenState();
}

class _ErrorHandlingScreenState extends State<_ErrorHandlingScreen> {
  final _repo = FakeUserProfileRepository();

  Result<UserProfile>? _lastResult;
  bool _loading = false;

  Future<void> _fetch(int id) async {
    setState(() {
      _loading = true;
      _lastResult = null;
    });
    final result = await _repo.getById(id);
    setState(() {
      _lastResult = result;
      _loading = false;
    });
  }

  Future<void> _update() async {
    setState(() {
      _loading = true;
      _lastResult = null;
    });
    final dummy = const UserProfile(
      id: 1,
      name: 'Alice Updated',
      email: 'alice@updated.com',
      bio: 'Updated bio',
    );
    final result = await _repo.update(dummy);
    setState(() {
      _lastResult = result;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error Handling Pattern'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Explanation
          Card(
            color: Colors.red.shade50,
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Result<T> pattern', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    'Repositories return Success(data) or Failure(error).\n'
                    'No exceptions propagating to the UI.\n'
                    'Compiler forces you to handle both cases.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Fetch buttons
          Text('Test getById()', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilledButton(onPressed: _loading ? null : () => _fetch(1), child: const Text('ID: 1 ✅')),
              FilledButton(onPressed: _loading ? null : () => _fetch(99), child: const Text('ID: 99 (not found)')),
              FilledButton(onPressed: _loading ? null : () => _fetch(0), child: const Text('ID: 0 (validation)')),
              FilledButton(onPressed: _loading ? null : () => _fetch(2), child: const Text('ID: 2 (may fail 20%)')),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _loading ? null : _update,
            icon: const Icon(Icons.edit),
            label: const Text('Test update() — may fail 50%'),
          ),
          const SizedBox(height: 20),

          // Result display
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_lastResult != null)
            _ResultDisplay(result: _lastResult!),

          const SizedBox(height: 24),

          // How to consume the Result
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('How to consume Result<T>',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.grey.shade100,
                    child: const Text(
                      'switch (result) {\n'
                      '  case Success(:final data) =>\n'
                      '    showProfile(data),\n'
                      '  case Failure(:final error) =>\n'
                      '    showError(error.message),\n'
                      '}\n\n'
                      '// Or using fold():\n'
                      'result.fold(\n'
                      '  onSuccess: (data) => ...,\n'
                      '  onFailure: (error) => ...,\n'
                      ');',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Displays a [Result] with visual distinction between success and failure.
class _ResultDisplay extends StatelessWidget {
  final Result<UserProfile> result;
  const _ResultDisplay({required this.result});

  @override
  Widget build(BuildContext context) {
    return switch (result) {
      Success(:final data) => Card(
          color: Colors.green.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Success<UserProfile>',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('ID: ${data.id}'),
                Text('Name: ${data.name}'),
                Text('Email: ${data.email}'),
                Text('Bio: ${data.bio}'),
              ],
            ),
          ),
        ),
      Failure(:final error) => Card(
          color: Colors.red.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Text('Failure<${error.runtimeType}>',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.red)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(error.message),
                const SizedBox(height: 4),
                Text(
                  'Error type: ${error.runtimeType}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
    };
  }
}
