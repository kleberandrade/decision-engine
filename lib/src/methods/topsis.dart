import 'dart:math' as math;

import '../contracts/decision_method.dart';
import '../domain/criterion.dart';
import '../domain/decision_matrix.dart';
import '../domain/method_evaluation.dart';

/// TOPSIS with vector normalization and Euclidean ideal-point distances.
///
/// Scores are closeness to the positive ideal: dNegative / (dPositive +
/// dNegative). Indistinguishable alternatives receive 0.5. Both signed and
/// zero-valued columns are supported; criterion direction selects each ideal.
final class Topsis implements DecisionMethod {
  /// Creates the stateless TOPSIS strategy.
  const Topsis();

  @override
  String get name => 'topsis';

  @override
  MethodEvaluation evaluate(DecisionMatrix matrix) {
    final rows = matrix.values.length;
    final columns = matrix.criteria.length;
    final normalized = List.generate(rows, (_) => List.filled(columns, 0.0));
    for (var j = 0; j < columns; j++) {
      var scale = 0.0;
      for (final row in matrix.values) {
        if (row[j].abs() > scale) scale = row[j].abs();
      }
      if (scale == 0) continue;
      final scaled = matrix.values.map((r) => r[j] / scale).toList();
      final norm = math.sqrt(scaled.fold(0.0, (sum, v) => sum + v * v));
      for (var i = 0; i < rows; i++) {
        normalized[i][j] = scaled[i] / norm;
      }
    }
    final weighted = List.generate(
      rows,
      (i) =>
          List.generate(columns, (j) => normalized[i][j] * matrix.weights[j]),
    );
    final positive = List.filled(columns, 0.0);
    final negative = List.filled(columns, 0.0);
    for (var j = 0; j < columns; j++) {
      var low = weighted.first[j];
      var high = low;
      for (final row in weighted) {
        if (row[j] < low) low = row[j];
        if (row[j] > high) high = row[j];
      }
      final maximize =
          matrix.criteria[j].direction == CriterionDirection.maximize;
      positive[j] = maximize ? high : low;
      negative[j] = maximize ? low : high;
    }
    // Stable norm avoids underflow when nonzero weighted differences are tiny.
    double distance(List<double> row, List<double> ideal) {
      final deltas = List.generate(columns, (j) => (row[j] - ideal[j]).abs());
      final scale = deltas.fold(0.0, math.max);
      if (scale == 0) return 0;
      return scale *
          math.sqrt(
            deltas.fold(0.0, (sum, d) => sum + (d / scale) * (d / scale)),
          );
    }

    final dp = weighted.map((r) => distance(r, positive)).toList();
    final dn = weighted.map((r) => distance(r, negative)).toList();
    return MethodEvaluation(
      scores: List.generate(
        rows,
        (i) => dp[i] + dn[i] == 0 ? 0.5 : dn[i] / (dp[i] + dn[i]),
      ),
      normalized: normalized,
      weighted: weighted,
      diagnostics: {'distanceToIdeal': dp, 'distanceToAntiIdeal': dn},
    );
  }
}
