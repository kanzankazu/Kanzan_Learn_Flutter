// ============================================================
// PHASE 1 — Pattern Matching & Sealed Class
// ============================================================
// ignore_for_file: unnecessary_cast
// (Intentional: explicit as-casts are shown in the "old style" comparison
//  block to contrast with Dart 3 type-pattern syntax that does the same thing
//  without a cast. The analyzer correctly flags them as unnecessary in Dart 3.)
// Purpose: Demonstrates Dart 3 pattern matching — sealed classes,
//          type patterns with simultaneous destructuring, `when` guards,
//          exhaustive switch expressions, and Record/List/Map destructuring.
//
// Run with:
//   dart run lib/phase1/07_pattern_matching/pattern_matching_demo.dart
//
// Prerequisites: Phase 0 OOP + Phase 1 Generics (sealed class concept)
// Dart SDK: >= 3.0.0 (patterns, sealed classes, and exhaustive switch)
//
// Feature: phase-1-dart-language, Requirement 7: Pattern Matching & Sealed Class
// ============================================================

// ============================================================
// SEALED CLASS HIERARCHY
//
// A `sealed` class restricts which files can subclass it — only files
// in the SAME LIBRARY (same file or same `part` set) can extend it.
//
// The compiler uses this knowledge to enforce EXHAUSTIVE switch coverage:
// if you forget a subclass case, you get a COMPILE-TIME error, not a
// runtime crash. This is the key advantage over a plain abstract class.
//
// Hierarchy used in this demo:
//
//   Shape  (sealed)
//   ├── Circle    (radius)
//   ├── Rectangle (width, height)
//   └── Triangle  (base, height)
// ============================================================

/// Base sealed class — cannot be extended outside this library.
sealed class Shape {
  // Const constructor so subclasses can declare their own `const` constructors.
  const Shape();
}

/// A circle defined by its [radius].
final class Circle extends Shape {
  /// The radius of the circle (must be positive).
  final double radius;
  const Circle(this.radius);
}

/// A rectangle defined by its [width] and [height].
final class Rectangle extends Shape {
  /// The width of the rectangle (must be positive).
  final double width;

  /// The height of the rectangle (must be positive).
  final double height;
  const Rectangle(this.width, this.height);
}

/// A triangle defined by its [base] and [height].
final class Triangle extends Shape {
  /// The base length of the triangle (must be positive).
  final double base;

  /// The perpendicular height of the triangle (must be positive).
  final double height;
  const Triangle(this.base, this.height);
}

// ============================================================
// Main entry point — calls each demo section in order
// ============================================================

void main() {
  print('=== Pattern Matching & Sealed Class Demo ===\n');

  _demoSealedClassSwitch();
  _demoConstantAndWildcardPatterns();
  _demoTypePatternWithDestructure();
  _demoWhenGuardClause();
  _demoDestructuringPatterns();
  _demoSideBySideComparison();
}

// ============================================================
// Section 1: Exhaustive sealed-class switch
//
// Because Shape is sealed, the compiler KNOWS every possible subtype.
// The switch expression MUST cover Circle, Rectangle, and Triangle —
// omitting any one causes a compile-time error.
// ============================================================

void _demoSealedClassSwitch() {
  print('--- 1. Exhaustive Sealed-Class Switch ---\n');

  // Calculate area for any Shape using an exhaustive switch expression.
  double area(Shape shape) => switch (shape) {
        // Type pattern: match the runtime type AND bind the variable.
        Circle(:var radius) => 3.14159 * radius * radius,
        Rectangle(:var width, :var height) => width * height,
        Triangle(:var base, :var height) => 0.5 * base * height,
        // No `default` needed — the compiler verified all 3 cases are covered.
      };

  final shapes = <Shape>[
    const Circle(5),
    const Rectangle(4, 6),
    const Triangle(3, 8),
  ];

  for (final shape in shapes) {
    final a = area(shape);
    print('  ${shape.runtimeType} → area = ${a.toStringAsFixed(2)}');
  }

  print('');

  // ============================================================
  // INCOMPLETE SWITCH — compile error if uncommented
  //
  // The following code would NOT compile because Triangle is missing:
  //
  //   double brokenArea(Shape shape) => switch (shape) {
  //         Circle(:var radius) => 3.14159 * radius * radius,
  //         Rectangle(:var width, :var height) => width * height,
  //         // Missing Triangle! Compiler error:
  //         //   The type 'Shape' is not exhaustively matched by the switch cases
  //         //   since it doesn't match 'Triangle'.
  //       };
  //
  // This compile-time guarantee is WHY sealed classes are so powerful —
  // you can NEVER forget to handle a new subtype at runtime.
  // ============================================================
}

// ============================================================
// Section 2: Constant patterns and wildcard pattern `_`
//
// Constant pattern — matches a specific literal value (int, String, bool, etc.)
// Wildcard `_`    — matches ANYTHING but discards the value (like a catch-all)
// ============================================================

void _demoConstantAndWildcardPatterns() {
  print('--- 2. Constant Patterns and Wildcard `_` ---\n');

  // Constant pattern: each `case` checks for an exact value.
  String describeNumber(int n) => switch (n) {
        0 => 'zero',
        1 => 'one',
        2 => 'two',
        // Wildcard `_`: matches any int that wasn't caught above.
        // Using `_` also signals "we intentionally don't need the value".
        _ => 'many',
      };

  for (final n in [0, 1, 2, 3, 99]) {
    print('  describeNumber($n) → ${describeNumber(n)}');
  }

  print('');

  // Constant pattern on String
  String httpVerb(String method) => switch (method.toUpperCase()) {
        'GET' => 'read resource',
        'POST' => 'create resource',
        'PUT' => 'replace resource',
        'DELETE' => 'remove resource',
        _ => 'unknown verb',
      };

  for (final m in ['GET', 'post', 'PATCH']) {
    print('  httpVerb("$m") → ${httpVerb(m)}');
  }

  print('');
}

// ============================================================
// Section 3: Type pattern with simultaneous type-check + field destructure
//
// Dart 3 object patterns let you both CHECK the type and BIND its fields
// in a single `case` clause — no separate `is` check and `as` cast needed.
//
// Syntax:  case Circle(:var radius):
//   •  Checks: is the value a Circle?
//   •  Binds:  `radius` is extracted from Circle.radius automatically.
//
// This replaces the old boilerplate:
//   if (shape is Circle) { final radius = (shape as Circle).radius; ... }
// ============================================================

void _demoTypePatternWithDestructure() {
  print('--- 3. Type Pattern with Field Destructure ---\n');

  void describeShape(Shape shape) {
    // Each case simultaneously checks the type AND destructures fields.
    // The `:var fieldName` syntax is shorthand for `fieldName: var fieldName`.
    final description = switch (shape) {
      Circle(:var radius) =>
        'Circle with radius $radius, circumference=${(2 * 3.14159 * radius).toStringAsFixed(2)}',
      Rectangle(:var width, :var height) =>
        'Rectangle ${width}×${height}, diagonal=${_diagonal(width, height).toStringAsFixed(2)}',
      Triangle(:var base, :var height) =>
        'Triangle base=$base height=$height, area=${(0.5 * base * height).toStringAsFixed(2)}',
    };
    print('  $description');
  }

  describeShape(const Circle(7));
  describeShape(const Rectangle(3, 4));
  describeShape(const Triangle(6, 5));

  print('');
}

/// Returns the diagonal of a rectangle via the Pythagorean theorem.
double _diagonal(double w, double h) => (w * w + h * h) > 0
    ? _sqrt(w * w + h * h)
    : 0;

/// Simple integer square root approximation for demo purposes.
double _sqrt(double value) {
  if (value <= 0) return 0;
  var result = value;
  // Newton-Raphson iterations
  for (var i = 0; i < 20; i++) {
    result = (result + value / result) / 2;
  }
  return result;
}

// ============================================================
// Section 4: `when` guard clause
//
// A `when` guard adds an EXTRA boolean condition on top of a pattern.
// The case only matches if both the pattern AND the guard are true.
//
// Syntax:  case Circle(:var radius) when radius > 10:
// ============================================================

void _demoWhenGuardClause() {
  print('--- 4. `when` Guard Clause ---\n');

  String classifyShape(Shape shape) => switch (shape) {
        // Guard: Circle with large radius → specific label
        Circle(:var radius) when radius > 10 =>
          'Large circle (r=$radius)',
        Circle(:var radius) when radius > 0 =>
          'Small circle (r=$radius)',
        Circle() =>
          'Degenerate circle (radius ≤ 0)',

        // Guard: Square is a special Rectangle where width == height
        Rectangle(:var width, :var height) when width == height =>
          'Square (side=$width)',
        Rectangle(:var width, :var height) =>
          'Rectangle (${width}×${height})',

        // Guard: Right-angled triangle — just for demo (3-4-5 check)
        Triangle(:var base, :var height) when base == 3 && height == 4 =>
          'Classic 3-4 triangle',
        Triangle(:var base, :var height) =>
          'Triangle (base=$base, h=$height)',
      };

  final shapes = <Shape>[
    const Circle(15),       // large circle
    const Circle(5),        // small circle
    const Rectangle(6, 6),  // square
    const Rectangle(4, 7),  // rectangle
    const Triangle(3, 4),   // 3-4 triangle
    const Triangle(5, 12),  // regular triangle
  ];

  for (final s in shapes) {
    print('  ${classifyShape(s)}');
  }

  print('');
}

// ============================================================
// Section 5: Destructuring patterns — Record, List, Map
//
// Dart 3 can destructure structured data directly in patterns:
//   Record  → (a, b) or ({int age, String name})
//   List    → [first, second, ...rest]
//   Map     → {'key': value}
// ============================================================

void _demoDestructuringPatterns() {
  print('--- 5. Destructuring Patterns ---\n');

  // ----- 5a: Record destructuring -----
  print('  [Record destructuring]');

  // Positional record — fields accessed as .$1, .$2, ...
  final (int x, int y) = (10, 20);
  print('  Positional record (10, 20): x=$x, y=$y');

  // Named record — fields accessed by name
  final ({String city, int population}) place =
      (city: 'Jakarta', population: 11000000);
  print('  Named record: city=${place.city}, pop=${place.population}');

  // Record as function return type: swap two values
  (String, int) labeledPair(String label, int value) => (label, value);
  final (String label, int val) = labeledPair('score', 42);
  print('  Returned record: label="$label", val=$val');

  // Destructure inside a switch
  final point = (3, -5);
  final quadrant = switch (point) {
    (var px, var py) when px > 0 && py > 0 => 'Q1',
    (var px, var py) when px < 0 && py > 0 => 'Q2',
    (var px, var py) when px < 0 && py < 0 => 'Q3',
    (var px, var py) when px > 0 && py < 0 => 'Q4',
    _ => 'on axis',
  };
  print('  Point $point is in $quadrant');

  print('');

  // ----- 5b: List destructuring -----
  print('  [List destructuring]');

  // Bind first, second, and collect the rest into a list
  final numbers = [10, 20, 30, 40, 50];
  final [first, second, ...rest] = numbers;
  print('  List $numbers:');
  print('    first  = $first');
  print('    second = $second');
  print('    rest   = $rest');

  // Pattern matching in switch on a List
  String describeList(List<int> items) => switch (items) {
        [] => 'empty list',
        [var only] => 'single element: $only',
        [var head, ...var tail] => 'head=$head, tail=$tail',
      };

  print('  describeList([])        → ${describeList([])}');
  print('  describeList([7])       → ${describeList([7])}');
  print('  describeList([1,2,3])   → ${describeList([1, 2, 3])}');

  print('');

  // ----- 5c: Map destructuring -----
  print('  [Map destructuring]');

  final config = {
    'host': 'localhost',
    'port': '8080',
    'debug': 'true',
  };

  // Extract specific keys from the map; other keys are ignored.
  final {'host': String host, 'port': String port} = config;
  print('  Map config extracted: host="$host", port="$port"');

  // Map pattern in switch — match on key presence + value
  String routeRequest(Map<String, String> req) => switch (req) {
        {'method': 'GET', 'path': var path} => 'GET $path',
        {'method': 'POST', 'path': var path} => 'POST $path',
        {'method': var method} => 'Unsupported method: $method',
        _ => 'Malformed request',
      };

  print('  routeRequest GET  → ${routeRequest({'method': 'GET', 'path': '/users'})}');
  print('  routeRequest POST → ${routeRequest({'method': 'POST', 'path': '/items'})}');
  print('  routeRequest PUT  → ${routeRequest({'method': 'PUT', 'path': '/x'})}');

  print('');
}

// ============================================================
// Section 6: Side-by-side comparison
//
// OLD style: if/else + `is` type-check + `as` cast — verbose, error-prone.
// NEW style: switch + type patterns — concise, exhaustive, no unsafe casts.
//
// Both functions compute the SAME output for the SAME input.
// ============================================================

void _demoSideBySideComparison() {
  print('--- 6. Side-by-Side Comparison: Old vs New ---\n');
  print('  Same shapes, same output — two styles:\n');

  final shapes = <Shape>[
    const Circle(3),
    const Rectangle(5, 4),
    const Triangle(6, 8),
  ];

  // Collect output lines from both approaches and then compare.
  final oldLines = <String>[];
  final newLines = <String>[];

  for (final shape in shapes) {
    oldLines.add(_describeOldStyle(shape));
    newLines.add(_describeNewStyle(shape));
  }

  print('  ${' Old style (if/else + is + as)'.padRight(40)} | New style (switch pattern)');
  print('  ${'-' * 40} | ${'-' * 40}');

  for (var i = 0; i < oldLines.length; i++) {
    final old = oldLines[i].padRight(40);
    final neo = newLines[i];
    print('  $old | $neo');
  }

  print('');

  // Verify that both approaches produce identical results.
  final identical = List.generate(oldLines.length, (i) => oldLines[i] == newLines[i])
      .every((match) => match);
  print('  Outputs identical: $identical');

  print('');
  print('  Key differences:');
  print('  Old: 3 separate if/else + 3 `is` checks + 3 `as` casts');
  print('  New: 1 switch expression, no `as` cast, compiler-verified exhaustive');
  print('  Old: Adding a new Shape subtype → SILENT bug (falls through to else)');
  print('  New: Adding a new Shape subtype → COMPILE ERROR (must add case)');
}

/// OLD approach: type-check with `is`, cast with `as`, no exhaustiveness.
///
/// Problems:
/// - Verbose — three separate `if/else if/else` blocks
/// - Unsafe cast: `as` throws at runtime if you make a mistake
/// - Non-exhaustive: a new Shape subtype silently falls through to `else`
String _describeOldStyle(Shape shape) {
  if (shape is Circle) {
    // Must cast explicitly to access the field — even though we just checked.
    final circle = shape as Circle;
    return 'Circle r=${circle.radius}';
  } else if (shape is Rectangle) {
    final rect = shape as Rectangle;
    return 'Rect ${rect.width}×${rect.height}';
  } else if (shape is Triangle) {
    final tri = shape as Triangle;
    return 'Triangle b=${tri.base} h=${tri.height}';
  } else {
    // This branch is unreachable NOW, but it exists to satisfy the compiler.
    // If a new Shape subtype is added and we forget to update this function,
    // it silently falls here — no warning, no error.
    return 'Unknown shape';
  }
}

/// NEW approach: switch expression with type patterns.
///
/// Benefits:
/// - Concise — field binding happens inside the case clause
/// - Safe — no `as` cast needed; the compiler knows the type from the pattern
/// - Exhaustive — adding a new Shape subtype causes a COMPILE-TIME error here
String _describeNewStyle(Shape shape) => switch (shape) {
      // `:var radius` is shorthand for `radius: var radius` — extracts the
      // `radius` field from Circle and binds it as a local variable.
      Circle(:var radius) => 'Circle r=$radius',
      Rectangle(:var width, :var height) => 'Rect ${width}×${height}',
      Triangle(:var base, :var height) => 'Triangle b=$base h=$height',
    };
