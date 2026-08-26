# 🦋 Flutter Zero to Hero
> Learn Flutter from scratch to production-ready, step by step, with heavily commented code.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

---

## 📖 About This Repo

This is a **learning repository** — not a production app. Each phase lives in its own folder inside `lib/`, so you can explore any phase without switching branches.

Perfect for:
- Absolute beginners who are just starting to code
- Backend developers switching to mobile development
- Android/iOS native devs who want to learn Flutter

---

## 🗺️ How to Use This Repo

```bash
# 1. Clone the repo
git clone https://github.com/kanzankazu/Kanzan_Learn_Flutter.git
cd Kanzan_Learn_Flutter

# 2. Install dependencies
flutter pub get

# 3. Open the Hub — semua phase bisa diakses dari sini
flutter run          # buka lib/main.dart (Hub utama, semua phase tampil sebagai menu)

# 4. Atau jalankan phase tertentu langsung
flutter run -t lib/phase2/main_phase2.dart   # Phase 2 menu
dart run lib/phase0/main_phase0.dart         # Phase 0 (Dart CLI)
dart run lib/phase1/main_phase1.dart         # Phase 1 (Dart CLI)

# 5. Atau langsung ke topik spesifik
flutter run -t lib/phase2/01_stateless_stateful/stateless_stateful_demo.dart
```

> **Tips:** Each file has detailed comments explaining concepts for beginners. Read the comments!

---

## 🎯 Where to Start?

| Your Profile | Start from | Estimated Duration |
|---|---|---|
| Never coded before | `lib/phase0/` | ~6 months |
| Already know how to code (Python/Java/JS) | `lib/phase1/` | ~3.5 months |
| Mobile native dev (Android/iOS) | `lib/phase1/` *(fast track)* | ~2-3 months |
| Already familiar with Flutter basics | `lib/phase3/` | ~2 months |

---

## 📁 Folder Structure

All phases live in `lib/` — no branch switching needed.
Run `flutter run` (tanpa `-t`) untuk buka **Hub Screen** yang menampilkan semua phase sekaligus.

```
lib/
├── main.dart        ← 🏠 Hub utama — daftar semua phase, tap untuk masuk
│
├── phase0/          ← Dart CLI: variables, OOP, collections, error handling
│   ├── 01_variables/
│   ├── ...
│   ├── mini_projects/
│   └── main_phase0.dart    ← entry point (dart run)
│
├── phase1/          ← Dart: null safety, async/await, Future, Stream, generics
│   ├── 01_null_safety/
│   ├── ...
│   ├── mini_projects/
│   └── main_phase1.dart    ← entry point (dart run)
│
├── phase2/          ← Flutter UI fundamentals
│   ├── 01_stateless_stateful/
│   ├── ...
│   ├── mini_projects/
│   └── main_phase2.dart    ← entry point (flutter run -t)
│
├── phase3/          ← State management (Riverpod) & navigation (GoRouter)
│   └── main_phase3.dart
├── phase4/          ← Networking & data (Dio, Hive, pagination)
│   └── main_phase4.dart
├── phase5/          ← Clean architecture, SOLID, DI
│   └── main_phase5.dart
├── phase6/          ← Advanced Flutter (CustomPainter, Slivers, Animation)
│   └── main_phase6.dart
├── phase7/          ← Testing (unit, widget, integration, golden)
│   └── main_phase7.dart
├── phase8/          ← Deployment & DevOps (flavors, CI/CD, Play Store)
│   └── main_phase8.dart
├── phase9/          ← Portfolio & Job Ready
│   └── main_phase9.dart
└── phase10/
    ├── 10_1_web_desktop/   ← Track 1: Web & Desktop
    ├── 10_2_advanced_state/ ← Track 2: Advanced State
    ├── 10_3_native_interop/ ← Track 3: Native Interop
    ├── 10_4_performance/    ← Track 4: Performance
    ├── 10_5_super_app/      ← Track 5: Super App
    ├── 10_6_backend/        ← Track 6: Backend Integration
    └── 10_7_ai_ml/          ← Track 7: AI/ML Mobile
```

---

## 🧭 Visual Roadmap

```
[Never coded]──┐
               ▼
         Phase 0: Programming Fundamentals (2-3 weeks)
         lib/phase0/  →  dart run lib/phase0/main_phase0.dart
               │
[Know coding]──▶│
               ▼
         Phase 1: Dart Language (1-2 weeks)
         lib/phase1/  →  dart run lib/phase1/main_phase1.dart
               │
               ▼
         Phase 2: Flutter Fundamentals (3-4 weeks)
         lib/phase2/  →  flutter run -t lib/phase2/main_phase2.dart
               │
               ▼
       ✅ MILESTONE 1: Can clone any app UI
               │
               ▼
         Phase 3: State & Navigation   lib/phase3/  ✅
         Phase 4: Networking & Data    lib/phase4/  ✅
         Phase 5: Architecture         lib/phase5/  ✅
               │
               ▼
       ✅ MILESTONE 2: Intermediate Flutter Dev
               │
               ▼
         Phase 6: Advanced Flutter     lib/phase6/  ✅
         Phase 7: Testing              lib/phase7/  ✅
         Phase 8: Deployment           lib/phase8/  ✅
               │
               ▼
       ✅ MILESTONE 3: Production-Ready
               │
               ▼
         Phase 9: Portfolio            lib/phase9/  ✅
         Phase 10.1: Web & Desktop     lib/phase10/10_1_web_desktop/    ✅
         Phase 10.2: Advanced State    lib/phase10/10_2_advanced_state/ ✅
         Phase 10.3: Native Interop    lib/phase10/10_3_native_interop/ ✅
         Phase 10.4: Performance       lib/phase10/10_4_performance/    ✅
         Phase 10.5: Super App         lib/phase10/10_5_super_app/      ✅
         Phase 10.6: Backend           lib/phase10/10_6_backend/        ✅
         Phase 10.7: AI/ML Mobile      lib/phase10/10_7_ai_ml/          ✅
```

---

## 📚 Learning Phases

### 🟢 Beginner Track

| Folder | Topics | How to Run | Status |
|---|---|---|---|
| `lib/phase0/` | Variables, OOP, Collections, Error Handling (Dart CLI) | `dart run lib/phase0/main_phase0.dart` | ✅ Ready |
| `lib/phase1/` | Null Safety, Async/Await, Future, Stream, Generics, Mixins | `dart run lib/phase1/main_phase1.dart` | ✅ Ready |
| `lib/phase2/` | Widget Tree, Layout, Forms, Theming, Animation | `flutter run -t lib/phase2/main_phase2.dart` | ✅ Ready |

**🏆 Milestone 1:** Able to clone a well-known app UI (Grab, Tokopedia)

---

### 🔵 Intermediate Track

| Folder | Topics | Status |
|---|---|---|
| `lib/phase3/` | Riverpod, GoRouter, Navigation, Deep Links | ✅ Ready |
| `lib/phase4/` | Dio, freezed, Hive/Isar, Firebase | ✅ Ready |
| `lib/phase5/` | Clean Architecture, Repository Pattern, SOLID | ✅ Ready |

**🏆 Milestone 2:** Able to build a CRUD app + API + proper state management

---

### 🟠 Advanced Track

| Folder | Topics | Status |
|---|---|---|
| `lib/phase6/` | Custom Painter, Slivers, Advanced Animation, Platform Channels, Responsive, Accessibility, i18n | ✅ Ready |
| `lib/phase7/` | Unit Test, Widget Test, Integration Test, Mocking | ✅ Ready |
| `lib/phase8/` | Flavors, App Signing, CI/CD, Play Store, Crashlytics | ✅ Ready |

**🏆 Milestone 3:** Production-ready — advanced + tested + published

---

### 🟣 Expert Track

| Folder | Topics | Status |
|---|---|---|
| `lib/phase9/` | Production-Quality Portfolio App | ✅ Ready |
| `lib/phase10/10_1_web_desktop/` | Track 1 — Web & Desktop (Responsive Web, PWA, Dart Frog) | ✅ Ready |
| `lib/phase10/10_2_advanced_state/` | Track 2 — Advanced State (Riverpod Generator, Offline-first, CRDT) | ✅ Ready |
| `lib/phase10/10_3_native_interop/` | Track 3 — Native Interop (Method/Event Channel, Pigeon, Dart FFI) | ✅ Ready |
| `lib/phase10/10_4_performance/` | Track 4 — Performance (DevTools, Custom RenderObject, Shader) | ✅ Ready |
| `lib/phase10/10_5_super_app/` | Track 5 — Super App (Melos, Micro-frontend, Feature Flags) | ✅ Ready |
| `lib/phase10/10_6_backend/` | Track 6 — Backend (GraphQL, gRPC, Supabase, CRDT) | ✅ Ready |
| `lib/phase10/10_7_ai_ml/` | Track 7 — AI/ML Mobile (TFLite, ML Kit, On-device LLM) | ✅ Ready |

---

## 💡 Learning Tips

1. **Code every day** — 1 hour/day is better than 8 hours once a week
2. **Read code comments** — every file already has beginner-friendly explanations
3. **Build your own projects** — don't just copy-paste, understand it first then modify
4. **Use hot reload** — change a value, save, see the result instantly
5. **Read error messages** — Flutter error messages are very informative

---

## 🛠️ Prerequisites

Before starting, make sure you have installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (latest stable version)
- [VS Code](https://code.visualstudio.com/) + [Flutter](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter) & [Dart](https://marketplace.visualstudio.com/items?itemName=Dart-Code.dart-code) extensions
- **Or** [Android Studio](https://developer.android.com/studio) with Flutter plugin
- [Git](https://git-scm.com/)
- Android Emulator / iOS Simulator (for Phase 2+)

Verify installation:

```bash
flutter doctor
```

---

## 📦 Tech Stack Used in This Repo

| Need | Package | Introduced in Phase |
|---|---|---|
| HTTP Client | [http](https://pub.dev/packages/http) | Phase 1 (Weather CLI) |
| State Management | [Riverpod](https://riverpod.dev) | Phase 3 |
| Navigation | [GoRouter](https://pub.dev/packages/go_router) | Phase 3 |
| Networking | [Dio](https://pub.dev/packages/dio) | Phase 4 |
| JSON Serialization | [freezed](https://pub.dev/packages/freezed) | Phase 4 |
| Local Database | [Isar](https://isar.dev) | Phase 4 |
| Testing | flutter_test, [mockito](https://pub.dev/packages/mockito) | Phase 7 |

---

## 🤝 Contributing

Found a typo, confusing code, or want to request a new topic?

1. Fork this repo
2. Create a branch: `fix/short-description` or `feat/new-topic`
3. Commit with a clear message
4. Open a Pull Request

---

## 📬 Contact & Community

- **Author:** [Faisal Bahri](https://github.com/kanzankazu)
- **Issues:** [github.com/kanzankazu/Kanzan_Learn_Flutter/issues](../../issues)
- **Flutter Community:** [Flutter ID](https://t.me/flutter_id) on Telegram

---

## 📄 License

This repo uses the [MIT](LICENSE) license — free to use for learning and personal projects.

---

<div align="center">

If this repo helped you learn Flutter, consider buying me a coffee ☕

[![Saweria](https://img.shields.io/badge/Saweria-Donate-orange?logo=ko-fi&logoColor=white)](https://saweria.co/kanzankazu)

**[saweria.co/kanzankazu](https://saweria.co/kanzankazu)**

Supports transfer bank & QRIS — any amount is appreciated 🙏

</div>

---

## 🟢 Phase 0 — Programming Fundamentals

> Folder: `lib/phase0/`
> Status: ✅ Done

### Topics Covered

| No | Topic | File |
|---|---|---|
| 1 | Variables & Data Types | `lib/phase0/01_variables/variables_demo.dart` |
| 2 | Operators | `lib/phase0/02_operators/operators_demo.dart` |
| 3 | Control Flow | `lib/phase0/03_control_flow/control_flow_demo.dart` |
| 4 | Functions | `lib/phase0/04_functions/functions_demo.dart` |
| 5 | Collections (List, Map, Set) | `lib/phase0/05_collections/collections_demo.dart` |
| 6 | OOP (Object-Oriented Programming) | `lib/phase0/06_oop/oop_demo.dart` |
| 7 | Error Handling | `lib/phase0/07_error_handling/error_handling_demo.dart` |

### How to Run

```bash
dart run lib/phase0/main_phase0.dart
```

### Mini Projects

| Project | How to Run |
|---|---|
| 🧮 Calculator CLI | `dart run lib/phase0/mini_projects/calculator/calculator.dart` |
| 📝 To-Do List CLI | `dart run lib/phase0/mini_projects/todo/todo_app.dart` |
| 🎯 Guess the Number | `dart run lib/phase0/mini_projects/guess_number/guess_number.dart` |

---

## 🔵 Phase 1 — Dart Language

> Folder: `lib/phase1/`
> Status: ✅ Done

### Topics Covered

| No | Topic | File |
|---|---|---|
| 1 | Null Safety | `lib/phase1/01_null_safety/null_safety_demo.dart` |
| 2 | Async/Await & Future | `lib/phase1/02_async_future/async_future_demo.dart` |
| 3 | Stream | `lib/phase1/03_stream/stream_demo.dart` |
| 4 | Advanced Collections | `lib/phase1/04_collections_advanced/collections_advanced_demo.dart` |
| 5 | Extension Methods | `lib/phase1/05_extensions/extensions_demo.dart` |
| 6 | Enhanced Enums (Dart 3) | `lib/phase1/06_enum_enhanced/enum_enhanced_demo.dart` |
| 7 | Pattern Matching & Sealed Classes | `lib/phase1/07_pattern_matching/pattern_matching_demo.dart` |
| 8 | Generics | `lib/phase1/08_generics/generics_demo.dart` |
| 9 | Mixins | `lib/phase1/09_mixins/mixins_demo.dart` |
| 10 | Records & Destructuring | `lib/phase1/10_records/records_demo.dart` |
| 11 | Isolates (Intro) | `lib/phase1/11_isolates/isolates_demo.dart` |

### How to Run

```bash
dart run lib/phase1/main_phase1.dart
```

### Mini Projects

| Project | How to Run |
|---|---|
| 🌤️ Weather CLI App | `OPENWEATHER_API_KEY=your_key dart run lib/phase1/mini_projects/weather/weather_app.dart Jakarta` |
| 📄 File Processor CLI | `dart run lib/phase1/mini_projects/file_processor/file_processor.dart stats lib/phase1/mini_projects/file_processor/sample.txt` |

> **Weather App note:** Get a free API key at [openweathermap.org](https://openweathermap.org/api).

---

## 🟡 Phase 2 — Flutter Fundamentals

> Folder: `lib/phase2/`
> Status: 🟡 In Progress (11/12 topics done)

### How to Run

```bash
# Main menu (all topics)
flutter run -t lib/phase2/main_phase2.dart

# Or run a specific topic directly
flutter run -t lib/phase2/01_stateless_stateful/stateless_stateful_demo.dart
flutter run -t lib/phase2/02_layout_widgets/layout_demo.dart
flutter run -t lib/phase2/03_container_decoration/container_demo.dart
flutter run -t lib/phase2/04_scrollable/scrollable_demo.dart
flutter run -t lib/phase2/05_input_widgets/input_demo.dart
flutter run -t lib/phase2/06_buttons_scaffold/buttons_demo.dart
flutter run -t lib/phase2/07_image_icon_dialog_snackbar/media_dialog_demo.dart
flutter run -t lib/phase2/08_custom_widget/custom_widget_demo.dart
flutter run -t lib/phase2/09_theming/theming_demo.dart
flutter run -t lib/phase2/10_responsive_layout/responsive_demo.dart
flutter run -t lib/phase2/11_animation/animation_demo.dart
flutter run -t lib/phase2/12_gesture_lifecycle/gesture_lifecycle_demo.dart
```

### Topics Covered

| No | Topic | File | Status |
|---|---|---|---|
| 01 | StatelessWidget & StatefulWidget | `lib/phase2/01_stateless_stateful/stateless_stateful_demo.dart` | ✅ |
| 02 | Layout Widgets (Column, Row, Stack, Expanded) | `lib/phase2/02_layout_widgets/layout_demo.dart` | ✅ |
| 03 | Container & BoxDecoration | `lib/phase2/03_container_decoration/container_demo.dart` | ✅ |
| 04 | Scrollable (ListView, GridView, SingleChildScrollView) | `lib/phase2/04_scrollable/scrollable_demo.dart` | ✅ |
| 05 | Input Widgets (TextField, Form, validation) | `lib/phase2/05_input_widgets/input_demo.dart` | ✅ |
| 06 | Button Widgets & AppBar/Scaffold | `lib/phase2/06_buttons_scaffold/buttons_demo.dart` | ✅ |
| 07 | Image, Icon, Dialog & SnackBar | `lib/phase2/07_image_icon_dialog_snackbar/media_dialog_demo.dart` | ✅ |
| 08 | Custom Widget (extract & composition) | `lib/phase2/08_custom_widget/custom_widget_demo.dart` | ✅ |
| 09 | Theming (ThemeData, ColorScheme, dark mode) | `lib/phase2/09_theming/theming_demo.dart` | ✅ |
| 10 | Responsive Layout (MediaQuery, LayoutBuilder) | `lib/phase2/10_responsive_layout/responsive_demo.dart` | ✅ |
| 11 | Basic Animation (AnimatedContainer, Hero, AnimatedSwitcher) | `lib/phase2/11_animation/animation_demo.dart` | ✅ |
| 12 | GestureDetector & Widget Lifecycle | `lib/phase2/12_gesture_lifecycle/gesture_lifecycle_demo.dart` | 🚧 |

### Mini Projects

| Project | How to Run | Status |
|---|---|---|
| 👤 Profile Card App | `flutter run -t lib/phase2/mini_projects/profile_card/profile_card_app.dart` | ✅ |
| 🧮 Calculator App | `flutter run -t lib/phase2/mini_projects/calculator/calculator_app.dart` | ✅ |
| 🍳 Recipe App | `flutter run -t lib/phase2/mini_projects/recipe_app/recipe_app.dart` | ✅ |

**🏆 Milestone 1:** Can clone a well-known app UI (Grab/Tokopedia)

---

## 🔵 Phase 3 — State Management & Navigation

> Folder: `lib/phase3/`
> Status: ✅ Done

### How to Run

```bash
# Main menu (all topics)
flutter run -t lib/phase3/main_phase3.dart

# Or run a specific topic directly
flutter run -t lib/phase3/01_go_router_basics/go_router_basics_demo.dart
flutter run -t lib/phase3/02_passing_data/passing_data_demo.dart
flutter run -t lib/phase3/03_bottom_nav/bottom_nav_demo.dart
flutter run -t lib/phase3/04_deep_linking/deep_linking_demo.dart
flutter run -t lib/phase3/05_riverpod/riverpod_demo.dart
flutter run -t lib/phase3/06_local_vs_global/local_vs_global_demo.dart
flutter run -t lib/phase3/07_bloc/bloc_demo.dart

# Mini projects
flutter run -t lib/phase3/mini_projects/todo_app/todo_app.dart
flutter run -t lib/phase3/mini_projects/shopping_cart/shopping_cart_app.dart
```

### Topics Covered

| No | Topic | File | Status |
|---|---|---|---|
| 01 | Named Routes & GoRouter Basics | `lib/phase3/01_go_router_basics/go_router_basics_demo.dart` | ✅ |
| 02 | Passing Data Between Screens (path param, query param, extra) | `lib/phase3/02_passing_data/passing_data_demo.dart` | ✅ |
| 03 | Bottom Navigation + Nested Navigator (`StatefulShellRoute`) | `lib/phase3/03_bottom_nav/bottom_nav_demo.dart` | ✅ |
| 04 | Deep Linking + Auth Redirect (`refreshListenable`) | `lib/phase3/04_deep_linking/deep_linking_demo.dart` | ✅ |
| 05 | Riverpod — Provider, StateNotifier, FutureProvider, StreamProvider | `lib/phase3/05_riverpod/riverpod_demo.dart` | ✅ |
| 06 | Local State vs Global State — when to use which | `lib/phase3/06_local_vs_global/local_vs_global_demo.dart` | ✅ |
| 07 | BLoC — Cubit, Bloc, BlocBuilder, BlocListener, BlocConsumer | `lib/phase3/07_bloc/bloc_demo.dart` | ✅ |

### Packages Used

| Package | Version | Purpose |
|---|---|---|
| `flutter_riverpod` | ^2.5.1 | State management (Riverpod) |
| `go_router` | ^17.5.0 | Declarative navigation |
| `flutter_bloc` | ^9.1.1 | State management (BLoC) |

### Mini Projects

| Project | How to Run | What it Practices |
|---|---|---|
| ✅ Multi-screen Todo App | `flutter run -t lib/phase3/mini_projects/todo_app/todo_app.dart` | GoRouter + Riverpod StateNotifier + filter + form validation |
| 🛍️ Shopping Cart App | `flutter run -t lib/phase4/mini_projects/shopping_cart/shopping_cart_app.dart` | FutureProvider + derived providers + multi-screen flow |

**🏆 Milestone 2:** Can build a CRUD app + API + proper state management

---

## 🔵 Phase 4 — Networking & Data

> Folder: `lib/phase4/`
> Status: 🟡 In Progress (7/8 topics done — Firebase pending)

### How to Run

```bash
# Main menu (all topics)
flutter run -t lib/phase4/main_phase4.dart

# Or run a specific topic directly
flutter run -t lib/phase4/01_dio_basics/dio_basics_demo.dart
flutter run -t lib/phase4/02_json_serialization/json_serialization_demo.dart
flutter run -t lib/phase4/03_state_pattern/state_pattern_demo.dart
flutter run -t lib/phase4/04_local_storage/local_storage_demo.dart
flutter run -t lib/phase4/05_image_caching/image_caching_demo.dart
flutter run -t lib/phase4/06_pagination/pagination_demo.dart
flutter run -t lib/phase4/07_offline_first/offline_first_demo.dart

# Mini projects
flutter run -t lib/phase4/mini_projects/weather_app/weather_app.dart
flutter run -t lib/phase4/mini_projects/news_reader/news_reader_app.dart
```

### Topics Covered

| No | Topic | File | Status |
|---|---|---|---|
| 01 | Dio Basics — GET, POST, Interceptors, Error Handling, Cancel Token | `lib/phase4/01_dio_basics/dio_basics_demo.dart` | ✅ |
| 02 | JSON Serialization — manual fromJson/toJson, copyWith, Result\<T\> | `lib/phase4/02_json_serialization/json_serialization_demo.dart` | ✅ |
| 03 | State Pattern — sealed `AsyncState<T>`: loading / error / success | `lib/phase4/03_state_pattern/state_pattern_demo.dart` | ✅ |
| 04 | Local Storage — SharedPreferences + Hive with TypeAdapter | `lib/phase4/04_local_storage/local_storage_demo.dart` | ✅ |
| 05 | Image Caching — CachedNetworkImage, placeholder, error widget | `lib/phase4/05_image_caching/image_caching_demo.dart` | ✅ |
| 06 | Pagination & Infinite Scroll — ScrollController, page-based API | `lib/phase4/06_pagination/pagination_demo.dart` | ✅ |
| 07 | Offline-First — cache-then-network, stale indicators | `lib/phase4/07_offline_first/offline_first_demo.dart` | ✅ |
| 08 | Firebase — Auth, Firestore, Storage, FCM | — | 🚧 |

### Packages Used

| Package | Version | Purpose |
|---|---|---|
| `dio` | ^5.11.0 | HTTP client |
| `shared_preferences` | ^2.5.5 | Key-value settings |
| `hive_flutter` | ^1.1.0 | Local NoSQL database |
| `cached_network_image` | ^3.4.1 | Image caching |
| `freezed_annotation` | ^3.1.0 | Data class annotations |

### Mini Projects

| Project | How to Run | What it Practices |
|---|---|---|
| 🌤️ Weather App | `flutter run -t lib/phase4/mini_projects/weather_app/weather_app.dart` | Dio + Open-Meteo API + SharedPrefs last city + sealed state |
| 📰 News Reader App | `flutter run -t lib/phase4/mini_projects/news_reader/news_reader_app.dart` | Pagination + Hive cache + CachedNetworkImage + bookmarks + tabs |

---

## 🔵 Phase 5 — Architecture & Clean Code

> Folder: `lib/phase5/`
> Status: 🟡 In Progress (6/7 topics done — code generation pending)

### How to Run

```bash
# Main menu (all topics)
flutter run -t lib/phase5/main_phase5.dart

# Or run a specific topic directly
flutter run -t lib/phase5/01_solid/solid_demo.dart
flutter run -t lib/phase5/02_repository_pattern/repository_pattern_demo.dart
flutter run -t lib/phase5/03_clean_architecture/clean_architecture_demo.dart
flutter run -t lib/phase5/04_use_cases/use_cases_demo.dart
flutter run -t lib/phase5/05_dependency_injection/di_demo.dart
flutter run -t lib/phase5/06_error_handling/error_handling_demo.dart

# Mini project
flutter run -t lib/phase5/mini_projects/weather_clean/weather_clean_app.dart
```

### Topics Covered

| No | Topic | File | Status |
|---|---|---|---|
| 01 | SOLID Principles — SRP, OCP, LSP, ISP, DIP (before/after for each) | `lib/phase5/01_solid/solid_demo.dart` | ✅ |
| 02 | Repository Pattern — abstract interface + multiple implementations | `lib/phase5/02_repository_pattern/repository_pattern_demo.dart` | ✅ |
| 03 | Clean Architecture — data/domain/presentation layers + DTOs | `lib/phase5/03_clean_architecture/clean_architecture_demo.dart` | ✅ |
| 04 | Use Cases — when to create vs when to skip (passthrough anti-pattern) | `lib/phase5/04_use_cases/use_cases_demo.dart` | ✅ |
| 05 | Dependency Injection — get_it (factory, singleton, lazySingleton) | `lib/phase5/05_dependency_injection/di_demo.dart` | ✅ |
| 06 | Error Handling — sealed `Result<T>`, typed `AppError` hierarchy | `lib/phase5/06_error_handling/error_handling_demo.dart` | ✅ |
| 07 | Code Generation — freezed, json_serializable, build_runner | — | 🚧 |

### Packages Used

| Package | Version | Purpose |
|---|---|---|
| `get_it` | ^9.2.1 | Dependency injection service locator |

### Mini Project

| Project | How to Run | What it Practices |
|---|---|---|
| 🌤️ Weather App (Clean Architecture) | `flutter run -t lib/phase5/mini_projects/weather_clean/weather_clean_app.dart` | Phase 4 Weather App refactored: domain/data/presentation + Repository + Use Case + get_it + Result\<T\> |

> 💡 Compare `lib/phase4/mini_projects/weather_app/` vs `lib/phase5/mini_projects/weather_clean/` to see exactly what Clean Architecture changes.

---

## 🟠 Phase 6 — Advanced Flutter

> Folder: `lib/phase6/`
> Status: ✅ Done

### How to Run

```bash
# Main menu (all topics)
flutter run -t lib/phase6/main_phase6.dart

# Or run a specific topic directly
flutter run -t lib/phase6/01_custom_painter/custom_painter_demo.dart
flutter run -t lib/phase6/02_slivers/slivers_demo.dart
flutter run -t lib/phase6/03_advanced_animation/advanced_animation_demo.dart
flutter run -t lib/phase6/04_platform_channels/platform_channels_demo.dart
flutter run -t lib/phase6/05_responsive_adaptive/responsive_adaptive_demo.dart
flutter run -t lib/phase6/06_accessibility/accessibility_demo.dart
flutter run -t lib/phase6/07_internationalization/internationalization_demo.dart
```

### Topics Covered

| No | Topic | File | Status |
|---|---|---|---|
| 01 | Custom Painter — shapes, animated arc, bar chart via Canvas API | `lib/phase6/01_custom_painter/custom_painter_demo.dart` | ✅ |
| 02 | Slivers — SliverAppBar, SliverList, SliverGrid, SliverPersistentHeader | `lib/phase6/02_slivers/slivers_demo.dart` | ✅ |
| 03 | Advanced Animation — AnimationController, Tween, CurvedAnimation, Stagger | `lib/phase6/03_advanced_animation/advanced_animation_demo.dart` | ✅ |
| 04 | Platform Channels — MethodChannel (one-shot) + EventChannel (stream) | `lib/phase6/04_platform_channels/platform_channels_demo.dart` | ✅ |
| 05 | Responsive & Adaptive — MediaQuery, LayoutBuilder, phone vs tablet nav | `lib/phase6/05_responsive_adaptive/responsive_adaptive_demo.dart` | ✅ |
| 06 | Accessibility — Semantics, MergeSemantics, ExcludeSemantics, live regions | `lib/phase6/06_accessibility/accessibility_demo.dart` | ✅ |
| 07 | Internationalization — ARB files, flutter gen-l10n, intl, RTL support | `lib/phase6/07_internationalization/internationalization_demo.dart` | ✅ |

### Mini Project

| Project | How to Run | What it Practices |
|---|---|---|
| 💪 Fitness Tracker App | `flutter run -t lib/phase6/mini_projects/fitness_tracker/fitness_tracker_app.dart` | Custom Painter progress rings + Slivers collapsing header + Responsive layout | 🚧 |

**🏆 Milestone 3:** Production-ready — advanced + tested + published

---

## 🟠 Phase 7 — Testing

> Folder: `lib/phase7/`
> Status: ✅ Done

### How to Run

```bash
# Demo app (concepts + interactive examples)
flutter run -t lib/phase7/main_phase7.dart

# Or run a specific topic
flutter run -t lib/phase7/01_unit_test/unit_test_demo.dart
flutter run -t lib/phase7/02_widget_test/widget_test_demo.dart
flutter run -t lib/phase7/03_integration_test/integration_test_demo.dart
flutter run -t lib/phase7/04_mocking/mocking_demo.dart
flutter run -t lib/phase7/05_code_coverage/code_coverage_demo.dart
flutter run -t lib/phase7/06_golden_test/golden_test_demo.dart

# Run the actual tests (in test/phase7/)
flutter test test/phase7/
flutter test --coverage
flutter test --update-goldens     # regenerate golden files
```

### Topics Covered

| No | Topic | File | Status |
|---|---|---|---|
| 01 | Unit Test — test(), expect(), matchers, group, setUp/tearDown, async | `lib/phase7/01_unit_test/unit_test_demo.dart` | ✅ |
| 02 | Widget Test — testWidgets(), Finder, pump/pumpAndSettle, interactions | `lib/phase7/02_widget_test/widget_test_demo.dart` | ✅ |
| 03 | Integration Test — full app on real device, Page Object Model | `lib/phase7/03_integration_test/integration_test_demo.dart` | ✅ |
| 04 | Mocking — mockito vs mocktail, when/verify, Mock vs Fake vs Stub | `lib/phase7/04_mocking/mocking_demo.dart` | ✅ |
| 05 | Code Coverage — flutter test --coverage, genhtml, CI enforcement | `lib/phase7/05_code_coverage/code_coverage_demo.dart` | ✅ |
| 06 | Golden Test — matchesGoldenFile, --update-goldens, golden_toolkit | `lib/phase7/06_golden_test/golden_test_demo.dart` | ✅ |

### Test Pyramid

```
    ▲  Integration  — few, slow, high confidence (full app on real device)
   ■■■ Widget       — moderate, medium speed (component + state)
  ●●●●● Unit        — many, fast, isolated (function / class)
```

### Quick Reference

| Command | What it does |
|---|---|
| `flutter test` | Run all tests |
| `flutter test test/phase7/` | Run a specific folder |
| `flutter test --coverage` | Run with coverage → `coverage/lcov.info` |
| `flutter test --name "login"` | Filter by test name |
| `flutter test --update-goldens` | Regenerate golden PNG files |

---

## 🟠 Phase 8 — Deployment & DevOps

> Folder: `lib/phase8/`
> Status: ✅ Done

### How to Run

```bash
# Demo app (concepts + interactive examples)
flutter run -t lib/phase8/main_phase8.dart

# Or run a specific topic
flutter run -t lib/phase8/01_build_flavors/build_flavors_demo.dart
flutter run -t lib/phase8/02_app_signing/app_signing_demo.dart
flutter run -t lib/phase8/03_ci_cd/ci_cd_demo.dart
flutter run -t lib/phase8/04_play_store/play_store_demo.dart
flutter run -t lib/phase8/05_crashlytics_analytics/crashlytics_analytics_demo.dart
flutter run -t lib/phase8/06_code_obfuscation/code_obfuscation_demo.dart
```

### Topics Covered

| No | Topic | File | Status |
|---|---|---|---|
| 01 | Build Flavors — --dart-define-from-file, AppConfig, productFlavors | `lib/phase8/01_build_flavors/build_flavors_demo.dart` | ✅ |
| 02 | App Signing — Android keystore, key.properties, CI signing, Play App Signing | `lib/phase8/02_app_signing/app_signing_demo.dart` | ✅ |
| 03 | CI/CD — GitHub Actions: analyze → test → build AAB → distribute | `lib/phase8/03_ci_cd/ci_cd_demo.dart` | ✅ |
| 04 | Play Store — AAB, versioning, release tracks, staged rollout, checklist | `lib/phase8/04_play_store/play_store_demo.dart` | ✅ |
| 05 | Crashlytics & Analytics — FlutterError.onError, recordError, screen tracking | `lib/phase8/05_crashlytics_analytics/crashlytics_analytics_demo.dart` | ✅ |
| 06 | Code Obfuscation — --obfuscate, --split-debug-info, ProGuard, flutter symbolize | `lib/phase8/06_code_obfuscation/code_obfuscation_demo.dart` | ✅ |

### Key Build Commands

| Command | Output |
|---|---|
| `flutter build appbundle --release` | `.aab` for Play Store |
| `flutter build apk --release --split-per-abi` | `.apk` per architecture |
| `flutter build ipa --release` | `.ipa` for App Store |
| `flutter build appbundle --dart-define-from-file=config/prod.json` | Production build with env config |
| `flutter build appbundle --obfuscate --split-debug-info=build/symbols` | Obfuscated build |

**🏆 Milestone 3:** Production-ready — advanced + tested + published

---

## 🟣 Phase 9 — Portfolio & Job Ready

> Folder: `lib/phase9/`
> Status: ✅ Done

### How to Run

```bash
# Topic menu
flutter run -t lib/phase9/main_phase9.dart

# Portfolio app directly
flutter run -t lib/phase9/mini_projects/personal_finance/personal_finance_app.dart

# Or run a specific topic
flutter run -t lib/phase9/01_portfolio_planning/portfolio_planning_demo.dart
flutter run -t lib/phase9/02_clean_architecture_review/clean_architecture_review_demo.dart
flutter run -t lib/phase9/03_production_patterns/production_patterns_demo.dart
flutter run -t lib/phase9/04_github_best_practices/github_best_practices_demo.dart
flutter run -t lib/phase9/05_interview_prep/interview_prep_demo.dart
```

### Topics Covered

| No | Topic | File | Status |
|---|---|---|---|
| 01 | Portfolio Planning — what makes a strong portfolio, GitHub checklist, app ideas | `lib/phase9/01_portfolio_planning/portfolio_planning_demo.dart` | ✅ |
| 02 | Clean Architecture Review — layers, Entity/DTO/Mapper, Repository, Use Cases | `lib/phase9/02_clean_architecture_review/clean_architecture_review_demo.dart` | ✅ |
| 03 | Production Patterns — AsyncState, retry, offline-first, pagination, debounce, optimistic UI | `lib/phase9/03_production_patterns/production_patterns_demo.dart` | ✅ |
| 04 | GitHub Best Practices — Conventional Commits, branching, tags, profile README | `lib/phase9/04_github_best_practices/github_best_practices_demo.dart` | ✅ |
| 05 | Interview Prep — 20 Q&A: Dart, Flutter, state, performance, testing, patterns | `lib/phase9/05_interview_prep/interview_prep_demo.dart` | ✅ |

### Mini Project: Personal Finance Manager

A full production-quality portfolio app demonstrating all Phase 0–8 skills working together.

| Screen | Features |
|--------|----------|
| Dashboard | Net worth, income/expense summary, 6-month bar chart (Custom Painter), wallet cards, recent transactions |
| Transactions | Search, filter by type, amount summary, transaction list |
| Wallets | All wallets with balances, type icons, total net worth |
| Budget | Per-category monthly limits with progress bars, over-budget alerts |
| Analytics | Donut chart breakdown, category ranking with progress bars |

**Architecture:**

```
lib/phase9/mini_projects/personal_finance/
├── domain/
│   ├── entities/     transaction.dart, wallet.dart, budget.dart
│   ├── repositories/ i_transaction_repository.dart, i_wallet_repository.dart, i_budget_repository.dart
│   └── usecases/     add_transaction_usecase.dart (validates + saves + checks budget)
├── screens/          dashboard, transactions, wallets, budget, analytics
├── widgets/          amount_display, transaction_list_tile, wallet_card, monthly_bar_chart
└── personal_finance_app.dart
```

**🏆 Milestone — Zero to Hero Complete:** You can now build, test, and ship production-quality Flutter apps. Next: Phase 10 — choose your specialization track.

---

## 🟣 Phase 10.1 — Track 1: Web & Desktop

> Folder: `lib/phase10/10_1_web_desktop/`
> Status: ✅ Done

### How to Run

```bash
# Topic menu
flutter run -d chrome -t lib/phase10/10_1_web_desktop/main_phase10_1.dart

# Mini project — Admin Dashboard (best on Chrome or macOS)
flutter run -d chrome -t lib/phase10/10_1_web_desktop/mini_projects/dashboard_app/dashboard_app.dart
flutter run -d macos  -t lib/phase10/10_1_web_desktop/mini_projects/dashboard_app/dashboard_app.dart

# Build for web production
flutter build web --release --web-renderer skwasm
```

### Topics Covered

| No | Topic | File | Status |
|---|---|---|---|
| 01 | Responsive Web — breakpoints, MouseRegion, SelectionArea, fluid grid | `lib/phase10/10_1_web_desktop/01_responsive_web/responsive_web_demo.dart` | ✅ |
| 02 | PWA — manifest.json, service worker, install prompt, Lighthouse | `lib/phase10/10_1_web_desktop/02_pwa/pwa_demo.dart` | ✅ |
| 03 | Web-Specific APIs — URL strategy, clipboard, JS interop, file download | `lib/phase10/10_1_web_desktop/03_web_specific_apis/web_specific_apis_demo.dart` | ✅ |
| 04 | Desktop Layout — adaptive nav, master-detail, keyboard shortcuts, D&D | `lib/phase10/10_1_web_desktop/04_desktop_layout/desktop_layout_demo.dart` | ✅ |
| 05 | Dart Frog — server-side Dart, file-based routing, middleware, shared models | `lib/phase10/10_1_web_desktop/05_dart_frog/dart_frog_demo.dart` | ✅ |
| 06 | Web Performance — CanvasKit vs Skwasm, tree-shaking, deferred loading | `lib/phase10/10_1_web_desktop/06_flutter_web_performance/web_performance_demo.dart` | ✅ |

### Mini Project: Admin Dashboard

| Screen | Features |
|--------|----------|
| Dashboard | KPI cards (hover effect), 6-month bar chart (Custom Painter), donut chart, recent orders table |
| Users | PaginatedDataTable with sort, filter, pagination |
| Products | Fluid responsive grid with search + category filter |
| Settings | Toggle switches, slider, form |

**Layout adapts at:**
- `< 600px` → BottomNavigationBar
- `600–1100px` → Compact NavigationRail (icons only)
- `> 1100px` → Extended sidebar with labels + keyboard shortcuts (Alt+1–5)

---

## 🟣 Phase 10.2 — Track 2: Advanced State Management

> Folder: `lib/phase10/10_2_advanced_state/`
> Status: ✅ Done

```bash
flutter run -t lib/phase10/10_2_advanced_state/main_phase10_2.dart
flutter run -t lib/phase10/10_2_advanced_state/mini_projects/collaborative_notes/collaborative_notes_app.dart
```

| No | Topic | Key Concepts |
|---|---|---|
| 01 | Riverpod Generator | @riverpod, code-gen, AsyncNotifier, family, keepAlive |
| 02 | Offline-First Advanced | Sync queue, conflict resolution (LWW/Server-Wins), connectivity_plus |
| 03 | CRDT | G-Counter, LWW-Register, OR-Set, crdt package, HLC |
| 04 | State Machines | Sealed-class FSM, guard transitions, XState patterns |

**Mini Project:** Collaborative Notes — offline-first notes with sync queue, CRDT conflict resolution, and connectivity monitoring.

---

## 🟣 Phase 10.3 — Track 3: Native Interop

> Folder: `lib/phase10/10_3_native_interop/`
> Status: ✅ Done

```bash
flutter run -t lib/phase10/10_3_native_interop/main_phase10_3.dart
flutter run -t lib/phase10/10_3_native_interop/mini_projects/battery_plugin/battery_plugin_demo.dart
```

| No | Topic | Key Concepts |
|---|---|---|
| 01 | Advanced Channels | Error codes, bidirectional, timeout, test mocks |
| 02 | Pigeon | @HostApi/@FlutterApi, nested types, enums, code-gen |
| 03 | Dart FFI | DynamicLibrary, Pointer, Struct, Arena, ffigen |
| 04 | Plugin Development | Federated structure, platform interface, pub.dev checklist |

**Mini Project:** Battery Plugin — complete Pigeon-based plugin demo for battery level + charging state.

---

## 🟣 Phase 10.4 — Track 4: Performance

> Folder: `lib/phase10/10_4_performance/`
> Status: ✅ Done

```bash
flutter run -t lib/phase10/10_4_performance/main_phase10_4.dart
flutter run -t lib/phase10/10_4_performance/mini_projects/perf_dashboard/perf_dashboard_app.dart
```

| No | Topic | Key Concepts |
|---|---|---|
| 01 | DevTools Profiling | CPU profiler, rebuild stats, RepaintBoundary, Timeline |
| 02 | Custom RenderObject | performLayout, paint, hitTest, ring layout |
| 03 | Shader Effects | GLSL, FragmentProgram, wave/blur/noise, GPU rendering |
| 04 | Isolates & compute() | Isolate.run(), compute(), SendPort/ReceivePort, worker |

**Mini Project:** Performance Dashboard — live FPS counter, frame time chart (Custom Painter), jank detector, workload simulator.

---

## 🟣 Phase 10.5 — Track 5: Super App

> Folder: `lib/phase10/10_5_super_app/`
> Status: ✅ Done

```bash
flutter run -t lib/phase10/10_5_super_app/main_phase10_5.dart
flutter run -t lib/phase10/10_5_super_app/mini_projects/super_app_shell/super_app_shell.dart
```

| No | Topic | Key Concepts |
|---|---|---|
| 01 | Melos | Monorepo, bootstrap, scripts, versioning, conventional commits |
| 02 | Micro-Frontend | FeatureModule contract, registry, shell scaffold, dynamic routing |
| 03 | Feature Flags | Firebase Remote Config, A/B testing, local override, kill switch |
| 04 | Module Communication | EventBus, shared providers, module API interface |

**Mini Project:** Super App Shell — 3 modules (Wallet, Promo, Settings) with adaptive navigation, feature flags, and event bus.

---

## 🟣 Phase 10.6 — Track 6: Backend Integration

> Folder: `lib/phase10/10_6_backend/`
> Status: ✅ Done

```bash
flutter run -t lib/phase10/10_6_backend/main_phase10_6.dart
flutter run -t lib/phase10/10_6_backend/mini_projects/chat_app/chat_app.dart
```

| No | Topic | Key Concepts |
|---|---|---|
| 01 | GraphQL | Schema SDL, queries/mutations/subscriptions, graphql_flutter, ferry codegen |
| 02 | gRPC | .proto files, Dart stubs, unary/server-stream, interceptors |
| 03 | Supabase Advanced | RLS policies, realtime subscriptions, edge functions, storage |
| 04 | REST Advanced | OpenAPI codegen, cursor pagination, rate limiting, multipart upload |

**Mini Project:** Realtime Chat — Supabase realtime + optimistic UI + offline support.

---

## 🟣 Phase 10.7 — Track 7: AI/ML Mobile

> Folder: `lib/phase10/10_7_ai_ml/`
> Status: ✅ Done

```bash
flutter run -t lib/phase10/10_7_ai_ml/main_phase10_7.dart
flutter run -t lib/phase10/10_7_ai_ml/mini_projects/smart_scanner/smart_scanner_app.dart
```

| No | Topic | Key Concepts |
|---|---|---|
| 01 | TFLite | Interpreter.fromAsset, tensor I/O, GPU delegate, INT8 quantization |
| 02 | ML Kit | OCR (TextRecognizer), barcode scanner, InputImage, real-time processing |
| 03 | On-Device LLM | MediaPipe LLM, gemma nano, streaming tokens, prompt engineering |
| 04 | AI Patterns | On-device vs cloud, RAG, embedding search, hybrid pipeline, caching |

**Mini Project:** Smart Scanner — ML Kit OCR → extract receipt text → TFLite classifies expense category → user can correct.

---

## 🟣 Phase 10 — Specialization Complete

All 7 tracks done. Run any track:

```bash
# Track 1: Web & Desktop
flutter run -d chrome -t lib/phase10/10_1_web_desktop/main_phase10_1.dart

# Track 2: Advanced State
flutter run -t lib/phase10/10_2_advanced_state/main_phase10_2.dart

# Track 3: Native Interop
flutter run -t lib/phase10/10_3_native_interop/main_phase10_3.dart

# Track 4: Performance
flutter run -t lib/phase10/10_4_performance/main_phase10_4.dart

# Track 5: Super App
flutter run -t lib/phase10/10_5_super_app/main_phase10_5.dart

# Track 6: Backend
flutter run -t lib/phase10/10_6_backend/main_phase10_6.dart

# Track 7: AI/ML Mobile
flutter run -t lib/phase10/10_7_ai_ml/main_phase10_7.dart
```
