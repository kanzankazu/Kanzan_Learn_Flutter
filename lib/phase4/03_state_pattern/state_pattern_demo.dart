/// Demo 03 — Loading / Error / Success State Pattern.
///
/// **Concepts covered:**
/// - The three UI states every async operation has: loading, error, success
/// - Sealed class `AsyncState<T>` — a type-safe alternative to three booleans
/// - How Riverpod's `AsyncValue<T>` works under the hood (same concept)
/// - Pull-to-refresh pattern
/// - Retry on error
/// - Empty state — success but no data
/// - Stale-while-revalidate — show cached data while re-fetching
///
/// **Why sealed class?**
/// Using `bool isLoading + String? error + T? data` leads to impossible states
/// (isLoading = true AND data != null at the same time). A sealed class makes
/// impossible states unrepresentable at compile time.
library;

import 'dart:math';

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Sealed state type
// ─────────────────────────────────────────────────────────────────────────────

/// Type-safe async state. Only one subclass can be active at a time.
/// This is the same idea as Riverpod's AsyncValue<T>.
sealed class AsyncState<T> {
  const AsyncState();
}

class AsyncLoading<T> extends AsyncState<T> {
  const AsyncLoading();
}

class AsyncSuccess<T> extends AsyncState<T> {
  final T data;
  const AsyncSuccess(this.data);
}

class AsyncError<T> extends AsyncState<T> {
  final String message;
  final StackTrace? stackTrace;
  const AsyncError(this.message, [this.stackTrace]);
}

// ─────────────────────────────────────────────────────────────────────────────
// Simulated data service
// ─────────────────────────────────────────────────────────────────────────────

class Article {
  final int id;
  final String title;
  final String author;

  const Article({required this.id, required this.title, required this.author});
}

class ArticleService {
  static int _callCount = 0;

  /// Simulates a network call.
  /// Every 3rd call fails to demonstrate error handling.
  static Future<List<Article>> fetchArticles({bool empty = false}) async {
    await Future.delayed(const Duration(milliseconds: 1200));

    _callCount++;
    if (_callCount % 3 == 0) {
      throw Exception('Network error (simulated — every 3rd call fails)');
    }

    if (empty) return [];

    return List.generate(
      5,
      (i) => Article(
        id: i + 1,
        title: 'Article ${i + 1} — fetched at call #$_callCount',
        author: ['Alice', 'Bob', 'Carol', 'Dave', 'Eve'][i % 5],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

class StatePatternDemo extends StatelessWidget {
  const StatePatternDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'State Pattern Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: const _StatePatternScreen(),
    );
  }
}

class _StatePatternScreen extends StatefulWidget {
  const _StatePatternScreen();

  @override
  State<_StatePatternScreen> createState() => _StatePatternScreenState();
}

class _StatePatternScreenState extends State<_StatePatternScreen> {
  AsyncState<List<Article>> _state = const AsyncLoading();
  List<Article> _cached = []; // for stale-while-revalidate
  bool _simulateEmpty = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _state = const AsyncLoading());
    try {
      final articles =
          await ArticleService.fetchArticles(empty: _simulateEmpty);
      _cached = articles; // cache for next refresh
      setState(() => _state = AsyncSuccess(articles));
    } catch (e, st) {
      setState(() => _state = AsyncError(e.toString(), st));
    }
  }

  /// Stale-while-revalidate: show old data immediately, update in background.
  Future<void> _refresh() async {
    // Don't clear UI — show cached data while loading
    if (_cached.isNotEmpty) {
      setState(() => _state = AsyncSuccess(_cached));
    }

    try {
      final articles =
          await ArticleService.fetchArticles(empty: _simulateEmpty);
      _cached = articles;
      setState(() => _state = AsyncSuccess(articles));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Refresh failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
        // Keep showing cached data even after failed refresh
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('State Pattern'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Toggle empty state simulation
          Tooltip(
            message: 'Toggle empty state',
            child: Switch(
              value: _simulateEmpty,
              onChanged: (v) {
                setState(() => _simulateEmpty = v);
                _load();
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Info banner
          Container(
            color: Colors.purple.shade50,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Text(
              '💡 Every 3rd request fails — keeps retrying to see error state.\n'
              'Toggle the switch to see the empty state.',
              style: TextStyle(fontSize: 12),
            ),
          ),

          // Main content — switch on sealed state
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    // Pattern match on the sealed class — exhaustive (compiler enforces all cases)
    return switch (_state) {
      AsyncLoading() => const Center(child: CircularProgressIndicator()),

      AsyncError(:final message) => _ErrorView(
          message: message,
          onRetry: _load,
        ),

      AsyncSuccess(:final data) when data.isEmpty => _EmptyView(
          onRefresh: _load,
        ),

      AsyncSuccess(:final data) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: data.length + 1, // +1 for header
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  '${data.length} articles loaded — pull to refresh',
                  style: const TextStyle(color: Colors.grey),
                ),
              );
            }
            final article = data[index - 1];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(child: Text('${article.id}')),
                title: Text(article.title),
                subtitle: Text('by ${article.author}'),
              ),
            );
          },
        ),
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Reusable error state widget.
///
/// Extracting this into a widget instead of building it inline serves two purposes:
/// 1. Reusability — any screen can show the same error UI
/// 2. Readability — the parent's `_buildBody()` switch stays clean
///
/// The [onRetry] callback lets the parent decide what "retry" means
/// (re-fetch from API, re-run a local computation, etc.).
class _ErrorView extends StatelessWidget {
  /// The error message to display (from Exception.toString() or DioException).
  final String message;

  /// Called when the user taps "Retry". Wires back to [_StatePatternScreenState._load].
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable empty state widget — shown when the API call succeeds but returns no data.
///
/// Empty state is a distinct UI state that beginners often forget.
/// Without it, the user sees a blank screen with no explanation — confusing.
///
/// 💡 Tip: Every list screen should handle four states:
/// 1. Loading   → spinner
/// 2. Error     → error message + retry
/// 3. Empty     → friendly message + refresh
/// 4. Data      → the actual list
class _EmptyView extends StatelessWidget {
  /// Called when the user taps "Refresh".
  final VoidCallback onRefresh;
  const _EmptyView({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No articles found',
              style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}
