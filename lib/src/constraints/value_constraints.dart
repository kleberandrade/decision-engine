import '../contracts/decision_constraint.dart';

/// Requires an observed criterion value to meet an inclusive lower bound.
final class MinimumValue implements DecisionConstraint {
  /// Creates a finite inclusive lower bound.
  MinimumValue(this.criterionId, this.minimum) {
    _validate(criterionId, minimum);
  }

  @override
  final String criterionId;

  /// Smallest accepted observed value.
  final double minimum;

  @override
  String? rejectionReason(double value) => value >= minimum
      ? null
      : '$criterionId: $value is below minimum $minimum';
}

/// Requires an observed criterion value to meet an inclusive upper bound.
final class MaximumValue implements DecisionConstraint {
  /// Creates a finite inclusive upper bound.
  MaximumValue(this.criterionId, this.maximum) {
    _validate(criterionId, maximum);
  }

  @override
  final String criterionId;

  /// Largest accepted observed value.
  final double maximum;

  @override
  String? rejectionReason(double value) =>
      value <= maximum ? null : '$criterionId: $value exceeds maximum $maximum';
}

void _validate(String id, double bound) {
  if (id.trim().isEmpty || !bound.isFinite) {
    throw ArgumentError(
      'Constraint requires a nonblank criterion ID and finite bound',
    );
  }
}
