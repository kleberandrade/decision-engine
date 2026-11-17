import 'dart:math' as math;

import '../domain/alternative.dart';
import '../domain/criterion.dart';
import '../domain/decision_matrix.dart';
import '../domain/decision_result.dart';
import '../engine/decision_engine.dart';

/// An immutable, named, complete set of relative criterion weights.
final class WeightScenario {
  /// Copies finite, nonnegative weights. Schema and positive-total validation
  /// occur when an analyzer matches these weights to its configured criteria.
  WeightScenario(this.name, {required Map<String, num> weights})
      : weights = Map.unmodifiable(weights.map(
          (id, value) => MapEntry(id, value.toDouble()),
        )) {
    if (name.trim().isEmpty ||
        this.weights.values.any((v) => !v.isFinite || v < 0)) {
      throw ArgumentError(
          'Require a nonblank name and finite, nonnegative weights');
    }
  }

  /// Unique scenario identifier within a report.
  final String name;

  /// Complete criterion-ID-to-relative-weight mapping.
  final Map<String, double> weights;
}

/// Re-evaluates a decision under explicit weights or a sampled one-weight sweep.
///
/// Methods and constraints are reused and must behave consistently between calls.
/// Scores are never compared across methods or treated as probabilities.
final class SensitivityAnalyzer {
  /// Composes the original decision configuration without changing it.
  const SensitivityAnalyzer({required this.engine});

  /// Baseline method, criteria and mandatory constraints.
  final DecisionEngine engine;

  /// Evaluates the baseline and each complete scenario in input order.
  ///
  /// All scenarios are validated before scoring starts. Unknown/missing IDs,
  /// duplicate names and all-zero weights throw [ArgumentError]. A change in
  /// eligibility across evaluations throws [StateError], because this analysis
  /// varies weights only. Results retain each scenario's complete numeric trace.
  SensitivityReport analyze(List<Alternative> alternatives,
      {List<WeightScenario> scenarios = const []}) {
    final options = List<Alternative>.unmodifiable(alternatives);
    final requested = List<WeightScenario>.of(scenarios);
    if (requested.map((s) => s.name).toSet().length != requested.length) {
      throw ArgumentError('Scenario names must be unique');
    }
    final configured = requested
        .map((scenario) => DecisionEngine(
              criteria: _criteriaFor(scenario.weights),
              method: engine.method,
              constraints: engine.constraints,
            ))
        .toList();
    final baseline = engine.evaluate(options);
    final baselineWinners = _winners(baseline);
    final baselineRanks = {
      for (final entry in baseline.ranking) entry.alternative.name: entry.rank,
    };
    final eligibleNames = baseline.eligible.map((a) => a.name).toSet();
    final evaluated = <SensitivityScenario>[];
    for (var i = 0; i < requested.length; i++) {
      final result = configured[i].evaluate(options);
      final names = result.eligible.map((a) => a.name).toSet();
      if (names.length != eligibleNames.length ||
          !names.containsAll(eligibleNames)) {
        throw StateError('Eligibility changed during weight-only analysis');
      }
      final winners = _winners(result);
      evaluated.add(SensitivityScenario._(
        scenario: requested[i],
        result: result,
        winners: winners,
        winnerSetChanged: !_sameSet(baselineWinners, winners),
        rankChanges: {
          for (final entry in result.ranking)
            entry.alternative.name:
                baselineRanks[entry.alternative.name]! - entry.rank,
        },
        maxWeightChange: List.generate(engine.criteria.length,
                (j) => (baseline.weights[j] - result.weights[j]).abs())
            .fold(0.0, math.max),
      ));
    }
    return SensitivityReport._(baseline, baselineWinners, evaluated);
  }

  /// Samples one normalized criterion weight using a nonempty ascending grid.
  ///
  /// Grid values must be finite in [0,1]; duplicates are allowed. Other criteria
  /// share the remaining weight in their baseline proportions. If they all have
  /// zero weight, only a target weight of 1 is possible. This includes a single-
  /// criterion engine. No uniform fallback or unrequested weight is invented.
  ///
  /// Adjacent changes in the report bracket sampled winner-set changes; they do
  /// not locate exact crossing points or prove stability between samples.
  SensitivityReport sweep(List<Alternative> alternatives,
      {required String criterionId, required List<double> weights}) {
    final index = engine.criteria.indexWhere((c) => c.id == criterionId);
    if (index < 0) {
      throw ArgumentError.value(
          criterionId, 'criterionId', 'Unknown criterion');
    }
    final grid = List<double>.of(weights);
    if (grid.isEmpty || grid.any((w) => !w.isFinite || w < 0 || w > 1)) {
      throw ArgumentError('Sweep requires finite weights in [0,1]');
    }
    for (var i = 1; i < grid.length; i++) {
      if (grid[i] < grid[i - 1]) {
        throw ArgumentError('Sweep grid must be ascending');
      }
    }
    final baseline =
        DecisionMatrix(criteria: engine.criteria, alternatives: const []);
    var otherTotal = 0.0;
    for (var j = 0; j < baseline.weights.length; j++) {
      if (j != index) otherTotal += baseline.weights[j];
    }
    if (otherTotal == 0 && grid.any((w) => w != 1)) {
      throw ArgumentError(
          'Cannot redistribute weight to zero-weight complementary criteria');
    }
    final scenarios = <WeightScenario>[];
    for (var i = 0; i < grid.length; i++) {
      final value = grid[i];
      scenarios.add(WeightScenario('$criterionId[$i]=$value', weights: {
        for (var j = 0; j < engine.criteria.length; j++)
          engine.criteria[j].id: j == index
              ? value
              : otherTotal == 0
                  ? 0
                  : (baseline.weights[j] / otherTotal) * (1 - value),
      }));
    }
    return analyze(alternatives, scenarios: scenarios);
  }

  List<Criterion> _criteriaFor(Map<String, double> weights) {
    if (weights.length != engine.criteria.length ||
        engine.criteria.any((c) => !weights.containsKey(c.id))) {
      throw ArgumentError('Scenario weights must match criterion IDs exactly');
    }
    return engine.criteria
        .map((c) => c.direction == CriterionDirection.maximize
            ? Criterion.maximize(c.id, weight: weights[c.id]!)
            : Criterion.minimize(c.id, weight: weights[c.id]!))
        .toList();
  }
}

/// One sampled scenario and its differences from the baseline ranking.
final class SensitivityScenario {
  SensitivityScenario._(
      {required this.scenario,
      required this.result,
      required List<String> winners,
      required this.winnerSetChanged,
      required Map<String, int> rankChanges,
      required this.maxWeightChange})
      : winners = List.unmodifiable(winners),
        rankChanges = Map.unmodifiable(rankChanges);

  /// Requested relative weights and scenario identifier.
  final WeightScenario scenario;

  /// Complete re-evaluation with normalized weights and immutable trace.
  final DecisionResult result;

  /// All alternatives sharing rank 1, in stable display order.
  final List<String> winners;

  /// Whether the full winner set differs from the baseline, including ties.
  final bool winnerSetChanged;

  /// Baseline rank minus scenario rank per eligible alternative.
  /// Positive means an improved competition rank; zero means unchanged.
  final Map<String, int> rankChanges;

  /// Largest absolute change of a normalized weight from baseline.
  final double maxWeightChange;
}

/// Two adjacent samples whose winner sets differ.
final class SensitivityTransition {
  SensitivityTransition._(this.from, this.to);

  /// Earlier requested sample, not an exact mathematical boundary.
  final SensitivityScenario from;

  /// Next requested sample with a different winner set.
  final SensitivityScenario to;
}

/// Immutable baseline and weight-scenario comparisons.
final class SensitivityReport {
  SensitivityReport._(this.baseline, List<String> baselineWinners,
      List<SensitivityScenario> scenarios)
      : baselineWinners = List.unmodifiable(baselineWinners),
        scenarios = List.unmodifiable(scenarios);

  /// Evaluation with the original configured weights.
  final DecisionResult baseline;

  /// Complete rank-1 set of the baseline, not just its representative best.
  final List<String> baselineWinners;

  /// Evaluations in the caller's scenario/grid order.
  final List<SensitivityScenario> scenarios;

  /// Fraction of requested scenarios retaining the baseline's complete winner
  /// set. Null for no scenarios or no eligible alternatives. This is a sampled
  /// descriptive fraction, not a probability or a robustness guarantee.
  double? get winnerStability => scenarios.isEmpty || baselineWinners.isEmpty
      ? null
      : scenarios.where((s) => !s.winnerSetChanged).length / scenarios.length;

  /// Changes between adjacent requested samples. For arbitrary explicit
  /// scenarios, adjacency refers only to input order, not geometric proximity.
  List<SensitivityTransition> get transitions => List.unmodifiable([
        for (var i = 1; i < scenarios.length; i++)
          if (!_sameSet(scenarios[i - 1].winners, scenarios[i].winners))
            SensitivityTransition._(scenarios[i - 1], scenarios[i]),
      ]);
}

List<String> _winners(DecisionResult result) => result.ranking
    .where((entry) => entry.rank == 1)
    .map((entry) => entry.alternative.name)
    .toList();

bool _sameSet(List<String> a, List<String> b) =>
    a.length == b.length && a.toSet().containsAll(b);
