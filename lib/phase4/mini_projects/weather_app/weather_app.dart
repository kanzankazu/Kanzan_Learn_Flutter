/// Mini Project Phase 4 — Weather App.
///
/// **What this project practices:**
/// - Dio with BaseOptions and LogInterceptor
/// - Manual JSON deserialization (no code gen)
/// - AsyncState<T> sealed class for loading/error/success
/// - SharedPreferences for persisting the last searched city
/// - Pull-to-refresh
/// - Formatted display of API data
///
/// **API:** Open-Meteo (https://open-meteo.com) — 100% free, no key needed.
///   Geocoding: https://geocoding-api.open-meteo.com/v1/search?name=Jakarta
///   Weather:   https://api.open-meteo.com/v1/forecast?latitude=...&longitude=...
///
/// **How to run:**
/// ```bash
/// flutter run -t lib/phase4/mini_projects/weather_app/weather_app.dart
/// ```
library;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────────────────────────────────────

/// Represents a city's geographic location returned by the geocoding API.
///
/// **Why geocoding?**
/// Weather APIs need latitude/longitude coordinates, not city names.
/// Step 1: Convert city name → coordinates (geocoding).
/// Step 2: Use coordinates → fetch weather.
///
/// All fields are `final` — models should be immutable. Once created,
/// a location object never changes. This prevents accidental mutation bugs.
class GeoLocation {
  final String name;       // city name, e.g. "Jakarta"
  final String country;    // country code, e.g. "ID"
  final double latitude;   // decimal degrees, e.g. -6.2 (negative = south)
  final double longitude;  // decimal degrees, e.g. 106.8 (positive = east)

  const GeoLocation({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  factory GeoLocation.fromJson(Map<String, dynamic> json) => GeoLocation(
        name: json['name'] as String,
        // country can be null for some entries — use ?? '' as safe default
        country: json['country'] as String? ?? '',
        // The API returns numbers as `num` (could be int or double).
        // .toDouble() ensures we always get a double regardless of the JSON format.
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
      );
}

/// Current weather conditions at a location.
///
/// **WMO Weather Code:**
/// The Open-Meteo API uses WMO (World Meteorological Organization) standard
/// weather codes. Code 0 = clear sky, codes 61-67 = rain, 95-99 = thunderstorm.
/// See [_weatherEmoji] and [_weatherDescription] for the full mapping.
class CurrentWeather {
  final double temperature; // in °C
  final double windspeed;   // in km/h
  final int weatherCode;    // WMO code: 0 = clear, 95-99 = thunderstorm
  final bool isDay;         // true during daylight hours (affects emoji choice)

  const CurrentWeather({
    required this.temperature,
    required this.windspeed,
    required this.weatherCode,
    required this.isDay,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) => CurrentWeather(
        temperature: (json['temperature_2m'] as num).toDouble(),
        windspeed: (json['windspeed_10m'] as num).toDouble(),
        weatherCode: json['weathercode'] as int,
        // API returns 1 for day, 0 for night — convert to bool
        isDay: (json['is_day'] as int) == 1,
      );
}

/// One hour of forecast data.
///
/// The API returns arrays of parallel data (times[], temperatures[], codes[]).
/// We zip them together into a list of [HourlyForecast] objects for easier use in the UI.
/// See [WeatherService.fetchWeather] for how the zipping is done.
class HourlyForecast {
  final String time;         // "HH:mm" format, e.g. "14:00"
  final double temperature;  // in °C
  final int weatherCode;     // WMO code for this hour

  const HourlyForecast({
    required this.time,
    required this.temperature,
    required this.weatherCode,
  });
}

/// Bundles all weather data for a location into one object.
///
/// This is the "aggregate root" pattern: instead of passing location,
/// current weather, and hourly forecast as three separate arguments to widgets,
/// we bundle them into one [WeatherData] object. This reduces function signatures
/// and makes it easier to add new fields later.
class WeatherData {
  final GeoLocation location;
  final CurrentWeather current;
  final List<HourlyForecast> hourly; // next 8 hours

  const WeatherData({
    required this.location,
    required this.current,
    required this.hourly,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Sealed state
// ─────────────────────────────────────────────────────────────────────────────

/// The four possible states of the weather screen.
///
/// Using a sealed class instead of three separate booleans
/// (`bool isLoading, bool hasError, WeatherData? data`) prevents
/// "impossible states" — e.g. isLoading = true AND data != null at the same time.
/// With a sealed class, only one state is possible at any moment.
///
/// This pattern is also used by Riverpod's [AsyncValue<T>] internally.
sealed class WeatherState {}

/// Initial state — the search box is empty, no search has been performed yet.
class WeatherIdle extends WeatherState {}

/// The API call is in progress — show a loading spinner.
class WeatherLoading extends WeatherState {}

/// The API call succeeded — [data] holds the weather information.
class WeatherLoaded extends WeatherState {
  final WeatherData data;
  WeatherLoaded(this.data);
}

/// The API call failed — [message] holds the error description to show the user.
class WeatherError extends WeatherState {
  final String message;
  WeatherError(this.message);
}

// ─────────────────────────────────────────────────────────────────────────────
// Weather service
// ─────────────────────────────────────────────────────────────────────────────

/// Handles all network calls for the weather feature.
///
/// **Why two separate Dio instances?**
/// The geocoding API and the weather API have different base URLs.
/// Each [Dio] instance is configured with its own [BaseOptions.baseUrl],
/// so we don't have to repeat the full URL in every request.
///
/// In a larger app, these would live in a repository class (Clean Architecture),
/// but for this mini-project a static service class is fine.
class WeatherService {
  // Separate Dio instance for geocoding (city → coordinates)
  static final _geoDio = Dio(BaseOptions(
    baseUrl: 'https://geocoding-api.open-meteo.com/v1',
    connectTimeout: const Duration(seconds: 10),
  ));

  // Separate Dio instance for the actual weather forecast
  static final _weatherDio = Dio(BaseOptions(
    baseUrl: 'https://api.open-meteo.com/v1',
    connectTimeout: const Duration(seconds: 10),
  ));

  /// Geocode a city name → latitude + longitude.
  static Future<GeoLocation> geocode(String city) async {
    final res = await _geoDio.get('/search', queryParameters: {
      'name': city,
      'count': 1,
      'language': 'en',
      'format': 'json',
    });
    final results = res.data['results'] as List?;
    if (results == null || results.isEmpty) {
      throw Exception('City "$city" not found');
    }
    return GeoLocation.fromJson(results[0] as Map<String, dynamic>);
  }

  /// Fetch current + hourly weather for a location.
  static Future<WeatherData> fetchWeather(GeoLocation loc) async {
    final res = await _weatherDio.get('/forecast', queryParameters: {
      'latitude': loc.latitude,
      'longitude': loc.longitude,
      'current': 'temperature_2m,windspeed_10m,weathercode,is_day',
      'hourly': 'temperature_2m,weathercode',
      'forecast_days': 1,
      'timezone': 'auto',
    });

    final current = CurrentWeather.fromJson(
        res.data['current'] as Map<String, dynamic>);

    // Parse next 8 hours of forecast
    final times = (res.data['hourly']['time'] as List).cast<String>();
    final temps = (res.data['hourly']['temperature_2m'] as List)
        .map((e) => (e as num).toDouble())
        .toList();
    final codes =
        (res.data['hourly']['weathercode'] as List).map((e) => e as int).toList();

    final hourly = List.generate(
      8,
      (i) => HourlyForecast(
        time: times[i].substring(11, 16), // HH:mm
        temperature: temps[i],
        weatherCode: codes[i],
      ),
    );

    return WeatherData(location: loc, current: current, hourly: hourly);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WMO weather code helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Maps a WMO weather code to an emoji for visual display.
///
/// **WMO (World Meteorological Organization) weather codes:**
/// These are standard codes used by many weather APIs:
/// - 0       → Clear sky
/// - 1–3     → Mainly clear / partly cloudy / overcast
/// - 45–48   → Fog / rime fog
/// - 51–55   → Drizzle (light to dense)
/// - 61–67   → Rain (slight to heavy / freezing)
/// - 71–77   → Snow (slight to heavy / snow grains)
/// - 80–82   → Rain showers
/// - 85–86   → Snow showers
/// - 95–99   → Thunderstorm
///
/// [isDay] changes the emoji — ☀️ vs 🌙 for the same clear-sky code.
///
/// 💡 Tip: Top-level functions are fine for pure helpers like this
/// (no state, no dependencies). They don't need to be in a class.
String _weatherEmoji(int code, {bool isDay = true}) {
  if (code == 0) return isDay ? '☀️' : '🌙';
  if (code <= 3) return isDay ? '⛅' : '🌥️';
  if (code <= 49) return '🌫️';
  if (code <= 59) return '🌦️';
  if (code <= 69) return '🌧️';
  if (code <= 79) return '❄️';
  if (code <= 82) return '🌧️';
  if (code <= 84) return '🌨️';
  if (code <= 99) return '⛈️';
  return '🌈';
}

/// Maps a WMO weather code to a human-readable description.
/// Used as a subtitle below the temperature display.
String _weatherDescription(int code) {
  if (code == 0) return 'Clear sky';
  if (code == 1) return 'Mainly clear';
  if (code == 2) return 'Partly cloudy';
  if (code == 3) return 'Overcast';
  if (code <= 49) return 'Foggy';
  if (code <= 59) return 'Drizzle';
  if (code <= 69) return 'Rain';
  if (code <= 79) return 'Snow';
  if (code <= 82) return 'Rain showers';
  if (code <= 99) return 'Thunderstorm';
  return 'Unknown';
}

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

void main() => runApp(const WeatherApp());

/// Root widget — sets up MaterialApp with a dark blue color scheme.
///
/// 💡 Notice: we use `ColorScheme.fromSeed` with `brightness: Brightness.light`
/// here even though the screen looks dark. That's because the dark background
/// is achieved by setting `Scaffold.backgroundColor` directly — independent
/// of the app's theme brightness. Both approaches are valid; this demo
/// prioritizes a dramatic weather app look.
class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const WeatherScreen(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main screen
// ─────────────────────────────────────────────────────────────────────────────

/// The main weather screen — owns the search state and the [WeatherState].
///
/// This is a [StatefulWidget] because it manages:
/// 1. The current [WeatherState] (idle/loading/loaded/error)
/// 2. The [TextEditingController] for the search field
/// 3. The last searched city (for the "Retry" button)
class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  WeatherState _state = WeatherIdle();
  final _searchCtrl = TextEditingController();
  String _lastCity = '';

  @override
  void initState() {
    super.initState(); // Always call super.initState() FIRST in initState
    _loadLastCity();
  }

  @override
  void dispose() {
    // Always dispose TextEditingController to prevent memory leaks.
    // A controller holds listeners; if not disposed, they keep running
    // even after the widget is removed from the tree.
    _searchCtrl.dispose();
    super.dispose(); // Always call super.dispose() LAST in dispose
  }

  /// Reads the last searched city from SharedPreferences and triggers a search.
  ///
  /// SharedPreferences.getInstance() is async, so we use async/await.
  /// The `?? 'Jakarta'` provides a default city if no previous search exists.
  Future<void> _loadLastCity() async {
    final prefs = await SharedPreferences.getInstance();
    // ?? = null-coalescing operator: use 'Jakarta' if getString returns null
    final city = prefs.getString('last_city') ?? 'Jakarta';
    _searchCtrl.text = city;
    _search(city);
  }

  /// Performs the two-step weather lookup: geocode city name → fetch weather.
  ///
  /// **Flow:**
  /// 1. Set state to [WeatherLoading] → UI shows spinner
  /// 2. Geocode: city name → (latitude, longitude)
  /// 3. Fetch weather using the coordinates
  /// 4. Persist city to SharedPreferences for next app launch
  /// 5. Set state to [WeatherLoaded] → UI shows weather data
  ///
  /// On any error: set state to [WeatherError] → UI shows error message + retry.
  ///
  /// **`if (mounted)` check before setState:**
  /// The user might navigate away before the async calls complete.
  /// Calling setState on an unmounted widget throws an error.
  /// `mounted` returns false after dispose() is called.
  Future<void> _search(String city) async {
    if (city.trim().isEmpty) return;
    setState(() => _state = WeatherLoading());

    try {
      final loc = await WeatherService.geocode(city.trim());
      final data = await WeatherService.fetchWeather(loc);

      // Persist last searched city so it loads automatically on next launch
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_city', city.trim());
      _lastCity = city.trim();

      // mounted check — the user might have navigated away during the await
      if (mounted) setState(() => _state = WeatherLoaded(data));
    } on DioException catch (e) {
      // Catch DioException first — it has richer error info than a generic Exception
      if (mounted) {
        setState(() => _state = WeatherError(
            e.type == DioExceptionType.connectionError
                ? 'No internet connection'
                : 'Network error: ${e.message}'));
      }
    } catch (e) {
      // Catch any other error (e.g. "City not found" thrown by the service)
      if (mounted) setState(() => _state = WeatherError(e.toString()));
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
        title: const Text('Weather App'),
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

          // Content
          Expanded(
            child: switch (_state) {
              WeatherIdle() => const Center(
                  child: Text('Search for a city',
                      style: TextStyle(color: Colors.white54, fontSize: 18)),
                ),
              WeatherLoading() => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              WeatherError(:final message) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 48),
                      const SizedBox(height: 12),
                      Text(message,
                          style: const TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => _search(_lastCity),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              WeatherLoaded(:final data) => RefreshIndicator(
                  onRefresh: () => _search(data.location.name),
                  // AlwaysScrollableScrollPhysics is REQUIRED for RefreshIndicator
                  // to work when content is shorter than the screen.
                  // Without it, you can't pull to refresh on a short list.
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: _WeatherContent(data: data),
                  ),
                ),
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Weather content widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Displays the full weather data for a location.
///
/// This is a "presentation widget" — it receives data and renders it.
/// It has no business logic, no network calls, no state management.
/// Keeping it pure makes it easy to test and reuse.
class _WeatherContent extends StatelessWidget {
  final WeatherData data;
  const _WeatherContent({required this.data});

  @override
  Widget build(BuildContext context) {
    final loc = data.location;
    final cur = data.current;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Location
        Text(
          '${loc.name}, ${loc.country}',
          style: const TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),

        // Big temperature + emoji
        Text(
          _weatherEmoji(cur.weatherCode, isDay: cur.isDay),
          style: const TextStyle(fontSize: 80),
        ),
        const SizedBox(height: 8),
        Text(
          '${cur.temperature.round()}°C',
          style: const TextStyle(
              color: Colors.white, fontSize: 56, fontWeight: FontWeight.w300),
        ),
        Text(
          _weatherDescription(cur.weatherCode),
          style: const TextStyle(color: Colors.white70, fontSize: 18),
        ),
        const SizedBox(height: 32),

        // Stats row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _StatChip(
                icon: Icons.air,
                label: 'Wind',
                value: '${cur.windspeed.round()} km/h'),
            _StatChip(
                icon: cur.isDay ? Icons.wb_sunny : Icons.nightlight,
                label: 'Period',
                value: cur.isDay ? 'Daytime' : 'Nighttime'),
          ],
        ),
        const SizedBox(height: 32),

        // Hourly forecast
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
            itemCount: data.hourly.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) => _HourlyCard(hour: data.hourly[i]),
          ),
        ),
        const SizedBox(height: 32),

        // Data source note
        Text(
          'Data: Open-Meteo API (free, no key required)',
          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
        ),
      ],
    );
  }
}

/// A small info chip showing an icon, a label, and a value.
///
/// Used for weather stats like wind speed and time-of-day.
/// Extracted into a separate widget to avoid repeating the Container/Column
/// structure for each stat.
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label; // small text below the icon, e.g. "Wind"
  final String value; // bold text below the label, e.g. "12 km/h"
  const _StatChip(
      {required this.icon, required this.label, required this.value});

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
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 11)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

/// A single card in the horizontal hourly forecast scroll.
///
/// Shows the time, a weather emoji, and the temperature for one hour.
/// The horizontal list in [_WeatherContent] renders one of these per forecast hour.
class _HourlyCard extends StatelessWidget {
  final HourlyForecast hour;
  const _HourlyCard({required this.hour});

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
          Text(hour.time,
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
          const SizedBox(height: 4),
          Text(_weatherEmoji(hour.weatherCode)),
          const SizedBox(height: 4),
          Text('${hour.temperature.round()}°',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
