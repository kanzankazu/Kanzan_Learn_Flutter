// ============================================================
// PHASE 1 — Mini Project: Weather CLI App (Data Layer)
// ============================================================
// Feature: phase-1-dart-language, Requirement 12: Weather CLI App
// Purpose: Demonstrates async/await, null safety, JSON parsing, and
//          custom exception hierarchies in a real-world HTTP client.
// Run with: dart run lib/phase1/mini_projects/weather/weather_app.dart <city>
// Prerequisites: Phase 0 (OOP, error handling), Phase 1 topics 1–4
// Dart SDK: >= 3.0.0
// External: package:http ^1.2.0
// ============================================================

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

// ============================================================
// DATA MODEL
// ============================================================

/// Represents parsed weather data from the OpenWeatherMap API.
///
/// All fields except [windGustMs] are required — the API guarantees
/// them when it returns HTTP 200. [windGustMs] is optional because
/// the `wind.gust` field is only present under certain wind conditions.
///
/// Example JSON (condensed):
/// ```json
/// {
///   "name": "Jakarta",
///   "main": { "temp": 32.5, "humidity": 80 },
///   "weather": [{ "description": "light rain" }],
///   "wind": { "speed": 4.1, "gust": 6.2 }
/// }
/// ```
class WeatherData {
  /// The city name returned by the API (e.g., "Jakarta").
  final String cityName;

  /// Temperature in Celsius. The API is called with `units=metric`.
  final double temperatureCelsius;

  /// Human-readable condition string from `weather[0].description`
  /// (e.g., "light rain", "clear sky").
  final String condition;

  /// Relative humidity percentage (0–100).
  final int humidityPercent;

  /// Wind speed in meters per second.
  final double windSpeedMs;

  /// Optional wind gust speed in m/s. Null when the API omits `wind.gust`.
  final double? windGustMs;

  const WeatherData({
    required this.cityName,
    required this.temperatureCelsius,
    required this.condition,
    required this.humidityPercent,
    required this.windSpeedMs,
    this.windGustMs, // nullable — no default needed, callers check for null
  });

  /// Parses a [WeatherData] instance from a raw OpenWeatherMap JSON map.
  ///
  /// Null-safety notes:
  /// - `wind['gust']` uses `?.` because the field may be absent entirely.
  ///   If absent, [windGustMs] is left as null (see field docs above).
  /// - `wind['speed']` uses `?? 0.0` as a safety default even though the
  ///   API always includes it — defensive coding for unexpected responses.
  ///
  /// Requirements: 12.7, 12.8
  factory WeatherData.fromJson(Map<String, dynamic> json) {
    // Navigate nested "main" object for temperature and humidity.
    final main = json['main'] as Map<String, dynamic>;

    // "weather" is an array; we always use the first element's description.
    final weatherList = json['weather'] as List<dynamic>;
    final condition = (weatherList[0] as Map<String, dynamic>)['description']
        as String;

    // "wind" object — gust is optional, so we use ?. for safe access.
    final wind = json['wind'] as Map<String, dynamic>;
    final windGust = wind['gust'] as double?; // ?.  — null if field absent

    return WeatherData(
      cityName: json['name'] as String,
      temperatureCelsius: (main['temp'] as num).toDouble(),
      condition: condition,
      humidityPercent: main['humidity'] as int,
      // wind.speed: always present per API spec, but ?? 0.0 guards against
      // malformed responses without crashing the entire parse.
      windSpeedMs: (wind['speed'] as num?)?.toDouble() ?? 0.0,
      windGustMs: windGust, // null when absent — callers use ?.
    );
  }

  @override
  String toString() =>
      'WeatherData(city: $cityName, temp: $temperatureCelsius°C, '
      'condition: $condition, humidity: $humidityPercent%, '
      'wind: ${windSpeedMs}m/s, gust: ${windGustMs ?? 'N/A'})';
}

// ============================================================
// EXCEPTION HIERARCHY
// ============================================================

/// Thrown when the OpenWeatherMap API returns a non-200 HTTP status.
///
/// Carries the HTTP [statusCode] and the [city] name that was queried
/// so that error messages can be specific and actionable.
///
/// Requirement: 12.6
class WeatherApiException implements Exception {
  /// The HTTP status code returned by the API (e.g., 500, 401).
  final int statusCode;

  /// The city name that was passed to the request.
  final String city;

  const WeatherApiException(this.statusCode, this.city);

  @override
  String toString() =>
      'WeatherApiException: HTTP $statusCode when fetching weather for "$city"';
}

/// Thrown specifically when the API returns HTTP 404 — city not found.
///
/// Extends [WeatherApiException] so callers can catch either the general
/// API error or the specific not-found case depending on their needs.
///
/// Example:
/// ```dart
/// try {
///   await service.fetchWeather('UnknownCity123');
/// } on CityNotFoundException catch (e) {
///   print('City not found: ${e.city}');
/// } on WeatherApiException catch (e) {
///   print('API error: ${e.statusCode}');
/// }
/// ```
///
/// Requirement: 12.6
class CityNotFoundException extends WeatherApiException {
  const CityNotFoundException(String city) : super(404, city);

  @override
  String toString() =>
      'CityNotFoundException: City "$city" not found (HTTP 404). '
      'Check the spelling or try a nearby larger city.';
}

// ============================================================
// NETWORK SERVICE
// ============================================================

/// Handles all HTTP communication with the OpenWeatherMap Current Weather API.
///
/// Usage:
/// ```dart
/// final service = WeatherService(apiKey: Platform.environment['OPENWEATHER_API_KEY']!);
/// final data = await service.fetchWeather('Jakarta');
/// ```
///
/// Error contract:
/// - [CityNotFoundException]  → HTTP 404
/// - [WeatherApiException]    → any other non-200 status
/// - [http.ClientException]   → network-level failure (no connectivity, DNS)
/// - [TimeoutException]       → request exceeded [_timeout]
///
/// The optional [httpClient] parameter allows injecting a mock client for
/// testing, avoiding real network calls during unit tests. If omitted, a
/// default [http.Client] is created internally.
///
/// Requirement: 12.2, 12.6
class WeatherService {
  /// OpenWeatherMap API host. The full endpoint path is `/data/2.5/weather`.
  /// Kept as a named constant for readability and easy updates.
  static const String _apiHost = 'api.openweathermap.org';

  /// Request timeout. The app should surface a clear error if this is hit
  /// rather than hanging indefinitely. 10 seconds is generous for a simple
  /// JSON payload — in production, 5s is often more appropriate.
  static const Duration _timeout = Duration(seconds: 10);

  /// The API key obtained from openweathermap.org (free tier available).
  final String apiKey;

  /// Optional injectable HTTP client — used in tests to provide mock responses
  /// without making real network calls. Production code leaves this null and
  /// relies on the [http.Client] created inside [fetchWeather].
  final http.Client? httpClient;

  const WeatherService({required this.apiKey, this.httpClient});

  /// Fetches current weather conditions for [city].
  ///
  /// The [city] string is URL-encoded automatically by [Uri.https], so
  /// city names with spaces (e.g., "New York") work without manual encoding.
  ///
  /// Throws:
  /// - [CityNotFoundException] if the API returns HTTP 404.
  /// - [WeatherApiException] for other non-200 status codes.
  /// - [http.ClientException] for network failures.
  /// - [TimeoutException] if the request takes longer than [_timeout].
  ///
  /// Requirements: 12.2, 12.7, 12.8
  Future<WeatherData> fetchWeather(String city) async {
    // Build the request URI with query parameters.
    // Uri.https() handles encoding of special characters in city names.
    final uri = Uri.https(
      _apiHost,
      '/data/2.5/weather',
      {
        'q': city,
        'appid': apiKey,
        'units': 'metric', // Celsius; use 'imperial' for Fahrenheit
      },
    );

    // Send GET request with a timeout to prevent indefinite hangs.
    // Use injected httpClient if provided (enables unit testing without network),
    // otherwise fall back to the default http.get() global function.
    final client = httpClient;
    final response = client != null
        ? await client.get(uri).timeout(_timeout)
        : await http.get(uri).timeout(_timeout);

    // Handle HTTP error responses before attempting JSON parse.
    if (response.statusCode != 200) {
      if (response.statusCode == 404) {
        // Specific subtype for "city not found" — callers may want to
        // suggest alternative city names or prompt for re-entry.
        throw CityNotFoundException(city);
      }
      // All other non-200 codes (401 invalid key, 429 rate limit, 5xx server)
      // are surfaced as the general WeatherApiException.
      throw WeatherApiException(response.statusCode, city);
    }

    // Parse the JSON body and map it to our strongly-typed WeatherData model.
    // jsonDecode returns dynamic; we cast to Map for the factory constructor.
    final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
    return WeatherData.fromJson(jsonMap);
  }
}

// ============================================================
// CLI ENTRY POINT
// ============================================================
// Run examples:
//   export OPENWEATHER_API_KEY=your_key_here
//   dart run lib/phase1/mini_projects/weather/weather_app.dart Jakarta
//   dart run lib/phase1/mini_projects/weather/weather_app.dart "New York"
//   dart run lib/phase1/mini_projects/weather/weather_app.dart  # interactive prompt
// ============================================================

/// Application entry point.
///
/// Flow:
///   1. Read API key from environment → exit(1) with instructions if missing.
///   2. Resolve city from CLI args or interactive prompt.
///   3. Print progress message while the HTTP request is in flight.
///   4. Print formatted weather output on success.
///   5. Catch all exceptions at the top level and exit(1) without stack traces.
///
/// Requirements: 12.1, 12.4, 12.5, 12.9, 12.10
Future<void> main(List<String> args) async {
  // ── Step 1: Resolve API key ────────────────────────────────────────────────
  // Requirement 12.9 — key must come from the environment variable, not
  // hard-coded in source. This keeps secrets out of version control.
  final apiKey = Platform.environment['OPENWEATHER_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    _printApiKeyInstructions();
    exit(1);
  }

  // ── Step 2: Resolve city name ──────────────────────────────────────────────
  // Requirement 12.5 — use CLI arg if provided, otherwise prompt stdin.
  final city = args.isNotEmpty ? _parseArgs(args) : await _promptCity();

  // ── Step 3 & 4: Fetch weather and print ───────────────────────────────────
  // The progress message is printed before the async call so the user gets
  // immediate feedback that the app is doing something.
  try {
    // Requirement 12.10 — progress indicator before the result.
    print('Mengambil data cuaca untuk $city...');

    final service = WeatherService(apiKey: apiKey);
    final data = await service.fetchWeather(city);

    // Requirement 12.3 — formatted output.
    _printWeather(data);
  }

  // ── Step 5: Top-level error handling ──────────────────────────────────────
  // Requirements 12.4 — specific messages per error type, no stack traces.
  on CityNotFoundException catch (e) {
    // 404 — city name was not recognised by the API.
    stderr.writeln('Error: Kota "$city" tidak ditemukan.');
    stderr.writeln(
      'Periksa ejaan atau coba kota besar terdekat. (${e.statusCode})',
    );
    exit(1);
  } on WeatherApiException catch (e) {
    // Other non-200 HTTP responses (401, 429, 5xx, etc.).
    stderr.writeln(
      'Error: API mengembalikan status HTTP ${e.statusCode} untuk "$city".',
    );
    stderr.writeln('Periksa API key Anda atau coba lagi nanti.');
    exit(1);
  } on TimeoutException {
    // Request exceeded the 10-second timeout.
    stderr.writeln(
      'Error: Koneksi ke server cuaca timeout (>10 detik). '
      'Periksa koneksi internet Anda.',
    );
    exit(1);
  } on SocketException catch (e) {
    // No network connectivity / DNS failure.
    stderr.writeln('Error: Tidak ada koneksi jaringan. ${e.message}');
    exit(1);
  } on Exception catch (e) {
    // Catch-all for any other unexpected exceptions.
    // We print the message but never the stack trace.
    stderr.writeln('Error tidak terduga: $e');
    exit(1);
  }
}

// ============================================================
// INPUT HELPERS
// ============================================================

/// Extracts the city name from the CLI argument list.
///
/// Only the first argument is used. If the user passes multiple tokens
/// (e.g., `New York` without quotes), only `New` would be used — the
/// correct invocation is `dart run weather_app.dart "New York"`.
///
/// Requirement: 12.5
String _parseArgs(List<String> args) {
  // args[0] is guaranteed non-empty by the caller's `args.isNotEmpty` guard.
  return args[0].trim();
}

/// Prompts the user for a city name via stdin and returns their input.
///
/// Used when no CLI argument is provided. Reads a single line from stdin.
/// Exits with an error if stdin returns an empty string (e.g., EOF or
/// the user just pressed Enter without typing).
///
/// Requirement: 12.5
Future<String> _promptCity() async {
  // Write prompt without a newline so the cursor stays on the same line.
  stdout.write('Masukkan nama kota: ');

  // readLineSync() blocks until the user presses Enter.
  final input = stdin.readLineSync()?.trim() ?? '';

  if (input.isEmpty) {
    stderr.writeln('Error: Nama kota tidak boleh kosong.');
    exit(1);
  }

  return input;
}

// ============================================================
// OUTPUT HELPERS
// ============================================================

/// Prints formatted weather information to stdout.
///
/// Output format:
/// ```
/// ────────────────────────────────
/// Cuaca di Jakarta
/// ────────────────────────────────
/// Suhu      : 32°C
/// Kondisi   : light rain
/// Kelembaban: 80%
/// Angin     : 4.1 m/s
/// ────────────────────────────────
/// ```
///
/// Temperature is displayed as an integer (floor) per Requirement 12.3.
/// Wind gust is shown as a bonus line when the API provides it.
///
/// Requirement: 12.3
void _printWeather(WeatherData data) {
  const separator = '────────────────────────────────';

  // Temperature displayed as integer (floor), matching the requirement
  // "Suhu: XX°C (integer, tanpa desimal)".
  final tempInt = data.temperatureCelsius.floor();

  print(separator);
  print('Cuaca di ${data.cityName}');
  print(separator);
  print('Suhu      : $tempInt°C');
  print('Kondisi   : ${data.condition}');
  print('Kelembaban: ${data.humidityPercent}%');
  print('Angin     : ${data.windSpeedMs} m/s');

  // Optional gust line — only printed when the API provides the field.
  if (data.windGustMs != null) {
    print('Hembusan  : ${data.windGustMs} m/s');
  }

  print(separator);
}

// ============================================================
// SETUP INSTRUCTIONS
// ============================================================

/// Prints step-by-step instructions for obtaining and configuring the
/// OpenWeatherMap API key.
///
/// Shown when the `OPENWEATHER_API_KEY` environment variable is not set.
/// Keeps the message actionable and concise so the learner can get
/// started immediately.
///
/// Requirement: 12.9
void _printApiKeyInstructions() {
  stderr.writeln('''
╔══════════════════════════════════════════════════════════════╗
║         OPENWEATHER API KEY DIPERLUKAN                       ║
╚══════════════════════════════════════════════════════════════╝

Environment variable OPENWEATHER_API_KEY belum di-set.

Cara mendapatkan API key gratis:
  1. Buka https://openweathermap.org/api
  2. Klik "Sign Up" dan buat akun gratis
  3. Pergi ke https://home.openweathermap.org/api_keys
  4. Salin API key Anda (biasanya aktif dalam 10-30 menit)

Cara men-set environment variable:

  macOS / Linux (sesi saat ini):
    export OPENWEATHER_API_KEY=your_api_key_here

  macOS / Linux (permanen, tambahkan ke ~/.zshrc atau ~/.bashrc):
    echo 'export OPENWEATHER_API_KEY=your_api_key_here' >> ~/.zshrc

  Windows (Command Prompt):
    set OPENWEATHER_API_KEY=your_api_key_here

  Windows (PowerShell):
    \$env:OPENWEATHER_API_KEY="your_api_key_here"

Setelah set, jalankan kembali:
  dart run lib/phase1/mini_projects/weather/weather_app.dart Jakarta
''');
}
