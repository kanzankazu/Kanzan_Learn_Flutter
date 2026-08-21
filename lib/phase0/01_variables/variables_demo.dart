// ============================================================
// PHASE 0 — Variables & Data Types
// ============================================================
// Purpose: Learn all basic Dart data types, variable declaration
//          (explicit, inferred, immutable), string interpolation,
//          and the concept of null safety.
// How to run: dart run lib/phase0/01_variables/variables_demo.dart
// ============================================================

void main() {
  print('=== Variables & Data Types Demo ===\n');

  _demoTipeEksplisit();
  _demoTipeInferensi();
  _demoImmutable();
  _demoStringInterpolation();
  _demoNullSafety();
}

// ============================================================
// DEMO 1 — Explicit Types
// ============================================================

/// Demo variable declaration with explicit types (type annotation).
///
/// Dart is a *type-safe* language — meaning the compiler knows
/// the type of every variable at compile time. Writing types
/// explicitly makes code easier to read and understand.
///
/// Basic Dart types:
/// - [int]    → whole numbers (no decimal point)
/// - [double] → decimal numbers (with floating point)
/// - [String] → text / characters
/// - [bool]   → true or false value
void _demoTipeEksplisit() {
  print('--- Explicit Types ---');

  // int: whole number, cannot store decimal values
  int umur = 25;
  int tahunLahir = 1999;
  print('int   → umur = $umur, tahunLahir = $tahunLahir');

  // double: decimal / floating-point number
  double tinggi = 175.5;
  double beratBadan = 70.0; // .0 is valid for whole numbers
  print('double→ tinggi = $tinggi cm, berat = $beratBadan kg');

  // String: text, wrapped in single or double quotes
  String nama = 'Faisal';
  String kota = "Bandung"; // double quotes are also valid
  print('String→ nama = $nama, kota = $kota');

  // bool: only two values, true or false
  bool isLoggedIn = true;
  bool sudahMakan = false;
  print('bool  → isLoggedIn = $isLoggedIn, sudahMakan = $sudahMakan');

  print(''); // section separator
}

// ============================================================
// DEMO 2 — Type Inference
// ============================================================

/// Demo variable declaration with compiler type inference.
///
/// Dart can infer (guess) the type of a variable from the value
/// given at declaration. There are two ways:
///
/// - `var`     → type is determined by the compiler at compile time.
///               Once set, the type CANNOT change.
/// - `dynamic` → type can change at any time during runtime.
///               Avoid unless truly necessary, as it disables
///               type-safety.
void _demoTipeInferensi() {
  print('--- Type Inference ---');

  // var: compiler automatically knows this is an int because the value is 42
  var jumlah = 42;
  print('var int    → jumlah = $jumlah (${jumlah.runtimeType})');

  // var: compiler automatically knows this is a String
  var pesan = 'Halo Dart!';
  print('var String → pesan = $pesan (${pesan.runtimeType})');

  // var: compiler automatically knows this is a double
  var harga = 15000.50;
  print('var double → harga = $harga (${harga.runtimeType})');

  // ⚠️ var CANNOT change type — this line would cause an error:
  // jumlah = 'teks'; // ERROR: A value of type 'String' can't be assigned to 'int'

  // dynamic: type can change at any time — use with caution!
  dynamic nilaiFleksibel = 100;
  print('\ndynamic initially int    → $nilaiFleksibel (${nilaiFleksibel.runtimeType})');

  nilaiFleksibel = 'now a String'; // valid for dynamic
  print('dynamic changed to String → $nilaiFleksibel (${nilaiFleksibel.runtimeType})');

  nilaiFleksibel = true; // changes again to bool
  print('dynamic changed to bool   → $nilaiFleksibel (${nilaiFleksibel.runtimeType})');

  print('');
}

// ============================================================
// DEMO 3 — Immutable: final & const
// ============================================================

/// Demo immutable variables (cannot be changed after being set).
///
/// Dart has two ways to create variables with a fixed value:
///
/// - `final` → value is set ONCE at runtime.
///             Suitable for values only known when the program
///             runs (e.g.: result of a function, user input).
///
/// - `const` → value must be known at COMPILE TIME.
///             Suitable for fixed constants (e.g.: Pi, MAX_SIZE).
///             More efficient because the value is "baked in" at compile time.
///
/// Tip: use `const` whenever possible, use `final` when the value
/// is only known at runtime.
void _demoImmutable() {
  print('--- Immutable: final & const ---');

  // final: set once at runtime
  final String namaUser = 'Faisal Bahri';
  final tanggalDaftar = DateTime.now(); // DateTime is only known at runtime
  print('final → namaUser     = $namaUser');
  print('final → tanggalDaftar = $tanggalDaftar');

  // ⚠️ final CANNOT be changed after being set:
  // namaUser = 'Budi'; // ERROR: The final variable 'namaUser' can only be set once.

  // const: must be known at compile time — value stays the same forever
  const double pi = 3.14159265358979;
  const int maksKoneksi = 10;
  const String appName = 'Kanzan Learn Flutter';
  print('\nconst → pi           = $pi');
  print('const → maksKoneksi  = $maksKoneksi');
  print('const → appName      = $appName');

  // ⚠️ const CANNOT use runtime values:
  // const waktuSekarang = DateTime.now(); // ERROR: cannot be const

  // Key difference between final and const:
  // - final: a List's contents can be mutated (add/remove), but the reference cannot be reassigned
  // - const: the List is truly immutable, contents cannot be mutated at all
  final List<String> daftarFinal = ['apel', 'jeruk'];
  daftarFinal.add('mangga'); // OK! List contents can still be changed
  print('\nfinal List (contents can be changed) → $daftarFinal');

  // ignore: prefer_const_declarations
  const List<String> daftarConst = ['merah', 'biru'];
  // daftarConst.add('hijau'); // ERROR: Cannot add to an unmodifiable list
  print('const List (contents CANNOT be changed) → $daftarConst');

  print('');
}

// ============================================================
// DEMO 4 — String Interpolation
// ============================================================

/// Demo string interpolation — a way to embed variables/expressions
/// inside a String without needing concatenation (`+`).
///
/// Dart provides two syntaxes:
/// - `'$variable'`    → for simple variables
/// - `'${expression}'`  → for expressions/property access/method calls
///
/// String interpolation is much cleaner than:
/// `'Hello ' + nama + ', age ' + umur.toString() + ' years old'`
void _demoStringInterpolation() {
  print('--- String Interpolation ---');

  String nama = 'Faisal';
  int umur = 25;
  double ipk = 3.85;
  bool lulus = true;

  // $variable syntax — for simple variables
  print('\$variabel  → "Halo, \$nama!"');
  print('Result     → "Halo, $nama!"');

  // ${expression} syntax — for expressions or property access
  print('\n\${expression}:');
  print('Age next year        → ${umur + 1} years old');
  print('GPA rounded          → ${ipk.toStringAsFixed(1)}');
  print('Graduation status    → ${lulus ? "Passed ✓" : "Not Yet ✗"}');
  print('Name uppercase       → ${nama.toUpperCase()}');
  print('Name length          → ${nama.length} characters');

  // Multi-line string with triple quotes
  String biodata = '''
Name  : $nama
Age   : $umur years old
GPA   : $ipk
Status: ${lulus ? 'Passed' : 'Not Yet Passed'}
''';
  print('\nMulti-line string:\n$biodata');

  // Raw string — \n, \t, etc. are NOT processed (prefixed with r'...')
  String pathWindows = r'C:\Users\Faisal\Documents';
  print('Raw string (r"..."): $pathWindows');

  print('');
}

// ============================================================
// DEMO 5 — Null Safety
// ============================================================

/// Demo null safety — one of the most important features of modern Dart.
///
/// Before Dart 2.12, any variable could be null, which often caused
/// NullPointerExceptions. Dart is now *null-safe* by default —
/// variables CANNOT be null unless we explicitly allow it.
///
/// Important symbols:
/// - `String`  → CANNOT be null (non-nullable)
/// - `String?` → CAN be null (nullable)
/// - `??`      → "if null, use this default value"
/// - `?.`      → access property only if not null
/// - `!`       → force non-null assertion (be careful, can crash!)
void _demoNullSafety() {
  print('--- Null Safety ---');

  // Non-nullable: String MUST have a value, cannot be null
  String namaMustNonNull = 'Faisal';
  print('Non-nullable String  → "$namaMustNonNull" (cannot be null)');

  // ⚠️ This line would ERROR at compile time:
  // String namaNonNull = null; // ERROR: A value of type 'Null' can't be assigned to 'String'

  // Nullable: String? is allowed to be null
  String? namaBolehNull = 'Budi';
  print('Nullable String?     → "$namaBolehNull"');

  namaBolehNull = null; // valid!
  print('Nullable after null  → $namaBolehNull');

  // Operator ?? (null coalescing) — "if null, use default"
  String? nickname = null;
  String tampilNickname = nickname ?? 'Anonymous User';
  print('\nOperator ??:');
  print('nickname             → $nickname');
  print('nickname ?? default  → $tampilNickname');

  // Operator ??= (assign if null)
  String? kota;
  kota ??= 'Jakarta'; // only assigned if kota is still null
  print('\nOperator ??=:');
  print('kota after ??=       → $kota');

  kota ??= 'Bandung'; // does not change because kota already has a value
  print('kota ??= again       → $kota (unchanged)');

  // Operator ?. (null-aware access) — access property only if not null
  String? email = 'faisal@example.com';
  print('\nOperator ?.:');
  print('email?.toUpperCase() → ${email?.toUpperCase()}');

  email = null;
  print('null?.toUpperCase()  → ${email?.toUpperCase()} (no crash!)');

  // Operator ! (null assertion) — force non-null
  // ONLY use when you are 100% certain the value is not null
  String? nilaiPasti = 'Value is definitely here';
  String hasilPasti = nilaiPasti!; // safe because nilaiPasti is definitely not null
  print('\nOperator ! (null assertion):');
  print('nilaiPasti!          → "$hasilPasti"');
  print('⚠️  Do not use ! without being sure — can crash if the value turns out to be null!');

  // Example of null check before access (the safe way)
  String? inputUser = null;
  if (inputUser != null) {
    print('\ninputUser != null: ${inputUser.toUpperCase()}');
  } else {
    print('\ninputUser is null — null check block runs safely');
  }

  print('');
}
