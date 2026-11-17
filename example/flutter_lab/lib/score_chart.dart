// ignore: deprecated_member_use
import 'package:flutter/material.dart' hide Text;
import 'localization.dart';
import 'package:decision_engine/decision_engine.dart';

const seriesColors = [Color(0xFF5DE4C7), Color(0xFF8CA9FF), Color(0xFFFFC770)];

class ScoreChart extends StatelessWidget {
  const ScoreChart(
      {super.key, required this.report, required this.criterionId});
  final SensitivityReport report;
  final String criterionId;

  @override
  Widget build(BuildContext context) => Semantics(
        label: tr(context,
            'Gráfico de notas por peso amostrado. Consulte os intervalos de mudança abaixo.'),
        child: SizedBox(
            height: 260,
            width: double.infinity,
            child: CustomPaint(painter: _ScorePainter(report, criterionId))),
      );
}

class _ScorePainter extends CustomPainter {
  _ScorePainter(this.report, this.criterionId);
  final SensitivityReport report;
  final String criterionId;

  void label(Canvas canvas, String text, Offset point,
      {Color color = const Color(0xFF94A5BA)}) {
    final painter = TextPainter(
        text:
            TextSpan(text: text, style: TextStyle(color: color, fontSize: 11)),
        textDirection: TextDirection.ltr)
      ..layout();
    painter.paint(canvas, point);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final area = Rect.fromLTRB(38, 12, size.width - 22, size.height - 32);
    if (area.width <= 0 || area.height <= 0) return;
    final grid = Paint()
      ..color = const Color(0xFF26374A)
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final f = i / 4;
      final y = area.bottom - area.height * f;
      canvas.drawLine(Offset(area.left, y), Offset(area.right, y), grid);
      label(canvas, f.toStringAsFixed(2), Offset(0, y - 6));
      final x = area.left + area.width * f;
      label(canvas, '${(f * 100).round()}%', Offset(x - 9, area.bottom + 10));
    }
    final column =
        report.baseline.criteria.indexWhere((c) => c.id == criterionId);
    for (var series = 0; series < report.baseline.eligible.length; series++) {
      final name = report.baseline.eligible[series].name;
      final path = Path();
      final color = seriesColors[series % seriesColors.length];
      for (var i = 0; i < report.scenarios.length; i++) {
        final sample = report.scenarios[i].result;
        final score = sample.ranking
            .firstWhere((r) => r.alternative.name == name)
            .score
            .clamp(0.0, 1.0);
        final point = Offset(area.left + area.width * sample.weights[column],
            area.bottom - area.height * score);
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
        canvas.drawCircle(point, 2.5, Paint()..color = color);
      }
      canvas.drawPath(
          path,
          Paint()
            ..color = color
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _ScorePainter oldDelegate) =>
      oldDelegate.report != report || oldDelegate.criterionId != criterionId;
}
