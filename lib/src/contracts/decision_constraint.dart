/// An eligibility requirement evaluated before normalization and ranking.
abstract interface class DecisionConstraint {
  /// Criterion whose observed value is checked.
  String get criterionId;

  /// Returns null for an accepted value, otherwise an exclusion reason.
  String? rejectionReason(double value);
}
