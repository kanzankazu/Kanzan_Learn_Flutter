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

# 3. Run the phase you want to learn
flutter run -t lib/phase2/main_phase2.dart   # Phase 2 menu
flutter run -t lib/phase1/main_phase1.dart   # Phase 1 menu
dart run lib/phase0/main_phase0.dart          # Phase 0 (Dart CLI)

# 4. Or run a specific topic directly
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

All phases live in `lib/` — no branch switching needed:

```
lib/
├── phase0/          ← Dart CLI: variables, OOP, collections, error handling
│   ├── 01_variables/
│   ├── ...
│   ├── mini_projects/
│   └── main_phase0.dart    ← entry point Phase 0
│
├── phase1/          ← Dart: null safety, async/await, Future, Stream, generics
│   ├── 01_null_safety/
│   ├── ...
│   ├── mini_projects/
│   └── main_phase1.dart    ← entry point Phase 1
│
├── phase2/          ← Flutter UI fundamentals
│   ├── 01_stateless_stateful/
│   ├── 02_layout_widgets/
│   ├── 03_container_decoration/
│   ├── 04_scrollable/
│   ├── 05_input_widgets/
│   ├── 06_buttons_scaffold/
│   ├── 07_image_icon_dialog_snackbar/
│   ├── 08_custom_widget/
│   ├── 09_theming/
│   ├── 10_responsive_layout/
│   ├── 11_animation/
│   ├── mini_projects/
│   │   ├── profile_card/
│   │   ├── calculator/
│   │   └── recipe_app/
│   └── main_phase2.dart    ← entry point Phase 2
│
├── phase3/          ← State management (Riverpod) & navigation (GoRouter)
│   ├── 01_go_router_basics/
│   ├── 02_passing_data/
│   ├── 03_bottom_nav/
│   ├── 04_deep_linking/
│   ├── 05_riverpod/
│   ├── 06_local_vs_global/
│   ├── mini_projects/
│   │   ├── todo_app/
│   │   └── shopping_cart/
│   └── main_phase3.dart    ← entry point Phase 3
│
├── phase4/          ← (Coming soon) Networking & data
├── phase5/          ← (Coming soon) Clean architecture
└── main.dart        ← Default Flutter entry point
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
         Phase 5: Architecture         lib/phase5/  🚧
               │
               ▼
       ✅ MILESTONE 2: Intermediate Flutter Dev
               │
               ▼
         Phase 6: Advanced Flutter     lib/phase6/  🚧
         Phase 7: Testing              lib/phase7/  🚧
         Phase 8: Deployment           lib/phase8/  🚧
               │
               ▼
       ✅ MILESTONE 3: Production-Ready
               │
               ▼
         Phase 9: Portfolio            lib/phase9/  🚧
         Phase 10: Specialization      lib/phase10/ 🚧
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
| `lib/phase5/` | Clean Architecture, Repository Pattern, SOLID | 🚧 Coming Soon |

**🏆 Milestone 2:** Able to build a CRUD app + API + proper state management

---

### 🟠 Advanced Track

| Folder | Topics | Status |
|---|---|---|
| `lib/phase6/` | Custom Painter, Slivers, Advanced Animation, Maps, FCM | 🚧 Coming Soon |
| `lib/phase7/` | Unit Test, Widget Test, Integration Test, Mocking | 🚧 Coming Soon |
| `lib/phase8/` | Flavors, App Signing, CI/CD, Play Store, Crashlytics | 🚧 Coming Soon |

**🏆 Milestone 3:** Production-ready — advanced + tested + published

---

### 🟣 Expert Track

| Folder | Topics | Status |
|---|---|---|
| `lib/phase9/` | Production-Quality Portfolio App | 🚧 Coming Soon |
| `lib/phase10/` | Choose a specialization track | 🚧 Coming Soon |

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

[![Saweria](https://img.shields.io/badge/Saweria-Donate-orange?logo=ko-fi&logoColor=white)](https://saweria.co/kanzankazu)

**[saweria.co/kanzankazu](https://saweria.co/kanzankazu)**

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
| 🛍️ Shopping Cart App | `flutter run -t lib/phase3/mini_projects/shopping_cart/shopping_cart_app.dart` | FutureProvider + derived providers + multi-screen flow |

**🏆 Milestone 2:** Can build a CRUD app + API + proper state management

---

## 🟢 Phase 4 — Networking & Data

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
