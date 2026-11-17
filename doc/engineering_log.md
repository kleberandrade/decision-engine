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
