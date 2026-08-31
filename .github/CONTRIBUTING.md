# Contributing to Kanzan Learn Flutter

Thanks for your interest in contributing! This is a learning repository, so contributions that help others learn Flutter are especially welcome.

---

## What You Can Contribute

- **Fix typos or errors** in code comments or documentation
- **Improve explanations** — clearer comments, better examples
- **Add mini projects** for a phase (follow the existing pattern)
- **Report bugs** — broken code examples, incorrect behavior
- **Suggest topics** — missing concepts, useful additions to a phase

---

## Ground Rules

- Keep code beginner-friendly — **comment everything**, explain the "why"
- Match the existing code style (Dart style guide, proper widget structure)
- One pull request per concern — don't mix multiple unrelated changes
- English for code and comments; discussion in any language is fine

---

## Setup for Development

```bash
# Fork & clone
git clone https://github.com/<your-username>/Kanzan_Learn_Flutter.git
cd Kanzan_Learn_Flutter

# Install dependencies
flutter pub get

# Run the app to verify everything works
flutter run
```

---

## Workflow

1. Fork this repository
2. Create a branch: `git checkout -b fix/typo-phase2` or `feat/add-phase3-example`
3. Make your changes
4. Run the app and verify nothing is broken
5. Commit with a clear message (see below)
6. Push and open a Pull Request

---

## Commit Message Format

```
type: short description

Examples:
fix: correct stateful widget example in phase1
feat: add mini project for phase2 navigation
docs: improve README quick start section
chore: update pubspec.yaml dependencies
```

Types: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`

---

## Pull Request Checklist

Before submitting, please make sure:

- [ ] App runs without errors (`flutter run`)
- [ ] No analysis issues (`flutter analyze`)
- [ ] Comments explain the concept, not just what the code does
- [ ] No secrets or private keys are included
- [ ] PR description explains what changed and why

---

## Reporting Issues

Please include:
- What you expected to happen
- What actually happened
- Steps to reproduce
- Flutter version (`flutter --version`) and OS

---

## Questions?

Open a GitHub Discussion or reach out via email: **kanzankazu46@gmail.com**
