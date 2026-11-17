# Decision laboratory: scenarios and limits

[Português](SCENARIOS.pt-BR.md) · [Run the lab](README.md)

## Reproduce a decision

Open **Editor visual** for labeled fields. Add, rename or remove alternatives;
edit each observed value; add criteria, choose **Menor é melhor** (minimize) or
**Maior é melhor** (maximize), and enter relative weights. Under **Restrições
obrigatórias**, select a criterion and supply an inclusive minimum, maximum or
both. Blank means that bound is unused; remove the row for no restriction.
Removing a criterion also removes its values and constraints. At least one
criterion and one alternative remain. New criterion values start at zero for all
alternatives; replace those defaults before applying as needed. Names change
display labels while stable criterion IDs preserve scenario references.

Click **Aplicar cenário** to validate the complete draft and recalculate. Cancel
or Escape discards the draft. Both editors share the same validation boundary;
invalid drafts leave the current decision intact. Fields accept decimal points
or commas; JSON uses decimal points. The visual editor is scrollable on narrow
screens, with apply/cancel always available. Current slider weights, selected
method and sweep are retained, including editable all-zero weight drafts.

Open **Importar / exportar JSON** to paste or copy a scenario. The JSON contains the current relative weights,
criterion IDs, display labels, `minimize`/`maximize` directions, named alternatives,
inclusive minimum/maximum constraints, selected method and sweep criterion. Edit
or paste a saved scenario, then **Validar e aplicar**. **Copiar JSON** copies the
text; save it in a local file. There is no automatic persistence or server upload.
Cancel (or Escape) discards edits in either editor. Invalid input leaves the previous decision
intact. **Restaurar** restores the imported scenario's weights;
**Reiniciar laboratório** restores the complete original provider scenario.

Use decimal points. Each alternative must have exactly one finite value for each
criterion; IDs and alternative names must be unique. Weights must be nonnegative
with at least one positive value. Both editors accept 1–12 criteria, 1–30
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

### Edit AHP judgments

Open **Editor AHP** for the current ordered criteria (1–10). New comparisons
start equal, not inferred from existing weights. Edit cells above the diagonal
with a number or fraction between 1/9 and 9 (for example `3`, `0.5` or `1/3`).
The inverse below the diagonal updates automatically; diagonal values stay 1.
Ratios describe importance of the row relative to the column, independently of
whether observed values are minimized or maximized. Tables scroll horizontally
on narrow screens. The CR indicator and apply/cancel actions remain fixed.

The existing core computes the principal eigenvector and normalized weights.
The editor displays weights, lambda, CI and RI, with CI=(lambda−n)/(n−1) and
CR=CI/RI. For 1 or 2 criteria both CI/CR are zero by convention. Acceptance uses
**raw CR <=0.10**, not the four-decimal headline; the detailed value is shown.
Invalid, out-of-range or nonconvergent inputs clear calculated output and block
application. Inconsistent matrices remain inspectable but cannot be applied.
There is no consistency override in this lab. Consistency does not establish the
validity of preferences. This is criterion weighting, not a full AHP hierarchy.

**Aplicar pesos** replaces only criterion weights and recomputes the existing
ranking, preserving directions, alternatives, constraints, method and sweep.
Cancel discards the draft. With more than ten criteria AHP is disabled and manual
weights remain available. **Comparações iguais** resets the draft to ones. For
the original three IDs, **Carregar exemplo** seeds consistent ratios with
availability/cost/latency weights 0.6/0.3/0.1; the matrix follows current row order.
For the initial cost/latency/availability order its editable cells are 3, 1/2,
1/6. A cyclic 9, 1/9, 9 produces a large CR and blocks application.

The optional JSON `ahp` object stores `criterionIds` and `comparisons`. Import
recalculates and requires consistency and a match to normalized criterion weights
within 1e-8. Old scenarios without `ahp` still work. Reopening the editor restores
the applied matrix while its weights still match. Manual weight changes drop
stale evidence from export; visual edits retain evidence only if criterion IDs
and normalized weights are unchanged. **Restaurar** returns to the scenario's
pre-AHP reset weights; a complete restart restores the original providers.

## Review and preview AHP adjustments

Choose **Review inconsistencies**. The list shows the top five pairs by mean
absolute log deviation, the worst triad witness, and a suggestion when a tested
candidate reduces CR. Markers #1–#3 highlight matrix priorities; ties are possible.
Priority does not prove which preference is wrong. **Preview impact before adjusting**
shows the ratio, actual CR before/after, absolute reduction and candidate weights.
**Discard preview** preserves the matrix. **Stage adjustment** changes only
the pair and its inverse. The scenario changes only with **Apply weights**, which
requires raw CR <=0.10. Edits invalidate earlier diagnoses and previews.

For cyclic 9,1/9,9, the first preview lowers CR from 6.1302682 to 0.48347731,
still above the limit. Review again or cancel. Orders 1/2 have no triads.
Suggestions bounded to 1/9–9 are heuristics and may require further review;
there is no global-solution guarantee. See the AHP guide for the complete policy.

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
5. **Edit and verify AHP.** In the original criterion order enter 3, 1/2 and
   1/6, verify CR≈0 and apply 30/10/60 weights. Export/reimport the JSON, then
   try 9, 1/9 and 9. Complete when consistent evidence round-trips and the cyclic
   matrix blocks application without changing the scenario. Review the disagreements,
   inspect CR before/after and discard the preview. Also verify that the preview
   preserves the original values and CR≈0.483 still prevents application.
