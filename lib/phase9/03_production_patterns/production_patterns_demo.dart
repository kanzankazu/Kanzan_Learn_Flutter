/// Phase 9 — Topic 03: Production Patterns
///
/// "Production patterns" are the techniques that separate a hobby app
/// from one that real users depend on without frustration.
///
/// Covered in this topic:
/// 1. AsyncState<T> — sealed loading / error / success pattern
/// 2. Error boundary — catch errors at the top, don't let them crash the app
/// 3. Retry + exponential back-off — network resilience
/// 4. Offline-first pattern — show cached data while syncing
/// 5. Pagination — infinite scroll with proper state management
/// 6. Debounce — prevent search from firing on every keystroke
/// 7. Optimistic UI — update locally before server confirms
/// 8. Empty / error / loading states — every screen must handle all three
import 'dart:async';

import 'package:flutter/material.dart';

/// Standalone entry point.
void main() => runApp(const _StandaloneApp());

class _StandaloneApp extends StatelessWidget {
  const _StandaloneApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Production Patterns',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const ProductionPatternsDemo(),
    );
  }
}

/// Demo screen showcasing production-ready patterns with live examples.
class ProductionPatternsDemo extends StatefulWidget {
  const ProductionPatternsDemo({super.key});

  @override
  State<ProductionPatternsDemo> createState() => _ProductionPatternsDemoState();
}

class _ProductionPatternsDemoState extends State<ProductionPatternsDemo> {
  // ── Pattern 1: AsyncState live demo ───────────────────────────────────────
  // Tracks the state of a simulated network request.
  _AsyncState<String> _asyncState = const _AsyncState.idle();

  // ── Pattern 5: Pagination live demo ───────────────────────────────────────
  final List<String> _items = [];
  bool _loadingMore = false;
  int _page = 0;

  // ── Pattern 6: Debounce live demo ─────────────────────────────────────────
  Timer? _debounceTimer;
  String _searchQuery = '';
  String _lastFiredQuery = '— (not fired yet)';

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  // ── Simulate a network request with configurable outcome ──────────────────
  Future<void> _simulateRequest({bool shouldFail = false}) async {
    setState(() => _asyncState = const _AsyncState.loading());
    await Future.delayed(const Duration(seconds: 2));

    if (shouldFail) {
      setState(() => _asyncState =
          const _AsyncState.error('Network error: connection timed out'));
    } else {
      setState(() => _asyncState =
          _AsyncState.success('Data loaded at ${DateTime.now().second}s'));
    }
  }

  // ── Simulate loading the next page of a paginated list ────────────────────
  Future<void> _loadNextPage() async {
    if (_loadingMore) return; // guard: don't load if already loading
    setState(() => _loadingMore = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _items.addAll(List.generate(10, (i) => 'Item ${_page * 10 + i + 1}'));
      _page++;
      _loadingMore = false;
    });
  }

  // ── Debounced search handler ───────────────────────────────────────────────
  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
    // Cancel the previous timer every time the user types
    _debounceTimer?.cancel();
    // Only fire after 500ms of silence
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() => _lastFiredQuery = value.isEmpty ? '(empty)' : value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('03 — Production Patterns'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── 1. AsyncState<T> sealed class ──────────────────────────────────
          _header('1. AsyncState<T> — Universal Async Pattern', Colors.green.shade700),
          const Text(
            'Every screen that loads data must handle exactly three states: '
            'loading, error, and success. Sealed classes enforce this at compile time.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          _code('''
// lib/core/async_state.dart

/// A sealed class that forces every caller to handle all three async states.
///
/// Usage with Riverpod:
///   class TransactionListNotifier extends AsyncNotifier<List<Transaction>> {}
///   // Riverpod's AsyncValue<T> is essentially this pattern built-in.
///
/// Usage in plain StatefulWidget or ChangeNotifier:
///   AsyncState<List<Transaction>> _state = const AsyncState.idle();
sealed class AsyncState<T> {
  const AsyncState();

  /// No request has started yet — show nothing or a placeholder.
  const factory AsyncState.idle() = _Idle;

  /// Request is in progress — show a loading spinner.
  const factory AsyncState.loading() = _Loading;

  /// Request completed with data — show the content.
  const factory AsyncState.success(T data) = _Success;

  /// Request failed — show an error message and a retry button.
  const factory AsyncState.error(String message) = _Error;

  /// Pattern-match all states — compiler error if you miss one.
  R when<R>({
    required R Function() idle,
    required R Function() loading,
    required R Function(T data) success,
    required R Function(String msg) error,
  }) =>
      switch (this) {
        _Idle()       => idle(),
        _Loading()    => loading(),
        _Success(:final data) => success(data),
        _Error(:final message) => error(message),
      };
}

class _Idle<T>    extends AsyncState<T> { const _Idle(); }
class _Loading<T> extends AsyncState<T> { const _Loading(); }
class _Success<T> extends AsyncState<T> {
  final T data;
  const _Success(this.data);
}
class _Error<T> extends AsyncState<T> {
  final String message;
  const _Error(this.message);
}

// Usage in build():
_state.when(
  idle:    () => const SizedBox.shrink(),
  loading: () => const CircularProgressIndicator(),
  success: (data) => Text(data.toString()),
  error:   (msg)  => Column(children: [
    Text(msg),
    ElevatedButton(onPressed: _reload, child: const Text('Retry')),
  ]),
)'''),
          const SizedBox(height: 8),
          // Live demo of AsyncState
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const Text('Live Demo — AsyncState',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  // Render based on current state
                  _asyncState.when(
                    idle: () => const Text('Tap a button to start',
                        style: TextStyle(color: Colors.grey)),
                    loading: () =>
                        const CircularProgressIndicator(),
                    success: (data) => Text('✅ $data',
                        style: const TextStyle(color: Colors.green)),
                    error: (msg) => Text('❌ $msg',
                        style: const TextStyle(color: Colors.red)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton(
                        onPressed: () => _simulateRequest(),
                        child: const Text('Load (success)'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () =>
                            _simulateRequest(shouldFail: true),
                        child: const Text('Load (fail)'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── 2. Retry with exponential back-off ─────────────────────────────
          _header('2. Retry with Exponential Back-off', Colors.orange),
          _code('''
/// Retries [operation] up to [maxAttempts] times.
/// Waits 1s, 2s, 4s between attempts (doubles each time).
///
/// Only retries on transient errors (network timeout, 503).
/// Never retries on permanent errors (401, 404, validation).
Future<T> withRetry<T>(
  Future<T> Function() operation, {
  int maxAttempts = 3,
}) async {
  var attempt = 0;
  while (true) {
    try {
      return await operation();
    } on NetworkException catch (e) {
      attempt++;
      if (attempt >= maxAttempts || !e.isRetryable) rethrow;
      // Exponential back-off: 1s → 2s → 4s
      await Future.delayed(Duration(seconds: 1 << (attempt - 1)));
    }
  }
}

// Usage:
final transactions = await withRetry(
  () => _api.fetchTransactions(walletId),
  maxAttempts: 3,
);'''),

          const SizedBox(height: 20),

          // ── 3. Offline-first pattern ───────────────────────────────────────
          _header('3. Offline-First Pattern', Colors.blue),
          _code('''
// Strategy: always show cached data immediately, then refresh from network.
// User never sees a blank screen while waiting for the network.

Future<Result<List<Transaction>>> getTransactions(String walletId) async {
  // ① Emit cached data immediately — user sees content at once
  final cached = await _localDb.getTransactions(walletId);
  if (cached.isNotEmpty) {
    // Optionally mark as stale so UI can show "last updated: 5 min ago"
    _cacheStateNotifier.markStale(walletId);
    _streamController.add(Success(cached.map(toEntity).toList()));
  }

  // ② Fetch fresh data in the background
  try {
    final fresh = await _api.fetchTransactions(walletId);
    await _localDb.upsert(fresh);                      // update cache
    _cacheStateNotifier.markFresh(walletId);
    return Success(fresh.map(toEntity).toList());      // emit fresh data
  } on NetworkException {
    // No network — cached data is already shown, no crash
    if (cached.isEmpty) {
      return const Failure(AppError.offline());        // only fail if cache is empty too
    }
    return Success(cached.map(toEntity).toList());
  }
}'''),

          const SizedBox(height: 20),

          // ── 4. Pagination ──────────────────────────────────────────────────
          _header('4. Pagination — Infinite Scroll', Colors.purple),
          const Text(
            'Load the first 20 items. When the user scrolls near the bottom, '
            'load 20 more. Repeat until all items are loaded.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          // Live pagination demo
          SizedBox(
            height: 200,
            child: Card(
              child: NotificationListener<ScrollNotification>(
                // Detect when user scrolls close to the bottom
                onNotification: (notification) {
                  if (notification is ScrollEndNotification) {
                    final metrics = notification.metrics;
                    // If within 100px of the bottom, load more
                    if (metrics.pixels >=
                        metrics.maxScrollExtent - 100) {
                      _loadNextPage();
                    }
                  }
                  return false;
                },
                child: ListView.builder(
                  itemCount:
                      _items.length + (_loadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _items.length) {
                      // Last item is a loading spinner
                      return const Padding(
                        padding: EdgeInsets.all(8),
                        child: Center(
                            child: CircularProgressIndicator()),
                      );
                    }
                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 12,
                        child: Text('${index + 1}',
                            style: const TextStyle(fontSize: 9)),
                      ),
                      title: Text(_items[index]),
                    );
                  },
                ),
              ),
            ),
          ),
          FilledButton(
            onPressed: _items.isEmpty ? _loadNextPage : null,
            child: const Text('Load first page'),
          ),

          const SizedBox(height: 20),

          // ── 5. Debounce ────────────────────────────────────────────────────
          _header('5. Debounce — Search Input', Colors.red),
          const Text(
            'Without debounce, every keystroke fires a network request. '
            'With debounce, the request fires only after 500ms of silence.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Type to search (debounced 500ms)…',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: _onSearchChanged,
          ),
          const SizedBox(height: 6),
          Text('Input:    "$_searchQuery"',
              style: const TextStyle(fontSize: 12)),
          Text('Fired at: "$_lastFiredQuery"',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold)),

          const SizedBox(height: 20),

          // ── 6. Optimistic UI ───────────────────────────────────────────────
          _header('6. Optimistic UI', Colors.brown),
          _code('''
// Optimistic UI = update the local state BEFORE the server confirms.
// If the server call fails, roll back to the previous state.
// Makes the app feel instant even on slow connections.

Future<void> toggleFavorite(String itemId) async {
  final wasLiked = state.likedIds.contains(itemId);

  // ① Apply the change locally — UI updates instantly
  state = state.copyWith(
    likedIds: wasLiked
        ? state.likedIds.where((id) => id != itemId).toSet()
        : {...state.likedIds, itemId},
  );

  try {
    // ② Confirm with the server in the background
    await _api.setLiked(itemId, !wasLiked);
  } catch (_) {
    // ③ Roll back if the server call failed
    state = state.copyWith(
      likedIds: wasLiked
          ? {...state.likedIds, itemId}        // re-add
          : state.likedIds.where((id) => id != itemId).toSet(), // re-remove
    );
    _showError('Could not update — please try again.');
  }
}'''),

          const SizedBox(height: 16),
          _card(
            color: Colors.green.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Key Takeaways',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('• AsyncState sealed class forces handling loading/error/success'),
                Text('• Retry with exponential back-off makes your app resilient to flaky networks'),
                Text('• Offline-first: show cache immediately, refresh in background'),
                Text('• Pagination: ScrollNotification detects bottom, load next page'),
                Text('• Debounce: cancel + restart a 500ms timer on every keystroke'),
                Text('• Optimistic UI: update locally first, roll back on failure'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── AsyncState sealed class (inline for this demo) ────────────────────────────

/// Minimal sealed async state used in the live demo above.
/// In a real project this lives in lib/core/async_state.dart.
sealed class _AsyncState<T> {
  const _AsyncState();
  const factory _AsyncState.idle() = _Idle;
  const factory _AsyncState.loading() = _Loading;
  const factory _AsyncState.success(T data) = _Success;
  const factory _AsyncState.error(String message) = _Error;

  R when<R>({
    required R Function() idle,
    required R Function() loading,
    required R Function(T data) success,
    required R Function(String msg) error,
  }) =>
      switch (this) {
        _Idle() => idle(),
        _Loading() => loading(),
        _Success(:final data) => success(data),
        _Error(:final message) => error(message),
      };
}

class _Idle<T> extends _AsyncState<T> { const _Idle(); }
class _Loading<T> extends _AsyncState<T> { const _Loading(); }
class _Success<T> extends _AsyncState<T> {
  final T data;
  const _Success(this.data);
}
class _Error<T> extends _AsyncState<T> {
  final String message;
  const _Error(this.message);
}

// ── Shared helpers ─────────────────────────────────────────────────────────────

Widget _header(String title, Color color) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(title,
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold, color: color)),
    );

Widget _code(String code) => Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(6),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(code,
            style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: Color(0xFFCDD6F4))),
      ),
    );

Widget _card({required Color color, required Widget child}) => Card(
      color: color,
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    );
