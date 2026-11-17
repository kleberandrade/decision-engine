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
