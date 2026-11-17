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
