/// Demo 04 — Deep Linking with GoRouter.
///
/// **Concepts covered:**
/// - Deep link = a URL that opens a specific page directly from outside the app
/// - Example: `myapp://products/42` → opens product 42 detail directly
/// - GoRouter automatically supports deep links via `initialLocation` and URL routing
/// - `redirect` → automatic routing logic (e.g. not logged in → go to /login)
/// - `refreshListenable` → router auto-redirects when auth state changes
///
/// **On simulator/device:** deep links can be tested via adb:
/// ```bash
/// adb shell am start -a android.intent.action.VIEW -d "http://myapp.com/articles/flutter"
/// ```
///
/// **Note:** In this demo we simulate deep links with buttons
/// since we don't need AndroidManifest/Info.plist setup for the demo.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Simulated auth state
// ─────────────────────────────────────────────────────────────────────────────

/// Simple auth state — in a real app this would use Riverpod or Provider.
/// `ChangeNotifier` is used so GoRouter can listen for changes via
/// `refreshListenable`.
class _AuthState extends ChangeNotifier {
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  void login() {
    _isLoggedIn = true;
    notifyListeners(); // tell GoRouter to re-evaluate the redirect
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }
}

// Global instance for demo (in a real app use Riverpod)
final _authState = _AuthState();

// ─────────────────────────────────────────────────────────────────────────────
// Dummy article data
// ─────────────────────────────────────────────────────────────────────────────

const _articles = {
  'flutter': 'Flutter is a cross-platform UI framework from Google.',
  'dart': 'Dart is the programming language used by Flutter.',
  'riverpod': 'Riverpod is a modern state management solution for Flutter.',
};

// ─────────────────────────────────────────────────────────────────────────────
// Router configuration with deep link + auth redirect
// ─────────────────────────────────────────────────────────────────────────────

GoRouter _buildRouter() => GoRouter(
      initialLocation: '/articles',

      // refreshListenable → GoRouter re-evaluates the redirect every time
      // _authState calls notifyListeners(). Without this, redirect is only
      // evaluated on the first navigation.
      refreshListenable: _authState,

      // redirect → called before every navigation.
      // Return null = proceed to the destination route.
      // Return a path = force redirect to that path.
      redirect: (context, state) {
        final isLoggedIn = _authState.isLoggedIn;
        final isOnLogin = state.uri.path == '/login';
        final isProtected = state.uri.path.startsWith('/profile');

        // Accessing a protected page without being logged in → redirect to /login
        if (isProtected && !isLoggedIn) {
          // Save the original destination in a query param so we can redirect back after login
          return '/login?redirect=${state.uri}';
        }

        // Already logged in but on the /login page → redirect to /articles
        if (isLoggedIn && isOnLogin) return '/articles';

        // null = no redirect, proceed to destination
        return null;
      },

      routes: [
        // Login page
        GoRoute(
          path: '/login',
          builder: (context, state) {
            // Get the redirect destination from query param
            final redirectTo = state.uri.queryParameters['redirect'];
            return _LoginScreen(redirectTo: redirectTo);
          },
        ),

        // Article list — accessible without login
        GoRoute(
          path: '/articles',
          builder: (context, state) => const _ArticleListScreen(),
          routes: [
            GoRoute(
              // Deep link: myapp://articles/flutter → flutter article
              path: ':slug',
              builder: (context, state) {
                final slug = state.pathParameters['slug']!;
                return _ArticleDetailScreen(slug: slug);
              },
            ),
          ],
        ),

        // Profile page — protected (requires login)
        GoRoute(
          path: '/profile',
          builder: (context, state) => const _ProfileScreen(),
        ),
      ],
    );

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

class DeepLinkingDemo extends StatelessWidget {
  const DeepLinkingDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Deep Linking Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      routerConfig: _buildRouter(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screens
// ─────────────────────────────────────────────────────────────────────────────

/// Article list with deep link simulation buttons.
class _ArticleListScreen extends StatelessWidget {
  const _ArticleListScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Articles'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
        ),
        actions: [
          // Button to go to profile (protected route)
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.go('/profile'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Deep link simulation
          Container(
            color: Colors.green.shade50,
            padding: const EdgeInsets.all(12),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '💡 Deep Link Simulation',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'The buttons below simulate a URL opened from outside the app.\n'
                  'In a real app, this URL comes from a notification / browser / QR code.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              children: _articles.keys
                  .map(
                    (slug) => ActionChip(
                      label: Text('Open /articles/$slug'),
                      avatar: const Icon(Icons.link, size: 16),
                      onPressed: () => context.go('/articles/$slug'),
                    ),
                  )
                  .toList(),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              children: _articles.entries
                  .map(
                    (e) => ListTile(
                      title: Text(e.key.toUpperCase()),
                      subtitle: Text(e.value, maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.go('/articles/${e.key}'),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Article detail screen.
class _ArticleDetailScreen extends StatelessWidget {
  final String slug;
  const _ArticleDetailScreen({required this.slug});

  @override
  Widget build(BuildContext context) {
    final content = _articles[slug] ?? 'Article "$slug" not found.';

    return Scaffold(
      appBar: AppBar(
        title: Text(slug.toUpperCase()),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(slug.toUpperCase(), style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            Text(content, style: const TextStyle(fontSize: 16, height: 1.6)),
            const SizedBox(height: 24),
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  '💡 This page\'s URL: /articles/$slug\n'
                  'If opened from outside the app (deep link), GoRouter renders this page directly.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Login screen — only accessible when not logged in.
class _LoginScreen extends StatelessWidget {
  final String? redirectTo;
  const _LoginScreen({this.redirectTo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: Colors.green),
              const SizedBox(height: 16),
              const Text(
                'You need to log in to access this page.',
                textAlign: TextAlign.center,
              ),
              if (redirectTo != null) ...[
                const SizedBox(height: 8),
                Text(
                  'After login, you will be redirected to:\n$redirectTo',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  _authState.login();
                  // The router will auto-redirect because of refreshListenable.
                  // But we also manually navigate to the original destination.
                  if (redirectTo != null) {
                    context.go(redirectTo!);
                  }
                },
                child: const Text('Login (Simulated)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Profile screen — protected, only accessible after login.
class _ProfileScreen extends StatelessWidget {
  const _ProfileScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/articles'),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified_user, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              'Welcome!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('This page is protected — only accessible after login.'),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () {
                _authState.logout();
                // refreshListenable will automatically trigger a redirect to /login
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
