# Contributing

Use semantic commits (`feat:`, `fix:`, `docs:`, `chore:`). Keep public APIs documented
with Dartdoc, English and Portuguese guides, examples and behavioral tests.

## Architecture

Follow [architecture](doc/architecture.md). Keep one decision in one place:
methods own math, constraints own eligibility, the engine owns orchestration.
Prefer small typed interfaces and immutable values. Never couple the core to
Flutter, HTTP, IO, other engines or a global strategy registry.

## Validation

```sh
dart pub get
dart format --output=none --set-exit-if-changed lib test example validation
dart analyze --fatal-infos
dart test
dart run example/decision_engine_example.dart
dart run example/weighted_sum.dart
dart run example/custom_method.dart
dart run example/ahp.dart
dart run example/ahp_review.dart
dart compile js example/ahp_review.dart -o /tmp/decision-ahp-review.js
node /tmp/decision-ahp-review.js
dart run example/sensitivity.dart
dart compile js example/decision_engine_example.dart -o /tmp/decision-engine.js
node /tmp/decision-engine.js
dart pub publish --dry-run
```

Also run `flutter pub get`, `flutter analyze --fatal-infos` and `flutter test`
in `validation/flutter_consumer/` for the source integration fixture.

Tests import only the public entry point. Verify independently calculated results,
invalid inputs, numerical edge cases, ownership and extension boundaries. Add a
failing regression test before a bug fix. Keep a concise action/reason/validation
record in `doc/engineering_log.md` and add user-facing changes under `Unreleased`.

## Releases

Version 0.1.0 is published under verified publisher kleberandrade.dev.
Subsequent releases are not published automatically. Before a
release, update the version and changelog together, run CI and review package
contents. During 0.x, incompatible API changes increment the minor version.
Do not claim hosted publication, publisher ownership or pub points without
verification. Do not commit tokens or create tags to test publishing automation.

Contributions use the MIT license. Desired repository topics are recorded in
`.github/topics.json`; that file alone does not update GitHub metadata.

For the pending initial source synchronization and release validation, see
[complete the first release](doc/complete_release.md). The one-time Git script
checks the exact expected remote commit before reconciling histories.

Validate `example/flutter_lab` separately with Flutter analysis, widget tests and
a web build. The lab is excluded from root Dart analysis and does not add Flutter
to core dependencies. See its README for the UI SDK requirement.
