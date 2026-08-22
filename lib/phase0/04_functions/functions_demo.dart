// ============================================================
// PHASE 0 — Function
// ============================================================
// Purpose: Explore the various types and variations of functions in Dart —
//          from regular functions, arrow functions, different kinds
//          of parameters, anonymous functions, higher-order functions,
//          to recursive functions.
//          Each concept is demonstrated with real-world examples
//          that are easy to understand for beginners.
//
// How to run: dart run lib/phase0/04_functions/functions_demo.dart
// ============================================================

void main() {
  print('=== Function Demo ===\n');

  _demoRegularFunction();
  _demoArrowFunction();
  _demoPositionalParameter();
  _demoNamedParameter();
  _demoDefaultParameter();
  _demoAnonymousFunction();
  _demoHigherOrderFunction();
  _demoRecursiveFunction();
}

// ============================================================
// DEMO 1 — Regular Function with Explicit Return Type
// ============================================================

/// Demo of a regular function with the return type written
/// explicitly in front of the function name.
///
/// Structure:
/// ```dart
/// ReturnType functionName(ParamType paramName) {
///   // function body
///   return value;
/// }
/// ```
///
/// Best practice: **always write an explicit return type** so code
/// is easier to read and Dart can catch bugs earlier.
///
/// Examples: `String`, `int`, `double`, `bool`, `void` (returns nothing).
void _demoRegularFunction() {
  print('--- Regular Function with Explicit Return Type ---');

  // ── Example 1: Calculate the area of a rectangle ────────────
  // Return type: double — the function returns a decimal value
  print('Example 1: Calculate rectangle area');
  double luas = hitungLuas(panjang: 8.0, lebar: 4.5);
  print('  Rectangle area 8 × 4.5 = $luas');

  // ── Example 2: Check whether a number is odd or even ────────
  // Return type: bool — the function returns true/false
  print('\nExample 2: Check even number');
  for (int angka in [2, 7, 12, 15]) {
    bool genap = adalahGenap(angka);
    print('  $angka → ${genap ? "even ✅" : "odd ❌"}');
  }

  // ── Example 3: Greeting with String return type ──────────────
  // Return type: String — the function returns text
  print('\nExample 3: Function that returns a String');
  String sapaan = buatSapaan('Faisal', 'morning');
  print('  $sapaan');

  // ── Example 4: Void function — returns no value ──────────────
  // `void` means this function only performs an action, no return value
  print('\nExample 4: void function (returns nothing)');
  tampilkanGaris(panjang: 20, karakter: '-');

  print('');
}

/// Calculates the area of a rectangle.
///
/// [panjang] is the length of the horizontal side in the same unit.
/// [lebar] is the length of the vertical side in the same unit.
///
/// Returns the area as a [double].
double hitungLuas({required double panjang, required double lebar}) {
  return panjang * lebar;
}

/// Checks whether [angka] is an even number.
///
/// Returns `true` if [angka] is divisible by 2, `false` otherwise.
bool adalahGenap(int angka) {
  // Modulo 2: if remainder = 0, the number is even
  return angka % 2 == 0;
}

/// Creates a greeting sentence based on [nama] and [waktu] (morning/afternoon/evening).
///
/// Returns a [String] greeting appropriate for the time of day.
String buatSapaan(String nama, String waktu) {
  return 'Good $waktu, $nama! Keep learning Dart! 🚀';
}

/// Prints a horizontal line to the console.
///
/// [panjang] determines how many characters are printed.
/// [karakter] is the character to repeat (default `-`).
void tampilkanGaris({required int panjang, String karakter = '-'}) {
  // String.fromCharCodes can't be used directly — use this approach instead
  print('  ${karakter * panjang}');
}

// ============================================================
// DEMO 2 — Arrow Function `=>`
// ============================================================

/// Demo of arrow functions — shorthand for functions with **a single expression**.
///
/// Structure:
/// ```dart
/// ReturnType functionName(params) => expression;
/// ```
///
/// The arrow `=>` automatically `return`s the result of the expression on its right.
/// Ideal for short one-liner functions — no need for `{}` or `return`.
///
/// ⚠️  Only works for **one expression**, not multiple statements.
/// If you need more than one line of logic, stick with `{}`.
void _demoArrowFunction() {
  print('--- Arrow Function `=>` ---');

  // ── Example 1: Simple math operations ───────────────────────
  print('Example 1: Math operations with arrow functions');
  print('  kuadrat(5)       = ${kuadrat(5)}');
  print('  kubik(3)         = ${kubik(3)}');
  print('  absolutNilai(-7) = ${absolutNilai(-7)}');

  // ── Example 2: Arrow function returning bool ─────────────────
  print('\nExample 2: Condition checks with arrow functions');
  print('  adalahPositif(10)           = ${adalahPositif(10)}');
  print('  adalahPositif(-5)           = ${adalahPositif(-5)}');
  print('  adalahPanjangMin5("Halo")   = ${adalahPanjangMin5("Halo")}');
  print('  adalahPanjangMin5("Hello World") = ${adalahPanjangMin5("Hello World")}');

  // ── Example 3: Arrow function stored in a variable ──────────
  // Arrow functions can be stored in variables (function expressions)
  print('\nExample 3: Arrow function stored in a variable');
  // The variable type is a "function signature" — int Function(int, int)
  int Function(int, int) tambah = (a, b) => a + b;
  int Function(int, int) kali = (a, b) => a * b;

  print('  tambah(3, 4) = ${tambah(3, 4)}');
  print('  kali(3, 4)   = ${kali(3, 4)}');

  print('');
}

/// Calculates the square of [n] (n to the power of 2).
/// Example: `kuadrat(4)` → `16`
int kuadrat(int n) => n * n;

/// Calculates the cube of [n] (n to the power of 3).
/// Example: `kubik(3)` → `27`
int kubik(int n) => n * n * n;

/// Returns the absolute value of [n] (always positive).
/// Example: `absolutNilai(-7)` → `7`
int absolutNilai(int n) => n < 0 ? -n : n;

/// Checks whether [angka] is a positive number (greater than 0).
bool adalahPositif(int angka) => angka > 0;

/// Checks whether [teks] has a minimum length of 5 characters.
bool adalahPanjangMin5(String teks) => teks.length >= 5;

// ============================================================
// DEMO 3 — Positional Parameter
// ============================================================

/// Demo of positional parameters — parameters filled in **based on their
/// position** when calling the function.
///
/// Types:
/// - **Required positional**: must be provided, just write the type directly
/// - **Optional positional**: optional, wrapped in `[ ]`
///
/// Structure:
/// ```dart
/// // Required positional:
/// void foo(String name, int age) { ... }
/// foo('Budi', 25); // order must match!
///
/// // Optional positional:
/// void bar(String name, [int? age]) { ... }
/// bar('Budi');        // age = null
/// bar('Budi', 25);    // age = 25
/// ```
void _demoPositionalParameter() {
  print('--- Positional Parameter ---');

  // ── Example 1: Required positional parameters ────────────────
  // All parameters must be filled in; order MUST match the definition
  print('Example 1: Required positional parameters');
  String hasil1 = perkenalan('Faisal', 27, 'Android Developer');
  print('  $hasil1');

  // Trying a different order would cause a type mismatch error!
  // perkenalan(27, 'Faisal', 'Android Developer'); // ERROR: type mismatch
  // That's the downside of positional parameters → easy to get order wrong

  // ── Example 2: Optional positional parameter [ ] ─────────────
  // Parameters in [ ] are optional — value is null (or default) if not provided
  print('\nExample 2: Optional positional parameters');

  // Call with all parameters
  String hasil2a = buatAlamat('Jl. Merdeka No. 1', 'Jakarta', 'Indonesia');
  print('  Full    : $hasil2a');

  // Call without the optional parameter (negara = null)
  String hasil2b = buatAlamat('Jl. Sudirman No. 5', 'Bandung');
  print('  Without country: $hasil2b');

  print('');
}

/// Creates an introduction sentence from [nama], [umur], and [pekerjaan].
///
/// This is an example of **required positional parameters** — all must be
/// provided in the correct order when calling the function.
String perkenalan(String nama, int umur, String pekerjaan) {
  return 'Name: $nama | Age: $umur | Job: $pekerjaan';
}

/// Creates an address string from the given components.
///
/// [jalan] and [kota] are required positional.
/// [negara] is an optional positional — can be omitted (null).
///
/// Examples:
/// ```dart
/// buatAlamat('Jl. Merdeka', 'Jakarta');               // without country
/// buatAlamat('Jl. Merdeka', 'Jakarta', 'Indonesia');  // full address
/// ```
String buatAlamat(String jalan, String kota, [String? negara]) {
  // If negara is not provided, display without it
  if (negara != null) {
    return '$jalan, $kota, $negara';
  }
  return '$jalan, $kota';
}

// ============================================================
// DEMO 4 — Named Parameter
// ============================================================

/// Demo of named parameters — parameters filled in **by name**,
/// not position. Safer and more readable when a function has
/// many parameters.
///
/// Types:
/// - `{required Type name}` → must be provided, write the name when calling
/// - `{Type? name}` → optional, null if not provided
///
/// Structure:
/// ```dart
/// void foo({required String name, int? age}) { ... }
/// foo(name: 'Budi');            // age null
/// foo(name: 'Budi', age: 25);   // any order allowed!
/// foo(age: 25, name: 'Budi');   // same result ✅
/// ```
///
/// Advantage vs positional: **order doesn't matter** and **code is more readable**.
void _demoNamedParameter() {
  print('--- Named Parameter ---');

  // ── Example 1: required named parameters ─────────────────────
  print('Example 1: required named parameters');

  // Write the parameter name when calling — order can be anything
  String profil = buatProfilUser(
    nama: 'Faisal Bahri',
    email: 'kanzankazu46@gmail.com',
    umur: 27,
  );
  print('  $profil');

  // Different order — still correct because we use named parameters!
  String profil2 = buatProfilUser(
    umur: 25,
    nama: 'Budi Santoso',
    email: 'budi@example.com',
  );
  print('  $profil2');

  // ── Example 2: optional named parameters ─────────────────────
  print('\nExample 2: optional named parameters (nullable)');

  // Call with all parameters
  String produk1 = deskripsiProduk(
    nama: 'Gaming Laptop',
    harga: 15000000,
    diskon: 10.0,
    catatan: 'Limited stock',
  );
  print('  Full product: $produk1');

  // Call without optional parameters — diskon and catatan are null
  String produk2 = deskripsiProduk(nama: 'Wireless Mouse', harga: 250000);
  print('  Minimal product: $produk2');

  print('');
}

/// Creates a user profile string from the given data.
///
/// All parameters are **required named** — must be provided when calling.
/// Advantage: the calling code is more readable and order-independent.
String buatProfilUser({
  required String nama,
  required String email,
  required int umur,
}) {
  return 'Profile → Name: $nama | Email: $email | Age: $umur';
}

/// Creates a product description with several optional parameters.
///
/// [nama] and [harga] are required.
/// [diskon] and [catatan] are optional (nullable).
///
/// If [diskon] is provided, the discounted price will be calculated.
String deskripsiProduk({
  required String nama,
  required int harga,
  double? diskon,
  String? catatan,
}) {
  // Format price with thousands separator
  String hargaStr = 'Rp ${_formatAngka(harga)}';

  String info = '$nama | $hargaStr';

  // Append discount info if provided
  if (diskon != null) {
    double hargaDiskon = harga * (1 - diskon / 100);
    info += ' | Discount $diskon% → Rp ${_formatAngka(hargaDiskon.round())}';
  }

  // Append note if provided
  if (catatan != null) {
    info += ' | ⚠️  $catatan';
  }

  return info;
}

// ============================================================
// DEMO 5 — Default Parameter Value
// ============================================================

/// Demo of default parameter values — providing a fallback value for
/// parameters that are not supplied when calling the function.
///
/// Applies to:
/// - Named parameters: `{String color = 'red'}`
/// - Optional positional parameters: `[String color = 'red']`
///
/// ⚠️  Default values must be **compile-time constants**.
/// You cannot use `DateTime.now()` or `List()` as defaults.
///
/// Difference from nullable:
/// - `{String? name}` → value is null if not provided (needs null check)
/// - `{String name = ''}` → value is '' if not provided (no null check needed)
void _demoDefaultParameter() {
  print('--- Default Parameter Value ---');

  // ── Example 1: Default value in named parameters ─────────────
  print('Example 1: Default value in named parameters');

  // Not filling `karakter` and `lebar` → use default values
  String garis1 = buatGaris();
  print('  Default   : "$garis1"');

  // Fill `karakter` but not `lebar` → lebar uses default (20)
  String garis2 = buatGaris(karakter: '=');
  print('  karakter= : "$garis2"');

  // Fill all
  String garis3 = buatGaris(karakter: '*', lebar: 10);
  print('  Custom    : "$garis3"');

  // ── Example 2: Default value in optional positional parameters ─
  print('\nExample 2: Default value in optional positional parameters');

  // Not filling optional parameters — all use defaults
  String kopi1 = pesanKopi('Americano');
  print('  Order   : $kopi1');

  // Fill all
  String kopi2 = pesanKopi('Latte', 'large', 2, false);
  print('  Order   : $kopi2');

  // ── Example 3: Mix required + default ────────────────────────
  print('\nExample 3: Mix of required + default values');

  // [nama] is required, the rest use defaults
  String sambutan1 = sambut('Faisal');
  print('  $sambutan1');

  // Override defaults for waktu and formality
  String sambutan2 = sambut('Mr. Budi', waktu: 'afternoon', formal: true);
  print('  $sambutan2');

  print('');
}

/// Creates a line with customizable character and width.
///
/// If not provided, [karakter] defaults to `'-'` and [lebar] to `20`.
///
/// Examples:
/// ```dart
/// buatGaris();                        // "--------------------"
/// buatGaris(karakter: '=');           // "===================="
/// buatGaris(karakter: '*', lebar: 5); // "*****"
/// ```
String buatGaris({String karakter = '-', int lebar = 20}) {
  // The * operator on String repeats it n times
  return karakter * lebar;
}

/// Creates a coffee order string with size, sugar, and milk options.
///
/// [jenis] is a required positional.
/// [ukuran], [sendokGula], and [pakaiSusu] are optional with defaults.
String pesanKopi(
  String jenis, [
  String ukuran = 'medium',
  int sendokGula = 1,
  bool pakaiSusu = true,
]) {
  // Build the description based on parameters
  String susu = pakaiSusu ? 'with milk' : 'no milk';
  return '$jenis ($ukuran) | $sendokGula tsp sugar | $susu';
}

/// Creates a greeting sentence based on [nama] and preferences.
///
/// [nama] is a required named parameter.
/// [waktu] defaults to `'morning'`, [formal] defaults to `false`.
String sambut(
  String nama, {
  String waktu = 'morning',
  bool formal = false,
}) {
  // Use different greeting depending on `formal`
  String sapaan = formal ? 'Good $waktu, Dear $nama.' : 'Hey $nama! Good $waktu 👋';
  return sapaan;
}

// ============================================================
// DEMO 6 — Anonymous Function / Lambda
// ============================================================

/// Demo of anonymous functions (functions without a name) — often called
/// **lambdas** or **closures** in other languages.
///
/// Structure:
/// ```dart
/// (params) {
///   // function body
/// }
/// // or the arrow version:
/// (params) => expression
/// ```
///
/// Key trait: no name — used directly inline or stored in a variable.
///
/// When to use anonymous functions?
/// - Callbacks that are only used once
/// - Arguments to higher-order functions (`.map`, `.where`, `.forEach`, etc.)
/// - Simple event handlers
void _demoAnonymousFunction() {
  print('--- Anonymous Function / Lambda ---');

  // ── Example 1: Anonymous function stored in a variable ───────
  print('Example 1: Anonymous function stored in a variable');

  // The variable type is written explicitly: `Function(params) returnType`
  int Function(int, int) tambahDua = (int a, int b) {
    // This is an anonymous function — it has no name
    return a + b;
  };

  // Arrow version of the same function
  int Function(int, int) kaliDua = (int a, int b) => a * b;

  print('  tambahDua(3, 4) = ${tambahDua(3, 4)}');
  print('  kaliDua(3, 4)   = ${kaliDua(3, 4)}');

  // ── Example 2: Lambda directly as an argument ────────────────
  // This is the most common use! e.g., `.forEach()` takes a function
  print('\nExample 2: Lambda as an argument to .forEach()');

  List<String> buah = ['Apple', 'Mango', 'Orange', 'Banana'];

  // Lambda directly inside .forEach() — no need to define a separate function
  buah.forEach((item) {
    print('  🍑 $item');
  });

  // ── Example 3: Lambda in .map() for transformation ───────────
  print('\nExample 3: Lambda in .map() — transform a list into a new list');

  List<int> angka = [1, 2, 3, 4, 5];

  // Multiply each element by 10, result is a new list
  List<int> dikali10 = angka.map((n) => n * 10).toList();
  print('  Original : $angka');
  print('  × 10     : $dikali10');

  // Convert to uppercase with map
  List<String> buahUpper = buah.map((b) => b.toUpperCase()).toList();
  print('  Fruits uppercase: $buahUpper');

  // ── Example 4: Lambda in .where() for filtering ──────────────
  print('\nExample 4: Lambda in .where() — filter elements');

  List<int> nilaiUjian = [55, 78, 90, 42, 85, 68, 73];

  // Filter only values >= 70 (passing grade)
  List<int> lulus = nilaiUjian.where((nilai) => nilai >= 70).toList();
  print('  All scores   : $nilaiUjian');
  print('  Passing (≥70): $lulus');

  print('');
}

// ============================================================
// DEMO 7 — Higher-Order Function
// ============================================================

/// Demo of higher-order functions — functions that **accept another function**
/// as an argument, or **return a function** as a result.
///
/// This is a fundamental concept in functional programming.
///
/// Why is it useful?
/// - Code becomes more flexible — behavior can be swapped from outside
/// - Avoids code duplication where only one part of the logic differs
/// - Foundation for patterns like callbacks, event handlers, middleware
void _demoHigherOrderFunction() {
  print('--- Higher-Order Function ---');

  // ── Example 1: Accept a function as a parameter ──────────────
  print('Example 1: Function that accepts another function as an argument');

  List<int> angka = [3, 7, 1, 9, 4, 6, 2, 8, 5];
  print('  Original list: $angka');

  // We have one `filterList` function that can be used
  // with different conditions — the condition is passed as a function!
  List<int> lebihDari5 = filterList(angka, (n) => n > 5);
  List<int> bilGenap = filterList(angka, (n) => n % 2 == 0);
  List<int> kurangDari4 = filterList(angka, (n) => n < 4);

  print('  > 5    : $lebihDari5');
  print('  Even   : $bilGenap');
  print('  < 4    : $kurangDari4');

  // ── Example 2: Apply an operation to every element ───────────
  print('\nExample 2: Apply an operation to all elements in a list');

  List<int> nilai = [10, 20, 30, 40, 50];
  print('  Original list: $nilai');

  // Different operations, same function (`terapkanOperasi`)
  List<int> ditambah5 = terapkanOperasi(nilai, (n) => n + 5);
  List<int> dikuadrat = terapkanOperasi(nilai, (n) => n * n);
  List<String> dijadikanStr = terapkanOperasiStr(nilai, (n) => 'Value: $n');

  print('  +5        : $ditambah5');
  print('  Squared   : $dikuadrat');
  print('  To String : $dijadikanStr');

  // ── Example 3: Function that RETURNS a function ──────────────
  print('\nExample 3: Function that returns a function (factory)');

  // `buatPengganda` returns a new function that multiplies by n
  Function(int) kali3 = buatPengganda(3);
  Function(int) kali7 = buatPengganda(7);

  print('  kali3(5)  = ${kali3(5)}');
  print('  kali3(10) = ${kali3(10)}');
  print('  kali7(4)  = ${kali7(4)}');

  // ── Example 4: Run a function with logging ───────────────────
  print('\nExample 4: Wrapper function — run + log execution');

  // `jalankanDenganLog` accepts a function and an operation name
  jalankanDenganLog('Calculate total', () {
    int total = 0;
    for (int i = 1; i <= 100; i++) {
      total += i;
    }
    print('    Result: $total');
  });

  print('');
}

/// Filters elements from [list] using the provided [kondisi].
///
/// [kondisi] is a function that takes an `int` and returns a `bool`.
/// Elements for which [kondisi] returns `true` are included in the result.
///
/// This is a higher-order function — `kondisi` is a function passed as a parameter.
///
/// Example:
/// ```dart
/// filterList([1, 2, 3, 4, 5], (n) => n > 3); // [4, 5]
/// ```
List<int> filterList(List<int> list, bool Function(int) kondisi) {
  List<int> hasil = [];
  for (int item in list) {
    if (kondisi(item)) {
      // Call the `kondisi` function with the current item
      hasil.add(item);
    }
  }
  return hasil;
}

/// Applies [operasi] to each element of [list] and returns a new list.
///
/// [operasi] is a transformation function: takes an `int`, returns an `int`.
List<int> terapkanOperasi(List<int> list, int Function(int) operasi) {
  List<int> hasil = [];
  for (int item in list) {
    hasil.add(operasi(item)); // transform each element
  }
  return hasil;
}

/// A version of [terapkanOperasi] that returns a `List<String>`.
///
/// [operasi] transforms an `int` into a `String`.
List<String> terapkanOperasiStr(List<int> list, String Function(int) operasi) {
  return list.map(operasi).toList();
}

/// Creates and returns a multiplier function with factor [n].
///
/// This is a function that **returns a function** — often called a
/// "function factory" or "closure".
///
/// Example:
/// ```dart
/// var kali5 = buatPengganda(5);
/// kali5(3); // → 15
/// kali5(4); // → 20
/// ```
Function(int) buatPengganda(int n) {
  // The returned function "remembers" the value of n (closure)
  return (int x) => x * n;
}

/// Runs [aksi] and logs the operation name around it.
///
/// Useful for wrapping: adds behavior (logging) without modifying
/// the body of the function being executed.
void jalankanDenganLog(String namaOperasi, void Function() aksi) {
  print('  ▶ Running: $namaOperasi');
  aksi(); // call the received function
  print('  ✅ Done: $namaOperasi');
}

// ============================================================
// DEMO 8 — Recursive Function
// ============================================================

/// Demo of recursive functions — functions that **call themselves**
/// to solve a problem that can be broken down into smaller,
/// similar sub-problems.
///
/// Every recursive function must have:
/// 1. **Base case** — the stopping condition. Without this → infinite recursion → crash!
/// 2. **Recursive case** — the function calls itself with a smaller input.
///
/// ⚠️  Be careful: deep recursion can cause a Stack Overflow.
/// In Dart, use it wisely — more than ~10,000 levels can crash.
void _demoRecursiveFunction() {
  print('--- Recursive Function ---');

  // ── Example 1: Factorial ──────────────────────────────────
  // Factorial: n! = n × (n-1) × (n-2) × ... × 1
  // Base case: 0! = 1
  print('Example 1: Factorial');

  for (int n in [0, 1, 5, 7, 10]) {
    print('  $n! = ${faktorial(n)}');
  }

  // ── Example 2: Fibonacci ──────────────────────────────────
  // Fibonacci: fib(n) = fib(n-1) + fib(n-2)
  // Base case: fib(0) = 0, fib(1) = 1
  print('\nExample 2: Fibonacci');

  for (int n in [0, 1, 2, 5, 8, 10]) {
    print('  fib($n) = ${fibonacci(n)}');
  }

  // Print the first 10 Fibonacci numbers
  print('\n  Fibonacci sequence index 0 to 9:');
  List<int> deret = List.generate(10, (i) => fibonacci(i));
  print('  $deret');

  // ── Example 3: Power (exponentiation) ───────────────────
  print('\nExample 3: Calculate exponents recursively');
  print('  2^10 = ${pangkat(2, 10)}');
  print('  3^5  = ${pangkat(3, 5)}');
  print('  5^3  = ${pangkat(5, 3)}');

  // ── Example 4: Sum of digits ─────────────────────────────
  print('\nExample 4: Sum all digits of a number');
  print('  jumlahDigit(12345) = ${jumlahDigit(12345)}'); // 1+2+3+4+5 = 15
  print('  jumlahDigit(9999)  = ${jumlahDigit(9999)}');  // 9+9+9+9 = 36
  print('  jumlahDigit(100)   = ${jumlahDigit(100)}');   // 1+0+0 = 1

  print('');
}

/// Calculates the factorial of [n] recursively.
///
/// Factorial: `n! = n × (n-1)!`
/// Base case: `0! = 1`
///
/// Example: `faktorial(5)` = `5 × 4 × 3 × 2 × 1` = `120`
///
/// ⚠️  Only valid for [n] >= 0.
int faktorial(int n) {
  // Base case: 0! = 1 (stop here)
  if (n <= 0) return 1;

  // Recursive case: n! = n × (n-1)!
  // The function calls itself with n-1 (a smaller value)
  return n * faktorial(n - 1);
}

/// Calculates the [n]th Fibonacci number recursively.
///
/// Fibonacci: `fib(n) = fib(n-1) + fib(n-2)`
/// Base case: `fib(0) = 0`, `fib(1) = 1`
///
/// Sequence: 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, ...
///
/// ⚠️  This implementation is exponential O(2^n) — for large values
/// use dynamic programming or memoization instead.
int fibonacci(int n) {
  // Base case: two stopping conditions
  if (n == 0) return 0;
  if (n == 1) return 1;

  // Recursive case: sum of the two preceding Fibonacci numbers
  return fibonacci(n - 1) + fibonacci(n - 2);
}

/// Calculates [basis] to the power of [eksponen] recursively.
///
/// Formula: `basis^n = basis × basis^(n-1)`
/// Base case: `basis^0 = 1`
///
/// Example: `pangkat(2, 10)` = `1024`
int pangkat(int basis, int eksponen) {
  // Base case: anything to the power of 0 = 1
  if (eksponen == 0) return 1;

  // Recursive case: multiply basis by basis^(eksponen-1)
  return basis * pangkat(basis, eksponen - 1);
}

/// Sums all digits of [angka] recursively.
///
/// Formula: `jumlahDigit(n) = (n % 10) + jumlahDigit(n ~/ 10)`
/// Base case: `n < 10` → return the number itself (single digit)
///
/// Example: `jumlahDigit(123)` = `1 + 2 + 3` = `6`
int jumlahDigit(int angka) {
  // Ensure the number is positive
  if (angka < 0) angka = -angka;

  // Base case: single digit — return directly
  if (angka < 10) return angka;

  // Recursive case:
  // - `angka % 10` → get the last digit (e.g. 123 % 10 = 3)
  // - `angka ~/ 10` → drop the last digit (e.g. 123 ~/ 10 = 12)
  return (angka % 10) + jumlahDigit(angka ~/ 10);
}

// ============================================================
// Helper — Format Number (thousands separator with dot)
// ============================================================

/// Formats an integer into a thousands-separated string.
///
/// Example: `15000000` → `"15.000.000"`
String _formatAngka(int angka) {
  String str = angka.toString();
  String hasil = '';
  int counter = 0;

  for (int i = str.length - 1; i >= 0; i--) {
    if (counter > 0 && counter % 3 == 0) {
      hasil = '.$hasil'; // add a dot every 3 digits from the right
    }
    hasil = str[i] + hasil;
    counter++;
  }

  return hasil;
}
