// ============================================================
// TEST: Phase 1 — Mixins (Property-Based Test)
// ============================================================
// Feature: phase-1-dart-language, Property 13: Validates Requirements 9.4
//
// Property 13: Mixin MRO — rightmost mixin wins for same-named method
//
// For any class `C with MixinA, MixinB` where both define a method with
// the same name, calling `C.m()` must invoke `MixinB.m()` (the rightmost
// mixin in the `with` clause).
//
// WHY THIS IS A DETERMINISTIC TEST (NOT RANDOMIZED):
// ---------------------------------------------------
// MRO (Method Resolution Order) is a *compile-time* guarantee enforced by
// the Dart compiler, not a runtime property that varies with input. There is
// no random data to generate — the outcome is 100% determined by the class
// declaration at compile time.
//
// Running this as a "property-style" test means:
//   - We state the universal property as a comment (∀ class C with A, B: B wins)
//   - We verify the single concrete instance `MyService` which is the canonical
//     representative of that class of programs
//   - The test is framed in the `test` package group/expect idiom used by PBT
//     tests, keeping style consistent with the rest of the test suite
//
// See design.md §Property 13 for the formal property statement.
// ============================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:belajar_1/phase1/09_mixins/mixins_demo.dart'
    show LoggerA, LoggerB, MyService;

void main() {
  // ============================================================
  // Property 13 group
  // ============================================================
  group('Property 13: Mixin MRO — rightmost mixin wins', () {
    // ----------------------------------------------------------
    // Core property: LoggerB (rightmost) wins over LoggerA
    // ----------------------------------------------------------
    // Dart linearises the `with` clause right-to-left, placing the rightmost
    // mixin closest to the class in the resolution chain:
    //
    //   class MyService with LoggerA, LoggerB
    //   MRO: MyService → LoggerB → LoggerA → Object
    //
    // So `logPrefix()` resolves to LoggerB.logPrefix() → '[B]'
    test(
      'MyService().logPrefix() returns "[B]" — LoggerB wins over LoggerA',
      () {
        // Arrange: instantiate the service whose `with` clause has LoggerB last
        final service = MyService();

        // Act: call the method whose implementation exists in both mixins
        final prefix = service.logPrefix();

        // Assert: must equal LoggerB's value, not LoggerA's
        expect(prefix, equals('[B]'),
            reason: 'LoggerB is rightmost in `with LoggerA, LoggerB`, '
                'so its logPrefix() must shadow LoggerA\'s');
      },
    );

    // ----------------------------------------------------------
    // Negative check: result must NOT be the leftmost mixin's value
    // ----------------------------------------------------------
    // This makes the property explicit in both directions.
    test(
      'MyService().logPrefix() does NOT return "[A]" — LoggerA is shadowed',
      () {
        final service = MyService();
        final prefix = service.logPrefix();

        expect(prefix, isNot(equals('[A]')),
            reason: 'LoggerA is the leftmost mixin and is shadowed by LoggerB');
      },
    );

    // ----------------------------------------------------------
    // Type hierarchy: MyService IS-A LoggerA AND IS-A LoggerB
    // ----------------------------------------------------------
    // Even though LoggerA's method is shadowed, the type relationship
    // still holds — the MRO affects *dispatch*, not *type inclusion*.
    test(
      'MyService IS-A LoggerA and IS-A LoggerB (mixins add to type hierarchy)',
      () {
        final service = MyService();

        // Both mixin types are part of MyService's type hierarchy
        expect(service is LoggerA, isTrue,
            reason: 'Mixins add to the is-a hierarchy even when shadowed');
        expect(service is LoggerB, isTrue,
            reason: 'LoggerB is both the winning implementation and a type');
      },
    );

    // ----------------------------------------------------------
    // Repeated calls: deterministic (same result every time)
    // ----------------------------------------------------------
    // MRO is resolved at compile time — calling the method multiple times
    // must always produce the same result regardless of call order or count.
    test(
      'logPrefix() is deterministic across multiple calls — always "[B]"',
      () {
        final service = MyService();

        // Call 100 times to confirm there is no randomness or side-effect
        // that could change the dispatch outcome. This bridges the PBT
        // "many iterations" convention even though the input is fixed.
        for (var i = 0; i < 100; i++) {
          expect(
            service.logPrefix(),
            equals('[B]'),
            reason: 'MRO dispatch must be identical on every call (iteration $i)',
          );
        }
      },
    );
  });
}
