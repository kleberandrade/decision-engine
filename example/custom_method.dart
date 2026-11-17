import 'package:decision_engine/decision_engine.dart';

/// Example strategy: score only the first criterion, preferring larger values.
/// This deliberately ignores weights and is not a multicriteria algorithm.
class FirstCriterion implements DecisionMethod {
  @override
  String get name => 'first_criterion';

  @override
  MethodEvaluation evaluate(DecisionMatrix matrix) => MethodEvaluation(
        scores: matrix.values.map((row) => row.first).toList(),
        normalized: matrix.values,
        weighted: matrix.values,
      );
}

void main() {
  final result = DecisionEngine(
    criteria: [Criterion.maximize('quality', weight: 1)],
    method: FirstCriterion(),
  ).evaluate([
    Alternative('A', values: {'quality': 5}),
    Alternative('B', values: {'quality': 8}),
  ]);
  print('Custom strategy winner: ${result.best?.name}');
  if (result.best?.name != 'B') {
    throw StateError('Custom method contract failed');
  }
}
