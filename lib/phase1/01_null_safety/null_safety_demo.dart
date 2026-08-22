// Feature: phase-1-dart-language, Requirement 1: Null Safety
//
// ignore_for_file: invalid_null_aware_operator, unnecessary_null_comparison
// ignore_for_file: unnecessary_non_null_assertion, dead_null_aware_expression
// ignore_for_file: no_leading_underscores_for_local_identifiers
// (Intentional: this demo deliberately shows ?. ?! ?? ??= on both nullable
//  and non-nullable receivers to illustrate the operator syntax itself,
//  even when the analyzer already knows the type at compile time.)
//
// ============================================================
// CONCEPT: Null Safety in Dart
// ============================================================
//
// Null safety is Dart's compile-time guarantee that a variable
// cannot hold null unless you explicitly declare it as nullable.
// This eliminates the infamous "Null check operator used on a null
// value" runtime crashes that plagued older Dart code.
//
// The distinction is simple:
//   String  name  → CANNOT be null (compiler enforces this)
//   String? name  → CAN be null (you must handle the null case)
//
// HOW TO RUN:
//   dart run lib/phase1/01_null_safety/null_safety_demo.dart
//
// PREREQUISITES:
//   - Phase 0 complete (variables, OOP, error handling)
//   - Dart SDK >= 2.12.0 (sound null safety)
//
// DART SDK REQUIREMENT: >= 2.12.0 (null safety is enabled by default
//   in all projects with Dart SDK >= 2.12.0 in pubspec.yaml)
// ============================================================

void main() {
  print('======================================');
  print('  Phase 1 — Topic 1: Null Safety');
  print('======================================\n');

  _demoNullableVsNonNullable();
  _demoSafeAccess();
  _demoNullAssertion();
  _demoDefaultValue();
  _demoAssignIfNull();
  _demoLateKeyword();

  print('\n✅ All null safety demos completed!');
}

// ─────────────────────────────────────────────
// SECTION 1: Nullable vs Non-Nullable Types
// Requirement 1.2
// ─────────────────────────────────────────────

/// Demonstrates the difference between nullable [String?] and
/// non-nullable [String] types. The Dart compiler enforces that
/// a non-nullable variable can never hold null.
void _demoNullableVsNonNullable() {
  print('--- Section 1: Nullable vs Non-Nullable ---');

  // Non-nullable: the compiler GUARANTEES this is never null.
  // Try assigning null here → compile error: "A value of type 'Null'
  // can't be assigned to a variable of type 'String'."
  String nonNullableName = 'Dart Developer';

  // Nullable: the `?` suffix tells Dart this CAN hold null.
  // This is an explicit opt-in — you must handle null yourself.
  String? nullableName;

  print('Non-nullable name: $nonNullableName');
  print('Nullable name (before assignment): $nullableName'); // prints: null

  nullableName = 'Faisal';
  print('Nullable name (after assignment): $nullableName');

  // The compiler prevents this assignment — uncomment to see the error:
  // nonNullableName = null; // ERROR: A value of type 'Null' can't be
  //                         // assigned to a variable of type 'String'.
  //
  // WHY? Because if we allowed null into a non-nullable variable, every
  // single use of that variable would need a null check. Null safety
  // moves this burden from runtime crashes to compile-time errors.

  print('');
}

// ─────────────────────────────────────────────
// SECTION 2: Safe Access Operator (?.)
// Requirement 1.3
// ─────────────────────────────────────────────

/// Demonstrates the `?.` (safe access / null-conditional) operator.
///
/// `object?.property` evaluates to null if [object] is null,
/// instead of throwing a NullPointerException-style error.
/// This is Dart's primary tool for safely navigating nullable chains.
void _demoSafeAccess() {
  print('--- Section 2: Safe Access Operator (?.) ---');

  String? city = 'Jakarta';

  // Safe access: returns the length of the string, or null if city is null.
  int? cityLength = city?.length;
  print('city: $city → city?.length = $cityLength'); // 7

  // Now set city to null and observe the difference.
  city = null;
  cityLength = city?.length;
  print('city: null → city?.length = $cityLength'); // null (no crash!)

  // Chained safe access — safe even through multiple levels.
  // If any segment is null, the entire expression short-circuits to null.
  List<String>? tags = ['flutter', 'dart', 'mobile'];
  String? firstTag = tags?.first;
  print('tags?.first = $firstTag'); // flutter

  tags = null;
  firstTag = tags?.first;
  print('tags (null)?.first = $firstTag'); // null — no error

  // Compare with direct access on a nullable — this does NOT compile:
  // int badLength = city.length; // ERROR: The property 'length' can't be
  //                              // unconditionally accessed because the
  //                              // receiver can be 'null'.

  print('');
}

// ─────────────────────────────────────────────
// SECTION 3: Null-Assertion Operator (!)
// Requirement 1.3, 1.7, 1.8
// ─────────────────────────────────────────────

/// Demonstrates the `!` (null-assertion / bang) operator.
///
/// `value!` tells the compiler: "I know this isn't null, trust me."
/// This bypasses the compile-time null check and moves the
/// responsibility to the developer. Use sparingly and only when
/// you have already verified the value is non-null.
///
/// ⚠️  WARNING: If the value IS null at runtime, Dart throws:
///     "Null check operator used on a null value"
///     This is an uncatchable error (it's a programming mistake, not
///     an expected exception). Only use `!` when you're CERTAIN.
void _demoNullAssertion() {
  print('--- Section 3: Null-Assertion Operator (!) ---');

  String? nullableInput = 'Hello, Dart!';

  // SAFE use of `!`: we checked the value is non-null just above.
  // The `!` unwraps String? → String so we can call non-nullable methods.
  if (nullableInput != null) {
    String definitelyNotNull = nullableInput!; // safe here — we checked
    print('Safe !-unwrap: $definitelyNotNull (length: ${definitelyNotNull.length})');
  }

  // Another safe pattern: assign only after a null guard.
  String? apiResponse = _simulateApiCall(success: true);
  if (apiResponse != null) {
    // `!` is redundant here because of flow analysis, but shows the concept.
    print('API response: ${apiResponse!.toUpperCase()}');
  }

  // DANGEROUS USE — shown as a comment to avoid crashing the demo:
  //
  // String? mightBeNull = null;
  // print(mightBeNull!.length); // 💥 RUNTIME CRASH:
  //                             //    "Null check operator used on a null value"
  //
  // This is NOT a catchable exception in the normal sense — it signals
  // a programming bug. The correct approach is to use `?.` or check for
  // null before using `!`.
  //
  // WHEN IS `!` SAFE?
  //   ✅ After an explicit `if (value != null)` check
  //   ✅ When a nullable field is set by the framework before use
  //      (e.g., Flutter's `BuildContext` in widget tests)
  //   ✅ When a database query guarantees a result exists
  //   ❌ Never use `!` without a prior null verification

  print('');
}

/// Simulates an API call that may return null on failure.
String? _simulateApiCall({required bool success}) {
  return success ? 'data from server' : null;
}

// ─────────────────────────────────────────────
// SECTION 4: Default Value Operator (??)
// Requirement 1.4
// ─────────────────────────────────────────────

/// Demonstrates the `??` (if-null / default value) operator.
///
/// `expr ?? defaultValue` evaluates to:
///   - [expr] if expr is non-null
///   - [defaultValue] if expr is null
///
/// This is the idiomatic way to provide fallback values in Dart.
void _demoDefaultValue() {
  print('--- Section 4: Default Value Operator (??) ---');

  String? userProvidedName;

  // When the left side is null, ?? returns the right side.
  String displayName = userProvidedName ?? 'Anonymous Guest';
  print('userProvidedName is null → displayName: "$displayName"'); // Anonymous Guest

  // When the left side is non-null, ?? returns it unchanged.
  userProvidedName = 'Faisal Bahri';
  displayName = userProvidedName ?? 'Anonymous Guest';
  print('userProvidedName is "$userProvidedName" → displayName: "$displayName"'); // Faisal Bahri

  // Chained ?? — tries each option left-to-right, returns first non-null.
  String? primary;
  String? secondary;
  String? tertiary = 'fallback value';
  String result = primary ?? secondary ?? tertiary ?? 'ultimate default';
  print('Chained ?? result: "$result"'); // fallback value

  // Common use case: parsing configuration with defaults.
  int? configuredPort;
  int serverPort = configuredPort ?? 8080;
  print('Server port (unconfigured ?? 8080): $serverPort'); // 8080

  print('');
}

// ─────────────────────────────────────────────
// SECTION 5: Assign-If-Null Operator (??=)
// Requirement 1.6
// ─────────────────────────────────────────────

/// Demonstrates the `??=` (assign-if-null / null-coalescing assignment)
/// operator.
///
/// `variable ??= value` assigns [value] to [variable] ONLY if
/// [variable] is currently null. If it already has a value,
/// it is left unchanged.
///
/// Equivalent to: `variable = variable ?? value`
/// but more concise and evaluates the right side only once.
void _demoAssignIfNull() {
  print('--- Section 5: Assign-If-Null Operator (??=) ---');

  String? cachedResult;

  // Before assignment: value is null.
  print('Before ??= → cachedResult: $cachedResult'); // null

  // ??= assigns because cachedResult is null.
  cachedResult ??= 'computed expensive value';
  print('After first ??= → cachedResult: "$cachedResult"'); // computed expensive value

  // ??= does NOT assign again because cachedResult is already non-null.
  cachedResult ??= 'this will be ignored';
  print('After second ??= → cachedResult: "$cachedResult"'); // still: computed expensive value

  // Practical example: lazy initialization pattern.
  int? _cachedCount;
  _cachedCount ??= _computeExpensiveCount();
  print('Lazy count (first call): $_cachedCount'); // 42

  _cachedCount ??= _computeExpensiveCount(); // _computeExpensiveCount not called again!
  print('Lazy count (second call, no recompute): $_cachedCount'); // still 42

  print('');
}

/// Simulates an expensive computation. In a real app, this might
/// involve parsing a file or making a network request.
int _computeExpensiveCount() {
  print('  [computing count...]'); // shows only on first call
  return 42;
}

// ─────────────────────────────────────────────
// SECTION 6: Late Keyword
// Requirement 1.5
// ─────────────────────────────────────────────

/// Demonstrates the `late` keyword for deferred initialization.
///
/// `late` tells the compiler: "This non-nullable variable will be
/// initialized before it is first accessed, I promise."
///
/// TWO USE CASES for `late`:
///   1. Deferred initialization — you know the value but can't
///      compute it at declaration time (e.g., depends on a method call).
///   2. Lazy initialization — with a `late` initializer expression
///      that is evaluated only when the variable is first accessed.
///
/// ⚠️  RISK: If you access a `late` variable before it's initialized,
///     Dart throws at RUNTIME:
///     "LateInitializationError: Field 'xxx' has not been initialized."
///     This is a programming bug — it means you broke your own promise.
void _demoLateKeyword() {
  print('--- Section 6: Late Keyword ---');

  // --- Use Case 1: Deferred initialization ---
  // The variable is declared late (non-nullable), initialized later.
  late String deferredGreeting;

  // We haven't touched deferredGreeting yet — that's okay with `late`.
  // Accessing it HERE would crash: LateInitializationError.

  // Initialize it before first access — fulfilling the promise.
  deferredGreeting = _buildGreeting('World');
  print('Deferred greeting: $deferredGreeting'); // Hello, World!

  // --- Use Case 2: Lazy initializer ---
  // The initializer expression runs ONLY when the variable is first read.
  // If it's never accessed, the initializer never runs (saves work).
  late String lazyMessage = _expensiveBuild();
  print('Lazy message: $lazyMessage'); // triggers _expensiveBuild() here
  print('Lazy message again: $lazyMessage'); // uses cached value, no rebuild

  // --- LateInitializationError demonstration ---
  // The following code WOULD crash at runtime if uncommented:
  //
  // late String notYetInitialized;
  // print(notYetInitialized); // 💥 RUNTIME:
  //                           //    LateInitializationError:
  //                           //    Local 'notYetInitialized' has not been initialized.
  //
  // The difference from a nullable String?:
  //   String? can be null (valid state)
  //   late String must be initialized before access (programming contract)
  //
  // Use `late` when:
  //   ✅ The value genuinely can't be set at declaration (e.g., class field
  //      set in initState() before use in build())
  //   ✅ Lazy initialization — expensive computation needed only sometimes
  //   ❌ DON'T use `late` just to avoid making a variable nullable — only
  //      use it when you truly guarantee initialization before first access

  print('');
}

/// Builds a greeting string — represents work done after declaration.
String _buildGreeting(String target) => 'Hello, $target!';

/// Simulates a moderately expensive build operation.
/// With `late`, this runs only when the variable is first accessed.
String _expensiveBuild() {
  print('  [building lazy message...]'); // called only once
  return 'I was built lazily — only when needed!';
}
