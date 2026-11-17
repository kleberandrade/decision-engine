import 'package:decision_engine/decision_engine.dart';

void main() {
  final baseline = AhpWeighting().evaluate(
    criterionIds: ['cost', 'latency', 'availability'],
    comparisons: [
      [1, 9, 1 / 9],
      [1 / 9, 1, 9],
      [9, 1 / 9, 1]
    ],
  );
  final review = const AhpConsistencyAdvisor().review(baseline);
  final pair = review.comparisons.first;
  final suggestion = pair.adjustment!;
  print(
      '${baseline.criterionIds[pair.row]} / ${baseline.criterionIds[pair.column]}');
  print('Mean absolute log deviation: ${pair.meanLogDeviation}');
  print(
      'CR: ${baseline.consistencyRatio} -> ${suggestion.evaluation.consistencyRatio}');
  print(
      'Suggested comparison: ${suggestion.value}; consistent: ${suggestion.evaluation.isConsistent}');
  print(
      'A preview does not adopt weights or prove that preferences are correct.');
}
