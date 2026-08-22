// ============================================================
// PHASE 1 — PBT: WeatherData.fromJson() field extraction
// ============================================================
// Feature: phase-1-dart-language, Property 14: Validates Requirements 12.3, 12.7
//
// Property 14: WeatherData.fromJson() correctly extracts all fields.
//
// For any valid OpenWeatherMap-shaped JSON map with randomised field values,
// WeatherData.fromJson() must produce a WeatherData where every field exactly
// matches the corresponding source value in the JSON. Specifically:
//   - cityName           == json['name']
//   - temperatureCelsius == (json['main']['temp'] as num).toDouble()
//   - condition          == json['weather'][0]['description']
//   - humidityPercent    == json['main']['humidity']
//   - windSpeedMs        == (json['wind']['speed'] as num).toDouble()
//   - windGustMs         == json['wind']['gust'] (double) when present, else null
//
// Run with: dart test test/phase1/mini_projects/weather/weather_pbt_test.dart
// ============================================================

import 'dart:math';

import 'package:belajar_1/phase1/mini_projects/weather/weather_app.dart';
import 'package:test/test.dart';

// ---------------------------------------------------------------------------
// Random generators
// ---------------------------------------------------------------------------

/// A small pool of realistic city-name strings used by the generator.
/// Using a pool is deliberate: real-world city names are ASCII strings with
/// mixed capitalisation, which matches what the OpenWeatherMap API returns.
const List<String> _cityPool = [
  'Jakarta',
  'Surabaya',
  'Bandung',
  'Medan',
  'Makassar',
  'London',
  'New York',
  'Tokyo',
  'Sydney',
  'Paris',
  'Berlin',
  'Seoul',
  'Mumbai',
  'Cairo',
  'Lagos',
];

/// A small pool of condition strings drawn from real OpenWeatherMap descriptions.
const List<String> _conditionPool = [
  'clear sky',
  'few clouds',
  'scattered clouds',
  'broken clouds',
  'shower rain',
  'rain',
  'thunderstorm',
  'snow',
  'mist',
  'light rain',
  'moderate rain',
  'heavy intensity rain',
  'overcast clouds',
  'light snow',
  'haze',
];

/// Generates a random city name from [_cityPool].
String _randomCity(Random rng) => _cityPool[rng.nextInt(_cityPool.length)];

/// Generates a random condition string from [_conditionPool].
String _randomCondition(Random rng) =>
    _conditionPool[rng.nextInt(_conditionPool.length)];

/// Generates a realistic temperature in Celsius, clamped to [-50, 60].
/// Uses a double with up to 2 decimal places to mirror API precision.
double _randomTemp(Random rng) {
  // Range: -50.0 to 59.99 (110 degree span)
  final raw = rng.nextDouble() * 110.0 - 50.0;
  // Round to 2 decimal places (same precision as OWM API)
  return (raw * 100).roundToDouble() / 100;
}

/// Generates a realistic humidity value [0, 100].
int _randomHumidity(Random rng) => rng.nextInt(101); // 0..100 inclusive

/// Generates a realistic wind speed in m/s, range [0.0, 50.0].
double _randomWindSpeed(Random rng) {
  final raw = rng.nextDouble() * 50.0;
  return (raw * 100).roundToDouble() / 100;
}

/// Generates a realistic wind gust speed in m/s, range [0.0, 70.0].
double _randomWindGust(Random rng) {
  final raw = rng.nextDouble() * 70.0;
  return (raw * 100).roundToDouble() / 100;
}

// ---------------------------------------------------------------------------
// JSON map builder — mirrors the actual OpenWeatherMap API response shape
// ---------------------------------------------------------------------------

/// Builds a minimal but structurally-correct OWM API response map.
///
/// [includeGust] controls whether `wind.gust` is present — testing both
/// the null (absent) and non-null (present) branches of fromJson().
Map<String, dynamic> _buildJson({
  required String cityName,
  required double temp,
  required int humidity,
  required String condition,
  required double windSpeed,
  double? windGust, // null → field absent from JSON (tests Req 12.7 null path)
}) {
  final wind = <String, dynamic>{'speed': windSpeed};
  if (windGust != null) {
    wind['gust'] = windGust;
  }

  return {
    'name': cityName,
    'main': {
      'temp': temp,
      'humidity': humidity,
    },
    'weather': [
      {'description': condition},
    ],
    'wind': wind,
  };
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // Fixed seed: any failing iteration is reproducible by re-running the test
  // with the same seed. Change the seed to explore different random space.
  const int seed = 20240825;
  const int iterations = 100;

  // ---------------------------------------------------------------------------
  // Property 14a: all required fields are extracted correctly
  // ---------------------------------------------------------------------------
  group('Property 14a — fromJson() extracts all required fields', () {
    test('holds for $iterations random inputs', () {
      final rng = Random(seed);

      for (var i = 0; i < iterations; i++) {
        final city = _randomCity(rng);
        final temp = _randomTemp(rng);
        final humidity = _randomHumidity(rng);
        final condition = _randomCondition(rng);
        final windSpeed = _randomWindSpeed(rng);
        final windGust = _randomWindGust(rng); // present in this variant

        final json = _buildJson(
          cityName: city,
          temp: temp,
          humidity: humidity,
          condition: condition,
          windSpeed: windSpeed,
          windGust: windGust,
        );

        final result = WeatherData.fromJson(json);

        // Each field must mirror the source value exactly.
        expect(
          result.cityName,
          equals(city),
          reason: 'Iteration $i: cityName mismatch',
        );
        expect(
          result.temperatureCelsius,
          equals(temp),
          reason: 'Iteration $i: temperatureCelsius mismatch',
        );
        expect(
          result.condition,
          equals(condition),
          reason: 'Iteration $i: condition mismatch',
        );
        expect(
          result.humidityPercent,
          equals(humidity),
          reason: 'Iteration $i: humidityPercent mismatch',
        );
        expect(
          result.windSpeedMs,
          equals(windSpeed),
          reason: 'Iteration $i: windSpeedMs mismatch',
        );
        // windGustMs should be set when gust is present in the JSON.
        expect(
          result.windGustMs,
          equals(windGust),
          reason: 'Iteration $i: windGustMs mismatch (gust present)',
        );
      }
    });
  });

  // ---------------------------------------------------------------------------
  // Property 14b: windGustMs is null when wind.gust is absent from JSON
  //               — Requirement 12.7 null-safety branch
  // ---------------------------------------------------------------------------
  group('Property 14b — windGustMs is null when gust key is absent', () {
    test('holds for $iterations random inputs without gust field', () {
      final rng = Random(seed + 1); // different seed for independent coverage

      for (var i = 0; i < iterations; i++) {
        final city = _randomCity(rng);
        final temp = _randomTemp(rng);
        final humidity = _randomHumidity(rng);
        final condition = _randomCondition(rng);
        final windSpeed = _randomWindSpeed(rng);

        // Build JSON *without* the optional gust field.
        final json = _buildJson(
          cityName: city,
          temp: temp,
          humidity: humidity,
          condition: condition,
          windSpeed: windSpeed,
          windGust: null, // ← field will be absent from the map
        );

        final result = WeatherData.fromJson(json);

        // The key invariant for Requirement 12.7: absent gust → null field.
        expect(
          result.windGustMs,
          isNull,
          reason: 'Iteration $i: windGustMs should be null when gust absent',
        );

        // Required fields must still be extracted correctly even without gust.
        expect(result.cityName, equals(city),
            reason: 'Iteration $i: cityName');
        expect(result.temperatureCelsius, equals(temp),
            reason: 'Iteration $i: temp');
        expect(result.windSpeedMs, equals(windSpeed),
            reason: 'Iteration $i: windSpeed');
      }
    });
  });

  // ---------------------------------------------------------------------------
  // Edge cases — boundary and special values
  // ---------------------------------------------------------------------------
  group('Edge cases', () {
    test('temperature exactly 0.0°C is preserved', () {
      final json = _buildJson(
        cityName: 'Freezing City',
        temp: 0.0,
        humidity: 50,
        condition: 'clear sky',
        windSpeed: 1.5,
      );
      final result = WeatherData.fromJson(json);
      expect(result.temperatureCelsius, equals(0.0));
    });

    test('temperature -50.0°C (extreme cold) is preserved', () {
      final json = _buildJson(
        cityName: 'Polar City',
        temp: -50.0,
        humidity: 30,
        condition: 'snow',
        windSpeed: 10.0,
      );
      final result = WeatherData.fromJson(json);
      expect(result.temperatureCelsius, equals(-50.0));
    });

    test('humidity at boundary values 0 and 100', () {
      for (final h in [0, 100]) {
        final json = _buildJson(
          cityName: 'Test City',
          temp: 25.0,
          humidity: h,
          condition: 'clear sky',
          windSpeed: 3.0,
        );
        expect(WeatherData.fromJson(json).humidityPercent, equals(h));
      }
    });

    test('wind speed 0.0 m/s is preserved', () {
      final json = _buildJson(
        cityName: 'Calm City',
        temp: 20.0,
        humidity: 65,
        condition: 'mist',
        windSpeed: 0.0,
      );
      final result = WeatherData.fromJson(json);
      expect(result.windSpeedMs, equals(0.0));
    });

    test('city name with spaces is preserved exactly', () {
      const cityWithSpaces = 'New York';
      final json = _buildJson(
        cityName: cityWithSpaces,
        temp: 15.0,
        humidity: 55,
        condition: 'few clouds',
        windSpeed: 5.0,
      );
      expect(WeatherData.fromJson(json).cityName, equals(cityWithSpaces));
    });

    test('windGustMs equals gust value when both speed and gust are present', () {
      final json = _buildJson(
        cityName: 'Windy City',
        temp: 18.0,
        humidity: 70,
        condition: 'scattered clouds',
        windSpeed: 12.3,
        windGust: 18.7,
      );
      final result = WeatherData.fromJson(json);
      expect(result.windSpeedMs, equals(12.3));
      expect(result.windGustMs, equals(18.7));
    });
  });
}
