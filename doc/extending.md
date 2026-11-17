# Extension contracts

[Português](extending.pt-BR.md)

Implement `DecisionMethod` with a `name` and `evaluate(DecisionMatrix)` method.
The matrix is nonempty, immutable and validated; criteria are unique, observations
finite and normalized weights sum to one within floating-point precision.

Return `MethodEvaluation` with one finite descending-preference score per row,
normalized and weighted matrices of the original shape, and optional diagnostic
vectors with one finite value per row. Custom methods may use other score ranges;
the built-in score range is not imposed on extensions. Meaningful normalization
and weighting semantics are the custom author's responsibility.

See the runnable [custom method](../example/custom_method.dart). It deliberately
uses only the first criterion to demonstrate the contract, not a general decision
algorithm. Never import `lib/src/` or subclass the engine.

Implement `DecisionConstraint` with a known `criterionId` and
`rejectionReason(double)`: return null to accept, a reason to reject. All constraints
run for every well-formed alternative, and all failed reasons are retained.
Constraints must behave consistently between calls; the engine cannot clone
application-owned strategy state.
