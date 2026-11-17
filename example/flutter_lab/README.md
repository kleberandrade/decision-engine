# Decision Engine Lab

A separate Flutter example for ranking, AHP weights, sampled sensitivity and
weighted-matrix inspection. The package core stays pure Dart. All data is
synthetic and all computations run locally. No API server is required.

## Run

Requires Flutter >=3.35.0. From this directory:

```sh
flutter pub get
flutter run -d chrome
```

To validate/build:

```sh
flutter analyze --fatal-infos
flutter test
flutter build web --no-web-resources-cdn
```

The core remains compatible with Dart >=3.3.0; the UI example has its own Flutter
SDK requirement. It consumes the root source package through a local path.

## Explore

- Change relative criterion weights and compare weighted sum with TOPSIS.
- Apply an independently consistent AHP matrix to seed weights (CI/CR shown).
- Sweep a selected normalized weight through 21 points from 0 to 1.
- Inspect the full winning set, sampled stability, transition brackets and score
  curves. Connected lines interpolate samples for display, not exact boundaries.
- Inspect the weighted matrix; its rows follow original eligible-option order.
- Nova is excluded before ranking because availability is below 99.9%.

The controls use relative weights; displayed percentages are normalized. Give at
least one criterion a positive weight. To sweep a criterion, another criterion
must have positive weight so complementary proportions can be preserved.

## Português

Laboratório Flutter separado do núcleo: pesos interativos, soma ponderada/TOPSIS,
pesos AHP, 21 amostras por varredura e matriz ponderada. Execute os comandos acima.
Os dados são sintéticos e nenhum servidor é necessário. Os intervalos de mudança
não são limites matemáticos exatos; a fração de estabilidade não é probabilidade.
A interface é responsiva, com conteúdo rolável e tabela horizontal em telas menores.

## Native render smoke without a local server

For environments where the normal widget-test runner cannot bind localhost, a
supplemental native render smoke can use the SDK's existing headless tester with
its VM service disabled. It uses files and standard process streams:

```sh
bash tool/render_smoke.sh /path/to/flutter-sdk
```

Run the web build first to prepare assets. The smoke checks ranking, method/AHP
callbacks, criterion selection, reset, the zero-weight state and a narrow layout;
it writes desktop/narrow PNGs to `/tmp/decision-lab-preview` by default. Set
`DECISION_LAB_CAPTURE_DIR` to choose an output directory. The Flutter tester and
frontend compiler must already exist in that SDK cache. This supplemental smoke
is not the standard `flutter test` suite or a browser-interaction test.

Use `bash tool/render_smoke.sh /path/to/flutter-sdk --test-fonts` to reproduce
layout checks with the Ahem font used by widget tests. Dropdowns expand within
their available width so wide test/accessibility text does not overflow.
