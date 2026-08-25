/// Phase 9 — Topic 05: Interview Preparation
///
/// This topic covers the most common Flutter / Dart / mobile interview
/// questions — grouped by category — with concise, correct answers.
///
/// How to use this file:
/// - Read each question BEFORE looking at the answer (tap to reveal)
/// - If you can't answer confidently → go back to that phase and review
/// - Practice answering out loud — interviews are verbal
///
/// Categories covered:
/// A. Dart language fundamentals
/// B. Flutter architecture (widget tree, rendering, keys)
/// C. State management
/// D. Performance
/// E. Testing
/// F. Design patterns & architecture
/// G. Behavioral / experience questions
import 'package:flutter/material.dart';

/// Standalone entry point.
void main() => runApp(const _StandaloneApp());

class _StandaloneApp extends StatelessWidget {
  const _StandaloneApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interview Prep',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const InterviewPrepDemo(),
    );
  }
}

/// Interactive interview Q&A — tap a question to reveal the answer.
class InterviewPrepDemo extends StatefulWidget {
  const InterviewPrepDemo({super.key});

  @override
  State<InterviewPrepDemo> createState() => _InterviewPrepDemoState();
}

class _InterviewPrepDemoState extends State<InterviewPrepDemo> {
  // Track which questions are expanded (answer visible).
  final Set<int> _expanded = {};

  void _toggle(int index) {
    setState(() {
      if (_expanded.contains(index)) {
        _expanded.remove(index);
      } else {
        _expanded.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('05 — Interview Prep'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          // Expand all / collapse all toggle
          TextButton(
            onPressed: () {
              setState(() {
                if (_expanded.length == _allQA.length) {
                  _expanded.clear();
                } else {
                  _expanded.addAll(
                      List.generate(_allQA.length, (i) => i));
                }
              });
            },
            child: Text(
              _expanded.length == _allQA.length
                  ? 'Collapse All'
                  : 'Expand All',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _card(
            color: Colors.indigo.shade50,
            child: const Text(
              'Tap each question to reveal the answer.\n'
              'Self-assess: can you answer confidently without looking?\n'
              'If not — go back to that phase and review.',
              style: TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(height: 12),

          // Render all Q&A items grouped by category
          ..._buildGrouped(),

          const SizedBox(height: 20),
          _card(
            color: Colors.indigo.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tips for the Interview',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('• Think out loud — interviewers want to hear your reasoning'),
                Text('• Use concrete examples from your own projects'),
                Text('• "I don\'t know but I would..." is better than bluffing'),
                Text('• Ask clarifying questions before diving into an answer'),
                Text('• Prepare 2–3 questions to ask THEM at the end'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGrouped() {
    final widgets = <Widget>[];
    int globalIndex = 0;

    for (final category in _categories) {
      // Category header
      widgets.add(Padding(
        padding: const EdgeInsets.fromLTRB(0, 16, 0, 4),
        child: Text(
          category,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.indigo),
        ),
      ));

      // Q&A items for this category
      for (final qa in _allQA.where((q) => q.category == category)) {
        final index = globalIndex;
        final isOpen = _expanded.contains(index);
        widgets.add(_QACard(
          qa: qa,
          index: index,
          isOpen: isOpen,
          onTap: () => _toggle(index),
        ));
        globalIndex++;
      }
    }

    return widgets;
  }
}

// ── Q&A Card Widget ────────────────────────────────────────────────────────────

/// A single expandable question + answer card.
class _QACard extends StatelessWidget {
  final _QA qa;
  final int index;
  final bool isOpen;
  final VoidCallback onTap;

  const _QACard({
    required this.qa,
    required this.index,
    required this.isOpen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question row
              Row(
                children: [
                  // Question number badge
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.indigo,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text('${index + 1}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      qa.question,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                  Icon(
                    isOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                ],
              ),

              // Answer (visible only when expanded)
              if (isOpen) ...[
                const Divider(height: 16),
                Text(
                  qa.answer,
                  style: const TextStyle(fontSize: 12, height: 1.5),
                ),
                // Optional code snippet
                if (qa.code != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2E),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        qa.code!,
                        style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            color: Color(0xFFCDD6F4)),
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Data model ─────────────────────────────────────────────────────────────────

/// A single interview question with its answer and optional code example.
class _QA {
  final String category;
  final String question;
  final String answer;
  final String? code;

  const _QA({
    required this.category,
    required this.question,
    required this.answer,
    this.code,
  });
}

/// Ordered list of categories as they appear on screen.
const _categories = [
  'A. Dart Language',
  'B. Flutter Architecture',
  'C. State Management',
  'D. Performance',
  'E. Testing',
  'F. Design Patterns',
  'G. Behavioral',
];

/// Full list of interview Q&A items.
const _allQA = [
  // ── A. Dart Language ──────────────────────────────────────────────────────
  _QA(
    category: 'A. Dart Language',
    question: 'What is null safety in Dart and why does it matter?',
    answer:
        'Null safety means the type system distinguishes between nullable (T?) '
        'and non-nullable (T) types at compile time. You cannot assign null to '
        'a non-nullable variable, so NullPointerExceptions are caught before '
        'the app runs. The ? suffix makes a type nullable, ! force-unwraps it '
        '(throws at runtime if null), and ?? provides a default value.',
    code:
        'String name = "Alice";        // non-nullable — can never be null\n'
        'String? nickname = null;      // nullable — can be null\n'
        'String display = nickname ?? name;  // use name if nickname is null\n'
        'int len = nickname!.length;   // throws if nickname is actually null',
  ),
  _QA(
    category: 'A. Dart Language',
    question: 'What is the difference between final and const?',
    answer:
        'final means the variable is assigned once at runtime and cannot be '
        'reassigned. const means the value is determined at compile time (it '
        'is a compile-time constant). Use const when the value is truly known '
        'at compile time (literal strings, numbers, const constructors). '
        'Using const improves performance because Flutter reuses the same '
        'object in memory instead of creating a new one.',
    code:
        'final now = DateTime.now();   // runtime value — cannot use const\n'
        'const pi = 3.14159;           // compile-time constant\n'
        'const box = SizedBox(width: 8); // widget is reused in memory',
  ),
  _QA(
    category: 'A. Dart Language',
    question: 'Explain async/await and Future in Dart.',
    answer:
        'A Future<T> represents a value that will be available sometime in the '
        'future (like a Promise in JS). async marks a function as asynchronous — '
        'it always returns a Future. await suspends the function until the Future '
        'completes, without blocking the thread. Flutter uses a single-threaded '
        'event loop — async/await lets you do IO without freezing the UI.',
    code:
        'Future<User> fetchUser(String id) async {\n'
        '  final response = await http.get(Uri.parse("/users/\$id"));\n'
        '  return User.fromJson(jsonDecode(response.body));\n'
        '}\n\n'
        '// Calling it:\n'
        'final user = await fetchUser("123"); // suspends until done\n'
        '// Or with then/catchError:\n'
        'fetchUser("123").then((u) => print(u.name)).catchError(print);',
  ),
  _QA(
    category: 'A. Dart Language',
    question: 'What is a Stream in Dart? How does it differ from a Future?',
    answer:
        'A Future delivers ONE value (or error) at some point in the future. '
        'A Stream delivers ZERO OR MORE values over time. '
        'Use Future for one-shot async operations (HTTP request, file read). '
        'Use Stream for continuous data (sensor updates, WebSocket messages, '
        'Firestore real-time listeners, user input events).',
    code:
        '// Future: one value\n'
        'final price = await fetchPrice("BTC"); // arrives once\n\n'
        '// Stream: many values over time\n'
        'final stream = FirebaseFirestore.instance\n'
        '    .collection("prices").snapshots(); // emits on every change\n'
        'stream.listen((snapshot) => print(snapshot.docs.length));',
  ),
  _QA(
    category: 'A. Dart Language',
    question: 'What are extension methods?',
    answer:
        'Extension methods let you add new methods to an existing type without '
        'subclassing or modifying the original class. They are syntactic sugar — '
        'at runtime they are just static function calls. Very useful for adding '
        'utility methods to String, BuildContext, or any third-party class.',
    code:
        'extension StringValidation on String {\n'
        '  bool get isValidEmail => RegExp(r"^[\\w.]+@[\\w]+\\.[\\w]+\$").hasMatch(this);\n'
        '}\n\n'
        'print("test@example.com".isValidEmail); // true',
  ),

  // ── B. Flutter Architecture ───────────────────────────────────────────────
  _QA(
    category: 'B. Flutter Architecture',
    question: 'What is the difference between StatelessWidget and StatefulWidget?',
    answer:
        'StatelessWidget describes UI that depends only on its constructor '
        'arguments. Once built, it never changes. '
        'StatefulWidget has a separate State object that can change over time '
        'via setState(). When setState() is called, Flutter rebuilds the widget '
        'subtree. As a rule: start with Stateless; switch to Stateful only when '
        'local mutable state is genuinely needed. For global/shared state, use '
        'Riverpod or BLoC instead of StatefulWidget.',
    code: null,
  ),
  _QA(
    category: 'B. Flutter Architecture',
    question: 'What are Keys and when should you use them?',
    answer:
        'Keys help Flutter identify widgets when the widget tree changes. '
        'Without a key, Flutter identifies widgets by their TYPE and POSITION '
        'in the tree. If you have a list of stateful widgets and the list '
        'reorders or removes items, Flutter may match the wrong state to the '
        'wrong widget. '
        'Use GlobalKey to access a widget\'s state from anywhere. '
        'Use ValueKey(id) for list items with unique IDs. '
        'Use UniqueKey() only when you always want a fresh widget (forces rebuild).',
    code:
        '// List item with ValueKey — Flutter correctly tracks state across reorders\n'
        'ListView(\n'
        '  children: items.map(\n'
        '    (item) => TodoItem(key: ValueKey(item.id), todo: item),\n'
        '  ).toList(),\n'
        ')',
  ),
  _QA(
    category: 'B. Flutter Architecture',
    question: 'How does Flutter render widgets? What is the three-tree model?',
    answer:
        'Flutter maintains three trees: '
        '(1) Widget tree — immutable blueprints you write in build(). '
        '(2) Element tree — mutable instances managed by Flutter. Elements '
        'are created once and updated when the widget changes. '
        '(3) RenderObject tree — handles actual layout and painting. '
        'When you call setState(), Flutter rebuilds the Widget tree, diffs it '
        'against the Element tree (reconciliation), and only updates the '
        'RenderObjects that changed.',
    code: null,
  ),
  _QA(
    category: 'B. Flutter Architecture',
    question: 'What is BuildContext?',
    answer:
        'BuildContext is a handle to a widget\'s location in the element tree. '
        'It is used to look up ancestors (Theme.of(context), MediaQuery.of(context)), '
        'navigate (Navigator.of(context)), and access providers '
        '(ref.read() in Riverpod, Provider.of<T>(context)). '
        'Never store a BuildContext across async gaps because the widget might '
        'be unmounted by the time you use it.',
    code: null,
  ),

  // ── C. State Management ───────────────────────────────────────────────────
  _QA(
    category: 'C. State Management',
    question: 'What state management solutions do you use and why?',
    answer:
        'Riverpod for most projects: type-safe, testable, no BuildContext '
        'required to read providers, good DevTools support. '
        'BLoC when the team has strong opinions about explicit events and states '
        'or when the project is very large and needs strict separation. '
        'setState() for purely local, ephemeral state (form field focus, '
        'toggle visibility). '
        'The key insight: use the simplest solution that handles the scope '
        'of the state — local, feature-level, or global.',
    code: null,
  ),
  _QA(
    category: 'C. State Management',
    question: 'Explain the difference between Provider, StateNotifier, and AsyncNotifier in Riverpod.',
    answer:
        'Provider: read-only, synchronous value. Use for constants, configs, '
        'or derived values computed from other providers. '
        'StateNotifier<State>: holds mutable state. You mutate it by calling '
        'methods on the notifier that assign a new State value. '
        'AsyncNotifier<T>: StateNotifier for async data (shows loading/error/data '
        'states automatically). Use for screens that fetch data from an API.',
    code:
        '// Provider — read-only\nfinal greetingProvider = Provider((ref) => "Hello");\n\n'
        '// StateNotifier — mutable sync state\nclass CounterNotifier extends StateNotifier<int> {\n'
        '  CounterNotifier() : super(0);\n'
        '  void increment() => state++;\n'
        '}\n\n'
        '// AsyncNotifier — async state with built-in loading/error\n'
        'class TransactionListNotifier extends AsyncNotifier<List<Transaction>> {\n'
        '  @override Future<List<Transaction>> build() => ref.read(repoProvider).getAll();\n'
        '}',
  ),

  // ── D. Performance ────────────────────────────────────────────────────────
  _QA(
    category: 'D. Performance',
    question: 'How do you optimize a Flutter app for performance?',
    answer:
        '1. Use const constructors everywhere possible — Flutter reuses the '
        'object in memory. '
        '2. Use ListView.builder instead of ListView with children: [] for '
        'long lists — builder is lazy (only builds visible items). '
        '3. Avoid rebuilding expensive widgets — extract them into separate '
        'widgets or use RepaintBoundary. '
        '4. Use cached_network_image to avoid re-downloading images. '
        '5. Profile with Flutter DevTools (CPU profiler, widget rebuilds) '
        'before optimizing — never guess. '
        '6. Compute-heavy work (image processing, parsing) in an Isolate '
        'to keep the main thread free for UI.',
    code: null,
  ),
  _QA(
    category: 'D. Performance',
    question: 'What causes jank (dropped frames) in Flutter?',
    answer:
        'Jank (< 60 fps) is caused by work on the main UI thread that takes '
        'more than 16ms per frame. Common causes: '
        '(1) Synchronous heavy computation (parsing large JSON on the main thread). '
        '(2) Expensive build() methods that rebuild unnecessarily. '
        '(3) Complex CustomPainter that runs on every frame. '
        '(4) Overdraw — too many overlapping semi-transparent layers. '
        'Fix: move heavy work to Isolate.run(), use const, minimize setState scope.',
    code: null,
  ),

  // ── E. Testing ────────────────────────────────────────────────────────────
  _QA(
    category: 'E. Testing',
    question: 'What is the test pyramid and what goes in each layer?',
    answer:
        'Unit tests (bottom, most): test a single function/class in isolation. '
        'No Flutter, no network. Fast, hundreds of them. Cover all business logic. '
        'Widget tests (middle): test a single widget in a simulated environment. '
        'No real device. Medium speed. Cover UI interactions and state changes. '
        'Integration tests (top, fewest): test the whole app on a real device. '
        'Slow. Cover critical end-to-end user flows (login, checkout).',
    code: null,
  ),
  _QA(
    category: 'E. Testing',
    question: 'How do you test a class that depends on an API client?',
    answer:
        'Use dependency injection: the class receives the API client via its '
        'constructor. In tests, pass a mock (mocktail/mockito) instead of the '
        'real client. The mock returns controlled responses, so tests never '
        'hit a real server. '
        'Alternatively, use a Fake — an in-memory implementation of the '
        'interface that stores data in a Map.',
    code:
        'class MockUserApi extends Mock implements UserApi {}\n\n'
        'test("returns user on 200", () async {\n'
        '  final mock = MockUserApi();\n'
        '  when(() => mock.getUser("1")).thenAnswer((_) async => UserDto(...));\n\n'
        '  final repo = UserRepository(mock);\n'
        '  final result = await repo.getUser("1");\n\n'
        '  expect(result, isA<Success<User>>());\n'
        '  verify(() => mock.getUser("1")).called(1);\n'
        '});',
  ),

  // ── F. Design Patterns ────────────────────────────────────────────────────
  _QA(
    category: 'F. Design Patterns',
    question: 'Explain Clean Architecture and the Dependency Rule.',
    answer:
        'Clean Architecture divides the codebase into three layers: '
        'Domain (entities, use cases, repository interfaces — pure Dart, no '
        'external dependencies), '
        'Data (repository implementations, API clients, local DB — knows about '
        'Firebase/Dio/SQLite), and '
        'Presentation (screens, widgets, state management — knows about Flutter). '
        'The Dependency Rule: source code dependencies always point inward. '
        'Domain never imports from Data or Presentation. '
        'This means you can test Domain with zero Flutter dependencies, and '
        'swap Firebase for REST without touching any UI code.',
    code: null,
  ),
  _QA(
    category: 'F. Design Patterns',
    question: 'When should you NOT create a Use Case?',
    answer:
        'Skip the Use Case when it is a pure passthrough — it only calls '
        'one repository method with no validation, transformation, or side '
        'effects. A passthrough Use Case adds a layer of indirection with '
        'zero benefit. Call the repository directly from the ViewModel/Provider. '
        'Create a Use Case when it combines multiple repositories, '
        'has business validation, has side effects (notifications, analytics), '
        'or aggregates/transforms data.',
    code: null,
  ),

  // ── G. Behavioral ─────────────────────────────────────────────────────────
  _QA(
    category: 'G. Behavioral',
    question: 'Tell me about a technically challenging bug you fixed.',
    answer:
        'Structure your answer with STAR: '
        'Situation — what was the context? '
        'Task — what were you trying to achieve? '
        'Action — specifically what you investigated and changed. '
        'Result — what improved and how you verified it. '
        'Example: "In BRImo billing, transactions were sometimes duplicated '
        'when users tapped the pay button rapidly. I traced it to missing '
        'debounce on the button and a non-idempotent API call. I added a '
        '500ms debounce and a local in-flight guard. Result: zero duplicate '
        'transaction reports in the next sprint."',
    code: null,
  ),
  _QA(
    category: 'G. Behavioral',
    question: 'How do you handle disagreement with a team member about a technical decision?',
    answer:
        'Acknowledge their concern and try to understand the reasoning behind it. '
        'Present data or concrete examples — not opinion. If it\'s a significant '
        'decision, propose a time-boxed prototype to test both approaches. '
        'Defer to the team lead or agreed-upon coding standard if there\'s no '
        'clear winner. The goal is the best outcome for the product, not being right.',
    code: null,
  ),
  _QA(
    category: 'G. Behavioral',
    question: 'How do you stay up to date with Flutter and the Dart ecosystem?',
    answer:
        'Flutter official release notes and blog posts (flutter.dev/blog). '
        'pub.dev for new package versions. '
        'Flutter community Discord and Telegram (Flutter ID). '
        'YouTube channels: Flutter official, Reso Coder, Andrea Bizzotto. '
        'Reading the source code of popular packages to understand how they work. '
        'Building small experiments when a new feature ships (e.g. testing '
        'Riverpod Generator when it was released).',
    code: null,
  ),
];

// ── Shared helpers ─────────────────────────────────────────────────────────────

Widget _card({required Color color, required Widget child}) => Card(
      color: color,
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    );
