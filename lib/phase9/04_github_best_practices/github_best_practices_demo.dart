/// Phase 9 — Topic 04: GitHub Best Practices
///
/// Your GitHub profile IS your portfolio. Recruiters look at it before
/// they read your resume. This topic covers everything you need to make
/// your GitHub presence professional and impressive.
///
/// Covered:
/// 1. Conventional Commits — structured commit messages that tell a story
/// 2. Branching strategy — feature branches, naming conventions
/// 3. Git tagging — version tags for releases
/// 4. GitHub profile README — your public landing page
/// 5. Keeping a clean history — squash, rebase (when and when not to)
/// 6. CI badge on every repo — visual proof that the code works
/// 7. GitHub releases — what to include, how to write release notes
import 'package:flutter/material.dart';

/// Standalone entry point.
void main() => runApp(const _StandaloneApp());

class _StandaloneApp extends StatelessWidget {
  const _StandaloneApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GitHub Best Practices',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const GitHubBestPracticesDemo(),
    );
  }
}

/// Demo screen covering GitHub best practices for Flutter developers.
class GitHubBestPracticesDemo extends StatelessWidget {
  const GitHubBestPracticesDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('04 — GitHub Best Practices'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── 1. Conventional Commits ───────────────────────────────────────
          _header('1. Conventional Commits', Colors.blueGrey),
          _card(
            color: Colors.blueGrey.shade50,
            child: const Text(
              'Conventional Commits is a standard format for commit messages. '
              'Tools like CHANGELOG generators, semantic versioning bots, and '
              'code review tools all rely on this format.',
              style: TextStyle(fontSize: 13),
            ),
          ),
          _code('''
# Format: <type>(<scope>): <short description>
#
# type:  feat | fix | docs | style | refactor | test | chore | perf | ci
# scope: optional — the module or feature affected
# description: present tense, no capital first letter, no period at end

# ✅ Good commit messages
feat(auth): add biometric login support
fix(transactions): prevent duplicate save on double tap
refactor(domain): extract budget validation to use case
test(wallet): add unit tests for balance calculation
chore(deps): upgrade flutter to 3.22.0
docs(readme): add architecture diagram and screenshots
perf(list): replace ListView.builder with CustomScrollView for 60fps
ci: add coverage badge to README

# ❌ Bad commit messages
fix bug                          # what bug? where?
WIP                              # never commit WIP to main
update files                     # meaningless
Changed the login screen stuff   # vague, past tense, no type

# Commit message with body (for complex changes):
feat(budget): add monthly rollover support

When a budget is not fully spent in a month, the remaining
amount rolls over to the next month automatically.
Closes #42

# The short description is what appears in git log --oneline:
# a1b2c3d feat(auth): add biometric login support
# d4e5f6a fix(transactions): prevent duplicate save on double tap'''),

          const SizedBox(height: 20),

          // ── 2. Branching strategy ─────────────────────────────────────────
          _header('2. Branching Strategy', Colors.blue),
          _code('''
# Simple Git Flow for solo/small-team projects:
#
#   main     ← always stable, always releasable
#     ↑
#   develop  ← integration branch (optional for small teams)
#     ↑
#   feature/xxx  ← one branch per feature or fix

# Branch naming conventions:
feature/add-dark-mode
feature/transaction-filters
fix/crash-on-empty-wallet
refactor/extract-budget-domain
chore/upgrade-flutter-3.22
docs/update-readme-screenshots
release/1.2.0

# Workflow:
git checkout -b feature/add-dark-mode   # 1. create feature branch
# ... code, commit, push ...
git push -u origin feature/add-dark-mode
# 2. open a PR from feature/add-dark-mode → main
# 3. review + merge (squash merge keeps main history clean)
git branch -d feature/add-dark-mode     # 4. delete merged branch

# For solo projects without PRs:
git checkout -b feature/x
# ... code + commit ...
git checkout main
git merge --squash feature/x            # squash all commits into one
git commit -m "feat(x): add x feature"
git branch -d feature/x'''),

          const SizedBox(height: 20),

          // ── 3. Git tagging ────────────────────────────────────────────────
          _header('3. Version Tags', Colors.teal),
          _code(r'''
# Tag every release so you can always find the exact code that was shipped.
# Use Semantic Versioning: MAJOR.MINOR.PATCH
#   MAJOR = breaking change
#   MINOR = new feature (backward compatible)
#   PATCH = bug fix

# Create an annotated tag (preferred — includes metadata)
git tag -a v1.2.0 -m "Release v1.2.0 — dark mode + budget rollover"
git push origin v1.2.0      # push the tag to GitHub

# List all tags
git tag -l

# Checkout the code at a specific release
git checkout v1.0.0

# This tag should match the versionName in pubspec.yaml:
# version: 1.2.0+15   ← 1.2.0 matches the tag, +15 is the build number

# GitHub automatically creates a downloadable ZIP + tar.gz per tag.
# Create a GitHub Release from the tag with:
# - What's new (features)
# - What's fixed (bug fixes)
# - Download link to the APK / AAB
# - Any migration notes for existing users'''),

          const SizedBox(height: 20),

          // ── 4. Profile README ─────────────────────────────────────────────
          _header('4. GitHub Profile README', Colors.green),
          const Text(
            'Create a repo with the same name as your GitHub username. '
            'Its README.md appears on your profile page.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          _code(r'''
<!-- github.com/kanzankazu/kanzankazu — README.md -->

# Hi, I'm Faisal 👋

Android & Flutter developer with 7+ years of experience.
Currently building fintech apps at BRI.

## 🛠️ Tech Stack

![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)
![Kotlin](https://img.shields.io/badge/Kotlin-7F52FF?logo=kotlin&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase&logoColor=black)
![Riverpod](https://img.shields.io/badge/Riverpod-0175C2?logo=dart&logoColor=white)

## 📱 Featured Projects

| Project | Description | Stack |
|---------|-------------|-------|
| [Finance Manager](https://github.com/.../finance) | Track income, expenses & budgets | Flutter, Firebase, Riverpod |
| [IP Scanner](https://github.com/.../remote) | Scan and manage network devices | Flutter, XML, MVP |
| [Learn Flutter](https://github.com/.../learn) | Zero to Hero Flutter roadmap | Flutter, Dart |

## 📊 GitHub Stats

![Stats](https://github-readme-stats.vercel.app/api?username=kanzankazu&show_icons=true)
![Top Langs](https://github-readme-stats.vercel.app/api/top-langs/?username=kanzankazu&layout=compact)

## 📬 Contact

[![LinkedIn](https://img.shields.io/badge/LinkedIn-blue?logo=linkedin)](https://linkedin.com/in/yourname)
[![Email](https://img.shields.io/badge/Email-red?logo=gmail)](mailto:kanzankazu46@gmail.com)'''),

          const SizedBox(height: 20),

          // ── 5. Clean git history ──────────────────────────────────────────
          _header('5. Keeping a Clean History', Colors.orange),
          _code('''
# Interactive rebase — clean up messy commits BEFORE pushing
# (NEVER rebase commits that are already pushed to a shared branch)

git rebase -i HEAD~5    # edit the last 5 commits

# In the editor, change "pick" to:
#   r (reword)  — change commit message
#   s (squash)  — merge into previous commit
#   f (fixup)   — like squash but discards the message
#   d (drop)    — remove the commit entirely

# Example: squash 3 WIP commits into one clean commit
pick a1b2c3d feat(auth): start login screen
f   d4e5f6a fix typo
f   g7h8i9j fix another typo
# → Results in a single clean commit: feat(auth): start login screen

# Squash merge when merging a PR (keeps main clean):
# GitHub PR → "Squash and merge" option
# → All feature branch commits become ONE commit on main

# Never force-push to main or develop — only to your own feature branches
git push --force-with-lease origin feature/my-branch  # safer than --force'''),

          const SizedBox(height: 20),

          // ── 6. Quick-start commands ────────────────────────────────────────
          _header('6. Daily Git Workflow', Colors.red),
          _code(r'''
# Start of day: pull latest changes
git checkout main && git pull

# Start a new feature
git checkout -b feature/add-category-filter

# Make atomic commits (one logical change per commit)
git add lib/features/transactions/
git commit -m "feat(transactions): add category filter UI"

git add test/features/transactions/
git commit -m "test(transactions): add filter provider unit tests"

# Push and open a PR
git push -u origin feature/add-category-filter
gh pr create --title "feat: add transaction category filter" --body "..."

# After PR is merged, clean up
git checkout main && git pull
git branch -d feature/add-category-filter

# Tag the release
git tag -a v1.3.0 -m "v1.3.0: category filter + budget rollover"
git push origin v1.3.0'''),

          const SizedBox(height: 16),
          _card(
            color: Colors.blueGrey.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Key Takeaways',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('• Conventional Commits: feat/fix/refactor/test/chore as prefix'),
                Text('• One branch per feature — merge via squash to keep main clean'),
                Text('• Tag every release with the same version as pubspec.yaml'),
                Text('• GitHub profile README = your public landing page'),
                Text('• Interactive rebase cleans WIP commits before pushing'),
                Text('• Never force-push to shared branches (main/develop)'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared helpers ─────────────────────────────────────────────────────────────

Widget _header(String title, Color color) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(title,
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold, color: color)),
    );

Widget _code(String code) => Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(6),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(code,
            style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: Color(0xFFCDD6F4))),
      ),
    );

Widget _card({required Color color, required Widget child}) => Card(
      color: color,
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    );
