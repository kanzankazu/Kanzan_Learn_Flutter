/// Entry point Phase 4 — Networking & Data.
///
/// Phase 4 covers everything you need to connect a Flutter app to the real world:
/// 1. **Dio** — HTTP client with interceptors, error handling, cancel tokens
/// 2. **JSON Serialization** — manual fromJson/toJson, copyWith, Result<T>
/// 3. **State Pattern** — sealed AsyncState<T> for loading/error/success
/// 4. **Local Storage** — SharedPreferences (settings) + Hive (structured data)
/// 5. **Image Caching** — CachedNetworkImage with placeholder & error widgets
/// 6. **Pagination** — infinite scroll with ScrollController
/// 7. **Offline-First** — cache-then-network, stale data indicators
///
/// How to run:
/// ```bash
/// flutter run -t lib/phase4/main_phase4.dart
/// ```
///
/// Mini projects:
/// ```bash
/// flutter run -t lib/phase4/mini_projects/weather_app/weather_app.dart
/// flutter run -t lib/phase4/mini_projects/news_reader/news_reader_app.dart
/// ```
library;

import 'package:flutter/material.dart';

import '01_dio_basics/dio_basics_demo.dart';
import '02_json_serialization/json_serialization_demo.dart';
import '03_state_pattern/state_pattern_demo.dart';
import '04_local_storage/local_storage_demo.dart';
import '05_image_caching/image_caching_demo.dart';
import '06_pagination/pagination_demo.dart';
import '07_offline_first/offline_first_demo.dart';

void main() => runApp(const Phase4MenuApp());

class Phase4MenuApp extends StatelessWidget {
  const Phase4MenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phase 4 — Networking & Data',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
        useMaterial3: true,
      ),
      home: const Phase4MenuScreen(),
    );
  }
}

class Phase4MenuScreen extends StatelessWidget {
  const Phase4MenuScreen({super.key});

  static const _topics = [
    _TopicItem(
      '01 — Dio Basics',
      'GET, POST, Interceptors, Error Handling, Cancel Token',
      Icons.http,
      Colors.cyan,
      DioBasicsDemo(),
    ),
    _TopicItem(
      '02 — JSON Serialization',
      'Manual fromJson/toJson, copyWith, Result<T>, nested objects',
      Icons.data_object,
      Colors.indigo,
      JsonSerializationDemo(),
    ),
    _TopicItem(
      '03 — State Pattern',
      'Sealed AsyncState<T>: loading, error, success, empty',
      Icons.swap_horiz,
      Colors.purple,
      StatePatternDemo(),
    ),
    _TopicItem(
      '04 — Local Storage',
      'SharedPreferences (settings) + Hive (structured cache)',
      Icons.storage,
      Colors.teal,
      LocalStorageDemo(),
    ),
    _TopicItem(
      '05 — Image Caching',
      'CachedNetworkImage, placeholder, error widget, fade-in',
      Icons.image,
      Colors.pink,
      ImageCachingDemo(),
    ),
    _TopicItem(
      '06 — Pagination & Infinite Scroll',
      'ScrollController, page-based API, end-of-list detection',
      Icons.list,
      Colors.orange,
      PaginationDemo(),
    ),
    _TopicItem(
      '07 — Offline-First',
      'Cache-then-network, stale indicator, connectivity fallback',
      Icons.cloud_off,
      Colors.blueGrey,
      OfflineFirstDemo(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phase 4 — Networking & Data'),
        backgroundColor: Colors.cyan,
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _topics.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final t = _topics[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: t.color.withOpacity(0.15),
                child: Icon(t.icon, color: t.color, size: 22),
              ),
              title: Text(t.label,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(t.subtitle,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => t.demo),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TopicItem {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget demo;

  const _TopicItem(
      this.label, this.subtitle, this.icon, this.color, this.demo);
}
