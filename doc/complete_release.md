# Complete the first release

Status: 0.1.0 is published, its publisher transfer is verified, and v0.1.0 is
released on GitHub. The one-time source synchronization has already completed.
Do not rerun it or republish 0.1.0; the procedure below is historical. Repository
documentation updates still need a normal Git push from a network-enabled terminal.

Run these scripts in a terminal with normal network and local socket access:

```sh
bash /Users/kleber/Projects/decision_engine/tool/sync_initial_repository.sh
bash /Users/kleber/Projects/decision_engine/tool/verify_initial_release.sh
```

The first script requires clean source/release worktrees and verifies that remote
main is exactly the known initial scaffolding commit before any history changes.
It retains that history with an `ours` merge, preserves the complete local source,
rebases the unpublished AHP feature branch and pushes both refs atomically without
force. It stops if remote main changed or a remote AHP branch already exists.
`--check` validates local preconditions only. If interrupted after local changes,
inspect Git status/history before retrying this one-time synchronization script.

The second script validates version 0.1.0 in `decision_engine_release`, including
Dart, JavaScript, Flutter and the publication dry-run. Neither script publishes
packages or creates tags. Verify minimum/stable SDK and Flutter results in
[GitHub Actions](https://github.com/kleberandrade/decision-engine/actions).
Only after all checks pass, run `dart pub publish` in the release worktree,
complete account authentication if required, verify hosted 0.1.0 and transfer it
to `kleberandrade.dev` through pub.dev administration. AHP remains on the separate
0.2.0-dev.1 feature branch. See the [Portuguese guide](complete_release.pt-BR.md).
