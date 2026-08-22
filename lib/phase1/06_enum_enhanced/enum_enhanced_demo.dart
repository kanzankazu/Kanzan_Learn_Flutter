// Feature: phase-1-dart-language, Requirement 6: Enum Enhanced
//
// Demonstrates the full spectrum of Dart enums — from the classic
// Dart 2 style all the way to Dart 3 enhanced enums with fields,
// interfaces, pattern matching, and state-machine behaviour.
//
// Run:
//   dart run lib/phase1/06_enum_enhanced/enum_enhanced_demo.dart
//
// Prerequisites: Phase 0 complete, Dart SDK >= 3.0
//
// Topics covered:
//   6.1 Simple enum (Dart 2 style)
//   6.2 Enum with fields and const constructor (Dart 3)
//   6.3 Enum implementing an interface
//   6.4 Exhaustive switch expression (no default)
//   6.5 Enum.values iteration
//   6.6 State-machine enum with transition logic
//   6.7 .name property
//   6.8 Enum in collections / used as map key

// ---------------------------------------------------------------------------
// 6.3 — Abstract interface for enums that can describe themselves.
//
// Using `abstract interface class` (Dart 3) is the idiomatic way to
// express a structural contract that enums (or any class) can fulfil.
// ---------------------------------------------------------------------------

/// A structural contract: implementors must provide a human-readable
/// description of themselves.
abstract interface class Describable {
  String get description;
}

// ---------------------------------------------------------------------------
// 6.1 — Dart 2-style simple enum
//
// No fields, no constructor — just a named set of constants.
// The compiler assigns an `index` (0-based) and a `.name` String to each value.
// ---------------------------------------------------------------------------

/// The four cardinal compass directions.
///
/// Classic Dart 2 enum: lightweight, zero overhead.
enum Direction { north, south, east, west }

// ---------------------------------------------------------------------------
// 6.2 — Dart 3 enhanced enum with fields and const constructor
//
// Source / inspiration:
//   https://dart.dev/language/enums#declaring-enhanced-enums
//   (The Planet example is taken from the official Dart language tour —
//    credit: dart.dev documentation team, used for educational purposes.)
//
// Rules for enhanced enums:
//   • Fields must be `final`.
//   • The constructor must be `const`.
//   • Instance variables cannot be initialised in the constructor body;
//     use initializer lists instead.
// ---------------------------------------------------------------------------

/// Represents a planet in the solar system with physical properties.
///
/// Demonstrates enhanced enum with `final` fields, a `const` constructor,
/// and a computed method — all part of the enum declaration.
enum Planet {
  mercury(mass: 3.303e+23, radius: 2.4397e6),
  venus(mass: 4.869e+24, radius: 6.0518e6),
  earth(mass: 5.976e+24, radius: 6.37814e6),
  mars(mass: 6.421e+23, radius: 3.3972e6),
  jupiter(mass: 1.9e+27, radius: 7.1492e7),
  saturn(mass: 5.688e+26, radius: 6.0268e7),
  uranus(mass: 8.686e+25, radius: 2.5559e7),
  neptune(mass: 1.024e+26, radius: 2.4746e7);

  // ---------------------------------------------------------------------------
  // Each planet carries two physical constants.
  // These must be `final` in an enhanced enum.
  // ---------------------------------------------------------------------------

  /// Mass of the planet in kilograms.
  final double mass;

  /// Mean radius of the planet in metres.
  final double radius;

  /// Universal gravitational constant (m³ kg⁻¹ s⁻²).
  static const double _g = 6.67430e-11;

  // Enhanced enum constructor — MUST be `const`.
  const Planet({required this.mass, required this.radius});

  /// Surface gravitational acceleration in m/s².
  double get surfaceGravity => _g * mass / (radius * radius);

  /// Weight (in Newtons) of an object with [bodyWeight] kg on this planet.
  double surfaceWeight(double bodyWeight) => bodyWeight * surfaceGravity;
}

// ---------------------------------------------------------------------------
// 6.3 — Enum implementing an interface
//
// An enhanced enum can `implement` any number of interfaces.
// The enum values themselves satisfy the contract.
// ---------------------------------------------------------------------------

/// Common HTTP status codes with human-readable descriptions.
///
/// Implements [Describable] so any code that accepts a `Describable`
/// can also accept an `HttpStatus` — demonstrating polymorphism via enum.
enum HttpStatus implements Describable {
  ok(200),
  created(201),
  badRequest(400),
  unauthorized(401),
  notFound(404),
  internalServerError(500);

  /// The numeric HTTP status code.
  final int code;

  const HttpStatus(this.code);

  /// Returns a human-readable description for this status.
  ///
  /// This satisfies the [Describable] interface contract.
  @override
  String get description => switch (this) {
        HttpStatus.ok => '200 OK — Request succeeded',
        HttpStatus.created => '201 Created — Resource was created',
        HttpStatus.badRequest => '400 Bad Request — Malformed request syntax',
        HttpStatus.unauthorized => '401 Unauthorized — Authentication required',
        HttpStatus.notFound => '404 Not Found — Resource does not exist',
        HttpStatus.internalServerError =>
          '500 Internal Server Error — Server-side failure',
        // NOTE: No `default` clause here.
        // If you add a new HttpStatus value and forget to add a case above,
        // the Dart compiler will produce a compile-time error:
        //   "The switch expression is missing a case for <newValue>."
        // This exhaustiveness check is one of the biggest advantages of
        // sealed types and enhanced enums over plain strings or ints.
      };
}

// ---------------------------------------------------------------------------
// 6.6 — State-machine enum
//
// Enums are a natural fit for finite-state machines because:
//   • The set of states is closed (compiler-enforced).
//   • Methods can encode the allowed transitions.
//   • Exhaustive switch prevents forgotten states.
// ---------------------------------------------------------------------------

/// Lifecycle states for a customer order.
enum OrderState {
  pending,
  processing,
  shipped,
  delivered,
  cancelled;

  /// Returns `true` if transitioning from this state to [next] is allowed.
  ///
  /// Valid transitions form a directed acyclic graph:
  ///   pending → processing → shipped → delivered
  ///   pending → cancelled
  ///   processing → cancelled
  ///   (shipped, delivered, cancelled) are terminal — no further transitions
  bool canTransitionTo(OrderState next) => switch (this) {
        OrderState.pending => next == OrderState.processing ||
            next == OrderState.cancelled,
        OrderState.processing => next == OrderState.shipped ||
            next == OrderState.cancelled,
        OrderState.shipped => next == OrderState.delivered,
        // Terminal states: once delivered or cancelled, no further moves.
        OrderState.delivered => false,
        OrderState.cancelled => false,
      };
}

// ---------------------------------------------------------------------------
// Demo helpers
// ---------------------------------------------------------------------------

void _demoSimpleEnum() {
  print('--- 6.1  Simple Enum (Direction) ---');

  // Accessing enum values by name
  final heading = Direction.north;
  print('Heading: ${heading.name}');

  // .index gives the 0-based declaration order
  print('Index of east: ${Direction.east.index}');

  // switch — note: using the old statement style here to contrast with the
  // switch *expression* style shown later.
  final label = switch (heading) {
    Direction.north => 'Going north ↑',
    Direction.south => 'Going south ↓',
    Direction.east => 'Going east →',
    Direction.west => 'Going west ←',
    // No default needed — all four Direction values are covered.
  };
  print(label);
  print('');
}

void _demoEnhancedEnum() {
  print('--- 6.2  Enhanced Enum with Fields (Planet) ---');

  // A person weighing 75 kg on Earth
  const earthWeight = 75.0;

  // .values gives every declared enum value in declaration order (6.5)
  for (final planet in Planet.values) {
    final weight = planet.surfaceWeight(earthWeight);
    print(
      '${planet.name.padRight(8)}  '
      'gravity: ${planet.surfaceGravity.toStringAsFixed(2).padLeft(6)} m/s²  '
      'weight of 75kg person: ${weight.toStringAsFixed(1).padLeft(8)} N',
    );
  }
  print('');
}

void _demoEnumInterface() {
  print('--- 6.3  Enum Implementing Interface (HttpStatus) ---');

  // HttpStatus satisfies Describable — can be passed to any function
  // that expects a Describable.
  void printDescription(Describable item) {
    print('  ${item.description}');
  }

  for (final status in HttpStatus.values) {
    printDescription(status); // polymorphic call via interface
  }
  print('');
}

void _demoExhaustiveSwitch() {
  print('--- 6.4  Exhaustive switch expression (no default) ---');

  // The switch expression is exhaustive: every Direction case is handled.
  // TRY IT: Remove one case (e.g., Direction.west) and the compiler will
  // immediately report an error — no runtime surprises.
  for (final dir in Direction.values) {
    final emoji = switch (dir) {
      Direction.north => '⬆️',
      Direction.south => '⬇️',
      Direction.east => '➡️',
      Direction.west => '⬅️',
    };
    print('  ${dir.name}: $emoji');
  }
  print('');
}

void _demoValuesIteration() {
  print('--- 6.5  Enum.values iteration (.name + property) ---');

  print('All planets with surface gravity:');
  for (final p in Planet.values) {
    // .name is available on every enum value (Dart 2.15+)
    print(
      '  ${p.name.padRight(8)}: ${p.surfaceGravity.toStringAsFixed(2)} m/s²',
    );
  }
  print('');
}

void _demoStateMachine() {
  print('--- 6.6  State-Machine Enum (OrderState) ---');

  // Helper: attempt a transition and print the outcome
  void tryTransition(OrderState from, OrderState to) {
    final allowed = from.canTransitionTo(to);
    final symbol = allowed ? '✅ ALLOWED' : '❌ DENIED ';
    print('  $symbol  ${from.name} → ${to.name}');
  }

  print('Valid transitions:');
  tryTransition(OrderState.pending, OrderState.processing);
  tryTransition(OrderState.processing, OrderState.shipped);
  tryTransition(OrderState.shipped, OrderState.delivered);
  tryTransition(OrderState.pending, OrderState.cancelled);

  print('\nInvalid transitions:');
  tryTransition(OrderState.shipped, OrderState.pending);    // going backward
  tryTransition(OrderState.delivered, OrderState.shipped);  // terminal state
  tryTransition(OrderState.cancelled, OrderState.processing); // terminal state
  tryTransition(OrderState.processing, OrderState.delivered); // skipped step

  print('');
}

void _demoEnumAsMapKey() {
  print('--- 6.8  Enum as Map key ---');

  // Enums are const-comparable and work perfectly as map keys.
  // This is a common pattern for config tables and lookup maps.
  final httpMessages = {
    HttpStatus.ok: 'All good!',
    HttpStatus.notFound: 'Check your URL.',
    HttpStatus.internalServerError: 'Server needs attention.',
  };

  for (final entry in httpMessages.entries) {
    print('  [${entry.key.code}] ${entry.value}');
  }
  print('');
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

void main() {
  print('═' * 55);
  print(' Phase 1 — Topic 6: Enum Enhanced');
  print('═' * 55);
  print('');

  _demoSimpleEnum();
  _demoEnhancedEnum();
  _demoEnumInterface();
  _demoExhaustiveSwitch();
  _demoValuesIteration();
  _demoStateMachine();
  _demoEnumAsMapKey();

  print('═' * 55);
  print(' Done. All enum demos completed successfully.');
  print('═' * 55);
}
