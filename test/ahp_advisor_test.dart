import 'dart:math' as math;
import 'package:decision_engine/decision_engine.dart';
import 'package:test/test.dart';

AhpResult outlier() => AhpWeighting().evaluate(criterionIds: [
      'a',
      'b',
      'c',
      'd'
    ], comparisons: [
      [1, 9, 1, 1],
      [1 / 9, 1, 1, 1],
      [1, 1, 1, 1],
      [1, 1, 1, 1],
    ]);
void main() {
  test(
      'triad disagreement singles out one conflicting comparison and previews an exact repair',
      () {
    final source = outlier();
    final report = AhpConsistencyAdvisor().review(source);
    final worst = report.comparisons.first;
    expect(worst.row, 0);
    expect(worst.column, 1);
    expect(worst.meanLogDeviation, closeTo(math.log(9), 1e-12));
    expect(worst.triadCount, 2);
    expect(worst.adjustment!.value, closeTo(1, 1e-12));
    expect(worst.adjustment!.evaluation.consistencyRatio, closeTo(0, 1e-12));
    expect(worst.adjustment!.evaluation.weights.values,
        everyElement(closeTo(.25, 1e-12)));
    expect(worst.adjustment!.evaluation.comparisons[1][0], closeTo(1, 1e-12));
    expect(source.comparisons[0][1], 9);
    expect(() => report.comparisons.clear(), throwsUnsupportedError);
  });
  test(
      'cyclic judgments yield bounded improvements without claiming a full repair',
      () {
    final source = AhpWeighting().evaluate(criterionIds: [
      'a',
      'b',
      'c'
    ], comparisons: [
      [1, 9, 1 / 9],
      [1 / 9, 1, 9],
      [9, 1 / 9, 1],
    ]);
    final report = AhpConsistencyAdvisor().review(source);
    for (final pair in report.comparisons) {
      final suggestion = pair.adjustment!;
      expect(pair.meanLogDeviation, closeTo(3 * math.log(9), 1e-12));
      expect(suggestion.targetWasClamped, isTrue);
      expect(suggestion.value, inInclusiveRange(1 / 9, 9));
      expect(suggestion.evaluation.consistencyRatio,
          lessThan(source.consistencyRatio));
      expect(suggestion.evaluation.isConsistent, isFalse);
      // After one bounded repair the triad product is 9 or 1/9.
      final t = math.pow(9, 1 / 3).toDouble();
      expect(suggestion.evaluation.lambdaMax, closeTo(1 + t + 1 / t, 1e-8));
      expect(suggestion.evaluation.consistencyRatio,
          closeTo((t + 1 / t - 2) / 2 / .58, 1e-8));
    }
  });
  test('consistent, singleton and pair judgments do not invent repairs', () {
    for (final n in [1, 2, 3, 10]) {
      final source = AhpWeighting().evaluate(
          criterionIds: List.generate(n, (i) => 'c$i'),
          comparisons: List.generate(n, (_) => List.filled(n, 1)));
      final report = AhpConsistencyAdvisor().review(source);
      expect(report.comparisons, isEmpty);
    }
  });
  test('preview changes only its chosen pair and preserves IDs and threshold',
      () {
    final source = outlier();
    final pair = AhpConsistencyAdvisor().review(source).comparisons.first;
    final next = pair.adjustment!.evaluation;
    expect(next.criterionIds, source.criterionIds);
    expect(next.consistencyThreshold, source.consistencyThreshold);
    for (var i = 0; i < 4; i++) {
      for (var j = 0; j < 4; j++) {
        if ((i == pair.row && j == pair.column) ||
            (i == pair.column && j == pair.row)) {
          continue;
        }
        expect(next.comparisons[i][j], source.comparisons[i][j]);
      }
    }
  });

  test(
      'default numerical boundary rejects loose reciprocals and preserves custom thresholds',
      () {
    final loose =
        AhpWeighting(reciprocityTolerance: .2).evaluate(criterionIds: [
      'a'
    ], comparisons: [
      [1.1]
    ]);
    expect(
        () => const AhpConsistencyAdvisor().review(loose), throwsArgumentError);
    final source =
        AhpWeighting(consistencyThreshold: .2).evaluate(criterionIds: [
      'a',
      'b',
      'c'
    ], comparisons: [
      [1, 3, 1],
      [1 / 3, 1, 1],
      [1, 1, 1]
    ]);
    final review = const AhpConsistencyAdvisor().review(source);
    expect(review.baseline.consistencyThreshold, .2);
    for (final pair in review.comparisons) {
      if (pair.adjustment != null) {
        expect(pair.adjustment!.evaluation.consistencyThreshold, .2);
      }
    }
  });
  test(
      'ten-criterion review recovers a single outlier without mutating other pairs',
      () {
    final matrix = List.generate(10, (_) => List<double>.filled(10, 1));
    matrix[0][1] = 9;
    matrix[1][0] = 1 / 9;
    final source = AhpWeighting().evaluate(
        criterionIds: List.generate(10, (i) => 'c$i'), comparisons: matrix);
    final review = const AhpConsistencyAdvisor().review(source);
    expect(review.comparisons.first.row, 0);
    expect(review.comparisons.first.column, 1);
    expect(review.comparisons.first.triadCount, 8);
    expect(review.comparisons.first.adjustment!.evaluation.consistencyRatio,
        closeTo(0, 1e-12));
    expect(source.comparisons[0][1], 9);
  });
}
