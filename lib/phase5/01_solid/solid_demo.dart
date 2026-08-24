/// Demo 01 — SOLID Principles.
///
/// SOLID is an acronym for five design principles that make code easier to
/// understand, maintain, and extend. They were introduced by Robert C. Martin
/// (Uncle Bob) and are considered fundamental to good object-oriented design.
///
/// **The five principles:**
/// 1. **S**ingle Responsibility Principle (SRP)
///    — A class should have only one reason to change.
/// 2. **O**pen/Closed Principle (OCP)
///    — Open for extension, closed for modification.
/// 3. **L**iskov Substitution Principle (LSP)
///    — Subtypes must be substitutable for their base types.
/// 4. **I**nterface Segregation Principle (ISP)
///    — No client should depend on methods it doesn't use.
/// 5. **D**ependency Inversion Principle (DIP)
///    — Depend on abstractions, not concretions.
///
/// **Why SOLID matters for Flutter:**
/// Flutter apps grow fast. Without these principles, adding a feature means
/// touching 10 files and breaking 3 things. With them, changes are isolated
/// and safe.
///
/// How to run: `flutter run -t lib/phase5/01_solid/solid_demo.dart`
library;

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// S — Single Responsibility Principle
// ─────────────────────────────────────────────────────────────────────────────

// ── BAD: one class doing too many things ──────────────────────────────────────

/// ❌ VIOLATES SRP — this class does three unrelated things:
/// 1. Validates user input
/// 2. Formats a price for display
/// 3. Calculates tax
///
/// If tax rules change, you modify this class.
/// If display format changes (currency symbol), you modify this class.
/// If validation rules change, you modify this class.
/// Three different reasons to change = three responsibilities = SRP violated.
class UserManager_Bad {
  bool validateEmail(String email) => email.contains('@');
  String formatPrice(double price) => 'Rp ${price.toStringAsFixed(0)}';
  double calculateTax(double price) => price * 0.11; // 11% VAT
}

// ── GOOD: each class has exactly one responsibility ───────────────────────────

/// ✅ SRP — only validates user input.
/// Reason to change: validation rules change.
class EmailValidator {
  /// Returns true if the email has a valid format.
  bool isValid(String email) => email.contains('@') && email.contains('.');
}

/// ✅ SRP — only formats prices for display.
/// Reason to change: display format requirements change (different currency, locale).
class PriceFormatter {
  /// Formats a double price as a localized currency string.
  String format(double price) => 'Rp ${price.toStringAsFixed(0)}';
}

/// ✅ SRP — only calculates tax.
/// Reason to change: government changes the tax rate.
class TaxCalculator {
  static const _vatRate = 0.11; // 11% VAT in Indonesia

  /// Returns the tax amount for a given price.
  double calculate(double price) => price * _vatRate;

  /// Returns the total price including tax.
  double withTax(double price) => price + calculate(price);
}

// ─────────────────────────────────────────────────────────────────────────────
// O — Open/Closed Principle
// ─────────────────────────────────────────────────────────────────────────────

// ── BAD: must modify existing code to add a new shape ────────────────────────

/// ❌ VIOLATES OCP — adding a new shape requires editing this class.
/// Every time you add Circle or Hexagon, you add another if/else here.
/// This class is never "closed" for modification.
class AreaCalculator_Bad {
  double calculate(Object shape) {
    if (shape is Rectangle_Bad) return shape.width * shape.height;
    if (shape is Circle_Bad) return 3.14 * shape.radius * shape.radius;
    // Add triangle → edit this class. Add hexagon → edit this class. Always touching old code.
    throw UnsupportedError('Unknown shape');
  }
}

class Rectangle_Bad {
  final double width, height;
  Rectangle_Bad(this.width, this.height);
}

class Circle_Bad {
  final double radius;
  Circle_Bad(this.radius);
}

// ── GOOD: extend behavior by adding new classes, not modifying old ones ───────

/// ✅ OCP — defines a contract that all shapes must fulfill.
/// The [AreaCalculator] only depends on this abstraction.
abstract class Shape {
  /// Returns the area of this shape.
  double area();

  /// Human-readable name for display.
  String get name;
}

/// ✅ OCP — new shape added without modifying [AreaCalculator].
class Rectangle extends Shape {
  final double width;
  final double height;
  Rectangle(this.width, this.height);

  @override
  double area() => width * height;

  @override
  String get name => 'Rectangle ${width}×${height}';
}

/// ✅ OCP — another new shape, still no changes to [AreaCalculator].
class Circle extends Shape {
  final double radius;
  Circle(this.radius);

  @override
  double area() => 3.14159 * radius * radius;

  @override
  String get name => 'Circle r=${radius}';
}

/// ✅ OCP — and another. AreaCalculator never needs to change.
class Triangle extends Shape {
  final double base;
  final double height;
  Triangle(this.base, this.height);

  @override
  double area() => 0.5 * base * height;

  @override
  String get name => 'Triangle b=${base} h=${height}';
}

/// ✅ OCP — closed for modification (never changes), open for extension
/// (works with any [Shape] we add in the future).
class AreaCalculator {
  /// Calculates area for any [Shape] implementation.
  /// Works with Rectangle, Circle, Triangle — and any future shape.
  double calculate(Shape shape) => shape.area();

  /// Calculates total area of a list of mixed shapes.
  double totalArea(List<Shape> shapes) =>
      shapes.fold(0, (sum, s) => sum + s.area());
}

// ─────────────────────────────────────────────────────────────────────────────
// L — Liskov Substitution Principle
// ─────────────────────────────────────────────────────────────────────────────

// ── BAD: subclass breaks the contract of its parent ──────────────────────────

/// A bird that can fly — establishes the contract.
class Bird {
  /// All birds can fly... right? (Spoiler: they can't.)
  void fly() => debugPrint('Flying');
}

/// ❌ VIOLATES LSP — Penguin IS-A Bird, but calling fly() throws.
/// Any code that uses Bird and assumes fly() works will break when given a Penguin.
/// This is the classic LSP violation.
class Penguin extends Bird {
  @override
  void fly() => throw UnsupportedError('Penguins cannot fly!');
}

// ── GOOD: design the hierarchy to match reality ───────────────────────────────

/// ✅ LSP — base contract only includes what ALL birds can do.
abstract class Bird_Good {
  String get name;

  /// All birds eat.
  void eat() => debugPrint('$name is eating');
}

/// ✅ LSP — separate interface for flying ability.
/// Not all birds fly, so flying is not in Bird_Good.
abstract class FlyingBird extends Bird_Good {
  void fly();
}

/// ✅ LSP — Eagle CAN fly, so it extends FlyingBird.
class Eagle extends FlyingBird {
  @override
  String get name => 'Eagle';

  @override
  void fly() => debugPrint('Eagle soaring at high altitude');
}

/// ✅ LSP — Penguin cannot fly, so it does NOT extend FlyingBird.
/// You can safely substitute Penguin wherever Bird_Good is expected.
class Penguin_Good extends Bird_Good {
  @override
  String get name => 'Penguin';

  /// Penguins swim instead of fly.
  void swim() => debugPrint('Penguin swimming gracefully');
}

// ─────────────────────────────────────────────────────────────────────────────
// I — Interface Segregation Principle
// ─────────────────────────────────────────────────────────────────────────────

// ── BAD: one fat interface forces implementations to implement unused methods ──

/// ❌ VIOLATES ISP — this interface forces every "worker" to implement
/// ALL three capabilities, even if they only need one.
/// A Robot worker that never eats must still implement eat() — pointless.
abstract class Worker_Bad {
  void work();
  void eat();   // robots don't eat
  void sleep(); // robots don't sleep
}

/// ❌ Robot is forced to implement methods it doesn't use.
class Robot_Bad implements Worker_Bad {
  @override
  void work() => debugPrint('Robot: working');

  @override
  void eat() => throw UnimplementedError('Robots do not eat'); // forced stub

  @override
  void sleep() => throw UnimplementedError('Robots do not sleep'); // forced stub
}

// ── GOOD: split into small, focused interfaces ────────────────────────────────

/// ✅ ISP — focused interface for working behavior only.
abstract class Workable {
  void work();
}

/// ✅ ISP — focused interface for eating behavior.
abstract class Eatable {
  void eat();
}

/// ✅ ISP — focused interface for sleeping behavior.
abstract class Sleepable {
  void sleep();
}

/// ✅ ISP — Human implements all three because humans work, eat, AND sleep.
class HumanWorker implements Workable, Eatable, Sleepable {
  @override
  void work() => debugPrint('Human: working');
  @override
  void eat() => debugPrint('Human: eating lunch');
  @override
  void sleep() => debugPrint('Human: sleeping 8 hours');
}

/// ✅ ISP — Robot only implements what it actually does. No forced stubs.
class RobotWorker implements Workable {
  @override
  void work() => debugPrint('Robot: working 24/7');
}

// ─────────────────────────────────────────────────────────────────────────────
// D — Dependency Inversion Principle
// ─────────────────────────────────────────────────────────────────────────────

// ── BAD: high-level class depends directly on low-level class ────────────────

/// ❌ VIOLATES DIP — directly depends on a concrete class.
/// If you want to use a different database (SQLite, Firebase, mock for tests),
/// you MUST modify UserService_Bad.
class MySQLDatabase {
  String getUser(int id) => 'User #$id from MySQL';
}

class UserService_Bad {
  // Direct dependency on a specific database implementation — tightly coupled
  final _db = MySQLDatabase();

  String getUser(int id) => _db.getUser(id);
}

// ── GOOD: both depend on an abstraction ───────────────────────────────────────

/// ✅ DIP — abstraction (interface) that both high-level and low-level depend on.
/// [UserService_Good] and all database implementations depend on THIS contract.
abstract class UserRepository {
  /// Returns a user by their ID. Implementation decides where data comes from.
  String getUser(int id);
}

/// ✅ DIP — concrete implementation for production (MySQL database).
class MySQLUserRepository implements UserRepository {
  @override
  String getUser(int id) => 'User #$id from MySQL';
}

/// ✅ DIP — concrete implementation for testing (in-memory mock).
/// No database needed — perfect for unit tests.
class MockUserRepository implements UserRepository {
  final Map<int, String> _data = {
    1: 'Alice (mock)',
    2: 'Bob (mock)',
  };

  @override
  String getUser(int id) => _data[id] ?? 'Unknown user #$id (mock)';
}

/// ✅ DIP — [UserService_Good] depends on the ABSTRACTION [UserRepository],
/// not on any specific database class.
/// Swap MySQL for Firebase, SQLite, or a mock — zero changes to this class.
class UserService_Good {
  /// The repository is injected via the constructor — this is Dependency Injection.
  /// The caller decides which implementation to provide.
  final UserRepository _repository;

  UserService_Good(this._repository);

  String getUser(int id) => _repository.getUser(id);
}

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

class SolidDemo extends StatelessWidget {
  const SolidDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOLID Principles Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const _SolidScreen(),
    );
  }
}

class _SolidScreen extends StatelessWidget {
  const _SolidScreen();

  @override
  Widget build(BuildContext context) {
    // Instantiate examples to show them working
    final validator = EmailValidator();
    final formatter = PriceFormatter();
    final tax = TaxCalculator();

    final shapes = [Rectangle(5, 3), Circle(4), Triangle(6, 4)];
    final calc = AreaCalculator();

    // DIP: swap implementation without changing UserService_Good
    final prodService = UserService_Good(MySQLUserRepository());
    final testService = UserService_Good(MockUserRepository());

    return Scaffold(
      appBar: AppBar(
        title: const Text('SOLID Principles'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _PrincipleCard(
            letter: 'S',
            title: 'Single Responsibility',
            subtitle: 'One class = one reason to change',
            color: Colors.red,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Three separate classes instead of one bloated class:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('EmailValidator: "${validator.isValid('user@test.com')}" — valid email'),
                Text('PriceFormatter: "${formatter.format(99000)}"'),
                Text('TaxCalculator: "${tax.withTax(100000).toStringAsFixed(0)}" — price + 11% VAT'),
                const SizedBox(height: 8),
                const Text(
                  '💡 Each class can be changed, tested, and reused independently.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          _PrincipleCard(
            letter: 'O',
            title: 'Open / Closed',
            subtitle: 'Open for extension, closed for modification',
            color: Colors.orange,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AreaCalculator works with any shape without modification:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...shapes.map(
                  (s) => Text('${s.name}: area = ${calc.calculate(s).toStringAsFixed(2)}'),
                ),
                Text(
                  'Total area: ${calc.totalArea(shapes).toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  '💡 Add a Hexagon class — AreaCalculator never needs to change.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          _PrincipleCard(
            letter: 'L',
            title: 'Liskov Substitution',
            subtitle: 'Subtypes must honor their parent\'s contract',
            color: Colors.green,
            content: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Eagle and Penguin are both Bird_Good — safely substitutable.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('• Eagle extends FlyingBird → can fly ✅'),
                Text('• Penguin extends Bird_Good → cannot fly, and that\'s fine ✅'),
                Text('• Penguin_Bad extends Bird → calling fly() throws ❌'),
                SizedBox(height: 8),
                Text(
                  '💡 If a subclass breaks the parent\'s contract, redesign the hierarchy.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          _PrincipleCard(
            letter: 'I',
            title: 'Interface Segregation',
            subtitle: 'Don\'t force classes to implement unused methods',
            color: Colors.blue,
            content: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Split one fat interface into three focused ones:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('• Workable → work()'),
                Text('• Eatable  → eat()'),
                Text('• Sleepable → sleep()'),
                SizedBox(height: 8),
                Text('HumanWorker implements all three ✅'),
                Text('RobotWorker implements only Workable ✅ (no forced stubs)'),
                SizedBox(height: 8),
                Text(
                  '💡 Clients should not be forced to depend on interfaces they don\'t use.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          _PrincipleCard(
            letter: 'D',
            title: 'Dependency Inversion',
            subtitle: 'Depend on abstractions, not concretions',
            color: Colors.indigo,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Same UserService, two different backends:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Production (MySQL): "${prodService.getUser(1)}"'),
                Text('Test (Mock): "${testService.getUser(1)}"'),
                const SizedBox(height: 8),
                const Text(
                  '💡 Swap MySQL for Firebase, SQLite, or a test mock '
                  'by changing the constructor argument only. '
                  'UserService never needs to change.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable card for displaying one SOLID principle.
/// The [letter] badge (S/O/L/I/D) is the visual anchor.
class _PrincipleCard extends StatelessWidget {
  final String letter;
  final String title;
  final String subtitle;
  final Color color;
  final Widget content;

  const _PrincipleCard({
    required this.letter,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Text(
            letter,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        children: [
          Padding(padding: const EdgeInsets.all(16), child: content),
        ],
      ),
    );
  }
}
