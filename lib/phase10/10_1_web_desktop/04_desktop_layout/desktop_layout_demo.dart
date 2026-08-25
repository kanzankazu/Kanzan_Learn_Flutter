/// Phase 10.1 — Topic 04: Desktop Layout
///
/// Desktop adds a third dimension to responsive design:
/// - Larger screens (1200–2560px)
/// - Mouse + keyboard as primary input (no touch)
/// - Window resizing (users drag the window border)
/// - Multiple windows (open same app in multiple windows)
/// - Right-click context menus
/// - Keyboard shortcuts (Ctrl+S, Ctrl+N, etc.)
/// - Drag and drop
/// - Hover states everywhere
///
/// Key concepts covered:
/// 1. Adaptive navigation — BottomNav → Rail → Drawer based on width
/// 2. Split-pane layout (master-detail) — list on left, detail on right
/// 3. window_manager package — resize, minimize, title, always on top
/// 4. Keyboard shortcuts — [Shortcuts] widget + [Intent] + [Actions]
/// 5. Context menu (right-click) — [GestureDetector] + [showMenu]
/// 6. Drag and drop — [Draggable] + [DragTarget]
/// 7. Window management — multi-window support (desktop only)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const _StandaloneApp());

class _StandaloneApp extends StatelessWidget {
  const _StandaloneApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Desktop Layout Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      // Register global keyboard shortcuts at the app root
      home: _ShortcutWrapper(child: const DesktopLayoutDemo()),
    );
  }
}

/// Wraps the app with global keyboard shortcuts.
class _ShortcutWrapper extends StatefulWidget {
  final Widget child;
  const _ShortcutWrapper({required this.child});

  @override
  State<_ShortcutWrapper> createState() => _ShortcutWrapperState();
}

class _ShortcutWrapperState extends State<_ShortcutWrapper> {
  String _lastShortcut = 'Press Ctrl+N, Ctrl+S, or Ctrl+F';

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      // Map keyboard combos to Intents (abstract actions)
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyN):
            const _NewDocumentIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS):
            const _SaveIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyF):
            const _SearchIntent(),
      },
      child: Actions(
        // Map Intents to actual handlers
        actions: {
          _NewDocumentIntent:
              CallbackAction<_NewDocumentIntent>(
                  onInvoke: (_) {
                    setState(
                        () => _lastShortcut = 'Ctrl+N → New Document');
                    return null;
                  }),
          _SaveIntent:
              CallbackAction<_SaveIntent>(
                  onInvoke: (_) {
                    setState(() => _lastShortcut = 'Ctrl+S → Save');
                    return null;
                  }),
          _SearchIntent:
              CallbackAction<_SearchIntent>(
                  onInvoke: (_) {
                    setState(() => _lastShortcut = 'Ctrl+F → Search');
                    return null;
                  }),
        },
        child: Focus(
          autofocus: true, // capture keyboard events from the start
          child: widget.child,
        ),
      ),
    );
  }
}

// ── Intent declarations ────────────────────────────────────────────────────────
// Intents are abstract actions — decoupled from the actual implementation.
// This lets you bind the same action to different keyboard combos or buttons.

class _NewDocumentIntent extends Intent { const _NewDocumentIntent(); }
class _SaveIntent extends Intent { const _SaveIntent(); }
class _SearchIntent extends Intent { const _SearchIntent(); }

// ── Main demo screen ───────────────────────────────────────────────────────────

/// Desktop layout demo with adaptive navigation + master-detail split pane.
class DesktopLayoutDemo extends StatefulWidget {
  const DesktopLayoutDemo({super.key});

  @override
  State<DesktopLayoutDemo> createState() => _DesktopLayoutDemoState();
}

class _DesktopLayoutDemoState extends State<DesktopLayoutDemo> {
  int _selectedNav = 0;
  int? _selectedItem;

  // Sample items for the master list
  static const _items = [
    'Project Alpha — Due Aug 30',
    'Project Beta — Due Sep 15',
    'Project Gamma — Due Oct 1',
    'Project Delta — Due Oct 20',
    'Project Epsilon — Due Nov 5',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        final w = constraints.maxWidth;

        if (w < 600) {
          // ── Compact: BottomNavigationBar ─────────────────────────────
          return Column(
            children: [
              Expanded(child: _content()),
              NavigationBar(
                selectedIndex: _selectedNav,
                onDestinationSelected: (i) =>
                    setState(() => _selectedNav = i),
                destinations: _navDestinations,
              ),
            ],
          );
        } else if (w < 1100) {
          // ── Medium: NavigationRail (compact — icons only) ─────────────
          return Row(
            children: [
              NavigationRail(
                selectedIndex: _selectedNav,
                onDestinationSelected: (i) =>
                    setState(() => _selectedNav = i),
                extended: false, // icons only, no labels
                destinations: _navDestinations
                    .map((d) => NavigationRailDestination(
                          icon: Icon(Icons.circle_outlined),
                          label: Text(d.label),
                        ))
                    .toList(),
              ),
              const VerticalDivider(width: 1),
              Expanded(child: _content()),
            ],
          );
        } else {
          // ── Wide: Extended NavigationRail (icons + labels) ─────────────
          return Row(
            children: [
              NavigationRail(
                selectedIndex: _selectedNav,
                onDestinationSelected: (i) =>
                    setState(() => _selectedNav = i),
                extended: true, // show text labels
                minExtendedWidth: 200,
                destinations: _navDestinations
                    .map((d) => NavigationRailDestination(
                          icon: Icon(Icons.circle_outlined),
                          label: Text(d.label),
                        ))
                    .toList(),
              ),
              const VerticalDivider(width: 1),
              // ── Master-Detail split pane ────────────────────────────────
              // Left: master list | Right: detail view
              Expanded(
                child: Row(
                  children: [
                    // Master (list)
                    SizedBox(
                      width: 280,
                      child: _MasterList(
                        items: _items,
                        selectedIndex: _selectedItem,
                        onSelected: (i) =>
                            setState(() => _selectedItem = i),
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    // Detail
                    Expanded(
                      child: _selectedItem == null
                          ? const _DetailPlaceholder()
                          : _DetailView(
                              item: _items[_selectedItem!],
                              index: _selectedItem!,
                            ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
      }),
    );
  }

  Widget _content() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('04 — Desktop Layout',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Resize the window to see the layout adapt:',
              style: TextStyle(color: Colors.grey)),
          const Text('• < 600px  → BottomNavigationBar'),
          const Text('• 600–1100px → NavigationRail (icons only)'),
          const Text('• > 1100px → NavigationRail extended + Master/Detail'),

          const SizedBox(height: 16),
          _header('Keyboard Shortcuts', Colors.blueGrey),
          const Text('Try these shortcuts (the app must be focused):',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          _ShortcutDisplay(),

          const SizedBox(height: 20),
          _header('Context Menu (Right-click)', Colors.blue),
          _ContextMenuDemo(),

          const SizedBox(height: 20),
          _header('Drag & Drop', Colors.orange),
          _DragDropDemo(),

          const SizedBox(height: 20),
          _header('window_manager (Desktop Only)', Colors.purple),
          _code('''
// pubspec.yaml
dependencies:
  window_manager: ^0.4.2   # Windows, macOS, Linux

// main.dart
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1200, 800),
    minimumSize: Size(800, 600),
    center: true,
    title: 'My Desktop App',
    titleBarStyle: TitleBarStyle.hidden, // custom title bar
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MyApp());
}

// Control the window:
await windowManager.minimize();
await windowManager.maximize();
await windowManager.setTitle('New Title');
await windowManager.setSize(const Size(1400, 900));
await windowManager.setAlwaysOnTop(true);
final isMaximized = await windowManager.isMaximized();'''),
        ],
      );

  static const _navDestinations = [
    NavigationDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard),
        label: 'Dashboard'),
    NavigationDestination(
        icon: Icon(Icons.folder_outlined),
        selectedIcon: Icon(Icons.folder),
        label: 'Projects'),
    NavigationDestination(
        icon: Icon(Icons.people_outlined),
        selectedIcon: Icon(Icons.people),
        label: 'Team'),
    NavigationDestination(
        icon: Icon(Icons.settings_outlined),
        selectedIcon: Icon(Icons.settings),
        label: 'Settings'),
  ];
}

// ── Master List ────────────────────────────────────────────────────────────────

class _MasterList extends StatelessWidget {
  final List<String> items;
  final int? selectedIndex;
  final ValueChanged<int> onSelected;

  const _MasterList({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text('Projects',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  )),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) => ListTile(
              title: Text(items[i],
                  style: const TextStyle(fontSize: 13)),
              selected: selectedIndex == i,
              selectedTileColor:
                  Theme.of(context).colorScheme.primaryContainer,
              onTap: () => onSelected(i),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Detail View ────────────────────────────────────────────────────────────────

class _DetailPlaceholder extends StatelessWidget {
  const _DetailPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Select a project to view details',
          style: TextStyle(color: Colors.grey)),
    );
  }
}

class _DetailView extends StatelessWidget {
  final String item;
  final int index;
  const _DetailView({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text('Project details for item #${index + 1}',
              style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          const Text(
            'In a real app, this panel shows the full detail view — '
            'forms, charts, comments, history, etc. '
            'The master-detail pattern is the core desktop UX pattern.',
          ),
        ],
      ),
    );
  }
}

// ── Keyboard shortcut display ──────────────────────────────────────────────────

class _ShortcutDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final shortcuts = [
      ('Ctrl+N', 'New Document'),
      ('Ctrl+S', 'Save'),
      ('Ctrl+F', 'Search'),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: shortcuts
          .map((s) => Chip(
                label: Text('${s.$1} → ${s.$2}',
                    style: const TextStyle(fontSize: 11)),
                avatar: const Icon(Icons.keyboard, size: 14),
              ))
          .toList(),
    );
  }
}

// ── Context menu demo ──────────────────────────────────────────────────────────

class _ContextMenuDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Right-click on desktop / long-press on mobile
      onSecondaryTapUp: (details) {
        showMenu(
          context: context,
          position: RelativeRect.fromLTRB(
            details.globalPosition.dx,
            details.globalPosition.dy,
            details.globalPosition.dx + 1,
            details.globalPosition.dy + 1,
          ),
          items: <PopupMenuEntry<String>>[
            const PopupMenuItem(value: 'copy', child: Text('Copy')),
            const PopupMenuItem(value: 'paste', child: Text('Paste')),
            const PopupMenuDivider(),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ).then((value) {
          if (value != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Selected: $value')),
            );
          }
        });
      },
      child: Container(
        width: double.infinity,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: const Text(
          'Right-click here to open context menu',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}

// ── Drag and drop demo ─────────────────────────────────────────────────────────

class _DragDropDemo extends StatefulWidget {
  @override
  State<_DragDropDemo> createState() => _DragDropDemoState();
}

class _DragDropDemoState extends State<_DragDropDemo> {
  String _dropResult = 'Drop a chip here';

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Draggable items
        Wrap(
          spacing: 8,
          children: ['Alpha', 'Beta', 'Gamma'].map((name) {
            return Draggable<String>(
              data: name, // data passed to the DragTarget
              feedback: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(20),
                child: Chip(label: Text(name)),
              ),
              childWhenDragging: Opacity(
                opacity: 0.3,
                child: Chip(label: Text(name)),
              ),
              child: Chip(label: Text(name)),
            );
          }).toList(),
        ),
        const SizedBox(width: 16),

        // Drop target
        Expanded(
          child: DragTarget<String>(
            onAcceptWithDetails: (details) {
              setState(() => _dropResult = 'Dropped: ${details.data}');
            },
            builder: (context, candidateData, rejectedData) {
              final isHovering = candidateData.isNotEmpty;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 60,
                decoration: BoxDecoration(
                  color: isHovering
                      ? Colors.blue.shade100
                      : Colors.grey.shade100,
                  border: Border.all(
                    color: isHovering
                        ? Colors.blue
                        : Colors.grey.shade300,
                    width: isHovering ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  _dropResult,
                  style: TextStyle(
                    color: isHovering ? Colors.blue : Colors.grey,
                  ),
                ),
              );
            },
          ),
        ),
      ],
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
