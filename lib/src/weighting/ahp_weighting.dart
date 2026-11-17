import 'dart:math' as math;

import '../domain/criterion.dart';

/// Derives criterion weights from reciprocal pairwise judgments using AHP.
///
/// Supports 1–10 criteria and judgments on the continuous Saaty range [1/9, 9].
/// A[i][j] means the importance of criterion i relative to criterion j.
/// This is criterion weighting, not full hierarchical AHP alternative synthesis.
final class AhpWeighting {
  /// Configures convergence, approximate reciprocity and consistency acceptance.
  ///
  /// [tolerance] and [reciprocityTolerance] must be finite in (0, 1).
  /// [consistencyThreshold] must be finite in [0, 1). Results are accepted when
  /// CR <= threshold, independently of numerical convergence.
  AhpWeighting({
    this.tolerance = 1e-10,
    this.reciprocityTolerance = 1e-8,
    this.consistencyThreshold = 0.10,
    this.maxIterations = 10000,
  }) {
    if (!tolerance.isFinite || tolerance <= 0 || tolerance >= 1) {
      throw ArgumentError.value(tolerance, 'tolerance', 'Must be in (0, 1)');
    }
    if (!reciprocityTolerance.isFinite ||
        reciprocityTolerance <= 0 ||
        reciprocityTolerance >= 1) {
      throw ArgumentError.value(
          reciprocityTolerance, 'reciprocityTolerance', 'Must be in (0, 1)');
    }
    if (!consistencyThreshold.isFinite ||
        consistencyThreshold < 0 ||
        consistencyThreshold >= 1) {
      throw ArgumentError.value(
          consistencyThreshold, 'consistencyThreshold', 'Must be in [0, 1)');
    }
    if (maxIterations < 1) {
      throw ArgumentError.value(maxIterations, 'maxIterations', 'Must be >= 1');
    }
  }

  /// Maximum absolute weight change and relative eigenvector residual.
  final double tolerance;

  /// Absolute tolerance for diagonal unity and reciprocal products.
  final double reciprocityTolerance;

  /// Inclusive upper bound on the consistency ratio for acceptance.
  final double consistencyThreshold;

  /// Maximum number of power iterations before a convergence error.
  final int maxIterations;

  // Saaty RI convention reproduced in Ishizaka & Labib (2009), Table 1.
  // Orders 1 and 2 use the zero-consistency convention. See doc/ahp.md.
  static const _randomIndices = [
    0.0,
    0.0,
    0.58,
    0.90,
    1.12,
    1.24,
    1.32,
    1.41,
    1.45,
    1.49,
  ];

  /// Validates and copies judgments, then computes the principal eigenvector.
  ///
  /// Throws [ArgumentError] for an invalid matrix or criterion IDs and
  /// [StateError] when power iteration does not converge within the configured
  /// budget. Inconsistent but numerically converged judgments return a result
  /// with [AhpResult.isConsistent] false so callers can inspect the evidence.
  AhpResult evaluate({
    required List<String> criterionIds,
    required List<List<num>> comparisons,
  }) {
    final ids = List<String>.of(criterionIds);
    final n = ids.length;
    if (n < 1 ||
        n > 10 ||
        ids.toSet().length != n ||
        ids.any((id) => id.trim().isEmpty)) {
      throw ArgumentError('Require 1–10 unique, nonblank criterion IDs');
    }
    if (comparisons.length != n || comparisons.any((row) => row.length != n)) {
      throw ArgumentError('Comparisons must be square and match criterion IDs');
    }
    final matrix = comparisons
        .map((row) => row.map((v) => v.toDouble()).toList())
        .toList();
    for (var i = 0; i < n; i++) {
      for (var j = 0; j < n; j++) {
        final value = matrix[i][j];
        if (!value.isFinite || value < 1 / 9 || value > 9) {
          throw ArgumentError('Judgments must be finite and in [1/9, 9]');
        }
      }
      if ((matrix[i][i] - 1).abs() > reciprocityTolerance) {
        throw ArgumentError('Diagonal judgments must equal one');
      }
      for (var j = 0; j < i; j++) {
        if ((matrix[i][j] * matrix[j][i] - 1).abs() > reciprocityTolerance) {
          throw ArgumentError('Pairwise judgments must be reciprocal');
        }
      }
    }

    List<double> multiply(List<double> vector) => List.generate(
        n,
        (i) => List.generate(n, (j) => matrix[i][j] * vector[j])
            .fold(0.0, (a, b) => a + b));
    var weights = List.filled(n, 1 / n);
    for (var iteration = 1; iteration <= maxIterations; iteration++) {
      final product = multiply(weights);
      final total = product.fold(0.0, (a, b) => a + b);
      final next = product.map((v) => v / total).toList();
      final change = List.generate(n, (i) => (next[i] - weights[i]).abs())
          .fold(0.0, math.max);
      weights = next;
      if (change > tolerance) continue;
      final aw = multiply(weights);
      final lambda = List.generate(n, (i) => aw[i] / weights[i])
              .fold(0.0, (a, b) => a + b) /
          n;
      final residual =
          List.generate(n, (i) => (aw[i] - lambda * weights[i]).abs())
                  .fold(0.0, math.max) /
              lambda;
      if (residual > tolerance) continue;
      final ci = n <= 2 ? 0.0 : math.max(0.0, (lambda - n) / (n - 1));
      final ri = _randomIndices[n - 1];
      return AhpResult._(
        criterionIds: ids,
        comparisons: matrix,
        weights: weights,
        lambdaMax: lambda,
        consistencyIndex: ci,
        randomIndex: ri,
        consistencyRatio: ri == 0 ? 0 : ci / ri,
        consistencyThreshold: consistencyThreshold,
        iterations: iteration,
        residual: residual,
      );
    }
    throw StateError(
        'AHP power iteration did not converge in $maxIterations iterations');
  }
}

/// Immutable AHP weights and evidence of numerical and judgment consistency.
final class AhpResult {
  AhpResult._({
    required List<String> criterionIds,
    required List<List<double>> comparisons,
    required List<double> weights,
    required this.lambdaMax,
    required this.consistencyIndex,
    required this.randomIndex,
    required this.consistencyRatio,
    required this.consistencyThreshold,
    required this.iterations,
    required this.residual,
  })  : criterionIds = List.unmodifiable(criterionIds),
        comparisons = List.unmodifiable(
            comparisons.map((row) => List<double>.unmodifiable(row))),
        weights = Map.unmodifiable(Map.fromIterables(criterionIds, weights));

  /// Unique IDs in matrix row/column order.
  final List<String> criterionIds;

  /// Original validated judgments, including accepted floating-point noise.
  final List<List<double>> comparisons;

  /// Positive principal-eigenvector weights, normalized to sum to one.
  final Map<String, double> weights;

  /// Estimated principal eigenvalue of the judgment matrix.
  final double lambdaMax;

  /// max(0, (lambdaMax - n)/(n - 1)); zero by convention for n <= 2.
  final double consistencyIndex;

  /// Reference random consistency index for this matrix order.
  final double randomIndex;

  /// CI / RI, or zero by convention when RI is zero.
  final double consistencyRatio;

  /// Inclusive acceptance threshold chosen by the caller.
  final double consistencyThreshold;

  /// Power iterations needed to satisfy the convergence checks.
  final int iterations;

  /// max(abs(A*w - lambdaMax*w)) / lambdaMax at convergence.
  final double residual;

  /// Whether CR meets the configured threshold; not a correctness guarantee.
  bool get isConsistent => consistencyRatio <= consistencyThreshold;

  /// Builds ordered criteria for either ranking method with explicit directions.
  ///
  /// [directions] must match the IDs exactly. By default, inconsistent judgments
  /// throw [StateError]. Inspect the evidence and explicitly set
  /// [requireConsistency] false to adopt such weights.
  List<Criterion> toCriteria(Map<String, CriterionDirection> directions,
      {bool requireConsistency = true}) {
    if (directions.length != criterionIds.length ||
        criterionIds.any((id) => !directions.containsKey(id))) {
      throw ArgumentError('Directions must match AHP criterion IDs exactly');
    }
    if (requireConsistency && !isConsistent) {
      throw StateError('AHP consistency ratio $consistencyRatio exceeds '
          'threshold $consistencyThreshold');
    }
    return List.unmodifiable(criterionIds.map((id) =>
        directions[id] == CriterionDirection.maximize
            ? Criterion.maximize(id, weight: weights[id]!)
            : Criterion.minimize(id, weight: weights[id]!)));
  }
}
