import 'dart:convert';
import 'dart:math' as math;
import 'package:decision_engine/decision_engine.dart';

/// Lab-only, bounded JSON boundary. Ranking remains in the pure Dart package.
class LabConfiguration {
  LabConfiguration._(this.criteria, this.labels, this.alternatives,
      this.constraints, this.bounds, this.methodName, this.sweepId);

  final String methodName;
  final String sweepId;
  final List<Criterion> criteria;
  final Map<String, String> labels;
  final List<Alternative> alternatives;
  final List<DecisionConstraint> constraints;
  final List<Map<String, Object>> bounds;

  factory LabConfiguration.sample() => LabConfiguration.parse('''{
    "criteria": [
      {"id":"cost","label":"Custo","direction":"minimize","weight":0.35},
      {"id":"latency","label":"Latência","direction":"minimize","weight":0.25},
      {"id":"availability","label":"Disponibilidade","direction":"maximize","weight":0.4}
    ],
    "alternatives": [
      {"name":"Atlas","values":{"cost":1200,"latency":25,"availability":99.95}},
      {"name":"Vega","values":{"cost":1600,"latency":15,"availability":99.99}},
      {"name":"Orion","values":{"cost":1000,"latency":40,"availability":99.9}},
      {"name":"Nova","values":{"cost":800,"latency":50,"availability":99.5}}
    ],
    "constraints":[{"criterion":"availability","minimum":99.9}]
  }''');

  factory LabConfiguration.parse(String source) {
    if (source.length > 100000) {
      throw const FormatException('JSON exceeds 100 KB / JSON excede 100 KB.');
    }
    try {
      final data = jsonDecode(source) as Map<String, dynamic>;
      final rows = data['criteria'] as List;
      final options = data['alternatives'] as List;
      if (rows.isEmpty ||
          rows.length > 12 ||
          options.isEmpty ||
          options.length > 30) {
        throw const FormatException('Use 1–12 criteria and 1–30 alternatives.');
      }
      final criteria = <Criterion>[];
      final labels = <String, String>{};
      for (final row in rows) {
        final id = _text(row['id']);
        if (labels.containsKey(id)) {
          throw const FormatException('Duplicate criterion ID.');
        }
        labels[id] = _text(row['label'] ?? id);
        final weight = _number(row['weight']);
        criteria.add(switch (row['direction']) {
          'minimize' => Criterion.minimize(id, weight: weight),
          'maximize' => Criterion.maximize(id, weight: weight),
          _ => throw const FormatException(
              'Direction must be minimize or maximize.')
        });
      }
      final alternatives = options.map((row) {
        final values = row['values'] as Map<String, dynamic>;
        if (values.length != criteria.length ||
            !criteria.every((c) => values.containsKey(c.id))) {
          throw const FormatException(
              'Each alternative must provide exactly all criterion values.');
        }
        return Alternative(_text(row['name']),
            values: values.map((id, v) => MapEntry(id, _number(v))));
      }).toList();
      final constraints = <DecisionConstraint>[];
      final bounds = <Map<String, Object>>[];
      for (final row in (data['constraints'] ?? []) as List) {
        final id = _text(row['criterion']);
        if (!labels.containsKey(id) ||
            (!row.containsKey('minimum') && !row.containsKey('maximum'))) {
          throw const FormatException(
              'Each bound needs an existing criterion and minimum/maximum.');
        }
        final bound = <String, Object>{'criterion': id};
        for (final key in ['minimum', 'maximum']) {
          if (row.containsKey(key)) {
            final value = _number(row[key]);
            bound[key] = value;
            constraints.add(key == 'minimum'
                ? MinimumValue(id, value)
                : MaximumValue(id, value));
          }
        }
        if (bound.containsKey('minimum') &&
            bound.containsKey('maximum') &&
            (bound['minimum'] as double) > (bound['maximum'] as double)) {
          throw const FormatException('Minimum cannot exceed maximum.');
        }
        bounds.add(Map.unmodifiable(bound));
      }
      final methodName = data['method'] ?? 'weighted_sum';
      final sweepId = data['sweep'] ?? criteria.first.id;
      if (!['weighted_sum', 'topsis'].contains(methodName) ||
          !labels.containsKey(sweepId)) {
        throw const FormatException(
            'Unknown ranking method or sweep criterion.');
      }
      final result = LabConfiguration._(
          List.unmodifiable(criteria),
          Map.unmodifiable(labels),
          List.unmodifiable(alternatives),
          List.unmodifiable(constraints),
          List.unmodifiable(bounds),
          methodName as String,
          sweepId as String);
      // Validate both available methods before any state is replaced.
      for (final method in [const WeightedSum(), const Topsis()]) {
        result.engine(method).evaluate(alternatives);
      }
      return result;
    } on FormatException {
      rethrow;
    } on Object {
      throw const FormatException(
          'Invalid scenario: check unique names/IDs, finite numbers, nonnegative weights and at least one positive weight.');
    }
  }

  Map<String, double> get sliderWeights {
    final scale = criteria.map((c) => c.weight).reduce(math.max);
    return {for (final c in criteria) c.id: c.weight / math.max(1, scale)};
  }

  DecisionEngine engine(DecisionMethod method,
          [Map<String, double>? weights]) =>
      DecisionEngine(
        criteria: [
          for (final c in criteria)
            c.direction == CriterionDirection.minimize
                ? Criterion.minimize(c.id, weight: weights?[c.id] ?? c.weight)
                : Criterion.maximize(c.id, weight: weights?[c.id] ?? c.weight)
        ],
        constraints: constraints,
        method: method,
      );

  String encode(
          [Map<String, double>? weights, String? method, String? sweep]) =>
      const JsonEncoder.withIndent('  ').convert({
        'method': method ?? methodName,
        'sweep': sweep ?? sweepId,
        'criteria': [
          for (final c in criteria)
            {
              'id': c.id,
              'label': labels[c.id],
              'direction': c.direction.name,
              'weight': weights?[c.id] ?? c.weight
            }
        ],
        'alternatives': [
          for (final a in alternatives) {'name': a.name, 'values': a.values}
        ],
        'constraints': bounds,
      });

  static String _text(dynamic value) {
    if (value is! String || value.trim().isEmpty || value.length > 80) {
      throw const FormatException(
          'Names and IDs must contain 1–80 characters.');
    }
    return value;
  }

  static double _number(dynamic value) {
    if (value is! num || !value.isFinite || value.abs() > 1e12) {
      throw const FormatException(
          'Use finite numbers with magnitude at most 1e12.');
    }
    return value.toDouble();
  }
}
