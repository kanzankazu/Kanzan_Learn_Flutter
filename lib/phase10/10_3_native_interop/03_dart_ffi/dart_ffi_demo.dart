/// Phase 10.3 — Topic 03: Dart FFI (Foreign Function Interface)
///
/// Dart FFI lets you call C libraries directly from Dart code —
/// without writing any Kotlin or Swift bridge code.
///
/// When to use FFI vs MethodChannel:
/// - FFI: call existing C/C++ library (zlib, OpenSSL, SQLite, custom SDK)
/// - FFI: performance-critical native code (image processing, crypto)
/// - MethodChannel: call platform-specific APIs (Android/iOS SDK APIs)
///
/// Key concepts covered:
/// 1. dart:ffi basics — DynamicLibrary, lookup, NativeFunction
/// 2. Pointer<T> — C pointers in Dart
/// 3. Struct — C struct mapping in Dart
/// 4. Memory management — malloc/free, Arena allocator
/// 5. Strings — converting Dart String ↔ C char*
/// 6. Callbacks — NativeCallable, Pointer.fromFunction
/// 7. ffigen — auto-generate FFI bindings from C header files
import 'package:flutter/material.dart';

void main() => runApp(const _StandaloneApp());

class _StandaloneApp extends StatelessWidget {
  const _StandaloneApp();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dart FFI Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown), useMaterial3: true),
      home: const DartFfiDemo(),
    );
  }
}

class DartFfiDemo extends StatelessWidget {
  const DartFfiDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('03 — Dart FFI'),
        backgroundColor: Colors.brown.shade700,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            color: Colors.brown.shade50,
            child: const Text(
              'Dart FFI = call C functions directly from Dart.\n\n'
              'No Kotlin/Swift wrapper needed. Load a .so (Android), .dylib (iOS/macOS), '
              'or .dll (Windows) and call functions as if they were Dart functions.',
              style: TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),

          // ── 1. Loading a C library ─────────────────────────────────────
          _header('1. Load a C Library', Colors.brown.shade700),
          _code(r'''
import 'dart:ffi';
import 'dart:io';

// Open the native library
DynamicLibrary _openLibrary() {
  if (Platform.isAndroid) return DynamicLibrary.open('libmylib.so');
  if (Platform.isIOS)     return DynamicLibrary.process(); // bundled with app
  if (Platform.isMacOS)   return DynamicLibrary.open('libmylib.dylib');
  if (Platform.isWindows) return DynamicLibrary.open('mylib.dll');
  throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
}

final _lib = _openLibrary();

// Look up a C function: int add(int a, int b)
// Dart type:  int Function(int, int)
// C type:     NativeFunction<Int32 Function(Int32, Int32)>
typedef _AddC    = Int32 Function(Int32 a, Int32 b); // C signature
typedef _AddDart = int Function(int a, int b);        // Dart signature

final add = _lib.lookupFunction<_AddC, _AddDart>('add');

// Call it like a normal Dart function:
final result = add(3, 4);  // returns 7
print('3 + 4 = $result');  // 3 + 4 = 7'''),

          const SizedBox(height: 20),

          // ── 2. Working with pointers ───────────────────────────────────
          _header('2. Pointers & Memory', Colors.teal),
          _code(r'''
import 'dart:ffi';
import 'package:ffi/ffi.dart';  // malloc, calloc, Arena

// Allocate a native int and pass its pointer to C
void example() {
  // malloc: manual memory management
  final Pointer<Int32> ptr = malloc<Int32>();
  ptr.value = 42;

  // Pass to a C function that writes to the pointer
  _lib.lookupFunction<Void Function(Pointer<Int32>), void Function(Pointer<Int32>)>
      ('populateInt')(ptr);

  print('Value from C: ${ptr.value}');

  // ALWAYS free what you malloc — memory leaks in FFI are real
  malloc.free(ptr);
}

// Better: use Arena for automatic cleanup (like Rust's drop)
void exampleWithArena() {
  using((Arena arena) {
    final ptr = arena<Int32>();  // automatically freed at end of using()
    ptr.value = 42;
    _lib.lookup<NativeFunction<Void Function(Pointer<Int32>)>>('populate')
        .asFunction<void Function(Pointer<Int32>)>()(ptr);
    print(ptr.value);
    // No need to call free — Arena handles it
  });
}'''),

          const SizedBox(height: 20),

          // ── 3. Strings ────────────────────────────────────────────────
          _header('3. Dart String ↔ C char*', Colors.orange),
          _code(r'''
import 'package:ffi/ffi.dart';

// C function: char* greet(const char* name)
typedef _GreetC    = Pointer<Utf8> Function(Pointer<Utf8>);
typedef _GreetDart = Pointer<Utf8> Function(Pointer<Utf8>);

final _greet = _lib.lookupFunction<_GreetC, _GreetDart>('greet');

String greet(String name) {
  // Convert Dart String → C string (null-terminated UTF-8)
  final Pointer<Utf8> namePtr = name.toNativeUtf8();
  try {
    // Call C function — returns char*
    final Pointer<Utf8> resultPtr = _greet(namePtr);
    // Convert result back to Dart String
    return resultPtr.toDartString();
    // Note: if C returned malloc'd memory, you must free resultPtr too
  } finally {
    malloc.free(namePtr);  // always free the input pointer
  }
}

print(greet('World'));  // "Hello, World!" from C'''),

          const SizedBox(height: 20),

          // ── 4. Structs ─────────────────────────────────────────────────
          _header('4. C Structs in Dart', Colors.purple),
          _code(r'''
// C struct:
// typedef struct {
//   int width;
//   int height;
//   float aspectRatio;
// } ImageSize;

// Dart Struct — must extend Struct
final class ImageSize extends Struct {
  @Int32() external int width;
  @Int32() external int height;
  @Float()  external double aspectRatio;
}

// C function: ImageSize getImageSize(const char* path)
typedef _GetSizeC    = ImageSize Function(Pointer<Utf8>);
typedef _GetSizeDart = ImageSize Function(Pointer<Utf8>);

final _getSize = _lib.lookupFunction<_GetSizeC, _GetSizeDart>('getImageSize');

ImageSize getSize(String path) {
  final pathPtr = path.toNativeUtf8();
  try {
    return _getSize(pathPtr);
  } finally {
    malloc.free(pathPtr);
  }
}

final size = getSize('/sdcard/photo.jpg');
print('${size.width} x ${size.height}  ratio: ${size.aspectRatio}');'''),

          const SizedBox(height: 20),

          // ── 5. ffigen ────────────────────────────────────────────────
          _header('5. ffigen — Auto-Generate Bindings', Colors.green),
          _code(r'''
# Instead of writing lookupFunction by hand for every C function,
# use ffigen to generate all bindings from the .h header file.

# pubspec.yaml
dev_dependencies:
  ffigen: ^13.0.0

# ffigen.yaml (project root)
name: LibMyLib
description: Bindings for libmylib
output: 'lib/src/mylib_bindings.g.dart'
headers:
  entry-points:
    - 'native/include/mylib.h'  # your C header file

# Generate:
dart run ffigen

# Result: lib/src/mylib_bindings.g.dart
# Contains: all lookupFunction declarations from the header
# Usage:
final lib = LibMyLib(DynamicLibrary.open('libmylib.so'));
lib.add(3, 4);         // auto-generated, fully typed
lib.greet('World'.toNativeUtf8()); // same pattern'''),

          const SizedBox(height: 16),
          _card(
            color: Colors.brown.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Key Takeaways', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('• DynamicLibrary.open() loads the C library; lookupFunction() binds a function'),
                Text('• Always free malloc\'d pointers — FFI memory leaks are permanent'),
                Text('• Use Arena/using() for automatic cleanup of short-lived allocations'),
                Text('• toNativeUtf8() / toDartString() bridge Dart String ↔ C char*'),
                Text('• ffigen auto-generates all bindings from a .h header file'),
                Text('• Prefer FFI for pure C libs; use MethodChannel for Android/iOS SDK APIs'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _header(String t, Color c) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(t, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: c)),
    );
Widget _code(String code) => Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF1E1E2E), borderRadius: BorderRadius.circular(6)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(code, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Color(0xFFCDD6F4))),
      ),
    );
Widget _card({required Color color, required Widget child}) =>
    Card(color: color, child: Padding(padding: const EdgeInsets.all(12), child: child));
