# Repository Guidelines

## Project Structure & Module Organization
- `lib/worker.dart` is the single public entry point and re-exports `draftmode_worker`; keep additional facades similarly lean and documented inline.
- Shared assets such as logos and platform icon variants live under `assets/`; run `ios.build.icons.sh` when updating iOS icon sizes.
- Package configuration (`pubspec.yaml`, `pubspec.lock`) defines SDK constraints and the local path dependencies on sibling repos; update both when bumping any dependency.
- Root-level scripts and configs should remain minimal—add new tooling in dedicated subdirectories (e.g., `tool/`) to avoid cluttering the facade package.

## Build, Test, and Development Commands
- `flutter pub get` — install or refresh dependencies after pulling or editing `pubspec.yaml`.
- `dart format .` — apply canonical Dart formatting before committing.
- `dart analyze .` — run the analyzer to catch API breaks or missing exports.
- `flutter test` — execute the package test suite (add tests under `test/` as described below).

## Coding Style & Naming Conventions
- Follow Dart's standard 2-space indentation and prefer `lower_snake_case.dart` filenames; match the existing `worker.dart` naming.
- Keep facades minimal: export statements first, optional documentation comments next, with no side effects.
- Document public APIs with triple-slash comments and favor descriptive class names (e.g., `WorkerFacade` over abbreviations).

## Testing Guidelines
- Place unit and integration tests in `test/`, mirroring the library structure (`test/worker_facade_test.dart`).
- Use the Flutter `test` package; aim for meaningful coverage of export behavior and any adapter logic you add.
- When wrapping upstream packages, add regression tests that fail if the exported API stops compiling against the sibling repo.

## Commit & Pull Request Guidelines
- Keep commit messages short and imperative (current history uses one-line summaries like `init project`).
- Reference related issues in the body (`Fixes #123`) and describe behavioral impact.
- Pull requests must include: purpose summary, testing evidence (command output or screenshots for UI-facing changes), and any dependency/version updates in `pubspec.yaml`.
- Ensure CI prerequisites (`dart format`, `dart analyze`, `flutter test`) pass locally before requesting review.

## Documentation Guidelines
- README begins with a single-sentence facade overview followed by a bullet list of wrapped packages.
- Each bullet links to the upstream repository and provides a one-line summary of the package’s purpose; omit additional sections or setup details.
- Update the README immediately whenever a wrapper is added, removed, or retargeted so the list stays authoritative.
