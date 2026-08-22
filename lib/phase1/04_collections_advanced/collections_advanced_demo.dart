// ============================================================
// PHASE 1 — Collections Advanced
// ============================================================
// Feature: phase-1-dart-language, Requirement 4: Collections Advanced
//
// ignore_for_file: invalid_null_aware_operator, dead_code
// (Intentional: ...? spread is shown on a non-nullable list to demonstrate
//  the syntax; the dead_code block demonstrates an unreachable catch branch
//  after a guaranteed-non-empty list guard, keeping the example complete.)// Purpose: Demonstrates advanced collection operations in Dart —
//          .map(), .where(), .fold(), .reduce(), spread operators,
//          collection-if, collection-for, chaining, and a
//          side-by-side imperative vs functional comparison.
//
// Run with: dart run lib/phase1/04_collections_advanced/collections_advanced_demo.dart
//
// Prerequisites: Phase 0 complete (especially Collections & OOP).
//               You already know List, Map, Set from Phase 0 —
//               now we layer on functional-style operations.
//
// Dart SDK: >= 3.0.0
// ============================================================

void main() {
  print('=== Collections Advanced Demo ===\n');

  _demoMapTransformation();
  _demoWhereFilter();
  _demoFoldAccumulate();
  _demoReduceVsFold();
  _demoSpreadOperator();
  _demoCollectionIfFor();
  _demoOperationChaining();
  _demoImperativeVsFunctional(); // Side-by-side comparison — placed last intentionally
}

// ============================================================
// 1. .map() — Transform every element into a new type
// ============================================================

/// Demonstrates [Iterable.map], which applies a function to every element
/// and returns a lazy [Iterable]. Call [toList] to materialise it.
///
/// Think of it as: "for every item, produce a new item of (possibly) a
/// different type." The original list is never mutated.
void _demoMapTransformation() {
  print('--- 1. .map() Transformation ---');

  final List<int> numbers = [1, 2, 3, 4, 5];

  // Transform List<int> → List<String>
  // The arrow function receives each int and returns a formatted String.
  final List<String> labels = numbers.map((n) => 'Item $n').toList();

  print('Original : $numbers');
  print('Mapped   : $labels');

  // You can also change the shape of the data, e.g. int → double
  final List<double> halved = numbers.map((n) => n / 2).toList();
  print('Halved   : $halved');

  // .map() is LAZY — it doesn't run until you iterate (toList, forEach, etc.)
  // This means chaining .map().where() is efficient: no intermediate lists.
  print('');
}

// ============================================================
// 2. .where() — Keep only elements that pass a predicate
// ============================================================

/// Demonstrates [Iterable.where], which returns only elements for which
/// the predicate function returns [true].
///
/// Before/after counts show how many elements survive the filter.
void _demoWhereFilter() {
  print('--- 2. .where() Filter ---');

  final List<int> numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  // Keep only even numbers
  final List<int> evens = numbers.where((n) => n.isEven).toList();

  print('Original (${ numbers.length} items) : $numbers');
  print('Evens    (${ evens.length} items) : $evens');

  // Keep only numbers greater than 5
  final List<int> greaterThanFive = numbers.where((n) => n > 5).toList();
  print('> 5      (${ greaterThanFive.length} items) : $greaterThanFive');

  // Combine two conditions with &&
  final List<int> evenAndGtFive = numbers.where((n) => n.isEven && n > 5).toList();
  print('Even > 5 (${ evenAndGtFive.length} items) : $evenAndGtFive');

  print('');
}

// ============================================================
// 3. .fold() — Accumulate a single value with an explicit seed
// ============================================================

/// Demonstrates [Iterable.fold], which reduces a list to a single value by
/// applying an accumulator function starting from an explicit [initialValue].
///
/// Unlike [reduce], fold works on EMPTY lists because it always has an
/// initial value to return.
void _demoFoldAccumulate() {
  print('--- 3. .fold() Accumulate ---');

  final List<int> numbers = [1, 2, 3, 4, 5];

  // Sum all numbers — initial value 0
  final int sum = numbers.fold(0, (accumulator, element) => accumulator + element);
  print('Numbers : $numbers');
  print('Sum (fold, init=0) : $sum');

  // Product — initial value 1 (neutral element for multiplication)
  final int product = numbers.fold(1, (acc, el) => acc * el);
  print('Product (fold, init=1) : $product');

  // Max via fold — initial value is the first element's "worst case"
  final int maxValue = numbers.fold(
    numbers.first,
    (acc, el) => el > acc ? el : acc,
  );
  print('Max (fold) : $maxValue');

  // fold on an EMPTY list returns the initial value — no crash
  final int emptySum = <int>[].fold(0, (acc, el) => acc + el);
  print('Empty list fold (init=0) : $emptySum'); // → 0

  // Build a String from a list of words
  final List<String> words = ['Dart', 'is', 'awesome'];
  final String sentence = words.fold('', (acc, word) => acc.isEmpty ? word : '$acc $word');
  print('Sentence from list : $sentence');

  print('');
}

// ============================================================
// 4. .reduce() — Like fold but NO initial value (non-empty list only)
// ============================================================

/// Demonstrates [Iterable.reduce], which combines all elements using the
/// given function, starting from the FIRST element (no seed value).
///
/// Key difference from fold:
///   - reduce requires a NON-EMPTY list; it throws [StateError] on empty
///   - fold accepts an empty list (returns the initial value)
///
/// The [StateError] from reduce is caught and printed — the program continues.
void _demoReduceVsFold() {
  print('--- 4. .reduce() vs .fold() ---');

  final List<int> numbers = [10, 3, 7, 1, 9];

  // reduce: starts with numbers[0] = 10, then applies f(acc, el) for the rest
  final int maxViaReduce = numbers.reduce((acc, el) => el > acc ? el : acc);
  print('Numbers     : $numbers');
  print('Max (reduce): $maxViaReduce');

  final int sumViaReduce = numbers.reduce((acc, el) => acc + el);
  print('Sum (reduce): $sumViaReduce');

  // reduce on an empty list throws StateError — we MUST catch it
  // This is the main danger of reduce; prefer fold when the list might be empty.
  try {
    final int result = <int>[].reduce((acc, el) => acc + el);
    print('Empty reduce : $result'); // never reached
  } on StateError catch (e) {
    // StateError: "No element" — reduce has nothing to start from
    print('Empty list reduce → caught StateError: $e');
  }

  print('');
}

// ============================================================
// 5. Spread operator ... and null-aware spread ...?
// ============================================================

/// Demonstrates the spread operator [...]  and the null-aware variant [...?].
///
/// Spread inserts all elements of an iterable directly into a list literal.
/// This is syntactic sugar that avoids calling .addAll().
///
/// The null-aware spread [...?] does nothing if the list is null,
/// preventing a NullPointerException.
void _demoSpreadOperator() {
  print('--- 5. Spread Operator ---');

  final List<int> first = [1, 2, 3];
  final List<int> second = [4, 5, 6];
  final List<int> extras = [7, 8, 9];

  // Basic spread: combine two lists into a new list
  final List<int> combined = [...first, ...second];
  print('first    : $first');
  print('second   : $second');
  print('combined : $combined');

  // Spread with additional literal elements
  final List<int> withExtras = [0, ...first, ...second, ...extras, 10];
  print('withExtras (0 + first + second + extras + 10) : $withExtras');

  // Null-aware spread: ...? handles a nullable list gracefully
  // If the nullable list is null, ...? contributes zero elements.
  List<int>? maybeList; // null by default — declared as List<int>? intentionally
  final List<int> withNull = [100, ...?maybeList, 200];
  print('maybeList is null   : $maybeList');
  print('withNull (null spread) : $withNull'); // → [100, 200]

  // Now with a real value
  maybeList = [150, 175];
  final List<int> withValue = [100, ...?maybeList, 200];
  print('maybeList has value    : $maybeList');
  print('withValue (non-null)   : $withValue'); // → [100, 150, 175, 200]

  print('');
}

// ============================================================
// 6. Collection if and collection for
// ============================================================

/// Demonstrates [collection if] and [collection for] —
/// Dart's way to embed conditional logic and loops directly
/// inside list/set/map literals.
///
/// This keeps list-building concise without separate [add] calls.
void _demoCollectionIfFor() {
  print('--- 6. Collection if + Collection for ---');

  final bool includeBonus = true;
  final List<int> baseScores = [10, 20, 30];

  // Collection if: conditionally add elements to a literal
  // The element 100 is included only when includeBonus is true.
  final List<int> scores = [
    ...baseScores,
    if (includeBonus) 100, // included
    if (!includeBonus) -999, // NOT included (condition is false)
  ];
  print('includeBonus = $includeBonus');
  print('scores (collection if) : $scores');

  // Collection if with else
  final String label = 'PRO';
  final List<String> tags = [
    'user',
    if (label == 'PRO') 'premium' else 'basic',
  ];
  print('tags (collection if-else) : $tags');

  // Collection for: spread a transformed iterable into a literal
  // Equivalent to: list.addAll(range.map((n) => n * n))
  final List<int> squares = [
    for (int i = 1; i <= 5; i++) i * i,
  ];
  print('squares (collection for) : $squares'); // [1, 4, 9, 16, 25]

  // Combine collection if + collection for
  final List<int> evenSquares = [
    for (int i = 1; i <= 10; i++)
      if (i.isEven) i * i, // only include square if i is even
  ];
  print('even squares (combined)  : $evenSquares'); // [4, 16, 36, 64, 100]

  print('');
}

// ============================================================
// 7. Operation chaining: .where().map().toList()
// ============================================================

/// Demonstrates chaining multiple Iterable operations in a single expression.
///
/// Because [where] and [map] return lazy [Iterable]s, chaining them does
/// NOT create intermediate lists — the pipeline is evaluated once when
/// [toList()] (or any terminal operation) is called.
void _demoOperationChaining() {
  print('--- 7. Chained .where().map().toList() ---');

  final List<int> numbers = List.generate(20, (i) => i + 1); // [1..20]

  // One expression: filter evens → square them → collect as list
  final List<int> evenSquares = numbers
      .where((n) => n.isEven) // keep: 2,4,6,...,20
      .map((n) => n * n) // square each
      .toList(); // materialise

  print('Input  : $numbers');
  print('Even squares (where + map + toList) : $evenSquares');

  // More complex chain: filter → transform → filter again → collect
  final List<String> result = numbers
      .where((n) => n % 3 == 0) // multiples of 3: 3,6,9,...
      .map((n) => 'triple_$n') // format as string
      .where((s) => s.length > 8) // keep strings longer than 8 chars
      .toList();

  print('Multiples of 3 formatted (len > 8) : $result');

  print('');
}

// ============================================================
// 8. Imperative vs Functional — side-by-side comparison (LAST)
// ============================================================

/// Demonstrates that imperative (for-loop) and functional (.map/.where/.fold)
/// approaches can produce IDENTICAL output.
///
/// The same task — "take a list of integers, keep those > 5, multiply by 2,
/// and sum the result" — is solved both ways.
///
/// The functional style is more concise and composable; the imperative style
/// is more explicit and sometimes easier to debug step-by-step.
/// Neither is wrong — understanding both makes you a well-rounded developer.
void _demoImperativeVsFunctional() {
  print('--- 8. Imperative vs Functional (Side-by-Side) ---');

  final List<int> numbers = [1, 3, 6, 8, 2, 10, 4, 7];

  // Task: keep elements > 5, double them, then sum all
  // Expected: elements > 5 are [6, 8, 10, 7] → doubled [12, 16, 20, 14] → sum = 62

  // ── Imperative approach ──────────────────────────────────────────
  // Traditional for-loop + accumulator variables
  int imperativeSum = 0;
  final List<int> imperativeDoubled = [];
  for (final n in numbers) {
    if (n > 5) {
      final doubled = n * 2;
      imperativeDoubled.add(doubled);
      imperativeSum += doubled;
    }
  }

  // ── Functional approach ──────────────────────────────────────────
  // Single-expression pipeline — no mutable variables
  final List<int> functionalDoubled = numbers
      .where((n) => n > 5)
      .map((n) => n * 2)
      .toList();
  final int functionalSum = functionalDoubled.fold(0, (acc, n) => acc + n);

  // ── Print both results side-by-side ─────────────────────────────
  // Both lines must be identical — that's the proof of equivalence.
  print('Input numbers            : $numbers');
  print('');
  print('Imperative doubled list  : $imperativeDoubled');
  print('Functional doubled list  : $functionalDoubled');
  print('');

  // Verify equivalence before printing
  assert(
    imperativeDoubled.toString() == functionalDoubled.toString(),
    'Lists should be identical!',
  );

  print('Imperative sum  : $imperativeSum');
  print('Functional sum  : $functionalSum');
  print('');

  // The real payoff: functional scales better when you need to add more steps.
  // Adding "only keep sums under 20" imperatively requires editing the loop;
  // functionally you just chain another .where().
  print('Both produce identical output ✓');
  print('');
  print('Functional pipeline is easy to extend:');
  final List<int> extendedResult = numbers
      .where((n) => n > 5) // filter step 1
      .map((n) => n * 2) // transform
      .where((n) => n < 20) // filter step 2 (easy to add!)
      .toList();
  print('After adding .where(n < 20) : $extendedResult');
}
