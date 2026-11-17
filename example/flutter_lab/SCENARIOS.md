# Decision laboratory: scenarios and limits

[Português](SCENARIOS.pt-BR.md) · [Run the lab](README.md)

## Reproduce a decision

Open **Editar / copiar cenário**. The JSON contains the current relative weights,
criterion IDs, display labels, `minimize`/`maximize` directions, named alternatives,
inclusive minimum/maximum constraints, selected method and sweep criterion. Edit
or paste a saved scenario, then **Validar e aplicar**. **Copiar JSON** copies the
text; save it in a local file. There is no automatic persistence or server upload.
Cancel (or Escape) discards edits. Invalid input leaves the previous decision
intact. **Restaurar** restores the imported scenario's weights;
**Reiniciar laboratório** restores the complete original provider scenario.

Use decimal points. Each alternative must have exactly one finite value for each
criterion; IDs and alternative names must be unique. Weights must be nonnegative
with at least one positive value. The editor accepts 1–12 criteria, 1–30
alternatives, at most 100,000 JSON characters and numbers of magnitude <=1e12.
These UI limits keep synchronous browser calculations bounded; the core has its
own independent validation. Unknown method/direction/criterion references fail.
Weights above one are proportionally rescaled for sliders without changing their
relative importance. Sliders have 0.01 relative steps; importing JSON supports
finer values. All-zero sliders show recovery guidance instead of a ranking.

## Provider selection

The initial synthetic data uses cost in R$, latency in ms and availability in %.
Nova fails availability >=99.9 and is excluded **before** either method normalizes
columns. The raw table includes rejected alternatives; calculation traces do not.

Weighted sum gives Vega 0.6500, Atlas 0.6056 and Orion 0.3500. For Atlas the
normalized utilities are 2/3, 0.6 and 5/9; multiplying by 0.35, 0.25 and 0.4 yields
0.2333 + 0.1500 + 0.2222 = 0.6056. TOPSIS instead ranks Atlas first (0.6232),
then Vega (0.5735), then Orion (0.4265). Its vector normalization retains the
small relative availability differences. Compare ordering, not scores across
methods. Weighted TOPSIS coordinates are not additive contributions: inspect
`distanceToIdeal` and `distanceToAntiIdeal`; closeness is d−/(d+ + d−).

## Change eligibility

In `constraints`, raise availability's minimum to 100. All four alternatives
are rejected, with reasons and no winner. Remove that constraint to rank all
four. Add `maximum` on cost to represent a hard budget; a weight represents a
trade-off and cannot substitute for an eligibility rule. Bounds are inclusive.

## Add your own criteria and alternatives

Add a criterion with a unique ID, label, direction and weight; add its value to
**every** alternative. Remove matching values/constraints when removing a
criterion. Directions are preferences, not units. Signed and zero values are
supported. Alternatives with equal scores share rank; display order is a
stable representative, not proof of a unique winner.

## Sensitivity and AHP

Sweep one normalized weight over 21 points from 0 to 1. Remaining weights retain
their proportions. The original cost sweep changes winners in the sampled
35–40% and 60–65% brackets. These are not exact mathematical boundaries and the
stability fraction is not a probability. Expand **Amostras em texto** for a
screen-reader-friendly alternative to the chart. Another criterion needs positive
weight for a sweep. The matrix shows normalized and weighted values in eligible
input order, separate from ranking order.

The AHP button demonstrates the existing core's principal-eigenvector weighting
for `availability`, `cost`, `latency` only, using [1,2,6; 1/2,1,3; 1/6,1/3,1].
It yields 0.6, 0.3, 0.1 and CR=0. It is disabled for other criterion sets. This
lab does not offer an arbitrary pairwise-matrix editor; see the core AHP API for
that capability. Consistency does not establish the validity of preferences.

## Execution and accessibility

Calculations finish immediately on change; there is no long-running task or
animation requiring pause. Cancel applies to the scenario editor. Use Tab,
Shift+Tab and arrow keys to navigate controls. Labels, textual samples and
rejection reasons complement color and plots. Narrow layouts stack panels;
wide numeric tables scroll horizontally. Automated checks cover text at 1.6×,
labeled controls, tap targets and contrast; manual checks are recorded in
[validation](../../doc/lab_validation.md). Browser/assistive-technology coverage
is limited to those recorded checks.

MIT applies to project code and synthetic examples. Flutter and bundled fonts
retain their respective licenses in the generated license notices.

## References

[Method equations](../../doc/methods.md) · [AHP](../../doc/ahp.md) ·
[Sensitivity semantics](../../doc/sensitivity.md)

## Five practical exercises

1. **Reproduce the baseline.** Export and reimport JSON. Complete when both method
   rankings and all displayed scores match before and after the round trip.
2. **Model a hard budget.** Add a cost maximum of 1200. Complete when Vega and Nova
   are excluded for their respective failed requirements and reasons are visible.
3. **Add a criterion.** Add maximizing `support` with a positive weight and values
   for every provider. Complete when both rankings and its trace column render.
4. **Inspect a sampled transition.** Sweep cost with the original weights. Complete
   when you identify the 35–40% bracket and verify both adjacent textual samples,
   explicitly distinguishing the bracket from an exact crossing.
5. **Explain AHP and recover state.** Apply the demonstration, inspect CR=0 and
   60/30/10 percentages, then restart. Complete when weights return to 40/35/25
   (availability/cost/latency) and Vega wins the weighted sum again.
