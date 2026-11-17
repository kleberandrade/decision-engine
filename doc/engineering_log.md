# Engineering log

## Initial 0.1.0 baseline

- Action: inspected fuzzy_engine, genetic_engine and neural_engine conventions.
  Reason: preserve pure Dart boundaries, typed strategies, public exports, MIT
  licensing, bilingual guides and observable validation.
- Action: implemented weighted sum, TOPSIS, hard constraints and immutable traces.
  Reason: deliver an inspectable decision pipeline before adding more algorithms.
- Action: validated finite values, schema, unique IDs/names, relative weights and
  strategy output dimensions. Reason: fail explicitly at public boundaries.
- Action: added independent numeric examples, edge cases and extension tests.
  Validation: 27 behavioral tests, formatter and strict analysis passed locally.
- Action: pinned signed-zero tie order with a failing public-API regression test,
  then treated numerically equal scores as ties before sorting.
  Validation: targeted failure reproduced; complete suite passed after correction.
- Action: ran three examples and compiled/executed provider selection in JavaScript.
  Validation: expected ranking and exclusion checks passed on Dart 3.11.5 and Node.
- Action: added CI for minimum/stable Dart and bilingual documentation, roadmap,
  contribution rules and desired GitHub topics. Reason: match sibling workflows.
- Environment: direct GitHub cloning fails DNS resolution. Created the public
  repository and uploaded root scaffolding through GitHub UI, then stopped manual
  uploads at the user's request to use normal Git commands. Source code remains
  committed locally until Git fetch/rebase/push can run with network access.
- Limits: minimum-SDK and Flutter checks have not run locally; publication dry-run
  was attempted but online dependency resolution is blocked. No release tag,
  publisher transfer or pub.dev publication has been performed.

## Release preparation

- Applied and verified eight GitHub topics through repository metadata.
- Added a local Flutter consumer with widget checks for both built-in methods.
  Validation: Flutter static analysis passed on Flutter 3.41.9. Widget execution
  was blocked before test startup: local server socket binding is not permitted.
- Added a dedicated Flutter CI job, excluding its package from root Dart analysis.
- Retried Git network access: DNS still cannot resolve github.com. No manual
  source uploads were resumed. Pub dry-run remains blocked by online resolution.

## Publication handoff preparation

- Grouped the initial baseline notes under 0.1.0 while retaining Unreleased.
- Added a release-candidate checklist that explicitly retains the outstanding
  minimum-SDK, Flutter runtime, remote-CI and publication checks.
- Retried GitHub access; DNS remains unavailable. No tag or publication was made.

## AHP on feat/ahp (0.2.0-dev.1)

- Preserved 0.1.0 on local main; added AHP in an independent feature branch.
- Read Ishizaka & Labib (2009) for eigenvector/consistency conventions and RI
  Table 1. Documented the chosen continuous judgment domain, supported orders,
  tolerances and inclusive CR policy in English and Portuguese.
- Wrote public-API tests first and observed missing-API failures, then added
  power iteration, finite reciprocal-matrix validation, CI/RI/CR diagnostics,
  immutable results and explicit conversion to directed ranking criteria.
- Added independent eigenvalue checks and a nontrivial order-four residual check.
  Validation: all 40 tests, strict analysis and formatting passed. The AHP example
  passed on Dart and as JavaScript executed by Node.
- Extended CI and contribution checks for AHP; remote CI remains pending because
  the complete source has not been pushed. No release or publication is claimed.

## Guarded release handoff

- Retried direct GitHub access; the session still cannot resolve github.com.
- Added a one-time Git synchronization script that checks clean worktrees, local
  ancestry and the exact known remote scaffold commit before any merge/rebase.
  It preserves source, retains remote history and uses an atomic non-force push.
- Added an initial-release verifier and bilingual execution instructions. Neither
  script publishes or creates tags. Validated Bash syntax and read-only local
  preconditions; live network synchronization remains unexecuted.
- Exercised the synchronization script against disposable local bare remotes,
  substituting only fixture paths and the expected initial SHA. Verified that
  both exact source trees survive, the remote scaffold remains an ancestor,
  both refs are pushed atomically, dirty worktrees stop without changing HEAD,
  and unexpected remote commits stop before merge/rebase. All three scenarios
  passed. This local simulation does not constitute a push to GitHub.
