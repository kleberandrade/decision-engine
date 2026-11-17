# Decision lab validation — 2026-11-17

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
Final run and deployment evidence is appended after remote verification.

The pub.dev API independently reported hosted **0.3.0**, publisher
`kleberandrade.dev`, MIT and **160/160** points. README claims were aligned to
that observed state. No package upload, tag or release was performed by this work.

## Limits

JSON configuration is the full editor, rather than a spreadsheet editor. AHP is
a disclosed fixed consistent example for the original three IDs. Sensitivity is
sampled, with no exact-boundary or continuous-robustness guarantee. The editor is
bounded to keep computations synchronous; cancel discards edits and restart
restores the complete sample. There is no running simulation requiring pause.
No arbitrary-matrix AHP UI, backend, persistence or external integration is claimed.
