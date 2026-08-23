/// Mini Project Phase 4 — News Reader App.
///
/// **What this project practices:**
/// - Dio for paginated API calls
/// - Manual JSON deserialization
/// - Offline-first pattern (Hive cache)
/// - Paginated infinite scroll
/// - Bookmark feature (SharedPreferences)
/// - CachedNetworkImage for article thumbnails
/// - Pull-to-refresh
/// - Category filter (tabs)
///
/// **API:** https://jsonplaceholder.typicode.com/posts (simulated as news)
///
/// **How to run:**
/// ```bash
/// flutter run -t lib/phase4/mini_projects/news_reader/news_reader_app.dart
/// ```
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────────────────────────────────────

class NewsArticle {
  final int id;
  final String title;
  final String body;
  final int userId; // used as "category" in this demo
  final String imageUrl;

  const NewsArticle({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
    required this.imageUrl,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int;
    return NewsArticle(
      id: id,
      title: json['title'] as String,
      body: json['body'] as String,
      userId: json['userId'] as int,
      // Picsum gives a different image per ID
      imageUrl: 'https://picsum.photos/seed/news$id/400/200',
    );
  }

  String get category => _categories[userId % _categories.length];
}

const _categories = ['Tech', 'Sports', 'Politics', 'Science', 'Arts'];

// ─────────────────────────────────────────────────────────────────────────────
// Hive adapter
// ─────────────────────────────────────────────────────────────────────────────

class NewsArticleAdapter extends TypeAdapter<NewsArticle> {
  @override
  final int typeId = 2;

  @override
  NewsArticle read(BinaryReader reader) => NewsArticle(
        id: reader.readInt(),
        title: reader.readString(),
        body: reader.readString(),
        userId: reader.readInt(),
        imageUrl: reader.readString(),
      );

  @override
  void write(BinaryWriter writer, NewsArticle obj) {
    writer.writeInt(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.body);
    writer.writeInt(obj.userId);
    writer.writeString(obj.imageUrl);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Repository
// ─────────────────────────────────────────────────────────────────────────────

class NewsRepository {
  static const _cacheBox = 'news_cache';
  static const _bookmarksKey = 'bookmarks';
  static const _pageSize = 10;

  static final _dio = Dio(
    BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      connectTimeout: const Duration(seconds: 8),
    ),
  );

  static Box<NewsArticle> get _box => Hive.box<NewsArticle>(_cacheBox);

  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(NewsArticleAdapter());
    }
    await Hive.openBox<NewsArticle>(_cacheBox);
  }

  // ── Cache ──────────────────────────────────────────────────────────────────

  static List<NewsArticle> getCached() => _box.values.toList();

  static Future<void> cacheArticles(List<NewsArticle> articles) async {
    await _box.clear();
    final map = {for (final a in articles) a.id.toString(): a};
    await _box.putAll(map);
  }

  // ── Network ────────────────────────────────────────────────────────────────

  static Future<List<NewsArticle>> fetchPage(int page) async {
    final res = await _dio.get(
      '/posts',
      queryParameters: {'_page': page, '_limit': _pageSize},
    );
    return (res.data as List)
        .map((e) => NewsArticle.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Bookmarks ──────────────────────────────────────────────────────────────

  static Future<Set<int>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_bookmarksKey) ?? [];
    return ids.map(int.parse).toSet();
  }

  static Future<void> toggleBookmark(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = (prefs.getStringList(_bookmarksKey) ?? []).toSet();
    if (ids.contains(id.toString())) {
      ids.remove(id.toString());
    } else {
      ids.add(id.toString());
    }
    await prefs.setStringList(_bookmarksKey, ids.toList());
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

void main() => runApp(const NewsReaderApp());

class NewsReaderApp extends StatelessWidget {
  const NewsReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News Reader',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const _NewsInitScreen(),
    );
  }
}

/// Initializes Hive before showing the main UI.
class _NewsInitScreen extends StatefulWidget {
  const _NewsInitScreen();

  @override
  State<_NewsInitScreen> createState() => _NewsInitScreenState();
}

class _NewsInitScreenState extends State<_NewsInitScreen> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    NewsRepository.init().then((_) {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return const NewsListScreen();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// News list screen
// ─────────────────────────────────────────────────────────────────────────────

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  final _scrollCtrl = ScrollController();

  final List<NewsArticle> _articles = [];
  Set<int> _bookmarks = {};
  int _page = 0;
  bool _isLoadingFirst = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _isOffline = false;
  String? _selectedCategory; // null = All

  static const _tabs = ['All', ..._categories];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        setState(() {
          _selectedCategory =
              _tabCtrl.index == 0 ? null : _tabs[_tabCtrl.index];
        });
      }
    });
    _scrollCtrl.addListener(_onScroll);
    _loadBookmarks();
    _loadCacheThenNetwork();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollCtrl.position;
    if (pos.pixels >= pos.maxScrollExtent - 300 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadNextPage();
    }
  }

  Future<void> _loadBookmarks() async {
    final bm = await NewsRepository.getBookmarks();
    if (mounted) setState(() => _bookmarks = bm);
  }

  Future<void> _loadCacheThenNetwork() async {
    setState(() => _isLoadingFirst = true);

    // Show cache immediately
    final cached = NewsRepository.getCached();
    if (cached.isNotEmpty) {
      setState(() {
        _articles.addAll(cached);
        _page = (cached.length / 10).ceil();
        _isLoadingFirst = false;
      });
    }

    // Then fetch fresh
    try {
      final fresh = await NewsRepository.fetchPage(1);
      await NewsRepository.cacheArticles(fresh);
      if (mounted) {
        setState(() {
          _articles.clear();
          _articles.addAll(fresh);
          _page = 1;
          _hasMore = fresh.length == 10;
          _isOffline = false;
          _isLoadingFirst = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isOffline = true;
          _isLoadingFirst = false;
        });
      }
    }
  }

  Future<void> _loadNextPage() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final nextPage = _page + 1;
      final newArticles = await NewsRepository.fetchPage(nextPage);
      if (mounted) {
        setState(() {
          _articles.addAll(newArticles);
          _page = nextPage;
          _hasMore = newArticles.length == 10;
          _isLoadingMore = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _articles.clear();
      _page = 0;
      _hasMore = true;
      _isOffline = false;
    });
    await _loadCacheThenNetwork();
  }

  Future<void> _toggleBookmark(int id) async {
    await NewsRepository.toggleBookmark(id);
    await _loadBookmarks();
  }

  List<NewsArticle> get _filteredArticles {
    if (_selectedCategory == null) return _articles;
    return _articles
        .where((a) => a.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News Reader'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_isOffline)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Chip(
                label: Text('OFFLINE',
                    style: TextStyle(fontSize: 10, color: Colors.white)),
                backgroundColor: Colors.orange,
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: _isLoadingFirst
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.all(16),
                itemCount: _filteredArticles.length + 1,
                itemBuilder: (context, index) {
                  if (index == _filteredArticles.length) {
                    if (_isLoadingMore) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (!_hasMore) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text('— End of feed —',
                              style: TextStyle(color: Colors.grey)),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }

                  final article = _filteredArticles[index];
                  final isBookmarked = _bookmarks.contains(article.id);

                  return _ArticleCard(
                    article: article,
                    isBookmarked: isBookmarked,
                    onBookmark: () => _toggleBookmark(article.id),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ArticleDetailScreen(article: article),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Article card
// ─────────────────────────────────────────────────────────────────────────────

class _ArticleCard extends StatelessWidget {
  final NewsArticle article;
  final bool isBookmarked;
  final VoidCallback onBookmark;
  final VoidCallback onTap;

  const _ArticleCard({
    required this.article,
    required this.isBookmarked,
    required this.onBookmark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            CachedNetworkImage(
              imageUrl: article.imageUrl,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                height: 160,
                color: Colors.grey.shade200,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (_, __, ___) => Container(
                height: 160,
                color: Colors.grey.shade200,
                child: const Icon(Icons.broken_image, size: 40),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category chip
                  Chip(
                    label: Text(article.category,
                        style: const TextStyle(fontSize: 11)),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    article.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('Article #${article.id}',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey)),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          isBookmarked
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: isBookmarked
                              ? Colors.deepPurple
                              : Colors.grey,
                        ),
                        onPressed: onBookmark,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Article detail screen
// ─────────────────────────────────────────────────────────────────────────────

class ArticleDetailScreen extends StatelessWidget {
  final NewsArticle article;
  const ArticleDetailScreen({required this.article, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article.category),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
              imageUrl: article.imageUrl,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                height: 220,
                color: Colors.grey.shade200,
                child: const Icon(Icons.broken_image, size: 48),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Chip(
                    label: Text(article.category),
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.title,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    // Repeat body to simulate a longer article
                    '${article.body}\n\n${article.body}\n\n${article.body}',
                    style: const TextStyle(fontSize: 15, height: 1.7),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Article ID: ${article.id} • Author ID: ${article.userId}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
