# binairo

Binairo puzzle generator and an Android/iOS app to play it.

## Layout

- `packages/binairo_core/`: pure Dart rules, solver and generator. No Flutter, so it is easy to port.
- `app/`: Flutter app that uses `binairo_core`.

Both are members of one [Dart pub workspace](https://dart.dev/tools/pub/workspaces) (root `pubspec.yaml`).

## How puzzles are made

1. Fill a random full board with backtracking search.
2. Remove clues one by one in random order.
3. Keep a clue removed only if the logical solver can still finish the board using the deductions allowed by the level.

Every deduction is forced, so a board the solver finishes has exactly one solution.
Easy uses pairs, gaps and line counts. Hard adds line lookahead and duplicate-line elimination, and must need them.

## Commands

```shell
flutter pub get

# Core
cd packages/binairo_core
dart test --exclude-tags slow   # fast tests
dart test --tags slow           # 1600 generated puzzles checked for uniqueness
dart run binairo_core:generate_puzzle --size 10 --difficulty hard --seed 42

# App
cd app
flutter test
flutter run --release           # phone plugged in with USB debugging on
flutter build apk --release     # build/app/outputs/flutter-apk/app-release.apk
```
