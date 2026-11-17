import '../contracts/decision_method.dart';
import '../domain/criterion.dart';
import '../domain/decision_matrix.dart';
import '../domain/method_evaluation.dart';

/// Weighted sum with direction-aware min-max normalization.
///
/// Nonconstant columns map to [0, 1], where 1 is preferred. Constant columns
/// receive 1 for every alternative, so they cannot change ordering.
final class WeightedSum implements DecisionMethod {
  /// Creates the stateless weighted-sum strategy.
  const WeightedSum();

  @override
  String get name => 'weighted_sum';

  @override
  MethodEvaluation evaluate(DecisionMatrix matrix) {
    final rows = matrix.values.length;
    final columns = matrix.criteria.length;
    final normalized = List.generate(rows, (_) => List.filled(columns, 0.0));
    for (var j = 0; j < columns; j++) {
      // Scale first to keep subtraction finite even for +/- double.maxFinite.
      var scale = 0.0;
      for (final row in matrix.values) {
        if (row[j].abs() > scale) scale = row[j].abs();
      }
      final column =
          matrix.values.map((r) => scale == 0 ? 0.0 : r[j] / scale).toList();
      var low = column.first;
      var high = column.first;
      for (final value in column) {
        if (value < low) low = value;
        if (value > high) high = value;
      }
      for (var i = 0; i < rows; i++) {
        normalized[i][j] = high == low
            ? 1.0
            : matrix.criteria[j].direction == CriterionDirection.maximize
                ? (column[i] - low) / (high - low)
                : (high - column[i]) / (high - low);
      }
    }
    final weighted = List.generate(
      rows,
      (i) =>
          List.generate(columns, (j) => normalized[i][j] * matrix.weights[j]),
    );
    return MethodEvaluation(
      scores: weighted.map((r) => r.fold(0.0, (a, b) => a + b)).toList(),
      normalized: normalized,
      weighted: weighted,
    );
  }
}
