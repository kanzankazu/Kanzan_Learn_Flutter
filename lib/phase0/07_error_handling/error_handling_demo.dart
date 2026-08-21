// ============================================================
// PHASE 0 — Error Handling
// ============================================================
// Purpose: Understand how to handle errors in Dart —
//          try/catch/finally, throwing custom exceptions, multiple
//          catch blocks, and the difference between Error vs Exception.
//
// How to run: dart run lib/phase0/07_error_handling/error_handling_demo.dart
// ============================================================

// ============================================================
// ERROR vs EXCEPTION — Fundamental Difference
// ============================================================
//
// [ERROR]
//   - Subclass of `Error`
//   - Indicates a BUG in the programmer's code — something that
//     should never happen if the code is written correctly.
//   - Examples: StackOverflowError, OutOfMemoryError, AssertionError
//   - Should NOT be caught — let it crash so the bug gets
//     detected and fixed.
//
// [EXCEPTION]
//   - Subclass of `Exception`
//   - Indicates an ANTICIPATED CONDITION — an error that might
//     occur at runtime due to user input, network errors,
//     file not found, etc.
//   - SHOULD be caught and handled properly.
//   - Examples: FormatException, IOException, our custom exceptions
//
// Simple analogy:
//   Error     = a wall collapses because of a bad foundation (construction bug)
//   Exception = a door is locked when you try to enter (a handleable condition)
// ============================================================

void main() {
  print('=== Error Handling Demo ===\n');

  _demoTryCatch();
  _demoOnSpecificType();
  _demoTryCatchFinally();
  _demoThrowCustomException();
  _demoMultipleCatchBlocks();
  _demoRethrow();
}

// ============================================================
// CUSTOM EXCEPTIONS
// ============================================================

/// Exception thrown when the balance is insufficient for a transaction.
///
/// Implements [Exception] (not extends) because in Dart, Exception
/// is an interface — a class can implement Exception to become
/// "an exception" without inheriting its implementation.
class InsufficientFundsException implements Exception {
  /// The available balance amount.
  final double balance;

  /// The amount being withdrawn/paid.
  final double amount;

  const InsufficientFundsException({
    required this.balance,
    required this.amount,
  });

  // toString() is overridden so the error message is informative when printed
  @override
  String toString() {
    return 'InsufficientFundsException: Insufficient balance. '
        'Available: Rp${balance.toStringAsFixed(0)}, '
        'Required: Rp${amount.toStringAsFixed(0)}';
  }
}

/// Exception thrown when user input is invalid.
///
/// Carries [field] (the name of the problematic field) and [message]
/// (explanation of why it's invalid) for clear error reporting.
class InvalidInputException implements Exception {
  /// The name of the field whose value is invalid.
  final String field;

  /// A message explaining why the input is invalid.
  final String message;

  const InvalidInputException({required this.field, required this.message});

  @override
  String toString() {
    return 'InvalidInputException: Field "$field" is invalid — $message';
  }
}

// ============================================================
// DEMO 1: try / catch basics
// ============================================================

/// Demo of the most basic try/catch usage — catching all Exceptions.
///
/// `catch (e)` without a specific type will catch ALL kinds of exceptions.
/// `e` holds the exception object, `s` (stackTrace) holds the stack trace.
void _demoTryCatch() {
  print('--- Demo 1: try / catch basics ---');

  try {
    // Trying to parse a non-numeric string → FormatException
    final angka = int.parse('bukan_angka');
    print('Result: $angka'); // This line will never be reached
  } catch (e) {
    // `e` is the FormatException object
    print('  [catch] An error occurred: $e');
  }

  // The program keeps running after catch — no crash
  print('  Program continues running after the error was handled.\n');
}

// ============================================================
// DEMO 2: on SpecificType catch (e) — catch a specific type
// ============================================================

/// Demo of `on Type` to catch exceptions of a specific type.
///
/// More precise than `catch (e)` — only catches exceptions that are
/// exactly the specified type or a subtype of it.
/// If the exception type doesn't match, it propagates up the call stack.
void _demoOnSpecificType() {
  print('--- Demo 2: on SpecificType catch (e) ---');

  // Scenario 1: FormatException caught with a specific type
  try {
    final hasil = double.parse('abc');
    print('Result: $hasil');
  } on FormatException catch (e) {
    // Only FormatException enters this block
    print('  [FormatException] ${e.message}');
  } on RangeError catch (e) {
    // RangeError won't enter here because it's not what was thrown
    print('  [RangeError] $e');
  }

  // Scenario 2: Custom exception caught with a specific type
  try {
    _tarikUang(saldo: 100000, jumlah: 500000);
  } on InsufficientFundsException catch (e) {
    print('  [InsufficientFundsException] $e');
  }

  print('');
}

// ============================================================
// DEMO 3: try / catch / finally — cleanup always runs
// ============================================================

/// Demo of `finally` — a block that ALWAYS executes, whether or not an error occurs.
///
/// `finally` is used for cleanup: closing files, closing database connections,
/// releasing resources, etc. Regardless of error or success, finally always runs.
void _demoTryCatchFinally() {
  print('--- Demo 3: try / catch / finally ---');

  // Scenario 1: There is an error — finally still runs
  print('  Scenario: error occurs');
  try {
    print('    [try] Opening database connection...');
    throw Exception('Database connection failed!');
  } catch (e) {
    print('    [catch] Handling error: $e');
  } finally {
    // This always executes — important for closing resources
    print('    [finally] Closing database connection (always runs!)');
  }

  print('');

  // Scenario 2: No error — finally still runs
  print('  Scenario: no error');
  try {
    print('    [try] Opening file...');
    print('    [try] Reading data... OK');
  } catch (e) {
    print('    [catch] Error: $e');
  } finally {
    // Finally still runs even if try succeeds without exception
    print('    [finally] Closing file (always runs!)\n');
  }
}

// ============================================================
// DEMO 4: throw — throwing a custom exception
// ============================================================

/// Demo of how to throw an exception using the `throw` keyword.
///
/// We can `throw` any object that implements `Exception`,
/// even a plain object can be thrown in Dart. But best practice:
/// always throw something that implements `Exception` or `Error`.
void _demoThrowCustomException() {
  print('--- Demo 4: throw custom exception ---');

  // Scenario 1: throw InsufficientFundsException
  try {
    _validasiNamaUser('');
  } on InvalidInputException catch (e) {
    print('  Caught InvalidInputException: $e');
  }

  // Scenario 2: throw based on a business condition
  try {
    _tarikUang(saldo: 50000, jumlah: 200000);
  } on InsufficientFundsException catch (e) {
    print('  Caught InsufficientFundsException: $e');
  }

  print('');
}

// ============================================================
// DEMO 5: Multiple catch blocks
// ============================================================

/// Demo of multiple catch blocks — each error type is handled differently.
///
/// The order of `on` / `catch` blocks matters:
/// - More specific types must come BEFORE more general types
/// - `catch (e)` goes last because it catches everything that slips through
void _demoMultipleCatchBlocks() {
  print('--- Demo 5: Multiple catch blocks ---');

  // Try several different scenarios
  final inputs = ['123', 'abc', null, '-1'];

  for (final input in inputs) {
    try {
      final hasil = _prosesInput(input);
      print('  Input "$input" → Result: $hasil');
    } on InvalidInputException catch (e) {
      // First specific type — catch InvalidInputException
      print('  Input "$input" → [InvalidInput] ${e.message}');
    } on FormatException catch (e) {
      // Second specific type — catch FormatException
      print('  Input "$input" → [FormatException] ${e.message}');
    } on RangeError catch (e) {
      // Third specific type — catch RangeError
      print('  Input "$input" → [RangeError] ${e.message}');
    } catch (e) {
      // Catch-all — catches any exception not matched above
      print('  Input "$input" → [Unknown] $e');
    }
  }

  print('');
}

// ============================================================
// DEMO 6: rethrow — re-throwing an exception
// ============================================================

/// Demo of `rethrow` — catching an exception, logging it, then re-throwing it to the caller.
///
/// `rethrow` is useful when we need to:
/// - Log the error in a lower layer
/// - But still let the upper layer handle/decide what to do
/// Unlike `throw e` — `rethrow` preserves the original stack trace.
void _demoRethrow() {
  print('--- Demo 6: rethrow ---');

  try {
    _operasiDenganRethrow();
  } on InsufficientFundsException catch (e) {
    // The exception re-thrown by _operasiDenganRethrow() is caught here
    print('  [Upper layer] Successfully caught exception from below: $e');
  }

  print('');
}

// ============================================================
// HELPER FUNCTIONS
// ============================================================

/// Simulates withdrawing money from an ATM.
/// Throws [InsufficientFundsException] if the balance is insufficient.
void _tarikUang({required double saldo, required double jumlah}) {
  if (jumlah <= 0) {
    throw InvalidInputException(
      field: 'jumlah',
      message: 'Withdrawal amount must be greater than 0',
    );
  }

  if (jumlah > saldo) {
    // Throw the custom exception with relevant data
    throw InsufficientFundsException(balance: saldo, amount: jumlah);
  }

  print('  Successfully withdrew Rp${jumlah.toStringAsFixed(0)}');
}

/// Validates a username — name must not be empty.
/// Throws [InvalidInputException] if the name is empty or null.
void _validasiNamaUser(String? nama) {
  if (nama == null || nama.trim().isEmpty) {
    throw InvalidInputException(
      field: 'nama',
      message: 'Name must not be empty',
    );
  }
}

/// Processes a string input — parses it into a positive number.
/// Throws various exceptions depending on the input condition.
int _prosesInput(String? input) {
  // null → InvalidInputException
  if (input == null) {
    throw InvalidInputException(field: 'input', message: 'Input must not be null');
  }

  // Not a number → FormatException (from int.parse)
  final angka = int.parse(input);

  // Negative number → RangeError
  if (angka < 0) {
    throw RangeError.range(angka, 0, null, 'input', 'Number must be positive');
  }

  return angka;
}

/// A function that catches an exception, logs it, then rethrows it to the caller.
void _operasiDenganRethrow() {
  try {
    print('  [Lower layer] Attempting operation...');
    _tarikUang(saldo: 10000, jumlah: 99999);
  } on InsufficientFundsException catch (e) {
    // Log at the lower layer — but don't handle it, pass it up
    print('  [Lower layer] Logging error: $e');
    rethrow; // Re-throw — original stack trace is preserved
  }
}
