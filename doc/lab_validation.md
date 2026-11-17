# Decision lab validation — 2026-11-17

## Visual editor update

The lab now offers a dedicated visual dialog for criterion labels, preference
directions and weights; alternative names and values; and criterion-specific
inclusive minimum/maximum constraints. Add/remove actions retain stable IDs,
remove dependent values/bounds when a criterion is removed, and keep at least
one criterion and one alternative. New values default to zero. The isolated draft
is validated through `LabConfiguration.parse` before replacing dashboard state.
Both editor paths use that boundary, and JSON preserves method/sweep settings.
Current slider weights, including all-zero drafts, remain editable.

Validation completed for this update:

- **52 core tests, 3 Flutter consumer tests and 16 lab tests** passed locally.
  Six new widget tests were written before the editor and first failed because
  the editor module did not exist. They cover changes to values/weights/bounds,
  add/remove cleanup, cancel/invalid numbers, direction/maximum changes reaching
  dashboard and JSON, large-text/mobile accessibility, and zero-weight recovery.
- Core, consumer and lab strict analysis passed. All five CLI examples and the
  compiled JavaScript example executed. No runtime dependency or core API changed.
- Production Web build passed with the existing Pages base path. The SDK remains
  an isolated Flutter 3.41.9 copy; remote CI also exercises stable Flutter 3.50.
- Native smoke opened and canceled the visual editor and captured its criteria,
  alternatives, constraints and narrow layout. Real captures:
  [desktop](evidence/visual-editor-desktop.png),
  [alternatives](evidence/visual-editor-alternatives.png),
  [constraints](evidence/visual-editor-constraints.png),
  [narrow](evidence/visual-editor-narrow.png). These are local native renders.
- Chrome manual Web check opened the visual form, changed cost weight to 1 and
  availability minimum to 100, and applied it. The dashboard correctly displayed
  no eligible alternatives, all four rejection reasons and changed normalized
  weights, while retaining the separate JSON action.

The existing test-gated Actions workflow publishes this update to the same Pages
URL. Exact remote validation/publication results are recorded by that workflow.

## Scope

Only `decision_engine` was changed. The core's runtime code, dependency-free
architecture and MIT ownership remain intact. `steering-engine` was read as a
Pages workflow reference; its files were not changed. The starting checkout was
clean, at 56e5634 on `feat/sensitivity`, matching local and remote `main`.

A separate copy of Flutter **3.41.9 / Dart 3.11.5** and a separate pub cache under
`/tmp/decision-lab-*` were used. The shared Flutter SDK was not updated or patched.
`pub outdated` and `pub upgrade` found no newer resolvable core dependencies on
this SDK. Newer transitive packages require other SDK/constraint combinations;
Flutter test dependencies are pinned by Flutter. No overrides were introduced.
The library's minimum Dart 3.3 support is additionally checked in remote CI.

## Completed local checks

- Core: strict analysis; formatting; all **52 public-entry-point tests**.
- All five documented CLI examples executed successfully. The main example was
  also compiled to JavaScript and executed with Node.
- Flutter consumer: strict analysis and **3 integration-widget tests**.
- Lab: strict analysis and **10 tests** (4 scenario-boundary tests, 6 widget tests).
  The scenario tests first failed because the new parser did not exist, then
  passed after implementation. An initial expected winner was corrected: TOPSIS
  favors Atlas whereas weighted sum favors Vega; the guide gives their scores.
- Widget interactions: method selection, AHP/reset, sweep selection, narrow
  scrolling, invalid import preserving current data, cancel, custom all-rejected
  scenario, complete restart. Large-text checks use the real dark application
  theme at 1.6×, 390×844, with labeled-target, Android touch-target and text-contrast
  guidelines. A test initially used a default light host; it was corrected to
  test the actual application rather than interpreting its dark colors on white.
- Web release build with `--no-web-resources-cdn --base-href /decision-engine/`.
  The compiler's Wasm compatibility dry-run passed. This is not a separate tested
  Wasm deployment. The compiler emitted a nonfatal unused Cupertino font-family
  warning; the app uses Material icons and the built output rendered correctly.
- Native supplemental smoke: method/AHP/sweep/reset callbacks, zero weights,
  narrow layout and real PNG captures with no Flutter framework errors.
  Captures: [desktop](evidence/desktop.png), 1280×1600;
  [narrow](evidence/narrow.png), 390×2200. Both were visually inspected. These
  are real native Flutter captures, not browser/device screenshots or mockups.
- Chrome served the production Web build under the Pages subpath. The manual
  browser check enabled Flutter accessibility, changed ranking method by keyboard
  to TOPSIS (Atlas 0.6232), opened the editor, submitted invalid JSON and canceled.
  This complements widget checks; it is not cross-browser or assistive-device
  certification.

## Hosted checks

GitHub metadata initially had eight relevant topics and no homepage or Pages
site. Pages was configured to build via Actions; the workflow deploys only on
`main`, after both Dart SDK jobs, Flutter consumer and Flutter lab pass. It uses
the explicit `/decision-engine/` base path and GitHub's deployment environment.
The first remote run,
[44168753596](https://github.com/kleberandrade/decision-engine/actions/runs/44168753596),
passed both Dart jobs and the consumer. Flutter **3.50.0** exposed the lab's
obscured ListTile ink via a framework assertion. The already-failing widget suite
was retained; panels now paint on shaped Material surfaces and the textual
sample expansion is also exercised. Local tests/build passed again after the fix.
The corrected source,
[43d993b](https://github.com/kleberandrade/decision-engine/commit/43d993bf9c2912639d552a7a72a487a44a26b32a),
passed all five jobs in
[run 44169249461](https://github.com/kleberandrade/decision-engine/actions/runs/44169249461):
Dart 3.3.0, stable Dart, Flutter consumer, Flutter lab and Pages deployment.
The hosted build uses stable Flutter **3.50.0**, resolving its compatible current
transitive dependencies independently of the local Flutter 3.41.9 cache.

The public [laboratory](https://kleberandrade.github.io/decision-engine/) was then
opened in Chrome and visually verified: the complete application rendered at
that HTTPS subpath, displaying Vega at 0.6500, the constraint exclusion, scenario
editor entry and raw data table. This verifies hosted publication rather than
inferring it from workflow configuration. The README and repository About link
to this verified URL. GitHub metadata was checked after updating its English
description, homepage and ten relevant topics. Pub and CI badges were checked;
the pub badge reports v0.3.0. Package dry-run after the source fix completed with
**zero warnings** and did not upload anything.

The pub.dev API independently reported hosted **0.3.0**, publisher
`kleberandrade.dev`, MIT and **160/160** points. README claims were aligned to
that observed state. No package upload, tag or release was performed by this work.

## Limits

Visual forms edit the scenario; JSON remains available for import/export. AHP is
a disclosed fixed consistent example for the original three IDs. Sensitivity is
sampled, with no exact-boundary or continuous-robustness guarantee. The editor is
bounded to keep computations synchronous; cancel discards edits and restart
restores the complete sample. There is no running simulation requiring pause.
No arbitrary-matrix AHP UI, backend, persistence or external integration is claimed.
