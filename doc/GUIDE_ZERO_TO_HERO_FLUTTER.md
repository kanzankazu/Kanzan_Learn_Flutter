# Flutter Guide — Zero to Hero

A Flutter learning roadmap from scratch — for absolute beginners and backend developers switching to mobile.

---

## Table of Contents

1. [Who This Guide Is For](#1-who-this-guide-is-for)
2. [Setup & Mindset](#2-setup--mindset)
3. [Phase 0: Programming Foundations](#3-phase-0-programming-foundations-2-3-weeks)
4. [Phase 1: Dart Language](#4-phase-1-dart-language-1-2-weeks)
5. [Phase 2: Flutter Fundamentals](#5-phase-2-flutter-fundamentals-3-4-weeks)
6. [Phase 3: State Management & Navigation](#6-phase-3-state-management--navigation-2-3-weeks)
7. [Phase 4: Networking & Data](#7-phase-4-networking--data-2-3-weeks)
8. [Phase 5: Architecture & Clean Code](#8-phase-5-architecture--clean-code-2-3-weeks)
9. [Phase 6: Advanced Flutter](#9-phase-6-advanced-flutter-3-4-weeks)
10. [Phase 7: Testing](#10-phase-7-testing-2-weeks)
11. [Phase 8: Deployment & DevOps](#11-phase-8-deployment--devops-1-2-weeks)
12. [Phase 9: Portfolio & Job Ready](#12-phase-9-portfolio--job-ready)
13. [Phase 10: Specialization](#13-phase-10-specialization)
14. [Visual Roadmap](#14-visual-roadmap)
15. [Time Estimates](#15-time-estimates)
16. [Practice Projects](#16-practice-projects)
17. [Tips for Backend Developers](#17-tips-for-backend-developers)
18. [Curated Resources](#18-curated-resources)
19. [Golden Rules](#19-golden-rules)

---

## 1. Who This Guide Is For

| Profile | Start From | Total Estimate |
|---------|-----------|----------------|
| No coding experience | Phase 0 | ~6 months |
| Can code (BE/web), no Flutter | Phase 1 | ~3.5 months |
| Mobile native (Android/iOS) | Phase 1 fast-track | ~2-3 months |

> Assumption: **2-3 hours/day** (part-time). Full-time? Divide by 2.

---

## 2. Setup & Mindset

### Tools to Install

1. **Flutter SDK** — [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)
2. **IDE** — VS Code (recommended) or Android Studio
3. **Extensions** — Flutter & Dart plugin for VS Code
4. **Emulator** — Android Emulator via Android Studio, or iOS Simulator (macOS only)
5. **Git** — version control from day one

### Key Mindset

- Flutter is **declarative**: `UI = f(state)` — not "find element → update"
- **Everything is a Widget** — think LEGO blocks
- **Composition > Inheritance** — combine small widgets into larger ones
- **Hot Reload** is a superpower — use it to experiment fast
- Don't memorize widgets — understand concepts, Google details when needed

---

## 3. Phase 0: Programming Foundations (2-3 weeks)

> **SKIP** if you can already code in any language (Python, Java, JS, etc.)

### Topics

| # | Topic | What to Understand |
|---|-------|--------------------|
| 1 | Variables & Data Types | `int`, `String`, `bool`, `double`, `var`, `dynamic` |
| 2 | Operators | Arithmetic, comparison, logical |
| 3 | Control Flow | `if/else`, `switch`, `for`, `while`, `do-while` |
| 4 | Functions | Parameters, return value, arrow function |
| 5 | Collections | `List`, `Map`, `Set` — basic operations |
| 6 | Basic OOP | Class, object, constructor, inheritance, interface |
| 7 | Error Handling | `try-catch-finally`, `throw` |
| 8 | Logic & Algorithms | Simple sorting, searching, string manipulation |

### Mini Projects
- CLI Calculator (terminal input/output)
- CLI To-Do List (in-memory CRUD)
- Guess the Number (random number game)

### Resources
- **DartPad** — [dartpad.dev](https://dartpad.dev) — code in browser, no install needed
- **Dart Language Tour** — [dart.dev/language](https://dart.dev/language) — official docs

---

## 4. Phase 1: Dart Language (1-2 weeks)

> Dart is Flutter's language. Master this before jumping into Flutter.

### Topics

| # | Topic | Why It Matters |
|---|-------|----------------|
| 1 | Null Safety | `?`, `!`, `??`, `late` — mandatory in Dart 3 |
| 2 | Async/Await | `Future`, `async`, `await`, `Stream` — all I/O in Flutter is async |
| 3 | Advanced Collections | `.map()`, `.where()`, `.fold()`, spread `...` |
| 4 | Extension Methods | Add methods to existing classes without inheritance |
| 5 | Enhanced Enums | Dart 3 enums with methods & fields |
| 6 | Pattern Matching | `switch` expression, `sealed class` (Dart 3) |
| 7 | Generics | `<T>` — common in state management |
| 8 | Mixins | `with` keyword — multiple inheritance alternative |
| 9 | Records & Destructuring | Dart 3 feature — return multiple values cleanly |
| 10 | Isolates (intro) | Concurrent programming — heavy computation off the UI thread |

### Dart vs Other Languages

| Concept | Java/Kotlin | Python | Dart |
|---------|-------------|--------|------|
| Null handling | `@Nullable` / `?` | `Optional` / `None` | `?` (built-in null safety) |
| Async | `CompletableFuture` / `suspend` | `async/await` | `Future` + `async/await` |
| Collection ops | Stream API / `.map{}` | list comprehension | `.map()`, `.where()` |
| Interface | `interface` keyword | Duck typing | Implicit (all classes = interface) |
| Concurrency | Thread / Coroutine | asyncio | Isolate (single thread per isolate) |

### Mini Projects
- **Weather CLI App** — fetch API (`http` package), parse JSON, display in terminal
- **File Processor** — read file, transform data, write output (async + Stream practice)

---

## 5. Phase 2: Flutter Fundamentals (3-4 weeks)

> The most important phase. Widget and layout foundations must be solid.

### Week 1-2: Widgets & Layout

| # | Topic | Key Widget / Concept |
|---|-------|----------------------|
| 1 | StatelessWidget | `build()`, immutable, pure UI |
| 2 | StatefulWidget | `setState()`, `initState()`, `dispose()` |
| 3 | Layout | `Column`, `Row`, `Stack`, `Expanded`, `Flexible` |
| 4 | Container & Decoration | `Container`, `BoxDecoration`, `Padding`, `Margin` |
| 5 | Scrollable | `ListView`, `GridView`, `SingleChildScrollView` |
| 6 | Input | `TextField`, `Form`, `TextFormField`, `Checkbox`, `Switch` |
| 7 | Buttons | `ElevatedButton`, `TextButton`, `OutlinedButton`, `IconButton` |
| 8 | Scaffold | `Scaffold`, `AppBar`, `BottomNavigationBar`, `Drawer` |
| 9 | Media | `Image.asset`, `Image.network`, `Icon` |
| 10 | Overlays | `showDialog`, `AlertDialog`, `SnackBar`, `BottomSheet` |

### Week 3-4: Intermediate Widgets

| # | Topic | Key Widget / Concept |
|---|-------|----------------------|
| 11 | Custom Widget | Extract widget, composition pattern |
| 12 | Theming | `ThemeData`, `ColorScheme`, light/dark mode |
| 13 | Responsive Layout | `MediaQuery`, `LayoutBuilder`, `OrientationBuilder` |
| 14 | Basic Animation | `AnimatedContainer`, `AnimatedOpacity`, `Hero` |
| 15 | GestureDetector | `onTap`, `onLongPress`, `onPan`, `InkWell` |
| 16 | Keys | `ValueKey`, `UniqueKey` — when to use them |
| 17 | Widget Lifecycle | `initState` → `build` → `didUpdateWidget` → `dispose` |

### Key Concepts

```
Everything is a Widget
├── StatelessWidget  → static UI (never changes)
├── StatefulWidget   → dynamic UI (changes via setState)
├── InheritedWidget  → share data down the tree
└── Composition > Inheritance
```

### Common Beginner Mistakes
1. **Logic in `build()`** — `build()` can be called many times, keep it pure
2. **Missing `const` constructor** — causes unnecessary rebuilds
3. **Over-nested widgets** — extract into custom widgets early
4. **`setState` for global state** — `setState` is local only

### Mini Projects
- Profile Card App — layout practice (photo, name, bio, skills)
- Calculator App — input handling, simple state
- Recipe App (UI only) — list, detail, basic navigation

---

## 6. Phase 3: State Management & Navigation (2-3 weeks)

> Pick **one** state management solution and master it before trying others.

### Navigation

| # | Topic | Notes |
|---|-------|-------|
| 1 | Named Routes | `Navigator.pushNamed()` — good for small apps |
| 2 | GoRouter | Modern: deep links, nested navigation, web support |
| 3 | Passing Data | Arguments between screens, return result |
| 4 | Bottom Navigation | Persistent tabs with nested navigator |
| 5 | Deep Linking | URL-based navigation — important for web & app links |

### State Management Options

| Level | Option | Best For |
|-------|--------|----------|
| Beginner | `setState` + `InheritedWidget` | Small app, 1-3 screens |
| **Recommended** | **Riverpod** | Medium-large, type-safe, testable |
| Intermediate | BLoC/Cubit | Enterprise, event-driven, strict pattern |
| Simple | Provider | Small-medium (Riverpod's predecessor) |
| Fast | GetX | Rapid dev, less strict (trade-off) |

### Why Riverpod

- Type-safe — compile-time errors, not runtime crashes
- No `BuildContext` dependency
- Easy to test
- Scales from small to large apps
- Industry standard 2024-2026

### Local vs Global State

```
Local State (setState)       Global/Shared State (Riverpod)
├── Form input               ├── User session / auth
├── Animation controller     ├── Theme preference
└── Toggle visibility        ├── Cart / order data
                             └── API response cache
```

### Mini Projects
- Counter App (upgraded) — Riverpod instead of setState
- Multi-screen Todo App — CRUD + navigation + persistent state
- Shopping Cart — add/remove items, total calculation, checkout flow

---

## 7. Phase 4: Networking & Data (2-3 weeks)

### Topics

| # | Topic | Package / Tool |
|---|-------|---------------|
| 1 | HTTP Requests | `http` (simple) or `dio` (interceptors, retry, cancel) |
| 2 | JSON Serialization | `freezed` + `json_serializable` + `build_runner` |
| 3 | REST API | GET, POST, PUT, DELETE — handle loading/error/success states |
| 4 | Error Handling | Network error, timeout, server error, parse error |
| 5 | Local Storage | `shared_preferences` (key-value), `sqflite` (SQL), `hive`/`isar` (NoSQL) |
| 6 | Image Caching | `cached_network_image` |
| 7 | Firebase | Auth, Firestore, Storage, FCM |
| 8 | WebSocket (intro) | Real-time data — chat, live updates |
| 9 | Pagination | Infinite scroll, load-more pattern |
| 10 | Offline-first | Cache strategy, sync queue |

### Data Layer Pattern

```
UI (Widget)
    ↕
State (Riverpod / BLoC)
    ↕
Repository  ← abstraction layer
    ↕
┌──────────┬─────────────┐
│  Remote  │    Local    │
│  (API)   │  (DB/Cache) │
└──────────┴─────────────┘
```

### Mini Projects
- News Reader — fetch public API, list + detail screen
- Weather App — location, pull-to-refresh, error states
- Note App — full CRUD + SQLite/Hive + Firebase sync

---

## 8. Phase 5: Architecture & Clean Code (2-3 weeks)

### Architecture Patterns

| Pattern | Complexity | Best For |
|---------|------------|----------|
| Feature-first folders | Low | All app sizes |
| Repository Pattern | Medium | Multiple data sources |
| Clean Architecture | High | Enterprise / large teams |
| MVVM + Repository | Medium | Balanced for most apps |

### Recommended Folder Structure

```
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── theme/
│   └── utils/
├── features/
│   └── auth/
│       ├── data/         # models, data sources, repository impl
│       ├── domain/       # entities, repository interface, use cases
│       └── presentation/ # screens, widgets, state
├── shared/
│   └── widgets/
└── main.dart
```

### Clean Code Topics

| # | Topic | Why It Matters |
|---|-------|----------------|
| 1 | SOLID Principles | Single Responsibility, Open/Closed, etc. |
| 2 | DRY | Extract shared logic |
| 3 | Dependency Injection | Testable, loosely coupled |
| 4 | Repository Pattern | Abstract data source from business logic |
| 5 | Use Cases | 1 class = 1 business action (only if logic exists) |
| 6 | Error Handling | `Either<Failure, Success>` or `sealed class Result` |
| 7 | Code Generation | `freezed`, `json_serializable`, `auto_route` |

### Mini Projects
- Refactor a Phase 4 project with Clean Architecture
- E-Commerce App skeleton — multi-feature, proper layer separation

---

## 9. Phase 6: Advanced Flutter (3-4 weeks)

### Week 1-2: Advanced UI

| # | Topic | Notes |
|---|-------|-------|
| 1 | Custom Painter | Draw custom shapes, charts, graphs from scratch |
| 2 | Slivers | `CustomScrollView`, `SliverAppBar`, `SliverList` — complex scroll effects |
| 3 | Advanced Animation | `AnimationController`, `Tween`, `Curves`, Rive, Lottie |
| 4 | Platform Channels | Flutter ↔ Native (Android/iOS) communication |
| 5 | Responsive & Adaptive | Different layouts for phone / tablet / web / desktop |
| 6 | Accessibility | `Semantics`, screen reader support, contrast ratios |
| 7 | Internationalization | `intl` package, multi-language support |
| 8 | Custom Theme System | Dynamic themes, brand theming |

### Week 3-4: Advanced Features

| # | Topic | Package |
|---|-------|---------|
| 9 | Push Notifications | `firebase_messaging`, `flutter_local_notifications` |
| 10 | Background Tasks | `workmanager`, `flutter_background_service` |
| 11 | Camera & Media | `camera`, `image_picker`, video recording |
| 12 | Maps & Location | `google_maps_flutter`, `geolocator`, `geocoding` |
| 13 | Biometric Auth | `local_auth` — fingerprint, Face ID |
| 14 | In-App Purchase | `in_app_purchase` |
| 15 | Deep Link & App Link | Universal links, deferred deep links |
| 16 | Performance Optimization | Minimize rebuilds, lazy loading, memory profiling |

### Mini Projects
- Social Media App — feed, post, like, comment, real-time
- Fitness Tracker — animation, charts, camera (progress photo), notifications

---

## 10. Phase 7: Testing (2 weeks)

> Code without tests = code afraid to be refactored.

### Testing Pyramid

```
         ╱╲
        ╱  ╲      Integration Test  (few)   → full end-to-end flow
       ╱────╲
      ╱      ╲    Widget Test       (some)  → UI component behavior
     ╱────────╲
    ╱          ╲  Unit Test         (many)  → logic, ViewModel, Repository
   ╱────────────╲
```

### Topics

| # | Topic | Tool |
|---|-------|------|
| 1 | Unit Test | `test` — function / class logic |
| 2 | Widget Test | `flutter_test` — render, interact, assert |
| 3 | Integration Test | `integration_test` — full app flow |
| 4 | Mocking | `mockito`, `mocktail` — fake dependencies |
| 5 | BLoC Test | `bloc_test` — test state transitions |
| 6 | Golden Test | Screenshot comparison — UI regression |
| 7 | Code Coverage | `flutter test --coverage` + `lcov` — target 70%+ for business logic |

---

## 11. Phase 8: Deployment & DevOps (1-2 weeks)

### Topics

| # | Topic | Notes |
|---|-------|-------|
| 1 | Build Variants | Debug / Release / Profile, flavors per environment |
| 2 | App Signing | Keystore (Android), Certificate (iOS) |
| 3 | Play Store | Console setup, listing, screenshots, review process |
| 4 | App Store | Apple Developer account, Xcode archive, TestFlight |
| 5 | CI/CD | GitHub Actions, Codemagic, Fastlane |
| 6 | Code Push / OTA | Shorebird — Dart-native over-the-air updates |
| 7 | Monitoring | Firebase Crashlytics, Analytics, Performance |
| 8 | Obfuscation | `--obfuscate --split-debug-info` |

### Pre-Release Checklist

- [ ] App icon & splash screen finalized
- [ ] All hardcoded strings → localized
- [ ] Performance profiling — no jank
- [ ] Tested on physical device (not just emulator)
- [ ] ProGuard/R8 rules configured (Android)
- [ ] Privacy policy & terms of service
- [ ] Store listing screenshots ready

---

## 12. Phase 9: Portfolio & Job Ready

### Portfolio App Ideas (pick 2-3)

| # | App | Skills Demonstrated |
|---|-----|---------------------|
| 1 | E-Commerce App | Full CRUD, cart, payment, order tracking |
| 2 | Chat App | Real-time (Firebase/WebSocket), media sharing |
| 3 | Fitness/Health App | Charts, animation, background service, notifications |
| 4 | Finance Tracker | Complex state, charts, export, multi-wallet |
| 5 | Food Delivery Clone | Maps, real-time tracking, multi-role |
| 6 | Social Media | Feed algorithm, image upload, infinite scroll |

### What Recruiters Look For

1. ✅ Clean architecture — no spaghetti code
2. ✅ Proper state management — not `setState` everywhere
3. ✅ Real API integration — no hardcoded data
4. ✅ Tests — at least unit tests for business logic
5. ✅ Polished UI — attention to detail
6. ✅ Clean git history — meaningful commit messages
7. ✅ Clear README on GitHub

---

## 13. Phase 10: Specialization

> You can build production-ready Flutter apps. Now choose a track.

### Available Tracks

| Track | Focus | Best For |
|-------|-------|----------|
| **Track 1: Web & Desktop** | Responsive web, PWA, Dart Frog | Flutter fullstack |
| **Track 2: Advanced State** | Riverpod Generator, offline-first, CRDT | Flutter Lead |
| **Track 3: Native Interop** | Method/Event Channel, Pigeon, Dart FFI, plugin dev | Plugin / SDK dev |
| **Track 4: Performance** | DevTools, Custom RenderObject, Shader, Isolate | Performance Engineer |
| **Track 5: Super App** | Micro-frontend, Melos, Module Federation, Feature Flags | Tech Lead |
| **Track 6: Backend** | GraphQL, gRPC, Supabase, CRDT | Fullstack |
| **Track 7: AI/ML Mobile** | TFLite, ML Kit, on-device LLM, Camera + ML | Emerging Tech |

### Track Recommendations

| Your Goal | Priority Tracks | Reason |
|-----------|----------------|--------|
| Flutter Lead | Track 5 + 4 | Architecture & performance = core of lead role |
| Flutter Fullstack | Track 1 + 6 | Web + backend = full coverage |
| Plugin / SDK dev | Track 3 + 4 | Native interop + performance = plugin quality |
| AI / emerging tech | Track 7 + 2 | On-device ML + reactive state = smart apps |
| Build a startup | Track 6 + 5 | Rapid backend + scalable architecture |

### Capstone: "AIO Productivity Suite"

An app combining all tracks — Task manager + Notes + Calendar + Expense tracker + AI assistant. Deploy to Android, iOS, Web, macOS, Windows.

- Web + Desktop + Mobile (Track 1)
- Offline-first sync (Track 2)
- Custom native plugin for hardware (Track 3)
- 60fps dashboard + charts (Track 4)
- Modular, add features without rebuilding (Track 5)
- GraphQL + Realtime backend (Track 6)
- AI assistant — auto-categorize, smart search (Track 7)

---

## 14. Visual Roadmap

```
MONTH 1                    MONTH 2                    MONTH 3
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│ Phase 0: Coding │──────▶│ Phase 2: Flutter│──────▶│ Phase 4: Network│
│ Phase 1: Dart   │       │ Fundamentals    │       │ Phase 5: Arch   │
└─────────────────┘       │ Phase 3: State  │       └─────────────────┘
                          └─────────────────┘

MONTH 4                    MONTH 5                    MONTH 6+
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│ Phase 6: Advanc │──────▶│ Phase 7: Test   │──────▶│ Phase 9: Port-  │
│ ed Flutter      │       │ Phase 8: Deploy │       │ folio & Jobs    │
└─────────────────┘       └─────────────────┘       └─────────────────┘
```

### Milestone Checkpoints

| Milestone | When | Proof |
|-----------|------|-------|
| "I can write Dart" | Week 3-4 | Solve HackerRank Easy problems in Dart |
| "I can build UI" | Week 6-7 | Clone UI of a popular app (Grab, Tokopedia) |
| "I can build an app" | Week 10-12 | Full CRUD app + API + state management |
| "I'm job-ready" | Week 16-20 | 2-3 portfolio apps + deployed + clean code |

---

## 15. Time Estimates

### Absolute Beginner

| Phase | Duration | Cumulative |
|-------|----------|------------|
| Phase 0: Coding Foundations | 2-3 weeks | 3 weeks |
| Phase 1: Dart | 2 weeks | 5 weeks |
| Phase 2: Flutter Fundamentals | 4 weeks | 9 weeks |
| Phase 3: State & Navigation | 3 weeks | 12 weeks |
| Phase 4: Networking | 3 weeks | 15 weeks |
| Phase 5: Architecture | 2 weeks | 17 weeks |
| Phase 6: Advanced | 3 weeks | 20 weeks |
| Phase 7: Testing | 2 weeks | 22 weeks |
| Phase 8: Deploy | 1 week | 23 weeks |
| **Total** | | **~6 months** |

### Backend Developer (already coding)

| Phase | Duration | Cumulative |
|-------|----------|------------|
| Phase 1: Dart | 1 week | 1 week |
| Phase 2: Flutter Fundamentals | 3 weeks | 4 weeks |
| Phase 3: State & Navigation | 2 weeks | 6 weeks |
| Phase 4: Networking | 1-2 weeks | 8 weeks |
| Phase 5: Architecture | 2 weeks | 10 weeks |
| Phase 6: Advanced | 3 weeks | 13 weeks |
| Phase 7: Testing | 1 week | 14 weeks |
| Phase 8: Deploy | 1 week | 15 weeks |
| **Total** | | **~3.5 months** |

> Assumes **2-3 hours/day** part-time. Full-time (8h/day) → divide by 2.

---

## 16. Practice Projects

Ordered from simplest to enterprise-level. Each has a difficulty tag and time estimate.

| Tag | Level | Time |
|-----|-------|------|
| 🟢 | Beginner | 1-3 days |
| 🟡 | Easy | 3-7 days |
| 🟠 | Medium | 1-3 weeks |
| 🔴 | Hard | 3-6 weeks |
| ⚫ | Production | 1-3 months |

### 🟢 Level 1 — Warm-up (Widgets & Layout)

| # | Project | Skills | Time |
|---|---------|--------|------|
| 1 | Business Card App | Column, Row, Container, Image, Text styling | 2-3 hrs |
| 2 | Dice Roller | StatefulWidget, setState, Random, GestureDetector | 3-4 hrs |
| 3 | BMI Calculator | TextField, Form validation, conditional rendering | 4-6 hrs |
| 4 | Tip Calculator | Slider, input formatting, real-time calculation | 3-5 hrs |
| 5 | Quiz App | List, index navigation, score tracking, result screen | 1 day |
| 6 | Color Palette Generator | Random colors, GridView, copy to clipboard, Snackbar | 1 day |
| 7 | Stopwatch & Timer | Timer class, Stream, format duration, animation | 1 day |
| 8 | Unit Converter | DropdownButton, TextFormField, conversion logic | 1 day |

### 🟡 Level 2 — Foundation (Navigation & Basic State)

| # | Project | Skills | Time |
|---|---------|--------|------|
| 9 | Multi-screen Todo App | CRUD, ListView, navigation, form, local state | 2-3 days |
| 10 | Expense Tracker (UI) | Charts, list grouping, FAB, BottomSheet | 2-3 days |
| 11 | Recipe Book | TabBar, search/filter, detail screen, Hero animation | 2-3 days |
| 12 | Pomodoro Timer | Countdown, local notification, circular progress | 2-3 days |
| 13 | Habit Tracker | Calendar widget, streak counting, SharedPreferences | 3-4 days |
| 14 | Flashcard App | PageView, flip animation, progress, categories | 2-3 days |
| 15 | Simple Blog Reader | Markdown rendering, local JSON, search, bookmarks | 3-4 days |
| 16 | Contacts App | Alphabet scroll, avatar initials, search, groups | 3-4 days |

### 🟠 Level 3 — Real-world (API, State, Local DB)

| # | Project | Skills | Time |
|---|---------|--------|------|
| 17 | Weather App | REST API, location, pull-to-refresh, error states | 1 week |
| 18 | News Reader | Paginated API, infinite scroll, WebView, bookmarks | 1-2 weeks |
| 19 | Movie/TV Database | TMDB API, search, genre filter, watchlist | 1-2 weeks |
| 20 | Crypto Tracker | WebSocket real-time price, chart, portfolio | 1-2 weeks |
| 21 | GitHub Profile Viewer | GitHub API, repos list, commit chart, basic OAuth | 1 week |
| 22 | Shopping List + Meal Planner | Multi-tab, drag reorder, Hive/Isar, share | 1-2 weeks |
| 23 | Podcast Player | Audio playback, background audio, playlist | 2 weeks |
| 24 | Location-based Reminder | Geofencing, Maps, local notification by location | 1-2 weeks |

### 🔴 Level 4 — Production-quality (Full Architecture, Testing, Deploy)

| # | Project | Skills | Time |
|---|---------|--------|------|
| 25 | E-Commerce App | Cart, checkout, order history, auth, product CRUD | 3-4 weeks |
| 26 | Chat App | Realtime (Firebase/Supabase), media, typing, read receipt | 3-4 weeks |
| 27 | Fitness Tracker | Camera, charts, workout timer, schedule, achievements | 3-4 weeks |
| 28 | Personal Finance Manager | Multi-wallet, budget, recurring tx, charts, CSV/PDF | 4-5 weeks |
| 29 | Social Media | Feed, post, like, comment, follow, explore, stories | 4-6 weeks |
| 30 | Travel Planner | Itinerary CRUD, Maps, offline, collaboration, gallery | 3-4 weeks |
| 31 | Job Board | Post job, apply, filter, recruiter chat, reviews | 4-5 weeks |
| 32 | Learning Platform | Course list, video player, progress, quiz, certificate | 4-5 weeks |

### ⚫ Level 5 — Enterprise (Like Real Company Apps)

> Build these solo at production quality → mid-senior Flutter level.

| # | Project | Similar To | Time |
|---|---------|-----------|------|
| 33 | Ride-hailing App | Grab, Gojek | 2-3 months |
| 34 | Food Delivery App | GrabFood, ShopeeFood | 2-3 months |
| 35 | Banking / Digital Wallet | OVO, DANA, BRImo | 2-3 months |
| 36 | Telemedicine App | Halodoc, Alodokter | 2-3 months |
| 37 | Marketplace (C2C) | Tokopedia, Shopee | 3-4 months |
| 38 | Field Agent / CRM | Sales force tracker | 2-3 months |
| 39 | POS (Point of Sale) | Moka, iSeller | 2 months |
| 40 | HR & Attendance App | Talenta, KaryaONE | 2 months |

### Recommended Portfolio Path

Pick **1 project per level** and complete it fully:

1. 🟢 Quiz App — covers most Level 1 concepts in one day
2. 🟡 Habit Tracker — date logic + local storage + gamification
3. 🟠 Weather App (full API cycle) or News Reader (pagination + offline)
4. 🔴 Personal Finance Manager — complex state + charts + export
5. ⚫ POS App — offline-first + hardware + multi-role (most achievable solo)

These 5 are enough for a solid Flutter developer portfolio.

### Phase → Project Mapping

| Level | Best at Phase | Skills Demonstrated |
|-------|--------------|---------------------|
| 🟢 Level 1 | Phase 2 | Widgets, layout, setState |
| 🟡 Level 2 | Phase 2-3 | Navigation, local state, basic persistence |
| 🟠 Level 3 | Phase 3-5 | API, state management, error handling, repository |
| 🔴 Level 4 | Phase 5-8 | Clean architecture, testing, CI/CD, deploy |
| ⚫ Level 5 | Phase 8-10 | Enterprise patterns, security, offline-first, hardware |

### What Interviewers Typically Ask

| Company Type | Level | Usually Asks For |
|-------------|-------|-----------------|
| Early-stage startup | 🟠-🔴 | Todo/Notes app with clean architecture + tests |
| Growth startup | 🔴 | E-commerce or social media mini (3-5 screens, API) |
| Fintech | 🔴-⚫ | Transfer flow, PIN/security, transaction history |
| Enterprise / Bank | ⚫ | Multi-role, offline, complex forms, security layers |
| Agency | 🟠-🔴 | Clone of client app (food delivery, booking) |

---

## 17. Tips for Backend Developers

### What You Already Know

| BE Concept | Flutter Equivalent |
|-----------|-------------------|
| REST API | `dio` / `http` — same request/response cycle |
| Database | `sqflite`, `drift` — same SQL syntax |
| Auth flow | Firebase Auth / custom JWT — same concept |
| Repository pattern | Exactly the same — abstract data source |
| Dependency Injection | `get_it` + `injectable`, or Riverpod providers |
| Error handling | `try-catch` + custom exception — similar |
| Clean Architecture | Same layers: domain / data / presentation |
| Async | `Future` ≈ `Promise` (JS) ≈ `CompletableFuture` (Java) |

### What's New

| Concept | Explanation |
|---------|------------|
| Declarative UI | `UI = f(state)` — not "find element → update". The whole tree rebuilds |
| Widget Tree | Deep nested composition — extract widgets often |
| Hot Reload | Super-fast feedback loop — experiment freely |
| State reactivity | UI auto-updates when state changes — no manual refresh |
| Platform-specific behavior | iOS/Android differ in gestures, nav patterns, UI conventions |
| Responsive without CSS | No flexbox — use `Row`, `Column`, `Expanded`, `MediaQuery` |

### Shortcuts for BE Devs

1. **Skip Phase 0** — you already code
2. **Phase 1 fast** — Dart is similar to Kotlin/Java/TypeScript; focus on null safety & async
3. **Phase 4 fast** — you know APIs; focus on Flutter packages & error handling patterns
4. **Jump to Phase 5** — Clean Architecture is familiar, just adapt to Flutter style

---

## 18. Curated Resources

### Free

| Resource | Type | Level |
|----------|------|-------|
| [flutter.dev](https://flutter.dev) | Docs | All |
| [dart.dev/language](https://dart.dev/language) | Docs | Beginner |
| [dartpad.dev](https://dartpad.dev) | Playground | Beginner |
| [codelabs.developers.google.com](https://codelabs.developers.google.com) | Tutorial | Beginner-Mid |
| Flutter YouTube ([@flutterdev](https://youtube.com/@flutterdev)) | Video | All |
| [riverpod.dev](https://riverpod.dev) | Docs | Mid |
| Reso Coder ([@ResoCoder](https://youtube.com/@ResoCoder)) | Video | Mid-Advanced |
| FilledStacks ([@FilledStacks](https://youtube.com/@FilledStacks)) | Video | Mid-Advanced |
| Flutter Mapp ([@FlutterMapp](https://youtube.com/@FlutterMapp)) | Video | Beginner |

### Paid (Worth It)

| Resource | Type | Level | Price |
|----------|------|-------|-------|
| Code With Andrea (Andrea Bizzotto) | Course | Mid-Advanced | $150-300 |
| Maximilian — Udemy | Course | Beginner-Mid | ~$15 on sale |
| Vandad Nahavandipoor | Video + Course | All | Free + Paid |
| Flutter Apprentice (Kodeco) | Book | Beginner | ~$50 |

### Indonesian Communities

| Resource | Platform |
|----------|----------|
| Flutter ID | Telegram |
| Erico Darmawan | YouTube |
| Kuldii Project | YouTube |

---

## 19. Golden Rules

1. **Code every day** — consistency beats intensity. 1h/day > 8h once a week
2. **Build projects, don't just watch tutorials** — tutorial hell is real
3. **Read Flutter error messages** — they're very informative and often suggest a fix
4. **Join a community** — Flutter ID (Telegram), Stack Overflow, Flutter Discord
5. **Read package source code** — levels up your understanding fast
6. **Ship ugly code first, refactor later** — don't be a perfectionist early on
7. **Master 1 state management** — don't hop Riverpod → BLoC → GetX without finishing any

---

*Last updated: August 2026*
*Target audience: Absolute beginners · Backend developers switching to Flutter · Flutter developers leveling up*

---

## See Also

- [flutter_developer_roadmap.puml](flutter_developer_roadmap.puml) — visual roadmap diagram
