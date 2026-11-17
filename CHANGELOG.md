# Changelog

## Unreleased

- Add guarded first-source synchronization and initial-release validation scripts.

- Add AHP principal-eigenvector criterion weighting, reciprocal-matrix validation,
  consistency diagnostics and explicit conversion for both ranking methods.
- Start 0.2.0-dev.1 development on feat/ahp; retain the 0.1.0 baseline on local main.

- Update installation and release verification documentation for published 0.1.0.

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
