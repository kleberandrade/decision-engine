import 'package:decision_engine/decision_engine.dart';

void main() {
  final engine = DecisionEngine(
    criteria: [
      Criterion.minimize('cost', weight: 0.35),
      Criterion.minimize('latency', weight: 0.25),
      Criterion.maximize('availability', weight: 0.40),
    ],
    constraints: [MinimumValue('availability', 99.9)],
    method: const Topsis(),
  );
  final result = engine.evaluate([
    Alternative(
      'Provider A',
      values: {'cost': 1200, 'latency': 25, 'availability': 99.95},
    ),
    Alternative(
      'Provider B',
      values: {'cost': 1600, 'latency': 15, 'availability': 99.99},
    ),
    Alternative(
      'Provider C',
      values: {'cost': 900, 'latency': 40, 'availability': 99.5},
    ),
  ]);
  for (final entry in result.ranking) {
    print(
      '${entry.rank}. ${entry.alternative.name}: ${entry.score.toStringAsFixed(4)}',
    );
  }
  for (final entry in result.excluded) {
    print('Excluded ${entry.alternative.name}: ${entry.reasons.join('; ')}');
  }
  print('Trace row order: ${result.eligible.map((a) => a.name).join(', ')}');
  print('Ideal distances: ${result.trace?.diagnostics['distanceToIdeal']}');
  if (result.ranking.length != 2 || result.excluded.length != 1) {
    throw StateError('Provider selection contract failed');
  }
}
