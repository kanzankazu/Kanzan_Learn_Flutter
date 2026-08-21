// ============================================================
// PHASE 0 — Collections (List, Map, Set)
// ============================================================
// Purpose: Get familiar with the three main collection types in Dart:
//          - List  → ordered sequence, allows duplicates, access by index
//          - Map   → key-value pairs, access by key
//          - Set   → unique values only, supports set operations
//
//          Each collection is demonstrated from creation,
//          CRUD operations, through conversion between types.
//
// How to run: dart run lib/phase0/05_collections/collections_demo.dart
// ============================================================

void main() {
  print('=== Collections Demo ===\n');

  _demoList();
  _demoListTypeSafe();
  _demoMap();
  _demoMapTypeSafe();
  _demoSet();
  _demoKonversiCollection();
}

// ============================================================
// DEMO 1 — List (Dynamic)
// ============================================================

/// Demo of basic [List] operations in Dart.
///
/// A List is an **ordered** collection that can contain **duplicates**.
/// Elements are accessed via **index** starting from 0.
///
/// Analogy: think of a list as a queue — there is an order, the same
/// person can appear more than once, and access is by queue number.
void _demoList() {
  print('--- List ---');

  // ── Ways to create a List ────────────────────────────────────
  // 1. List literal — the most common way
  List buah = ['Apel', 'Mangga', 'Jeruk'];

  // 2. Empty list — can be filled later
  List daftarKosong = [];

  // 3. Using the `List()` constructor (rarely used)
  // List buahLain = List.empty(growable: true); // growable so items can be added

  print('Example 1: Create a List');
  print('  buah       : $buah');
  print('  daftarKosong: $daftarKosong');

  // ── length — number of elements ─────────────────────────────
  // `length` returns the number of elements in the list
  print('\nExample 2: length');
  print('  buah.length = ${buah.length}');
  print('  daftarKosong.length = ${daftarKosong.length}');

  // ── add — append one element at the end ──────────────────────
  // `add(item)` appends the item to the very end of the list
  print('\nExample 3: add()');
  buah.add('Pisang');
  buah.add('Semangka');
  print('  After add Pisang & Semangka: $buah');

  // ── addAll — add multiple elements at once ───────────────────
  // `addAll(iterable)` appends all elements from another collection
  daftarKosong.addAll(['Satu', 'Dua', 'Tiga']);
  print('\n  daftarKosong after addAll: $daftarKosong');

  // ── access by index ──────────────────────────────────────────
  // Index starts at 0. Last index = `length - 1`
  // ⚠️  Out-of-bounds index → RangeError (runtime crash)
  print('\nExample 4: Access element by index');
  print('  buah[0]  = ${buah[0]}');  // first element
  print('  buah[2]  = ${buah[2]}');  // third element
  print('  buah.first = ${buah.first}'); // shortcut for index 0
  print('  buah.last  = ${buah.last}');  // shortcut for last index

  // ── contains — check if element exists ───────────────────────
  // `contains(item)` returns true if item exists in the list
  print('\nExample 5: contains()');
  print('  contains("Apel")   = ${buah.contains("Apel")}');
  print('  contains("Durian") = ${buah.contains("Durian")}');

  // ── remove — delete by value ──────────────────────────────────
  // `remove(item)` removes the **first occurrence** of the item found
  // Returns `true` if successful, `false` if not found
  print('\nExample 6: remove() — delete by value');
  print('  Before remove Jeruk: $buah');
  bool berhasil = buah.remove('Jeruk');
  print('  Result of remove("Jeruk"): $berhasil');
  print('  After remove Jeruk : $buah');

  // ── removeAt — delete by index ────────────────────────────────
  // `removeAt(index)` removes the element at the given index position
  // Returns the removed element
  print('\nExample 7: removeAt() — delete by index');
  print('  Before removeAt(1): $buah');
  var dihapus = buah.removeAt(1); // remove element at index 1
  print('  Removed element : $dihapus');
  print('  After removeAt(1) : $buah');

  // ── insert — add at a specific position ──────────────────────
  // `insert(index, item)` inserts an item at the given index position
  print('\nExample 8: insert() — insert at a specific position');
  buah.insert(1, 'Anggur'); // insert "Anggur" at index 1
  print('  After insert(1, "Anggur"): $buah');

  // ── iterate using for-in ──────────────────────────────────────
  // The cleanest way to iterate over all elements
  print('\nExample 9: Iterate with for-in');
  for (var item in buah) {
    print('  🍎 $item');
  }

  // ── iterate using forEach + lambda ───────────────────────────
  // Alternative with a lambda — often used for one-liners
  print('\nExample 10: Iterate with forEach');
  buah.forEach((item) => print('  → $item'));

  // ── iterate with index using a for loop ──────────────────────
  // When you need the index while iterating, use a classic for loop
  print('\nExample 11: Iterate with index');
  for (int i = 0; i < buah.length; i++) {
    print('  [$i] ${buah[i]}');
  }

  // ── indexOf — find element position ──────────────────────────
  // `indexOf(item)` returns the first index found, or -1 if not present
  print('\nExample 12: indexOf()');
  print('  indexOf("Apel")   = ${buah.indexOf("Apel")}');
  print('  indexOf("Durian") = ${buah.indexOf("Durian")} (not found → -1)');

  // ── sort — sort the list ──────────────────────────────────────
  // `sort()` sorts in-place (the original list is modified)
  print('\nExample 13: sort()');
  print('  Before sort: $buah');
  buah.sort(); // alphabetical sort for Strings
  print('  After sort : $buah');

  // ── reversed — reverse the order ─────────────────────────────
  // `reversed` returns an Iterable, not a List — call `.toList()` to convert
  print('\nExample 14: reversed');
  List buahTerbalik = buah.reversed.toList();
  print('  buah reversed: $buahTerbalik');
  print('  Original buah (unchanged): $buah'); // sort() was in-place, reversed is not

  // ── clear — remove all elements ──────────────────────────────
  // `clear()` empties the list — length becomes 0
  print('\nExample 15: clear()');
  List sementara = ['a', 'b', 'c'];
  print('  Before clear: $sementara (length: ${sementara.length})');
  sementara.clear();
  print('  After clear : $sementara (length: ${sementara.length})');

  print('');
}

// ============================================================
// DEMO 2 — List Type-Safe
// ============================================================

/// Demo of [List] with a declared element type (generic).
///
/// `List<T>` means the list can only contain elements of type `T`.
/// Dart will error at **compile time** if you try to insert the
/// wrong type — safer than an untyped List.
///
/// When to use a type-safe list?
/// → **Always!** This is best practice. Untyped (dynamic) lists should be
/// avoided unless mixed types are genuinely needed.
void _demoListTypeSafe() {
  print('--- List Type-Safe ---');

  // ── List<String> — can only hold Strings ─────────────────────
  List<String> namaKota = ['Jakarta', 'Bandung', 'Surabaya'];

  print('Example 1: List<String>');
  print('  namaKota: $namaKota');

  namaKota.add('Yogyakarta');
  // namaKota.add(123); // compile-time ERROR: int cannot go into List<String>
  print('  After add "Yogyakarta": $namaKota');

  // All String operations are available because the type is already known
  // No manual casting needed like (namaKota[0] as String).toUpperCase()
  List<String> kotaUpper = namaKota.map((kota) => kota.toUpperCase()).toList();
  print('  Uppercase: $kotaUpper');

  // ── List<int> — can only hold integers ───────────────────────
  List<int> nilaiUjian = [85, 72, 90, 68, 95];

  print('\nExample 2: List<int>');
  print('  nilaiUjian: $nilaiUjian');

  // Because the type is int, numeric operations work directly
  int total = 0;
  for (int nilai in nilaiUjian) {
    total += nilai; // no casting needed
  }
  double rataRata = total / nilaiUjian.length;

  print('  Total  : $total');
  print('  Average: ${rataRata.toStringAsFixed(2)}');

  // reduce — combine all elements into a single value
  // `reduce` is great for sum, max, min, etc.
  int nilaiMax = nilaiUjian.reduce((a, b) => a > b ? a : b);
  int nilaiMin = nilaiUjian.reduce((a, b) => a < b ? a : b);
  print('  Max score: $nilaiMax');
  print('  Min score: $nilaiMin');

  // ── List<double> — can only hold doubles ─────────────────────
  List<double> suhu = [36.5, 37.1, 36.8, 38.2, 36.9];

  print('\nExample 3: List<double>');
  print('  Patient temperatures: $suhu');

  // where — filter elements based on a condition
  List<double> demam = suhu.where((s) => s >= 38.0).toList();
  print('  Fever temperatures (≥38°C): $demam');

  // ── List<bool> — boolean list example ────────────────────────
  List<bool> jawabanBenar = [true, false, true, true, false];

  print('\nExample 4: List<bool>');
  print('  Answers: $jawabanBenar');

  int jumlahBenar = jawabanBenar.where((j) => j).length;
  print('  Correct count: $jumlahBenar / ${jawabanBenar.length}');

  // ── List<List<int>> — nested list (2D array) ──────────────────
  // Lists can be nested! This is like a matrix/table
  List<List<int>> matrik = [
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9],
  ];

  print('\nExample 5: List<List<int>> — 3×3 matrix');
  for (int i = 0; i < matrik.length; i++) {
    print('  Row $i: ${matrik[i]}');
  }
  print('  Element [1][2] = ${matrik[1][2]}'); // row 1, column 2 = 6

  print('');
}

// ============================================================
// DEMO 3 — Map (Dynamic)
// ============================================================

/// Demo of basic [Map] operations in Dart.
///
/// A Map is a **key-value pair** collection (like a dictionary).
/// Every key is unique — no duplicates allowed. Values can repeat.
/// Elements are accessed by key, not by index.
///
/// Analogy: a Map is like a dictionary — look up a word (key) and get its
/// meaning (value). Or like a national ID — the ID number (key) is unique,
/// but the name (value) can be shared.
void _demoMap() {
  print('--- Map ---');

  // ── Ways to create a Map ─────────────────────────────────────
  // 1. Map literal — the most common way
  Map profil = {
    'nama': 'Faisal',
    'umur': 27,
    'kota': 'Jakarta',
  };

  // 2. Empty Map
  Map dataKosong = {};

  print('Example 1: Create a Map');
  print('  profil    : $profil');
  print('  dataKosong: $dataKosong');

  // ── Access value by key ───────────────────────────────────────
  // `map[key]` returns the value or NULL if the key is not found
  // ⚠️  Use null-safe access: map[key] can be null!
  print('\nExample 2: Access value by key');
  print('  profil["nama"]    = ${profil["nama"]}');
  print('  profil["umur"]    = ${profil["umur"]}');
  print('  profil["email"]   = ${profil["email"]}'); // null because key doesn't exist

  // Null-safe access: use ?? to provide a default value
  String email = (profil['email'] ?? 'No email') as String;
  print('  email (null-safe) = $email');

  // ── Add a new entry ───────────────────────────────────────────
  // Just assign to a new key — if the key already exists, its value is updated
  print('\nExample 3: Add a new entry');
  profil['pekerjaan'] = 'Android Developer';
  profil['kota'] = 'Bandung'; // update the existing 'kota' value
  print('  After adding pekerjaan & updating kota: $profil');

  // ── putIfAbsent — add only if key doesn't already exist ──────
  // `putIfAbsent(key, () => value)` will NOT override an existing value
  // Useful for setting defaults — safe from accidental overrides
  print('\nExample 4: putIfAbsent()');
  profil.putIfAbsent('nama', () => 'Default Name');   // NOT changed (already exists)
  profil.putIfAbsent('email', () => 'faisal@email.com'); // ADDED (does not exist yet)
  print('  nama (already exists, not overridden) = ${profil["nama"]}');
  print('  email (newly added)                   = ${profil["email"]}');

  // ── containsKey and containsValue ────────────────────────────
  // Check whether a specific key or value exists in the map
  print('\nExample 5: containsKey() and containsValue()');
  print('  containsKey("nama")     = ${profil.containsKey("nama")}');
  print('  containsKey("hobi")     = ${profil.containsKey("hobi")}');
  print('  containsValue("Faisal") = ${profil.containsValue("Faisal")}');
  print('  containsValue("Budi")   = ${profil.containsValue("Budi")}');

  // ── remove — delete an entry by key ──────────────────────────
  // `remove(key)` deletes the entry and returns its value
  // Returns null if the key is not found
  print('\nExample 6: remove()');
  print('  Before remove "kota": $profil');
  var nilaiDihapus = profil.remove('kota');
  print('  Removed value   : $nilaiDihapus');
  print('  After remove "kota": $profil');

  // ── keys, values, entries ────────────────────────────────────
  // Access all keys, all values, or all key-value pairs
  print('\nExample 7: keys, values, entries');
  print('  keys   : ${profil.keys}');
  print('  values : ${profil.values}');

  // ── Iterate using .entries ────────────────────────────────────
  // `entries` produces an Iterable<MapEntry> — each entry has .key and .value
  print('\nExample 8: Iterate with .entries');
  for (var entry in profil.entries) {
    print('  ${entry.key.toString().padRight(12)} : ${entry.value}');
  }

  // ── Iterate directly over keys ────────────────────────────────
  print('\nExample 9: Iterate with .keys');
  for (var key in profil.keys) {
    print('  $key → ${profil[key]}');
  }

  // ── length ────────────────────────────────────────────────────
  print('\nExample 10: length');
  print('  profil.length = ${profil.length}');

  // ── update — update an existing value ────────────────────────
  // `update(key, (oldValue) => newValue)` transforms the current value
  print('\nExample 11: update()');
  profil.update('umur', (umurLama) => (umurLama as int) + 1); // increment age by 1
  print('  Age after update: ${profil["umur"]}');

  print('');
}

// ============================================================
// DEMO 4 — Map Type-Safe
// ============================================================

/// Demo of [Map] with declared key and value types (generic).
///
/// `Map<K, V>` means keys are of type `K` and values are of type `V`.
/// Like `List<T>`, this is safer and performs better
/// because Dart doesn't need to box/unbox dynamic types.
///
/// Most common in Android/Flutter: `Map<String, dynamic>` for JSON parsing,
/// `Map<String, int>` for counting, `Map<String, String>` for lookup tables.
void _demoMapTypeSafe() {
  print('--- Map Type-Safe ---');

  // ── Map<String, int> — String key, int value ──────────────────
  // Example use case: count word/grade frequencies
  Map<String, int> frekuensiNilai = {
    'A': 5,
    'B': 8,
    'C': 12,
    'D': 3,
    'E': 2,
  };

  print('Example 1: Map<String, int> — grade frequency');
  print('  frekuensiNilai: $frekuensiNilai');

  // Because values are int, numeric operations work directly
  int totalSiswa = frekuensiNilai.values.reduce((a, b) => a + b);
  print('  Total students: $totalSiswa');

  // Find the grade with the highest frequency
  String nilaiTerbanyak = frekuensiNilai.entries
      .reduce((a, b) => a.value > b.value ? a : b)
      .key;
  print('  Most common grade: $nilaiTerbanyak (${frekuensiNilai[nilaiTerbanyak]} students)');

  // ── Map<String, String> — String key, String value ───────────
  // Example use case: lookup table (translations, country codes, etc.)
  Map<String, String> kodeNegara = {
    'ID': 'Indonesia',
    'US': 'Amerika Serikat',
    'JP': 'Jepang',
    'MY': 'Malaysia',
    'SG': 'Singapura',
  };

  print('\nExample 2: Map<String, String> — country codes');
  // Access with null-safe because map[key] can be null
  String? negara = kodeNegara['ID'];
  print('  Code "ID" = ${negara ?? "not found"}');
  print('  Code "AU" = ${kodeNegara["AU"] ?? "not found"}');

  // Loop and format output
  print('\n  Country list:');
  kodeNegara.forEach((kode, nama) {
    print('  $kode → $nama');
  });

  // ── Map<String, List<String>> — value is a List ───────────────
  // Values can be complex types, like a list inside a map
  Map<String, List<String>> hobi = {
    'Faisal': ['Coding', 'Gaming', 'Badminton'],
    'Budi'  : ['Membaca', 'Hiking'],
    'Rina'  : ['Memasak', 'Fotografi', 'Yoga'],
  };

  print('\nExample 3: Map<String, List<String>> — hobbies per person');
  for (var entry in hobi.entries) {
    print('  ${entry.key.padRight(8)}: ${entry.value.join(", ")}');
  }

  // Add a new hobby for Faisal
  hobi['Faisal']?.add('Reading'); // null-safe: if key is null, no error
  print('\n  Faisal\'s hobbies after adding one: ${hobi["Faisal"]}');

  // ── Map<int, String> — int key ────────────────────────────────
  // Keys can also be int — example: error codes mapped to error messages
  Map<int, String> pesanError = {
    200: 'OK - Success',
    400: 'Bad Request - Invalid request',
    401: 'Unauthorized - Not logged in',
    404: 'Not Found - Data not found',
    500: 'Internal Server Error - Server error',
  };

  print('\nExample 4: Map<int, String> — HTTP status codes');
  List<int> statusYangDicek = [200, 404, 500, 403];
  for (int kode in statusYangDicek) {
    // containsKey before access — or use ?? for a default
    String pesan = pesanError[kode] ?? 'Unknown status code';
    print('  $kode: $pesan');
  }

  print('');
}

// ============================================================
// DEMO 5 — Set
// ============================================================

/// Demo of basic [Set] operations in Dart.
///
/// A Set is a collection that only stores **unique values**.
/// - No duplicates — identical elements are stored only once
/// - No guaranteed order (unlike List)
/// - No index-based access — use `.contains()` or iterate
///
/// Advantages over List:
/// - `.contains()` is faster O(1) vs List O(n)
/// - Auto-deduplicates when adding elements
///
/// Analogy: a Set is like a guest list — the same name can only
/// appear once, no matter how many times it is added.
void _demoSet() {
  print('--- Set ---');

  // ── Ways to create a Set ─────────────────────────────────────
  // 1. Set literal — use `{}` but without keys (different from Map)
  Set<String> bahasaPemrograman = {'Dart', 'Kotlin', 'Swift', 'Python'};

  // 2. Empty Set — MUST use `<Type>{}` or `Set<Type>()`
  // Because `{}` alone is interpreted as an empty Map literal by Dart!
  Set<int> angkaKosong = <int>{};
  // or: Set<int> angkaKosong = Set<int>();

  print('Example 1: Create a Set');
  print('  bahasaPemrograman: $bahasaPemrograman');
  print('  angkaKosong      : $angkaKosong');

  // ── Auto-deduplicate — duplicates are ignored ─────────────────
  // This is the main feature of a Set! Adding an existing element → ignored
  print('\nExample 2: Auto-deduplicate');
  Set<String> anggotas = {'Ali', 'Budi', 'Citra', 'Ali', 'Deni', 'Budi'};
  // Even though Ali and Budi are added twice, the Set stores them only once
  print('  Input  : Ali, Budi, Citra, Ali, Deni, Budi');
  print('  Result : $anggotas');
  print('  Length : ${anggotas.length} (not 6, but ${anggotas.length})');

  // ── add — add one element ─────────────────────────────────────
  // `add(item)` returns true if successfully added, false if already present
  print('\nExample 3: add()');
  bool berhasil1 = bahasaPemrograman.add('JavaScript'); // new → true
  bool berhasil2 = bahasaPemrograman.add('Dart');       // already exists → false
  print('  add("JavaScript") = $berhasil1 (successfully added)');
  print('  add("Dart")       = $berhasil2 (already exists, ignored)');
  print('  Set now           : $bahasaPemrograman');

  // ── addAll ────────────────────────────────────────────────────
  bahasaPemrograman.addAll(['Go', 'Rust', 'Dart']); // 'Dart' will be ignored
  print('\n  After addAll(["Go", "Rust", "Dart"]): $bahasaPemrograman');

  // ── remove ────────────────────────────────────────────────────
  // `remove(item)` deletes an item — no index needed since Set is unordered
  print('\nExample 4: remove()');
  bahasaPemrograman.remove('Python');
  print('  After remove "Python": $bahasaPemrograman');

  // ── contains ──────────────────────────────────────────────────
  // O(1) — much faster than List.contains() which is O(n)
  print('\nExample 5: contains()');
  print('  contains("Dart")   = ${bahasaPemrograman.contains("Dart")}');
  print('  contains("Python") = ${bahasaPemrograman.contains("Python")}');

  // ── Set Operations: union, intersection, difference ───────────
  // This is the main advantage of Set over List!
  Set<int> himpunanA = {1, 2, 3, 4, 5};
  Set<int> himpunanB = {3, 4, 5, 6, 7};

  print('\nExample 6: Set operations');
  print('  A = $himpunanA');
  print('  B = $himpunanB');

  // union — all elements from both A and B (no duplicates)
  // A ∪ B — everything that is in A OR in B
  Set<int> gabungan = himpunanA.union(himpunanB);
  print('\n  A ∪ B (union)       = $gabungan');

  // intersection — elements present in BOTH sets
  // A ∩ B — only what is in A AND in B at the same time
  Set<int> irisan = himpunanA.intersection(himpunanB);
  print('  A ∩ B (intersection)= $irisan');

  // difference — elements in A but NOT in B
  // A − B — only what is in A, removing anything that is also in B
  Set<int> selisih = himpunanA.difference(himpunanB);
  Set<int> selisihBA = himpunanB.difference(himpunanA);
  print('  A − B (difference)  = $selisih');
  print('  B − A (difference)  = $selisihBA');

  // ── Real-world use case: collect unique tags from all articles ──
  print('\nExample 7: Use case — collect unique tags from articles');
  List<List<String>> tagsPerArtikel = [
    ['flutter', 'dart', 'mobile'],
    ['dart', 'programming', 'tutorial'],
    ['flutter', 'ui', 'mobile'],
    ['programming', 'tips', 'dart'],
  ];

  Set<String> semuaTag = {};
  for (var tags in tagsPerArtikel) {
    semuaTag.addAll(tags); // duplicates are automatically ignored
  }
  print('  All unique tags: $semuaTag');
  print('  Number of unique tags: ${semuaTag.length}');

  // ── length, isEmpty, isNotEmpty ───────────────────────────────
  print('\nExample 8: length, isEmpty, isNotEmpty');
  print('  bahasaPemrograman.length    = ${bahasaPemrograman.length}');
  print('  angkaKosong.isEmpty         = ${angkaKosong.isEmpty}');
  print('  bahasaPemrograman.isNotEmpty = ${bahasaPemrograman.isNotEmpty}');

  print('');
}

// ============================================================
// DEMO 6 — Converting Between Collections
// ============================================================

/// Demo of converting between the three collection types: [List], [Set], [Map].
///
/// Frequently needed in real code — for example:
/// - Got data from an API as a List, but want to check for duplicates → toSet()
/// - Have a Set, but need an ordered result → toList()
/// - List of pairs → turn into a Map for key-based access
///
/// Dart provides built-in methods for all of these conversions.
void _demoKonversiCollection() {
  print('--- Converting Between Collections ---');

  // ── List → Set (deduplicate) ──────────────────────────────────
  // `list.toSet()` automatically removes duplicates
  print('Example 1: List → Set (remove duplicates)');
  List<String> listDenganDuplikat = ['apel', 'mangga', 'apel', 'jeruk', 'mangga', 'pisang'];
  print('  Original list : $listDenganDuplikat (${listDenganDuplikat.length} elements)');

  Set<String> setUnik = listDenganDuplikat.toSet();
  print('  Resulting set : $setUnik (${setUnik.length} unique elements)');

  // ── Set → List ────────────────────────────────────────────────
  // `set.toList()` converts a Set to a List — can be sorted and indexed
  // ⚠️  Set order is not guaranteed — sort after converting if order matters
  print('\nExample 2: Set → List (can be sorted)');
  Set<int> setAngka = {5, 2, 8, 1, 9, 3};
  print('  Original set : $setAngka');

  List<int> listDariSet = setAngka.toList();
  print('  Resulting list : $listDariSet (not necessarily sorted)');

  listDariSet.sort(); // sort after converting
  print('  After sort: $listDariSet');

  // ── List → deduplicated List (shortcut) ───────────────────────
  // Common pattern: remove duplicates from a list using toSet().toList()
  print('\nExample 3: List → deduplicated List (toSet().toList())');
  List<int> nomorLotere = [7, 12, 7, 3, 12, 5, 3, 9];
  List<int> nomorUnik = nomorLotere.toSet().toList();
  print('  Input  : $nomorLotere');
  print('  Unique : $nomorUnik');

  // ── Map → List (keys/values/entries) ─────────────────────────
  // Map has `.keys.toList()`, `.values.toList()`, `.entries.toList()`
  print('\nExample 4: Map → List (keys, values, entries)');
  Map<String, int> skorPemain = {
    'Alice': 1250,
    'Bob'  : 980,
    'Carol': 1450,
    'Dave' : 760,
  };

  List<String> daftarNama = skorPemain.keys.toList();
  List<int> daftarSkor = skorPemain.values.toList();

  print('  keys.toList()   : $daftarNama');
  print('  values.toList() : $daftarSkor');

  // entries.toList() → List<MapEntry<K, V>>
  List<MapEntry<String, int>> entries = skorPemain.entries.toList();
  // Sort entries by value (score) — descending
  entries.sort((a, b) => b.value.compareTo(a.value));
  print('\n  Ranking by score:');
  for (int i = 0; i < entries.length; i++) {
    print('  ${i + 1}. ${entries[i].key.padRight(8)} → ${entries[i].value}');
  }

  // ── List<Map> — list of maps (most common from APIs) ──────────
  // This is the data format you'll encounter most often from JSON APIs!
  print('\nExample 5: List<Map> — data format from a JSON API');
  List<Map<String, dynamic>> produk = [
    {'id': 1, 'nama': 'Laptop', 'harga': 15000000},
    {'id': 2, 'nama': 'Mouse',  'harga': 250000},
    {'id': 3, 'nama': 'Keyboard', 'harga': 450000},
  ];

  print('  Product data:');
  for (var p in produk) {
    print('  #${p["id"]} ${(p["nama"] as String).padRight(10)} '
        'Rp ${_formatRibuan(p["harga"] as int)}');
  }

  // Extract only product names → List<String>
  List<String> namaProduk = produk.map((p) => p['nama'] as String).toList();
  print('\n  Product names only: $namaProduk');

  // Filter expensive products (> 500,000)
  List<Map<String, dynamic>> produkMahal = produk
      .where((p) => (p['harga'] as int) > 500000)
      .toList();
  print('  Expensive products : ${produkMahal.map((p) => p["nama"]).toList()}');

  // ── Map from List (with asMap and fromIterables) ──────────────
  print('\nExample 6: List → Map');

  // asMap() → Map<int, T> using the index as key
  List<String> hari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'];
  Map<int, String> hariDenganIndex = hari.asMap();
  print('  asMap() → index as key: $hariDenganIndex');

  // Map.fromIterables — combine two lists into a Map
  List<String> kunci = ['nama', 'umur', 'kota'];
  List<dynamic> nilai = ['Faisal', 27, 'Jakarta'];
  Map<String, dynamic> petaData = Map.fromIterables(kunci, nilai);
  print('\n  Map.fromIterables: $petaData');

  // Map.fromEntries — from a List<MapEntry>
  List<MapEntry<String, int>> listEntry = [
    MapEntry('satu', 1),
    MapEntry('dua', 2),
    MapEntry('tiga', 3),
  ];
  Map<String, int> petaDariEntry = Map.fromEntries(listEntry);
  print('\n  Map.fromEntries: $petaDariEntry');

  print('');
  print('✅ All collection demos complete!');
  print('   Summary:');
  print('   - List  → ordered, allows duplicates, access by index');
  print('   - Map   → key-value pairs, access by key, keys are unique');
  print('   - Set   → unique values only, supports set operations');
}

// ============================================================
// Helper — Format Number with Thousands Separator
// ============================================================

/// Formats an integer as a string with dot-separated thousands groups.
///
/// Example: `15000000` → `"15.000.000"`
String _formatRibuan(int angka) {
  String str = angka.toString();
  String hasil = '';
  int counter = 0;

  for (int i = str.length - 1; i >= 0; i--) {
    if (counter > 0 && counter % 3 == 0) {
      hasil = '.$hasil';
    }
    hasil = str[i] + hasil;
    counter++;
  }

  return hasil;
}
