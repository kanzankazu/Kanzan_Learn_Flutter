// ============================================================
// PHASE 1 — Extension Methods
// ============================================================
// Purpose: Demonstrates how to add new methods and getters to existing
//          types without modifying or subclassing them, using Dart's
//          `extension` keyword.
//
// Run with:
//   dart run lib/phase1/05_extensions/extensions_demo.dart
//
// Prerequisites: Phase 0 complete (especially OOP + Collections)
// Dart SDK: >= 2.7.0 (extension methods introduced in 2.7)
//
// Feature: phase-1-dart-language, Requirement 5: Extension Methods
// ============================================================

// NOTE: In a real project, each extension would live in its own file,
// e.g., `lib/extensions/string_utils.dart`, then imported where needed.
// Here they are defined in the same file to keep the demo self-contained.

// ============================================================
// EXTENSIONS: When to use what?
//
// Extension method   — Add behavior to an EXISTING type you don't own
//                      (String, int, List, or a third-party class).
//                      Use this when you just need extra utility methods.
//
// Subclass           — Create a new type that IS-A variation of the parent.
//                      Use this when you need to change/override existing
//                      behavior or add persistent state.
//
// Wrapper / Delegate — Wrap an existing type in a new class (has-a).
//                      Use this when you need full control over the API,
//                      or when the type is final/sealed and can't be extended.
// ============================================================

import 'dart:math' show Random;

// ============================================================
// Extension 1: StringUtils
// Adds utility getters to the built-in [String] type.
// ============================================================

extension StringUtils on String {
  /// Returns this string with the first character converted to upper case.
  ///
  /// Returns the string unchanged if it is empty.
  ///
  /// Example:
  /// ```dart
  /// 'hello'.capitalize  // → 'Hello'
  /// 'dart'.capitalize   // → 'Dart'
  /// ''.capitalize       // → ''
  /// ```
  String get capitalize {
    if (isEmpty) return this;
    // Take the first character, uppercase it, then append the rest.
    return this[0].toUpperCase() + substring(1);
  }

  /// Returns `true` if this string reads the same forwards and backwards,
  /// ignoring case differences.
  ///
  /// Example:
  /// ```dart
  /// 'racecar'.isPalindrome  // → true
  /// 'hello'.isPalindrome    // → false
  /// 'A'.isPalindrome        // → true  (single char)
  /// ''.isPalindrome         // → true  (empty string is trivially palindrome)
  /// ```
  bool get isPalindrome {
    final lower = toLowerCase();
    // Compare the string with its reverse.
    return lower == lower.split('').reversed.join();
  }
}

// ============================================================
// Extension 2: IntUtils
// Adds utility getters and methods to the built-in [int] type.
// ============================================================

extension IntUtils on int {
  /// Returns `true` if this integer is even.
  ///
  /// This delegates to `this % 2 == 0` but demonstrates that you can add
  /// semantic getters to primitives via extensions.
  ///
  /// Example:
  /// ```dart
  /// 4.isEven  // → true
  /// 7.isEven  // → false
  /// ```
  bool get isEven => this % 2 == 0;

  /// Converts this integer to its Roman numeral string representation.
  ///
  /// Bounded to the range 1–3999 (standard Roman numeral system).
  /// Values outside this range return an empty string — Roman numerals
  /// have no representation for zero, negative numbers, or values ≥ 4000.
  ///
  /// Example:
  /// ```dart
  /// 1.toRomanNumeral()     // → 'I'
  /// 4.toRomanNumeral()     // → 'IV'
  /// 9.toRomanNumeral()     // → 'IX'
  /// 2024.toRomanNumeral()  // → 'MMXXIV'
  /// 3999.toRomanNumeral()  // → 'MMMCMXCIX'
  /// 0.toRomanNumeral()     // → ''  (out of range)
  /// 4000.toRomanNumeral()  // → ''  (out of range)
  /// ```
  String toRomanNumeral() {
    // Out-of-range: Roman numerals are only defined for 1–3999.
    if (this < 1 || this > 3999) return '';

    // Mapping table: value → symbol pairs, ordered from largest to smallest.
    // Subtractive notation (IV, IX, XL, XC, CD, CM) is included explicitly.
    const values = [
      1000, 900, 500, 400,
      100, 90, 50, 40,
      10, 9, 5, 4, 1,
    ];
    const symbols = [
      'M', 'CM', 'D', 'CD',
      'C', 'XC', 'L', 'XL',
      'X', 'IX', 'V', 'IV', 'I',
    ];

    var remaining = this;
    final buffer = StringBuffer();

    for (var i = 0; i < values.length; i++) {
      // Append the symbol as many times as it fits into `remaining`.
      while (remaining >= values[i]) {
        buffer.write(symbols[i]);
        remaining -= values[i];
      }
    }

    return buffer.toString();
  }
}

// ============================================================
// Extension 3: ListUtils<T>
// Generic extension — adds utility getters and methods to List<T>.
// Using <T> shows that extensions can be generic over the element type.
// ============================================================

extension ListUtils<T> on List<T> {
  /// Returns the second element of this list, or `null` if the list has
  /// fewer than 2 elements.
  ///
  /// This is safer than `list[1]`, which throws a [RangeError] on short lists.
  ///
  /// Example:
  /// ```dart
  /// [10, 20, 30].second  // → 20
  /// [10].second          // → null
  /// <int>[].second       // → null
  /// ```
  T? get second => length >= 2 ? this[1] : null;

  /// Returns a new list with the same elements in a randomized order.
  ///
  /// This is a NON-MUTATING operation — the original list is not modified.
  /// Contrast with [List.shuffle], which mutates in place.
  ///
  /// Example:
  /// ```dart
  /// final original = [1, 2, 3, 4, 5];
  /// final shuffled = original.shuffled();
  /// print(original);  // still [1, 2, 3, 4, 5]
  /// print(shuffled);  // e.g. [3, 1, 5, 2, 4]
  /// ```
  List<T> shuffled() {
    // Copy the list first so we never mutate the original.
    final copy = List<T>.from(this);
    copy.shuffle(Random());
    return copy;
  }
}

// ============================================================
// Main entry point
// ============================================================

void main() {
  print('=== Extension Methods Demo ===\n');

  _demoStringUtils();
  _demoIntUtils();
  _demoListUtils();
  _demoChainedExtensions();
}

// ============================================================
// Section 1: StringUtils demonstration
// ============================================================

void _demoStringUtils() {
  print('--- StringUtils on String ---\n');

  // capitalize: using dot notation on a String literal
  print('capitalize:');
  print('  "hello".capitalize   → ${'hello'.capitalize}');
  print('  "dart".capitalize    → ${'dart'.capitalize}');
  print('  "WORLD".capitalize   → ${'WORLD'.capitalize}');
  // Empty string: returns empty unchanged
  print('  "".capitalize        → "${''.capitalize}" (empty stays empty)');

  print('');

  // isPalindrome: true when string reads same backwards
  print('isPalindrome:');
  print('  "racecar".isPalindrome  → ${'racecar'.isPalindrome}');
  print('  "level".isPalindrome    → ${'level'.isPalindrome}');
  print('  "Madam".isPalindrome    → ${'Madam'.isPalindrome} (case-insensitive)');
  print('  "hello".isPalindrome    → ${'hello'.isPalindrome}');
  print('  "a".isPalindrome        → ${'a'.isPalindrome} (single char)');
  print('  "".isPalindrome         → ${''.isPalindrome} (empty is trivially true)');

  print('');
}

// ============================================================
// Section 2: IntUtils demonstration
// ============================================================

void _demoIntUtils() {
  print('--- IntUtils on int ---\n');

  // isEven: calling a getter via dot notation on an int variable
  print('isEven:');
  final numbers = [0, 1, 4, 7, 100, -3];
  for (final n in numbers) {
    print('  $n.isEven  → ${n.isEven}');
  }

  print('');

  // toRomanNumeral: method call via dot notation
  print('toRomanNumeral():');
  final samples = [1, 4, 9, 14, 40, 90, 399, 1000, 2024, 3999];
  for (final n in samples) {
    print('  ${n.toRomanNumeral().padLeft(10)}  ←  $n');
  }

  // Out-of-range behavior — no crash, just empty string
  print('');
  print('  Out-of-range cases (returns empty string ""):');
  print('  0.toRomanNumeral()    → "${0.toRomanNumeral()}"');
  print('  4000.toRomanNumeral() → "${4000.toRomanNumeral()}"');
  print('  (-5).toRomanNumeral() → "${(-5).toRomanNumeral()}"');

  print('');
}

// ============================================================
// Section 3: ListUtils<T> demonstration
// ============================================================

void _demoListUtils() {
  print('--- ListUtils<T> on List<T> ---\n');

  // second: safe access to index 1
  print('second getter:');
  final fruits = ['apple', 'banana', 'cherry'];
  print('  $fruits.second        → ${fruits.second}');

  final single = ['only'];
  print('  $single.second  → ${single.second} (fewer than 2 elements → null)');

  final empty = <int>[];
  print('  [].second             → ${empty.second} (empty list → null)');

  print('');

  // shuffled: non-mutating shuffle returns a new list
  print('shuffled():');
  final original = [1, 2, 3, 4, 5];
  final result = original.shuffled();
  // Original is unchanged — this is the key difference from List.shuffle()
  print('  original : $original');
  print('  shuffled : $result');
  print('  (original unchanged: ${original.toString() == '[1, 2, 3, 4, 5]'})');

  // Works with any type T — generic extension in action
  print('');
  print('  Generic extension works on any element type:');
  final words = ['dart', 'flutter', 'kotlin', 'swift', 'python'];
  print('  original strings: $words');
  print('  shuffled strings: ${words.shuffled()}');

  print('');
}

// ============================================================
// Section 4: Chained extensions — combining multiple extensions
// ============================================================

void _demoChainedExtensions() {
  print('--- Chaining Extensions ---\n');
  print('Extensions compose naturally via dot notation:\n');

  // Chain StringUtils + ListUtils together
  final rawNames = ['alice', 'bob', 'carol', 'dave', 'eve'];
  print('  Input:    $rawNames');

  // .map() + capitalize (StringUtils) + toList() + shuffled() (ListUtils)
  final capitalizedShuffled = rawNames
      .map((name) => name.capitalize) // StringUtils.capitalize on each element
      .toList()
      .shuffled(); // ListUtils.shuffled on the resulting List<String>
  print('  Capitalize then shuffle: $capitalizedShuffled');

  // second getter after transformation
  print('  Second item after transform: ${capitalizedShuffled.second}');

  print('');

  // Chaining int extension with a loop
  print('  Even numbers from 1..10 as Roman numerals:');
  final romanEvens = List.generate(10, (i) => i + 1)
      .where((n) => n.isEven) // IntUtils.isEven
      .map((n) => '${n.toRomanNumeral().padLeft(4)} ($n)') // IntUtils.toRomanNumeral
      .toList();
  for (final r in romanEvens) {
    print('    $r');
  }

  print('');
  print('All extension calls above use dot notation — no wrapper class needed.');
}
