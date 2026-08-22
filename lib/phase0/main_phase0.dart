// ============================================================
// PHASE 0 — Entry Point: Main Menu
// ============================================================
// Purpose: Entry point for all demos and mini projects in Phase 0.
//          Learners can see the complete list of topics along with
//          instructions on how to run each file directly.
//
// How to run: dart run lib/phase0/main_phase0.dart
// ============================================================

import 'dart:io';

void main() {
  print('');
  print('╔══════════════════════════════════════════════════╗');
  print('║        PHASE 0 — Dart Programming Foundations   ║');
  print('║          Learn Dart from Scratch, Step by Step  ║');
  print('╚══════════════════════════════════════════════════╝');
  print('');

  // Menu loop — keeps showing until user selects exit (0)
  bool running = true;
  while (running) {
    _tampilkanMenu();

    final input = stdin.readLineSync()?.trim() ?? '';
    print('');

    switch (input) {
      case '1':
        _tampilkanInfo(
          judul: 'Variables & Data Types Demo',
          perintah: 'dart run lib/phase0/01_variables/variables_demo.dart',
          topik: [
            'int, double, String, bool',
            'var (type inference), dynamic',
            'final, const (immutable)',
            'String interpolation',
            'Null safety: String? vs String, operator ??',
          ],
        );
      case '2':
        _tampilkanInfo(
          judul: 'Operators Demo',
          perintah: 'dart run lib/phase0/02_operators/operators_demo.dart',
          topik: [
            'Arithmetic: +, -, *, /, ~/, %',
            'Assignment: =, +=, -=, *=, /=, ??=',
            'Comparison: ==, !=, >, <, >=, <=',
            'Logical: &&, ||, !',
            'Null-aware: ??, ?., ! (null assertion)',
          ],
        );
      case '3':
        _tampilkanInfo(
          judul: 'Control Flow Demo',
          perintah:
              'dart run lib/phase0/03_control_flow/control_flow_demo.dart',
          topik: [
            'if / else if / else',
            'switch / case / default',
            'for loop (counter)',
            'for-in loop (collection iteration)',
            'while and do-while loop',
            'break (exit loop) and continue (skip iteration)',
          ],
        );
      case '4':
        _tampilkanInfo(
          judul: 'Functions Demo',
          perintah: 'dart run lib/phase0/04_functions/functions_demo.dart',
          topik: [
            'Regular function with return type',
            'Arrow function (=> expression)',
            'Positional, named, and optional parameters',
            'Default parameter value',
            'Anonymous function / lambda',
            'Higher-order function (function as argument)',
            'Recursive function (example: factorial)',
          ],
        );
      case '5':
        _tampilkanInfo(
          judul: 'Collections Demo',
          perintah:
              'dart run lib/phase0/05_collections/collections_demo.dart',
          topik: [
            'List: add, remove, index access, iteration',
            'Map: key-value, null-safe access, entries iteration',
            'Set: auto-deduplicate, union, intersection, difference',
            'Type-safe collection: List<String>, Map<String, int>',
            'Conversion: list.toSet(), set.toList()',
          ],
        );
      case '6':
        _tampilkanInfo(
          judul: 'OOP (Object-Oriented Programming) Demo',
          perintah: 'dart run lib/phase0/06_oop/oop_demo.dart',
          topik: [
            'Class, constructor (positional & named)',
            'Instance variable and method',
            'Inheritance: extends, super',
            'Abstract class as blueprint',
            'Implements (multiple interfaces)',
            'Getter and setter',
            'Static member (class variable & method)',
          ],
        );
      case '7':
        _tampilkanInfo(
          judul: 'Error Handling Demo',
          perintah:
              'dart run lib/phase0/07_error_handling/error_handling_demo.dart',
          topik: [
            'try / catch — catch general errors',
            'on SpecificType catch (e) — catch specific types',
            'try / catch / finally — cleanup always runs',
            'throw — throw a custom exception',
            'Custom Exception class',
            'Difference between Error (bug) vs Exception (anticipated condition)',
          ],
        );
      case '8':
        _tampilkanInfo(
          judul: 'Mini Project: CLI Calculator',
          perintah:
              'dart run lib/phase0/mini_projects/calculator/calculator.dart',
          topik: [
            'Calculator class with methods: add, subtract, multiply, divide',
            'Custom DivisionByZeroException',
            'Operation history stored in a List',
            'Interactive menu via stdin',
            'Input validation and error handling',
          ],
          isMiniProject: true,
        );
      case '9':
        _tampilkanInfo(
          judul: 'Mini Project: CLI To-Do List',
          perintah: 'dart run lib/phase0/mini_projects/todo/todo_app.dart',
          topik: [
            'TodoItem class (id, title, isDone, createdAt)',
            'TodoManager class — CRUD operations',
            'Filter: pending vs completed',
            'Interactive menu via stdin',
            'Validation: cannot add an empty task',
          ],
          isMiniProject: true,
        );
      case '10':
        _tampilkanInfo(
          judul: 'Mini Project: Guess the Number',
          perintah:
              'dart run lib/phase0/mini_projects/guess_number/guess_number.dart',
          topik: [
            'Choose difficulty: Easy / Normal / Hard',
            'Random number generation (dart:math)',
            'Hint: Too high / Too low / CORRECT',
            'Attempt counter + star score system',
            'Option to play again without restarting',
          ],
          isMiniProject: true,
        );
      case '0':
        // Exit the program
        print('Happy learning Dart! 🚀');
        print('');
        running = false;
      default:
        // Invalid input — prompt again
        print('⚠️  Invalid choice. Enter a number from 0–10.');
        print('');
    }
  }
}

/// Displays the Phase 0 main menu.
///
/// Shows all available demo and mini project options
/// in Phase 0.
void _tampilkanMenu() {
  print('┌──────────────────────────────────────────────────┐');
  print('│                  SELECT TOPIC                    │');
  print('├──────────────────────────────────────────────────┤');
  print('│  Topic Demos:                                    │');
  print('│   1. Variables & Data Types                      │');
  print('│   2. Operators                                   │');
  print('│   3. Control Flow                                │');
  print('│   4. Functions                                   │');
  print('│   5. Collections (List, Map, Set)                │');
  print('│   6. OOP (Object-Oriented Programming)           │');
  print('│   7. Error Handling                              │');
  print('├──────────────────────────────────────────────────┤');
  print('│  Mini Projects:                                  │');
  print('│   8. CLI Calculator                              │');
  print('│   9. CLI To-Do List                              │');
  print('│  10. Guess the Number                            │');
  print('├──────────────────────────────────────────────────┤');
  print('│   0. Exit                                        │');
  print('└──────────────────────────────────────────────────┘');
  stdout.write('Select (0-10): ');
}

/// Displays information about the selected topic.
///
/// Since demo files are run separately, this function
/// shows the topic description and the command to run it.
///
/// Parameters:
/// - [judul] — the topic name to display
/// - [perintah] — the `dart run` command to execute the file
/// - [topik] — list of concepts covered in this demo
/// - [isMiniProject] — if true, label is shown as "Mini Project"
void _tampilkanInfo({
  required String judul,
  required String perintah,
  required List<String> topik,
  bool isMiniProject = false,
}) {
  // Category label: Topic Demo or Mini Project
  final label = isMiniProject ? '🎯 MINI PROJECT' : '📖 TOPIC DEMO';

  print('$label: $judul');
  print('─' * 50);

  // Display the list of concepts covered
  print('Concepts covered:');
  for (final t in topik) {
    print('  • $t');
  }

  print('');
  print('Run with:');
  print('  \$ $perintah');
  print('');
}
