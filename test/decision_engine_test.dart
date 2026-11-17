import 'dart:math' as math;
import 'package:decision_engine/decision_engine.dart';
import 'package:test/test.dart';

Alternative option(String name, num benefit, num cost) =>
    Alternative(name, values: {'benefit': benefit, 'cost': cost});

List<Criterion> criteria([double benefitWeight = 3, double costWeight = 1]) => [
      Criterion.maximize('benefit', weight: benefitWeight),
      Criterion.minimize('cost', weight: costWeight),
    ];

void main() {
  group('weighted sum', () {
    test(
      'normalizes mixed directions and explains a hand-calculated result',
      () {
        final result = DecisionEngine(
          criteria: criteria(),
          method: const WeightedSum(),
        ).evaluate([
          option('A', 10, 100),
          option('B', 20, 200),
          option('C', 15, 125),
        ]);
        expect(result.weights, [0.75, 0.25]);
        expect(result.trace!.scores, [0.25, 0.75, 0.5625]);
        expect(result.trace!.normalized[2], [0.5, 0.75]);
        expect(result.trace!.weighted[2], [0.375, 0.1875]);
        expect(result.ranking.map((r) => r.alternative.name), ['B', 'C', 'A']);
        expect(result.best!.name, 'B');
      },
    );
    test('constant criteria contribute equally, ties preserve input order', () {
      final result = DecisionEngine(
        criteria: criteria(1, 1),
        method: const WeightedSum(),
      ).evaluate([option('B', 7, 4), option('A', 7, 4)]);
      expect(result.trace!.scores, [1, 1]);
      expect(result.ranking.map((r) => r.rank), [1, 1]);
      expect(result.best!.name, 'B');
    });
    test('signed values and zero-weight criteria are supported', () {
      final result = DecisionEngine(
        criteria: criteria(1, 0),
        method: const WeightedSum(),
      ).evaluate([option('A', -10, 1), option('B', -5, 10000)]);
      expect(result.trace!.scores, [0, 1]);
    });
  });

  group('TOPSIS', () {
    test(
      'matches independently derived distances for conflicting criteria',
      () {
        final result = DecisionEngine(
          criteria: criteria(1, 1),
          method: const Topsis(),
        ).evaluate([option('A', 1, 1), option('B', 2, 3)]);
        final benefitGap = 0.5 / math.sqrt(5);
        final costGap = 1 / math.sqrt(10);
        final expectedA = costGap / (costGap + benefitGap);
        expect(result.trace!.scores[0], closeTo(expectedA, 1e-12));
        expect(result.trace!.scores[1], closeTo(1 - expectedA, 1e-12));
        expect(
          result.trace!.diagnostics['distanceToIdeal']![0],
          closeTo(benefitGap, 1e-12),
        );
        expect(
          result.trace!.diagnostics['distanceToAntiIdeal']![0],
          closeTo(costGap, 1e-12),
        );
        expect(result.best!.name, 'A');
      },
    );
    test('dominant option scores one, anti-ideal scores zero', () {
      final result = DecisionEngine(
        criteria: criteria(),
        method: const Topsis(),
      ).evaluate([option('A', 20, 100), option('B', 10, 200)]);
      expect(result.trace!.scores, [1, 0]);
    });
    test('zero columns and identical alternatives return neutral ties', () {
      final result = DecisionEngine(
        criteria: criteria(),
        method: const Topsis(),
      ).evaluate([option('A', 0, 0), option('B', 0, 0)]);
      expect(result.trace!.scores, [0.5, 0.5]);
      expect(result.ranking.map((r) => r.rank), [1, 1]);
    });
    test('signed criteria respect direction', () {
      final result = DecisionEngine(
        criteria: criteria(),
        method: const Topsis(),
      ).evaluate([option('A', -1, -5), option('B', -2, -3)]);
      expect(result.trace!.scores, [1, 0]);
    });
  });

  group('both methods', () {
    for (final method in <DecisionMethod>[
      const WeightedSum(),
      const Topsis(),
    ]) {
      test(
        '${method.name}: excludes before fitting and collects all reasons',
        () {
          final result = DecisionEngine(
            criteria: criteria(),
            method: method,
            constraints: [
              MinimumValue('benefit', 10),
              MaximumValue('cost', 200),
            ],
          ).evaluate([
            option('rejected', -100000, 1e9),
            option('A', 10, 100),
            option('B', 20, 200),
          ]);
          expect(result.excluded.single.reasons, hasLength(2));
          expect(result.eligible.map((a) => a.name), ['A', 'B']);
          final withoutRejected = DecisionEngine(
            criteria: criteria(),
            method: method,
          ).evaluate([option('A', 10, 100), option('B', 20, 200)]);
          expect(result.trace!.scores, withoutRejected.trace!.scores);
        },
      );
      test('${method.name}: empty and entirely rejected sets have no best', () {
        final engine = DecisionEngine(
          criteria: criteria(),
          method: method,
          constraints: [MinimumValue('benefit', 10)],
        );
        expect(engine.evaluate([]).best, isNull);
        final result = engine.evaluate([option('A', 1, 1)]);
        expect(result.best, isNull);
        expect(result.ranking, isEmpty);
        expect(result.trace, isNull);
        expect(result.excluded, hasLength(1));
      });
      test(
        '${method.name}: singleton and extreme finite inputs remain finite',
        () {
          final engine = DecisionEngine(
            criteria: criteria(1e308, 1e308),
            method: method,
          );
          final singleton = engine.evaluate([option('A', 0, 0)]);
          expect(singleton.ranking.single.rank, 1);
          final result = engine.evaluate([
            option('A', 1e308, -1e308),
            option('B', -1e308, 1e308),
          ]);
          expect(result.best!.name, 'A');
          expect(result.trace!.scores.every((s) => s.isFinite), isTrue);
        },
      );
      test('${method.name}: positive unit scaling preserves scores', () {
        final engine = DecisionEngine(criteria: criteria(), method: method);
        final a = engine.evaluate([
          option('A', 10, 100),
          option('B', 20, 200),
          option('C', 15, 125),
        ]);
        final b = engine.evaluate([
          option('A', 1, 100000),
          option('B', 2, 200000),
          option('C', 1.5, 125000),
        ]);
        for (var i = 0; i < 3; i++) {
          expect(b.trace!.scores[i], closeTo(a.trace!.scores[i], 1e-12));
        }
      });
      test('${method.name}: repeated evaluations retain no run state', () {
        final engine = DecisionEngine(criteria: criteria(), method: method);
        final options = [option('A', 10, 100), option('B', 20, 200)];
        final before = engine.evaluate(options);
        engine.evaluate([option('other', 0, 0)]);
        expect(engine.evaluate(options).trace!.scores, before.trace!.scores);
      });
      test('${method.name}: zero weight removes criterion influence', () {
        final result = DecisionEngine(
          criteria: criteria(1, 0),
          method: method,
        ).evaluate([option('A', 10, 0), option('B', 20, 1e308)]);
        expect(result.best!.name, 'B');
      });
    }
  });

  group('validation and ownership', () {
    test('rejects invalid criteria, weights and references', () {
      expect(() => Criterion.maximize(' ', weight: 1), throwsArgumentError);
      for (final weight in [-1.0, double.nan, double.infinity]) {
        expect(
          () => Criterion.minimize('x', weight: weight),
          throwsArgumentError,
        );
      }
      expect(
        () => DecisionEngine(criteria: [], method: const Topsis()),
        throwsArgumentError,
      );
      expect(
        () => DecisionEngine(criteria: criteria(0, 0), method: const Topsis()),
        throwsArgumentError,
      );
      expect(
        () => DecisionEngine(
          criteria: [
            Criterion.maximize('x', weight: 1),
            Criterion.minimize('x', weight: 1),
          ],
          method: const Topsis(),
        ),
        throwsArgumentError,
      );
      expect(
        () => DecisionEngine(
          criteria: criteria(),
          method: const Topsis(),
          constraints: [MinimumValue('missing', 1)],
        ),
        throwsArgumentError,
      );
      expect(() => MinimumValue('x', double.infinity), throwsArgumentError);
      expect(() => MaximumValue('', 1), throwsArgumentError);
    });
    test(
      'rejects blank names, nonfinite, missing, extra and duplicate inputs',
      () {
        final engine = DecisionEngine(
          criteria: criteria(),
          method: const Topsis(),
        );
        expect(() => option('', 1, 2), throwsArgumentError);
        expect(() => option('A', double.nan, 1), throwsArgumentError);
        expect(() => option('A', 1, double.infinity), throwsArgumentError);
        expect(
          () => engine.evaluate([
            Alternative('A', values: {'benefit': 1}),
          ]),
          throwsArgumentError,
        );
        expect(
          () => engine.evaluate([
            Alternative('A', values: {'benefit': 1, 'cost': 1, 'extra': 1}),
          ]),
          throwsArgumentError,
        );
        expect(
          () => engine.evaluate([option('A', 1, 2), option('A', 2, 3)]),
          throwsArgumentError,
        );
      },
    );
    test('validates rejected options too', () {
      final engine = DecisionEngine(
        criteria: criteria(),
        method: const Topsis(),
        constraints: [MinimumValue('benefit', 10)],
      );
      expect(
        () => engine.evaluate([
          Alternative('A', values: {'benefit': 0}),
        ]),
        throwsArgumentError,
      );
    });
    test(
      'copies configuration, observations and nested result collections',
      () {
        final values = <String, num>{'benefit': 10, 'cost': 100};
        final a = Alternative('A', values: values);
        values['benefit'] = -999;
        final config = criteria();
        final engine = DecisionEngine(criteria: config, method: const Topsis());
        config.clear();
        final result = engine.evaluate([a, option('B', 20, 200)]);
        expect(a.values['benefit'], 10);
        expect(() => a.values['cost'] = 0, throwsUnsupportedError);
        expect(() => result.ranking.clear(), throwsUnsupportedError);
        expect(
          () => result.trace!.normalized[0][0] = 0,
          throwsUnsupportedError,
        );
        expect(
          () => result.trace!.diagnostics['distanceToIdeal']!.clear(),
          throwsUnsupportedError,
        );
        expect(() => result.weights.clear(), throwsUnsupportedError);
      },
    );
    test('inclusive constraint bounds', () {
      expect(MinimumValue('x', 10).rejectionReason(10), isNull);
      expect(MaximumValue('x', 10).rejectionReason(10), isNull);
    });
    test('custom methods use public contract and descending scores', () {
      final result = DecisionEngine(
        criteria: criteria(),
        method: const CustomMethod(),
      ).evaluate([option('A', 1, 1), option('B', 2, 2), option('C', 3, 3)]);
      expect(result.method, 'custom');
      expect(result.ranking.map((r) => r.rank), [1, 1, 3]);
      expect(result.ranking.map((r) => r.alternative.name), ['A', 'B', 'C']);
      expect(result.trace!.scores, [2, 2, -1]);
    });
    test('signed zero scores are ties in original order', () {
      final result =
          DecisionEngine(criteria: criteria(), method: SignedZeroMethod())
              .evaluate([option('A', 1, 1), option('B', 2, 2)]);
      expect(result.ranking.map((r) => r.alternative.name), ['A', 'B']);
      expect(result.ranking.map((r) => r.rank), [1, 1]);
    });
    test('rejects malformed strategy output at the extension boundary', () {
      for (final mode in ['scores', 'nonfinite', 'matrix', 'diagnostic']) {
        final engine = DecisionEngine(
          criteria: criteria(),
          method: BrokenMethod(mode),
        );
        expect(() => engine.evaluate([option('A', 1, 1)]), throwsStateError);
      }
    });
  });
}

class CustomMethod implements DecisionMethod {
  const CustomMethod();
  @override
  String get name => 'custom';
  @override
  MethodEvaluation evaluate(DecisionMatrix matrix) => MethodEvaluation(
        scores: [2, 2, -1],
        normalized: matrix.values,
        weighted: matrix.values,
      );
}

class BrokenMethod implements DecisionMethod {
  BrokenMethod(this.mode);
  final String mode;
  @override
  String get name => 'broken';
  @override
  MethodEvaluation evaluate(DecisionMatrix matrix) => MethodEvaluation(
        scores: mode == 'scores' ? [] : [mode == 'nonfinite' ? double.nan : 0],
        normalized: mode == 'matrix' ? [[]] : matrix.values,
        weighted: matrix.values,
        diagnostics: mode == 'diagnostic' ? {'bad': []} : {},
      );
}

class SignedZeroMethod implements DecisionMethod {
  @override
  String get name => 'signed_zero';
  @override
  MethodEvaluation evaluate(DecisionMatrix matrix) => MethodEvaluation(
      scores: [-0.0, 0.0], normalized: matrix.values, weighted: matrix.values);
}
