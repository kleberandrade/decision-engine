/// An immutable named option with a numeric value for every criterion.
final class Alternative {
  /// Copies [values] and rejects blank names or nonfinite numbers.
  Alternative(this.name, {required Map<String, num> values})
      : values = Map.unmodifiable(
          values.map((k, v) => MapEntry(k, v.toDouble())),
        ) {
    if (name.trim().isEmpty) {
      throw ArgumentError.value(name, 'name', 'Must not be blank');
    }
    if (this.values.values.any((v) => !v.isFinite)) {
      throw ArgumentError('Alternative values must be finite');
    }
  }

  /// Unique name within an evaluation.
  final String name;

  /// Observed values keyed by criterion ID.
  final Map<String, double> values;
}
