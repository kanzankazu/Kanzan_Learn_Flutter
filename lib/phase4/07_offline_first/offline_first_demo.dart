/// Demo 07 — Offline-First Pattern.
///
/// **Concepts covered:**
/// - Cache-then-network: show cached data immediately, update from network
/// - Network-then-cache: try network, fall back to cache on failure
/// - Connectivity check: detect when device is offline
/// - Marking data as "stale" (from cache) vs "fresh" (from network)
/// - Hive as the local cache store
///
/// **The offline-first approach:**
/// 1. On launch → show cached data immediately (fast UI)
/// 2. In background → fetch fresh data from network
/// 3. On success → update cache + refresh UI
/// 4. On failure (no internet) → keep showing cached data + show offline badge
///
/// This gives users a working app even with no connection.
library;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────────────────────────────────────

class CachedPost {
  final int id;
  final String title;
  final String body;
  final DateTime cachedAt;
  final bool isStale; // true = from cache, false = just fetched

  const CachedPost({
    required this.id,
    required this.title,
    required this.body,
    required this.cachedAt,
    this.isStale = false,
  });

  CachedPost copyWith({bool? isStale}) => CachedPost(
        id: id,
        title: title,
        body: body,
        cachedAt: cachedAt,
        isStale: isStale ?? this.isStale,
      );
}

/// Hive adapter for CachedPost.
class CachedPostAdapter extends TypeAdapter<CachedPost> {
  @override
  final int typeId = 1;

  @override
  CachedPost read(BinaryReader reader) => CachedPost(
        id: reader.readInt(),
        title: reader.readString(),
        body: reader.readString(),
        cachedAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
        isStale: true, // always stale when read from disk
      );

  @override
  void write(BinaryWriter writer, CachedPost obj) {
    writer.writeInt(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.body);
    writer.writeInt(obj.cachedAt.millisecondsSinceEpoch);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Repository — wraps both cache and network
// ─────────────────────────────────────────────────────────────────────────────

class PostRepository {
  static const _cacheBoxName = 'cached_posts';
  static final _dio = Dio(
    BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      connectTimeout: const Duration(seconds: 5),
    ),
  );

  static Box<CachedPost> get _box => Hive.box<CachedPost>(_cacheBoxName);

  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CachedPostAdapter());
    }
    await Hive.openBox<CachedPost>(_cacheBoxName);
  }

  /// Cache-then-network strategy.
  /// 1. Return cached posts immediately (empty list if cache is empty).
  /// 2. Caller uses these to show UI instantly.
  static List<CachedPost> getCached() {
    return _box.values.toList()..sort((a, b) => a.id.compareTo(b.id));
  }

  /// Fetch fresh posts from the network and update the cache.
  /// Returns the fresh list on success, throws on failure.
  static Future<List<CachedPost>> fetchFresh() async {
    final response = await _dio.get('/posts', queryParameters: {'_limit': 15});
    final fresh = (response.data as List)
        .map((e) => CachedPost(
              id: e['id'] as int,
              title: e['title'] as String,
              body: e['body'] as String,
              cachedAt: DateTime.now(),
              isStale: false,
            ))
        .toList();

    // Write fresh data to cache
    await _box.clear();
    final map = {for (final p in fresh) p.id.toString(): p};
    await _box.putAll(map);

    return fresh;
  }

  static Future<void> clear() => _box.clear();
}

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

class OfflineFirstDemo extends StatelessWidget {
  const OfflineFirstDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Offline-First Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const _OfflineFirstScreen(),
    );
  }
}

class _OfflineFirstScreen extends StatefulWidget {
  const _OfflineFirstScreen();

  @override
  State<_OfflineFirstScreen> createState() => _OfflineFirstScreenState();
}

class _OfflineFirstScreenState extends State<_OfflineFirstScreen> {
  List<CachedPost> _posts = [];
  bool _isInitializing = true;
  bool _isFetching = false;
  bool _isOffline = false;
  String? _message;
  DateTime? _lastFetched;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Step 1 — init Hive and show cached data immediately
    await Hive.initFlutter();
    await PostRepository.init();

    final cached = PostRepository.getCached();
    setState(() {
      _posts = cached;
      _isInitializing = false;
      if (cached.isNotEmpty) {
        _message = '⚡ Showing ${cached.length} cached posts — fetching fresh data...';
      }
    });

    // Step 2 — fetch fresh in background
    _fetchFresh();
  }

  Future<void> _fetchFresh() async {
    if (_isFetching) return;
    setState(() {
      _isFetching = true;
      _isOffline = false;
    });

    try {
      final fresh = await PostRepository.fetchFresh();
      setState(() {
        _posts = fresh;
        _isFetching = false;
        _lastFetched = DateTime.now();
        _message = '✅ Fresh data loaded at ${_formatTime(_lastFetched!)}';
      });
    } catch (e) {
      final cached = PostRepository.getCached();
      setState(() {
        _isFetching = false;
        _isOffline = true;
        if (cached.isNotEmpty) {
          _posts = cached.map((p) => p.copyWith(isStale: true)).toList();
          _message = '📵 Offline — showing cached data from ${cached.isNotEmpty ? _formatTime(cached.first.cachedAt) : 'unknown'}';
        } else {
          _message = '📵 Offline and no cached data available.';
        }
      });
    }
  }

  Future<void> _clearCache() async {
    await PostRepository.clear();
    setState(() {
      _posts = [];
      _lastFetched = null;
      _message = 'Cache cleared. Pull to refresh.';
    });
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline-First'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_isFetching)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear cache',
            onPressed: _clearCache,
          ),
        ],
      ),
      body: Column(
        children: [
          // Status banner
          if (_message != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: _isOffline ? Colors.orange.shade100 : Colors.green.shade50,
              child: Text(
                _message!,
                style: TextStyle(
                  fontSize: 12,
                  color: _isOffline ? Colors.orange.shade800 : Colors.green.shade800,
                ),
              ),
            ),

          // Offline badge
          if (_isOffline)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4),
              color: Colors.orange,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text('OFFLINE MODE',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),

          // Strategy explanation
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.blueGrey.shade50,
            child: const Text(
              '💡 Strategy: Cache-then-Network\n'
              '1. Show cached data instantly (great UX)\n'
              '2. Fetch fresh data in background\n'
              '3. If offline → keep showing cache + badge',
              style: TextStyle(fontSize: 11),
            ),
          ),

          // Posts list
          Expanded(
            child: _posts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        const Text('No data — pull to refresh',
                            style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 16),
                        FilledButton(
                            onPressed: _fetchFresh,
                            child: const Text('Retry')),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchFresh,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _posts.length,
                      itemBuilder: (context, index) {
                        final post = _posts[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: post.isStale
                                  ? Colors.orange.shade100
                                  : Colors.green.shade100,
                              child: Text('${post.id}',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: post.isStale
                                          ? Colors.orange.shade800
                                          : Colors.green.shade800)),
                            ),
                            title: Text(
                              post.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              post.isStale
                                  ? '📦 From cache'
                                  : '🌐 Fresh from network',
                              style: TextStyle(
                                fontSize: 11,
                                color: post.isStale
                                    ? Colors.orange
                                    : Colors.green,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
