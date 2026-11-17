import 'package:decision_engine/decision_engine.dart';

void main() {
  final ahp = AhpWeighting().evaluate(
    criterionIds: ['quality', 'cost', 'latency'],
    comparisons: [
      [1, 2, 6],
      [1 / 2, 1, 3],
      [1 / 6, 1 / 3, 1],
    ],
  );
  print('Weights: ${ahp.weights}');
  print('Consistency ratio: ${ahp.consistencyRatio}');
  final criteria = ahp.toCriteria({
    'quality': CriterionDirection.maximize,
    'cost': CriterionDirection.minimize,
    'latency': CriterionDirection.minimize,
  });
  final alternatives = [
    Alternative('Economy', values: {'quality': 6, 'cost': 100, 'latency': 40}),
    Alternative('Performance',
        values: {'quality': 9, 'cost': 180, 'latency': 15}),
    Alternative('Balanced', values: {'quality': 8, 'cost': 130, 'latency': 25}),
  ];
  for (final method in <DecisionMethod>[const WeightedSum(), const Topsis()]) {
    final result = DecisionEngine(criteria: criteria, method: method)
        .evaluate(alternatives);
    print(
        '${method.name}: ${result.ranking.map((r) => '${r.alternative.name}=${r.score.toStringAsFixed(4)}').join(', ')}');
    final expected = method.name == 'weighted_sum' ? 'Performance' : 'Balanced';
    if (result.ranking.length != 3 ||
        !ahp.isConsistent ||
        result.best?.name != expected) {
      throw StateError('AHP composition contract failed');
    }
  }
}
