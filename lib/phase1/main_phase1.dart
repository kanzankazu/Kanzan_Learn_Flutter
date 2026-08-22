// Feature: phase-1-dart-language, Requirement 14: Entry Point & Integration
// ============================================================
// PHASE 1 — Interactive Menu Entry Point
// ============================================================
// Purpose: Guides learners through all 13 Phase 1 topics by showing
//          their descriptions, concepts covered, and the exact
//          'dart run' command to execute each demo.
//
// Run with: dart run lib/phase1/main_phase1.dart
// Prerequisites: Phase 0 complete (lib/phase0/mini_projects/ must exist)
//
// IMPORTANT: This file has NO imports from demo files.
//            It only shows run commands — it never executes them.
// ============================================================

import 'dart:io';

// ============================================================
// Entry Point
// ============================================================

/// Interactive CLI menu for Phase 1 — Dart Language.
///
/// Checks Phase 0 prerequisites, then runs an input loop that
/// accepts topic numbers 1–13 or 0 to exit.
void main() {
  _checkPhase0Prerequisites();

  print('');
  print('╔══════════════════════════════════════════════════╗');
  print('║       PHASE 1 — DART LANGUAGE FEATURES          ║');
  print('║   11 Topics + 2 Mini Projects — Pure Dart CLI   ║');
  print('╚══════════════════════════════════════════════════╝');

  // Main input loop — keeps running until user enters 0 to exit.
  while (true) {
    _showMenu();
    stdout.write('Enter topic number (0 to exit): ');

    final input = stdin.readLineSync()?.trim() ?? '';

    print(''); // blank line for readability

    // Try to parse the input as an integer.
    final choice = int.tryParse(input);

    if (choice == null) {
      // Non-integer input (e.g., letters, symbols, empty string)
      print('❌  Invalid input: "$input" is not a number.');
      print('    Please enter a number between 0 and 13.');
      continue;
    }

    if (choice == 0) {
      // Exit the program gracefully.
      print('👋  Thanks for studying Phase 1 — Dart Language Features!');
      print('    When you\'re ready, move on to:');
      print('    Phase 2 — Flutter Fundamentals');
      print('    Branch: phase/2-flutter-fundamentals');
      print('');
      exit(0);
    }

    if (choice < 1 || choice > 13) {
      // Out-of-range integer input (e.g., 14, -1, 100)
      print('❌  Invalid choice: $choice is out of range.');
      print('    Please enter a number between 1 and 13, or 0 to exit.');
      continue;
    }

    // Valid input 1–13: show topic info.
    _showTopicInfo(choice);
  }
}

// ============================================================
// Prerequisites Check
// ============================================================

/// Checks if Phase 0 mini projects directory exists as a prerequisite gate.
///
/// Returns true if Phase 0 appears to be complete (directory found),
/// false otherwise. Always prints a reminder about running 'dart pub get'.
///
/// Note: This is a lightweight heuristic check — it only verifies
/// the directory exists, not that every project is functionally complete.
bool _checkPhase0Prerequisites() {
  print('');
  print('📋  PREREQUISITES CHECK');
  print('────────────────────────────────────');

  // Check if Phase 0 mini projects directory exists.
  final phase0Dir = Directory('lib/phase0/mini_projects');
  final phase0Exists = phase0Dir.existsSync();

  if (phase0Exists) {
    print('✅  Phase 0 complete — lib/phase0/mini_projects/ found.');
  } else {
    print('⚠️   Phase 0 not found — lib/phase0/mini_projects/ is missing.');
    print('    Phase 1 works standalone, but Phase 0 is recommended first.');
    print('    Start here: git checkout phase/0-fondasi-pemrograman');
  }

  // Always remind learners to run 'dart pub get' at the start of each session.
  // Phase 1 uses the 'http' package (Weather CLI) which requires this step.
  print('');
  print('💡  REMINDER: Run the following before executing any demo:');
  print('    dart pub get');
  print('    (Required for the http package used by Weather CLI — Topic 12)');
  print('────────────────────────────────────');

  return phase0Exists;
}

// ============================================================
// Menu Display
// ============================================================

/// Prints the numbered topic menu (1–13) with a brief title for each.
///
/// Called at the start of every input loop iteration so the learner
/// always has the list visible when choosing.
void _showMenu() {
  print('');
  print('┌──────────────────────────────────────────────────┐');
  print('│                   TOPIC LIST                     │');
  print('├──────────────────────────────────────────────────┤');
  print('│  1.  Null Safety                                  │');
  print('│  2.  Async/Await & Future                         │');
  print('│  3.  Stream                                       │');
  print('│  4.  Collections Advanced                         │');
  print('│  5.  Extension Methods                            │');
  print('│  6.  Enum Enhanced (Dart 3)                       │');
  print('│  7.  Pattern Matching & Sealed Class              │');
  print('│  8.  Generics                                     │');
  print('│  9.  Mixins                                       │');
  print('│ 10.  Records & Destructuring                      │');
  print('│ 11.  Isolates                                     │');
  print('├──────────────────────────────────────────────────┤');
  print('│ 12.  [Mini Project] Weather CLI App               │');
  print('│ 13.  [Mini Project] File Processor CLI            │');
  print('├──────────────────────────────────────────────────┤');
  print('│  0.  Exit                                         │');
  print('└──────────────────────────────────────────────────┘');
}

// ============================================================
// Topic Info Display
// ============================================================

/// Dispatches to the correct topic info based on [topicNumber] (1–13).
///
/// Calls [_showTopicDetail] with the appropriate metadata for each topic.
void _showTopicInfo(int topicNumber) {
  switch (topicNumber) {
    case 1:
      _showTopicDetail(
        title: 'Null Safety',
        requirement: 'Requirement 1',
        description:
            'Dart\'s sound null safety system eliminates null reference errors '
            'at compile time. You declare whether a variable can hold null, '
            'and the compiler enforces it.',
        concepts: [
          'Nullable (String?) vs non-nullable (String) types',
          'Safe navigation operator ?.  (e.g., user?.name)',
          'Null coalescing ?? and ??=  (fallback values)',
          'Null assertion !  (use only when you are 100% sure)',
          'late keyword for deferred initialization',
        ],
        command: 'dart run lib/phase1/01_null_safety/null_safety_demo.dart',
      );

    case 2:
      _showTopicDetail(
        title: 'Async/Await & Future',
        requirement: 'Requirement 2',
        description:
            'Dart is single-threaded but non-blocking. Futures represent '
            'values that will be available asynchronously — like network '
            'responses or file reads. async/await makes async code read '
            'like synchronous code.',
        concepts: [
          'Creating Futures: Future.value(), Future.delayed(), async fn',
          'await keyword — suspends execution until Future completes',
          'Error handling with try/catch inside async functions',
          'Future.wait() — run multiple Futures in parallel',
          'Method chaining: .then(), .catchError(), .whenComplete()',
          'Timing: why code after await may run "later" than you expect',
        ],
        command:
            'dart run lib/phase1/02_async_future/async_future_demo.dart',
      );

    case 3:
      _showTopicDetail(
        title: 'Stream',
        requirement: 'Requirement 3',
        description:
            'A Stream is a sequence of asynchronous events — think of it as '
            'an async Iterable. Core to Flutter: UI events, Firebase snapshots, '
            'and WebSocket messages are all Streams.',
        concepts: [
          'Creating: Stream.fromIterable(), Stream.periodic(), async* generator',
          'Consuming with await for loop',
          'Transformations: .map(), .where(), .take(), .skip()',
          'StreamController — manually push events and close the stream',
          'Single-subscription vs broadcast streams',
          'StreamSubscription with onData, onError, onDone callbacks',
        ],
        command: 'dart run lib/phase1/03_stream/stream_demo.dart',
      );

    case 4:
      _showTopicDetail(
        title: 'Collections Advanced',
        requirement: 'Requirement 4',
        description:
            'You already know List, Map, Set from Phase 0. Now level up with '
            'functional-style operations that let you transform collections '
            'in one expressive pipeline instead of multiple for-loops.',
        concepts: [
          '.map()   — transform every element (returns new Iterable)',
          '.where() — filter elements by predicate',
          '.fold()  — reduce to a single value with an initial seed',
          '.reduce() — like fold but no initial value (StateError on empty)',
          'Spread operator ... and null-aware spread ...?',
          'Collection if and collection for in list/map/set literals',
          'Chaining: .where().map().toList()',
        ],
        command:
            'dart run lib/phase1/04_collections_advanced/collections_advanced_demo.dart',
      );

    case 5:
      _showTopicDetail(
        title: 'Extension Methods',
        requirement: 'Requirement 5',
        description:
            'Extension methods let you add new functionality to existing types '
            '(even from external packages) without subclassing. Used '
            'extensively in Flutter codebases for context.theme(), '
            'string.toColor(), etc.',
        concepts: [
          'Defining: extension ExtName on ExistingType { ... }',
          'String extensions: capitalize(), isPalindrome()',
          'int extensions: isEven getter, toRomanNumeral()',
          'Generic extensions: ListUtils<T> with second, shuffled()',
          'Dot-notation usage — looks like built-in methods',
          'When to use extension vs subclass vs wrapper class',
        ],
        command: 'dart run lib/phase1/05_extensions/extensions_demo.dart',
      );

    case 6:
      _showTopicDetail(
        title: 'Enum Enhanced (Dart 3)',
        requirement: 'Requirement 6',
        description:
            'Dart 3 enums are far more powerful than classic enums. They can '
            'have fields, constructors, methods, and even implement interfaces — '
            'making them first-class objects rather than just named constants.',
        concepts: [
          'Simple enum (Dart 2 style): enum Direction { north, south }',
          'Enum with fields + const constructor (Planet example)',
          'Enum implementing an interface',
          'Exhaustive switch expression — compiler error if case missing',
          'EnumName.values — iterate all variants',
          'State-machine pattern using enum + valid transition logic',
        ],
        command:
            'dart run lib/phase1/06_enum_enhanced/enum_enhanced_demo.dart',
      );

    case 7:
      _showTopicDetail(
        title: 'Pattern Matching & Sealed Class',
        requirement: 'Requirement 7',
        description:
            'Pattern matching (Dart 3) replaces verbose if/else chains with '
            'expressive switch expressions. Sealed classes (also Dart 3) '
            'guarantee exhaustive handling — the compiler tells you if you '
            'missed a case.',
        concepts: [
          'sealed class — all subclasses must be in the same file',
          'switch expression with type patterns (eliminates is/as casts)',
          'when guard clauses for extra conditions',
          'Exhaustive sealed switch — missing case = compile error',
          'Destructuring: Records, List patterns, Map patterns',
          'Old if/else+is+as vs new switch pattern side-by-side',
        ],
        command:
            'dart run lib/phase1/07_pattern_matching/pattern_matching_demo.dart',
      );

    case 8:
      _showTopicDetail(
        title: 'Generics',
        requirement: 'Requirement 8',
        description:
            'Generics let you write type-safe code that works with many types. '
            'You\'ve already used List<T> and Map<K,V> — now build your own '
            'generic classes and functions, including the Result<T, E> pattern '
            'used in Clean Architecture.',
        concepts: [
          'Generic class: Box<T> with map<U>() method',
          'Generic function: findMax<T extends Comparable<T>>()',
          'Type bounds: <T extends Comparable<T>>',
          'Result<T, E> sealed class (Success / Failure)',
          'List<dynamic> vs List<Object> vs List<String> comparison',
          'Pair<A, B> with swap() — multi-type generics',
        ],
        command: 'dart run lib/phase1/08_generics/generics_demo.dart',
      );

    case 9:
      _showTopicDetail(
        title: 'Mixins',
        requirement: 'Requirement 9',
        description:
            'Mixins provide reusable behavior that can be "mixed in" to any '
            'class without inheritance. Flutter uses mixins everywhere: '
            'TickerProviderStateMixin, AutomaticKeepAliveClientMixin, etc.',
        concepts: [
          'mixin keyword and with clause',
          'Mixin stacking — multiple mixins on one class',
          'MRO (Method Resolution Order) — rightmost wins',
          'mixin on ClassName — access base class members',
          'Mixin vs abstract class vs interface comparison',
          'Real Flutter examples in comments',
        ],
        command: 'dart run lib/phase1/09_mixins/mixins_demo.dart',
      );

    case 10:
      _showTopicDetail(
        title: 'Records & Destructuring',
        requirement: 'Requirement 10',
        description:
            'Records (Dart 3) are anonymous immutable value types — a lightweight '
            'alternative to creating a full class just to return 2+ values from '
            'a function. Destructuring extracts values from Records, Lists, '
            'and Maps in one expression.',
        concepts: [
          'Positional record: (int, String) with .\$1 / .\$2 access',
          'Named record: ({int age, String name}) with .age / .name',
          'Record as function return type (multiple return values)',
          'Destructuring: var (x, y) = record',
          'List pattern: [first, second, ...rest]',
          'Map pattern: {\'key\': value}',
          'Records in switch expressions',
        ],
        command: 'dart run lib/phase1/10_records/records_demo.dart',
      );

    case 11:
      _showTopicDetail(
        title: 'Isolates',
        requirement: 'Requirement 11',
        description:
            'Dart is single-threaded, but Isolates provide true parallelism '
            'by running code in separate memory heaps with no shared state. '
            'Critical for Flutter: heavy computation on the main isolate '
            'causes UI jank (dropped frames).',
        concepts: [
          'Dart threading model — single thread + event loop',
          'Isolate.run() — simple API for one-shot computation',
          'SendPort / ReceivePort — bidirectional message passing',
          'Top-level functions required for Isolate.spawn()',
          'Prime sieve benchmark: blocking vs isolate timing',
          '16ms frame budget — why offloading matters in Flutter',
        ],
        command: 'dart run lib/phase1/11_isolates/isolates_demo.dart',
      );

    case 12:
      _showTopicDetail(
        title: 'Mini Project: Weather CLI App',
        requirement: 'Requirement 12',
        isMiniProject: true,
        description:
            'A complete CLI app that fetches real weather data from the '
            'OpenWeatherMap API. Combines: async/await, HTTP requests, '
            'JSON parsing, null safety, custom exceptions, and proper '
            'error handling — all in one practical project.',
        concepts: [
          'WeatherData class with fromJson() factory constructor',
          'WeatherApiException + CityNotFoundException hierarchy',
          'WeatherService.fetchWeather() — async HTTP request',
          'Environment variable: OPENWEATHER_API_KEY (required)',
          'Formatted output: temperature, humidity, wind speed',
          'Exit codes: 0 = success, 1 = any error',
        ],
        command:
            'OPENWEATHER_API_KEY=your_key dart run lib/phase1/mini_projects/weather/weather_app.dart London',
        setupNote:
            'Get a free API key at: https://openweathermap.org/api\n'
            '    (Takes ~10 minutes to activate after sign-up)',
      );

    case 13:
      _showTopicDetail(
        title: 'Mini Project: File Processor CLI',
        requirement: 'Requirement 13',
        isMiniProject: true,
        description:
            'A multi-mode CLI tool that processes text files using Streams '
            'and functional collection operations. No API key needed — '
            'works immediately with the bundled sample.txt.',
        concepts: [
          'File reading via Stream: .openRead().transform(utf8.decoder)',
          'Result<T, E> sealed class for error handling without exceptions',
          'TextUtils extension on String (wordCount, lineCount)',
          'Three modes: stats, search, transform (upper/lower/reverse)',
          'Functional pipeline: .map().where().fold() (no for-loops)',
          'ProcessingMode + TransformMode enums',
        ],
        command:
            'dart run lib/phase1/mini_projects/file_processor/file_processor.dart'
            ' stats lib/phase1/mini_projects/file_processor/sample.txt',
      );
  }
}

// ============================================================
// Topic Detail Formatter
// ============================================================

/// Prints detailed information for a single topic.
///
/// Parameters:
/// - [title]        Topic display name
/// - [requirement]  Requirement reference from the spec (e.g., "Requirement 1")
/// - [description]  2–3 sentence description of the concept
/// - [concepts]     Bullet list of key concepts demonstrated
/// - [command]      Copy-paste `dart run` command to execute the demo
/// - [isMiniProject] True for topics 12 & 13 — adds a "[MINI PROJECT]" badge
/// - [setupNote]    Optional extra setup instruction (e.g., API key info)
void _showTopicDetail({
  required String title,
  required String requirement,
  required String description,
  required List<String> concepts,
  required String command,
  bool isMiniProject = false,
  String? setupNote,
}) {
  final badge = isMiniProject ? ' [MINI PROJECT]' : '';

  print('╔══════════════════════════════════════════════════╗');
  print('║  $title$badge');
  print('║  $requirement');
  print('╚══════════════════════════════════════════════════╝');
  print('');
  print('📖  DESCRIPTION');
  print('    $description');
  print('');
  print('🎯  CONCEPTS COVERED');
  for (final concept in concepts) {
    print('    • $concept');
  }
  print('');

  // Optional setup note — shown before the run command if present.
  if (setupNote != null) {
    print('⚙️   SETUP');
    print('    $setupNote');
    print('');
  }

  print('▶️   RUN IT NOW — copy and paste this command:');
  print('');
  print('    $command');
  print('');
  print('────────────────────────────────────────────────────');
}
