import 'alternative.dart';
import 'criterion.dart';

/// Validated read-only input supplied to a decision-method implementation.
///
/// Rows are eligible alternatives; columns follow [criteria]. Weights are
/// normalized and at least one criterion has positive weight.
final class DecisionMatrix {
  /// Builds a validated matrix and copies its inputs.
  DecisionMatrix({
    required List<Criterion> criteria,
    required List<Alternative> alternatives,
  })  : criteria = List.unmodifiable(criteria),
        alternatives = List.unmodifiable(alternatives) {
    if (criteria.isEmpty ||
        criteria.map((c) => c.id).toSet().length != criteria.length) {
      throw ArgumentError('Criteria must be nonempty with unique IDs');
    }
    var maxWeight = 0.0;
    for (final criterion in criteria) {
      if (criterion.weight > maxWeight) maxWeight = criterion.weight;
    }
    if (maxWeight == 0) {
      throw ArgumentError('At least one weight must be positive');
    }
    final scaled = criteria.map((c) => c.weight / maxWeight).toList();
    final total = scaled.fold(0.0, (a, b) => a + b);
    weights = List.unmodifiable(scaled.map((w) => w / total));
    if (alternatives.map((a) => a.name).toSet().length != alternatives.length) {
      throw ArgumentError('Alternative names must be unique');
    }
    for (final alternative in alternatives) {
      if (alternative.values.length != criteria.length ||
          criteria.any((c) => !alternative.values.containsKey(c.id))) {
        throw ArgumentError(
          'Alternative ${alternative.name} must match criterion IDs exactly',
        );
      }
    }
    values = List.unmodifiable(
      alternatives.map(
        (a) => List<double>.unmodifiable(criteria.map((c) => a.values[c.id]!)),
      ),
    );
  }

  /// Ordered criteria.
  final List<Criterion> criteria;

  /// Ordered eligible alternatives.
  final List<Alternative> alternatives;

  /// Relative weights, normalized without overflowing their raw sum.
  late final List<double> weights;

  /// Immutable row-major observation matrix.
  late final List<List<double>> values;
}
