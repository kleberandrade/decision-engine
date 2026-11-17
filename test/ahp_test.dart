import 'package:decision_engine/decision_engine.dart';
import 'package:test/test.dart';

List<List<num>> consistent() => [
      [1, 2, 6],
      [1 / 2, 1, 3],
      [1 / 6, 1 / 3, 1],
    ];
List<List<num>> inconsistent() => [
      [1, 9, 1 / 9],
      [1 / 9, 1, 9],
      [9, 1 / 9, 1],
    ];

void main() {
  test('AHP recovers known ratio weights and a zero consistency ratio', () {
    final result = AhpWeighting().evaluate(
        criterionIds: ['quality', 'cost', 'latency'],
        comparisons: consistent());
    expect(result.weights['quality'], closeTo(0.6, 1e-10));
    expect(result.weights['cost'], closeTo(0.3, 1e-10));
    expect(result.weights['latency'], closeTo(0.1, 1e-10));
    expect(result.lambdaMax, closeTo(3, 1e-10));
    expect(result.consistencyIndex, closeTo(0, 1e-10));
    expect(result.consistencyRatio, closeTo(0, 1e-10));
    expect(result.randomIndex, 0.58);
    expect(result.isConsistent, isTrue);
    expect(result.residual, lessThanOrEqualTo(1e-10));
  });

  test('AHP identifies cyclic judgments with independently known eigenvalue',
      () {
    final result = AhpWeighting()
        .evaluate(criterionIds: ['a', 'b', 'c'], comparisons: inconsistent());
    // Equal row sums make [1/3,1/3,1/3] an exact Perron eigenvector.
    final lambda = 1 + 9 + 1 / 9;
    expect(result.lambdaMax, closeTo(lambda, 1e-10));
    expect(result.consistencyRatio, closeTo((lambda - 3) / 2 / 0.58, 1e-10));
    expect(result.isConsistent, isFalse);
    expect(
        () => result.toCriteria({
              'a': CriterionDirection.maximize,
              'b': CriterionDirection.minimize,
              'c': CriterionDirection.maximize,
            }),
        throwsStateError);
    expect(
        result.toCriteria({
          'a': CriterionDirection.maximize,
          'b': CriterionDirection.minimize,
          'c': CriterionDirection.maximize,
        }, requireConsistency: false),
        hasLength(3));
  });

  test('AHP weights compose with both built-in ranking methods', () {
    final weights = AhpWeighting().evaluate(
        criterionIds: ['quality', 'cost', 'latency'],
        comparisons: consistent());
    final criteria = weights.toCriteria({
      'latency': CriterionDirection.minimize,
      'cost': CriterionDirection.minimize,
      'quality': CriterionDirection.maximize,
    });
    expect(criteria.map((c) => c.id), ['quality', 'cost', 'latency']);
    expect(criteria[1].direction, CriterionDirection.minimize);
    for (final method in <DecisionMethod>[
      const WeightedSum(),
      const Topsis()
    ]) {
      final options = [
        Alternative('A', values: {'quality': 10, 'cost': 200, 'latency': 40}),
        Alternative('B', values: {'quality': 20, 'cost': 100, 'latency': 20}),
      ];
      final result =
          DecisionEngine(criteria: criteria, method: method).evaluate(options);
      expect(result.best!.name, 'B');
      expect(result.ranking.first.score, closeTo(1, 1e-10));
    }
  });

  test(
      'AHP satisfies the eigenvector relation for a nontrivial order-four matrix',
      () {
    final matrix = <List<num>>[
      [1, 3, 5, 7],
      [1 / 3, 1, 2, 4],
      [1 / 5, 1 / 2, 1, 3],
      [1 / 7, 1 / 4, 1 / 3, 1],
    ];
    final result = AhpWeighting()
        .evaluate(criterionIds: ['a', 'b', 'c', 'd'], comparisons: matrix);
    final weights =
        result.criterionIds.map((id) => result.weights[id]!).toList();
    for (var i = 0; i < 4; i++) {
      var product = 0.0;
      for (var j = 0; j < 4; j++) {
        product += matrix[i][j] * weights[j];
      }
      expect(product, closeTo(result.lambdaMax * weights[i], 1e-8));
    }
    expect(result.consistencyRatio, greaterThan(0));
    expect(weights.every((w) => w > 0), isTrue);
    expect(weights.fold(0.0, (a, b) => a + b), closeTo(1, 1e-12));
  });

  test('AHP singleton and pair use a defined zero CR convention', () {
    final one = AhpWeighting().evaluate(criterionIds: [
      'a'
    ], comparisons: [
      [1]
    ]);
    expect(one.weights, {'a': 1});
    expect(one.randomIndex, 0);
    expect(one.consistencyRatio, 0);
    final two = AhpWeighting().evaluate(criterionIds: [
      'a',
      'b'
    ], comparisons: [
      [1, 9],
      [1 / 9, 1]
    ]);
    expect(two.weights['a'], closeTo(0.9, 1e-10));
    expect(two.consistencyRatio, 0);
    expect(two.isConsistent, isTrue);
  });

  test('AHP defines the entire supported random index table', () {
    final indices = [0.0, 0, 0.58, 0.90, 1.12, 1.24, 1.32, 1.41, 1.45, 1.49];
    for (var n = 1; n <= 10; n++) {
      final result = AhpWeighting().evaluate(
        criterionIds: List.generate(n, (i) => 'c$i'),
        comparisons: List.generate(n, (_) => List<num>.filled(n, 1)),
      );
      expect(result.randomIndex, indices[n - 1]);
      expect(
          result.weights.values.fold(0.0, (a, b) => a + b), closeTo(1, 1e-12));
      expect(result.consistencyRatio, closeTo(0, 1e-12));
    }
  });

  test('AHP copies input and exposes immutable weights and comparisons', () {
    final ids = ['a', 'b', 'c'];
    final values = consistent();
    final result =
        AhpWeighting().evaluate(criterionIds: ids, comparisons: values);
    ids.clear();
    values[0][0] = 5;
    expect(result.criterionIds, ['a', 'b', 'c']);
    expect(result.comparisons[0][0], 1);
    expect(() => result.weights['a'] = 0, throwsUnsupportedError);
    expect(() => result.comparisons[0][0] = 2, throwsUnsupportedError);
    expect(() => result.criterionIds.clear(), throwsUnsupportedError);
  });

  test('AHP rejects invalid dimensions, IDs, scale and reciprocity', () {
    final invalid = <List<List<num>>>[
      [],
      [
        [1]
      ],
      [
        [1, 2],
        [1, 1]
      ],
      [
        [2, 1],
        [1, 1]
      ],
      [
        [1, 0],
        [0, 1]
      ],
      [
        [1, -1],
        [-1, 1]
      ],
      [
        [1, double.nan],
        [1, 1]
      ],
      [
        [1, double.infinity],
        [0, 1]
      ],
      [
        [1, 10],
        [0.1, 1]
      ],
      [
        [1, 1, 1],
        [1, 1, 1]
      ],
    ];
    for (final values in invalid) {
      expect(
          () => AhpWeighting()
              .evaluate(criterionIds: ['a', 'b'], comparisons: values),
          throwsArgumentError);
    }
    expect(() => AhpWeighting().evaluate(criterionIds: [], comparisons: []),
        throwsArgumentError);
    expect(
        () => AhpWeighting().evaluate(criterionIds: [
              'a',
              'a'
            ], comparisons: [
              [1, 1],
              [1, 1]
            ]),
        throwsArgumentError);
    expect(
        () => AhpWeighting().evaluate(criterionIds: [
              ' '
            ], comparisons: [
              [1]
            ]),
        throwsArgumentError);
    expect(
        () => AhpWeighting().evaluate(
            criterionIds: List.generate(11, (i) => '$i'),
            comparisons: List.generate(11, (_) => List.filled(11, 1))),
        throwsArgumentError);
  });

  test('AHP rejects invalid numerical policy configuration', () {
    for (final value in [0.0, -1.0, double.nan, double.infinity, 1.0]) {
      expect(() => AhpWeighting(tolerance: value), throwsArgumentError);
      expect(
          () => AhpWeighting(reciprocityTolerance: value), throwsArgumentError);
    }
    for (final value in [-1.0, double.nan, double.infinity, 1.0]) {
      expect(
          () => AhpWeighting(consistencyThreshold: value), throwsArgumentError);
    }
    expect(() => AhpWeighting(maxIterations: 0), throwsArgumentError);
    expect(() => AhpWeighting(maxIterations: -1), throwsArgumentError);
  });

  test('AHP reports nonconvergence rather than returning provisional weights',
      () {
    expect(
        () => AhpWeighting(maxIterations: 1, tolerance: 1e-15).evaluate(
              criterionIds: ['a', 'b', 'c'],
              comparisons: [
                [1, 2, 7],
                [1 / 2, 1, 3],
                [1 / 7, 1 / 3, 1],
              ],
            ),
        throwsStateError);
  });

  test('AHP threshold is inclusive and explicit', () {
    final first = AhpWeighting().evaluate(criterionIds: [
      'a',
      'b',
      'c'
    ], comparisons: [
      [1, 2, 7],
      [1 / 2, 1, 3],
      [1 / 7, 1 / 3, 1],
    ]);
    expect(first.consistencyRatio, greaterThan(0));
    final boundary =
        AhpWeighting(consistencyThreshold: first.consistencyRatio).evaluate(
      criterionIds: ['a', 'b', 'c'],
      comparisons: [
        [1, 2, 7],
        [1 / 2, 1, 3],
        [1 / 7, 1 / 3, 1],
      ],
    );
    expect(boundary.isConsistent, isTrue);
    final strict = AhpWeighting(consistencyThreshold: 0).evaluate(
      criterionIds: ['a', 'b', 'c'],
      comparisons: [
        [1, 2, 7],
        [1 / 2, 1, 3],
        [1 / 7, 1 / 3, 1],
      ],
    );
    expect(strict.isConsistent, isFalse);
  });

  test('AHP requires exactly one explicit direction per generated criterion',
      () {
    final result = AhpWeighting().evaluate(criterionIds: [
      'a'
    ], comparisons: [
      [1]
    ]);
    expect(() => result.toCriteria({}), throwsArgumentError);
    expect(
        () => result.toCriteria({
              'a': CriterionDirection.maximize,
              'b': CriterionDirection.minimize
            }),
        throwsArgumentError);
  });

  test('AHP permuting criteria permutes weights and preserves consistency', () {
    final result = AhpWeighting()
        .evaluate(criterionIds: ['a', 'b', 'c'], comparisons: consistent());
    final order = [2, 0, 1];
    final values = consistent();
    final permuted = AhpWeighting().evaluate(criterionIds: [
      'c',
      'a',
      'b'
    ], comparisons: [
      for (final i in order) [for (final j in order) values[i][j]]
    ]);
    for (final id in result.criterionIds) {
      expect(permuted.weights[id], closeTo(result.weights[id]!, 1e-10));
    }
    expect(permuted.consistencyRatio, closeTo(result.consistencyRatio, 1e-10));
  });
}
