/// Numeric output of a decision method, in input row and column order.
final class MethodEvaluation {
  /// Deep-copies all matrices and diagnostics.
  MethodEvaluation({
    required List<double> scores,
    required List<List<double>> normalized,
    required List<List<double>> weighted,
    Map<String, List<double>> diagnostics = const {},
  })  : scores = List.unmodifiable(scores),
        normalized = _freeze(normalized),
        weighted = _freeze(weighted),
        diagnostics = Map.unmodifiable(
          diagnostics.map(
            (key, value) => MapEntry(key, List<double>.unmodifiable(value)),
          ),
        );

  /// One finite score per alternative; higher is preferred.
  final List<double> scores;

  /// Normalized values before weighting.
  final List<List<double>> normalized;

  /// Normalized values multiplied by criterion weights.
  final List<List<double>> weighted;

  /// One finite value per alternative for each method-specific diagnostic.
  final Map<String, List<double>> diagnostics;

  static List<List<double>> _freeze(List<List<double>> rows) =>
      List.unmodifiable(rows.map((row) => List<double>.unmodifiable(row)));
}
