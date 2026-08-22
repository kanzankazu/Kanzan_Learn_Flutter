// ============================================================
// PHASE 1 — Generics
// ============================================================
// Purpose: Demonstrates how Dart's type-parameter system (`<T>`) lets you
//          write code that is both type-safe AND reusable across different
//          data types, without falling back to `dynamic`.
//
// Run with:
//   dart run lib/phase1/08_generics/generics_demo.dart
//
// Prerequisites: Phase 0 complete (OOP, Collections); Phase 1 topics 1–7
// Dart SDK: >= 3.0.0 (for sealed class + exhaustive switch patterns)
//
// Feature: phase-1-dart-language, Requirement 8: Generics
// ============================================================
//
// WHY GENERICS?
//
// Without generics you face a dilemma:
//   • Duplicate code for every type (int version, String version, …)
//   • OR use `dynamic`, which throws type errors at RUNTIME, not compile time
//
// Generics give you the best of both worlds:
//   • ONE implementation that works for many types
//   • Type errors caught at COMPILE time — the compiler knows the exact type
//
// ============================================================

void main() {
  print('=== Generics Demo ===\n');

  _demoGenericClasses();
  _demoGenericFunctions();
  _demoBoundedGenerics();
  _demoResultType();
}

// ============================================================
// Section 1: Generic Classes
// ============================================================
// A class can be parameterised with one or more type parameters.
// The type parameter acts as a placeholder filled in by the caller.

// -------------------------------------------------------
// Box<T> — a simple single-value container.
//
// The `<T>` after the class name declares T as a type parameter.
// Any identifier works, but single capital letters are conventional:
//   T = "Type"      (general purpose)
//   E = "Element"   (collections)
//   K/V = "Key/Value" (maps)
//   R = "Return"    (callbacks)
// -------------------------------------------------------
class Box<T> {
  /// The value stored inside this box.
  final T value;

  /// Creates a [Box] wrapping [value].
  const Box(this.value);

  /// Transforms the value inside this box using [transform], returning a new
  /// [Box] with the result.
  ///
  /// This is the classic "functor map" operation: the box structure is
  /// preserved while the contained value is converted to a different type.
  ///
  /// Example:
  /// ```dart
  /// Box(42).map((n) => '$n items')  // → Box<String>('42 items')
  /// ```
  Box<U> map<U>(U Function(T) transform) {
    return Box<U>(transform(value));
  }

  @override
  String toString() => 'Box<${T}>(${value})';
}

// -------------------------------------------------------
// Pair<A, B> — holds two values of potentially different types.
//
// Two type parameters let us express a heterogeneous pair with
// full compile-time type safety on both slots.
// -------------------------------------------------------
class Pair<A, B> {
  /// The first element of the pair.
  final A first;

  /// The second element of the pair.
  final B second;

  /// Creates a [Pair] with [first] and [second].
  const Pair(this.first, this.second);

  /// Returns a new [Pair] with the two elements swapped.
  ///
  /// The return type is `Pair<B, A>` — notice that the type arguments are
  /// reversed, reflecting the fact that what was second is now first.
  ///
  /// Example:
  /// ```dart
  /// Pair(1, 'one').swap()  // → Pair<String, int>('one', 1)
  /// ```
  Pair<B, A> swap() => Pair<B, A>(second, first);

  @override
  String toString() => 'Pair<${A}, ${B}>(${first}, ${second})';
}

void _demoGenericClasses() {
  print('--- Section 1: Generic Classes ---\n');

  // Box<int>: the type argument is int
  final intBox = Box<int>(42);
  print('Box<int>:');
  print('  intBox          = $intBox');

  // Dart infers Box<String> from the argument — explicit annotation optional
  final strBox = Box('hello');
  print('  strBox          = $strBox');

  // Box.map: transforms Box<int> → Box<String>
  final mappedBox = intBox.map((n) => '$n items');
  print('  intBox.map(...)  → $mappedBox');

  // Chain: Box<int> → Box<bool>
  final boolBox = intBox.map((n) => n > 0);
  print('  intBox.map(n>0)  → $boolBox');

  print('');

  // Pair<int, String>
  final pair = Pair<int, String>(1, 'one');
  print('Pair<int, String>:');
  print('  pair            = $pair');
  print('  pair.first      = ${pair.first}');
  print('  pair.second     = "${pair.second}"');

  // swap() returns Pair<String, int>
  final swapped = pair.swap();
  print('  pair.swap()     = $swapped');
  // swapped.first is now a String — the compiler knows this at compile time
  print('  swapped.first.toUpperCase() = ${swapped.first.toUpperCase()}');

  print('');
}

// ============================================================
// Section 2: Generic Functions
// ============================================================
// Functions can also be generic — the type parameter is declared after
// the function name, before the parameter list.

/// Wraps any value in a [Box].
///
/// The type parameter [T] is inferred from the argument in most cases.
Box<T> boxIt<T>(T value) => Box<T>(value);

/// Returns the first element of [items] that satisfies [predicate],
/// or `null` if no element matches.
///
/// This is a generic version of [Iterable.firstWhere] with a null return
/// instead of throwing when nothing is found.
T? findFirstWhere<T>(List<T> items, bool Function(T) predicate) {
  for (final item in items) {
    if (predicate(item)) return item;
  }
  return null;
}

void _demoGenericFunctions() {
  print('--- Section 2: Generic Functions ---\n');

  // boxIt<T>: two concrete-type calls to show the same function works for both
  final boxedInt = boxIt(99); // T inferred as int
  final boxedStr = boxIt('dart'); // T inferred as String
  print('boxIt():');
  print('  boxIt(99)      = $boxedInt');
  print('  boxIt("dart")  = $boxedStr');
  print('');

  // findFirstWhere<T>: works on any List<T>
  final ints = [3, 7, 12, 18, 25, 42];
  final firstEven = findFirstWhere<int>(ints, (n) => n % 2 == 0);
  print('findFirstWhere():');
  print('  list         = $ints');
  print('  first even   = $firstEven');

  final words = ['apple', 'banana', 'cherry', 'date'];
  final shortWord = findFirstWhere(words, (w) => w.length <= 4);
  // T is inferred as String from the list type — no explicit <String> needed
  print('  words        = $words');
  print('  first ≤4 ch  = $shortWord');
  print('');

  // -------------------------------------------------------
  // List<dynamic> vs List<Object> vs List<String> — comparison
  //
  // (a) Compiler rejects wrong type:
  //       List<dynamic>  — NO rejection. Any value accepted at compile time.
  //       List<Object>   — NO rejection. Everything is-an Object in Dart.
  //       List<String>   — YES rejection. `list.add(42)` is a compile error.
  //
  // (b) Cast needed when reading:
  //       List<dynamic>  — YES. `list[0]` is dynamic; you must cast: `list[0] as String`
  //       List<Object>   — YES. `list[0]` is Object; you must cast: `(list[0] as String)`
  //       List<String>   — NO.  `list[0]` is already typed String. No cast needed.
  //
  // (c) When to use:
  //       List<dynamic>  — Avoid in new code. Use only for truly mixed JSON-like data.
  //       List<Object>   — When you need to hold values of different types that all
  //                        share Object's interface (toString, ==, hashCode).
  //       List<String>   — Default choice when you know all elements are strings.
  //                        Prefer the most specific type parameter possible.
  // -------------------------------------------------------

  print('List<dynamic> vs List<Object> vs List<String>:');

  final dynamicList = <dynamic>['hello', 42, true];
  // Reading requires a cast — the compiler has no idea what type is inside
  final firstDynamic = dynamicList[0] as String; // explicit cast required
  print('  List<dynamic>[0] as String = "$firstDynamic"');

  final objectList = <Object>['world', 100, 3.14];
  final firstObject = objectList[0] as String; // cast also required
  print('  List<Object>[0] as String  = "$firstObject"');

  final stringList = <String>['dart', 'flutter', 'generics'];
  final firstString = stringList[0]; // no cast — already typed String
  print('  List<String>[0]            = "$firstString" (no cast needed)');

  // Attempting to add a wrong type to List<String> is a COMPILE ERROR:
  // stringList.add(42);
  // ↑ Error: The argument type 'int' can't be assigned to the parameter type 'String'
  // Uncomment the line above to see the compile-time rejection.

  print('');
}

// ============================================================
// Section 3: Bounded Generics
// ============================================================
// A type bound (`T extends SomeType`) constrains which types can be used
// as T, giving you access to the methods defined on the bound type.

/// Returns the largest element in [items].
///
/// [T] is bounded to [Comparable], which means T must support the
/// `compareTo()` method. This bound gives us compile-time access to
/// `compareTo`, letting us compare elements safely.
///
/// Types that satisfy this bound include: int, double, String,
/// DateTime, Duration, and any custom class that implements Comparable.
///
/// Throws [ArgumentError] if [items] is empty (no meaningful maximum exists).
// NOTE: The bound is `Comparable` (without `<T>`) rather than `Comparable<T>`.
// In Dart, `int` implements `Comparable<num>` (not `Comparable<int>`), so the
// tighter `Comparable<T>` bound would reject `int` at the call site.
// Using the raw `Comparable` bound accepts int, double, String, DateTime, etc.
T findMax<T extends Comparable>(List<T> items) {
  if (items.isEmpty) {
    throw ArgumentError('Cannot find max of an empty list.');
  }
  // Start with the first element as the current maximum.
  var max = items.first;
  for (final item in items) {
    // compareTo returns positive when item > max
    if (item.compareTo(max) > 0) {
      max = item;
    }
  }
  return max;
}

void _demoBoundedGenerics() {
  print('--- Section 3: Bounded Generics ---\n');

  // findMax<int>: works because int implements Comparable<int>
  final ints = [3, 41, 17, 8, 55, 22];
  final maxInt = findMax<int>(ints);
  print('findMax<int>:');
  print('  list    = $ints');
  print('  max     = $maxInt');
  print('');

  // findMax<double>: same function, different type — no duplicate code needed
  final doubles = [1.5, 2.7, 0.3, 9.1, 4.0];
  final maxDouble = findMax(doubles); // T inferred as double
  print('findMax<double>:');
  print('  list    = $doubles');
  print('  max     = $maxDouble');
  print('');

  // findMax<String>: String is Comparable<String> — lexicographic order
  final words = ['banana', 'apple', 'cherry', 'date', 'elderberry'];
  final maxWord = findMax(words); // T inferred as String
  print('findMax<String>:');
  print('  list    = $words');
  print('  max     = "$maxWord" (lexicographic maximum)');
  print('');

  // Empty list → ArgumentError (caught gracefully)
  try {
    findMax<int>([]);
  } on ArgumentError catch (e) {
    print('  findMax([]) throws → ArgumentError: ${e.message}');
  }

  print('');

  // Without the bound, `item.compareTo(max)` would be a compile error
  // because the compiler wouldn't know that T has a `compareTo` method.
  // The bound `T extends Comparable<T>` is what unlocks that method.
}

// ============================================================
// Section 4: Result<T, E> — Generic Sealed Class
// ============================================================
// A `Result` type is a functional alternative to exceptions.
// Instead of throwing, a function returns either a `Success` (with a value)
// or a `Failure` (with an error). The caller must handle both cases.
//
// This is intentionally duplicated from generics_demo.dart → file_processor.dart.
// Seeing the same pattern in two different contexts reinforces understanding.

/// A type-safe container representing either a successful outcome ([Success])
/// or a failed outcome ([Failure]).
///
/// [T] is the type of the success value.
/// [E] is the type of the error/failure descriptor.
///
/// Always exhausted via `switch`:
/// ```dart
/// switch (result) {
///   case Success(:final value) => print('Got: $value');
///   case Failure(:final error) => print('Err: $error');
/// }
/// ```
sealed class Result<T, E> {}

/// Represents a successful [Result] carrying a [value] of type [T].
class Success<T, E> extends Result<T, E> {
  /// The success value.
  final T value;

  /// Creates a [Success] wrapping [value].
  Success(this.value);

  @override
  String toString() => 'Success(${value})';
}

/// Represents a failed [Result] carrying an [error] descriptor of type [E].
class Failure<T, E> extends Result<T, E> {
  /// The error descriptor.
  final E error;

  /// Creates a [Failure] wrapping [error].
  Failure(this.error);

  @override
  String toString() => 'Failure(${error})';
}

// -------------------------------------------------------
// Example functions that return Result<T, E>
// -------------------------------------------------------

/// Parses [input] as an integer, returning a [Success] on success or a
/// [Failure] with a human-readable message on failure.
Result<int, String> parseInt(String input) {
  final parsed = int.tryParse(input);
  if (parsed == null) {
    return Failure('Cannot parse "$input" as an integer');
  }
  return Success(parsed);
}

/// Divides [numerator] by [denominator], returning a [Failure] for
/// division-by-zero instead of throwing.
Result<double, String> safeDivide(double numerator, double denominator) {
  if (denominator == 0) {
    return Failure('Division by zero is undefined');
  }
  return Success(numerator / denominator);
}

void _demoResultType() {
  print('--- Section 4: Result<T, E> — Generic Sealed Class ---\n');

  // ---- parseInt ----
  final inputs = ['42', '-7', '0', 'hello', '3.14'];
  print('parseInt():');
  for (final input in inputs) {
    final result = parseInt(input);
    // The switch is exhaustive: both Success and Failure MUST be handled.
    // Removing either case is a compile error — the sealed class guarantees this.
    final message = switch (result) {
      Success(:final value) => 'OK  → $value',
      Failure(:final error) => 'ERR → $error',
    };
    print('  parseInt("$input") = $message');
  }
  print('');

  // ---- safeDivide ----
  print('safeDivide():');
  final divisions = [
    (10.0, 4.0),
    (7.0, 2.0),
    (5.0, 0.0), // division by zero — returns Failure
  ];
  for (final (num, den) in divisions) {
    final result = safeDivide(num, den);
    switch (result) {
      case Success(:final value):
        print('  $num / $den = ${value.toStringAsFixed(4)}');
      case Failure(:final error):
        print('  $num / $den = ERR → $error');
    }
  }
  print('');

  // ---- Chaining Results ----
  // A common pattern: parse first, then use the value in a second operation.
  print('Chaining Results:');
  final raw = '20';
  final chained = switch (parseInt(raw)) {
    Failure(:final error) => Failure<double, String>(error),
    Success(:final value) => safeDivide(value.toDouble(), 4.0),
  };
  switch (chained) {
    case Success(:final value):
      print('  parseInt("$raw") then ÷4 = $value');
    case Failure(:final error):
      print('  Chain failed → $error');
  }
  print('');

  // ---- Type safety demonstration ----
  // Result uses two type parameters so both sides are strongly typed.
  // The compiler knows:
  //   Success<int, String>.value is int  — no cast needed
  //   Failure<int, String>.error is String — no cast needed
  print('Type safety:');
  final r = parseInt('100');
  if (r is Success<int, String>) {
    // r.value is int — the compiler allows arithmetic directly
    print('  value + 1 = ${r.value + 1}  (no cast needed, value is int)');
  }

  print('');
  print('Result<T, E> forces the caller to handle both Success and Failure.');
  print('Unlike exceptions, failures are visible in the function signature.');
}
