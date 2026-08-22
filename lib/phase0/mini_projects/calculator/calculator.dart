// ============================================================
// PHASE 0 — Mini Project 1: Calculator CLI
// ============================================================
// Goal: Practice Phase 0 concepts in an integrated way:
//   - Class & constructor (Calculator, DivisionByZeroException)
//   - Methods with return values (add, subtract, multiply, divide)
//   - Error handling (try/catch, custom Exception, FormatException)
//   - Collections (List<String> for history)
//   - Control flow (menu loop, switch for operation choice)
//   - Terminal input/output (stdin.readLineSync)
//
// How to run: dart run lib/phase0/mini_projects/calculator/calculator.dart
// ============================================================

import 'dart:io'; // for stdin.readLineSync() — reads input from terminal

// ============================================================
// EXCEPTION: DivisionByZeroException
// ============================================================
// Custom Exception for division by zero cases.
// In Dart, you can create your own exception by using
// "implements Exception". This is more descriptive than
// throwing a generic Exception('message').
//
// Concept: custom exception, implements keyword

/// Exception thrown when attempting to divide by zero.
///
/// Example:
/// ```dart
/// throw DivisionByZeroException();
/// ```
class DivisionByZeroException implements Exception {
  /// Error message describing the cause of the exception.
  final String message;

  /// Constructor — message already has a default value.
  const DivisionByZeroException(
      [this.message = 'Cannot divide by zero!']);

  /// toString() is overridden so the message prints cleanly.
  @override
  String toString() => 'DivisionByZeroException: $message';
}

// ============================================================
// CLASS: Calculator
// ============================================================
// Main calculator class. Stores the history of all operations
// performed during a single session.
//
// Concepts: class, private field (_history), List, method,
//           throw exception

/// A simple calculator that supports 4 basic operations
/// and stores a history of every operation performed.
///
/// Example usage:
/// ```dart
/// final calc = Calculator();
/// double result = calc.add(5, 3); // 8.0
/// print(calc.getHistory());        // ['5.0 + 3.0 = 8.0']
/// ```
class Calculator {
  // Private field: List to store all operation results.
  // Leading underscore (_) means private in Dart.
  final List<String> _history = [];

  // ----------------------------------------------------------
  // ARITHMETIC OPERATIONS
  // ----------------------------------------------------------
  // Each method accepts two doubles, computes the result,
  // saves it to history, then returns the result.

  /// Adds [a] and [b], then saves to history.
  double add(double a, double b) {
    final result = a + b;
    // Save to history in a human-readable format
    _history.add('$a + $b = $result');
    return result;
  }

  /// Subtracts [b] from [a], then saves to history.
  double subtract(double a, double b) {
    final result = a - b;
    _history.add('$a - $b = $result');
    return result;
  }

  /// Multiplies [a] by [b], then saves to history.
  double multiply(double a, double b) {
    final result = a * b;
    _history.add('$a * $b = $result');
    return result;
  }

  /// Divides [a] by [b], then saves to history.
  ///
  /// Throws [DivisionByZeroException] if [b] is 0.
  double divide(double a, double b) {
    // Guard clause: check divisor before performing the operation
    // If b = 0, throw exception — do not proceed
    if (b == 0) throw const DivisionByZeroException();

    final result = a / b;
    _history.add('$a / $b = $result');
    return result;
  }

  // ----------------------------------------------------------
  // HISTORY
  // ----------------------------------------------------------

  /// Returns an unmodifiable copy of the history list.
  ///
  /// Uses List.unmodifiable so callers cannot mutate the internal list.
  List<String> getHistory() => List.unmodifiable(_history);

  /// Clears all operation history.
  void clearHistory() => _history.clear();
}

// ============================================================
// HELPER: Terminal Input
// ============================================================

/// Reads one line of input from the terminal.
/// Returns an empty string if the user presses Enter without typing anything.
String readLine(String prompt) {
  stdout.write(prompt); // stdout.write = print without a trailing newline
  return stdin.readLineSync() ?? ''; // ?? '' = use empty string if null
}

/// Reads a double value from the terminal.
///
/// Keeps asking for input until the user enters a valid number.
/// Handles [FormatException] if the input is not a number.
///
/// [prompt] — text displayed before the input field
double readDouble(String prompt) {
  while (true) {
    // Loop until input is valid
    final input = readLine(prompt);
    try {
      // double.parse() throws FormatException if input is not a number
      return double.parse(input);
    } on FormatException {
      // Catch the error, ask again — no crash
      print('⚠️  Invalid input! Enter a number (e.g. 5, 3.14, -2).');
    }
  }
}

/// Reads a menu choice (integer) from the terminal.
///
/// Keeps asking until the user enters a number within [min]–[max].
///
/// [prompt] — text displayed before the input field
/// [min], [max] — lower and upper bounds for valid choices
int readMenuChoice(String prompt, int min, int max) {
  while (true) {
    final input = readLine(prompt);
    try {
      final choice = int.parse(input); // int.parse() for whole numbers
      if (choice >= min && choice <= max) {
        return choice; // valid → exit the loop
      }
      print('⚠️  Choice must be between $min–$max. Try again.');
    } on FormatException {
      print('⚠️  Enter a number only (e.g. 1, 2, 0). No letters or symbols.');
    }
  }
}

// ============================================================
// MAIN: Menu Loop
// ============================================================
// Program entry point. All UI logic lives here.
// Calculator is instantiated once and reused throughout the session.

void main() {
  // Create a Calculator instance — history is empty at start
  final calculator = Calculator();

  // Display the welcome header
  print('╔══════════════════════════════╗');
  print('║     🧮  CALCULATOR CLI       ║');
  print('║     Phase 0 — Mini Project   ║');
  print('╚══════════════════════════════╝');
  print('');

  // ── MENU LOOP ──────────────────────────────────────────────
  // Loop until the user selects 0 (Exit).
  // This is a common pattern: a "game loop" or REPL (Read-Eval-Print Loop).
  while (true) {
    // Display the menu on every iteration
    _tampilMenu();

    // Read user choice: must be a number 0–6
    final pilihan = readMenuChoice('Choose menu [0–6]: ', 0, 6);

    // Choice 0 = exit the loop
    if (pilihan == 0) {
      print('\n👋 Goodbye! Your history: ${calculator.getHistory().length} operation(s).');
      break; // exit the while loop
    }

    // Process the selected option
    _prosesMenu(pilihan, calculator);

    // Add spacing before showing the menu again
    print('');
  }
}

/// Displays the main menu in the terminal.
void _tampilMenu() {
  print('──────────────────────────────');
  print('  CALCULATOR MENU');
  print('──────────────────────────────');
  print('  1. ➕ Add');
  print('  2. ➖ Subtract');
  print('  3. ✖️  Multiply');
  print('  4. ➗ Divide');
  print('  5. 📜 View History');
  print('  6. 🗑️  Clear History');
  print('  0. 🚪 Exit');
  print('──────────────────────────────');
}

/// Processes the selected menu option and executes the corresponding operation.
///
/// [pilihan] — number 1–6 from user input
/// [calculator] — the Calculator instance in use
void _prosesMenu(int pilihan, Calculator calculator) {
  // switch–case is cleaner than nested if–else for menu choices
  switch (pilihan) {
    case 1:
    case 2:
    case 3:
    case 4:
      // Choices 1–4 = arithmetic operation: ask for two numbers
      _lakukanOperasi(pilihan, calculator);

    case 5:
      // Display all history entries
      _tampilHistory(calculator);

    case 6:
      // Delete all history
      calculator.clearHistory();
      print('✅ History cleared successfully.');
  }
}

/// Asks the user for two numbers, performs the operation, and displays the result.
///
/// [pilihan] — 1=add, 2=subtract, 3=multiply, 4=divide
/// [calculator] — the Calculator instance
void _lakukanOperasi(int pilihan, Calculator calculator) {
  // Operation name for a user-friendly prompt
  final namaOperasi = switch (pilihan) {
    1 => 'Add (+)',
    2 => 'Subtract (-)',
    3 => 'Multiply (×)',
    4 => 'Divide (÷)',
    _ => 'Operation', // fallback (should never happen)
  };

  print('\n📐 $namaOperasi');

  // Read two numbers from the user
  final a = readDouble('  First number  : ');
  final b = readDouble('  Second number : ');

  try {
    // Execute the operation based on the choice
    // Result is stored in a variable so it can be displayed
    final double result;
    final String simbol;

    switch (pilihan) {
      case 1:
        result = calculator.add(a, b);
        simbol = '+';
      case 2:
        result = calculator.subtract(a, b);
        simbol = '-';
      case 3:
        result = calculator.multiply(a, b);
        simbol = '×';
      case 4:
        result = calculator.divide(a, b); // can throw DivisionByZeroException
        simbol = '÷';
      default:
        return; // should not reach here
    }

    // Display the result in format: "5.0 + 3.0 = 8.0"
    print('\n  ✅ Result: $a $simbol $b = $result');
  } on DivisionByZeroException catch (e) {
    // Catch DivisionByZeroException specifically from the divide() method
    print('\n  ❌ Error: ${e.message}');
  }
}

/// Displays all stored operation history entries.
///
/// [calculator] — the Calculator instance
void _tampilHistory(Calculator calculator) {
  final history = calculator.getHistory();

  print('\n📜 OPERATION HISTORY:');
  print('──────────────────────────────');

  if (history.isEmpty) {
    // No operations have been performed yet
    print('  (No operations yet.)');
  } else {
    // Enumerate with index: display a sequential number for each entry
    // asMap() converts List → Map<int, String> (index → value)
    for (final entry in history.asMap().entries) {
      print('  ${entry.key + 1}. ${entry.value}');
    }
  }

  print('──────────────────────────────');
  print('  Total: ${history.length} operation(s)');
}
