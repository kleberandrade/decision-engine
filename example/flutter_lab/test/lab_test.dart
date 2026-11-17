import 'package:decision_engine_lab/main.dart';
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('dashboard ranks constrained options and renders a sampled chart',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const DecisionLabApp());
    expect(find.byKey(const Key('ranking')), findsOneWidget);
    expect(find.byKey(const Key('score-chart')), findsOneWidget);
    expect(find.text('3 elegíveis • 1 excluída'), findsOneWidget);
    expect(find.textContaining('21 cenários'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'method selection recomputes and AHP weights can be applied and reset',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const DecisionLabApp());
    await tester.tap(find.byKey(const Key('method-selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('TOPSIS').last);
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<DropdownButtonFormField<String>>(
                find.byKey(const Key('method-selector')))
            .initialValue,
        'topsis');
    await tester.tap(find.byKey(const Key('apply-ahp')));
    await tester.pumpAndSettle();
    expect(find.text('Disponibilidade • 60%'), findsOneWidget);
    expect(find.text('Pesos AHP aplicados • CR 0.0000'), findsOneWidget);
    await tester.tap(find.byKey(const Key('weights-reset')));
    await tester.pumpAndSettle();
    expect(find.text('Disponibilidade • 40%'), findsOneWidget);
    expect(find.textContaining('Pesos AHP aplicados'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sweep criterion changes without altering the baseline weights',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const DecisionLabApp());
    await tester.ensureVisible(find.byKey(const Key('criterion-selector')));
    await tester.tap(find.byKey(const Key('criterion-selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Disponibilidade').last);
    await tester.pumpAndSettle();
    expect(find.text('Disponibilidade • 40%'), findsOneWidget);
    expect(find.byKey(const Key('score-chart')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('narrow screen remains scrollable without layout exceptions',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const DecisionLabApp());
    await tester.ensureVisible(find.byKey(const Key('score-chart')));
    await tester.pumpAndSettle();
    expect(find.text('Memória de cálculo'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
