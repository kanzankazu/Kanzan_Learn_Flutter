// ============================================================
// PHASE 0 — Mini Project 3: Guess a Number
// ============================================================
// Purpose: Practice random, loop, conditions, and counter
//          in a single interactive CLI program.
//
// Concepts practiced:
//   - dart:math (Random) to generate a random number
//   - Enum for difficulty choices
//   - Loop (while) for the game cycle
//   - Conditions (if/else) for hints and scoring
//   - try/catch for input validation
//   - Counter (attempts)
//
// How to run: dart run lib/phase0/mini_projects/guess_number/guess_number.dart
// ============================================================

import 'dart:io';
import 'dart:math';

// ============================================================
// ENUM: Difficulty Level
// ============================================================

/// Difficulty levels for the number guessing game.
///
/// Each level determines the upper bound of the generated number range.
/// `label` is used for the menu display, `maxNumber` for the range limit.
///
/// Concepts practiced:
/// - Enum with fields and constructor
/// - Encapsulating configuration in a data type
enum Difficulty {
  /// Easy — number between 1 and 50.
  mudah('Easy (1-50)', 50),

  /// Normal — number between 1 and 100.
  normal('Normal (1-100)', 100),

  /// Hard — number between 1 and 200.
  susah('Hard (1-200)', 200);

  /// Label displayed in the selection menu.
  final String label;

  /// Upper bound of the number range that can be generated (inclusive).
  final int maxNumber;

  // Enum constructor — every value must have a label and maxNumber
  const Difficulty(this.label, this.maxNumber);
}

// ============================================================
// CLASS: GameResult
// ============================================================

/// The final result of one game session.
///
/// Stores the secret number, the number of attempts,
/// and the final score text.
///
/// Concepts practiced:
/// - Simple class as a data container
/// - Named constructor-style via field initialization
class GameResult {
  /// The secret number that had to be guessed.
  final int secretNumber;

  /// Total attempts needed to guess correctly.
  final int attempts;

  /// Score text based on the number of attempts (e.g. "⭐⭐⭐ AMAZING!").
  final String scoreLabel;

  /// Creates a [GameResult] from the secret number, attempts, and score label.
  GameResult({
    required this.secretNumber,
    required this.attempts,
    required this.scoreLabel,
  });
}

// ============================================================
// FUNCTION: Input & Validation
// ============================================================

/// Display a prompt and read one line of input from the user.
///
/// Returns an empty string if `stdin` is exhausted (EOF),
/// so the program does not crash in non-interactive environments.
String readLine(String prompt) {
  stdout.write(prompt);
  return stdin.readLineSync() ?? '';
}

/// Ask the user to choose a difficulty and return the selected [Difficulty].
///
/// Concepts practiced:
/// - do-while loop for repeated input validation
/// - Parsing a string to int with try/catch
/// - Using a `List` for valid choices
Difficulty chooseDifficulty() {
  // List of all Difficulty enum values
  final options = Difficulty.values;

  while (true) {
    print('\nChoose difficulty level:');
    for (var i = 0; i < options.length; i++) {
      // Display numbers starting from 1 to feel more natural for the user
      print('  ${i + 1}. ${options[i].label}');
    }

    final input = readLine('Choice (1-${options.length}): ').trim();

    try {
      final choice = int.parse(input);
      if (choice >= 1 && choice <= options.length) {
        // Return the enum matching the choice (index = choice - 1)
        return options[choice - 1];
      }
    } on FormatException {
      // Input is not a number — FormatException from int.parse
    }

    // Error message if input is invalid
    print('⚠️  Invalid input. Enter a number from 1 to ${options.length}.');
  }
}

/// Ask the user for a guess and validate it.
///
/// Keeps asking until the user enters an `int`
/// within the range `1` to `maxNumber`.
///
/// Concepts practiced:
/// - Input validation with try/catch + while loop
/// - Range check with comparison operators
int askGuess(int maxNumber) {
  while (true) {
    final input = readLine('Your guess (1-$maxNumber): ').trim();

    try {
      final guess = int.parse(input);
      if (guess >= 1 && guess <= maxNumber) {
        return guess; // ✅ Valid — exit the loop
      }
      // Number is out of range
      print('⚠️  Number must be between 1 and $maxNumber.');
    } on FormatException {
      // Not a whole number
      print('⚠️  Invalid input. Enter a whole number.');
    }
  }
}

// ============================================================
// FUNCTION: Score
// ============================================================

/// Calculate the score label based on the number of attempts.
///
/// Fewer attempts yield more stars:
/// - ≤ 3  → ⭐⭐⭐ AMAZING!
/// - ≤ 7  → ⭐⭐ GREAT!
/// - ≤ 15 → ⭐ DECENT
/// - > 15 → Keep practicing!
///
/// Concepts practiced:
/// - if/else if/else chain as a grade system
String calculateScore(int attempts) {
  if (attempts <= 3) {
    return '⭐⭐⭐ AMAZING!';
  } else if (attempts <= 7) {
    return '⭐⭐ GREAT!';
  } else if (attempts <= 15) {
    return '⭐ DECENT';
  } else {
    return 'Keep practicing!';
  }
}

// ============================================================
// FUNCTION: One Game Session
// ============================================================

/// Run one number guessing game session.
///
/// Generates a secret number, then loops asking for guesses until correct.
/// Each iteration increments the `attempts` counter by one.
/// After a correct guess, calculates the score and returns a [GameResult].
///
/// Concepts practiced:
/// - dart:math Random for random numbers
/// - while loop with a stopping condition
/// - Counter variable (attempts)
/// - Nested if/else for hints
GameResult playGame(Difficulty difficulty) {
  // Generate a random number in range 1 to maxNumber (inclusive)
  final random = Random();
  // nextInt(n) produces 0 to n-1 → add 1 to shift range to 1-maxNumber
  final secretNumber = random.nextInt(difficulty.maxNumber) + 1;

  int attempts = 0; // attempt counter, starting at 0

  print('\n🎮 Game started! Guess a number between 1 and ${difficulty.maxNumber}.\n');

  // Main loop — continues until the guess is correct
  while (true) {
    final guess = askGuess(difficulty.maxNumber);
    attempts++; // increment counter on every guess

    if (guess < secretNumber) {
      // Guess is too low
      print('👆 Higher!\n');
    } else if (guess > secretNumber) {
      // Guess is too high
      print('👇 Lower!\n');
    } else {
      // Guess is correct — exit the loop
      final score = calculateScore(attempts);
      return GameResult(
        secretNumber: secretNumber,
        attempts: attempts,
        scoreLabel: score,
      );
    }
  }
}

// ============================================================
// FUNCTION: Show Result
// ============================================================

/// Display the final result of a game session to the console.
///
/// Shows the secret number, the number of attempts, and the score label.
void showResult(GameResult result) {
  print('🎉 CORRECT! The number was ${result.secretNumber}.');
  print('📊 You got it in ${result.attempts} attempt(s).');
  print('🏆 Score: ${result.scoreLabel}');
}

// ============================================================
// FUNCTION: Ask to Play Again
// ============================================================

/// Ask whether the user wants to play again.
///
/// Accepts 'Y' or Enter for yes, 'n' for no.
/// Input is case-insensitive — 'y' and 'Y' are both accepted.
///
/// Concepts practiced:
/// - Case-insensitive string comparison
/// - Default value from empty input (Enter = yes)
bool askPlayAgain() {
  final input = readLine('\nPlay again? (Y/n): ').trim().toLowerCase();
  // Empty input (user pressed Enter) is treated as "yes"
  return input == '' || input == 'y';
}

// ============================================================
// ENTRY POINT
// ============================================================

/// Entry point for the Guess a Number program.
///
/// The program runs in an outer loop — each iteration is one
/// full session: choose difficulty → guess → see score.
/// The loop stops when the user chooses not to play again.
///
/// Concepts practiced:
/// - Main program loop with a user-driven stopping condition
/// - Composing small functions into a clear program flow
void main() {
  // Opening banner
  print('╔════════════════════════════╗');
  print('║   🎯 GUESS A NUMBER CLI    ║');
  print('╚════════════════════════════╝');
  print('Welcome to the Guess a Number game!');

  // Outer loop — for the play-again feature without restarting the program
  do {
    // 1. Choose difficulty
    final difficulty = chooseDifficulty();
    print('\n✅ Difficulty: ${difficulty.label}');

    // 2. Play one session
    final result = playGame(difficulty);

    // 3. Show final result
    print('');
    print('─' * 32);
    showResult(result);
    print('─' * 32);
  } while (askPlayAgain()); // repeat if user wants to play again

  // Closing message
  print('\nThanks for playing! See you next time. 👋');
}
