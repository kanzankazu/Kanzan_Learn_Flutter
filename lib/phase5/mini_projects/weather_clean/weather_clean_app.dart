/// Mini Project Phase 5 — Weather App (Clean Architecture Edition).
///
/// This is the Phase 4 Weather App, REFACTORED to Clean Architecture.
/// Compare this file with `lib/phase4/mini_projects/weather_app/weather_app.dart`
/// to see what changes and what stays the same.
///
/// **What changed:**
/// - Code is split into domain / data / presentation layers
/// - Repository interface in domain; implementation in data
/// - Use Case encapsulates the two-step fetch (geocode → weather)
/// - Presentation only knows domain types — never imports Dio directly
/// - get_it wires everything together
///
/// **What stayed the same:**
/// - The UI widgets look identical
/// - The API calls are identical
/// - The end user experience is identical
///
/// **Why bother?**
/// - Swap Open-Meteo for WeatherAPI.com → change ONE class (data layer)
/// - Test the use case with a mock → no network calls needed
/// - UI developer doesn't need to know about Dio at all
///
/// **Folder structure this represents:**
/// ```
/// features/weather/
/// ├── domain/
/// │   ├── entities/       → WeatherData, CurrentWeather, etc.
/// │   ├── repositories/   → WeatherRepository (abstract)
/// │   └── usecases/       → GetWeatherUseCase
/// ├── data/
/// │   ├── datasources/    → WeatherRemoteDataSource (Dio)
/// │   ├── models/         → WeatherDto, GeoLocationDto
/// │   └── repositories/   → WeatherRepositoryImpl
/// └── presentation/
///     ├── viewmodels/     → WeatherViewModel
///     └── screens/        → WeatherScreen
/// ```
///
/// How to run:
/// ```bash
/// flutter run -t lib/phase5/mini_projects/weather_clean/weather_clean_app.dart
/// ```
library;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ═════════════════════════════════════════════════════════════════════════════
// DOMAIN LAYER
// Pure Dart. No Dio, no Flutter widgets, no framework code.
// ═════════════════════════════════════════════════════════════════════════════

// ── Domain Entities ───────────────────────────────────────────────────────────

/// Geographic coordinates for a city.
class GeoLocation {
  final String cityName;
  final String countryCode;
  final double latitude;
  final double longitude;

  const GeoLocation({
    required this.cityName,
    required this.countryCode,
    required this.latitude,
    required this.longitude,
  });
}

/// Current weather conditions.
class CurrentWeather {
  final double temperatureCelsius;
  final double windspeedKmh;
  final int wmoCode; // WMO weather interpretation code
  final bool isDay;

  const CurrentWeather({
    required this.temperatureCelsius,
    required this.windspeedKmh,
    required this.wmoCode,
    required this.isDay,
  });
}

/// Hourly forecast for one hour.
class HourlyForecast {
  final String time; // "HH:mm"
  final double temperatureCelsius;
  final int wmoCode;

  const HourlyForecast({
    required this.time,
    required this.temperatureCelsius,
    required this.wmoCode,
  });
}

/// Aggregate — bundles location, current, and hourly into one object.
class WeatherReport {
  final GeoLocation location;
  final CurrentWeather current;
  final List<HourlyForecast> hourly;

  const WeatherReport({
    required this.location,
    required this.current,
    required this.hourly,
  });
}

// ── Domain Repository Interface ────────────────────────────────────────────────

/// What the domain layer needs from a weather data source.
/// The data layer fulfills this contract. Domain never imports Dio.
abstract class WeatherRepository {
  /// Resolves a city name to its coordinates.
  /// Returns [Success<GeoLocation>] or [Failure].
  Future<Result<GeoLocation>> geocode(String cityName);

  /// Fetches current + hourly weather for a given location.
  Future<Result<WeatherReport>> fetchWeather(GeoLocation location);
}

// ── Domain Use Case ───────────────────────────────────────────────────────────

/// Use Case: get a complete weather report for a city name.
///
/// **Why this warrants a Use Case:**
/// It combines two repository calls (geocode → fetchWeather) and
/// does input validation. The ViewModel shouldn't know about this flow.
///
/// ViewModel just calls: `getWeather.execute('Jakarta')`.
class GetWeatherUseCase {
  final WeatherRepository _repository;

  GetWeatherUseCase(this._repository);

  /// Executes the two-step weather lookup:
  /// 1. Geocode the city name → coordinates
  /// 2. Fetch weather using those coordinates
  Future<Result<WeatherReport>> execute(String cityName) async {
    final trimmed = cityName.trim();

    // Domain validation — happens before any network call
    if (trimmed.isEmpty) {
      return Failure(ValidationError('City name cannot be empty.'));
    }

    // Step 1: geocode
    final geoResult = await _repository.geocode(trimmed);
    if (geoResult is Failure) return Failure((geoResult as Failure).error);

    // Step 2: fetch weather with the resolved coordinates
    final location = (geoResult as Success<GeoLocation>).data;
    return _repository.fetchWeather(location);
  }
}

// ── Result type (same as Demo 06) ─────────────────────────────────────────────

sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(String message) onFailure,
  }) {
    return switch (this) {
      Success(:final data) => onSuccess(data),
      Failure(:final error) => onFailure(error.message),
    };
  }
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final DomainError error;
  const Failure(this.error);
}

abstract class DomainError {
  String get message;
}

class NetworkDomainError extends DomainError {
  final String detail;
  NetworkDomainError(this.detail);

  @override
  String get message => 'Network error: $detail';
}

class NotFoundDomainError extends DomainError {
  final String resource;
  NotFoundDomainError(this.resource);

  @override
  String get message => '$resource not found.';
}

class ValidationError extends DomainError {
  final String detail;
  ValidationError(this.detail);

  @override
  String get message => detail;
}

// ═════════════════════════════════════════════════════════════════════════════
// DATA LAYER
// Knows about Dio, JSON. Implements domain interfaces.
// ═════════════════════════════════════════════════════════════════════════════

/// Concrete implementation using Open-Meteo API.
///
/// This is the ONLY class that imports Dio.
/// Swap this for a Firebase or WeatherAPI implementation without
/// touching domain or presentation code.
class OpenMeteoWeatherRepository implements WeatherRepository {
  static final _geoDio = Dio(BaseOptions(
    baseUrl: 'https://geocoding-api.open-meteo.com/v1',
    connectTimeout: const Duration(seconds: 10),
  ));

  static final _weatherDio = Dio(BaseOptions(
    baseUrl: 'https://api.open-meteo.com/v1',
    connectTimeout: const Duration(seconds: 10),
  ));

  @override
  Future<Result<GeoLocation>> geocode(String cityName) async {
    try {
      final res = await _geoDio.get('/search', queryParameters: {
        'name': cityName,
        'count': 1,
        'language': 'en',
        'format': 'json',
      });
      final results = res.data['results'] as List?;
      if (results == null || results.isEmpty) {
        return Failure(NotFoundDomainError('City "$cityName"'));
      }
      final raw = results[0] as Map<String, dynamic>;
      // Data layer maps JSON → domain entity (no domain entity knows about JSON)
      return Success(GeoLocation(
        cityName: raw['name'] as String,
        countryCode: raw['country'] as String? ?? '',
        latitude: (raw['latitude'] as num).toDouble(),
        longitude: (raw['longitude'] as num).toDouble(),
      ));
    } on DioException catch (e) {
      return Failure(NetworkDomainError(e.message ?? 'Unknown network error'));
    }
  }

  @override
  Future<Result<WeatherReport>> fetchWeather(GeoLocation loc) async {
    try {
      final res = await _weatherDio.get('/forecast', queryParameters: {
        'latitude': loc.latitude,
        'longitude': loc.longitude,
        'current': 'temperature_2m,windspeed_10m,weathercode,is_day',
        'hourly': 'temperature_2m,weathercode',
        'forecast_days': 1,
        'timezone': 'auto',
      });

      // Map JSON → domain entities
      final rawCurrent = res.data['current'] as Map<String, dynamic>;
      final current = CurrentWeather(
        temperatureCelsius: (rawCurrent['temperature_2m'] as num).toDouble(),
        windspeedKmh: (rawCurrent['windspeed_10m'] as num).toDouble(),
        wmoCode: rawCurrent['weathercode'] as int,
        isDay: (rawCurrent['is_day'] as int) == 1,
      );

      final times = (res.data['hourly']['time'] as List).cast<String>();
      final temps = (res.data['hourly']['temperature_2m'] as List)
          .map((e) => (e as num).toDouble())
          .toList();
      final codes = (res.data['hourly']['weathercode'] as List)
          .map((e) => e as int)
          .toList();

      final hourly = List.generate(
        8,
        (i) => HourlyForecast(
          time: times[i].substring(11, 16),
          temperatureCelsius: temps[i],
          wmoCode: codes[i],
        ),
      );

      return Success(WeatherReport(
        location: loc,
        current: current,
        hourly: hourly,
      ));
    } on DioException catch (e) {
      return Failure(NetworkDomainError(e.message ?? 'Network error'));
    }
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// PRESENTATION LAYER
// Depends on domain only. No Dio, no JSON parsing.
// ═════════════════════════════════════════════════════════════════════════════

/// Sealed state for the weather screen — same pattern as Phase 4.
sealed class WeatherState {}

class WeatherIdle extends WeatherState {}

class WeatherLoading extends WeatherState {}

class WeatherLoaded extends WeatherState {
  final WeatherReport report;
  WeatherLoaded(this.report);
}

class WeatherErrorState extends WeatherState {
  final String message;
  WeatherErrorState(this.message);
}

/// ViewModel — only depends on [GetWeatherUseCase] from the domain layer.
/// Compare to Phase 4: there we called WeatherService directly.
/// Now we call a use case that handles all the domain logic.
class WeatherViewModel extends ChangeNotifier {
  final GetWeatherUseCase _getWeather;

  WeatherViewModel(this._getWeather);

  WeatherState _state = WeatherIdle();
  WeatherState get state => _state;

  Future<void> search(String cityName) async {
    _state = WeatherLoading();
    notifyListeners();

    final result = await _getWeather.execute(cityName);
    _state = result.fold(
      onSuccess: (report) => WeatherLoaded(report),
      onFailure: (message) => WeatherErrorState(message),
    );
    notifyListeners();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dependency injection setup
// ─────────────────────────────────────────────────────────────────────────────

final GetIt _sl = GetIt.asNewInstance();

void _setupDependencies() {
  // Data layer
  _sl.registerLazySingleton<WeatherRepository>(
    () => OpenMeteoWeatherRepository(),
  );
  // Domain layer
  _sl.registerLazySingleton<GetWeatherUseCase>(
    () => GetWeatherUseCase(_sl<WeatherRepository>()),
  );
  // Presentation layer
  _sl.registerFactory<WeatherViewModel>(
    () => WeatherViewModel(_sl<GetWeatherUseCase>()),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// WMO helpers (pure functions, no layer violations)
// ─────────────────────────────────────────────────────────────────────────────

String _weatherEmoji(int code, {bool isDay = true}) {
  if (code == 0) return isDay ? '☀️' : '🌙';
  if (code <= 3) return isDay ? '⛅' : '🌥️';
  if (code <= 49) return '🌫️';
  if (code <= 59) return '🌦️';
  if (code <= 69) return '🌧️';
  if (code <= 79) return '❄️';
  if (code <= 82) return '🌧️';
  if (code <= 99) return '⛈️';
  return '🌈';
}

String _weatherDescription(int code) {
  if (code == 0) return 'Clear sky';
  if (code == 1) return 'Mainly clear';
  if (code == 2) return 'Partly cloudy';
  if (code == 3) return 'Overcast';
  if (code <= 49) return 'Foggy';
  if (code <= 59) return 'Drizzle';
  if (code <= 69) return 'Rain';
  if (code <= 79) return 'Snow';
  if (code <= 99) return 'Thunderstorm';
  return 'Unknown';
}

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  _setupDependencies();
  runApp(const WeatherCleanApp());
}

class WeatherCleanApp extends StatelessWidget {
  const WeatherCleanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App (Clean Architecture)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue, brightness: Brightness.light),
        useMaterial3: true,
      ),
      home: const WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  // get_it resolves the full dependency chain automatically
  late final WeatherViewModel _vm = _sl<WeatherViewModel>();
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vm.addListener(() => setState(() {}));
    _loadLastCity();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _vm.dispose();
    super.dispose();
  }

  Future<void> _loadLastCity() async {
    final prefs = await SharedPreferences.getInstance();
    final city = prefs.getString('clean_last_city') ?? 'Jakarta';
    _searchCtrl.text = city;
    await _search(city);
  }

  Future<void> _search(String city) async {
    await _vm.search(city);
    // Persist on success
    if (_vm.state is WeatherLoaded) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('clean_last_city', city.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a237e),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Weather (Clean Architecture)'),
            Text('Phase 4 refactored', style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search city...',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withOpacity(0.15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () => _search(_searchCtrl.text),
                ),
              ),
              onSubmitted: _search,
            ),
          ),

          // Content — pattern match on the sealed WeatherState
          Expanded(
            child: switch (_vm.state) {
              WeatherIdle() => const Center(
                  child: Text('Search for a city',
                      style: TextStyle(color: Colors.white54, fontSize: 18))),
              WeatherLoading() => const Center(
                  child: CircularProgressIndicator(color: Colors.white)),
              WeatherErrorState(:final message) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 12),
                      Text(message,
                          style: const TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
              WeatherLoaded(:final report) => RefreshIndicator(
                  onRefresh: () => _search(report.location.cityName),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: _WeatherContent(report: report),
                  ),
                ),
            },
          ),
        ],
      ),
    );
  }
}

/// Presentation widget — receives a [WeatherReport] domain entity.
/// Note: it uses domain fields (`temperatureCelsius`, `wmoCode`, `cityName`)
/// not API field names (`temperature_2m`, `weathercode`).
/// The translation happened in the data layer.
class _WeatherContent extends StatelessWidget {
  final WeatherReport report;
  const _WeatherContent({required this.report});

  @override
  Widget build(BuildContext context) {
    final loc = report.location;
    final cur = report.current;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('${loc.cityName}, ${loc.countryCode}',
            style: const TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        Text(_weatherEmoji(cur.wmoCode, isDay: cur.isDay),
            style: const TextStyle(fontSize: 80)),
        const SizedBox(height: 8),
        Text('${cur.temperatureCelsius.round()}°C',
            style: const TextStyle(
                color: Colors.white, fontSize: 56, fontWeight: FontWeight.w300)),
        Text(_weatherDescription(cur.wmoCode),
            style: const TextStyle(color: Colors.white70, fontSize: 18)),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _Stat(icon: Icons.air, label: 'Wind', value: '${cur.windspeedKmh.round()} km/h'),
            _Stat(
              icon: cur.isDay ? Icons.wb_sunny : Icons.nightlight,
              label: 'Period',
              value: cur.isDay ? 'Daytime' : 'Nighttime',
            ),
          ],
        ),
        const SizedBox(height: 32),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Next 8 hours',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: report.hourly.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => _HourCard(hour: report.hourly[i]),
          ),
        ),
        const SizedBox(height: 24),
        Text('Data: Open-Meteo API • Clean Architecture edition',
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _Stat({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _HourCard extends StatelessWidget {
  final HourlyForecast hour;
  const _HourCard({required this.hour});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(hour.time, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          const SizedBox(height: 4),
          Text(_weatherEmoji(hour.wmoCode)),
          const SizedBox(height: 4),
          Text('${hour.temperatureCelsius.round()}°',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
