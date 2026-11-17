/// Whether larger or smaller values are preferred.
enum CriterionDirection {
  /// Prefer larger values.
  maximize,

  /// Prefer smaller values.
  minimize,
}

/// An immutable criterion with a finite, nonnegative relative weight.
final class Criterion {
  /// Creates a criterion whose larger values are preferred.
  Criterion.maximize(this.id, {required this.weight})
      : direction = CriterionDirection.maximize {
    _validate();
  }

  /// Creates a criterion whose smaller values are preferred.
  Criterion.minimize(this.id, {required this.weight})
      : direction = CriterionDirection.minimize {
    _validate();
  }

  /// Unique, nonblank key used in alternative value maps.
  final String id;

  /// Relative importance; the engine normalizes weights to sum to one.
  final double weight;

  /// Preference direction.
  final CriterionDirection direction;

  void _validate() {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Must not be blank');
    }
    if (!weight.isFinite || weight < 0) {
      throw ArgumentError.value(weight, 'weight', 'Must be finite and >= 0');
    }
  }
}
