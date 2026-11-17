import 'package:decision_engine/decision_engine.dart';
import 'package:decision_engine_lab/configuration.dart';
import 'package:decision_engine_lab/main.dart';
import 'dart:convert';
import 'package:decision_engine_lab/visual_editor.dart';
// Keep the lab's Flutter >=3.35 import path; 3.50 deprecates this re-export.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> launch(
      WidgetTester tester, void Function(LabConfiguration?) save,
      {bool narrow = false, Map<String, double>? weights}) async {
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
                    onPressed: () async => save(
                        await showDialog<LabConfiguration>(
                            context: context,
                            builder: (_) => VisualScenarioEditor(
                                configuration: LabConfiguration.sample(),
                                relativeWeights: weights))),
                    child: const Text('Open'))))));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, String key) async {
    await tester.ensureVisible(find.byKey(Key(key)));
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  Future<void> enter(WidgetTester tester, String key, String text) async {
    await tester.ensureVisible(find.byKey(Key(key)));
    await tester.enterText(find.byKey(Key(key)), text);
    await tester.pump();
  }

  testWidgets(
      'edits values, weights and bounds, validates then evaluates real core',
      (tester) async {
    LabConfiguration? result;
    await launch(tester, (value) => result = value);
    await enter(tester, 'criterion-label-cost', 'Preço');
    await enter(tester, 'criterion-weight-cost', '1');
    await enter(tester, 'criterion-weight-latency', '0');
    await enter(tester, 'criterion-weight-availability', '0');
    await enter(tester, 'alternative-name-0', 'Atlas editado');
    await enter(tester, 'value-0-cost', '500');
    await enter(tester, 'bound-min-0', '100');
    await tap(tester, 'visual-apply');
    expect(result, isNotNull);
    expect(result!.labels['cost'], 'Preço');
    expect(
        result!
            .engine(const WeightedSum())
            .evaluate(result!.alternatives)
            .ranking,
        isEmpty);
    expect(result!.alternatives.first.values['cost'], 500);
    expect(result!.alternatives.first.name, 'Atlas editado');
    expect(tester.takeException(), isNull);
  });
  testWidgets('adds and removes dependent rows and preserves import/export',
      (tester) async {
    LabConfiguration? result;
    await launch(tester, (value) => result = value);
    await tap(tester, 'add-criterion');
    await enter(tester, 'criterion-label-criterion1', 'Suporte');
    await tap(tester, 'remove-criterion-latency');
    await tap(tester, 'add-alternative');
    await tap(tester, 'remove-alternative-1');
    await tap(tester, 'add-bound');
    await tap(tester, 'remove-bound-0');
    await tap(tester, 'visual-apply');
    final restored = LabConfiguration.parse(result!.encode());
    expect(restored.criteria.map((c) => c.id),
        ['cost', 'availability', 'criterion1']);
    expect(restored.alternatives.length, 4);
    expect(
        restored.alternatives.every((a) => a.values.keys.length == 3), isTrue);
    expect(restored.bounds.length, 1);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'invalid numbers stay editable and cancel preserves source on mobile',
      (tester) async {
    LabConfiguration? result;
    await launch(tester, (value) => result = value, narrow: true);
    await enter(tester, 'criterion-weight-cost', '-1');
    await tap(tester, 'visual-apply');
    expect(result, isNull);
    expect(find.textContaining('Revise os campos destacados'), findsOneWidget);
    expect(find.text('Use um número finito entre 0 e 1e12.'), findsOneWidget);
    await tap(tester, 'visual-cancel');
    expect(result, isNull);
    expect(LabConfiguration.sample().criteria.first.weight, 0.35);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'visual apply updates dashboard and JSON with direction and maximum',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const DecisionLabApp());
    await tap(tester, 'visual-editor');
    await tap(tester, 'direction-cost');
    await tester.tap(find.text('Maior é melhor').last);
    await tester.pumpAndSettle();
    await enter(tester, 'criterion-label-cost', 'Preço editado');
    await enter(tester, 'bound-min-0', '');
    await enter(tester, 'bound-max-0', '99,9');
    await tap(tester, 'visual-apply');
    expect(find.text('2 elegíveis • 2 excluídas'), findsOneWidget);
    await tap(tester, 'scenario-edit');
    final text = tester
        .widget<TextField>(find.byKey(const Key('scenario-json')))
        .controller!
        .text;
    final data = jsonDecode(text) as Map<String, dynamic>;
    expect(data['criteria'][0]['label'], 'Preço editado');
    expect(data['criteria'][0]['direction'], 'maximize');
    expect(data['constraints'][0]['maximum'], 99.9);
    expect(data['constraints'][0].containsKey('minimum'), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'visual form supports large text, labels and touch on narrow screens',
      (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final semantics = tester.ensureSemantics();
    try {
      await launch(tester, (_) {}, narrow: true);
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await enter(tester, 'bound-min-0', '99.95');
      await tap(tester, 'visual-cancel');
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('zero current slider weights remain visible and can be repaired',
      (tester) async {
    LabConfiguration? result;
    await launch(tester, (value) => result = value,
        weights: {'cost': 0, 'latency': 0, 'availability': 0});
    expect(
        tester
            .widget<TextFormField>(
                find.byKey(const Key('criterion-weight-cost')))
            .initialValue,
        '0.0');
    await tap(tester, 'visual-apply');
    expect(result, isNull);
    expect(find.textContaining('Não foi possível aplicar'), findsOneWidget);
    await enter(tester, 'criterion-weight-cost', '1');
    await tap(tester, 'visual-apply');
    expect(result!.criteria.first.weight, 1);
    expect(result!.criteria.last.weight, 0);
    expect(tester.takeException(), isNull);
  });
}
