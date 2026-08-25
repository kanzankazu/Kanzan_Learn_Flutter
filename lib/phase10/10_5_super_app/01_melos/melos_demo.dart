/// Phase 10.5 — Topic 01: Melos — Dart Monorepo Manager
///
/// A Super App is a single app that hosts multiple mini-apps (features)
/// built by different teams. Managing dozens of inter-dependent packages
/// in one repository is where Melos shines.
///
/// Melos solves:
/// - Running commands (test, analyze, build) across ALL packages at once
/// - Managing inter-package dependencies with local path overrides
/// - Coordinated versioning and CHANGELOG generation
/// - Parallel CI execution per package
///
/// Key concepts covered:
/// 1. melos.yaml — workspace definition
/// 2. melos bootstrap — link local packages together
/// 3. melos run — execute scripts across packages
/// 4. melos version — bump versions + generate CHANGELOG
/// 5. Conventional commits → automatic versioning
/// 6. Package filtering — run commands on a subset of packages
/// 7. Lifecycle hooks — preBootstrap, postBootstrap
import 'package:flutter/material.dart';

void main() => runApp(const _App());

class _App extends StatelessWidget {
  const _App();
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Melos Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange), useMaterial3: true),
        home: const MelosDemo(),
      );
}

class MelosDemo extends StatelessWidget {
  const MelosDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('01 — Melos'), backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(color: Colors.deepOrange.shade50, child: const Text(
            'Melos = Lerna for Dart/Flutter.\n\n'
            'One repository → many packages. Melos links them, runs '
            'commands across them, and keeps versions in sync.',
            style: TextStyle(fontSize: 13),
          )),
          const SizedBox(height: 16),

          // ── 1. Install & setup ─────────────────────────────────────────
          _h('1. Install & Setup', Colors.deepOrange),
          _code(r'''
# Install Melos globally
dart pub global activate melos

# Project structure after setup:
super_app/
├── melos.yaml              ← workspace config
├── packages/
│   ├── core/               ← shared utilities, models, DI
│   │   └── pubspec.yaml
│   ├── feature_wallet/     ← Wallet mini-app
│   │   └── pubspec.yaml
│   ├── feature_promo/      ← Promo mini-app
│   │   └── pubspec.yaml
│   ├── design_system/      ← shared UI components
│   │   └── pubspec.yaml
│   └── app/                ← shell app (depends on all features)
│       └── pubspec.yaml
└── pubspec.yaml            ← root pubspec (Melos reads this too)'''),

          const SizedBox(height: 20),

          // ── 2. melos.yaml ────────────────────────────────────────────
          _h('2. melos.yaml — Workspace Config', Colors.blue),
          _code(r'''
# melos.yaml — at the repo root
name: super_app_workspace

# Which packages are part of this monorepo
packages:
  - packages/**

# IDE integration (generates IntelliJ/VSCode project files)
ide:
  intellij: true

# Custom scripts — run with: melos run <name>
scripts:
  # Run all tests across every package
  test:
    run: flutter test --coverage
    exec:
      concurrency: 4      # run 4 packages in parallel

  # Analyze all packages
  analyze:
    run: flutter analyze
    exec:
      concurrency: 4

  # Generate code in all packages that use build_runner
  generate:
    run: dart run build_runner build --delete-conflicting-outputs
    exec:
      # Only run in packages that have build_runner as a dev dependency
      packageFilters:
        dependsOn: build_runner

  # Build the shell app
  build:
    run: flutter build apk --release
    exec:
      # Only run in the shell app package
      packageFilters:
        name: app

# Version management settings
command:
  version:
    # Use conventional commits to determine version bumps
    # feat: → minor bump (1.0.0 → 1.1.0)
    # fix:  → patch bump (1.0.0 → 1.0.1)
    # feat!: → major bump (1.0.0 → 2.0.0)
    conventionalCommits: true
    # Include private packages in version bumping
    includePrivatePackages: true
    # Update pubspec.lock files
    updateGitTagRefs: true'''),

          const SizedBox(height: 20),

          // ── 3. Common commands ─────────────────────────────────────────
          _h('3. Common Melos Commands', Colors.teal),
          _code(r'''
# Link all local packages together (sets up path dependencies)
melos bootstrap
# After bootstrap: packages can import each other like pub packages

# Run tests across ALL packages (4 in parallel)
melos run test

# Run analyze across ALL packages
melos run analyze

# Run only in specific packages (filter by name pattern)
melos run test --scope="feature_*"

# Run only in packages that changed since main branch
melos run test --diff=origin/main

# Run in packages that depend on a specific package
melos run test --dependsOn=core

# Execute an arbitrary command in every package
melos exec -- dart pub get

# Execute only where a file exists
melos exec --file-exists="test/**_test.dart" -- flutter test

# List all packages in the workspace
melos list
melos list --graph  # show dependency graph'''),

          const SizedBox(height: 20),

          // ── 4. Versioning ──────────────────────────────────────────────
          _h('4. Versioning with Conventional Commits', Colors.purple),
          _code(r'''
# Commit messages drive version bumps automatically:
#   feat:     → MINOR bump (new feature, backward compatible)
#   fix:      → PATCH bump (bug fix)
#   feat!:    → MAJOR bump (breaking change)
#   chore:    → no version bump
#   docs:     → no version bump

# Step 1: Make commits using conventional format
git commit -m "feat(wallet): add QR code payment support"
git commit -m "fix(core): fix null pointer in UserRepository"

# Step 2: Run melos version to bump and generate CHANGELOG
melos version
# Analyzes commits since last tag
# Bumps versions in affected packages
# Generates/updates CHANGELOG.md per package
# Creates a git commit and tag

# Step 3: Push tags to trigger CI release
git push --follow-tags

# The generated CHANGELOG.md:
# ## 1.2.0 (2026-08-24)
# ### Features
# * **wallet**: add QR code payment support
# ### Bug Fixes
# * **core**: fix null pointer in UserRepository'''),

          const SizedBox(height: 20),

          // ── 5. Inter-package dependencies ──────────────────────────────
          _h('5. Local Package Dependencies', Colors.green),
          _code(r'''
# packages/feature_wallet/pubspec.yaml
name: feature_wallet
version: 1.0.0

dependencies:
  flutter:
    sdk: flutter
  # Reference core package by name — Melos handles the path linking
  core: any

# After melos bootstrap, this resolves to:
# dependency_overrides:
#   core:
#     path: ../../core   ← Melos adds this automatically

# packages/core/pubspec.yaml
name: core
version: 0.5.0

dependencies:
  flutter:
    sdk: flutter
  riverpod: ^2.6.0
  # ... other shared dependencies

# packages/app/pubspec.yaml (shell)
name: app

dependencies:
  flutter:
    sdk: flutter
  core:           any
  feature_wallet: any
  feature_promo:  any
  design_system:  any'''),

          const SizedBox(height: 16),
          _card(color: Colors.deepOrange.shade50, child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Key Takeaways', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• melos bootstrap links local packages — no manual path overrides'),
              Text('• melos run <script> runs across all packages in parallel'),
              Text('• --scope, --diff, --dependsOn filter which packages run'),
              Text('• Conventional commits → melos version auto-bumps + CHANGELOG'),
              Text('• Each feature package is independent — different team, own version'),
              Text('• melos exec lets you run ANY command in every package at once'),
            ],
          )),
        ],
      ),
    );
  }
}

Widget _h(String t, Color c) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(t, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: c)));
Widget _code(String s) => Container(width: double.infinity, margin: const EdgeInsets.only(bottom: 4), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF1E1E2E), borderRadius: BorderRadius.circular(6)), child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text(s, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Color(0xFFCDD6F4)))));
Widget _card({required Color color, required Widget child}) => Card(color: color, child: Padding(padding: const EdgeInsets.all(12), child: child));
