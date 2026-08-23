/// Demo 01 — Dio Basics: GET, POST, Interceptors, Error Handling.
///
/// **Concepts covered:**
/// - Why Dio instead of the built-in `http` package
///   → interceptors, retry, cancel token, timeout, form data out of the box
/// - Creating a Dio instance with BaseOptions (baseUrl, headers, timeout)
/// - GET request with query parameters
/// - POST request with JSON body
/// - Path parameters: `/users/{id}`
/// - Error handling with DioException (status codes, network errors)
/// - LogInterceptor — logs every request/response to the console
/// - Custom interceptor — attach auth token to every request
/// - CancelToken — cancel an in-flight request
///
/// **Public API used:** https://jsonplaceholder.typicode.com (free, no key needed)
library;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Dio instance — shared across the demo
// ─────────────────────────────────────────────────────────────────────────────

/// Creates a configured Dio instance.
/// In a real app this lives in a DI container (Riverpod provider / get_it).
Dio _buildDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // LogInterceptor — prints every request + response to the console.
  // Disable in production (set requestBody/responseBody to false).
  dio.interceptors.add(
    LogInterceptor(requestBody: true, responseBody: true),
  );

  // Custom auth interceptor — adds a fake Bearer token to every request.
  // In a real app, read the token from secure storage.
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['Authorization'] = 'Bearer fake-token-for-demo';
        handler.next(options); // continue the request
      },
      onError: (error, handler) {
        // Global error handling — e.g. redirect to login on 401
        if (error.response?.statusCode == 401) {
          debugPrint('[Auth] Token expired — redirect to login');
        }
        handler.next(error); // let the caller handle the error too
      },
    ),
  );

  return dio;
}

final _dio = _buildDio();

// ─────────────────────────────────────────────────────────────────────────────
// Simple model (manual fromJson — no code gen needed for demos)
// ─────────────────────────────────────────────────────────────────────────────

/// Represents a single post from the JSONPlaceholder API.
///
/// This is an immutable data class — all fields are `final`.
/// Immutability is important in Flutter because widgets rebuild based on
/// value changes; mutable objects can cause subtle bugs where the UI
/// doesn't update because the reference hasn't changed.
///
/// **fromJson pattern:**
/// Every model that comes from an API needs a `factory fromJson` constructor.
/// The `as Type` casts are intentional — they throw a clear [TypeError] early
/// if the server sends an unexpected type (e.g. a String where you expect an int).
/// This is better than silently getting `null` or wrong data deep in the UI.
///
/// **toJson pattern:**
/// Needed when sending data back to the server (POST/PUT requests).
/// Returns a plain [Map<String, dynamic>] that Dio can serialize to JSON.
class Post {
  final int id;
  final int userId; // who authored the post (foreign key to users)
  final String title;
  final String body; // content of the post

  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        id: json['id'] as int,
        userId: json['userId'] as int,
        title: json['title'] as String,
        body: json['body'] as String,
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'title': title,
        'body': body,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

class DioBasicsDemo extends StatelessWidget {
  const DioBasicsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dio Basics Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
        useMaterial3: true,
      ),
      home: const _DioMenuScreen(),
    );
  }
}

class _DioMenuScreen extends StatelessWidget {
  const _DioMenuScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dio Basics'),
        backgroundColor: Colors.cyan,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DemoCard(
            title: '1. GET — Fetch list of posts',
            subtitle: 'GET /posts?_limit=5',
            color: Colors.cyan,
            child: const _GetListDemo(),
          ),
          const SizedBox(height: 12),
          _DemoCard(
            title: '2. GET — Fetch single post by ID',
            subtitle: 'GET /posts/:id (path parameter)',
            color: Colors.teal,
            child: const _GetByIdDemo(),
          ),
          const SizedBox(height: 12),
          _DemoCard(
            title: '3. POST — Create a new post',
            subtitle: 'POST /posts (JSON body)',
            color: Colors.green,
            child: const _PostDemo(),
          ),
          const SizedBox(height: 12),
          _DemoCard(
            title: '4. Error Handling',
            subtitle: 'GET /posts/99999 (triggers 404)',
            color: Colors.orange,
            child: const _ErrorHandlingDemo(),
          ),
          const SizedBox(height: 12),
          _DemoCard(
            title: '5. Cancel Token',
            subtitle: 'Start a slow request then cancel it',
            color: Colors.red,
            child: const _CancelTokenDemo(),
          ),
        ],
      ),
    );
  }
}

/// An expandable card used to present each Dio demo section.
///
/// Extracting this helper widget keeps [_DioMenuScreen.build()] clean —
/// instead of repeating the same Card/ExpansionTile structure 5 times,
/// we define it once and pass in the parts that vary (title, subtitle, child).
///
/// This is the "composition over inheritance" principle in practice.
class _DemoCard extends StatelessWidget {
  final String title;
  final String subtitle; // brief description shown in the collapsed state
  final Color color;     // icon accent color to distinguish each demo visually
  final Widget child;    // the actual demo content, shown when expanded

  const _DemoCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        leading: Icon(Icons.code, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        children: [
          Padding(padding: const EdgeInsets.all(12), child: child),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Demo 1 — GET list
// ─────────────────────────────────────────────────────────────────────────────

class _GetListDemo extends StatefulWidget {
  const _GetListDemo();

  @override
  State<_GetListDemo> createState() => _GetListDemoState();
}

class _GetListDemoState extends State<_GetListDemo> {
  List<Post> _posts = [];
  bool _loading = false;
  String? _error;

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // queryParameters → adds ?_limit=5 to the URL automatically.
      // Dio URL-encodes the map; you never need to build the query string manually.
      final response = await _dio.get(
        '/posts',
        queryParameters: {'_limit': 5},
      );
      // response.data is already parsed from JSON by Dio — it's a List<dynamic> here.
      // We cast each element to Map<String, dynamic> and pass to Post.fromJson.
      final data = response.data as List;
      setState(() => _posts = data.map((e) => Post.fromJson(e)).toList());
    } on DioException catch (e) {
      // Catch DioException specifically — it gives you structured error info.
      // Catching Exception or Object would lose the DioExceptionType information.
      setState(() => _error = _formatDioError(e));
    } finally {
      // finally block ALWAYS runs — whether try succeeded or catch ran.
      // Perfect for cleanup that must happen regardless: stop loading spinner,
      // close a dialog, release a lock, etc.
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilledButton.icon(
          onPressed: _loading ? null : _fetch,
          icon: const Icon(Icons.download),
          label: const Text('Fetch Posts'),
        ),
        const SizedBox(height: 12),
        if (_loading) const LinearProgressIndicator(),
        if (_error != null)
          _ErrorBox(_error!),
        ..._posts.map(
          (p) => ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 14,
              child: Text('${p.id}', style: const TextStyle(fontSize: 11)),
            ),
            title: Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text('userId: ${p.userId}'),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Demo 2 — GET by ID
// ─────────────────────────────────────────────────────────────────────────────

class _GetByIdDemo extends StatefulWidget {
  const _GetByIdDemo();

  @override
  State<_GetByIdDemo> createState() => _GetByIdDemoState();
}

class _GetByIdDemoState extends State<_GetByIdDemo> {
  Post? _post;
  bool _loading = false;
  String? _error;
  final _ctrl = TextEditingController(text: '1');

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    final id = int.tryParse(_ctrl.text);
    if (id == null) return;
    setState(() {
      _loading = true;
      _error = null;
      _post = null;
    });
    try {
      // Path parameter — /posts/1, /posts/42, etc.
      final response = await _dio.get('/posts/$id');
      setState(() => _post = Post.fromJson(response.data));
    } on DioException catch (e) {
      setState(() => _error = _formatDioError(e));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Post ID (1–100)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: _loading ? null : _fetch,
              child: const Text('Fetch'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_loading) const LinearProgressIndicator(),
        if (_error != null) _ErrorBox(_error!),
        if (_post != null)
          Card(
            color: Colors.teal.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID: ${_post!.id}  •  userId: ${_post!.userId}'),
                  const SizedBox(height: 4),
                  Text(_post!.title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(_post!.body,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Demo 3 — POST
// ─────────────────────────────────────────────────────────────────────────────

class _PostDemo extends StatefulWidget {
  const _PostDemo();

  @override
  State<_PostDemo> createState() => _PostDemoState();
}

class _PostDemoState extends State<_PostDemo> {
  Post? _created;
  bool _loading = false;
  String? _error;
  final _titleCtrl = TextEditingController(text: 'My new post');
  final _bodyCtrl = TextEditingController(text: 'Hello from Dio!');

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    setState(() {
      _loading = true;
      _error = null;
      _created = null;
    });
    try {
      final response = await _dio.post(
        '/posts',
        data: Post(
          id: 0,
          userId: 1,
          title: _titleCtrl.text.trim(),
          body: _bodyCtrl.text.trim(),
        ).toJson(),
      );
      // JSONPlaceholder returns id: 101 for every new post
      setState(() => _created = Post.fromJson(response.data));
    } on DioException catch (e) {
      setState(() => _error = _formatDioError(e));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _titleCtrl,
          decoration: const InputDecoration(
            labelText: 'Title',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _bodyCtrl,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Body',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _loading ? null : _post,
          icon: const Icon(Icons.send),
          label: const Text('POST'),
        ),
        if (_loading) const Padding(
          padding: EdgeInsets.only(top: 8),
          child: LinearProgressIndicator(),
        ),
        if (_error != null) _ErrorBox(_error!),
        if (_created != null)
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('✅ Created!',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.green)),
                  Text('Returned ID: ${_created!.id}'),
                  Text('Title: ${_created!.title}'),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Demo 4 — Error handling
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorHandlingDemo extends StatefulWidget {
  const _ErrorHandlingDemo();

  @override
  State<_ErrorHandlingDemo> createState() => _ErrorHandlingDemoState();
}

class _ErrorHandlingDemoState extends State<_ErrorHandlingDemo> {
  String _result = 'Press a button to trigger an error scenario.';
  bool _loading = false;

  Future<void> _trigger404() async {
    _run(() => _dio.get('/posts/99999'));
  }

  Future<void> _triggerTimeout() async {
    _run(() => _dio.get(
          '/posts/1',
          options: Options(receiveTimeout: const Duration(milliseconds: 1)),
        ));
  }

  Future<void> _run(Future<Response> Function() call) async {
    setState(() {
      _loading = true;
      _result = 'Loading...';
    });
    try {
      final res = await call();
      setState(() => _result = 'Success: ${res.statusCode}');
    } on DioException catch (e) {
      // DioExceptionType tells you WHY it failed
      setState(() => _result = _formatDioError(e));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          children: [
            OutlinedButton(
              onPressed: _loading ? null : _trigger404,
              child: const Text('Trigger 404'),
            ),
            OutlinedButton(
              onPressed: _loading ? null : _triggerTimeout,
              child: const Text('Trigger Timeout'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_loading) const LinearProgressIndicator(),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Text(_result, style: const TextStyle(fontFamily: 'monospace')),
        ),
        const SizedBox(height: 8),
        const Text(
          '💡 DioException types:\n'
          '• connectionTimeout / sendTimeout / receiveTimeout\n'
          '• badResponse → server replied (check statusCode)\n'
          '• connectionError → no internet\n'
          '• cancel → request cancelled by CancelToken',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Demo 5 — Cancel Token
// ─────────────────────────────────────────────────────────────────────────────

class _CancelTokenDemo extends StatefulWidget {
  const _CancelTokenDemo();

  @override
  State<_CancelTokenDemo> createState() => _CancelTokenDemoState();
}

class _CancelTokenDemoState extends State<_CancelTokenDemo> {
  String _status = 'Idle';
  CancelToken? _cancelToken;

  void _start() {
    final token = CancelToken();
    setState(() {
      _cancelToken = token;
      _status = 'Request in flight...';
    });

    _dio
        .get('/posts', cancelToken: token,
            queryParameters: {'_limit': 100})
        .then((res) {
          if (mounted) setState(() => _status = 'Done — got ${(res.data as List).length} items');
        })
        .catchError((e) {
          if (e is DioException && CancelToken.isCancel(e)) {
            if (mounted) setState(() => _status = 'Cancelled ✅');
          } else {
            if (mounted) setState(() => _status = 'Error: $e');
          }
        });
  }

  void _cancel() {
    _cancelToken?.cancel('User cancelled the request');
    setState(() => _cancelToken = null);
  }

  @override
  Widget build(BuildContext context) {
    final inFlight = _cancelToken != null && !_cancelToken!.isCancelled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            FilledButton(
              onPressed: inFlight ? null : _start,
              child: const Text('Start Request'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: inFlight ? _cancel : null,
              child: const Text('Cancel'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text('Status: $_status'),
        const SizedBox(height: 8),
        const Text(
          '💡 CancelToken is useful for:\n'
          '• Cancelling a search-as-you-type request when user types again\n'
          '• Cancelling a request when user leaves the screen',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper
// ─────────────────────────────────────────────────────────────────────────────

/// Formats a [DioException] into a human-readable string for display in the UI.
///
/// Always prefer switching on [DioException.type] (an enum) over checking
/// [DioException.message] with string contains — the message can change
/// across Dio versions, but the enum values are stable.
///
/// This function is a pure helper (no side effects, no state) — it's a
/// top-level function because it belongs to no specific class.
String _formatDioError(DioException e) {
  return switch (e.type) {
    DioExceptionType.connectionTimeout => 'Connection timeout',
    DioExceptionType.sendTimeout => 'Send timeout',
    DioExceptionType.receiveTimeout => 'Receive timeout — took too long',
    DioExceptionType.badResponse =>
      'Server error ${e.response?.statusCode}: ${e.response?.statusMessage}',
    DioExceptionType.cancel => 'Request was cancelled',
    DioExceptionType.connectionError => 'No internet connection',
    _ => 'Unexpected error: ${e.message}',
  };
}

/// Reusable error display box — a red-bordered container with an error icon.
///
/// Extracting this into a widget means every demo section shows the same
/// consistent error UI. If you want to change how errors look app-wide,
/// you change this one widget.
class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: const TextStyle(color: Colors.red, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
