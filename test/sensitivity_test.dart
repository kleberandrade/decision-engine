import 'package:decision_engine/decision_engine.dart';
import 'package:test/test.dart';

DecisionEngine engine(
        {DecisionMethod method = const WeightedSum(),
        List<DecisionConstraint> constraints = const []}) =>
    DecisionEngine(
      criteria: [
        Criterion.maximize('quality', weight: 3),
        Criterion.minimize('cost', weight: 1)
      ],
      method: method,
      constraints: constraints,
    );
List<Alternative> options() => [
      Alternative('Basic', values: {'quality': 10, 'cost': 100}),
      Alternative('Premium', values: {'quality': 20, 'cost': 200}),
    ];

void main() {
  test(
      'explicit scenarios reproduce independent weighted-sum results and rank changes',
      () {
    final report =
        SensitivityAnalyzer(engine: engine()).analyze(options(), scenarios: [
      WeightScenario('economy', weights: {'quality': 1, 'cost': 3}),
      WeightScenario('same', weights: {'quality': 30, 'cost': 10}),
    ]);
    expect(report.baseline.best!.name, 'Premium');
    expect(report.baselineWinners, ['Premium']);
    expect(report.scenarios[0].result.best!.name, 'Basic');
    expect(report.scenarios[0].result.ranking.first.score, 0.75);
    expect(report.scenarios[0].rankChanges, {'Basic': 1, 'Premium': -1});
    expect(report.scenarios[0].maxWeightChange, 0.5);
    expect(report.scenarios[0].winnerSetChanged, isTrue);
    expect(report.scenarios[1].winnerSetChanged, isFalse);
    expect(report.winnerStability, 0.5);
  });

  test(
      'sweep preserves complementary proportions and detects sampled transitions',
      () {
    final report = SensitivityAnalyzer(engine: engine()).sweep(options(),
        criterionId: 'quality', weights: [0, 0.25, 0.5, 0.75, 1]);
    expect(report.scenarios.map((s) => s.result.weights.first),
        [0, 0.25, 0.5, 0.75, 1]);
    expect(report.scenarios[2].winners, ['Basic', 'Premium']);
    expect(report.scenarios[2].rankChanges, {'Basic': 1, 'Premium': 0});
    expect(report.transitions, hasLength(2));
    expect(report.transitions.first.from, same(report.scenarios[1]));
    expect(report.transitions.first.to, same(report.scenarios[2]));
    expect(report.winnerStability, 2 / 5);
    final three = DecisionEngine(criteria: [
      Criterion.maximize('a', weight: 2),
      Criterion.maximize('b', weight: 3),
      Criterion.maximize('c', weight: 5),
    ], method: const WeightedSum());
    final result = SensitivityAnalyzer(engine: three).sweep(
        [
          Alternative('A', values: {'a': 1, 'b': 2, 'c': 3}),
        ],
        criterionId: 'a',
        weights: [0.6]);
    expect(result.scenarios.single.result.weights[0], closeTo(0.6, 1e-12));
    expect(result.scenarios.single.result.weights[1], closeTo(0.15, 1e-12));
    expect(result.scenarios.single.result.weights[2], closeTo(0.25, 1e-12));
  });

  test('winner comparison uses the whole tie set, not the representative best',
      () {
    final tiedEngine = DecisionEngine(criteria: [
      Criterion.maximize('quality', weight: 1),
      Criterion.minimize('cost', weight: 1)
    ], method: const WeightedSum());
    final report =
        SensitivityAnalyzer(engine: tiedEngine).analyze(options(), scenarios: [
      WeightScenario('break tie', weights: {'quality': 0, 'cost': 1}),
    ]);
    expect(report.baseline.best!.name, 'Basic');
    expect(report.scenarios.single.result.best!.name, 'Basic');
    expect(report.scenarios.single.winnerSetChanged, isTrue);
    expect(report.winnerStability, 0);
  });

  test('TOPSIS scenarios agree with direct method evaluation', () {
    final report = SensitivityAnalyzer(engine: engine(method: const Topsis()))
        .sweep(options(), criterionId: 'quality', weights: [0.2, 0.8]);
    for (var i = 0; i < 2; i++) {
      final w = [0.2, 0.8][i];
      final direct = DecisionEngine(criteria: [
        Criterion.maximize('quality', weight: w),
        Criterion.minimize('cost', weight: 1 - w)
      ], method: const Topsis())
          .evaluate(options());
      expect(report.scenarios[i].result.trace!.scores, direct.trace!.scores);
    }
  });

  test('constraints remain in force and cannot be bypassed by zero weight', () {
    final report = SensitivityAnalyzer(
            engine: engine(constraints: [MaximumValue('cost', 150)]))
        .sweep(options(), criterionId: 'cost', weights: [0, 1]);
    for (final scenario in report.scenarios) {
      expect(scenario.result.excluded.single.alternative.name, 'Premium');
      expect(scenario.winners, ['Basic']);
    }
    expect(report.winnerStability, 1);
  });

  test(
      'empty comparisons and no eligible alternatives have no stability estimate',
      () {
    final report = SensitivityAnalyzer(engine: engine()).analyze(options());
    expect(report.scenarios, isEmpty);
    expect(report.winnerStability, isNull);
    final empty = SensitivityAnalyzer(engine: engine())
        .sweep([], criterionId: 'quality', weights: [0, 1]);
    expect(empty.baselineWinners, isEmpty);
    expect(empty.winnerStability, isNull);
    expect(empty.transitions, isEmpty);
    final excluded = SensitivityAnalyzer(
            engine: engine(constraints: [MaximumValue('cost', 0)]))
        .sweep(options(), criterionId: 'quality', weights: [0, 1]);
    expect(excluded.winnerStability, isNull);
  });

  test('rejects malformed scenarios before evaluating custom methods', () {
    final analyzer = SensitivityAnalyzer(engine: engine());
    for (final weights in <Map<String, num>>[
      {'quality': 1},
      {'quality': 1, 'cost': 1, 'extra': 1},
      {'quality': 0, 'cost': 0},
    ]) {
      expect(
          () => analyzer.analyze(options(),
              scenarios: [WeightScenario('bad', weights: weights)]),
          throwsArgumentError);
    }
    expect(
        () => analyzer.analyze(options(), scenarios: [
              WeightScenario('same', weights: {'quality': 1, 'cost': 0}),
              WeightScenario('same', weights: {'quality': 0, 'cost': 1})
            ]),
        throwsArgumentError);
    for (final value in [-1.0, double.nan, double.infinity]) {
      expect(() => WeightScenario('bad', weights: {'quality': value}),
          throwsArgumentError);
    }
    expect(() => WeightScenario(' ', weights: {'quality': 1}),
        throwsArgumentError);
  });

  test('sweep validates bounds, order and unsupported redistribution', () {
    final analyzer = SensitivityAnalyzer(engine: engine());
    expect(
        () => analyzer.sweep(options(), criterionId: 'missing', weights: [0.5]),
        throwsArgumentError);
    for (final grid in <List<double>>[
      [],
      [-0.1],
      [1.1],
      [double.nan],
      [double.infinity],
      [0.8, 0.2]
    ]) {
      expect(
          () =>
              analyzer.sweep(options(), criterionId: 'quality', weights: grid),
          throwsArgumentError);
    }
    final single = SensitivityAnalyzer(
        engine: DecisionEngine(
            criteria: [Criterion.maximize('x', weight: 1)],
            method: const WeightedSum()));
    expect(
        () => single.sweep(
            [
              Alternative('A', values: {'x': 1})
            ],
            criterionId: 'x',
            weights: [0.5]),
        throwsArgumentError);
    expect(
        single
            .sweep(
                [
                  Alternative('A', values: {'x': 1})
                ],
                criterionId: 'x',
                weights: [1])
            .scenarios,
        hasLength(1));
    final noOthers = SensitivityAnalyzer(
        engine: DecisionEngine(criteria: [
      Criterion.maximize('quality', weight: 1),
      Criterion.minimize('cost', weight: 0)
    ], method: const WeightedSum()));
    expect(
        () => noOthers.sweep(options(), criterionId: 'quality', weights: [0.5]),
        throwsArgumentError);
    expect(
        noOthers
            .sweep(options(), criterionId: 'cost', weights: [0.5]).scenarios,
        hasLength(1));
  });

  test('snapshots, scenarios, ranks and winner lists are immutable', () {
    final values = <String, num>{'quality': 1, 'cost': 3};
    final scenario = WeightScenario('economy', weights: values);
    values['cost'] = 0;
    final report = SensitivityAnalyzer(engine: engine())
        .analyze(options(), scenarios: [scenario]);
    expect(report.scenarios.single.result.best!.name, 'Basic');
    expect(() => scenario.weights['cost'] = 0, throwsUnsupportedError);
    expect(() => report.scenarios.clear(), throwsUnsupportedError);
    expect(() => report.baselineWinners.clear(), throwsUnsupportedError);
    expect(() => report.scenarios.single.rankChanges.clear(),
        throwsUnsupportedError);
    expect(
        () => report.scenarios.single.winners.clear(), throwsUnsupportedError);
    expect(() => report.transitions.clear(), throwsUnsupportedError);
  });

  test('sweep handles extreme relative weights without summing raw weights',
      () {
    final analyzer = SensitivityAnalyzer(
        engine: DecisionEngine(criteria: [
      Criterion.maximize('quality', weight: 1e308),
      Criterion.minimize('cost', weight: 1e308)
    ], method: const WeightedSum()));
    final result = analyzer
        .sweep(options(), criterionId: 'quality', weights: [0.25, 0.75]);
    expect(result.scenarios.first.result.weights, [0.25, 0.75]);
    expect(result.scenarios.last.winners, ['Premium']);
  });

  test('AHP-generated criteria participate without changing inference code',
      () {
    final ahp = AhpWeighting().evaluate(criterionIds: [
      'quality',
      'cost'
    ], comparisons: [
      [1, 3],
      [1 / 3, 1]
    ]);
    final e = DecisionEngine(
        criteria: ahp.toCriteria({
          'quality': CriterionDirection.maximize,
          'cost': CriterionDirection.minimize
        }),
        method: const WeightedSum());
    final report = SensitivityAnalyzer(engine: e)
        .sweep(options(), criterionId: 'quality', weights: [0.25, 0.75]);
    expect(report.baseline.best!.name, 'Premium');
    expect(report.scenarios.first.winners, ['Basic']);
  });

  test('changing constraint eligibility across evaluations is rejected', () {
    final constraint = ChangingConstraint();
    final e = engine(constraints: [constraint]);
    expect(
        () => SensitivityAnalyzer(engine: e).analyze(options(), scenarios: [
              WeightScenario('change', weights: {'quality': 1, 'cost': 1})
            ]),
        throwsStateError);
  });
}

class ChangingConstraint implements DecisionConstraint {
  var calls = 0;
  @override
  String get criterionId => 'cost';
  @override
  String? rejectionReason(double value) => ++calls > 2 ? 'changed' : null;
}
