/// Phase 7 — Topic 05: Code Coverage
///
/// Code coverage measures what percentage of your source code is executed
/// by your tests. It helps identify untested paths — but high coverage
/// alone does not guarantee good tests.
///
/// Flutter uses lcov format for coverage reports.
///
/// Key concepts covered:
/// 1. Running tests with coverage: [flutter test --coverage]
/// 2. The lcov.info file — what it contains
/// 3. Generating an HTML report with [genhtml]
/// 4. Excluding files from coverage (generated code, main.dart, etc.)
/// 5. Coverage in CI — fail the build if coverage drops below a threshold
/// 6. What to target — practical advice on coverage goals
/// 7. Line vs branch vs function coverage
///
/// How to generate coverage:
/// ```bash
/// flutter test --coverage
/// genhtml coverage/lcov.info -o coverage/html
/// open coverage/html/index.html
/// ```
library;

import 'package:flutter/material.dart';

/// Standalone entry point.
void main() => runApp(_StandaloneApp());

class _StandaloneApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Code Coverage Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
        useMaterial3: true,
      ),
      home: const CodeCoverageDemo(),
    );
  }
}

/// Demo screen explaining code coverage concepts.
class CodeCoverageDemo extends StatelessWidget {
  const CodeCoverageDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('05 — Code Coverage'),
        backgroundColor: Colors.cyan.shade700,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            color: Colors.cyan.shade50,
            child: const Text(
              'Coverage = lines executed by tests ÷ total lines × 100%\n\n'
              'Good rule of thumb:\n'
              '• Domain / use-case layer: aim for ≥ 90%\n'
              '• Data / repository layer:  aim for ≥ 80%\n'
              '• UI / presentation layer:  aim for ≥ 60%\n'
              '• Generated code / main.dart: exclude',
              style: TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),

          // ── 1. Run with coverage ──────────────────────────────────────────
          _header('1. Run Tests with Coverage', Colors.cyan.shade700),
          _code('''
# Run all tests and collect coverage data → coverage/lcov.info
flutter test --coverage

# Run a specific folder
flutter test test/domain/ --coverage

# After collecting, generate an HTML report
# (requires lcov: brew install lcov on macOS)
genhtml coverage/lcov.info -o coverage/html

# Open the report in your browser
open coverage/html/index.html   # macOS
# xdg-open coverage/html/index.html  # Linux'''),

          const SizedBox(height: 16),

          // ── 2. lcov.info format ───────────────────────────────────────────
          _header('2. lcov.info Format', Colors.teal),
          const Text(
            'The lcov.info file is a text file listing each source file '
            'and which lines were hit (executed) vs missed.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          _code('''
# coverage/lcov.info (simplified)
SF:lib/domain/calculator.dart        # SF = source file
FN:5,Calculator.add                  # FN = function name + start line
FNDA:3,Calculator.add                # FNDA = function hit count
DA:6,3                               # DA = line 6, hit 3 times
DA:7,0                               # DA = line 7, hit 0 times (NOT covered!)
LH:1                                 # LH = lines hit
LF:2                                 # LF = lines found (total)
end_of_record'''),

          const SizedBox(height: 16),

          // ── 3. Excluding files ────────────────────────────────────────────
          _header('3. Excluding Files from Coverage', Colors.orange),
          const Text(
            'Generated files, main.dart, and injection setup should be excluded — '
            'they inflate total line counts without being meaningful to test.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          _code(r'''
# Option A: use lcov --remove after generating
flutter test --coverage
lcov --remove coverage/lcov.info \
  '*/generated/*.dart' \
  '*/l10n/*.dart' \
  '*/injection_container.dart' \
  'lib/main.dart' \
  -o coverage/lcov_filtered.info

genhtml coverage/lcov_filtered.info -o coverage/html

# Option B: coveragePathExcludePatterns in flutter_test section of pubspec
# (not natively supported — use lcov removal instead)

# Option C: // coverage:ignore-line  (inline ignore for specific lines)
final x = SomeGeneratedClass(); // coverage:ignore-line

// coverage:ignore-start
void _generatedMethod() {
  // entire block ignored
}
// coverage:ignore-end'''),

          const SizedBox(height: 16),

          // ── 4. CI enforcement ─────────────────────────────────────────────
          _header('4. Enforce Coverage in CI', Colors.red),
          _code('''
# .github/workflows/test.yml
- name: Run tests with coverage
  run: flutter test --coverage

- name: Check coverage threshold
  run: |
    # Extract line coverage percentage from lcov.info
    COVERAGE=\$(lcov --summary coverage/lcov.info 2>&1 | grep "lines" | \\
      grep -o "[0-9]*\\.[0-9]*%" | head -1 | tr -d "%")
    echo "Coverage: \$COVERAGE%"
    # Fail if below 70%
    if (( \$(echo "\$COVERAGE < 70" | bc -l) )); then
      echo "Coverage \$COVERAGE% is below 70% threshold!"
      exit 1
    fi

# Alternative: use the lcov_cobertura package + codecov.io
# They give you a coverage badge and PR comments automatically'''),

          const SizedBox(height: 16),

          // ── 5. Line vs branch vs function ────────────────────────────────
          _header('5. Line vs Branch vs Function Coverage', Colors.purple),
          _card(
            color: Colors.purple.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Line coverage', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '% of lines executed at least once. The most common metric. '
                  'Easy to game — a single test can "cover" many lines without '
                  'testing all logical paths.',
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 8),
                Text('Branch coverage', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '% of if/else/switch branches executed. More meaningful — '
                  'catches untested error paths even when the happy path is covered.',
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 8),
                Text('Function coverage', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '% of functions/methods called at least once. Useful to spot '
                  'dead code — functions that are never invoked.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          _code('''
// Example: line coverage = 100% but branch coverage = 50%
double divide(double a, double b) {
  if (b == 0) return double.nan; // ← NOT covered if tests never pass b=0
  return a / b;                  // ← covered
}

// A test that only calls divide(10, 2) gives:
// Line coverage:     2/2 = 100% ✅
// Branch coverage:   1/2 = 50%  ⚠️ — the b==0 branch is never tested'''),

          const SizedBox(height: 16),
          _card(
            color: Colors.cyan.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Key Takeaways', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('• flutter test --coverage → coverage/lcov.info'),
                Text('• genhtml lcov.info -o html/ → human-readable HTML report'),
                Text('• Exclude generated files, main.dart, and DI setup'),
                Text('• Enforce minimum coverage in CI to prevent regression'),
                Text('• Branch coverage is more meaningful than line coverage'),
                Text('• 100% coverage ≠ bug-free code — quality of assertions matters'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _header(String title, Color color) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(title,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
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
                fontFamily: 'monospace', fontSize: 11, color: Color(0xFFCDD6F4))),
      ),
    );

Widget _card({required Color color, required Widget child}) => Card(
      color: color,
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    );
