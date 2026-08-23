/// Demo 01 — Named Routes & GoRouter Basics.
///
/// **Concepts covered:**
/// - What GoRouter is and why it's better than Navigator 1.0
/// - Defining routes with path strings (`/home`, `/detail`)
/// - Navigation with `context.go()` and `context.push()`
/// - Difference between `go()` and `push()`: go = replace stack, push = add to stack
/// - `redirect` for automatic route guards (e.g. auth check)
/// - `errorBuilder` for 404 pages
///
/// **Why GoRouter?**
/// Navigator 1.0 (`Navigator.push()`) doesn't support deep links or web URLs.
/// GoRouter is Flutter's official solution for declarative routing.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Entry point for the GoRouter demo. Creates its own GoRouter instance
/// so it doesn't interfere with the Phase 3 menu navigation.
class GoRouterBasicsDemo extends StatelessWidget {
  const GoRouterBasicsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    // Router definition — this is the "map" of all pages in our app.
    // In real apps this lives in a separate file (e.g. router.dart),
    // but here it's combined for easier learning.
    final router = GoRouter(
      // The first route opened when the app starts.
      initialLocation: '/home',

      // List of all available routes.
      routes: [
        GoRoute(
          path: '/home',
          // `name` is optional but strongly recommended — enables navigation by name
          // without hardcoding path strings.
          name: 'home',
          builder: (context, state) => const _HomeScreen(),

          // Sub-routes: pages "nested" under /home.
          // Full URL becomes /home/detail, not /detail.
          routes: [
            GoRoute(
              path: 'detail', // relative → /home/detail
              name: 'detail',
              builder: (context, state) => const _DetailScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/about',
          name: 'about',
          builder: (context, state) => const _AboutScreen(),
        ),
      ],

      // Shown when the user navigates to an unknown URL.
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('404 — Page Not Found')),
        body: Center(
          child: Text(
            'Path "${state.uri}" is not recognized.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );

    // MaterialApp.router = how to connect GoRouter to a Flutter app.
    return MaterialApp.router(
      title: 'GoRouter Basics Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Demo screens
// ─────────────────────────────────────────────────────────────────────────────

/// Home screen — demonstrates navigation with go() and push().
class _HomeScreen extends StatelessWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'GoRouter Basics',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check the source code for full explanations.\n\n'
              'Two main navigation methods:',
            ),
            const SizedBox(height: 24),

            // context.go() → REPLACES the navigation stack.
            // Back button is not available after go().
            // Use case: login → home (don't want to go back to login).
            FilledButton.icon(
              onPressed: () => context.go('/home/detail'),
              icon: const Icon(Icons.swap_horiz),
              label: const Text('go() to Detail\n(back button disappears)'),
            ),
            const SizedBox(height: 12),

            // context.push() → ADDS to the navigation stack.
            // Back button is available.
            // Use case: home → profile (want to go back to home).
            OutlinedButton.icon(
              onPressed: () => context.push('/about'),
              icon: const Icon(Icons.info_outline),
              label: const Text('push() to About\n(back button available)'),
            ),
            const SizedBox(height: 12),

            // Navigate by name — safer than hardcoding path strings.
            OutlinedButton.icon(
              onPressed: () => context.goNamed('about'),
              icon: const Icon(Icons.label_outline),
              label: const Text('goNamed() to About\n(navigate by name)'),
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              '💡 Difference between go() and push():',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '• go() → replaces the stack. Cannot go back.\n'
              '• push() → adds to the stack. Can go back.\n'
              '• goNamed() → same as go() but uses a name instead of a path.',
            ),
          ],
        ),
      ),
    );
  }
}

/// Detail screen — demonstrates going back with context.pop().
class _DetailScreen extends StatelessWidget {
  const _DetailScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        // context.canPop() → checks if there's a stack to pop.
        // Because we navigated with go(), the stack is empty → back button won't appear automatically.
        // We override it with a manual leading button.
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              )
            : IconButton(
                icon: const Icon(Icons.home),
                onPressed: () => context.go('/home'),
              ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.article, size: 64, color: Colors.teal),
            const SizedBox(height: 16),
            const Text(
              'Detail Page',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Opened with context.go() from Home.'),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go('/home'),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

/// About screen — opened with push(), so the back button appears automatically.
class _AboutScreen extends StatelessWidget {
  const _AboutScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        // GoRouter adds the back button automatically because this was opened with push().
      ),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info, size: 64, color: Colors.teal),
            SizedBox(height: 16),
            Text(
              'About Page',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Opened with context.push() from Home.\nBack button is automatically available.'),
          ],
        ),
      ),
    );
  }
}
