# Weight sensitivity

[Português](sensitivity.pt-BR.md) · [CLI example](../example/sensitivity.dart) ·
[Flutter lab](../example/flutter_lab/README.md)

`SensitivityAnalyzer` composes an existing `DecisionEngine`. It evaluates the
baseline and reuses the same method, observations, criterion directions and hard
constraints under alternative weights. It neither changes the original engine
nor introduces Flutter, IO, networking or runtime dependencies into the core.

## Complete scenarios

```dart
final report = SensitivityAnalyzer(engine: engine).analyze(alternatives,
  scenarios: [
    WeightScenario('economy', weights: {'quality': 1, 'cost': 3}),
    WeightScenario('quality', weights: {'quality': 3, 'cost': 1}),
  ],
);
```

Each scenario has a unique nonblank name and exactly one finite, nonnegative
relative weight for each criterion ID. At least one weight must be positive.
Unknown/missing keys, duplicate names and all-zero weights are rejected before
scoring starts. Weights are normalized by the existing engine. All constraints
remain active, including constraints on zero-weight criteria.

## One-criterion sweep

```dart
final report = SensitivityAnalyzer(engine: engine).sweep(alternatives,
  criterionId: 'quality', weights: [0, 0.25, 0.5, 0.75, 1],
);
```

The grid is nonempty, finite, ascending and within [0,1]. Repeated weights are
allowed and receive distinct index-based scenario names. The selected weight is
normalized directly; the others share the remaining mass in their baseline
proportions: newOther = oldOther / sum(otherWeights) * (1 - target).

If complementary criteria all have zero weight (including a one-criterion
engine), target=1 is the only supported sample. No uniform fallback is invented.
A zero-weight target with positive complementary criteria can be swept normally.
Normalization uses the engine's overflow-safe weights, not their raw sum.

## Interpret the result

| Member | Meaning |
| --- | --- |
| `baseline` | Original evaluation with complete immutable trace |
| `baselineWinners` | All names at rank 1, including ties |
| `scenarios` | Samples in the requested order, each retaining its full result |
| `scenario.winners` | Complete rank-1 set for that sample |
| `scenario.winnerSetChanged` | Full winner-set difference from baseline |
| `scenario.rankChanges` | Baseline competition rank minus sample rank; positive improves |
| `scenario.maxWeightChange` | Largest absolute normalized-weight change from baseline |
| `winnerStability` | Fraction of requested samples retaining the entire baseline winner set |
| `transitions` | Adjacent requested samples whose full winner sets differ |

For quality [10,20], cost [100,200], baseline weights [3,1] and weighted sum,
Premium wins at baseline. At quality weights [0,0.25,0.5,0.75,1], Basic wins the
first two, both tie at 0.5 and Premium wins the last two. Stability is 2/5, because
the tie does not retain the original singleton winner set. The transitions bracket
0.25–0.5 and 0.5–0.75. This known calculation is pinned in tests.

## Limits and ownership

A transition is **not an exact crossing point**. A grid can miss changes between
samples. Stability is a descriptive sample fraction, not a probability, confidence
level, sensitivity derivative or continuous robustness guarantee. In explicit
scenarios, adjacency is input order and does not imply numerical proximity.
Finer grids or application-specific optimization may be needed for tighter bounds.

With no scenarios, or no eligible alternatives, stability is null. Empty rankings
have no winners or transitions. Exact score ties retain the existing engine
semantics. Scores must not be compared across different ranking methods.

AHP-generated criteria work directly; a sweep deliberately changes their weights
and does not represent a new consistent AHP judgment matrix. To change judgments,
rerun `AhpWeighting` and submit the resulting complete weights as a scenario.

Methods and constraints must behave consistently between calls. A change of
eligible set during analysis throws `StateError`, because eligibility changes
cannot be attributed to weights alone. Scenario maps, winner lists, ranks, report
collections and nested traces are copied and immutable. Retaining every trace
costs O(samples * alternatives * criteria) memory. Work is the cost of repeated
engine evaluations; this API does not schedule isolates or background execution.
