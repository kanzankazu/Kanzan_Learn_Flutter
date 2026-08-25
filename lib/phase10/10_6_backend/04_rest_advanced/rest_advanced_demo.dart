/// Phase 10.6 — Topic 04: Advanced REST Patterns
///
/// Phase 4 covered basic Dio usage. This topic covers production-grade
/// REST API patterns used in real backend integrations.
///
/// Key concepts covered:
/// 1. OpenAPI / Swagger — API contract and code generation
/// 2. Cursor-based pagination — scalable, consistent pagination
/// 3. API versioning — how to handle breaking changes
/// 4. Rate limiting and retry strategy — handling 429 Too Many Requests
/// 5. Request deduplication — avoid duplicate concurrent requests
/// 6. Caching headers — ETag, If-None-Match, Cache-Control
/// 7. Multipart upload — files + metadata in one request
import 'package:flutter/material.dart';

void main() => runApp(const _App());
class _App extends StatelessWidget {
  const _App();
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'REST Advanced',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo), useMaterial3: true),
    home: const RestAdvancedDemo(),
  );
}

class RestAdvancedDemo extends StatelessWidget {
  const RestAdvancedDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('04 — REST Advanced'), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _h('1. OpenAPI Code Generation', Colors.indigo),
          _code(r'''
# OpenAPI Specification (swagger.yaml or openapi.json) defines:
# - All endpoints
# - Request/response schemas
# - Authentication
# - Error responses
#
# Generate Dart client automatically with openapi-generator:

# Install:
brew install openapi-generator

# Generate Dart client from OpenAPI spec:
openapi-generator generate \
  -i https://api.example.com/openapi.json \
  -g dart-dio \
  -o lib/generated/api_client

# Or use the Dart package openapi_generator_dart:
# dart pub global activate openapi_generator_dart
# Then annotate in build.yaml and run build_runner

# Result: type-safe API client with all endpoints as methods:
final api = DefaultApi(ApiClient(basePath: 'https://api.example.com'));
final user = await api.getUserById(userId: '123');
print(user.name);  // typed String, not dynamic!'''),

          const SizedBox(height: 20),
          _h('2. Cursor-Based Pagination', Colors.blue),
          _code(r'''
// Offset pagination (simple but has problems):
// GET /posts?page=2&limit=20
// Problem: if a post is added between page 1 and page 2,
// page 2 will have a duplicate or skip an item.

// Cursor pagination (correct):
// GET /posts?cursor=<opaque_cursor>&limit=20
// GET /posts?cursor=eyJpZCI6MTIzfQ==&limit=20
// The cursor encodes "where we left off" — no skips or duplicates.

class CursorPage<T> {
  final List<T> items;
  final String? nextCursor;   // null = no more pages
  final bool hasMore;

  const CursorPage({required this.items, required this.nextCursor, required this.hasMore});

  factory CursorPage.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) => CursorPage(
    items: (json['data'] as List).map((e) => fromJson(e as Map<String, dynamic>)).toList(),
    nextCursor: json['next_cursor'] as String?,
    hasMore: json['has_more'] as bool? ?? false,
  );
}

// Riverpod infinite scroll:
@riverpod
class PostFeed extends _$PostFeed {
  final List<Post> _allPosts = [];
  String? _nextCursor;
  bool _hasMore = true;

  @override
  AsyncValue<List<Post>> build() => const AsyncData([]);

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;
    state = const AsyncLoading();

    final page = await ref.read(apiClientProvider)
        .getPosts(cursor: _nextCursor, limit: 20);

    _allPosts.addAll(page.items);
    _nextCursor = page.nextCursor;
    _hasMore = page.hasMore;
    state = AsyncData(List.from(_allPosts));
  }
}

// Trigger loadMore when user scrolls near the bottom:
NotificationListener<ScrollNotification>(
  onNotification: (n) {
    if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
      ref.read(postFeedProvider.notifier).loadMore();
    }
    return false;
  },
  child: ...,
)'''),

          const SizedBox(height: 20),
          _h('3. Rate Limiting + Retry with Dio', Colors.orange),
          _code(r'''
// Dio interceptor that handles 429 Too Many Requests
class RateLimitInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 429) {
      // Server tells us when to retry via Retry-After header
      final retryAfter = err.response?.headers['retry-after']?.first;
      final seconds = int.tryParse(retryAfter ?? '') ?? 5;

      await Future.delayed(Duration(seconds: seconds));

      // Retry the request
      try {
        final response = await err.requestOptions.dioInstance.fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }
    handler.next(err);
  }
}

// Exponential back-off for generic failures
class RetryInterceptor extends Interceptor {
  static const _maxRetries = 3;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final attempt = err.requestOptions.extra['attempt'] as int? ?? 0;
    final isRetryable = [408, 500, 502, 503, 504].contains(err.response?.statusCode);

    if (isRetryable && attempt < _maxRetries) {
      final delay = Duration(milliseconds: 200 * (1 << attempt)); // 200ms, 400ms, 800ms
      await Future.delayed(delay);

      err.requestOptions.extra['attempt'] = attempt + 1;
      try {
        final response = await err.requestOptions.dioInstance.fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }
    handler.next(err);
  }
}'''),

          const SizedBox(height: 20),
          _h('4. Multipart File Upload', Colors.green),
          _code(r'''
// Upload a profile photo with metadata in one request

Future<String> uploadProfilePhoto({
  required String userId,
  required File imageFile,
  required String contentType, // 'image/jpeg' or 'image/png'
}) async {
  // Build multipart form data
  final formData = FormData.fromMap({
    // File field
    'photo': await MultipartFile.fromFile(
      imageFile.path,
      filename: 'profile.jpg',
      contentType: MediaType.parse(contentType),
    ),
    // Metadata fields alongside the file
    'userId': userId,
    'timestamp': DateTime.now().toIso8601String(),
  });

  final response = await _dio.post(
    '/users/$userId/photo',
    data: formData,
    onSendProgress: (sent, total) {
      // Update a progress indicator
      final progress = sent / total;
      _progressNotifier.value = progress;
    },
  );

  return response.data['photoUrl'] as String;
}

// Cancel in-progress upload:
final cancelToken = CancelToken();

Future<void> cancelUpload() async {
  cancelToken.cancel('User cancelled upload');
}

// Pass the token to the request:
await _dio.post('/upload', data: formData, cancelToken: cancelToken);'''),

          const SizedBox(height: 16),
          _card(color: Colors.indigo.shade50, child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Key Takeaways', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• OpenAPI spec → openapi-generator → type-safe Dart client (no Map<String, dynamic>)'),
              Text('• Cursor pagination: no skips/duplicates — use for infinite scroll'),
              Text('• Retry-After header tells you exactly how long to wait on 429'),
              Text('• Exponential back-off: 200ms → 400ms → 800ms between retries'),
              Text('• MultipartFile for file uploads; onSendProgress for progress indicators'),
              Text('• CancelToken = cancel an in-flight request (e.g. user navigates away)'),
            ],
          )),
        ],
      ),
    );
  }
}

Widget _h(String t, Color c) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(t, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: c)));
Widget _code(String s) => Container(width: double.infinity, margin: const EdgeInsets.only(bottom: 4), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF1E1E2E), borderRadius: BorderRadius.circular(6)), child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text(s, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Color(0xFFCDD6F4)))));
Widget _card({required Color color, required Widget child}) => Card(color: color, child: Padding(padding: const EdgeInsets.all(12), child: child));
