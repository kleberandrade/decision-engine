#!/usr/bin/env bash
# One-time synchronization for this repository's already-created GitHub scaffold.
set -euo pipefail

decision_source=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
decision_release="$(dirname "$decision_source")/decision_engine_release"
decision_expected_remote=04e990a2eb69406623d3081baa00d53b4996b1f6

fail() { printf '%s\n' "$*" >&2; exit 1; }

[[ $# -eq 0 || ( $# -eq 1 && "$1" == --check ) ]] || fail 'Usage: sync_initial_repository.sh [--check]'
[[ -d "$decision_release" ]] || fail "Release worktree missing: $decision_release"
[[ $(git -C "$decision_source" branch --show-current) == feat/ahp ]] || fail 'Source worktree must be on feat/ahp'
[[ $(git -C "$decision_release" branch --show-current) == main ]] || fail 'Release worktree must be on main'
for decision_checkout in "$decision_source" "$decision_release"; do
  [[ -z $(git -C "$decision_checkout" status --porcelain) ]] || fail "Uncommitted changes: $decision_checkout"
done
[[ $(git -C "$decision_source" remote get-url origin) == https://github.com/kleberandrade/decision-engine.git ]] || fail 'Unexpected origin URL'
git -C "$decision_source" merge-base --is-ancestor main feat/ahp || fail 'Feature branch must contain the local release baseline'
[[ $(awk '/^version:/ { print $2 }' "$decision_release/pubspec.yaml") == 0.1.0 ]] || fail 'Release worktree must contain version 0.1.0'

if [[ ${1:-} == --check ]]; then
  printf '%s\n' 'Local preconditions passed. No fetch, merge, rebase or push performed.'
  exit 0
fi

git -C "$decision_source" fetch origin
[[ $(git -C "$decision_source" rev-parse refs/remotes/origin/main) == "$decision_expected_remote" ]] || fail 'Remote main changed; inspect it before reconciling histories'
if git -C "$decision_source" show-ref --verify --quiet refs/remotes/origin/feat/ahp; then
  fail 'Remote feat/ahp already exists; inspect it before rebasing unpublished work'
fi

# The exact checked remote commit contains only our initial root scaffolding.
# Retain that history while preserving the reviewed, complete local source tree.
git -C "$decision_release" merge --allow-unrelated-histories --strategy=ours origin/main \
  -m 'chore: reconcile GitHub initialization with complete package source'
GIT_EDITOR=true git -C "$decision_source" rebase main
# Advance both branches together; no force push or remote deletion.
git -C "$decision_source" push --atomic origin \
  main:refs/heads/main feat/ahp:refs/heads/feat/ahp
git -C "$decision_source" branch --set-upstream-to=origin/main main
git -C "$decision_source" branch --set-upstream-to=origin/feat/ahp feat/ahp
printf '%s\n' 'Source synchronized. Inspect GitHub Actions before publishing 0.1.0.'
