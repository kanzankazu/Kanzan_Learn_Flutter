// ============================================================
// PHASE 1 — Records & Destructuring
// ============================================================
// Purpose: Demonstrates Dart 3's Record type — lightweight, anonymous,
//          immutable composite values — and various destructuring patterns
//          for Records, Lists, and Maps.
//
// Run with:
//   dart run lib/phase1/10_records/records_demo.dart
//
// Prerequisites: Phase 1 — Pattern Matching (07_pattern_matching)
// Dart SDK: >= 3.0.0 (Records introduced in Dart 3)
//
// Feature: phase-1-dart-language, Requirement 10: Records & Destructuring
// ============================================================

void main() {
  print('======================================');
  print('  PHASE 1: Records & Destructuring');
  print('======================================\n');

  _demoPositionalRecord();
  _demoNamedRecord();
  _demoFunctionReturningRecord();
  _demoDestructuringRecord();
  _demoListDestructuring();
  _demoMapDestructuring();
  _demoRecordsInSwitch();
  _demoMapVsRecord();

  print('======================================');
  print('  Done!');
  print('======================================');
}

// ============================================================
// SECTION 1: Positional Records
// ============================================================
// A positional record groups values by position, like an anonymous tuple.
// Fields are accessed via .$1, .$2, .$3, etc. (1-indexed).
void _demoPositionalRecord() {
  print('--- 1. Positional Record ---');

  // Create a positional record with (int, String)
  (int, String) person = (42, 'Alice');

  // Access fields by position: .$1, .$2
  int age = person.$1;
  String name = person.$2;

  print('Record: $person');
  print('  .\$1 (age)  = $age');
  print('  .\$2 (name) = $name');

  // Records are structural — two records with the same type & values are equal
  (int, String) sameValues = (42, 'Alice');
  print('  Equal to identical values: ${person == sameValues}'); // true
  print('');
}

// ============================================================
// SECTION 2: Named Records
// ============================================================
// Named records use field labels, making code more readable.
// Fields are accessed by their name: .age, .name, etc.
void _demoNamedRecord() {
  print('--- 2. Named Record ---');

  // Named records use the ({type label, ...}) syntax
  ({int age, String name}) employee = (age: 30, name: 'Bob');

  // Access fields by name
  int age = employee.age;
  String name = employee.name;

  print('Record: $employee');
  print('  .age  = $age');
  print('  .name = $name');

  // Mix of positional and named fields is also valid
  (int, {String city}) location = (100, city: 'Jakarta');
  print('  Mixed record: position=${location.$1}, city=${location.city}');
  print('');
}

// ============================================================
// SECTION 3: Function Returning a Record
// ============================================================
// Records shine as return types — a function can return multiple typed
// values without defining a helper class.

/// Returns a full name split into (firstName, lastName) and the length.
(String firstName, String lastName, int totalLength) _splitName(String full) {
  final parts = full.split(' ');
  final first = parts.first;
  final last = parts.length > 1 ? parts.last : '';
  return (first, last, full.length);
}

/// Returns min and max of an integer list as a named record.
({int min, int max}) _minMax(List<int> values) {
  // Assumes non-empty list for simplicity
  int minVal = values.reduce((a, b) => a < b ? a : b);
  int maxVal = values.reduce((a, b) => a > b ? a : b);
  return (min: minVal, max: maxVal);
}

void _demoFunctionReturningRecord() {
  print('--- 3. Function Returning a Record ---');

  // Unpack the returned record directly
  final (first, last, length) = _splitName('Charlie Chaplin');
  print('Full name split:');
  print('  firstName    = $first');
  print('  lastName     = $last');
  print('  totalLength  = $length');

  // Named record return
  final stats = _minMax([5, 2, 8, 1, 9, 3]);
  print('minMax([5,2,8,1,9,3]):');
  print('  min = ${stats.min}');
  print('  max = ${stats.max}');
  print('');
}

// ============================================================
// SECTION 4: Record Destructuring
// ============================================================
// The `var (x, y) = record` syntax unpacks record fields into local variables.
// The destructured variables can then be used freely in subsequent expressions.
void _demoDestructuringRecord() {
  print('--- 4. Record Destructuring ---');

  final point = (3.0, 4.0); // a 2D point (x, y)

  // Destructure into local variables x and y
  var (x, y) = point;

  // Use x and y in a subsequent expression (Pythagoras distance from origin)
  // The destructured variables x and y are used directly in the formula below
  print('Point: $point');
  print('  Destructured: x = $x, y = $y');
  print('  Distance from origin = ${(x * x + y * y).sqrt().toStringAsFixed(4)}');

  // Named record destructuring: use : to bind to a local name
  final ({String brand, int year}) car = (brand: 'Toyota', year: 2023);
  final (:brand, :year) = car; // shorthand — variable names match field names
  print('Car record: $car');
  print('  Destructured: brand = $brand, year = $year');
  print('');
}

// Small extension to avoid importing dart:math for sqrt
extension on double {
  double sqrt() {
    // Newton–Raphson approximation — good enough for demo purposes
    if (this <= 0) return 0;
    double x = this;
    for (int i = 0; i < 20; i++) {
      x = (x + this / x) / 2;
    }
    return x;
  }
}

// ============================================================
// SECTION 5: List Destructuring
// ============================================================
// Dart 3 pattern matching supports `[first, second, ...rest]` to unpack lists.
void _demoListDestructuring() {
  print('--- 5. List Destructuring ---');

  final fruits = ['apple', 'banana', 'cherry', 'date', 'elderberry'];

  // Destructure: first two elements + the remainder via rest pattern `...rest`
  final [first, second, ...rest] = fruits;

  print('List: $fruits');
  print('  first  = $first');
  print('  second = $second');
  print('  rest   = $rest');

  // Head-only destructuring (ignore the rest with `...`)
  final [head, ...] = fruits;
  print('  head only = $head');

  // Nested list destructuring
  final matrix = [[1, 2], [3, 4]];
  final [[a, b], [c, d]] = matrix;
  print('  matrix[0]: a=$a, b=$b  |  matrix[1]: c=$c, d=$d');
  print('');
}

// ============================================================
// SECTION 6: Map Destructuring
// ============================================================
// Map patterns extract values by key. The key must be a constant expression.
void _demoMapDestructuring() {
  print('--- 6. Map Destructuring ---');

  final config = {
    'host': 'localhost',
    'port': '8080',
    'debug': 'true',
  };

  // Extract specific keys — only listed keys are extracted; others are ignored
  final {'host': host, 'port': port} = config;
  print('Config map: $config');
  print('  host = $host');
  print('  port = $port');

  // Map pattern in a switch expression (see Section 7), but also works here:
  // Explicit dynamic value type so the pattern can cast each field individually
  final Map<String, dynamic> json = {'status': 200, 'message': 'OK'};
  final {'status': int statusCode, 'message': String message} = json;
  print('JSON: $json');
  print('  statusCode = $statusCode');
  print('  message    = $message');
  print('');
}

// ============================================================
// SECTION 7: Records in switch Expression
// ============================================================
// switch expressions can match on record types, giving exhaustive dispatch
// over composite values without nested if/else chains.

/// Classifies a point in 2D space based on its (x, y) values.
String _classifyPoint((num, num) point) {
  return switch (point) {
    // Case 1: both coordinates are zero — the origin
    (0, 0) => 'origin',

    // Case 2: x is zero, any y — on the Y-axis
    (0, var y) => 'on Y-axis at y=$y',

    // Case 3: y is zero, any x — on the X-axis
    (var x, 0) => 'on X-axis at x=$x',

    // Wildcard: anything else — a general point in the plane
    _ => 'point at (${point.$1}, ${point.$2})',
  };
}

/// Routes an HTTP-style response record to a human-readable status.
String _describeResponse((int code, String body) response) {
  return switch (response) {
    // Typed case 1: 2xx success range
    (>= 200 && < 300, final body) => 'Success: $body',

    // Typed case 2: 4xx client error
    (>= 400 && < 500, final body) => 'Client error: $body',

    // Wildcard: everything else (5xx, redirects, etc.)
    _ => 'Other (${response.$1}): ${response.$2}',
  };
}

void _demoRecordsInSwitch() {
  print('--- 7. Records in switch Expression ---');

  // Geometric point classification
  final points = [(0, 0), (0, 5), (3, 0), (3, 4)];
  for (final p in points) {
    print('  classify$p → ${_classifyPoint(p)}');
  }

  print('');

  // HTTP response classification
  final responses = <(int, String)>[
    (200, 'data returned'),
    (404, 'not found'),
    (500, 'internal server error'),
  ];
  for (final r in responses) {
    print('  ${_describeResponse(r)}');
  }
  print('');
}

// ============================================================
// SECTION 8: Map vs Record — Side-by-Side Comparison
// ============================================================
// Both Map and Record can represent composite data, but they have
// very different characteristics. This section prints the SAME data
// using both approaches to make the difference tangible.
//
// Record advantages over Map:
//   1. TYPE SAFETY  — each field has a specific compile-time type;
//                     no accidental wrong-type values or missing keys.
//   2. IMMUTABILITY — Records are value types; fields cannot be reassigned
//                     after creation, preventing accidental mutation.
//   3. CONCISENESS  — No key lookup noise (`map['field']`); fields are
//                     accessed via `.fieldName` with IDE auto-complete.
void _demoMapVsRecord() {
  print('--- 8. Map vs Record (Identical Data, Two Approaches) ---');

  // ---- Using Map ----
  final Map<String, dynamic> userMap = {
    'name': 'Diana',
    'age': 28,
    'city': 'Bandung',
  };

  // Map access requires casting — no compile-time type guarantee
  final String mapName = userMap['name'] as String;
  final int mapAge = userMap['age'] as int;
  final String mapCity = userMap['city'] as String;

  print('  [Map]');
  print('    name : $mapName');
  print('    age  : $mapAge');
  print('    city : $mapCity');

  // ---- Using Record ----
  final ({String name, int age, String city}) userRecord = (
    name: 'Diana',
    age: 28,
    city: 'Bandung',
  );

  // Record access is type-safe — no cast needed
  final String recName = userRecord.name;
  final int recAge = userRecord.age;
  final String recCity = userRecord.city;

  print('  [Record]');
  print('    name : $recName');
  print('    age  : $recAge');
  print('    city : $recCity');

  // Confirm the printed values are identical
  assert(mapName == recName, 'names must match');
  assert(mapAge == recAge, 'ages must match');
  assert(mapCity == recCity, 'cities must match');

  print('');
  print('  Both approaches printed identical data. ✓');
  print('  Record wins on: type safety, immutability, conciseness.');
  print('');
}
