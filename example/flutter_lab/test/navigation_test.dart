import 'dart:convert';
import 'package:decision_engine_lab/main.dart';
import 'package:decision_engine_lab/lab_frame.dart';
// Compatibility with the lab's Flutter >=3.35 minimum.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> start(WidgetTester tester, {bool mobile = false}) async {
    tester.view.physicalSize =
        mobile ? const Size(390, 844) : const Size(1440, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const DecisionLabApp());
  }

  Future<void> tap(WidgetTester tester, String id) async {
    await tester.ensureVisible(find.byKey(Key(id)));
    await tester.tap(find.byKey(Key(id)));
    await tester.pumpAndSettle();
  }

  Future<void> language(WidgetTester tester, String label) async {
    await tap(tester, label == 'English' ? 'language-en' : 'language-pt');
  }

  testWidgets(
      'language and Learn navigation preserve AHP scenario; examples run',
      (tester) async {
    await start(tester);
    await tap(tester, 'apply-ahp');
    await tap(tester, 'ahp-demo');
    await tap(tester, 'ahp-apply');
    await language(tester, 'English');
    expect(find.text('Availability • 60%'), findsOneWidget);
    expect(find.text('Import / export JSON'), findsOneWidget);
    await tap(tester, 'nav-1');
    expect(find.text('Learn explainable decisions'), findsOneWidget);
    await tap(tester, 'nav-0');
    expect(find.text('Availability • 60%'), findsOneWidget);
    await tap(tester, 'scenario-edit');
    final data = jsonDecode(tester
        .widget<TextField>(find.byKey(const Key('scenario-json')))
        .controller!
        .text) as Map<String, dynamic>;
    expect(data['ahp'], isNotNull);
    expect(data['criteria'][2]['weight'], closeTo(.6, 1e-8));
    await tap(tester, 'scenario-cancel');
    await tap(tester, 'nav-2');
    await tap(tester, 'preset-budget');
    expect(find.text('2 eligible • 2 excluded'), findsOneWidget);
    await language(tester, 'PT-BR');
    expect(find.text('2 elegíveis • 2 excluídas'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('mobile menu, keyboard and educational preset remain accessible',
      (tester) async {
    await start(tester, mobile: true);
    await tap(tester, 'mobile-navigation');
    await tester.tap(find.text('Aprender').last);
    await tester.pumpAndSettle();
    expect(find.text('Aprender com decisões explicáveis'), findsOneWidget);
    await tap(tester, 'learn-example');
    expect(find.byKey(const Key('ranking')), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(tester.binding.focusManager.primaryFocus, isNotNull);
    await language(tester, 'English');
    await tap(tester, 'apply-ahp');
    expect(find.text('AHP pairwise comparison matrix'), findsOneWidget);
    await tap(tester, 'ahp-cancel');
    expect(tester.takeException(), isNull);
  });
  testWidgets('documentation and GitHub actions target real repository URLs',
      (tester) async {
    await start(tester);
    String? copied;
    tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        copied = (call.arguments as Map)['text'] as String;
      }
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));
    await tap(tester, 'nav-docs');
    expect(copied, '$repositoryUrl/blob/main/doc/getting_started.pt-BR.md');
    await tap(tester, 'nav-github');
    expect(copied, repositoryUrl);
  });

  testWidgets('all educational examples load complete reproducible scenarios',
      (tester) async {
    await start(tester);
    for (final id in presetIds) {
      await tap(tester, 'nav-2');
      await tap(tester, 'preset-$id');
      final count = id == 'budget'
          ? '2 elegíveis • 2 excluídas'
          : id == 'availability'
              ? '0 elegíveis • 4 excluídas'
              : '3 elegíveis • 1 excluída';
      expect(find.text(count), findsOneWidget);
      if (id == 'ahp') {
        expect(find.text('Disponibilidade • 60%'), findsOneWidget);
      }
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('circular language buttons expose labels and selected state',
      (tester) async {
    await start(tester, mobile: true);
    expect(find.byTooltip('Português (Brasil)'), findsOneWidget);
    expect(find.byTooltip('Inglês (Reino Unido)'), findsOneWidget);
    expect(
        tester
            .widget<IconButton>(find.byKey(const Key('language-pt')))
            .isSelected,
        isTrue);
    await tap(tester, 'language-en');
    expect(
        tester
            .widget<IconButton>(find.byKey(const Key('language-en')))
            .isSelected,
        isTrue);
    expect(find.byTooltip('Portuguese (Brazil)'), findsOneWidget);
    expect(find.byTooltip('English (United Kingdom)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('English review previews keep the applied scenario unchanged',
      (tester) async {
    await start(tester);
    await language(tester, 'English');
    await tap(tester, 'apply-ahp');
    for (final edit in [
      ('ahp-0-1', '9'),
      ('ahp-0-2', '1/9'),
      ('ahp-1-2', '9')
    ]) {
      await tester.ensureVisible(find.byKey(Key(edit.$1)));
      await tester.enterText(find.byKey(Key(edit.$1)), edit.$2);
      await tester.pumpAndSettle();
    }
    await tap(tester, 'ahp-diagnose');
    expect(find.text('Priority comparisons for review'), findsOneWidget);
    await tap(tester, 'ahp-preview-0-1');
    expect(find.text('Adjustment preview — scenario still unchanged'),
        findsOneWidget);
    expect(find.textContaining('CR before: 6.1302682'), findsOneWidget);
    expect(find.textContaining('CR after: 0.48347731'), findsOneWidget);
    await tap(tester, 'ahp-preview-cancel');
    await tap(tester, 'ahp-cancel');
    expect(find.text('Availability • 40%'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
