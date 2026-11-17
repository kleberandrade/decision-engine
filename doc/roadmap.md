# Roadmap

[Português](roadmap.pt-BR.md)

## 0.1.0 — initial baseline

- Pure Dart core, public interfaces and immutable models.
- Weighted sum with min-max normalization; TOPSIS with vector normalization.
- Inclusive eligibility constraints and complete rejection reasons.
- Deterministic ranking, exact ties, calculation traces and custom methods.
- English/Portuguese guides, executable examples, behavioral tests and CI.

## 0.2.0-dev.1 — implemented locally, not released

- AHP pairwise criterion weighting with reciprocal-matrix validation,
  consistency index and consistency ratio.
- Document the random-index table, supported matrix sizes and acceptance policy.
- Compose AHP-generated weights with either ranking method.

The implementation uses principal-eigenvector power iteration, 1–10 criteria,
the documented RI table, explicit directions and default consistency gating.
See [AHP](ahp.md). Source synchronization and release validation remain pending.

## Later proposals, not delivery commitments

- Weight sensitivity scenarios, winner stability and rank changes.
- Weighted product with an explicit positive-domain policy and log-space math.
- VIKOR with documented compromise acceptance rules.
- Flutter lab for interactive weights, rankings and method traces.
- Versioned JSON model/result persistence and cross-engine integration examples.

Before a hosted release: complete CI on the minimum and stable SDKs, inspect the
publication dry-run and package contents, and verify name availability on pub.dev.
GitHub repository creation does not publish or reserve a pub.dev package name.
