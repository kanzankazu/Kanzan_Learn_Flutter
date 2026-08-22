// ============================================================
// PHASE 1 — Mixins
// ============================================================
// ignore_for_file: unnecessary_type_check
// (Intentional: the mixin capability demo checks 'bird is Flyable' etc. to
//  show that mixed-in capabilities are visible via 'is'. The analyzer flags
//  these as always-true because the type is statically known — that's exactly
//  the point being illustrated.)
// Purpose: Demonstrates how to use Dart mixins to compose behavior
//          across unrelated class hierarchies without multiple inheritance.
//
// Run with:
//   dart run lib/phase1/09_mixins/mixins_demo.dart
//
// Prerequisites: Phase 0 complete (OOP: class, inheritance, interface)
// Dart SDK: >= 2.1.0 (mixin keyword introduced; `on` clause since 2.1)
//
// Feature: phase-1-dart-language, Requirement 9: Mixins
// ============================================================

// ============================================================
// MIXINS vs ABSTRACT CLASS vs INTERFACE — When to use what?
//
// Mixin         — A reusable "capability" bundle that can be applied to any
//                 class with `with`. Use when you want to share behaviour
//                 (methods/getters) across unrelated class hierarchies without
//                 forcing an IS-A relationship. Cannot be instantiated directly.
//                 In Dart, a `mixin` may optionally declare an `on` constraint
//                 to access members from a specific base class.
//
// Abstract class — Defines a partial or full contract that subclasses MUST
//                 fulfil. Use when you also need shared constructor logic or
//                 fields that all subclasses inherit. Establishes an IS-A bond.
//                 Cannot be instantiated; its concrete subclasses can.
//
// Interface     — In Dart, every class implicitly defines an interface.
//                 Use `implements` to commit to a public API contract without
//                 inheriting any implementation. The implementing class must
//                 provide its own body for every declared member.
//
// Rule of thumb:
//   - Shared STATE  → abstract class (or base class with `extend`)
//   - Shared BEHAVIOUR across unrelated types → mixin
//   - Public CONTRACT only → interface (`implements`)
// ============================================================

// ============================================================
// Mixin 1: Serializable
// Declares an abstract contract: any class that uses this mixin
// must provide a toJson() implementation.
// ============================================================

/// A mixin that marks a class as JSON-serializable.
///
/// Classes that apply this mixin must implement [toJson] to convert
/// their state to a `Map<String, dynamic>` suitable for JSON encoding.
mixin Serializable {
  /// Converts this object's state to a JSON-compatible map.
  ///
  /// Must be overridden by every concrete class that uses this mixin.
  Map<String, dynamic> toJson();
}

// ============================================================
// Mixin 2: Loggable
// Provides a ready-to-use log() method. Uses `runtimeType` so the
// output automatically shows the actual class name — no constructor
// arguments needed.
// ============================================================

/// A mixin that gives any class a simple console logging capability.
///
/// The log prefix is derived from [runtimeType], so each class that
/// applies this mixin automatically identifies itself in log messages.
///
/// Example output:
///   [Duck] Taking off from the water surface
mixin Loggable {
  /// Prints [message] to stdout, prefixed with the runtime class name.
  ///
  /// Format: `[ClassName] message`
  void log(String message) {
    // runtimeType resolves to the concrete class at runtime, not 'Loggable'.
    print('[$runtimeType] $message');
  }
}

// ============================================================
// Mixin 3: Flyable
// Capability: the mixed-in class can fly.
// ============================================================

/// A mixin that grants flying capability to any animal class.
mixin Flyable {
  /// Simulates this object taking flight.
  void fly() {
    // runtimeType shows which concrete class is flying.
    print('[$runtimeType] 🦅 Spreading wings and taking flight!');
  }
}

// ============================================================
// Mixin 4: Swimmable
// Capability: the mixed-in class can swim.
// ============================================================

/// A mixin that grants swimming capability to any animal class.
mixin Swimmable {
  /// Simulates this object swimming.
  void swim() {
    print('[$runtimeType] 🌊 Gliding through the water!');
  }
}

// ============================================================
// Base class: Animal
// Concrete subclasses extend Animal and compose capabilities with mixins.
// ============================================================

/// Abstract base class for all animals.
///
/// Holds the shared [name] field. Subclasses extend this and compose
/// capability mixins using `with`.
abstract class Animal {
  /// The name of this individual animal.
  String name;

  /// Creates an [Animal] with the given [name].
  Animal(this.name);

  @override
  String toString() => '$runtimeType("$name")';
}

// ============================================================
// Class: Bird
// Extends Animal. Gains Flyable + Loggable capabilities via mixins.
// A bird can fly and log, but cannot swim.
// ============================================================

/// A bird that can fly and log its actions.
///
/// Mixin composition: `Flyable` + `Loggable`
/// MRO (left to right): Animal → Flyable → Loggable
class Bird extends Animal with Flyable, Loggable {
  /// Creates a [Bird] with the given [name].
  Bird(super.name);

  /// Demonstrates the bird's daily behaviour using its mixed-in capabilities.
  void doActivities() {
    log('Starting morning activities...');
    fly();
    log('Landed safely in the treetop.');
  }
}

// ============================================================
// Class: Duck
// Extends Animal. Gains Flyable + Swimmable + Loggable — all three.
// A duck can do everything: fly, swim, and log its actions.
// ============================================================

/// A duck that can fly, swim, and log its actions.
///
/// Mixin composition: `Flyable` + `Swimmable` + `Loggable`
/// MRO (left to right): Animal → Flyable → Swimmable → Loggable
class Duck extends Animal with Flyable, Swimmable, Loggable {
  /// Creates a [Duck] with the given [name].
  Duck(super.name);

  /// Demonstrates the duck's varied daily activities.
  void doActivities() {
    log('Good morning! Ready to show off all my skills.');
    fly();
    swim();
    log('What a productive day!');
  }
}

// ============================================================
// MRO (Method Resolution Order) Demo
//
// When two mixins in the `with` clause define the same method name,
// the RIGHTMOST mixin wins. Dart resolves mixins right-to-left,
// so the last `with` entry takes highest precedence.
//
// In `class MyService with LoggerA, LoggerB`:
//   - LoggerA.logPrefix() returns '[A]'
//   - LoggerB.logPrefix() returns '[B]'
//   - MyService().logPrefix() → '[B]'  (LoggerB is rightmost → wins)
// ============================================================

/// Mixin A: provides a log prefix '[A]'.
mixin LoggerA {
  /// Returns the log prefix for this mixin.
  String logPrefix() => '[A]';
}

/// Mixin B: provides a log prefix '[B]'.
mixin LoggerB {
  /// Returns the log prefix for this mixin.
  String logPrefix() => '[B]';
}

/// Service class that applies both logger mixins.
///
/// Because `LoggerB` is listed AFTER `LoggerA` in the `with` clause,
/// LoggerB's [logPrefix] wins in the MRO.
class MyService with LoggerA, LoggerB {
  /// Demonstrates which mixin's method was actually selected by the MRO.
  void showPrefix() {
    final prefix = logPrefix(); // resolved at compile time by Dart's MRO
    print('  MyService.logPrefix() → "$prefix"');
    print('  LoggerB wins! (rightmost mixin in `with LoggerA, LoggerB`)');
  }
}

// ============================================================
// Constrained Mixin: ValidatableMixin on BaseForm
//
// The `on` clause restricts which classes can use this mixin.
// It also allows the mixin to access members declared in BaseForm
// without declaring them itself — the `on` clause acts as a contract
// that the base class will provide those members.
// ============================================================

/// A form base class that holds input fields.
///
/// Subclasses extend this to participate in form validation
/// via [ValidatableMixin].
abstract class BaseForm {
  /// The form's input fields: key = field name, value = user input.
  Map<String, String> fields = {};
}

/// A mixin that adds validation logic to [BaseForm] subclasses.
///
/// The `on BaseForm` constraint means:
///   1. Only classes that extend (or implement) [BaseForm] can use this mixin.
///   2. The mixin body can freely access `fields` from [BaseForm].
mixin ValidatableMixin on BaseForm {
  /// Returns a list of validation error messages for the current [fields].
  ///
  /// A field is considered invalid if its value is blank (empty or whitespace).
  List<String> validate() {
    final errors = <String>[];
    for (final entry in fields.entries) {
      // Access `fields` directly — guaranteed by the `on BaseForm` constraint.
      if (entry.value.trim().isEmpty) {
        errors.add('${entry.key} must not be blank');
      }
    }
    return errors;
  }

  /// Returns `true` if [validate] produces no errors.
  bool get isValid => validate().isEmpty;
}

/// A concrete login form that extends [BaseForm] and gains validation
/// behaviour via [ValidatableMixin].
class LoginForm extends BaseForm with ValidatableMixin {
  /// Creates a login form pre-populated with the given [username] and [password].
  LoginForm({required String username, required String password}) {
    // Populate fields — validate() will inspect these.
    fields['username'] = username;
    fields['password'] = password;
  }
}

// ============================================================
// Main entry point — runs all demo sections in order
// ============================================================

void main() {
  print('=== Mixins Demo ===\n');

  _demoAnimalMixins();
  _demoMROResolution();
  _demoConstrainedMixin();
}

// ============================================================
// Section 1: Bird & Duck — basic mixin composition
// ============================================================

void _demoAnimalMixins() {
  print('--- Section 1: Basic Mixin Composition (Bird & Duck) ---\n');

  final bird = Bird('Tweety');
  print('${bird} — capabilities: Flyable + Loggable');
  bird.doActivities();

  print('');

  final duck = Duck('Donald');
  print('${duck} — capabilities: Flyable + Swimmable + Loggable');
  duck.doActivities();

  print('');

  // Demonstrates that mixins add to the type hierarchy:
  // Bird IS-A Flyable and IS-A Loggable
  print('Type checks (mixins add to the is-a hierarchy):');
  print('  bird is Flyable   → ${bird is Flyable}');
  print('  bird is Swimmable → ${bird is Swimmable}'); // false — Bird has no Swimmable
  print('  duck is Flyable   → ${duck is Flyable}');
  print('  duck is Swimmable → ${duck is Swimmable}');
  print('  duck is Loggable  → ${duck is Loggable}');

  print('');
}

// ============================================================
// Section 2: MRO — rightmost mixin wins same-named method
// ============================================================

void _demoMROResolution() {
  print('--- Section 2: Method Resolution Order (MRO) ---\n');
  print('  class MyService with LoggerA, LoggerB');
  print('  Both LoggerA and LoggerB define logPrefix().');
  print('  Which one does MyService use?\n');

  final service = MyService();
  service.showPrefix(); // Prints the actual resolved prefix — proves [B] wins

  print('');
  print('  Explanation:');
  print('  Dart linearises mixins right-to-left in the `with` list.');
  print('  LoggerB (rightmost) is placed closer to the class in the MRO');
  print('  chain, so its logPrefix() shadows LoggerA\'s definition.');
  print('  Think of it as: MyService → LoggerB → LoggerA → Object');

  print('');
}

// ============================================================
// Section 3: Constrained mixin (on BaseForm)
// ============================================================

void _demoConstrainedMixin() {
  print('--- Section 3: Constrained Mixin (ValidatableMixin on BaseForm) ---\n');

  // Valid form: all fields have non-blank values
  final validForm = LoginForm(username: 'alice', password: 'secr3t');
  print('  LoginForm(username: "alice", password: "secr3t")');
  print('  isValid → ${validForm.isValid}');
  print('  errors  → ${validForm.validate()}');

  print('');

  // Invalid form: password is blank
  final invalidForm = LoginForm(username: 'bob', password: '   ');
  print('  LoginForm(username: "bob", password: "   ")  ← blank password');
  print('  isValid → ${invalidForm.isValid}');
  print('  errors  → ${invalidForm.validate()}');

  print('');

  // Invalid form: both fields blank
  final emptyForm = LoginForm(username: '', password: '');
  print('  LoginForm(username: "", password: "")  ← both blank');
  print('  isValid → ${emptyForm.isValid}');
  print('  errors  → ${emptyForm.validate()}');

  print('');

  // Key point: the `on BaseForm` constraint means the mixin can safely
  // access `fields` without it being declared on the mixin itself.
  print('  Key point: ValidatableMixin accesses `fields` from BaseForm');
  print('  via the `on BaseForm` constraint — no need to redeclare it.');

  print('');

  // ----------------------------------------------------------------
  // NOTE: The following would be a compile error — you CANNOT apply
  // ValidatableMixin to a class that does not extend BaseForm:
  //
  //   class RandomClass with ValidatableMixin {} // ❌ compile error
  //
  // The `on` clause is enforced at compile time, not runtime.
  // ----------------------------------------------------------------
}
