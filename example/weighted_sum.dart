import 'package:decision_engine/decision_engine.dart';

void main() {
  final result = DecisionEngine(
    criteria: [
      Criterion.maximize('quality', weight: 3),
      Criterion.minimize('price', weight: 1),
    ],
    method: const WeightedSum(),
  ).evaluate([
    Alternative('Basic', values: {'quality': 10, 'price': 100}),
    Alternative('Premium', values: {'quality': 20, 'price': 200}),
    Alternative('Balanced', values: {'quality': 15, 'price': 125}),
  ]);
  for (final entry in result.ranking) {
    print('${entry.alternative.name}: ${entry.score} (rank ${entry.rank})');
  }
  if (result.best?.name != 'Premium' || result.ranking.first.score != 0.75) {
    throw StateError('Weighted sum reference calculation failed');
  }
}
