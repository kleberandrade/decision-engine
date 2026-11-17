import 'dart:convert';
import 'package:decision_engine/decision_engine.dart';
import 'package:decision_engine_lab/ahp_editor.dart';
import 'package:decision_engine_lab/configuration.dart';
import 'package:decision_engine_lab/main.dart';
// Compatibility with the lab's Flutter >=3.35 minimum.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'applied judgments and weights round trip; altered weights drop stale AHP',
      () {
    final source = LabConfiguration.sample();
    final result = AhpWeighting().evaluate(criterionIds: [
      'cost',
      'latency',
      'availability'
    ], comparisons: [
      [1, 3, 0.5],
      [1 / 3, 1, 1 / 6],
      [2, 6, 1]
    ]);
    final applied = source.withAhp(result);
    final restored = LabConfiguration.parse(applied.encode());
    expect(restored.ahpResult!.consistencyRatio, closeTo(0, 1e-10));
    expect(restored.criteria.map((c) => c.weight),
        orderedEquals(result.weights.values));
    expect(
        jsonDecode(applied.encode({'cost': 1, 'latency': 0, 'availability': 0}))
            .containsKey('ahp'),
        isFalse);
    final invalid = jsonDecode(applied.encode()) as Map<String, dynamic>;
    invalid['criteria'][0]['weight'] = 5;
    expect(() => LabConfiguration.parse(jsonEncode(invalid)),
        throwsFormatException);
  });

  Future<void> launch(WidgetTester tester, void Function(AhpResult?) save,
      {bool narrow = false, List<Criterion>? criteria}) async {
    tester.view.physicalSize =
        narrow ? const Size(390, 844) : const Size(1200, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        theme: ThemeData.dark(useMaterial3: true),
        home: Builder(
            builder: (context) => Scaffold(
                body: TextButton(
                    onPressed: () async {
                      save(await showDialog<AhpResult>(
                          context: context,
                          builder: (_) => AhpMatrixEditor(
                              criteria: criteria ??
                                  LabConfiguration.sample().criteria,
                              labels: LabConfiguration.sample().labels)));
                    },
                    child: const Text('Open'))))));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  Future<void> edit(WidgetTester tester, String key, String value) async {
    await tester.ensureVisible(find.byKey(Key(key)));
    await tester.enterText(find.byKey(Key(key)), value);
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, String key) async {
    await tester.ensureVisible(find.byKey(Key(key)));
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  testWidgets('reciprocal edits calculate independent ratio weights and apply',
      (tester) async {
    AhpResult? result;
    await launch(tester, (value) => result = value);
    await edit(tester, 'ahp-0-1', '3');
    await edit(tester, 'ahp-0-2', '1/2');
    await edit(tester, 'ahp-1-2', '1/6');
    expect(find.byKey(const Key('ahp-matrix')), findsOneWidget);
    expect(find.text('CR 0.0000'), findsOneWidget);
    await tap(tester, 'ahp-apply');
    expect(result!.weights['cost'], closeTo(0.3, 1e-9));
    expect(result!.weights['latency'], closeTo(0.1, 1e-9));
    expect(result!.weights['availability'], closeTo(0.6, 1e-9));
    expect(result!.comparisons[1][0], closeTo(1 / 3, 1e-12));
    expect(tester.takeException(), isNull);
  });
  testWidgets('invalid and inconsistent matrices never apply stale weights',
      (tester) async {
    AhpResult? result;
    await launch(tester, (value) => result = value);
    await edit(tester, 'ahp-0-1', '9');
    await edit(tester, 'ahp-0-2', '1/9');
    await edit(tester, 'ahp-1-2', '9');
    expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('ahp-apply')))
            .onPressed,
        isNull);
    expect(find.textContaining('Inconsistente'), findsOneWidget);
    for (final invalid in ['0', '10', '1/0', '1/10', 'NaN']) {
      await edit(tester, 'ahp-0-1', invalid);
      expect(
          tester
              .widget<FilledButton>(find.byKey(const Key('ahp-apply')))
              .onPressed,
          isNull);
    }
    expect(find.byKey(const Key('ahp-cr')), findsNothing);
    expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('ahp-apply')))
            .onPressed,
        isNull);
    await tap(tester, 'ahp-cancel');
    expect(result, isNull);
    expect(tester.takeException(), isNull);
  });
  testWidgets('single criterion convention and mobile accessibility',
      (tester) async {
    AhpResult? result;
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final semantics = tester.ensureSemantics();
    try {
      await launch(tester, (value) => result = value,
          narrow: true, criteria: [Criterion.maximize('cost', weight: 1)]);
      expect(find.text('CR 0.0000'), findsOneWidget);
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await tap(tester, 'ahp-apply');
      expect(result!.weights['cost'], 1);
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });
  testWidgets('dashboard applies editable AHP and exports evidence',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const DecisionLabApp());
    await tap(tester, 'apply-ahp');
    await tap(tester, 'ahp-demo');
    await tap(tester, 'ahp-apply');
    expect(find.text('Disponibilidade • 60%'), findsOneWidget);
    await tap(tester, 'scenario-edit');
    final json = tester
        .widget<TextField>(find.byKey(const Key('scenario-json')))
        .controller!
        .text;
    expect(LabConfiguration.parse(json).ahpResult!.weights['availability'],
        closeTo(0.6, 1e-9));
    expect(tester.takeException(), isNull);
  });

  testWidgets('two, four and ten custom criteria use the full matrix',
      (tester) async {
    for (final n in [2, 4, 10]) {
      AhpResult? result;
      await launch(tester, (value) => result = value,
          criteria: List.generate(
              n, (i) => Criterion.maximize('custom$i', weight: 1)));
      expect(find.byType(TextField), findsNWidgets(n * (n - 1) ~/ 2));
      await tap(tester, 'ahp-apply');
      expect(result!.weights.length, n);
      for (final weight in result!.weights.values) {
        expect(weight, closeTo(1 / n, 1e-10));
      }
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('eleven criteria retain manual weights and explain the AHP limit',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const DecisionLabApp());
    await tap(tester, 'scenario-edit');
    await tester.enterText(
        find.byKey(const Key('scenario-json')),
        jsonEncode({
          'criteria': [
            for (var i = 0; i < 11; i++)
              {'id': 'c$i', 'direction': 'maximize', 'weight': 1}
          ],
          'alternatives': [
            {
              'name': 'Only',
              'values': {for (var i = 0; i < 11; i++) 'c$i': 0}
            }
          ],
          'constraints': [],
        }));
    await tap(tester, 'scenario-apply');
    expect(
        tester
            .widget<OutlinedButton>(find.byKey(const Key('apply-ahp')))
            .onPressed,
        isNull);
    expect(find.textContaining('Com mais de 10 critérios'), findsOneWidget);
    expect(find.byKey(const Key('ranking')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('consistency remains visible while a mobile matrix scrolls',
      (tester) async {
    await launch(tester, (_) {}, narrow: true);
    expect(find.byKey(const Key('ahp-cr')).hitTestable(), findsOneWidget);
    await tap(tester, 'ahp-cancel');
  });
}
