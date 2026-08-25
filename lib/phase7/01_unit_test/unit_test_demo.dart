/// Phase 7 — Topic 01: Unit Test
///
/// Unit tests verify the behavior of a single function, method, or class
/// in complete isolation — no UI, no network, no file system.
///
/// They are the cheapest test to write and the fastest to run.
/// Aim for ≥ 80% coverage on all business logic (use cases, repositories,
/// models, utilities) with unit tests.
///
/// Key concepts covered:
/// 1. [test()] — defines a single test case
/// 2. [group()] — organizes related tests into a named group
/// 3. [expect()] + [Matcher]s — assertion library (equals, isTrue, throws…)
/// 4. [setUp()] / [tearDown()] — run before / after each test in a group
/// 5. [setUpAll()] / [tearDownAll()] — run once before / after the entire group
/// 6. Async tests — [Future] and [Stream] testing with [expectLater]
/// 7. Parameterized patterns — loop-driven tests for many input/output pairs
///
/// How to run the actual tests:
/// ```bash
/// flutter test test/phase7/unit_test_example_test.dart
/// flutter test test/phase7/   # run all phase7 tests
/// ```
///
/// This file is a Flutter app that SHOWS the concepts with explanations
/// and interactive examples. The real test files live in test/phase7/.
library;

import 'package:flutter/material.dart';

/// Standalone entry point — run this file directly to see the UI demo.
void main() => runApp(_StandaloneApp());

class _StandaloneApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unit Test Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const UnitTestDemo(),
    );
  }
}

/// Demo screen explaining unit test concepts with live examples.
class UnitTestDemo extends StatefulWidget {
  const UnitTestDemo({super.key});

  @override
  State<UnitTestDemo> createState() => _UnitTestDemoState();
}

class _UnitTestDemoState extends State<UnitTestDemo> {
  // ── Live demo: run the Calculator methods and show results ─────────────────
  final _calc = Calculator();
  String _result = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('01 — Unit Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── What is a unit test? ─────────────────────────────────────────
          _card(
            color: Colors.blue.shade50,
            child: const Text(
              'A unit test verifies ONE unit of logic (a function or class) '
              'in complete isolation. No UI, no network, no database.\n\n'
              'Run with: flutter test',
              style: TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),

          // ── 1. Basic test structure ──────────────────────────────────────
          _header('1. Basic Test Structure', Colors.blue),
          _code('''
// test/phase7/calculator_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/calculator.dart';

void main() {
  // group() organizes related tests — shows as a collapsible block in output
  group('Calculator', () {

    // test() = one test case. Name it like a sentence: "should ..."
    test('should add two numbers', () {
      final calc = Calculator();

      // expect(actual, matcher) — the assertion
      expect(calc.add(2, 3), equals(5));
      expect(calc.add(-1, 1), equals(0));
      expect(calc.add(0, 0), equals(0));
    });

    test('should throw when dividing by zero', () {
      final calc = Calculator();

      // throwsA + isA = checks the exception type
      expect(
        () => calc.divide(10, 0),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}'''),

          const SizedBox(height: 16),

          // ── 2. setUp / tearDown ──────────────────────────────────────────
          _header('2. setUp / tearDown', Colors.indigo),
          _code('''
group('Calculator with setUp', () {
  late Calculator calc;

  // setUp runs BEFORE EACH test — use to reset state
  setUp(() {
    calc = Calculator();   // fresh instance per test
  });

  // tearDown runs AFTER EACH test — use to clean up resources
  tearDown(() {
    calc.reset();
  });

  // setUpAll / tearDownAll run ONCE for the whole group
  // — use for expensive one-time setup (DB connection, file read)
  setUpAll(() async {
    await SomeService.initialize();
  });

  test('add works after reset', () {
    calc.add(5, 3);
    calc.reset();
    expect(calc.lastResult, isNull);
  });
});'''),

          const SizedBox(height: 16),

          // ── 3. Common matchers ───────────────────────────────────────────
          _header('3. Common Matchers', Colors.teal),
          _code('''
// Equality
expect(2 + 2, equals(4));
expect(2 + 2, 4);           // shorthand — equals() is the default

// Type checks
expect('hello', isA<String>());
expect(null, isNull);
expect(42, isNotNull);

// Boolean
expect(true, isTrue);
expect(false, isFalse);

// Collections
expect([1, 2, 3], contains(2));
expect([1, 2, 3], hasLength(3));
expect([1, 2, 3], containsAll([1, 3]));
expect({'a': 1}, containsPair('a', 1));

// Numeric ranges
expect(3.14, closeTo(3.14159, 0.01)); // within delta

// Strings
expect('Flutter', startsWith('Flu'));
expect('Flutter', endsWith('ter'));
expect('Flutter', contains('utt'));

// Exception
expect(() => throw Exception('oops'), throwsException);
expect(() => int.parse('abc'), throwsFormatException);
expect(
  () => myFunc(),
  throwsA(predicate((e) => e is MyError && e.code == 404)),
);'''),

          const SizedBox(height: 16),

          // ── 4. Async tests ───────────────────────────────────────────────
          _header('4. Async Tests', Colors.orange),
          _code('''
// Async functions — use async/await directly
test('fetchUser returns a User', () async {
  final service = UserService();
  final user = await service.fetchUser(id: 1);

  expect(user.id, equals(1));
  expect(user.name, isNotEmpty);
});

// Stream testing — use expectLater + emitsInOrder
test('counter stream emits 1, 2, 3', () async {
  final stream = Counter().stream;

  await expectLater(
    stream,
    emitsInOrder([1, 2, 3, emitsDone]),
    //            ^^^^^^^^^^^^^^^^^^^
    // emitsDone asserts the stream closes after these values
  );
});

// Test that a Future throws
test('fetchUser throws on 404', () async {
  final service = UserService();

  expect(
    () => service.fetchUser(id: 9999),
    throwsA(isA<NotFoundException>()),
  );
});'''),

          const SizedBox(height: 16),

          // ── 5. Parameterized tests ───────────────────────────────────────
          _header('5. Parameterized Tests', Colors.purple),
          _code('''
// No built-in @ParameterizedTest in Dart — use a loop instead
void main() {
  group('Calculator.add', () {
    // Table of (a, b, expected) — easy to extend
    const cases = [
      (2, 3, 5),
      (-1, 1, 0),
      (0, 0, 0),
      (100, -50, 50),
    ];

    for (final (a, b, expected) in cases) {
      test('add(\$a, \$b) == \$expected', () {
        expect(Calculator().add(a, b), equals(expected));
      });
    }
  });
}'''),

          const SizedBox(height: 16),

          // ── 6. Live interactive demo ─────────────────────────────────────
          _header('6. Live Demo — Calculator', Colors.green),
          const Text(
            'The Calculator class below is what the unit tests target. '
            'Tap buttons to call methods and see the result.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    _result.isEmpty ? 'Tap a button to test' : _result,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _result.startsWith('Error')
                          ? Colors.red
                          : Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _demoButton('add(5, 3)', () {
                        setState(() => _result = 'add(5,3) = ${_calc.add(5, 3)}');
                      }),
                      _demoButton('subtract(10, 4)', () {
                        setState(() => _result = 'subtract(10,4) = ${_calc.subtract(10, 4)}');
                      }),
                      _demoButton('multiply(6, 7)', () {
                        setState(() => _result = 'multiply(6,7) = ${_calc.multiply(6, 7)}');
                      }),
                      _demoButton('divide(10, 2)', () {
                        setState(() => _result = 'divide(10,2) = ${_calc.divide(10, 2)}');
                      }),
                      _demoButton('divide(10, 0) 💥', () {
                        try {
                          _calc.divide(10, 0);
                        } catch (e) {
                          setState(() => _result = 'Error: $e');
                        }
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── 7. Test file location convention ────────────────────────────
          _header('7. File Naming Convention', Colors.brown),
          _code('''
// Source file:  lib/features/auth/domain/login_use_case.dart
// Test file:    test/features/auth/domain/login_use_case_test.dart
//                                                         ^^^^^^
// Rule: mirror the lib/ folder structure under test/
//       always suffix with _test.dart

// Run single file:
//   flutter test test/features/auth/domain/login_use_case_test.dart
//
// Run all tests in a folder:
//   flutter test test/features/auth/
//
// Run with --name to filter by test name:
//   flutter test --name "login"'''),

          const SizedBox(height: 16),
          _card(
            color: Colors.blue.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Key Takeaways', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('• test() = one case, group() = namespace for related cases'),
                Text('• setUp/tearDown = before/after each test in a group'),
                Text('• expect(actual, matcher) — never write if(x != y) manually'),
                Text('• Async tests: use async/await; Stream tests: use expectLater + emitsInOrder'),
                Text('• Mirror lib/ structure under test/ and suffix files with _test.dart'),
                Text('• Run: flutter test test/   to run all tests at once'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _demoButton(String label, VoidCallback onTap) => FilledButton(
        style: FilledButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
        onPressed: onTap,
        child: Text(label, style: const TextStyle(fontSize: 12)),
      );
}

// ── Sample class that unit tests would target ──────────────────────────────────

/// A simple calculator that demonstrates what a unit-testable class looks like.
///
/// Rules for testable classes:
/// - Pure functions: same input → same output, no side effects
/// - Dependencies injected via constructor (not hardcoded inside)
/// - Clear error contracts (throws on invalid input, not silent fail)
class Calculator {
  /// Adds [a] and [b].
  double add(double a, double b) => a + b;

  /// Subtracts [b] from [a].
  double subtract(double a, double b) => a - b;

  /// Multiplies [a] by [b].
  double multiply(double a, double b) => a * b;

  /// Divides [a] by [b].
  ///
  /// Throws [ArgumentError] if [b] is zero — never return Infinity silently.
  double divide(double a, double b) {
    if (b == 0) throw ArgumentError('Cannot divide by zero');
    return a / b;
  }
}

// ── Shared helper widgets ──────────────────────────────────────────────────────

Widget _header(String title, Color color) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color),
      ),
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
        child: Text(
          code,
          style: const TextStyle(
              fontFamily: 'monospace', fontSize: 11, color: Color(0xFFCDD6F4)),
        ),
      ),
    );

Widget _card({required Color color, required Widget child}) => Card(
      color: color,
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    );
