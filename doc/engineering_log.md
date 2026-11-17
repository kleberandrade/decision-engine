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

## Verified 0.1.0 release

- Observed main fcc0a86 and feat/ahp cc1479b synchronized with remote tracking refs.
- Verified GitHub Actions run 44003996882 passed Dart 3.3.0, stable and Flutter.
- Verified hosted 0.1.0 with 160 pub points. Completed and verified the authorized
  transfer from legacy uploader ownership to publisher kleberandrade.dev.
- Created GitHub release/tag v0.1.0 specifically on validated commit fcc0a86.
  The tag was created through GitHub's interface; it is not a local annotated tag.
- Updated bilingual README installation and validation evidence without changing
  published source or republishing the same version. Documentation push remains
  subject to this session's outbound-network restriction.

## 0.2.0 release preparation

- Reviewed the AHP public classes, numerical policies and composition boundaries;
  retained the existing compatible API and pure Dart, dependency-free core.
- Promoted the source version from 0.2.0-dev.1 to 0.2.0, grouped unreleased notes
  under the target version and retained all published 0.1.0 notes unchanged.
- Added an AHP-to-ranking Flutter widget scenario and bilingual release guidance.
  Runtime validation and hosted publication are recorded only after verification.

- Validation: 40 core tests, strict analysis, formatting and all examples passed;
  provider/AHP JavaScript execution passed. Flutter analysis passed, but the
  runner is blocked by local socket restrictions. Pub dry-run could not finish
  network resolution. The 0.1.0 changelog section was preserved byte-for-byte.
- GitHub tree creation and PR creation both returned 403 (integration write
  access unavailable). No source upload, release tag or hosted 0.2.0 is claimed.

## 0.3 sensitivity and Flutter laboratory

- Verified 0.2.0 analysis at 160/160 pub points and started feat/sensitivity with
  version 0.3.0-dev.1. Kept the stable main source and published notes intact.
- Wrote public-API tests first, observed missing-API failures and implemented
  complete weight scenarios plus normalized one-criterion sweeps by composition.
- Added tie-set comparisons, rank deltas, sample stability and transition brackets;
  documented the absence of exact crossing/continuous robustness guarantees.
  Validation: all 52 tests, strict Dart analysis and CLI/JavaScript example passed.
- Built a separate Flutter package for interactive weights, method comparison,
  AHP, sample curves and weighted-matrix inspection. Kept Flutter outside core.
- Validated Flutter analysis and a web build. Added four CI widget scenarios.
- Compiled and ran a supplemental headless native render smoke using standard
  files/process streams without opening a server. Checked callbacks and zero-weight
  handling, rendered desktop/narrow PNGs with zero framework errors, and inspected
  the captures. This does not substitute a claimed standard widget-test pass.

## 0.3.0 final preparation

- Read failed lab job 133796507215 from CI run 44010623342: all four widget
  scenarios reported a 38-pixel horizontal RenderFlex overflow. Core minimum/
  stable Dart and the separate Flutter consumer jobs passed.
- Reproduced the same 38-pixel overflow locally using the SDK headless tester
  with --use-test-fonts, before changing the layout. This pinned the failure
  independently of the socket-blocked standard local runner.
- Expanded both dropdowns within available width and bounded long criterion
  labels. Added --test-fonts to the supplementary native smoke script.
- The Ahem smoke passed after the fix. Promoted source version to 0.3.0,
  grouped unreleased notes, preserved published changelog notes and prepared
  bilingual installation/release documentation. Final remote CI is still a gate.

## Reproducible online decision laboratory — 2026-11-17

- Read shared modernization, project architecture/contribution instructions and
  ub-mode; confirmed clean checkout, remote/main agreement and isolated tooling.
- Added scenario tests before the JSON boundary, observed missing-API failure,
  then implemented immutable validated lab configuration through the public core.
- Replaced fixed UI inputs with editable/copyable complete scenarios; added
  atomic apply/cancel, complete restart, method comparison, normalized/weighted
  values, TOPSIS distances and textual sensitivity samples. Disclosed fixed AHP.
- Added widget interactions and accessibility checks; verified 52 core, 3 consumer
  and 10 lab tests, strict analysis, CLI/JS examples and production Web compilation.
  Captured and inspected desktop/narrow output; manually exercised Chrome Web UI.
- Added bilingual scenario/limits guides. Verified hosted 0.3.0, MIT, publisher
  and 160/160 points from pub.dev rather than inferring publication from source.
- Configured test-gated Pages workflow and correct project base path. Remote
  validation/publication outcomes are recorded in doc/lab_validation.md.
- The specialized crapper/dryer/mutator tools are unavailable in this session;
  scenario boundary and public behavior tests were used for concrete validation.

- CI run 44168753596 passed Dart minimum/stable and consumer checks but exposed
  Flutter 3.50's assertion that the new ExpansionTile ink was obscured by the
  panel's DecoratedBox. Existing widget tests failed before the fix. Replaced
  the panel decoration with a shaped Material surface, preserving appearance
  while giving controls a visible ink ancestor; revalidated locally before push.

- Corrected source 43d993b passed all five jobs in CI run 44169249461, including
  stable Flutter 3.50 and Pages deployment. Opened the public HTTPS lab in Chrome
  and visually verified the running UI. Recorded exact links, ten actual GitHub
  topics and successful zero-warning package dry-run in doc/lab_validation.md.


## Visual scenario editor — 2026-11-17

- Kept the existing clean checkout and shared SDK untouched. Added six widget
  tests first and observed the missing-editor failure before implementing it.
- Added isolated visual drafts for criteria/weights/directions, alternatives/
  values and inclusive bounds, with add/remove and dependent cleanup. Reused the
  existing scenario parser for atomic apply; preserved separate JSON import/export.
- Verified 52 core, 3 consumer and 16 lab tests, strict analyses, all CLI examples,
  JavaScript execution and the production Web build. Added native render captures
  of each editor section and narrow layout; manually applied a modified weight
  and constraint in Chrome and confirmed the resulting empty eligible set.
- Updated bilingual scenario guides, README entry points and Unreleased notes.
  No dependencies, core APIs, package version, publisher settings or tags changed.

- Added an always-visible, announced footer summary for invalid visual fields.
  The new expectation first failed, then passed after the fix; retained field
  errors and draft state and reran the lab suite, strict analysis and Web build.

- CI 44172248537 passed both Dart jobs and the consumer, but strict Flutter 3.50
  analysis flagged the new Material compatibility imports. Applied the same
  import-scoped deprecation bridge used by the existing lab files to retain its
  declared Flutter >=3.35 minimum, without suppressing type checks or changing
  the core. The bridge and local/remote SDK versions are documented.

- Source 5144160 passed every job in run 44172690594, including Flutter 3.50 and
  Pages. Opened the public URL and visually inspected the published editor, with
  JSON still available alongside it. Package dry-run passed with zero warnings.
  Recorded exact source/run/public links in doc/lab_validation.md.

## Editable AHP matrix — 2026-11-17

- Wrote missing-editor/JSON evidence tests first, observed their expected failure,
  and composed the existing AhpWeighting core in a separate Flutter dialog.
- Added reciprocal upper-triangle editing, fractions, default equal comparisons,
  a sample preset, CR/CI/RI/eigenvalue and weights, consistency-gated application
  and cancel. Kept raw CR acceptance separate from rounded display.
- Added optional validated AHP evidence to scenario JSON, checking IDs, consistency
  and normalized-weight correspondence; omitted stale evidence after manual edits.
- An existing reset test exposed lazy initialization of reset weights after AHP
  replacement; eagerly captured reset weights in initState. A new mobile test
  exposed a clipped CR indicator; moved CR to the fixed action area.
- Validated 52 core, 3 consumer and 24 lab tests, strict analysis, all CLI/JS examples,
  Web build and native AHP desktop/narrow captures. Core runtime APIs and SDK remain
  unchanged. Bilingual navigation/Learn requested during this work follows next.

## Bilingual navigation and integrated learning — 2026-11-17

- Incorporated the explicitly requested navbar, original three-input decision mark,
  compact variant/favicon, EN/PT-BR selection and integrated Learn/Examples pages.
- Kept all engine calculations in the core. Rendered authored UI/help/feedback in
  the selected language without rewriting scenario data; language preference uses
  browser localStorage with a safe fallback, and experiment state remains in the
  existing dashboard while navigating sections or changing languages.
- Educational content follows methods/AHP/sensitivity/getting-started sources:
  actual formulas, independent provider calculations, four runnable presets,
  explicit numerical/feature limits, links/credits and exactly five exercises.
- Added widget tests for state preservation with AHP, mobile navigation, keyboard,
  runnable examples and documentation/GitHub targets. Validation is recorded below.

- Final combined validation passed 52 core, 3 consumer and 28 lab tests, strict
  analysis, formatting, Web build and native bilingual/AHP captures. Added Flutter's
  own UI localization SDK package; core manifests/runtime dependencies unchanged.
- Manually exercised the Web build in Chrome: reciprocal AHP ratios, CR=0, applied
  30/10/60 weights, English controls/feedback, 390px navbar and Learn, keyboard
  navigation, and language persistence after reload (`html lang=en`). Restored
  browser viewport. Verified English/PT reference links, reviewed diff and scanned
  added sources for credential patterns; none found. Remote main matched baseline.

- Incorporated the requested circular Brazil/UK language buttons as local vector
  paintings, with selected ring/check, language-name tooltips, selected semantics,
  keyboard focus and >=48px targets; retained the same state/storage controller.
- CI 44177633354 passed core/consumer jobs but flagged Flutter 3.50's relocated
  GlobalMaterialLocalizations symbol. Kept the declared Flutter >=3.35 bridge
  narrowly scoped to that symbol, matching the existing Material import bridges.
  All other analysis/type checks remain enabled; the following CI revalidates it.

- Added the circular-flag selection test; final local suite now has 29 lab tests
  (84 total including core/consumer), retaining all AHP and scenario checks.
