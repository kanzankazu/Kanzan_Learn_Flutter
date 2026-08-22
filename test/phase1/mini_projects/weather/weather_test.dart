// ============================================================
// PHASE 1 — Unit Tests: Weather CLI App
// ============================================================
// Feature: phase-1-dart-language, Requirement 12: Weather CLI App
// Purpose: Unit tests for WeatherData.fromJson() parsing and
//          WeatherService HTTP error handling.
//
// Test coverage:
//   - WeatherData.fromJson() happy path (all fields present)
//   - WeatherData.fromJson() missing wind.gust → windGustMs is null
//   - WeatherData.fromJson() temperature = 0°C edge case
//   - WeatherService.fetchWeather() HTTP 404 → CityNotFoundException
//   - WeatherService.fetchWeather() HTTP 500 → WeatherApiException
//
// Run with: dart test test/phase1/mini_projects/weather/weather_test.dart
// ============================================================

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

// Import the production code under test.
// We use a relative import because this is a CLI Dart project,
// not a Flutter package — avoids package: resolution issues.
import '../../../../lib/phase1/mini_projects/weather/weather_app.dart';

void main() {
  group('WeatherData.fromJson()', () {
    // --------------------------------------------------------
    // Helper: builds a full, valid OpenWeatherMap-style JSON map.
    // This mirrors the real API response structure so tests stay
    // aligned with what the production code actually receives.
    // --------------------------------------------------------
    Map<String, dynamic> _buildWeatherJson({
      String cityName = 'Jakarta',
      double temp = 32.5,
      String description = 'light rain',
      int humidity = 80,
      double windSpeed = 4.1,
      double? windGust = 6.2, // null omits the key entirely (see below)
    }) {
      final windMap = <String, dynamic>{
        'speed': windSpeed,
        // Only include 'gust' when a value is provided — matches real API
        // behaviour where the field is absent under calm conditions.
        if (windGust != null) 'gust': windGust,
      };

      return {
        'name': cityName,
        'main': {
          'temp': temp,
          'humidity': humidity,
        },
        'weather': [
          {'description': description},
        ],
        'wind': windMap,
      };
    }

    // ----------------------------------------------------------
    // Happy path: all required fields present and mapped correctly.
    // Requirements: 12.3, 12.7, 12.8
    // ----------------------------------------------------------
    test('maps all required fields correctly from a full JSON response', () {
      final json = _buildWeatherJson(
        cityName: 'Jakarta',
        temp: 32.5,
        description: 'light rain',
        humidity: 80,
        windSpeed: 4.1,
        windGust: 6.2,
      );

      final data = WeatherData.fromJson(json);

      expect(data.cityName, equals('Jakarta'));
      expect(data.temperatureCelsius, equals(32.5));
      expect(data.condition, equals('light rain'));
      expect(data.humidityPercent, equals(80));
      expect(data.windSpeedMs, equals(4.1));
      expect(data.windGustMs, equals(6.2));
    });

    // ----------------------------------------------------------
    // Missing wind.gust → windGustMs must be null.
    // The API omits this field under calm wind conditions.
    // Requirements: 12.7
    // ----------------------------------------------------------
    test('sets windGustMs to null when wind.gust is absent from JSON', () {
      // windGust: null causes the helper to omit the 'gust' key entirely.
      final json = _buildWeatherJson(windGust: null);

      final data = WeatherData.fromJson(json);

      expect(data.windGustMs, isNull,
          reason: 'wind.gust absent in API response should yield null windGustMs');
    });

    // ----------------------------------------------------------
    // Edge case: temperature = 0°C.
    // Ensures 0.0 is not treated as falsy / missing anywhere in the
    // parsing chain (some code mistakenly uses ?? on numeric 0).
    // Requirements: 12.3
    // ----------------------------------------------------------
    test('correctly parses temperature of 0.0°C without treating it as absent', () {
      final json = _buildWeatherJson(temp: 0.0);

      final data = WeatherData.fromJson(json);

      expect(data.temperatureCelsius, equals(0.0),
          reason: '0°C is a valid temperature and must not fall back to a default');
    });

    // ----------------------------------------------------------
    // Additional edge cases for robustness.
    // ----------------------------------------------------------
    test('parses integer temperature from JSON as double (num coercion)', () {
      // The API sometimes returns whole-number temps as integers, not doubles.
      final json = _buildWeatherJson()
        ..['main'] = {'temp': 30, 'humidity': 70}; // int, not double

      final data = WeatherData.fromJson(json);

      expect(data.temperatureCelsius, equals(30.0));
      expect(data.temperatureCelsius, isA<double>());
    });

    test('parses negative temperature correctly', () {
      final json = _buildWeatherJson(temp: -15.3);

      final data = WeatherData.fromJson(json);

      expect(data.temperatureCelsius, equals(-15.3));
    });

    test('parses humidity of 100% (maximum value)', () {
      final json = _buildWeatherJson(humidity: 100);

      final data = WeatherData.fromJson(json);

      expect(data.humidityPercent, equals(100));
    });

    test('parses city name with spaces correctly', () {
      final json = _buildWeatherJson(cityName: 'New York');

      final data = WeatherData.fromJson(json);

      expect(data.cityName, equals('New York'));
    });
  });

  // ============================================================
  // WeatherService HTTP error handling tests
  // ============================================================
  // Strategy: inject a MockClient from package:http/testing.dart.
  // MockClient lets us return canned HTTP responses without a real
  // network connection, so tests are fast, deterministic, and offline.
  //
  // We test the *exception type and properties* thrown by fetchWeather(),
  // not the HTTP internals. This keeps tests aligned with the public contract.
  // Requirements: 12.4, 12.6
  // ============================================================
  group('WeatherService.fetchWeather() HTTP error handling', () {
    const testCity = 'TestCity';
    const testApiKey = 'fake-api-key-for-testing';

    // --------------------------------------------------------
    // HTTP 404 → must throw CityNotFoundException (subtype of
    // WeatherApiException) with the correct city name.
    // Requirements: 12.4, 12.6
    // --------------------------------------------------------
    test('throws CityNotFoundException for HTTP 404 response', () async {
      // Build a MockClient that always returns 404.
      final mockClient = MockClient((_) async {
        return http.Response('{"cod":"404","message":"city not found"}', 404);
      });

      // WeatherService needs an injectable client — see note below.
      // We construct directly using the testable constructor.
      final service = WeatherService(
        apiKey: testApiKey,
        httpClient: mockClient, // injected mock
      );

      // fetchWeather should throw CityNotFoundException for 404.
      expect(
        () async => await service.fetchWeather(testCity),
        throwsA(
          isA<CityNotFoundException>()
              .having((e) => e.city, 'city', equals(testCity))
              .having((e) => e.statusCode, 'statusCode', equals(404)),
        ),
      );
    });

    // --------------------------------------------------------
    // HTTP 500 → must throw WeatherApiException (not the 404 subtype)
    // with statusCode == 500 and the correct city.
    // Requirements: 12.4, 12.6
    // --------------------------------------------------------
    test('throws WeatherApiException with statusCode 500 for HTTP 500 response',
        () async {
      final mockClient = MockClient((_) async {
        return http.Response('{"cod":500,"message":"Internal Server Error"}', 500);
      });

      final service = WeatherService(
        apiKey: testApiKey,
        httpClient: mockClient,
      );

      expect(
        () async => await service.fetchWeather(testCity),
        throwsA(
          isA<WeatherApiException>()
              .having((e) => e.statusCode, 'statusCode', equals(500))
              .having((e) => e.city, 'city', equals(testCity)),
        ),
      );
    });

    // --------------------------------------------------------
    // HTTP 500 should NOT throw CityNotFoundException — ensure the
    // exception hierarchy is not crossed incorrectly.
    // --------------------------------------------------------
    test('HTTP 500 does NOT throw CityNotFoundException', () async {
      final mockClient = MockClient((_) async {
        return http.Response('Internal Server Error', 500);
      });

      final service = WeatherService(
        apiKey: testApiKey,
        httpClient: mockClient,
      );

      expect(
        () async => await service.fetchWeather(testCity),
        throwsA(isNot(isA<CityNotFoundException>())),
      );
    });

    // --------------------------------------------------------
    // HTTP 401 (invalid API key) → WeatherApiException with code 401.
    // --------------------------------------------------------
    test('throws WeatherApiException with statusCode 401 for HTTP 401 response',
        () async {
      final mockClient = MockClient((_) async {
        return http.Response('{"cod":401,"message":"Invalid API key"}', 401);
      });

      final service = WeatherService(
        apiKey: 'wrong-key',
        httpClient: mockClient,
      );

      expect(
        () async => await service.fetchWeather(testCity),
        throwsA(
          isA<WeatherApiException>()
              .having((e) => e.statusCode, 'statusCode', equals(401)),
        ),
      );
    });

    // --------------------------------------------------------
    // HTTP 200 with valid JSON → no exception, returns WeatherData.
    // --------------------------------------------------------
    test('returns WeatherData on HTTP 200 with valid JSON', () async {
      final responseBody = jsonEncode({
        'name': testCity,
        'main': {'temp': 28.0, 'humidity': 75},
        'weather': [
          {'description': 'few clouds'}
        ],
        'wind': {'speed': 3.5},
      });

      final mockClient = MockClient((_) async {
        return http.Response(responseBody, 200);
      });

      final service = WeatherService(
        apiKey: testApiKey,
        httpClient: mockClient,
      );

      final result = await service.fetchWeather(testCity);

      expect(result, isA<WeatherData>());
      expect(result.cityName, equals(testCity));
      expect(result.temperatureCelsius, equals(28.0));
    });
  });
}
