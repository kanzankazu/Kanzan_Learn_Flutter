/// Demo 06 — Pagination & Infinite Scroll.
///
/// **Concepts covered:**
/// - Page-based pagination: /posts?_page=1&_limit=10
/// - Infinite scroll with ScrollController
/// - Loading indicator at the bottom while fetching next page
/// - End-of-list detection — stop fetching when server returns fewer items
/// - Pull-to-refresh — reset to page 1 and reload
/// - Debounce — avoid firing multiple simultaneous page requests
///
/// **ScrollController trick:**
/// ```dart
/// if (controller.position.pixels >= controller.position.maxScrollExtent - 200) {
///   // User is 200px from the bottom — prefetch next page
/// }
/// ```
library;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────────────────────────────────────

class Post {
  final int id;
  final String title;
  final String body;
  final int userId;

  const Post({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
  });

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        id: json['id'] as int,
        title: json['title'] as String,
        body: json['body'] as String,
        userId: json['userId'] as int,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Service
// ─────────────────────────────────────────────────────────────────────────────

class PostService {
  static final _dio = Dio(
    BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com'),
  );

  static const _pageSize = 10;

  static Future<List<Post>> fetchPage(int page) async {
    final response = await _dio.get(
      '/posts',
      queryParameters: {'_page': page, '_limit': _pageSize},
    );
    final data = response.data as List;
    return data.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

class PaginationDemo extends StatelessWidget {
  const PaginationDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pagination Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const _PaginationScreen(),
    );
  }
}

class _PaginationScreen extends StatefulWidget {
  const _PaginationScreen();

  @override
  State<_PaginationScreen> createState() => _PaginationScreenState();
}

class _PaginationScreenState extends State<_PaginationScreen> {
  final _scrollController = ScrollController();

  final List<Post> _posts = [];
  int _currentPage = 0;
  bool _isLoadingFirst = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNextPage();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Trigger next page load when 300px from the bottom
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 300 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadNextPage();
    }
  }

  Future<void> _loadNextPage() async {
    if (_isLoadingMore || !_hasMore) return;

    final isFirst = _posts.isEmpty;
    setState(() {
      if (isFirst) {
        _isLoadingFirst = true;
      } else {
        _isLoadingMore = true;
      }
      _error = null;
    });

    try {
      final nextPage = _currentPage + 1;
      final newPosts = await PostService.fetchPage(nextPage);

      setState(() {
        _posts.addAll(newPosts);
        _currentPage = nextPage;
        // If fewer items than page size → we've reached the end
        if (newPosts.length < 10) _hasMore = false;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() {
        _isLoadingFirst = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _posts.clear();
      _currentPage = 0;
      _hasMore = true;
      _error = null;
    });
    await _loadNextPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Posts (${_posts.length} loaded)'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.orange.shade50,
            child: const Text(
              '💡 Scroll to the bottom to load more posts.\n'
              'Pull down to refresh from the beginning.',
              style: TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            child: _isLoadingFirst
                ? const Center(child: CircularProgressIndicator())
                : _error != null && _posts.isEmpty
                    ? _ErrorView(
                        message: _error!,
                        onRetry: _loadNextPage,
                      )
                    : RefreshIndicator(
                        onRefresh: _refresh,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          // +1 for the bottom loader/end indicator
                          itemCount: _posts.length + 1,
                          itemBuilder: (context, index) {
                            // Last item = loader or end indicator
                            if (index == _posts.length) {
                              if (_isLoadingMore) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              if (!_hasMore) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24),
                                  child: Center(
                                    child: Text(
                                      '— You have reached the end —',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            }

                            final post = _posts[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text('${post.id}'),
                                ),
                                title: Text(
                                  post.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  post.body,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: Text(
                                  'p${(index ~/ 10) + 1}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
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

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.orange),
          const SizedBox(height: 12),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
