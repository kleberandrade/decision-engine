import '../domain/decision_matrix.dart';
import '../domain/method_evaluation.dart';

/// A stateless ranking strategy, independent of orchestration and constraints.
abstract interface class DecisionMethod {
  /// Human-readable method identifier included in results.
  String get name;

  /// Scores a nonempty matrix, returning finite data with matching dimensions.
  ///
  /// Scores use descending preference. Each diagnostic must contain one value
  /// per alternative. Implementations must not modify inputs or retain run state.
  MethodEvaluation evaluate(DecisionMatrix matrix);
}
