import 'package:decision_engine/decision_engine.dart';

void main() {
  final engine = DecisionEngine(
    criteria: [
      Criterion.maximize('quality', weight: 3),
      Criterion.minimize('cost', weight: 1),
    ],
    method: const WeightedSum(),
  );
  final alternatives = [
    Alternative('Basic', values: {'quality': 10, 'cost': 100}),
    Alternative('Premium', values: {'quality': 20, 'cost': 200}),
  ];
  final analyzer = SensitivityAnalyzer(engine: engine);
  final report = analyzer.sweep(alternatives,
      criterionId: 'quality', weights: [0, 0.25, 0.5, 0.75, 1]);
  print('Baseline winners: ${report.baselineWinners}');
  for (final sample in report.scenarios) {
    print('${sample.scenario.name}: winners=${sample.winners}, '
        'rank changes=${sample.rankChanges}');
  }
  print('Sampled winner-set stability: ${report.winnerStability}');
  for (final transition in report.transitions) {
    print('Sampled change: ${transition.from.scenario.name} -> '
        '${transition.to.scenario.name}');
  }
  final explicit = analyzer.analyze(alternatives, scenarios: [
    WeightScenario('economy', weights: {'quality': 1, 'cost': 3}),
  ]);
  if (report.winnerStability != 0.4 ||
      report.transitions.length != 2 ||
      explicit.scenarios.single.winners.single != 'Basic') {
    throw StateError('Sensitivity reference calculation failed');
  }
}
