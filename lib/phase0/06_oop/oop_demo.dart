// ============================================================
// PHASE 0 — OOP (Object-Oriented Programming)
// ============================================================
// Purpose: Understand OOP concepts in Dart — class, constructor,
//          inheritance, abstract class, interface,
//          getter/setter, static member, and polymorphism.
//          Each concept is demonstrated with animal examples
//          that are easy for beginners to understand.
//
// How to run: dart run lib/phase0/06_oop/oop_demo.dart
// ============================================================

void main() {
  print('=== OOP (Object-Oriented Programming) Demo ===\n');

  _demoConstructor();
  _demoGetterSetter();
  _demoInheritance();
  _demoAbstractClass();
  _demoInterface();
  _demoPolymorphism();
  _demoStaticMember();
}

// ============================================================
// CLASS HIERARCHY
// ============================================================
//
//  abstract Hewan          ← base class: suara() abstract, makan() concrete
//      │
//      ├── Anjing          ← override suara() → "Guk!"
//      │     │
//      │     └── Labrador  ← extends Anjing + implements BisaBerenang
//      │
//      └── Kucing          ← override suara() → "Meow!"
//
//  abstract BisaBerenang   ← "interface": berenang() abstract
//

// ============================================================
// ABSTRACT CLASS — Hewan
// ============================================================

/// Abstract base class representing an animal in general.
///
/// **Concepts demonstrated:**
/// - `abstract class` — cannot be instantiated directly
/// - `abstract method` — must be overridden by subclasses
/// - Concrete method — already has an implementation, ready to use
/// - Constructor with positional and named parameters
///
/// All animals can always eat, but the way they make sounds differs —
/// that's why `makan()` is concrete and `suara()` is abstract.
abstract class Hewan {
  /// The animal's name (e.g., "Rex", "Kitty").
  final String nama;

  /// The animal's age in years.
  int umur;

  // ── Positional Constructor ──────────────────────────────────
  // Regular constructor: parameters are filled in by position order.
  // `this.nama` is shorthand for `nama = namaParam`.
  /// Creates an animal with the given [nama] and [umur].
  ///
  /// This is a **positional constructor** — parameters are filled by order.
  /// Example: `Anjing('Rex', 3)`
  Hewan(this.nama, this.umur);

  // ── Named Constructor ───────────────────────────────────────
  // Dart supports multiple constructors with different names.
  // Useful for different object creation scenarios.
  /// Creates a baby animal (age 0) with the given name.
  ///
  /// This is a **named constructor** — an alternative way to create an object.
  /// Example: `Anjing.bayi('Puppy')`
  Hewan.bayi(this.nama) : umur = 0;

  // ── Abstract Method ─────────────────────────────────────────
  // Declared but NOT implemented here.
  // Every subclass MUST override this method with its own implementation.
  /// Produces the characteristic sound of this animal.
  ///
  /// This is an **abstract method** — no implementation here.
  /// Each subclass must provide its own implementation.
  String suara();

  // ── Concrete Method ─────────────────────────────────────────
  // Already has an implementation — subclasses can use it directly or override.
  /// Displays this animal's eating action.
  ///
  /// This is a **concrete method** — a default implementation already exists.
  /// Subclasses may override it, but it's not required.
  void makan() {
    print('  $nama is eating eagerly 🍖');
  }

  /// Displays complete information about this animal.
  ///
  /// Uses `suara()` which will be called polymorphically —
  /// the implementation that runs depends on the actual object type.
  @override
  String toString() {
    return '$runtimeType($nama, $umur yrs) → sound: "${suara()}"';
  }
}

// ============================================================
// ABSTRACT CLASS — BisaBerenang (used as an "interface")
// ============================================================

/// Abstract class that acts as an interface for swimming ability.
///
/// **Concepts demonstrated:**
/// - Dart has no `interface` keyword — use `abstract class` instead
/// - `implements` to implement an interface
/// - A class can `implements` multiple abstract classes (multiple interfaces)
///
/// Why abstract class instead of mixin?
/// For Phase 0 learning purposes, we use abstract class so the
/// concept is easier to understand. Mixins will be covered in Phase 1.
abstract class BisaBerenang {
  /// Displays the swimming action.
  ///
  /// Every class that `implements BisaBerenang` MUST implement
  /// this method — there is no default implementation here.
  void berenang();
}

// ============================================================
// CLASS — Anjing (extends Hewan)
// ============================================================

/// Represents a dog that inherits from [Hewan].
///
/// **Concepts demonstrated:**
/// - `extends` — inheritance from a parent class
/// - `super(...)` — call the parent constructor
/// - `@override` — marks a method being overridden
/// - Getter and setter with validation
///
/// A dog always makes the sound "Guk!" — that's the override of `suara()`.
class Anjing extends Hewan {
  // Additional field only Anjing has (not all animals)
  /// The breed of this dog (e.g., "Poodle", "Bulldog").
  final String ras;

  // Private field for getter/setter demo
  // Convention: private field names start with `_` (underscore)
  int _bobotKg;

  // ── Constructor with super() ──────────────────────────────
  // `super(nama, umur)` calls the parent constructor (Hewan).
  // Without this, Dart doesn't know how to initialize the parent fields.
  /// Creates a dog with [nama], [umur], [ras], and [bobotKg].
  ///
  /// `super(nama, umur)` → calls the [Hewan] constructor with
  /// the given name and age.
  Anjing(super.nama, super.umur, this.ras, int bobotKg) : _bobotKg = bobotKg;

  /// Named constructor to create a baby dog (age 0).
  ///
  /// Calls `Hewan.bayi(nama)` from the parent via `super.bayi(nama)`.
  Anjing.bayi(String nama, this.ras) : _bobotKg = 1, super.bayi(nama);

  // ── Override Abstract Method ────────────────────────────────
  // Required! Because `suara()` is abstract in the parent.
  // `@override` is an annotation — tells Dart we intentionally
  // override a method from the parent.
  @override
  String suara() => 'Guk! 🐕';

  // ── Getter ──────────────────────────────────────────────────
  // Getter = "computed property" — looks like a field but actually
  // runs code to get the value.
  // Syntax: `get propertyName => expression;`
  /// The dog's weight in kilograms (must be ≥ 1).
  ///
  /// This is a **getter** — accessed like a field but has logic behind it.
  /// Example: `anjing.bobotKg` → gets the value directly, not `anjing.bobotKg()`
  int get bobotKg => _bobotKg;

  // ── Setter ──────────────────────────────────────────────────
  // Setter = "property that can be set with validation".
  // Useful for maintaining invariants (values are always valid).
  // Syntax: `set propertyName(Type value) { ... }`
  /// Sets the dog's weight.
  ///
  /// This is a **setter** — write `anjing.bobotKg = 5` to call this setter.
  /// Validation: weight must be between 1 and 200 kg.
  set bobotKg(int nilai) {
    if (nilai < 1 || nilai > 200) {
      // Throw an error if the value is out of the valid range
      throw ArgumentError('Weight must be between 1-200 kg, got: $nilai');
    }
    _bobotKg = nilai;
  }

  /// Getter for the dog's size category based on weight.
  ///
  /// Computed property — value is calculated from [_bobotKg] each time it's accessed.
  String get kategoriUkuran {
    if (_bobotKg <= 5) return 'Small 🐾';
    if (_bobotKg <= 20) return 'Medium';
    return 'Large 🦴';
  }

  @override
  void makan() {
    // Override concrete method — add dog-specific behavior
    super.makan(); // still call the parent implementation
    print('  $nama wags its tail after eating! 🐾');
  }
}

// ============================================================
// CLASS — Kucing (extends Hewan)
// ============================================================

/// Represents a cat that inherits from [Hewan].
///
/// **Concepts demonstrated:**
/// - `extends` — inheritance, Kucing has everything Hewan has
/// - `@override` — override suara() with the cat's sound
/// - Multiple named constructors
///
/// Difference from Anjing: Kucing does not implement BisaBerenang
/// because cats (usually) don't like water! 🐱
class Kucing extends Hewan {
  /// The color of this cat's fur.
  final String warnaBulu;

  /// Whether this cat is a pampered/indoor cat.
  bool isPeliharaan;

  /// Creates a cat with [nama], [umur], [warnaBulu], and [isPeliharaan].
  Kucing(super.nama, super.umur, this.warnaBulu, {this.isPeliharaan = true});

  /// Named constructor for a stray cat (not a pet).
  Kucing.liar(String nama, String warnaBulu)
      : warnaBulu = warnaBulu,
        isPeliharaan = false,
        super(nama, 0);

  @override
  String suara() => 'Meow! 🐈';

  /// Displays the cat's characteristic purring action.
  void mendengkur() {
    print('  $nama: Purrr... 😻 (purring)');
  }
}

// ============================================================
// CLASS — Labrador (extends Anjing, implements BisaBerenang)
// ============================================================

/// Labrador that inherits from [Anjing] AND implements [BisaBerenang].
///
/// **Concepts demonstrated:**
/// - `extends` + `implements` at the same time — Dart supports this!
/// - Multi-level inheritance: Labrador → Anjing → Hewan
/// - `implements` requires implementing `berenang()`
/// - `super.suara()` to call the parent method
///
/// Labradors are a breed known for being great swimmers —
/// a perfect example of a class implementing BisaBerenang.
class Labrador extends Anjing implements BisaBerenang {
  /// The color of the Labrador's fur: 'black', 'yellow', or 'brown'.
  final String warnaBulu;

  /// Creates a Labrador with all required attributes.
  ///
  /// Calls the [Anjing] constructor with `ras = 'Labrador'`.
  Labrador(String nama, int umur, this.warnaBulu, int bobotKg)
      : super(nama, umur, 'Labrador', bobotKg);

  // ── BisaBerenang Implementation ───────────────────────────
  // Because Labrador `implements BisaBerenang`, it MUST implement
  // all abstract methods from BisaBerenang. Here only `berenang()`.
  @override
  void berenang() {
    print('  $nama (Labrador) dives into the water and swims powerfully! 🏊');
  }

  // Labrador makes the same sound as a regular Anjing.
  // No need to override `suara()` — inheritance from Anjing is enough.
  // But we can call `super.suara()` to demonstrate how it works:
  /// Displays the Labrador's sound with additional info.
  void gonggong() {
    // `super.suara()` calls `suara()` from the parent class (Anjing)
    print('  $nama says: ${super.suara()} (from Anjing via super)');
  }
}

// ============================================================
// STATIC MEMBER — in class PendaftaranHewan
// ============================================================

/// Utility class for animal registration.
///
/// **Concepts demonstrated:**
/// - `static` field — belongs to the CLASS, not to any instance
/// - `static` method — called without creating an object
/// - Difference between instance member and static member
///
/// Static members are accessed with the class name: `PendaftaranHewan.totalTerdaftar`
/// not with an object: ~~`pendaftaran.totalTerdaftar`~~
class PendaftaranHewan {
  // ── Static Field ────────────────────────────────────────────
  // `static` = belongs to the class, not to any specific instance.
  // All instances share the same value.
  // A change in one place is visible everywhere.
  /// Total number of registered animals. This is a **static field**.
  ///
  /// Its value is shared by ALL instances of `PendaftaranHewan`.
  /// Access: `PendaftaranHewan.totalTerdaftar` (no object needed!)
  static int totalTerdaftar = 0;

  // Static constant — a fixed value accessible without an instance
  /// Maximum shelter capacity. This is a **static constant**.
  static const int kapasitasMaksimum = 50;

  // ── Static Method ────────────────────────────────────────────
  // A method that can be called WITHOUT creating a class instance.
  // Static methods CANNOT access `this` or instance members.
  /// Registers one new animal to the shelter.
  ///
  /// This is a **static method** — called with the class name,
  /// no need to create a `PendaftaranHewan` object.
  ///
  /// Example: `PendaftaranHewan.daftarkan('Rex')` ← without `new`!
  static void daftarkan(String namaHewan) {
    if (totalTerdaftar >= kapasitasMaksimum) {
      print('  ❌ Shelter is full! Cannot register $namaHewan.');
      return;
    }
    totalTerdaftar++; // access static field from a static method
    print('  ✅ $namaHewan successfully registered. Total: $totalTerdaftar animals');
  }

  /// Displays the current shelter capacity status.
  ///
  /// Static method to display info — no instance state needed.
  static void tampilkanStatus() {
    double persensi = (totalTerdaftar / kapasitasMaksimum) * 100;
    print(
        '  📊 Shelter: $totalTerdaftar/$kapasitasMaksimum animals (${persensi.toStringAsFixed(1)}%)');
  }

  /// Resets the registration counter (e.g., for testing or annual reset).
  static void reset() {
    totalTerdaftar = 0;
    print('  🔄 Registration counter reset to 0.');
  }
}

// ============================================================
// DEMO 1 — Constructor: Positional & Named
// ============================================================

/// Demo of various constructor types in Dart.
///
/// **What is demonstrated:**
/// - Positional constructor: parameters filled in by order
/// - Named constructor: alternative constructor with a specific name
/// - `super()`: call the parent constructor
void _demoConstructor() {
  print('--- Constructor: Positional & Named ---');

  // ── Positional Constructor ──────────────────────────────────
  print('Example 1: Positional constructor');
  // Parameters filled in by order: nama, umur, ras, bobot
  var anjing1 = Anjing('Rex', 3, 'German Shepherd', 30);
  var kucing1 = Kucing('Kitty', 5, 'Orange Tabby');

  print('  Dog  : ${anjing1.nama}, ${anjing1.umur} yrs, breed: ${anjing1.ras}');
  print('  Cat  : ${kucing1.nama}, ${kucing1.umur} yrs, fur: ${kucing1.warnaBulu}');

  // ── Named Constructor ───────────────────────────────────────
  print('\nExample 2: Named constructor (.bayi, .liar)');
  // `Anjing.bayi(...)` — named constructor specifically for baby dogs
  var puppy = Anjing.bayi('Puppy', 'Poodle');
  // `Kucing.liar(...)` — named constructor for stray cats
  var kucingLiar = Kucing.liar('Tom', 'Gray');

  print('  Puppy     : ${puppy.nama}, age: ${puppy.umur} yrs (baby via .bayi())');
  print('  Stray cat : ${kucingLiar.nama}, pet: ${kucingLiar.isPeliharaan}');

  // ── Labrador — extends + super ──────────────────────────────
  print('\nExample 3: Labrador (extends Anjing, super constructor)');
  var labrador = Labrador('Buddy', 4, 'Yellow', 32);
  print('  Labrador: ${labrador.nama}, breed: ${labrador.ras}, color: ${labrador.warnaBulu}');

  print('');
}

// ============================================================
// DEMO 2 — Getter & Setter
// ============================================================

/// Demo of getters and setters in Dart.
///
/// **What is demonstrated:**
/// - Getter: access a "property" computed from a private field
/// - Setter: intercept value assignment for validation
/// - Computed property via getter
void _demoGetterSetter() {
  print('--- Getter & Setter ---');

  var anjing = Anjing('Max', 2, 'Bulldog', 15);

  // ── Getter ──────────────────────────────────────────────────
  print('Example 1: Getter');
  // Accessed like a regular field (no parentheses), but actually calls the getter
  print('  anjing.bobotKg        = ${anjing.bobotKg}');         // int getter
  print('  anjing.kategoriUkuran = ${anjing.kategoriUkuran}');  // computed getter

  // ── Setter with validation ──────────────────────────────────
  print('\nExample 2: Setter with validation');
  // Set a new value via the setter — looks like a regular assignment
  anjing.bobotKg = 18;
  print('  After bobotKg = 18 → ${anjing.bobotKg} kg (${anjing.kategoriUkuran})');

  anjing.bobotKg = 3;
  print('  After bobotKg = 3  → ${anjing.bobotKg} kg (${anjing.kategoriUkuran})');

  // ── Setter rejects invalid value ─────────────────────────────
  print('\nExample 3: Setter rejects out-of-range value');
  try {
    anjing.bobotKg = 999; // setter will throw ArgumentError
  } catch (e) {
    print('  ❌ Error: $e');
  }
  print('  Weight unchanged: ${anjing.bobotKg} kg (no change due to error)');

  print('');
}

// ============================================================
// DEMO 3 — Inheritance
// ============================================================

/// Demo of inheritance in Dart.
///
/// **What is demonstrated:**
/// - Subclass has all methods and fields from the parent
/// - Override parent method
/// - `super.method()` to call the parent implementation
void _demoInheritance() {
  print('--- Inheritance ---');

  var labrador = Labrador('Cooper', 3, 'Black', 28);

  // ── Subclass has everything from the parent ────────────────────────
  print('Example 1: Labrador has everything from Anjing + Hewan');
  // Inherited from Hewan (ancestor)
  print('  nama  (from Hewan) : ${labrador.nama}');
  print('  umur  (from Hewan) : ${labrador.umur} yrs');
  // Inherited from Anjing (direct parent)
  print('  ras   (from Anjing): ${labrador.ras}');
  print('  bobot (from Anjing): ${labrador.bobotKg} kg');
  // Field belonging to Labrador itself
  print('  color (own field)  : ${labrador.warnaBulu}');

  // ── Override method ─────────────────────────────────────────
  print('\nExample 2: Override makan() in Anjing (also calls super)');
  labrador.makan(); // calls Anjing.makan() which also calls super

  // ── super.method() ──────────────────────────────────────────
  print('\nExample 3: super.suara() — call the parent implementation');
  labrador.gonggong(); // calls super.suara() from inside Labrador

  print('');
}

// ============================================================
// DEMO 4 — Abstract Class
// ============================================================

/// Demo of abstract classes in Dart.
///
/// **What is demonstrated:**
/// - Abstract class cannot be instantiated directly
/// - Abstract methods MUST be overridden by subclasses
/// - Concrete methods from an abstract class are ready to use
void _demoAbstractClass() {
  print('--- Abstract Class ---');

  // ── Cannot create instance of abstract class ─────────────────
  print('Example 1: Abstract class cannot be instantiated');
  // The line below will ERROR if uncommented:
  // var hewan = Hewan('Unknown', 0); // ❌ ERROR: abstract class
  print('  → Hewan is an abstract class — cannot do: Hewan("x", 0)');
  print('  → Must go through a subclass: Anjing(...) or Kucing(...)');

  // ── Subclass can be instantiated ────────────────────────────
  print('\nExample 2: Subclass can be instantiated');
  var anjing = Anjing('Buddy', 2, 'Poodle', 8);
  var kucing = Kucing('Luna', 4, 'White');

  print('  ✅ Anjing: ${anjing.nama} — sound: ${anjing.suara()}');
  print('  ✅ Kucing: ${kucing.nama} — sound: ${kucing.suara()}');

  // ── Concrete method from abstract class ─────────────────────
  print('\nExample 3: Concrete method `makan()` is ready to use');
  // makan() is defined in Hewan (abstract class) but already has
  // a default implementation — used directly by all subclasses
  kucing.makan(); // Hewan.makan() because Kucing does not override it

  print('');
}

// ============================================================
// DEMO 5 — Interface (via Abstract Class)
// ============================================================

/// Demo of using abstract class as an interface in Dart.
///
/// **What is demonstrated:**
/// - `implements` to implement an "interface"
/// - A class can extends + implements at the same time
/// - Type checking: `is` keyword
void _demoInterface() {
  print('--- Interface (via Abstract Class) ---');

  var labrador = Labrador('Nemo', 2, 'Yellow', 30);
  var anjingBiasa = Anjing('Rex', 3, 'Rottweiler', 40);
  var kucing = Kucing('Whiskers', 1, 'Tabby');

  // ── implements requires implementing berenang() ───────────
  print('Example 1: Labrador implements BisaBerenang');
  labrador.berenang(); // method from BisaBerenang — must exist in Labrador

  // ── Type checking with `is` keyword ──────────────────────
  print('\nExample 2: Type checking with `is`');
  // `is` checks whether an object is of a certain type (or subtype)
  print('  labrador is Hewan        → ${labrador is Hewan}');
  print('  labrador is Anjing       → ${labrador is Anjing}');
  print('  labrador is BisaBerenang → ${labrador is BisaBerenang}');
  print('  anjingBiasa is BisaBerenang → ${anjingBiasa is BisaBerenang}'); // false!
  print('  kucing is BisaBerenang   → ${kucing is BisaBerenang}');         // false!

  // ── Call via interface type ──────────────────────────────────
  print('\nExample 3: Call via BisaBerenang interface type');
  // We can store a Labrador in a variable typed as BisaBerenang
  BisaBerenang perenang = labrador;
  perenang.berenang(); // polymorphic via interface

  print('');
}

// ============================================================
// DEMO 6 — Polymorphism
// ============================================================

/// Demo of polymorphism (many forms) in Dart.
///
/// **What is demonstrated:**
/// - Objects of different types are treated uniformly via a base type
/// - Each object responds to the same method in its own way
/// - This is the heart of powerful OOP!
///
/// Imagine: we have a mixed list of Anjing, Kucing, Labrador —
/// we can call `.suara()` on all of them without knowing the specific type.
void _demoPolymorphism() {
  print('--- Polymorphism ---');

  // ── All stored in a List<Hewan> ─────────────────────────────
  // Even though the contents are a mix of Anjing, Kucing, Labrador!
  // This works because all of them extend Hewan.
  List<Hewan> semuaHewan = [
    Anjing('Rex', 3, 'German Shepherd', 30),
    Kucing('Kitty', 5, 'Orange Tabby'),
    Labrador('Buddy', 4, 'Brown', 32),
    Kucing('Luna', 2, 'White'),
    Anjing('Max', 1, 'Poodle', 8),
  ];

  // ── Call suara() on all — different results! ─────────────────
  print('Example 1: Polymorphism — call suara() on all animals');
  print('  Each animal makes a sound according to its ACTUAL TYPE:\n');

  for (int i = 0; i < semuaHewan.length; i++) {
    Hewan h = semuaHewan[i];
    // `h.suara()` — Dart automatically calls the CORRECT implementation
    // even though variable h is typed as Hewan (abstract)
    print('  ${i + 1}. ${h.nama} (${h.runtimeType}) → ${h.suara()}');
  }

  // ── toString() is also polymorphic ───────────────────────────
  print('\nExample 2: Polymorphic toString() (via Hewan.toString())');
  for (Hewan h in semuaHewan.take(3)) {
    // toString() calls suara() — which dispatches to the correct implementation
    print('  $h'); // implicitly calls toString()
  }

  // ── Type check + specific action ─────────────────────────────
  print('\nExample 3: Check specific type and perform additional action');
  for (Hewan h in semuaHewan) {
    // If it's a Labrador (which implements BisaBerenang), take it swimming!
    if (h is BisaBerenang) {
      print('  ${h.nama} can swim:');
      (h as BisaBerenang).berenang();
    }
    // If it's a Kucing, make it purr
    if (h is Kucing) {
      h.mendengkur(); // can access Kucing methods after type check
    }
  }

  print('');
}

// ============================================================
// DEMO 7 — Static Member
// ============================================================

/// Demo of static members (class variable and class method) in Dart.
///
/// **What is demonstrated:**
/// - Static field: value is shared by all instances
/// - Static method: called without creating an object
/// - Difference between instance member and static member
void _demoStaticMember() {
  print('--- Static Member ---');

  // ── Access static member without creating an object ──────────
  print('Example 1: Access static without instantiation');
  // Notice: no `var p = PendaftaranHewan()` here!
  // Use the class name directly: `PendaftaranHewan.xxxxx`
  print('  Max capacity : ${PendaftaranHewan.kapasitasMaksimum} animals');
  print('  Initial total: ${PendaftaranHewan.totalTerdaftar} animals');

  // ── Register a few animals ───────────────────────────────────
  print('\nExample 2: Register a few animals (static counter)');
  PendaftaranHewan.daftarkan('Rex the Dog');
  PendaftaranHewan.daftarkan('Kitty the Cat');
  PendaftaranHewan.daftarkan('Buddy the Labrador');
  PendaftaranHewan.tampilkanStatus();

  // ── Static counter is shared by everyone ─────────────────────
  print('\nExample 3: Static counter is shared by all');
  // Create 2 different "managers" — but the counter stays the same!
  // (because static = belongs to the class, not to instances)
  PendaftaranHewan.daftarkan('Luna the Cat');
  PendaftaranHewan.daftarkan('Nemo the Labrador');
  PendaftaranHewan.tampilkanStatus();
  print('  ↑ totalTerdaftar = 5 no matter where it is called from');

  // ── Reset ────────────────────────────────────────────────────
  print('\nExample 4: Reset counter');
  PendaftaranHewan.reset();
  PendaftaranHewan.tampilkanStatus();

  print('');
}
