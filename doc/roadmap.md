# Roadmap

[Português](roadmap.pt-BR.md)

## 0.1.0 — initial baseline

- Pure Dart core, public interfaces and immutable models.
- Weighted sum with min-max normalization; TOPSIS with vector normalization.
- Inclusive eligibility constraints and complete rejection reasons.
- Deterministic ranking, exact ties, calculation traces and custom methods.
- English/Portuguese guides, executable examples, behavioral tests and CI.

## 0.2.0 — published with 160/160 points

- AHP pairwise criterion weighting with reciprocal-matrix validation,
  consistency index and consistency ratio.
- Document the random-index table, supported matrix sizes and acceptance policy.
- Compose AHP-generated weights with either ranking method.

The implementation uses principal-eigenvector power iteration, 1–10 criteria,
the documented RI table, explicit directions and default consistency gating.
See [AHP](ahp.md). Main integration, hosted publication and source release v0.2.0 are verified.

## 0.3.0-dev.1 — implemented on feat/sensitivity

- Complete relative-weight scenarios and sampled one-criterion sweeps.
- Full winner-set stability, competition-rank changes and transition brackets.
- Immutable reports retaining the complete calculation trace per scenario.
- Separate Flutter lab with AHP, method comparison, weights and sampled curves.
- English/Portuguese guides, CLI/JavaScript examples and independent tests.

No hosted 0.3 release is implied. Verify its new CI jobs before release preparation.

## Later proposals, not delivery commitments

- Weighted product with an explicit positive-domain policy and log-space math.
- VIKOR with documented compromise acceptance rules.
- Versioned JSON model/result persistence and cross-engine integration examples.

Before a hosted release: complete CI on the minimum and stable SDKs, inspect the
publication dry-run and package contents, and verify name availability on pub.dev.
GitHub repository creation does not publish or reserve a pub.dev package name.
