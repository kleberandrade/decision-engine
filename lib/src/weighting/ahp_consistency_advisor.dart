import 'dart:math' as math;
import 'ahp_weighting.dart';

/// Prioritizes pairwise judgments by their disagreement with indirect triads.
///
/// This is a review heuristic, not evidence that an individual judgment is wrong.
/// For each i<j, severity is mean_k |log(Aij)-log(Aik)-log(Akj)|, k != i,j.
/// Suggestions test the bounded geometric mean of indirect paths and three
/// log-space intermediate steps. Each candidate changes one reciprocal pair;
/// the existing [AhpWeighting] evaluates its actual CR. No global optimum or
/// complete repair is promised, and preferences must be reviewed by a person.
final class AhpConsistencyAdvisor {
  /// Creates a stateless advisor using the core's default convergence policy.
  const AhpConsistencyAdvisor();

  /// Reviews immutable, previously validated AHP evidence without changing it.
  ///
  /// The baseline is reevaluated under default convergence/reciprocity settings,
  /// retaining its consistency threshold. Matrices accepted only under looser
  /// custom reciprocity tolerances throw [ArgumentError] at this boundary.
  /// Orders <3 have no triads. Deviations <=1e-10 are treated as numerical noise.
  /// Only candidates reducing CR by >1e-12 are offered. Nonconvergent candidates
  /// are skipped; the diagnosis remains available even without an improvement.
  AhpConsistencyReview review(AhpResult source) {
    source = AhpWeighting(consistencyThreshold: source.consistencyThreshold)
        .evaluate(
            criterionIds: source.criterionIds, comparisons: source.comparisons);
    final n = source.criterionIds.length;
    final pairs = <AhpComparisonReview>[];
    for (var i = 0; i < n; i++) {
      for (var j = i + 1; j < n; j++) {
        if (n < 3) continue;
        final logValue = math.log(source.comparisons[i][j]);
        var sum = 0.0;
        var deviation = 0.0;
        var largest = -1.0;
        var witness = -1;
        for (var k = 0; k < n; k++) {
          if (k == i || k == j) continue;
          final indirect = math.log(source.comparisons[i][k]) +
              math.log(source.comparisons[k][j]);
          final distance = (logValue - indirect).abs();
          sum += indirect;
          deviation += distance;
          if (distance > largest) {
            largest = distance;
            witness = k;
          }
        }
        final severity = deviation / (n - 2);
        if (severity <= 1e-10) continue;
        final target = sum / (n - 2);
        pairs.add(AhpComparisonReview._(
            i, j, severity, n - 2, witness, _suggest(source, i, j, target)));
      }
    }
    pairs.sort((a, b) {
      final severity = b.meanLogDeviation.compareTo(a.meanLogDeviation);
      if (severity != 0) return severity;
      final row = a.row.compareTo(b.row);
      return row != 0 ? row : a.column.compareTo(b.column);
    });
    return AhpConsistencyReview._(source, pairs);
  }

  AhpAdjustment? _suggest(AhpResult source, int i, int j, double targetLog) {
    final low = math.log(1 / 9);
    final high = math.log(9);
    final bounded = targetLog.clamp(low, high).toDouble();
    final current = math.log(source.comparisons[i][j]);
    final evaluator =
        AhpWeighting(consistencyThreshold: source.consistencyThreshold);
    AhpAdjustment? best;
    var bestCr = source.consistencyRatio;
    for (final fraction in [1.0, .75, .5, .25]) {
      final value = math
          .exp(current + (bounded - current) * fraction)
          .clamp(1 / 9, 9)
          .toDouble();
      final matrix = [
        for (final row in source.comparisons) List<double>.of(row)
      ];
      matrix[i][j] = value;
      matrix[j][i] = 1 / value;
      try {
        final result = evaluator.evaluate(
            criterionIds: source.criterionIds, comparisons: matrix);
        if (result.consistencyRatio < bestCr - 1e-12) {
          bestCr = result.consistencyRatio;
          best = AhpAdjustment._(
              value, result, targetLog < low || targetLog > high);
        }
      } on StateError {
        // No provisional/nonconvergent candidate is exposed as an improvement.
        continue;
      }
    }
    return best;
  }
}

/// Immutable review of a baseline and its nontrivial comparison disagreements.
final class AhpConsistencyReview {
  AhpConsistencyReview._(this.baseline, List<AhpComparisonReview> comparisons)
      : comparisons = List.unmodifiable(comparisons);

  /// Original immutable evidence used for every independent one-pair preview.
  final AhpResult baseline;

  /// Descending mean absolute log disagreement; ties follow row/column order.
  final List<AhpComparisonReview> comparisons;
}

/// A pair's disagreement with all available two-edge indirect paths.
final class AhpComparisonReview {
  AhpComparisonReview._(this.row, this.column, this.meanLogDeviation,
      this.triadCount, this.witness, this.adjustment);

  /// Upper-triangle row index in baseline criterion order.
  final int row;

  /// Upper-triangle column index in baseline criterion order.
  final int column;

  /// Mean absolute log deviation, zero for multiplicatively consistent triads.
  final double meanLogDeviation;

  /// Number of indirect paths supporting the diagnostic (n-2).
  final int triadCount;

  /// Criterion index forming the pair's most-disagreeing triad.
  final int witness;

  /// Best improving candidate among the four tested steps, or null.
  final AhpAdjustment? adjustment;
}

/// Immutable one-pair preview; constructing it never adopts its weights.
final class AhpAdjustment {
  AhpAdjustment._(this.value, this.evaluation, this.targetWasClamped);

  /// Suggested Aij; Aji becomes its reciprocal.
  final double value;

  /// Complete recalculated candidate evidence, including its actual CR/weights.
  final AhpResult evaluation;

  /// Whether the indirect geometric-mean target exceeded [1/9,9].
  final bool targetWasClamped;
}
