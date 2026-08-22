// ============================================================
// PHASE 0 — Operators
// ============================================================
// Purpose: Explore all types of operators in Dart — arithmetic,
//          assignment, comparison, logical, and null-aware.
//          Each category is demonstrated with real-world examples
//          that are easy for beginners to understand.
// How to run: dart run lib/phase0/02_operators/operators_demo.dart
// ============================================================

void main() {
  print('=== Operators Demo ===\n');

  _demoAritmatika();
  _demoAssignment();
  _demoPerbandingan();
  _demoLogika();
  _demoNullAware();
}

// ============================================================
// DEMO 1 — Arithmetic Operators
// ============================================================

/// Demo arithmetic operators — basic math operations in Dart.
///
/// Available operators:
/// - `+`  → addition
/// - `-`  → subtraction
/// - `*`  → multiplication
/// - `/`  → division (always returns a [double])
/// - `~/` → integer division (result is [int], remainder discarded)
/// - `%`  → modulo / remainder
///
/// Tips: Use `~/` when you need a whole number result (e.g., counting pages,
/// splitting items into groups), and `%` to check even/odd numbers.
void _demoAritmatika() {
  print('--- Arithmetic Operators ---');

  int a = 17;
  int b = 5;

  // Addition
  print('$a + $b  = ${a + b}');

  // Subtraction
  print('$a - $b  = ${a - b}');

  // Multiplication
  print('$a * $b  = ${a * b}');

  // Division — always returns double, even if divisible evenly
  // Example: 10 / 2 = 5.0 (not 5)
  print('$a / $b  = ${a / b}   (result is double: ${(a / b).runtimeType})');

  // Integer division — discards the remainder, result is int
  // Example: 17 ~/ 5 = 3 (remainder 2 is discarded)
  print('$a ~/ $b = ${a ~/ b}    (int result, remainder discarded)');

  // Modulo — remainder from integer division
  // Example: 17 % 5 = 2 (because 17 = 5×3 + 2)
  print('$a % $b  = ${a % b}     (remainder of $a divided by $b)');

  print('\nPractical examples:');

  // Check whether a number is even or odd using modulo
  int angka = 24;
  bool isGenap = angka % 2 == 0;
  print('  $angka % 2 == 0  → isEven = $isGenap');

  // Calculate number of pages from total items
  int totalItem = 47;
  int itemPerHalaman = 10;
  int totalHalaman = (totalItem + itemPerHalaman - 1) ~/ itemPerHalaman; // ceiling division
  print('  $totalItem items, $itemPerHalaman per page → $totalHalaman pages');

  print('');
}

// ============================================================
// DEMO 2 — Assignment Operators
// ============================================================

/// Demo assignment operators — ways to set and update variable values.
///
/// Available operators:
/// - `=`   → simple assignment
/// - `+=`  → add then assign (shorthand: `a = a + x`)
/// - `-=`  → subtract then assign (shorthand: `a = a - x`)
/// - `*=`  → multiply then assign (shorthand: `a = a * x`)
/// - `/=`  → divide then assign (shorthand: `a = a / x`, result is double)
/// - `??=` → assign ONLY if the variable is currently null
///
/// Compound assignment operators (`+=`, `-=`, etc.) make code
/// shorter and easier to read.
void _demoAssignment() {
  print('--- Assignment Operators ---');

  // = (simple assignment)
  int skor = 0;
  print('Initial : skor = $skor');

  // += (add then store back)
  skor += 10; // equivalent to: skor = skor + 10
  print('+= 10   : skor = $skor');

  // -= (subtract then store back)
  skor -= 3; // equivalent to: skor = skor - 3
  print('-= 3    : skor = $skor');

  // *= (multiply then store back)
  skor *= 2; // equivalent to: skor = skor * 2
  print('*= 2    : skor = $skor');

  // /= (divide then store back — result becomes double)
  double nilaiDouble = skor.toDouble();
  nilaiDouble /= 4; // equivalent to: nilaiDouble = nilaiDouble / 4
  print('/= 4    : nilaiDouble = $nilaiDouble');

  print('\nOperator ??= (assign if null):');

  // ??= (null-aware assignment) — assigns ONLY if the variable is null
  // Very useful for lazy initialization (initialize when first needed)
  String? namaDefault;
  print('  Before ??= : namaDefault = $namaDefault');

  namaDefault ??= 'New User'; // assigned because it was null
  print('  After ??=  : namaDefault = $namaDefault');

  namaDefault ??= 'Other Name'; // NOT changed because it already has a value
  print('  ??= again  : namaDefault = $namaDefault (unchanged)');

  print('');
}

// ============================================================
// DEMO 3 — Comparison Operators
// ============================================================

/// Demo comparison operators — comparing two values.
///
/// All comparison operators return a [bool] (true/false):
/// - `==` → equal to
/// - `!=` → not equal to
/// - `>`  → greater than
/// - `<`  → less than
/// - `>=` → greater than or equal to
/// - `<=` → less than or equal to
///
/// Comparison operators are commonly used in `if`, `while` conditions,
/// and ternary expressions `condition ? trueValue : falseValue`.
void _demoPerbandingan() {
  print('--- Comparison Operators ---');

  int x = 10;
  int y = 7;
  print('x = $x, y = $y\n');

  // == (equal to)
  print('x == y  → ${x == y}   (is $x equal to $y?)');
  print('x == 10 → ${x == 10} (is $x equal to 10?)');

  // != (not equal to)
  print('x != y  → ${x != y}   (is $x not equal to $y?)');

  // > (greater than)
  print('x > y   → ${x > y}   (is $x greater than $y?)');

  // < (less than)
  print('x < y   → ${x < y}  (is $x less than $y?)');

  // >= (greater than or equal to)
  print('x >= 10 → ${x >= 10} (is $x >= 10?)');

  // <= (less than or equal to)
  print('x <= y  → ${x <= y}  (is $x <= $y?)');

  print('\nPractical example — grading system:');

  int nilaiSiswa = 78;
  String grade;

  // Using comparison operators inside if conditions
  if (nilaiSiswa >= 90) {
    grade = 'A';
  } else if (nilaiSiswa >= 80) {
    grade = 'B';
  } else if (nilaiSiswa >= 70) {
    grade = 'C';
  } else if (nilaiSiswa >= 60) {
    grade = 'D';
  } else {
    grade = 'E';
  }

  print('  Score $nilaiSiswa → Grade: $grade');

  print('');
}

// ============================================================
// DEMO 4 — Logical Operators
// ============================================================

/// Demo logical operators — combining or inverting boolean conditions.
///
/// Available operators:
/// - `&&` → AND  — true only if BOTH conditions are true
/// - `||` → OR   — true if AT LEAST ONE condition is true
/// - `!`  → NOT  — flips the boolean value (true → false, false → true)
///
/// Tips: Logical operators use *short-circuit evaluation*:
/// - `&&`: if the left side is already false, the right side is not evaluated
/// - `||`: if the left side is already true, the right side is not evaluated
/// This is useful for guard checks (check for null before accessing a property).
void _demoLogika() {
  print('--- Logical Operators ---');

  bool sudahLogin = true;
  bool punyaAksesPremium = false;
  bool sudahVerifikasi = true;

  print('isLoggedIn        = $sudahLogin');
  print('hasPremiumAccess  = $punyaAksesPremium');
  print('isVerified        = $sudahVerifikasi\n');

  // && (AND) — ALL conditions must be true
  bool bisaLihatKontenPremium = sudahLogin && punyaAksesPremium;
  print('&& (AND):');
  print('  sudahLogin && punyaAksesPremium → $bisaLihatKontenPremium');
  print('  (must be logged in AND have premium access)\n');

  // || (OR) — AT LEAST ONE condition must be true
  bool bisaMasuk = sudahLogin || sudahVerifikasi;
  print('|| (OR):');
  print('  sudahLogin || sudahVerifikasi → $bisaMasuk');
  print('  (logged in OR verified is enough)\n');

  // ! (NOT) — flips the boolean value
  bool belumLogin = !sudahLogin;
  bool belumVerifikasi = !sudahVerifikasi;
  print('! (NOT):');
  print('  !sudahLogin       → $belumLogin');
  print('  !sudahVerifikasi  → $belumVerifikasi\n');

  // Combining && and || in a real condition
  int umur = 20;
  bool punyaKTP = true;
  bool punyaSIM = false;

  // Allowed to register if: (age >= 17 AND has national ID) OR has driver's license
  bool bolehDaftar = (umur >= 17 && punyaKTP) || punyaSIM;
  print('Combined operator example:');
  print('  age=$umur, hasID=$punyaKTP, hasLicense=$punyaSIM');
  print('  (umur >= 17 && punyaKTP) || punyaSIM → $bolehDaftar');

  // Short-circuit: if the left side is sufficient, the right side is not evaluated
  String? teks = null;
  // Without short-circuit, teks.length would crash because of null
  // With &&: if teks != null is false, .length is never accessed
  bool adaTeks = teks != null && teks.length > 0;
  print('\nShort-circuit &&:');
  print('  teks = null');
  print('  teks != null && teks.length > 0 → $adaTeks (no crash!)');

  print('');
}

// ============================================================
// DEMO 5 — Null-Aware Operators
// ============================================================

/// Demo null-aware operators — working with values that might be null.
///
/// Dart has special operators for handling null gracefully:
/// - `??`  → null coalescing: use a default value if null
/// - `?.`  → null-aware access: access a member only if not null
/// - `!`   → null assertion: force non-null (use with caution!)
///
/// These operators replace verbose `if (x != null) { ... }` checks
/// with more concise and expressive code. Learn these well — you'll
/// use them constantly when working with APIs, databases,
/// and user input.
void _demoNullAware() {
  print('--- Null-Aware Operators ---');

  // ── Operator ?? (null coalescing) ──────────────────────────
  print('Operator ?? (null coalescing):');

  String? kota = null;
  // If kota is null, use 'Jakarta' as the default
  String kotaTampil = kota ?? 'Jakarta';
  print('  kota = null');
  print('  kota ?? "Jakarta"     → "$kotaTampil"');

  String? kotaAda = 'Bandung';
  String kotaAda2 = kotaAda ?? 'Jakarta'; // default not used because a value exists
  print('  kotaAda = "Bandung"');
  print('  kotaAda ?? "Jakarta"  → "$kotaAda2" (uses the original value)\n');

  // ── Operator ?. (null-aware access) ────────────────────────
  print('Operator ?. (null-aware access):');

  String? email = 'faisal@example.com';
  // Access a method/property only if the value is not null
  // If null, the result is null (no NullPointerException crash)
  String? emailUpper = email?.toUpperCase();
  print('  email = "$email"');
  print('  email?.toUpperCase()  → "$emailUpper"\n');

  String? emailNull = null;
  String? emailNullUpper = emailNull?.toUpperCase();
  print('  emailNull = null');
  print('  emailNull?.toUpperCase() → $emailNullUpper (no crash!)\n');

  // Chaining ?. — can be chained for nested property access
  List<String>? daftarNama = ['Faisal', 'Budi', 'Citra'];
  int? panjangDaftar = daftarNama?.length;
  print('  daftarNama?.length    → $panjangDaftar');

  List<String>? daftarKosong = null;
  int? panjangKosong = daftarKosong?.length;
  print('  null?.length          → $panjangKosong\n');

  // ── Operator ! (null assertion) ────────────────────────────
  print('Operator ! (null assertion):');

  // Use ! ONLY when you are 100% certain the value is not null
  // If it turns out to be null → will throw NullCheckFailure and crash the app
  String? nilaiYakin = 'Definitely exists';
  String nilaiNonNull = nilaiYakin!; // safe because nilaiYakin is not null
  print('  nilaiYakin = "$nilaiYakin"');
  print('  nilaiYakin! (non-null assertion) → "$nilaiNonNull"');
  print('  ⚠️  Avoid ! carelessly — ?? or ?. are safer!\n');

  // ── Comparison: safe vs unsafe approach ────────────────────
  print('Approach comparison:');

  String? inputUser = null;

  // Unsafe approach (can crash):
  // String result = inputUser!.toUpperCase(); // ← CRASH if null

  // Safe approach with ??
  String hasilAman1 = (inputUser ?? '').toUpperCase();
  print('  inputUser = null');
  print('  (inputUser ?? "").toUpperCase() → "$hasilAman1"');

  // Safe approach with ?.
  String? hasilAman2 = inputUser?.toUpperCase();
  print('  inputUser?.toUpperCase()        → $hasilAman2 (null, no crash)');

  // Safe approach with if-check
  if (inputUser != null) {
    print('  if (inputUser != null): ${inputUser.toUpperCase()}');
  } else {
    print('  if-check: inputUser is null → else block runs safely');
  }

  print('');
}
