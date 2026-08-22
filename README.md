# 🦋 Flutter Zero to Hero
> Learn Flutter from scratch to production-ready, step by step, with heavily commented code.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

---

## 📖 About This Repo

This is a **learning repository** — not a production app. Each branch represents one Flutter learning phase, from programming fundamentals to Play Store deployment.

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

# 2. See all available branches
git branch -r

# 3. Checkout to the phase you need
git checkout phase/0-fondasi-pemrograman

# 4. Read the README in that branch for detailed guidance
```

> **Tips:** Start from the phase that matches your current level. Use the table below to find your entry point.

---

## 🎯 Where to Start?

| Your Profile | Start from Branch | Estimated Duration |
|---|---|---|
| Never coded before | `phase/0-fondasi-pemrograman` | ~6 months |
| Already know how to code (Python/Java/JS) | `phase/1-dart-language` | ~3.5 months |
| Mobile native dev (Android/iOS) | `phase/1-dart-language` *(fast track)* | ~2-3 months |
| Already familiar with Flutter basics | `phase/3-state-navigation` | ~2 months |

---

## 🌿 Learning Branches

### 🟢 Beginner Track

| Branch | Topics | Duration | Status |
|---|---|---|---|
| [`phase/0-fondasi-pemrograman`](../../tree/phase/0-fondasi-pemrograman) | Variables, OOP, Collections, Error Handling (Dart CLI) | 2-3 weeks | ✅ Ready |
| [`phase/1-dart-language`](../../tree/phase/1-dart-language) | Null Safety, Async/Await, Future, Stream, Generics, Mixins | 1-2 weeks | ✅ Ready |
| [`phase/2-flutter-fundamentals`](../../tree/phase/2-flutter-fundamentals) | Widget Tree, Layout, Forms, Basic Animation | 3-4 weeks | 🚧 Coming Soon |

**🏆 Milestone 1:** Able to clone a well-known app UI (Grab, Tokopedia)

---

### 🔵 Intermediate Track

| Branch | Topics | Duration | Status |
|---|---|---|---|
| [`phase/3-state-navigation`](../../tree/phase/3-state-navigation) | Riverpod, GoRouter, Navigation, Deep Links | 2-3 weeks | 🚧 Coming Soon |
| [`phase/4-networking-data`](../../tree/phase/4-networking-data) | Dio, freezed, Hive/Isar, Firebase | 2-3 weeks | 🚧 Coming Soon |
| [`phase/5-clean-architecture`](../../tree/phase/5-clean-architecture) | Clean Architecture, Repository Pattern, SOLID | 2-3 weeks | 🚧 Coming Soon |

**🏆 Milestone 2:** Able to build a CRUD app + API + proper state management

---

### 🟠 Advanced Track

| Branch | Topics | Duration | Status |
|---|---|---|---|
| [`phase/6-advanced-flutter`](../../tree/phase/6-advanced-flutter) | Custom Painter, Slivers, Advanced Animation, Maps, FCM | 3-4 weeks | 🚧 Coming Soon |
| [`phase/7-testing`](../../tree/phase/7-testing) | Unit Test, Widget Test, Integration Test, Mocking | 2 weeks | 🚧 Coming Soon |
| [`phase/8-deployment`](../../tree/phase/8-deployment) | Flavors, App Signing, CI/CD, Play Store, Crashlytics | 1-2 weeks | 🚧 Coming Soon |

**🏆 Milestone 3:** Production-ready — advanced + tested + published

---

### 🟣 Expert Track

| Branch | Topics | Status |
|---|---|---|
| [`phase/9-portfolio`](../../tree/phase/9-portfolio) | Production-Quality Portfolio App | 🚧 Coming Soon |
| [`phase/10-specialization`](../../tree/phase/10-specialization) | Choose a specialization track (Web, Native Interop, AI/ML, etc.) | 🚧 Coming Soon |

---

## 📚 Branch Structure

Each branch follows a consistent structure:

```
branch: phase/X-topic-name
├── README.md          ← Detailed guide for this phase (topics, how to run, mini project)
├── lib/
│   └── ...            ← Dart/Flutter code with explanatory comments
├── doc/               ← Additional materials, diagrams, notes
└── pubspec.yaml
```

---

## 🧭 Visual Roadmap

```
[Never coded]──┐
               ▼
         Phase 0: Programming Fundamentals (2-3 weeks)
               │
[Know coding]──▶│
               ▼
         Phase 1: Dart Language (1-2 weeks)
               │
[Know Flutter]─┼──────────────────────────┐
               ▼                          │
         Phase 2: Flutter Fundamentals    │
               │    (3-4 weeks)           │
               ▼                          │
       ✅ MILESTONE 1: Can build UI       │
               │                          ▼
               ▼                   Phase 3: State & Nav
         Phase 3: State & Nav ◀───────────┘
         Phase 4: Networking
         Phase 5: Architecture
               │
               ▼
       ✅ MILESTONE 2: Intermediate Dev
               │
               ▼
         Phase 6: Advanced Flutter
         Phase 7: Testing
         Phase 8: Deployment
               │
               ▼
       ✅ MILESTONE 3: Production-Ready
               │
               ▼
         Phase 9: Portfolio
         Phase 10: Specialization
```

---

## 💡 Learning Tips

1. **Code every day** — 1 hour/day is better than 8 hours once a week
2. **Read code comments** — every file already has beginner-friendly explanations
3. **Build your own projects** — don't just copy-paste, understand it first then modify
4. **Read error messages** — Flutter error messages are very informative
5. **Don't skip phases** — a strong foundation = a solid building

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

Read [CONTRIBUTING.md](CONTRIBUTING.md) for full guidelines.

---

## 📬 Contact & Community

- **Author:** [Faisal Bahri](https://github.com/kanzankazu)
- **Issues:** [github.com/kanzankazu/Kanzan_Learn_Flutter/issues](../../issues)
- **Flutter Community:** [Flutter ID](https://t.me/flutter_id) on Telegram

---

## 📄 License

This repo uses the [MIT](LICENSE) license — free to use for learning and personal projects.

---

## ☕ Support This Project

If this repo helped you learn Flutter, consider buying me a coffee!

All contributions go toward maintaining and expanding this learning repo.

<div align="center">

[![Saweria](https://img.shields.io/badge/Saweria-Donate-orange?logo=ko-fi&logoColor=white)](https://saweria.co/kanzankazu)

**[saweria.co/kanzankazu](https://saweria.co/kanzankazu)**

*Supports: Bank Transfer, QRIS, and more 🇮🇩*

</div>

---

<div align="center">

**⭐ If this repo helped you, give it a star!**

*Happy learning & keep building!* 🚀

</div>

---

## 🟢 Phase 0 — Fondasi Pemrograman

> Branch: `phase/0-fondasi-pemrograman`  
> Status: ✅ Selesai

### Topik yang Dipelajari

| No | Topik | File |
|---|---|---|
| 1 | Variabel & Tipe Data | `lib/phase0/01_variables/variables_demo.dart` |
| 2 | Operator | `lib/phase0/02_operators/operators_demo.dart` |
| 3 | Control Flow | `lib/phase0/03_control_flow/control_flow_demo.dart` |
| 4 | Function | `lib/phase0/04_functions/functions_demo.dart` |
| 5 | Collections (List, Map, Set) | `lib/phase0/05_collections/collections_demo.dart` |
| 6 | OOP (Object-Oriented Programming) | `lib/phase0/06_oop/oop_demo.dart` |
| 7 | Error Handling | `lib/phase0/07_error_handling/error_handling_demo.dart` |

### Cara Menjalankan Demo

```bash
# Entry point (menu pilih demo)
dart run lib/phase0/main_phase0.dart

# Atau langsung jalankan file demo tertentu:
dart run lib/phase0/01_variables/variables_demo.dart
dart run lib/phase0/02_operators/operators_demo.dart
dart run lib/phase0/03_control_flow/control_flow_demo.dart
dart run lib/phase0/04_functions/functions_demo.dart
dart run lib/phase0/05_collections/collections_demo.dart
dart run lib/phase0/06_oop/oop_demo.dart
dart run lib/phase0/07_error_handling/error_handling_demo.dart
```

### Mini Projects

| Project | Cara Jalankan |
|---|---|
| 🧮 Kalkulator CLI | `dart run lib/phase0/mini_projects/calculator/calculator.dart` |
| 📝 To-Do List CLI | `dart run lib/phase0/mini_projects/todo/todo_app.dart` |
| 🎯 Tebak Angka | `dart run lib/phase0/mini_projects/guess_number/guess_number.dart` |

---

## 🔵 Phase 1 — Dart Language

> Branch: `phase/1-dart-language`  
> Status: ✅ Selesai

### Topik yang Dipelajari

| No | Topik | File |
|---|---|---|
| 1 | Null Safety | `lib/phase1/01_null_safety/null_safety_demo.dart` |
| 2 | Async/Await & Future | `lib/phase1/02_async_future/async_future_demo.dart` |
| 3 | Stream | `lib/phase1/03_stream/stream_demo.dart` |
| 4 | Collections Advanced | `lib/phase1/04_collections_advanced/collections_advanced_demo.dart` |
| 5 | Extension Methods | `lib/phase1/05_extensions/extensions_demo.dart` |
| 6 | Enum Enhanced (Dart 3) | `lib/phase1/06_enum_enhanced/enum_enhanced_demo.dart` |
| 7 | Pattern Matching & Sealed Class | `lib/phase1/07_pattern_matching/pattern_matching_demo.dart` |
| 8 | Generics | `lib/phase1/08_generics/generics_demo.dart` |
| 9 | Mixins | `lib/phase1/09_mixins/mixins_demo.dart` |
| 10 | Records & Destructuring | `lib/phase1/10_records/records_demo.dart` |
| 11 | Isolates (Intro) | `lib/phase1/11_isolates/isolates_demo.dart` |

### Cara Menjalankan Demo

```bash
# Entry point (menu pilih demo)
dart run lib/phase1/main_phase1.dart

# Atau langsung jalankan file demo tertentu:
dart run lib/phase1/01_null_safety/null_safety_demo.dart
dart run lib/phase1/02_async_future/async_future_demo.dart
dart run lib/phase1/03_stream/stream_demo.dart
dart run lib/phase1/04_collections_advanced/collections_advanced_demo.dart
dart run lib/phase1/05_extensions/extensions_demo.dart
dart run lib/phase1/06_enum_enhanced/enum_enhanced_demo.dart
dart run lib/phase1/07_pattern_matching/pattern_matching_demo.dart
dart run lib/phase1/08_generics/generics_demo.dart
dart run lib/phase1/09_mixins/mixins_demo.dart
dart run lib/phase1/10_records/records_demo.dart
dart run lib/phase1/11_isolates/isolates_demo.dart
```

### Mini Projects

| Project | Cara Jalankan |
|---|---|
| 🌤️ Weather CLI App | `OPENWEATHER_API_KEY=your_key dart run lib/phase1/mini_projects/weather/weather_app.dart Jakarta` |
| 📄 File Processor CLI | `dart run lib/phase1/mini_projects/file_processor/file_processor.dart stats lib/phase1/mini_projects/file_processor/sample.txt` |

> **Catatan Weather App:** Dapatkan API key gratis di [openweathermap.org](https://openweathermap.org/api). Set env var `OPENWEATHER_API_KEY` sebelum menjalankan. Tanpa API key, app akan mencetak instruksi setup dan exit.
