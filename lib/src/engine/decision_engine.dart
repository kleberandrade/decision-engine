import '../contracts/decision_constraint.dart';
import '../contracts/decision_method.dart';
import '../domain/alternative.dart';
import '../domain/criterion.dart';
import '../domain/decision_matrix.dart';
import '../domain/decision_result.dart';
import '../domain/method_evaluation.dart';

/// Validates options, filters constraints, delegates scoring and builds a ranking.
final class DecisionEngine {
  /// Copies configuration and validates criterion and constraint references.
  DecisionEngine({
    required List<Criterion> criteria,
    required this.method,
    List<DecisionConstraint> constraints = const [],
  })  : criteria = List.unmodifiable(criteria),
        constraints = List.unmodifiable(constraints) {
    DecisionMatrix(criteria: this.criteria, alternatives: const []);
    final ids = this.criteria.map((c) => c.id).toSet();
    if (this.constraints.any((c) => !ids.contains(c.criterionId))) {
      throw ArgumentError('Constraints must reference existing criteria');
    }
  }

  /// Immutable ordered criteria.
  final List<Criterion> criteria;

  /// Composed scoring strategy.
  final DecisionMethod method;

  /// Immutable eligibility requirements.
  final List<DecisionConstraint> constraints;

  /// Evaluates without modifying inputs or retaining state between calls.
  ///
  /// Malformed alternatives fail even if a constraint would exclude them.
  /// Empty input or an entirely rejected set returns an empty ranking.
  DecisionResult evaluate(List<Alternative> alternatives) {
    final input = DecisionMatrix(
      criteria: criteria,
      alternatives: alternatives,
    );
    final eligible = <Alternative>[];
    final excluded = <ExcludedAlternative>[];
    for (final alternative in input.alternatives) {
      final reasons = <String>[];
      for (final constraint in constraints) {
        final reason = constraint.rejectionReason(
          alternative.values[constraint.criterionId]!,
        );
        if (reason != null) reasons.add(reason);
      }
      if (reasons.isEmpty) {
        eligible.add(alternative);
      } else {
        excluded.add(ExcludedAlternative(alternative, reasons));
      }
    }
    final matrix = DecisionMatrix(criteria: criteria, alternatives: eligible);
    MethodEvaluation? trace;
    final ranking = <RankedAlternative>[];
    if (eligible.isNotEmpty) {
      trace = method.evaluate(matrix);
      _validateTrace(trace, eligible.length, criteria.length);
      final indices = List.generate(eligible.length, (i) => i);
      indices.sort((a, b) {
        if (trace!.scores[a] == trace.scores[b]) return a.compareTo(b);
        final scoreOrder = trace.scores[b].compareTo(trace.scores[a]);
        return scoreOrder == 0 ? a.compareTo(b) : scoreOrder;
      });
      var rank = 1;
      for (var i = 0; i < indices.length; i++) {
        final index = indices[i];
        if (i > 0 && trace.scores[index] != trace.scores[indices[i - 1]]) {
          rank = i + 1;
        }
        ranking.add(
          RankedAlternative(
            alternative: eligible[index],
            score: trace.scores[index],
            rank: rank,
          ),
        );
      }
    }
    return DecisionResult(
      method: method.name,
      criteria: criteria,
      weights: matrix.weights,
      eligible: eligible,
      ranking: ranking,
      excluded: excluded,
      trace: trace,
    );
  }

  void _validateTrace(MethodEvaluation trace, int rows, int columns) {
    bool vectorValid(List<double> values) =>
        values.length == rows && values.every((v) => v.isFinite);
    bool matrixValid(List<List<double>> values) =>
        values.length == rows &&
        values.every((r) => r.length == columns && r.every((v) => v.isFinite));
    if (!vectorValid(trace.scores) ||
        !matrixValid(trace.normalized) ||
        !matrixValid(trace.weighted) ||
        !trace.diagnostics.values.every(vectorValid)) {
      throw StateError(
        'Decision method returned nonfinite values or mismatched dimensions',
      );
    }
  }
}
