# Getting started

[Português](getting_started.pt-BR.md)

1. Install from Git as shown in the [README](../README.md).
2. Define unique criterion IDs, relative weights and maximize/minimize directions.
3. Create uniquely named alternatives with exactly those keys and finite values.
4. Compose a `DecisionEngine` with `WeightedSum` or `Topsis`.
5. Add `MinimumValue` and/or `MaximumValue` for mandatory inclusive bounds.
6. Evaluate and inspect `ranking`, `excluded`, `weights`, `eligible` and `trace`.

Run `dart run example/weighted_sum.dart` for a fully worked additive comparison,
`dart run example/decision_engine_example.dart` for provider selection, or
`dart run example/custom_method.dart` for strategy composition.

In Flutter, import the same Dart library and call `evaluate` from your application
logic. There is no widget dependency or automatic background execution. Handle
`best == null` explicitly. Never index a trace by ranking position: use the
matching alternative in `eligible`. See [methods](methods.md) before interpreting
scores or comparing results with different candidate sets.
