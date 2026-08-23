/// Demo 03 — Bottom Navigation + Nested Navigator with GoRouter.
///
/// **Concepts covered:**
/// - `StatefulShellRoute` → shell route that preserves each tab's state
/// - Bottom navigation with 3 tabs (Home, Search, Profile)
/// - Each tab has its own navigator stack (nested navigator)
/// - State preservation: scroll position, form input, not lost when switching tabs
///
/// **Why StatefulShellRoute?**
/// With a plain ShellRoute, tab state resets every time you switch tabs.
/// StatefulShellRoute keeps each tab's state alive in the background.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Router configuration
// ─────────────────────────────────────────────────────────────────────────────

/// GoRouter with StatefulShellRoute for bottom navigation.
final _router = GoRouter(
  initialLocation: '/home',
  routes: [
    // StatefulShellRoute → wraps all tabs. Each branch = one tab.
    StatefulShellRoute.indexedStack(
      // builder = how to render the shell (includes BottomNavigationBar)
      builder: (context, state, navigationShell) {
        return _ScaffoldWithBottomNav(navigationShell: navigationShell);
      },
      branches: [
        // Branch 0 → Home Tab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const _HomeTab(),
              routes: [
                GoRoute(
                  path: 'detail/:item',
                  builder: (context, state) {
                    final item = state.pathParameters['item']!;
                    return _DetailTab(item: item);
                  },
                ),
              ],
            ),
          ],
        ),
        // Branch 1 → Search Tab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) => const _SearchTab(),
            ),
          ],
        ),
        // Branch 2 → Profile Tab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const _ProfileTab(),
            ),
          ],
        ),
      ],
    ),
  ],
);

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

class BottomNavDemo extends StatelessWidget {
  const BottomNavDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Bottom Nav Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shell scaffold (wrapper with BottomNavigationBar)
// ─────────────────────────────────────────────────────────────────────────────

/// Main scaffold that wraps all tabs.
/// `navigationShell` is the widget that renders the active tab's content.
class _ScaffoldWithBottomNav extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _ScaffoldWithBottomNav({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // navigationShell renders the currently active tab's content
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        // currentIndex → which tab is currently active
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          // goBranch() → switch to a specific tab with state preservation.
          // initialLocation: true → if the active tab is tapped again, go back to its root.
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab content
// ─────────────────────────────────────────────────────────────────────────────

/// Home Tab — has a detail sub-page (nested navigator).
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  static const _items = ['Flutter', 'Dart', 'Riverpod', 'GoRouter', 'Freezed'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          // This goes back to the Phase 3 menu, not to a previous tab
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Tap an item → opens detail (nested navigator inside this tab).\n'
              'Switch to another tab → come back here, position is preserved.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(_items[index]),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/home/detail/${_items[index]}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Detail screen inside the Home Tab — demonstrates nested navigator.
class _DetailTab extends StatelessWidget {
  final String item;
  const _DetailTab({required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          // pop() goes back to _HomeTab within the Home tab's stack (not out of the app)
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.article, size: 64, color: Colors.purple),
            const SizedBox(height: 16),
            Text(
              'Detail: $item',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('This is a detail page inside the Home tab.'),
          ],
        ),
      ),
    );
  }
}

/// Search Tab — has a TextField. State is not reset when switching tabs.
class _SearchTab extends StatefulWidget {
  const _SearchTab();

  @override
  State<_SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<_SearchTab> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Type something...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Text(
              'Text: "${_controller.text}"\n\n'
              '💡 Switch to another tab and come back — the text is still there!\n'
              'This is because StatefulShellRoute preserves state.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Profile Tab — simple static content.
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(radius: 48, child: Icon(Icons.person, size: 48)),
            SizedBox(height: 16),
            Text(
              'Faisal Bahri',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text('Flutter Developer'),
          ],
        ),
      ),
    );
  }
}
