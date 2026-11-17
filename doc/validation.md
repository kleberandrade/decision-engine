# Validation evidence

Local validation uses Dart 3.11.5 on macOS arm64. Dependencies were resolved
offline from the preinstalled cache into an isolated writable cache because
outbound DNS and writes to the global SDK/cache are restricted in this session.

| Check | Result |
| --- | --- |
| Dart formatter | Passed |
| `dart analyze --fatal-infos` | Passed, no issues |
| Public-API behavioral tests | 40 passed (27 baseline + 13 AHP) |
| Provider selection, weighted sum, custom method examples | Passed |
| Compile provider and AHP examples to JavaScript and execute with Node | Passed |
| Minimum SDK 3.3.0 | Passed in GitHub Actions for fcc0a86 |
| Flutter source-consumer integration | Passed in GitHub Actions; local execution remains socket-restricted |
| Publication dry-run | Passed in stable GitHub Actions job; local online resolution remains restricted |
| Hosted publication / pub points | Hosted 0.1.0 verified; 160 points; verified publisher kleberandrade.dev |
| Git synchronization | Source main/feat/ahp synchronized; subsequent documentation update pending push |

Tests include independent weighted-sum and TOPSIS calculations, both criterion
directions, signed/zero/extreme finite observations, constant columns, zero
weights, eligibility order, all rejection reasons, empty and singleton sets,
immutability, repeated evaluations, malformed custom output and exact tie order.
A signed-zero regression was first observed failing, then fixed and revalidated.

The source CI matrix covers Dart 3.3.0 and stable, examples, JavaScript compilation
and stable publication dry-run. Configuration alone does not mean remote checks
have run. Once network access is available, run the complete CONTRIBUTING checks
and inspect GitHub Actions before any release.

The Flutter fixture runs on Flutter 3.41.9 against the local source package.
It is designed to validate rendered constrained rankings for both methods, not hosted
installation, device benchmarks, or a visualization lab. Eight repository topics
were applied and verified on GitHub. Online publication dry-run remains blocked.

`flutter test` could not start the test process because the sandbox disallows
binding a local server socket on 127.0.0.1. Neither widget test ran; this is not
a passing runtime integration check.

## AHP development evidence

The 0.2.0-dev.1 feature branch adds 13 tests for known consistent weights,
independently known cyclic-matrix eigenvalues, a nontrivial order-four
matrix/eigenvector relation, RI orders 1–10, malformed matrices, threshold
boundaries, nonconvergence, immutability and composition with both methods.
All 40 tests passed. Strict analysis and Dart/JavaScript AHP examples passed.
The first AHP tests failed because the public API did not exist, before the
implementation was added. No pub.dev name availability or publisher ownership
claim was verified. No publication was attempted after a blocked dry-run.

## Release handoff scripts

Bash syntax checks and read-only local preconditions passed. A disposable-local-
remote integration exercise verified successful atomic synchronization with
source/history preservation, dirty-worktree rejection and unexpected-remote-
commit rejection. Only fixture bindings were substituted in the script copy.
The actual GitHub push and full release-verifier execution remain blocked by
this session's network/socket restrictions.

## Verified release status

[CI run 44003996882](https://github.com/kleberandrade/decision-engine/actions/runs/44003996882)
passed the Dart 3.3.0/stable matrix and Flutter job for `fcc0a86`.
[pub.dev 0.1.0](https://pub.dev/packages/decision_engine/versions/0.1.0) was verified
with 160 points. Its transfer to verified publisher `kleberandrade.dev` completed
successfully and the package page displays that publisher.
[GitHub release v0.1.0](https://github.com/kleberandrade/decision-engine/releases/tag/v0.1.0)
was created on `fcc0a86`. Local environment limitations above describe historical
local attempts; the successful remote checks supersede release blockers.

The tag was created through GitHub's release interface, not as a local annotated
Git tag. The initial candidate checklist remains unchanged as historical evidence.
Repository README updates are separate from the already-published package archive;
they will appear in a future package release, not by republishing 0.1.0.

## 0.2.0 candidate validation

- Core API review retained the compatible AHP contracts and the pure Dart core.
- Version 0.2.0: all 40 Dart tests, strict analysis and formatting passed.
- Four Dart examples passed; both provider and AHP examples compiled to JavaScript
  and executed successfully with Node.
- Flutter source-consumer dependency resolution and static analysis passed.
- Added one AHP-composition widget test (three widget tests now configured).
  Runtime execution could not start because local socket binding is forbidden.
- Publication dry-run was attempted and stopped after 30 seconds waiting for
  online dependency resolution. It did not complete or publish anything.
- The GitHub connector permits reads but rejected tree/PR creation with HTTP 403
  Resource not accessible by integration. This is an integration permission error,
  not a completed source push or an automatic approval rejection.
- Main integration is prepared locally. The new source must be pushed and pass
  its minimum/stable Dart and Flutter CI before publication and the v0.2.0 tag.

## 0.3 development validation

- Verified the hosted 0.2.0 score page: 160/160 points, including 50/50 static
  analysis, under publisher kleberandrade.dev.
- Added 12 public-API sensitivity tests, first observed failing for the absent
  API. All 52 core tests passed after implementation. Strict Dart analysis,
  formatting and the sensitivity CLI/JavaScript reference example passed.
- Flutter lab dependency resolution, static analysis and web compilation passed
  on Flutter 3.41.9. A lab-specific widget suite with four tests is configured in
  CI; its normal local runner is subject to the session's socket restriction.
- A supplemental headless native render smoke used the installed SDK tester with
  no VM service or local server. Ranking, method switch, AHP weights/CR, sweep
  selection, reset and all-zero weights were checked. Desktop 1280x1600 and narrow
  390x2200 captures rendered with zero framework/layout errors and were inspected.
- This smoke exercises widget callbacks directly; it does not claim browser
  gesture testing or successful execution of the normal widget-test suite.
- The 0.3 branch has not been published. Remote CI and source push are verified
  separately from local evidence. New CI includes a Flutter-lab analysis/test/web
  build job and downloadable web-build artifact.

## 0.3.0 release candidate correction

The first sensitivity CI (44010623342) passed both Dart SDK jobs and the Flutter
source consumer. Its lab job failed all four widget scenarios with the same
38-pixel horizontal overflow. This was reproduced locally with `--use-test-fonts`
before fixing the dropdown width constraints; the native Ahem smoke then passed.
The normal-font smoke also passed method/AHP/sweep/reset/zero-weight and narrow
layout checks. Strict Dart and Flutter analysis and all 52 core tests passed for
the corrected candidate. The candidate's new remote CI must still pass before
hosted publication. No hosted 0.3.0 or v0.3.0 source tag is claimed here.
