/// Phase 7 — Topic 04: Mocking
///
/// Mocking replaces real dependencies (API clients, databases, sensors)
/// with fake objects that you control. This keeps unit and widget tests
/// fast, deterministic, and isolated from external systems.
///
/// Two popular Dart mocking libraries:
/// ┌──────────────┬────────────────────────────────────────────────────────┐
/// │ mockito      │ Code-gen based. Uses @GenerateMocks + build_runner.    │
/// │              │ Type-safe, more boilerplate setup.                     │
/// ├──────────────┼────────────────────────────────────────────────────────┤
/// │ mocktail     │ No code-gen. Uses generics. Less setup.                │
/// │              │ Recommended for most projects.                         │
/// └──────────────┴────────────────────────────────────────────────────────┘
///
/// Key concepts covered:
/// 1. Why mock? — isolate, speed, determinism, test error paths
/// 2. mockito — @GenerateMocks, build_runner, when/thenReturn
/// 3. mocktail — Mock<T>, when/thenReturn/thenThrow, verify
/// 4. [when()] / [thenReturn()] / [thenAnswer()] / [thenThrow()]
/// 5. [verify()] / [verifyNever()] — assert calls happened (or not)
/// 6. [any()] / [captureAny()] — argument matchers
/// 7. Fake vs Mock vs Stub — what's the difference
///
/// How to run tests:
/// ```bash
/// flutter test test/phase7/mocking_test.dart
/// ```
library;

import 'package:flutter/material.dart';

/// Standalone entry point.
void main() => runApp(_StandaloneApp());

class _StandaloneApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mocking Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: const MockingDemo(),
    );
  }
}

/// Demo screen explaining mocking concepts.
class MockingDemo extends StatelessWidget {
  const MockingDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('04 — Mocking'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Why mock? ────────────────────────────────────────────────────
          _card(
            color: Colors.purple.shade50,
            child: const Text(
              'Without mocking, tests depend on real servers, real databases, '
              'and real time — they become slow, flaky, and hard to reason about.\n\n'
              'Mocking gives you control: specify exactly what the dependency '
              'returns so you can test every branch of your code.',
              style: TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),

          // ── 1. The class we want to test ─────────────────────────────────
          _header('1. Class Under Test', Colors.purple),
          const Text(
            'The WeatherRepository depends on a WeatherApi. '
            'We mock the API so tests never touch the network.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          _code('''
// lib/weather/weather_api.dart  — interface (abstract class)
abstract class WeatherApi {
  Future<WeatherDto> fetchWeather(String city);
}

// lib/weather/weather_repository.dart  — class under test
class WeatherRepository {
  final WeatherApi api; // dependency injected via constructor

  const WeatherRepository(this.api);

  Future<Result<Weather>> getWeather(String city) async {
    try {
      final dto = await api.fetchWeather(city);
      return Success(Weather.fromDto(dto));
    } on NetworkException catch (e) {
      return Failure(AppError.network(e.message));
    }
  }
}'''),

          const SizedBox(height: 16),

          // ── 2. mocktail (no code-gen) ────────────────────────────────────
          _header('2. mocktail — No Code-Gen (Recommended)', Colors.teal),
          _code('''
# pubspec.yaml
dev_dependencies:
  mocktail: ^1.0.4
  flutter_test:
    sdk: flutter'''),
          const SizedBox(height: 6),
          _code('''
// test/weather/weather_repository_test.dart
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

// 1. Create a mock class — extend Mock and implement the interface
class MockWeatherApi extends Mock implements WeatherApi {}

void main() {
  late MockWeatherApi mockApi;
  late WeatherRepository sut; // sut = System Under Test

  setUp(() {
    mockApi = MockWeatherApi();
    sut = WeatherRepository(mockApi);   // inject the mock
  });

  group('WeatherRepository.getWeather', () {
    test('returns Success when API responds', () async {
      // Arrange — define what the mock returns for this specific call
      when(() => mockApi.fetchWeather('Jakarta'))
          .thenAnswer((_) async => WeatherDto(city: 'Jakarta', temp: 32));

      // Act
      final result = await sut.getWeather('Jakarta');

      // Assert
      expect(result, isA<Success<Weather>>());
      expect((result as Success).value.city, equals('Jakarta'));
    });

    test('returns Failure when API throws NetworkException', () async {
      // Arrange — simulate a network error
      when(() => mockApi.fetchWeather(any()))
          .thenThrow(NetworkException('No internet'));

      // Act
      final result = await sut.getWeather('Jakarta');

      // Assert
      expect(result, isA<Failure<Weather>>());
    });

    test('calls API exactly once', () async {
      when(() => mockApi.fetchWeather(any()))
          .thenAnswer((_) async => WeatherDto(city: 'A', temp: 25));

      await sut.getWeather('Jakarta');

      // verify() checks how many times the method was called
      verify(() => mockApi.fetchWeather('Jakarta')).called(1);
      // verifyNever ensures a method was NOT called
      verifyNever(() => mockApi.fetchWeather('Bandung'));
    });
  });
}'''),

          const SizedBox(height: 16),

          // ── 3. mockito (code-gen) ────────────────────────────────────────
          _header('3. mockito — Code-Gen Approach', Colors.orange),
          _code('''
# pubspec.yaml
dev_dependencies:
  mockito: ^5.4.4
  build_runner: ^2.4.9
  flutter_test:
    sdk: flutter'''),
          const SizedBox(height: 6),
          _code('''
// test/weather/weather_repository_test.dart
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';

// 1. Annotate the test file — build_runner reads this annotation
@GenerateMocks([WeatherApi])
void main() {
  // MockWeatherApi is GENERATED — run build_runner to create it:
  // dart run build_runner build --delete-conflicting-outputs
  late MockWeatherApi mockApi;

  setUp(() => mockApi = MockWeatherApi());

  test('returns Success on valid response', () async {
    // when/thenReturn for sync, when/thenAnswer for async
    when(mockApi.fetchWeather('Jakarta'))
        .thenAnswer((_) async => WeatherDto(city: 'Jakarta', temp: 30));

    final repo = WeatherRepository(mockApi);
    final result = await repo.getWeather('Jakarta');

    expect(result, isA<Success<Weather>>());
    verify(mockApi.fetchWeather('Jakarta')).called(1);
  });
}
// Run build_runner once after adding @GenerateMocks:
// dart run build_runner build --delete-conflicting-outputs'''),

          const SizedBox(height: 16),

          // ── 4. when variants ─────────────────────────────────────────────
          _header('4. when() Variants', Colors.red),
          _code('''
// thenReturn — synchronous return value
when(() => mock.getName()).thenReturn('Alice');

// thenAnswer — use when the return value is computed or async
when(() => mock.fetchUser(any()))
    .thenAnswer((invocation) async {
      final id = invocation.positionalArguments[0] as int;
      return User(id: id, name: 'User \$id');
    });

// thenThrow — simulate an exception
when(() => mock.deleteUser(any())).thenThrow(PermissionDeniedException());

// Multiple stubs — different return per call
when(() => mock.getCount())
    ..thenReturn(1)   // first call returns 1
    ..thenReturn(2)   // second call returns 2
    ..thenReturn(3);  // third call returns 3

// Argument matchers
when(() => mock.search(any()))         // any argument
    .thenReturn([]);
when(() => mock.search(startsWith('A'))) // conditional matcher
    .thenReturn(['Alice', 'Adam']);'''),

          const SizedBox(height: 16),

          // ── 5. Mock vs Fake vs Stub ──────────────────────────────────────
          _header('5. Mock vs Fake vs Stub', Colors.indigo),
          _card(
            color: Colors.indigo.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Stub', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  'Returns hardcoded values. No behavior verification. '
                  'Simple — just override a method to return what you want.',
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 8),
                Text('Mock', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  'Stub + call verification. Can assert verify(mock.foo()).called(1). '
                  'Use when you care that a dependency was called correctly.',
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 8),
                Text('Fake', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  'A lightweight in-memory implementation of an interface. '
                  'No library needed — just implement the abstract class with '
                  'a Map or List as the backing store.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          _code('''
// Fake example — useful for repository fakes in widget tests
class FakeWeatherRepository implements WeatherRepository {
  // In-memory store instead of real network/DB
  final Map<String, Weather> _store = {};

  void seed(String city, Weather weather) => _store[city] = weather;

  @override
  Future<Result<Weather>> getWeather(String city) async {
    final w = _store[city];
    if (w == null) return Failure(AppError.notFound());
    return Success(w);
  }
}

// Usage in widget test — no mock library needed
testWidgets('shows temperature', (tester) async {
  final repo = FakeWeatherRepository()
    ..seed('Jakarta', Weather(city: 'Jakarta', temp: 32));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [weatherRepoProvider.overrideWithValue(repo)],
      child: const MaterialApp(home: WeatherScreen()),
    ),
  );
  await tester.pumpAndSettle();

  expect(find.text('32°C'), findsOneWidget);
});'''),

          const SizedBox(height: 16),
          _card(
            color: Colors.purple.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Key Takeaways', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('• mocktail = no code-gen, simpler setup (recommended)'),
                Text('• mockito = code-gen, more type safety'),
                Text('• when().thenReturn() for sync; when().thenAnswer() for async'),
                Text('• verify() checks a method was called; verifyNever() checks it wasn\'t'),
                Text('• Fake = in-memory impl, Mock = stub + call verification'),
                Text('• Inject dependencies via constructor — makes mocking possible'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared helpers ─────────────────────────────────────────────────────────────

Widget _header(String title, Color color) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(title,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
    );

Widget _code(String code) => Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(6),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(code,
            style: const TextStyle(
                fontFamily: 'monospace', fontSize: 11, color: Color(0xFFCDD6F4))),
      ),
    );

Widget _card({required Color color, required Widget child}) => Card(
      color: color,
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    );
