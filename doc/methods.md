# Methods and conventions

[Português](methods.pt-BR.md)

## Common input

Rows are alternatives, columns are criteria. Observations are finite doubles;
signed and zero values are allowed. Weights must be finite and nonnegative, with
at least one positive. The engine computes w[j] = weight[j] / sum(weights), using
maximum-weight scaling to avoid overflow. IDs and alternative names are unique.
Missing or extra criterion keys are errors, including on rejected alternatives.

Hard constraints run first, and all failures are collected. Normalization and
ideal points use only eligible alternatives. No method runs on an empty set.

## Weighted sum

For a benefit criterion, u[i,j] = (x[i,j] - min[j]) / (max[j] - min[j]).
For a cost criterion, u[i,j] = (max[j] - x[i,j]) / (max[j] - min[j]).
A constant column receives u = 1 for every row. The score is sum(w[j] * u[i,j]).

Example: benefits [10,20,15], costs [100,200,125], weights [3,1]. Normalized
weights are [0.75,0.25]. Utilities are [[0,1],[1,0],[0.5,0.75]] and scores are
[0.25,0.75,0.5625]. The second alternative ranks first.

This is an additive preference model. Weights are trade-offs on the normalized
ranges, not the original measurement units. The min-max variant is not invariant
to adding or removing options. Constant columns add the same offset to all scores.

## TOPSIS

Compute r[i,j] = x[i,j] / sqrt(sum_i(x[i,j]^2)) and v[i,j] = w[j] * r[i,j].
An all-zero column has r = 0. For benefit criteria, the positive ideal is max(v)
and the anti-ideal is min(v); cost criteria reverse these choices. Compute
Euclidean distances dPositive and dNegative from each weighted row to those ideals.
The closeness score is dNegative / (dPositive + dNegative).

If both distances are zero, return 0.5. This covers a singleton eligible set,
identical options or differences confined to zero-weight columns. This score
expresses indistinguishability, not a confidence or success probability.

For benefit [1,2], cost [1,3] and equal weights, the first row is separated from
the positive ideal by 0.5/sqrt(5) and from the anti-ideal by 1/sqrt(10). Its score
is approximately 0.585786, and the second row scores approximately 0.414214.
These independent calculations are pinned in public-API tests.

Column scaling before normalization avoids overflow for large finite values;
a scaled distance norm reduces underflow for tiny differences. Floating-point
rounding and underflow can still collapse distinctions below representable
precision. No arbitrary-precision or fuzzy tie tolerance is promised.

## Ranking and interpretation

Higher scores rank first. Exact score ties share a competition rank (1,1,3),
with original input order as the deterministic display order. There is no
near-equality tolerance; consumers can group approximate ties for presentation.

Both methods can compensate a weak criterion with strength elsewhere. Mandatory
requirements belong in constraints. Scores depend on the method, chosen weights
and eligible set; they are not comparable across these contexts. Rankings are
preference-model outputs, not proof of an objectively best option. TOPSIS can
exhibit rank reversal when the candidate set changes. Sensitivity analysis is
planned and currently must be performed by explicit reevaluation.
