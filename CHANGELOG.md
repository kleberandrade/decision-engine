# Changelog

## Unreleased

- Use locally drawn circular Brazil/UK language flags with tooltips, selected
  semantics/ring/check, keyboard focus and at least 48px touch targets.

- Add responsive Laboratory/Learn/Examples navigation, original vector branding
  and favicon, EN/PT-BR UI/help/feedback/education and browser language preference.
  Preserve active decisions across language/navigation changes.
- Embed implemented method formulas, interpreted examples, repository references,
  four runnable presets and five practical exercises in the learning area.
- PT: navbar, marca própria, idioma persistente, aprendizado integrado e exemplos
  executáveis, preservando o experimento durante a troca de idioma.

- Add a reciprocal AHP matrix editor for 1–10 scenario criteria, with fractions,
  automatic inverse cells, live CR/CI/RI and weight previews, consistency-gated
  apply and cancel. Keep the consistency indicator visible on narrow screens.
- Preserve applied AHP matrices in scenario JSON; validate consistency and weight
  correspondence on import, and omit stale evidence after manual weight changes.
- PT: editor da matriz AHP, razão de consistência e aplicação dos pesos ao cenário;
  evidência reproduzível no JSON, sem alterar o núcleo Dart.

- Add a visual scenario editor for criterion labels/directions/weights,
  alternative names/values and inclusive bounds, with add/remove, atomic apply,
  cancel and dependent-row cleanup. Keep JSON import/export alongside it.
- PT: editor visual com campos para critérios, pesos, alternativas e restrições;
  inclusão/remoção, validação ao aplicar e cancelamento sem alterar o cenário.

- Add validated, reproducible Flutter lab scenarios with editable alternatives,
  criteria, directions and inclusive constraints; cancel/restart controls.
- Show simultaneous weighted-sum/TOPSIS rankings, normalized/weighted matrices,
  distance diagnostics and accessible textual sensitivity samples.
- Add bilingual scenario guides and a test-gated GitHub Pages deployment.
- Paint lab panels with Material so interaction ink remains visible on Flutter
  3.50, as required by the framework assertion.
- PT: cenários reproduzíveis e editáveis, comparação dos métodos, amostras
  acessíveis e publicação do laboratório após validações.

## 0.3.0

- Add pure Dart weight sensitivity with complete scenarios, proportion-preserving
  sweeps, tie-aware winner stability, rank changes and sampled transition brackets.
- Add a separate Flutter lab with interactive weights, AHP, method comparison,
  score curves and weighted-matrix inspection.
- Constrain Flutter dropdowns to the available width, including Ahem widget-test
  fonts, and add an optional test-font native render smoke.
- Add bilingual sensitivity guides, a runnable Dart/JavaScript example and a
  dedicated Flutter lab CI job with widget tests and a web-build artifact.

## 0.2.0

- Add AHP criterion weighting using principal-eigenvector power iteration.
- Validate 1–10 reciprocal comparison criteria on the continuous [1/9, 9] scale.
- Expose immutable weights, eigenvalue estimate, CI/RI/CR, iterations and residual.
- Add explicit criterion directions and default rejection of inconsistent weights
  when composing AHP with weighted sum or TOPSIS.
- Document consistency thresholds, convergence controls and the fixed RI table
  in English and Portuguese, with runnable Dart and JavaScript examples.
- Add AHP composition coverage in the Flutter source-consumer fixture.
- Update hosted installation documentation and release preparation utilities.

## 0.1.0

- Initial 0.1.0 development baseline: pure Dart multicriteria decision engine.
- Add weighted sum with min-max normalization and TOPSIS with vector normalization.
- Add inclusive minimum/maximum eligibility constraints with complete reasons.
- Add immutable results, normalized weights, calculation traces and exact ties.
- Add public contracts for custom methods and constraints, validated at boundaries.
- Add English/Portuguese documentation, executable examples and behavioral tests.
- Add Dart CI for minimum/stable SDKs, JavaScript portability and publication dry-run.

- Preserve original input order for custom methods returning signed-zero ties.
- Add a Flutter source-consumer fixture and dedicated CI job for constrained rankings.

No hosted version has been released by this repository workflow.
