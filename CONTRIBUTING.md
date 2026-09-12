# Contributing to Aarogyam

Thank you for your interest in contributing. This document describes the workflow, code style expectations, and review process.

---

## Workflow

1. **Fork** the repository to your own GitHub account.
2. **Clone** your fork locally:
   ```bash
   git clone https://github.com/<your-username>/aarogyam.git
   cd aarogyam
   ```
3. **Create a feature branch** from `main`. Use a descriptive name:
   ```bash
   git checkout -b feat/chat-typing-indicator
   # or
   git checkout -b fix/cors-wildcard
   ```
4. **Make your changes.** Keep commits atomic and focused on a single concern.
5. **Validate** your changes before pushing (see [Validation](#validation) below).
6. **Push** your branch and open a **Pull Request** against `main`.
7. A maintainer will review the PR. Address any requested changes promptly.

### Commit message format

Use the [Conventional Commits](https://www.conventionalcommits.org/) style:

```
feat(chat): add typing indicator while awaiting AI response
fix(rag): handle empty PDF extraction gracefully
docs(readme): add architecture diagram
chore(deps): pin chromadb to 0.6.3
```

---

## Validation

### Flutter

```bash
cd aarogyam-flutter
flutter analyze          # must pass with zero errors
flutter format --set-exit-if-changed lib/   # must be no-op
flutter test             # all tests must pass
```

### Python backends

```bash
# From within each backend directory, with venv active:
black --check .          # zero formatting issues
python -m pytest         # all tests must pass (if tests exist)
```

---

## Code Style

### Dart / Flutter

- Format with `flutter format` (enforces `dart format` under the hood).
- No `FlutterFlow`-specific imports — use pure Flutter + Material 3.
- All leaf widgets should use `const` constructors where possible.
- Prefer `Theme.of(context)` over hard-coded color values.
- All env values read via `dotenv.env['KEY']` — no hardcoded secrets.

### Python

- Format with [black](https://black.readthedocs.io/) (`black .`).
- All credentials loaded via `os.getenv()` — no hardcoded keys.
- New endpoints must have a corresponding docstring and return JSON.
- Pin new dependencies in `requirements.txt` with an exact version.

---

## Issue Templates

When filing a bug or feature request, please include:

- **Bug**: steps to reproduce, expected behaviour, actual behaviour, and relevant log output.
- **Feature**: a clear description of the problem being solved and the proposed approach.

---

## Contributor License Agreement

By submitting a pull request you agree that your contribution is made under the [MIT License](LICENSE) and that you have the right to grant those rights.

---

## Questions

Open a [GitHub Discussion](../../discussions) or file an issue labelled `question`.
