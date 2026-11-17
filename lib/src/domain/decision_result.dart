import 'alternative.dart';
import 'criterion.dart';
import 'method_evaluation.dart';

/// A scored alternative and its competition rank.
final class RankedAlternative {
  /// Creates a ranking entry; equal scores share a rank (1, 1, 3).
  const RankedAlternative({
    required this.alternative,
    required this.score,
    required this.rank,
  });

  /// Original immutable alternative.
  final Alternative alternative;

  /// Method score; higher values are preferred within this evaluation.
  final double score;

  /// One-based competition rank.
  final int rank;
}

/// An alternative excluded before the decision method runs.
final class ExcludedAlternative {
  /// Copies the rejection reasons.
  ExcludedAlternative(this.alternative, List<String> reasons)
      : reasons = List.unmodifiable(reasons);

  /// Original excluded alternative.
  final Alternative alternative;

  /// All failed eligibility requirements.
  final List<String> reasons;
}

/// Immutable evidence for a complete decision, including rejected options.
final class DecisionResult {
  /// Copies result collections; trace rows follow [eligible], not [ranking].
  DecisionResult({
    required this.method,
    required List<Criterion> criteria,
    required List<double> weights,
    required List<Alternative> eligible,
    required List<RankedAlternative> ranking,
    required List<ExcludedAlternative> excluded,
    required this.trace,
  })  : criteria = List.unmodifiable(criteria),
        weights = List.unmodifiable(weights),
        eligible = List.unmodifiable(eligible),
        ranking = List.unmodifiable(ranking),
        excluded = List.unmodifiable(excluded);

  /// Selected strategy identifier.
  final String method;

  /// Criteria in trace column order.
  final List<Criterion> criteria;

  /// Normalized relative weights in criterion order.
  final List<double> weights;

  /// Eligible alternatives in original input order, matching trace rows.
  final List<Alternative> eligible;

  /// Descending scores; exact ties preserve original input order.
  final List<RankedAlternative> ranking;

  /// Rejected alternatives and all their failure reasons.
  final List<ExcludedAlternative> excluded;

  /// Method calculations, or null when there are no eligible alternatives.
  final MethodEvaluation? trace;

  /// First ranked alternative, or null for an empty eligible set.
  ///
  /// This is a deterministic representative of a tie, not a unique winner.
  Alternative? get best => ranking.isEmpty ? null : ranking.first.alternative;
}
