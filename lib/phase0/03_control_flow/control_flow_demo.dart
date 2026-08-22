// ============================================================
// PHASE 0 — Control Flow
// ============================================================
// Purpose: Learn all control flow structures in Dart —
//          if/else, switch/case, various loop types, and
//          the break and continue keywords to control loops.
//          Each concept is demonstrated with real-world examples
//          that are easy for beginners to understand.
//
// How to run: dart run lib/phase0/03_control_flow/control_flow_demo.dart
// ============================================================

import 'dart:io';

void main() {
  print('=== Control Flow Demo ===\n');

  _demoIfElse();
  _demoSwitch();
  _demoForLoop();
  _demoForInLoop();
  _demoWhileLoop();
  _demoDoWhileLoop();
  _demoBreak();
  _demoContinue();
}

// ============================================================
// DEMO 1 — if / else if / else
// ============================================================

/// Demo branching with `if / else if / else` — choosing an execution
/// path based on a given condition.
///
/// Basic structure:
/// ```dart
/// if (condition1) {
///   // runs if condition1 is true
/// } else if (condition2) {
///   // runs if condition1 is false and condition2 is true
/// } else {
///   // runs if all conditions above are false
/// }
/// ```
///
/// Dart also supports the **ternary operator** as a shorthand:
/// `condition ? valueIfTrue : valueIfFalse`
///
/// Example use case: determining a letter grade from an exam score.
void _demoIfElse() {
  print('--- if / else if / else ---');

  // ── Example 1: Exam grade system ───────────────────────────
  // We have a numeric score and want to convert it to a letter grade
  print('Example 1: Exam grade system');

  int nilaiUjian = 78;
  String grade;

  // Cascading checks from the strictest condition to the most lenient
  if (nilaiUjian >= 90) {
    grade = 'A';
  } else if (nilaiUjian >= 80) {
    grade = 'B';
  } else if (nilaiUjian >= 70) {
    grade = 'C'; // nilaiUjian 78 falls here
  } else if (nilaiUjian >= 60) {
    grade = 'D';
  } else {
    grade = 'E'; // score < 60 → failing
  }

  print('  Score: $nilaiUjian → Grade: $grade');

  // Try a few other scores
  for (int nilai in [95, 82, 70, 55]) {
    String g;
    if (nilai >= 90) {
      g = 'A';
    } else if (nilai >= 80) {
      g = 'B';
    } else if (nilai >= 70) {
      g = 'C';
    } else if (nilai >= 60) {
      g = 'D';
    } else {
      g = 'E';
    }
    print('  Score: $nilai → Grade: $g');
  }

  // ── Example 2: Ternary operator (shorthand if-else) ────────
  // Use ternary for simple conditions with only 2 outcomes
  print('\nExample 2: Ternary operator');

  int umur = 20;
  // condition ? value_if_true : value_if_false
  String statusUmur = umur >= 17 ? 'Adult' : 'Minor';
  print('  Age $umur → $statusUmur');

  bool isLoggedIn = false;
  String pesanSambutan = isLoggedIn ? 'Welcome back!' : 'Please log in first.';
  print('  isLoggedIn = $isLoggedIn → "$pesanSambutan"');

  // ── Example 3: if without else (one-sided condition) ───────
  // Sometimes we only need an action when the condition is met
  print('\nExample 3: One-sided if (no else)');

  double suhu = 38.5;
  print('  Temperature: $suhu°C');
  if (suhu > 37.5) {
    print('  ⚠️  Fever! Rest and drink plenty of water.');
  }
  // If temperature is normal, no output — program continues to the next line

  print('');
}

// ============================================================
// DEMO 2 — switch / case / default
// ============================================================

/// Demo `switch / case / default` — a cleaner alternative to if-else
/// when comparing one variable against many fixed values.
///
/// Structure:
/// ```dart
/// switch (variable) {
///   case value1:
///     // action for value1
///     break; // ← required, to prevent "falling through" to the next case
///   case value2:
///     // action for value2
///     break;
///   default:
///     // action if no case matches
/// }
/// ```
///
/// ⚠️  Don't forget `break`! Without it, execution will continue
/// into the next case (called "fall-through").
///
/// Example use case: day names and activity recommendations.
void _demoSwitch() {
  print('--- switch / case / default ---');

  // ── Example 1: Day name of the week ────────────────────────
  print('Example 1: Day name of the week');

  int hariKe = 3; // 1 = Monday, 7 = Sunday
  String namaHari;

  switch (hariKe) {
    case 1:
      namaHari = 'Senin';
      break;
    case 2:
      namaHari = 'Selasa';
      break;
    case 3:
      namaHari = 'Rabu'; // hariKe = 3 → falls here
      break;
    case 4:
      namaHari = 'Kamis';
      break;
    case 5:
      namaHari = 'Jumat';
      break;
    case 6:
      namaHari = 'Sabtu';
      break;
    case 7:
      namaHari = 'Minggu';
      break;
    default:
      // Values outside 1–7 are not valid
      namaHari = 'Unknown';
  }

  print('  Day #$hariKe is: $namaHari');

  // ── Example 2: Fall-through — multiple cases, one action ───
  // We can stack cases without break between them to share
  // the same action for multiple values
  print('\nExample 2: Fall-through — multiple cases, one action');

  for (int hari in [1, 3, 5, 6, 7]) {
    String tipe;
    switch (hari) {
      case 6: // Saturday
      case 7: // Sunday
        // These two cases share one action (intentional fall-through)
        tipe = 'Weekend 🎉';
        break;
      case 1:
      case 2:
      case 3:
      case 4:
      case 5:
        tipe = 'Weekday 💼';
        break;
      default:
        tipe = 'Invalid';
    }
    print('  Day #$hari → $tipe');
  }

  // ── Example 3: Switch with String ──────────────────────────
  print('\nExample 3: Switch with String (season)');

  String bulan = 'Maret';
  String musim;

  switch (bulan) {
    case 'Desember':
    case 'Januari':
    case 'Februari':
      musim = 'Rainy Season (peak)';
      break;
    case 'Maret': // month March → falls here
    case 'April':
    case 'Mei':
      musim = 'Transitional Season';
      break;
    case 'Juni':
    case 'Juli':
    case 'Agustus':
      musim = 'Dry Season';
      break;
    case 'September':
    case 'Oktober':
    case 'November':
      musim = 'Transitional Season';
      break;
    default:
      musim = 'Unknown month';
  }

  print('  Month $bulan → $musim');

  print('');
}

// ============================================================
// DEMO 3 — for Loop (with counter)
// ============================================================

/// Demo `for` loop — repeating code execution a specific number of times.
///
/// Structure:
/// ```dart
/// for (initialization; condition; increment) {
///   // code to repeat
/// }
/// ```
///
/// The three parts inside the parentheses:
/// 1. **Initialization** — runs once at the start (`int i = 0`)
/// 2. **Condition** — checked each iteration, loop stops when false (`i < 5`)
/// 3. **Increment** — runs after each iteration (`i++`)
///
/// Use `for` loop when the **number of iterations is known in advance**.
void _demoForLoop() {
  print('--- for Loop (with counter) ---');

  // ── Example 1: Count up ─────────────────────────────────────
  print('Example 1: Count from 1 to 5');
  for (int i = 1; i <= 5; i++) {
    // i++ is shorthand for i = i + 1
    print('  Iteration #$i');
  }

  // ── Example 2: Count down ──────────────────────────────────
  print('\nExample 2: Count down from 5 to 1');
  for (int i = 5; i >= 1; i--) {
    // i-- is shorthand for i = i - 1
    print('  $i...');
  }
  print('  🚀 Liftoff!');

  // ── Example 3: Step greater than 1 ─────────────────────────
  print('\nExample 3: Even numbers from 2 to 10 (step += 2)');
  for (int i = 2; i <= 10; i += 2) {
    // i += 2 means increment by 2 each iteration
    print('  $i');
  }

  // ── Example 4: Loop with accumulation ──────────────────────
  print('\nExample 4: Calculate total 1 + 2 + ... + 10');
  int total = 0;
  for (int i = 1; i <= 10; i++) {
    total += i; // accumulate: add value of i to total
  }
  print('  Total = $total');

  // ── Example 5: Multiplication table ───────────────────────
  print('\nExample 5: Multiplication table of 3');
  for (int i = 1; i <= 5; i++) {
    print('  3 × $i = ${3 * i}');
  }

  print('');
}

// ============================================================
// DEMO 4 — for-in Loop (collection iteration)
// ============================================================

/// Demo `for-in` loop — an elegant way to iterate over all elements
/// in a collection (List, Set, Map, etc.).
///
/// Structure:
/// ```dart
/// for (var element in collection) {
///   // use element here
/// }
/// ```
///
/// Difference from a regular `for` loop:
/// - Regular `for`: you manually control the index/counter
/// - `for-in`: Dart handles the iteration, you focus on the content
///
/// Use `for-in` when you want to **process all elements** without
/// caring about their index. If you need the index, use a regular
/// `for` loop or the `.asMap().entries` method.
void _demoForInLoop() {
  print('--- for-in Loop (collection iteration) ---');

  // ── Example 1: Iterate over a List of Strings ──────────────
  print('Example 1: List of friend names');
  List<String> namaTeman = ['Budi', 'Citra', 'Dian', 'Eko'];

  for (String nama in namaTeman) {
    // Each iteration, the `nama` variable holds the current element
    print('  Hello, $nama!');
  }

  // ── Example 2: Iterate over List of int + operations ────────
  print('\nExample 2: Calculate average score');
  List<int> nilaiUjian = [75, 88, 92, 65, 80];
  int jumlah = 0;

  for (int nilai in nilaiUjian) {
    jumlah += nilai; // accumulate total
  }

  // Calculate average — convert to double first for precision
  double rataRata = jumlah / nilaiUjian.length;
  print('  Scores: $nilaiUjian');
  print('  Average: $rataRata');

  // ── Example 3: Iteration with condition (manual filter) ────
  print('\nExample 3: Filter passing scores (>= 70)');
  List<int> semuaNilai = [55, 78, 90, 42, 85, 68, 73];

  for (int nilai in semuaNilai) {
    if (nilai >= 70) {
      // Only display passing scores
      print('  ✅ Pass: $nilai');
    }
  }

  // ── Example 4: Iterate over a Map ─────────────────────────
  // For Maps, use .entries to get key-value pairs
  print('\nExample 4: Iterate over Map (stock inventory)');
  Map<String, int> stokBarang = {
    'Apel': 50,
    'Mangga': 30,
    'Jeruk': 0,
    'Pisang': 15,
  };

  for (var entry in stokBarang.entries) {
    // entry.key = item name, entry.value = stock count
    String status = entry.value > 0 ? '✅' : '❌ OUT OF STOCK';
    print('  $status ${entry.key}: ${entry.value} pcs');
  }

  // ── Example 5: Iteration with index (using asMap) ───────────
  print('\nExample 5: Display sequence numbers with asMap().entries');
  List<String> todoList = ['Learn Dart', 'Exercise', 'Read a book'];

  for (var entry in todoList.asMap().entries) {
    // entry.key = index, entry.value = list item
    int nomor = entry.key + 1; // +1 so numbering starts at 1, not 0
    print('  $nomor. ${entry.value}');
  }

  print('');
}

// ============================================================
// DEMO 5 — while Loop
// ============================================================

/// Demo `while` loop — repeating execution as long as a condition remains true.
///
/// Structure:
/// ```dart
/// while (condition) {
///   // code to repeat
///   // make sure something changes the condition, or it'll be an infinite loop!
/// }
/// ```
///
/// Difference from `for`:
/// - `for`   → number of iterations is known upfront
/// - `while` → iteration continues as long as condition is met
///             (number of iterations may be unknown)
///
/// ⚠️  Make sure something inside the loop eventually makes the
/// condition false, or the loop will run forever
/// (infinite loop) and the program will never stop!
void _demoWhileLoop() {
  print('--- while Loop ---');

  // ── Example 1: Save until target ───────────────────────────
  print('Example 1: Save until target Rp 1,000,000');

  int tabungan = 0;
  int tabunganPerMinggu = 150000;
  int target = 1000000;
  int minggu = 0;

  // Keep looping until savings reach the target
  while (tabungan < target) {
    minggu++;
    tabungan += tabunganPerMinggu;
    print('  Week $minggu: Rp ${_formatRupiah(tabungan)}');
  }
  print('  🎉 Target reached in $minggu weeks!');

  // ── Example 2: Count down to zero ─────────────────────────
  print('\nExample 2: Countdown');
  int hitungan = 5;
  while (hitungan > 0) {
    print('  $hitungan...');
    hitungan--; // without this → infinite loop!
  }
  print('  Boom! 💥');

  // ── Example 3: Find first number divisible by 7 ────────────
  print('\nExample 3: First number after 50 divisible by 7');
  int angka = 51; // start from 51, skip 50 which is already known
  while (angka % 7 != 0) {
    angka++; // keep incrementing until divisible by 7
  }
  print('  Found: $angka (${angka ~/ 7} × 7)');

  print('');
}

// ============================================================
// DEMO 6 — do-while Loop
// ============================================================

/// Demo `do-while` loop — similar to `while` but the condition is
/// checked **after** the first block executes.
///
/// Structure:
/// ```dart
/// do {
///   // code to repeat
/// } while (condition); // ← condition checked here, AFTER first execution
/// ```
///
/// Key difference from `while`:
/// - `while`    → condition checked BEFORE the first iteration
///               → loop body may never execute (0 times)
/// - `do-while` → condition checked AFTER the first iteration
///               → loop body is guaranteed to run AT LEAST 1 time
///
/// When to use `do-while`? When you need the code to run at least
/// once regardless of the condition — e.g.: display a menu,
/// prompt user for input, validate input.
void _demoDoWhileLoop() {
  print('--- do-while Loop ---');

  // ── Example 1: Comparison between while and do-while ───────
  print('Example 1: Comparison between while and do-while');

  // while: condition is false from the start → loop body never executes
  int angkaWhile = 10;
  print('  while (angka < 5): angka = $angkaWhile');
  while (angkaWhile < 5) {
    print('  This will never be printed!');
    angkaWhile++;
  }
  print('  while done — loop never ran because 10 < 5 = false');

  // do-while: even if condition is immediately false, block runs once
  int angkaDoWhile = 10;
  print('\n  do-while (angka < 5): angka = $angkaDoWhile');
  do {
    print('  This prints ONCE even though 10 < 5 = false!');
    angkaDoWhile++;
  } while (angkaDoWhile < 5); // condition checked after block executes
  print('  do-while done — block runs at least once');

  // ── Example 2: PIN entry simulation ───────────────────────
  // do-while is ideal for "try at least once" scenarios
  // Here we simulate without stdin, using a list of attempts
  print('\nExample 2: PIN validation simulation (no interactive input)');

  List<String> percobaanPin = ['1234', '0000', '9999']; // simulated user input
  String pinBenar = '0000';
  int indexPercobaan = 0;
  bool pinValid = false;

  do {
    String inputPin = percobaanPin[indexPercobaan];
    print('  PIN attempt: $inputPin');

    if (inputPin == pinBenar) {
      pinValid = true;
      print('  ✅ Correct PIN! Access granted.');
    } else {
      print('  ❌ Wrong PIN, try again.');
      indexPercobaan++;
    }

    // Loop stops if PIN is correct or all attempts are exhausted
  } while (!pinValid && indexPercobaan < percobaanPin.length);

  if (!pinValid) {
    print('  🔒 Account locked after ${percobaanPin.length} failed attempts.');
  }

  print('');
}

// ============================================================
// DEMO 7 — break (exit from loop)
// ============================================================

/// Demo `break` — exit a loop or switch **before** the condition
/// finishes normally.
///
/// When `break` executes:
/// - Dart immediately exits the current loop/switch
/// - Remaining iterations are not executed
/// - Execution continues at the line after the loop/switch block
///
/// Use `break` when:
/// - You've already found what you were looking for (search/find)
/// - An error condition requires the loop to stop
/// - Implementing an "early exit" for efficiency
void _demoBreak() {
  print('--- break (exit from loop) ---');

  // ── Example 1: Find the first matching element ─────────────
  print('Example 1: Search for "Dewi" in the list');

  List<String> daftarNama = ['Andi', 'Budi', 'Dewi', 'Eko', 'Fani'];
  String cari = 'Dewi';
  int indexDitemukan = -1; // -1 means not found yet

  for (int i = 0; i < daftarNama.length; i++) {
    print('  Checking index $i: ${daftarNama[i]}');
    if (daftarNama[i] == cari) {
      indexDitemukan = i;
      break; // ← exit immediately, no need to check the rest of the list
    }
  }

  if (indexDitemukan != -1) {
    print('  ✅ "$cari" found at index $indexDitemukan');
    print('  (index 4 and 5 were not checked — exited early)');
  } else {
    print('  ❌ "$cari" not found');
  }

  // ── Example 2: Break inside a while loop ──────────────────
  print('\nExample 2: Process numbers until a multiple of 13 is found');

  int angka = 1;
  while (true) {
    // while (true) = infinite loop — NEEDS break to stop!
    if (angka % 13 == 0) {
      print('  Found! $angka is the first multiple of 13 above 0.');
      break; // without this, the loop will never stop
    }
    angka++;
  }

  // ── Example 3: Break in a nested loop ──────────────────────
  print('\nExample 3: Break in a nested loop');
  print('  (break only exits the INNERMOST loop)');

  // Outer loop: iterate rows (1–3)
  for (int baris = 1; baris <= 3; baris++) {
    print('  Row $baris:');
    // Inner loop: iterate columns (1–5)
    for (int kolom = 1; kolom <= 5; kolom++) {
      if (kolom == 3) {
        print('    → Column 3 found, breaking from inner loop!');
        break; // only exits the INNER loop (column), not the outer loop (row)
      }
      print('    Column $kolom');
    }
  }

  print('');
}

// ============================================================
// DEMO 8 — continue (skip iteration)
// ============================================================

/// Demo `continue` — skips the rest of the current iteration and
/// **immediately** jumps to the next one.
///
/// Difference between `break` and `continue`:
/// - `break`    → exits the loop entirely
/// - `continue` → skips the current iteration, loop KEEPS running
///
/// Use `continue` when:
/// - You want to skip certain elements without stopping the loop
/// - Replacing a long `if (condition) { ... }` block with a
///   "skip if condition not met" approach
void _demoContinue() {
  print('--- continue (skip iteration) ---');

  // ── Example 1: Skip odd numbers ────────────────────────────
  print('Example 1: Display only even numbers from 1–10');

  for (int i = 1; i <= 10; i++) {
    if (i % 2 != 0) {
      continue; // odd number → skip, jump to next i
    }
    // This line only runs if i is an even number
    print('  $i (even)');
  }

  // ── Example 2: Skip specific elements in a list ────────────
  print('\nExample 2: Display all fruits except "Durian"');

  List<String> daftarBuah = ['Apel', 'Durian', 'Mangga', 'Durian', 'Jeruk'];

  for (String buah in daftarBuah) {
    if (buah == 'Durian') {
      print('  ⏭️  Skip: $buah');
      continue; // skip Durian, continue to next fruit
    }
    print('  ✅ $buah');
  }

  // ── Example 3: Skip negative values during accumulation ────
  print('\nExample 3: Sum only positive values');

  List<int> dataNilai = [10, -3, 5, -8, 12, 0, 7, -1];
  int totalPositif = 0;

  for (int nilai in dataNilai) {
    if (nilai <= 0) {
      continue; // skip negative and zero values
    }
    totalPositif += nilai;
    print('  Add $nilai → total = $totalPositif');
  }

  print('  Total of positive values: $totalPositif');

  // ── Example 4: continue in a while loop ───────────────────
  print('\nExample 4: continue in while loop — skip multiples of 3');

  int n = 0;
  int dicetak = 0; // output counter to keep output manageable

  while (n < 20) {
    n++;
    if (n % 3 == 0) {
      continue; // skip multiples of 3, jump back to while condition check
    }
    // Only reaches here if n is not a multiple of 3
    if (dicetak < 8) {
      // Limit output to avoid being too long
      stdout.write('  $n ');
      dicetak++;
    }
  }
  print('\n  (multiples of 3 are skipped: 3, 6, 9, 12, ...)');

  print('');
}

// ============================================================
// Helper — Format Rupiah
// ============================================================

/// Formats an integer into a simple Rupiah currency string.
///
/// Example: `1000000` → `"1.000.000"`
///
/// This is a private helper (name starts with `_`) used by the
/// demos above. It does not need to be accessed from outside this file.
String _formatRupiah(int jumlah) {
  // Convert to string then add a dot every 3 digits from the right
  String str = jumlah.toString();
  String hasil = '';
  int counter = 0;

  for (int i = str.length - 1; i >= 0; i--) {
    if (counter > 0 && counter % 3 == 0) {
      hasil = '.$hasil'; // add dot every 3 digits
    }
    hasil = str[i] + hasil;
    counter++;
  }

  return hasil;
}
