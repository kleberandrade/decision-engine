import 'dart:convert';
import 'package:decision_engine/decision_engine.dart';
import 'package:decision_engine_lab/configuration.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('scenario round trip preserves both rankings and rejection evidence',
      () {
    final source = LabConfiguration.sample();
    final restored = LabConfiguration.parse(source.encode());
    for (final method in [const WeightedSum(), const Topsis()]) {
      final result = restored.engine(method).evaluate(restored.alternatives);
      expect(result.ranking.first.alternative.name,
          method is WeightedSum ? 'Vega' : 'Atlas');
      expect(result.excluded.single.alternative.name, 'Nova');
      expect(
          result.ranking.map((r) => r.score),
          source
              .engine(method)
              .evaluate(source.alternatives)
              .ranking
              .map((r) => r.score));
    }
  });
  test('export includes selected method and sensitivity criterion', () {
    final restored = LabConfiguration.parse(
        LabConfiguration.sample().encode(null, 'topsis', 'latency'));
    expect(restored.methodName, 'topsis');
    expect(restored.sweepId, 'latency');
  });
  test('custom criteria, alternatives and inclusive bounds use public core',
      () {
    final config = LabConfiguration.parse(jsonEncode({
      'criteria': [
        {'id': 'price', 'label': 'Price', 'direction': 'minimize', 'weight': 3},
        {
          'id': 'quality',
          'label': 'Quality',
          'direction': 'maximize',
          'weight': 1
        }
      ],
      'alternatives': [
        {
          'name': 'A',
          'values': {'price': 10, 'quality': 2}
        },
        {
          'name': 'B',
          'values': {'price': 20, 'quality': 4}
        },
        {
          'name': 'C',
          'values': {'price': 30, 'quality': 5}
        }
      ],
      'constraints': [
        {'criterion': 'price', 'maximum': 20}
      ]
    }));
    final result =
        config.engine(const WeightedSum()).evaluate(config.alternatives);
    expect(result.ranking.map((r) => r.score), [0.75, 0.25]);
    expect(result.excluded.single.alternative.name, 'C');
  });
  test('invalid input is rejected atomically with a readable error', () {
    for (final edit in <void Function(Map<String, dynamic>)>[
      (d) => d['criteria'][0]['direction'] = 'unknown',
      (d) => d['method'] = 'missing',
      (d) => d['sweep'] = 'missing',
      (d) => d['alternatives'][0]['values']['cost'] = 'invalid',
      (d) => d['constraints'][0]['criterion'] = 'missing',
      (d) => d['criteria'][1]['id'] = 'cost',
      (d) => d['criteria'].forEach((dynamic c) => c['weight'] = 0),
      (d) => d['constraints'][0]['maximum'] = 90,
    ]) {
      final data = jsonDecode(LabConfiguration.sample().encode())
          as Map<String, dynamic>;
      edit(data);
      expect(() => LabConfiguration.parse(jsonEncode(data)),
          throwsFormatException);
    }
  });
}
