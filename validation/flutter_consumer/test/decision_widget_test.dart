import 'package:decision_engine/decision_engine.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final method in <DecisionMethod>[const WeightedSum(), const Topsis()]) {
    testWidgets('${method.name} renders an eligible winner in Flutter',
        (tester) async {
      final result = DecisionEngine(
        criteria: [Criterion.maximize('quality', weight: 1)],
        constraints: [MinimumValue('quality', 5)],
        method: method,
      ).evaluate([
        Alternative('Excluded', values: {'quality': 1}),
        Alternative('Basic', values: {'quality': 5}),
        Alternative('Premium', values: {'quality': 10}),
      ]);
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: Text(result.best?.name ?? 'No eligible option'),
      ));
      expect(find.text('Premium'), findsOneWidget);
      expect(result.excluded.single.alternative.name, 'Excluded');
      expect(result.ranking.first.score, 1);
    });
  }
}
