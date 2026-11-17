#!/usr/bin/env bash
# Validate the 0.1.0 worktree without publishing or creating release tags.
set -euo pipefail

decision_source=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
decision_release="$(dirname "$decision_source")/decision_engine_release"
[[ $# -eq 0 ]] || { printf '%s\n' 'Usage: verify_initial_release.sh' >&2; exit 1; }
[[ -f "$decision_release/pubspec.yaml" ]] || { printf '%s\n' 'Release worktree missing' >&2; exit 1; }
[[ $(awk '/^version:/ { print $2 }' "$decision_release/pubspec.yaml") == 0.1.0 ]] || { printf '%s\n' 'Expected version 0.1.0' >&2; exit 1; }
for decision_command in dart flutter node; do
  command -v "$decision_command" >/dev/null || { printf 'Missing command: %s\n' "$decision_command" >&2; exit 1; }
done

decision_validation_tmp=$(mktemp -d "${TMPDIR:-/tmp}/decision-validation.XXXXXX")
trap 'rm -rf "$decision_validation_tmp"' EXIT
cd "$decision_release"
dart pub get
dart format --output=none --set-exit-if-changed lib test example validation
dart analyze --fatal-infos
dart test
for decision_example in decision_engine_example weighted_sum custom_method; do
  dart run "example/$decision_example.dart"
done
dart compile js example/decision_engine_example.dart -o "$decision_validation_tmp/provider.js"
node "$decision_validation_tmp/provider.js"
(
  cd validation/flutter_consumer
  flutter pub get
  flutter analyze --fatal-infos
  flutter test
)
dart pub publish --dry-run
printf '%s\n' 'Local release checks passed. Minimum-SDK and remote CI results must also pass before publishing.'
