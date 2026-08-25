/// Phase 10.1 — Topic 05: Dart Frog (Server-side Dart)
///
/// Dart Frog is a fast, minimalist backend framework for Dart.
/// It lets you write your Flutter app's API server in the same language
/// as your frontend — sharing models, validation logic, and utilities.
///
/// Key concepts covered:
/// 1. What Dart Frog is and when to use it
/// 2. Project structure — routes/ folder maps to URL paths
/// 3. Request handlers — RequestContext, Request, Response
/// 4. Middleware — authentication, CORS, logging
/// 5. Route parameters — /users/[id].dart
/// 6. Dependency injection — provider middleware
/// 7. Testing Dart Frog routes
/// 8. Deployment — Docker, fly.io, Railway
///
/// NOTE: This is a CONCEPT DEMO file. Dart Frog runs as a separate
/// server-side project — not inside the Flutter app. The code snippets
/// show what a Dart Frog project looks like.
///
/// To create a real Dart Frog project:
/// ```bash
/// dart pub global activate dart_frog_cli
/// dart_frog create my_api
/// cd my_api
/// dart_frog dev   # starts server at localhost:8080
/// ```
import 'package:flutter/material.dart';

void main() => runApp(const _StandaloneApp());

class _StandaloneApp extends StatelessWidget {
  const _StandaloneApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dart Frog Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      home: const DartFrogDemo(),
    );
  }
}

/// Demo screen explaining Dart Frog server-side Dart concepts.
class DartFrogDemo extends StatelessWidget {
  const DartFrogDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('05 — Dart Frog'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: SelectionArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _card(
              color: Colors.brown.shade50,
              child: const Text(
                'Dart Frog = Express.js but for Dart.\n\n'
                'Ideal when your team already knows Dart and wants to share '
                'models/validation between frontend and backend. '
                'NOT a replacement for a full backend like NestJS or Django — '
                'use it for lightweight APIs, BFF (Backend For Frontend), and '
                'serverless functions.',
                style: TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),

            // ── 1. Setup ─────────────────────────────────────────────────
            _header('1. Setup & Project Structure', Colors.brown),
            _code(r'''
# Install Dart Frog CLI
dart pub global activate dart_frog_cli

# Create a new project
dart_frog create my_api
cd my_api

# Start dev server (auto-reloads on file changes)
dart_frog dev

# Project structure:
my_api/
├── routes/           ← file path = URL path (file-based routing!)
│   ├── index.dart    → GET /
│   ├── _middleware.dart → applies to all routes
│   ├── users/
│   │   ├── index.dart   → GET /users  (list all users)
│   │   └── [id].dart    → GET /users/123  ([id] = dynamic segment)
├── lib/
│   ├── models/       ← shared models (can be used by Flutter app too!)
│   └── services/
└── pubspec.yaml'''),

            const SizedBox(height: 20),

            // ── 2. Route handler ─────────────────────────────────────────
            _header('2. Route Handler', Colors.teal),
            _code(r'''
// routes/users/index.dart
import 'package:dart_frog/dart_frog.dart';

// Each file exports a single handler function called "onRequest"
Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.get  => _getUsers(context),
    HttpMethod.post => _createUser(context),
    _ => Response(statusCode: 405), // Method Not Allowed
  };
}

Future<Response> _getUsers(RequestContext context) async {
  // Read query parameters
  final params = context.request.uri.queryParameters;
  final page = int.tryParse(params['page'] ?? '1') ?? 1;

  // Get the service from the request context (injected via middleware)
  final userService = context.read<UserService>();
  final users = await userService.getUsers(page: page);

  // Return JSON response
  return Response.json(body: {
    'data': users.map((u) => u.toJson()).toList(),
    'page': page,
  });
}

Future<Response> _createUser(RequestContext context) async {
  final body = await context.request.json() as Map<String, dynamic>;

  // Input validation
  if (body['name'] == null || (body['name'] as String).isEmpty) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'name is required'},
    );
  }

  final userService = context.read<UserService>();
  final user = await userService.createUser(name: body['name'] as String);

  return Response.json(statusCode: 201, body: user.toJson());
}'''),

            const SizedBox(height: 20),

            // ── 3. Dynamic route ─────────────────────────────────────────
            _header('3. Dynamic Route Parameters', Colors.indigo),
            _code(r'''
// routes/users/[id].dart
// [id] in the filename becomes a URL parameter
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  // "id" is injected automatically from the URL
  // e.g. GET /users/123 → id = "123"
  return switch (context.request.method) {
    HttpMethod.get    => _getUser(context, id),
    HttpMethod.put    => _updateUser(context, id),
    HttpMethod.delete => _deleteUser(context, id),
    _ => Response(statusCode: 405),
  };
}

Future<Response> _getUser(RequestContext context, String id) async {
  final userService = context.read<UserService>();
  final user = await userService.getUserById(id);

  if (user == null) {
    return Response.json(statusCode: 404, body: {'error': 'User not found'});
  }

  return Response.json(body: user.toJson());
}'''),

            const SizedBox(height: 20),

            // ── 4. Middleware ─────────────────────────────────────────────
            _header('4. Middleware', Colors.orange),
            _code(r'''
// routes/_middleware.dart
// Applies to ALL routes in this directory and subdirectories

import 'package:dart_frog/dart_frog.dart';

Handler middleware(Handler handler) {
  return handler
      .use(requestLogger())        // log every request
      .use(cors())                 // add CORS headers
      .use(_authMiddleware())      // check auth token
      .use(_injectServices());     // inject services into context
}

// Custom auth middleware
Middleware _authMiddleware() {
  return (handler) => (context) async {
    final path = context.request.uri.path;

    // Skip auth for public routes
    if (path == '/health' || path == '/auth/login') {
      return handler(context);
    }

    final token = context.request.headers['Authorization'];
    if (token == null || !token.startsWith('Bearer ')) {
      return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});
    }

    // Validate token
    final userId = await verifyToken(token.substring(7));
    if (userId == null) {
      return Response.json(statusCode: 401, body: {'error': 'Invalid token'});
    }

    // Attach userId to context for downstream handlers
    return handler(context.provide(() => AuthUser(id: userId)));
  };
}

// Inject services so route handlers can access them via context.read<T>()
Middleware _injectServices() {
  final db = Database.connect();
  return (handler) => (context) {
    return handler(
      context
          .provide<UserService>(() => UserService(db))
          .provide<AuthService>(() => AuthService(db)),
    );
  };
}'''),

            const SizedBox(height: 20),

            // ── 5. Shared models ─────────────────────────────────────────
            _header('5. Sharing Models with Flutter', Colors.green),
            _card(
              color: Colors.green.shade50,
              child: const Text(
                'The biggest advantage of Dart Frog: your Flutter app and your '
                'API server share the same model classes.\n\n'
                'Create a shared Dart package:',
                style: TextStyle(fontSize: 13),
              ),
            ),
            _code(r'''
# Monorepo structure:
my_project/
├── my_app/          ← Flutter app
├── my_api/          ← Dart Frog server
└── my_models/       ← shared Dart package

# my_models/lib/src/user.dart
class User {
  final String id;
  final String name;
  final String email;

  const User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) => User(
    id:    json['id'] as String,
    name:  json['name'] as String,
    email: json['email'] as String,
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email};
}

# Both Flutter app AND Dart Frog API add this to their pubspec.yaml:
dependencies:
  my_models:
    path: ../my_models

# Result: zero JSON mismatch bugs — both sides use the exact same class'''),

            const SizedBox(height: 20),

            // ── 6. Deploy ────────────────────────────────────────────────
            _header('6. Build & Deploy', Colors.red),
            _code(r'''
# Build for production
dart_frog build         # → build/ folder

# Docker deploy (Dart Frog generates a Dockerfile automatically)
docker build -t my-api .
docker run -p 8080:8080 my-api

# Deploy to fly.io (free tier available):
fly launch
fly deploy

# Deploy to Railway:
# 1. Push to GitHub
# 2. Connect repo to Railway
# 3. Set start command: dart /app/build/bin/server.dart

# Environment variables:
# Use dotenv or fly.io secrets:
fly secrets set DATABASE_URL=postgres://...
fly secrets set JWT_SECRET=super_secret_key

# Health check endpoint (required by most platforms):
// routes/health.dart
Response onRequest(RequestContext context) {
  return Response.json(body: {'status': 'ok'});
}'''),

            const SizedBox(height: 20),

            // ── 7. Testing ────────────────────────────────────────────────
            _header('7. Testing Dart Frog Routes', Colors.purple),
            _code(r'''
// test/routes/users_test.dart
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_test/dart_frog_test.dart';
import 'package:test/test.dart';

import '../../routes/users/index.dart' as handler;

void main() {
  group('GET /users', () {
    test('returns 200 with user list', () async {
      // Create a mock request
      final request = Request.get(Uri.parse('http://localhost/users'));

      // Create a mock context with injected fake service
      final context = RequestContext.test(
        request: request,
        // Inject a fake UserService that returns test data
        providers: [
          provider<UserService>(() => FakeUserService()),
        ],
      );

      // Call the handler
      final response = await handler.onRequest(context);

      // Assert
      expect(response.statusCode, equals(200));
      final body = await response.json() as Map;
      expect(body['data'], isA<List>());
    });
  });
}'''),

            const SizedBox(height: 16),
            _card(
              color: Colors.brown.shade50,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Key Takeaways',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('• File-based routing: routes/users/[id].dart → /users/:id'),
                  Text('• onRequest handler receives RequestContext — all data flows through it'),
                  Text('• Middleware: auth, CORS, logging, DI all chained with .use()'),
                  Text('• Shared models package = zero JSON mismatch between frontend & backend'),
                  Text('• dart_frog build → Docker container → deploy to fly.io/Railway'),
                  Text('• Use Dart Frog as BFF (Backend For Frontend), not as a full monolith'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
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
