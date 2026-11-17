import 'dart:io';
import 'dart:ui' as ui;
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:decision_engine_lab/main.dart';

Iterable<Element> elements(Element root) sync* {
  yield root;
  final children = <Element>[];
  root.visitChildElements(children.add);
  for (final child in children) {
    yield* elements(child);
  }
}

Future<void> main() async {
  final errors = <String>[];
  FlutterError.onError = (details) {
    errors.add(details.toString());
    stderr.writeln(details);
  };
  final binding = WidgetsFlutterBinding.ensureInitialized();
  final key = GlobalKey();
  final output = Directory(Platform.environment['DECISION_LAB_CAPTURE_DIR'] ??
      '/tmp/decision-lab-preview');
  await output.create(recursive: true);
  Future<void> frame() async {
    binding.scheduleFrame();
    await binding.endOfFrame;
  }

  Iterable<Widget> widgets() =>
      elements(binding.rootElement!).map((e) => e.widget);
  bool hasText(String text) =>
      widgets().whereType<Text>().any((w) => w.data == text);
  void check(bool condition, String message) {
    if (!condition) throw StateError(message);
  }

  Future<void> viewport(double width, double height) async {
    binding.renderViews.first.configuration = ViewConfiguration(
      logicalConstraints: BoxConstraints.tightFor(width: width, height: height),
      physicalConstraints:
          BoxConstraints.tightFor(width: width, height: height),
      devicePixelRatio: 1,
    );
    await frame();
  }

  Future<void> capture(String name) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await frame();
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!;
    await File('${output.path}/$name.png')
        .writeAsBytes(bytes.buffer.asUint8List());
  }

  DropdownButtonFormField<String> dropdown(String id) => widgets()
      .whereType<DropdownButtonFormField<String>>()
      .firstWhere((w) => w.key == Key(id));
  try {
    runApp(RepaintBoundary(key: key, child: const DecisionLabApp()));
    await binding.endOfFrame;
    await viewport(1280, 1600);
    check(hasText('3 elegíveis • 1 excluída'), 'Constrained ranking missing');
    check(widgets().any((w) => w.key == const Key('score-chart')),
        'Sensitivity chart missing');
    await capture('desktop');

    dropdown('method-selector').onChanged!('topsis');
    await frame();
    check(
        widgets()
            .whereType<Text>()
            .any((w) => w.data?.startsWith('Proximidade do ideal') ?? false),
        'TOPSIS did not update');
    widgets()
        .whereType<OutlinedButton>()
        .firstWhere((w) => w.key == const Key('apply-ahp'))
        .onPressed!();
    await frame();
    check(hasText('Disponibilidade • 60%'), 'AHP weights missing');
    check(
        hasText('Pesos AHP aplicados • CR 0.0000'), 'AHP consistency missing');
    dropdown('criterion-selector').onChanged!('availability');
    await frame();
    check(hasText('Disponibilidade • 60%'), 'Sweep changed baseline weights');
    widgets()
        .whereType<TextButton>()
        .firstWhere((w) => w.key == const Key('weights-reset'))
        .onPressed!();
    await frame();
    check(hasText('Disponibilidade • 40%'), 'Reset failed');
    for (final id in ['cost', 'latency', 'availability']) {
      widgets()
          .whereType<Slider>()
          .firstWhere((w) => w.key == Key('weight-$id'))
          .onChanged!(0);
      await frame();
    }
    check(hasText('Atribua peso positivo a pelo menos um critério.'),
        'Zero-weight state missing');
    widgets()
        .whereType<TextButton>()
        .firstWhere((w) => w.key == const Key('weights-reset'))
        .onPressed!();
    await frame();
    dropdown('method-selector').onChanged!('weighted_sum');
    await frame();
    dropdown('criterion-selector').onChanged!('cost');
    await frame();
    await viewport(390, 2200);
    await capture('narrow');
    check(errors.isEmpty, 'Framework/layout errors: ${errors.length}');
    stdout.writeln(
        'Native smoke passed: ranking, method, AHP, sweep, reset, zero weights, narrow layout; ${output.path}');
    exit(0);
  } catch (error, stack) {
    stderr.writeln('$error\n$stack');
    exit(1);
  }
}
