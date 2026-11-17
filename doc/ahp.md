# AHP criterion weighting

[Português](ahp.pt-BR.md)

`AhpWeighting` derives relative criterion weights before a ranking method runs.
It does not implement a full hierarchy or pairwise alternative synthesis.
Use the resulting criteria with `WeightedSum` or `Topsis`.

## Input convention

Provide ordered unique `criterionIds` and a square judgment matrix `comparisons`.
A[i][j] expresses the importance of criterion i relative to criterion j: 1 means
equal, 3 means i is three times as important, and 1/3 means the inverse.
Judgments measure importance, not whether the observed criterion is minimized.
For example, cost may be important yet still use `CriterionDirection.minimize`.

Supported orders are 1 through 10. Values must be finite and in [1/9, 9];
continuous ratios inside this range are allowed. Diagonal values must be one and
A[i][j] * A[j][i] must equal one within absolute `reciprocityTolerance` (default
1e-8). Accepted floating-point noise is retained; the matrix is not repaired.
Incomplete comparisons and out-of-scale judgments are rejected.

## Computation and evidence

Power iteration starts from uniform weights. Each step multiplies A*w and
normalizes the result to sum to one. It stops only when maximum absolute weight
change and max(abs(A*w - lambda*w))/lambda are both <= `tolerance` (default 1e-10).
The eigenvalue estimate is the mean of (A*w)[i]/w[i]. A failure to converge within
`maxIterations` (default 10000) throws `StateError`, without provisional weights.

CI = max(0, (lambdaMax - n)/(n - 1)); CR = CI / RI.
For orders 1 and 2, CI and CR are zero by convention. Small negative CI caused by
floating-point noise is clamped to zero. The result retains weights, comparisons,
lambdaMax, CI, RI, CR, iteration count and residual as immutable evidence.

| Matrix order | RI |
| --- | --- |
| 1 | 0 |
| 2 | 0 |
| 3 | 0.58 |
| 4 | 0.90 |
| 5 | 1.12 |
| 6 | 1.24 |
| 7 | 1.32 |
| 8 | 1.41 |
| 9 | 1.45 |
| 10 | 1.49 |

The implementation fixes the Saaty RI convention reproduced in Table 1 of
[Ishizaka & Labib (2009), *Analytic Hierarchy Process and Expert Choice:
Benefits and Limitations*](https://pure.port.ac.uk/ws/files/42847/ORI-preprint-AIshizaka.pdf).
Other published tables differ; the table is part of this API's numerical policy.

## Consistency policy

Numerical convergence and consistency acceptance are separate. A converged
inconsistent matrix returns `isConsistent == false` for inspection. The package
uses an inclusive CR <= `consistencyThreshold` rule, default 0.10. This is an
explicit library policy; the cited paper describes a less-than-10% convention.
Thresholds must be finite in [0,1). A small CR does not prove the judgments are
correct, fair, or useful for the application.

`result.toCriteria(directions)` requires exactly one explicit direction per ID,
keeps matrix order, and rejects inconsistent results by default. Applications may
inspect the evidence and pass `requireConsistency: false` to explicitly adopt
such weights. Reading `result.weights` itself never suppresses inconsistent data.

## Runnable example

```dart
final ahp = AhpWeighting().evaluate(
  criterionIds: ['quality', 'cost', 'latency'],
  comparisons: [
    [1, 2, 6],
    [1 / 2, 1, 3],
    [1 / 6, 1 / 3, 1],
  ],
);
final criteria = ahp.toCriteria({
  'quality': CriterionDirection.maximize,
  'cost': CriterionDirection.minimize,
  'latency': CriterionDirection.minimize,
});
final engine = DecisionEngine(criteria: criteria, method: const Topsis());
```

The known consistent weights are 0.6, 0.3 and 0.1. Run `dart run example/ahp.dart`
for composition with both ranking methods. Tests independently pin this ratio
matrix and an inconsistent cyclic matrix with equal row sums and known eigenvalue.
Power iteration costs O(iterations * n²) time and O(n²) matrix memory. Execution
policy and consistency review remain application responsibilities.


## Inconsistency review (Unreleased source API)

`AhpConsistencyAdvisor` is available in this checkout, not in hosted 0.3.0.
Run `dart run example/ahp_review.dart` for a complete reproducible preview:

```dart
final review = const AhpConsistencyAdvisor().review(ahp);
for (final pair in review.comparisons) {
  final candidate = pair.adjustment;
  if (candidate == null) continue;
  print('${pair.row}/${pair.column}: ${review.baseline.consistencyRatio}'
      ' -> ${candidate.evaluation.consistencyRatio}');
}
```

For each pair i<j, priority is the mean absolute log deviation
`mean_k |ln(Aij) - ln(Aik) - ln(Akj)|`, over k distinct from i,j.
The report supplies the worst triad witness, triad count, and deterministic
row/column tie order. It prioritizes disagreements; it cannot establish which
judgment is wrong. Orders 1/2 have no triads. Deviations <=1e-10 are ignored.

The target is the geometric mean of indirect ratios Aik×Akj, clamped to [1/9,9].
Four log-space steps (100%, 75%, 50%, 25%) toward that target are tested.
Each changes only Aij and its reciprocal, and the full eigenvector/CR is
recomputed. The best converged candidate is offered only if CR decreases by
more than 1e-12. A pair may have no improving tested candidate. This is a bounded
heuristic, not a global optimizer or guaranteed complete repair.

The advisor reevaluates the baseline with default convergence and reciprocity
settings while preserving its consistency threshold. A matrix accepted only
with looser custom reciprocity tolerance is rejected here. Reports and candidate
matrices are immutable and do not adopt weights. The lab separately previews,
stages one adjustment, and applies weights only when raw CR <=0.10.

For cyclic editable ratios 9,1/9,9, CR drops from 6.1302682 to 0.48347731 after
one bounded adjustment; it still fails acceptance. A four-criterion all-ones
matrix with only A01=9 (and reciprocal A10) identifies that pair uniquely;
suggesting 1 restores CR≈0 and equal weights. Neither example proves the
suggested preference is appropriate for a real decision.
